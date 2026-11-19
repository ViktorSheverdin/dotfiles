#!/usr/bin/env python3
"""memwatch: sample system + nvim memory into a JSONL log.

Run periodically by a systemd user timer (see ~/.config/systemd/user/memwatch.*).
Each run appends ONE line to ~/.local/state/memwatch/samples-YYYY-MM-DD.jsonl.

What is recorded per sample:
  system   RAM/swap/zram numbers + memory pressure (PSI)
  top      top 20 processes by RSS+swap
  nvim     every running nvim: RSS, swap, peak (VmHWM), uptime, cwd,
           language-server children, and - via its RPC socket - Lua heap,
           timer counts/origins, buffers, LSP clients
nvim-side spike events (written by lua/viktor/core/mem-guard.lua) go to
~/.local/state/memwatch/nvim-events.jsonl.
"""
import glob
import json
import os
import subprocess
import time

STATE = os.path.expanduser("~/.local/state/memwatch")
RUNTIME = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
CLK = os.sysconf("SC_CLK_TCK")
BOOT = time.time() - float(open("/proc/uptime").read().split()[0])

# Read-only probe evaluated inside each nvim over RPC.
NVIM_PROBE = r"""
local t = {total = 0, running = 0, stopped = 0}
local origins = {}
local trace = _G.MemGuardDebug and _G.MemGuardDebug.timer_trace or {}
vim.uv.walk(function(h)
  if h:get_type() ~= "timer" then return end
  t.total = t.total + 1
  if h:is_active() then t.running = t.running + 1 else t.stopped = t.stopped + 1 end
  local o = trace[h] or "?"
  origins[o] = (origins[o] or 0) + 1
end)
local top = {}
for k, v in pairs(origins) do if v > 1 then top[#top + 1] = {k, v} end end
table.sort(top, function(a, b) return a[2] > b[2] end)
local loaded = 0
for _, b in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(b) then loaded = loaded + 1 end
end
local clients = {}
for _, c in ipairs(vim.lsp.get_clients()) do clients[#clients + 1] = c.name end
local handles = {}
vim.uv.walk(function(h) local k = h:get_type(); handles[k] = (handles[k] or 0) + 1 end)
return vim.json.encode({
  lua_heap_mb = math.floor(collectgarbage("count") / 1024),
  timers = t, timer_dupes = {unpack(top, 1, 5)},
  handles = handles,
  bufs = #vim.api.nvim_list_bufs(), bufs_loaded = loaded,
  tabs = #vim.api.nvim_list_tabpages(),
  lsp = clients, debug = _G.MemGuardDebug ~= nil,
})
"""


def status(pid):
    out = {}
    try:
        for line in open(f"/proc/{pid}/status"):
            k, _, v = line.partition(":")
            if k in ("Name", "PPid", "VmRSS", "VmSwap", "VmHWM"):
                v = v.strip()
                out[k] = v if k == "Name" else int(v.split()[0])
    except OSError:
        return None
    return out


def cmdline(pid, n=120):
    try:
        raw = open(f"/proc/{pid}/cmdline", "rb").read().replace(b"\0", b" ")
        return raw.decode(errors="replace").strip()[:n]
    except OSError:
        return ""


def started(pid):
    try:
        f = open(f"/proc/{pid}/stat").read().rsplit(")", 1)[1].split()
        return BOOT + int(f[19]) / CLK
    except (OSError, IndexError):
        return None


def mb(kb):
    return round(kb / 1024)


def system():
    mi = {}
    for line in open("/proc/meminfo"):
        k, v = line.split(":")
        mi[k] = int(v.split()[0])
    out = {
        "total_mb": mb(mi["MemTotal"]),
        "available_mb": mb(mi["MemAvailable"]),
        "swap_used_mb": mb(mi["SwapTotal"] - mi["SwapFree"]),
        "cached_mb": mb(mi["Cached"]),
    }
    try:  # orig_data compr_data mem_used ...
        z = open("/sys/block/zram0/mm_stat").read().split()
        out["zram_orig_mb"] = round(int(z[0]) / 1048576)
        out["zram_ram_mb"] = round(int(z[2]) / 1048576)
    except OSError:
        pass
    psi = open("/proc/pressure/memory").read().split("\n")[0]
    out["psi_some_avg60"] = float(psi.split("avg60=")[1].split()[0])
    return out


def processes():
    procs = {}
    for d in os.listdir("/proc"):
        if d.isdigit():
            s = status(int(d))
            if s and "VmRSS" in s:
                procs[int(d)] = s
    return procs


def children(procs, root):
    kids = {}
    for pid, s in procs.items():
        kids.setdefault(s.get("PPid"), []).append(pid)
    out, stack = [], list(kids.get(root, []))
    while stack:
        p = stack.pop()
        out.append(p)
        stack.extend(kids.get(p, []))
    return out


def probe_nvim(sock):
    try:
        r = subprocess.run(
            ["nvim", "--headless", "--clean", "--server", sock, "--remote-expr",
             'luaeval("loadstring(_A)()", ' + json.dumps(NVIM_PROBE) + ")"],
            capture_output=True, text=True, timeout=10,
        )
        return json.loads(r.stdout) if r.stdout.strip() else {"error": r.stderr.strip()[:200]}
    except (subprocess.TimeoutExpired, json.JSONDecodeError) as e:
        return {"error": type(e).__name__}


def main():
    os.makedirs(STATE, exist_ok=True)
    now = time.time()
    procs = processes()

    top = sorted(procs.items(), key=lambda kv: -(kv[1]["VmRSS"] + kv[1].get("VmSwap", 0)))[:20]
    top_out = [
        {"pid": p, "name": s["Name"], "rss_mb": mb(s["VmRSS"]), "swap_mb": mb(s.get("VmSwap", 0)),
         "cmd": cmdline(p, 90)}
        for p, s in top
    ]

    nvims = []
    for sock in glob.glob(f"{RUNTIME}/nvim.*.0"):
        pid = int(sock.split(".")[-2])
        s = procs.get(pid)
        if not s:
            continue  # stale socket from a dead nvim
        kids = []
        for k in children(procs, pid):
            ks = procs[k]
            if ks["VmRSS"] > 20 * 1024:
                kids.append({"name": ks["Name"], "rss_mb": mb(ks["VmRSS"]),
                             "swap_mb": mb(ks.get("VmSwap", 0)), "cmd": cmdline(k, 90)})
        st = started(pid)
        nvims.append({
            "pid": pid,
            "cwd": os.path.realpath(f"/proc/{pid}/cwd").replace(os.path.expanduser("~"), "~"),
            "uptime_h": round((now - st) / 3600, 1) if st else None,
            "rss_mb": mb(s["VmRSS"]), "swap_mb": mb(s.get("VmSwap", 0)), "peak_mb": mb(s.get("VmHWM", 0)),
            "children_mb": sum(k["rss_mb"] + k["swap_mb"] for k in kids),
            "children": kids,
            "inside": probe_nvim(sock),
        })

    sample = {
        "ts": time.strftime("%Y-%m-%dT%H:%M:%S"),
        "system": system(),
        "nvim": nvims,
        "top": top_out,
    }
    path = os.path.join(STATE, time.strftime("samples-%Y-%m-%d.jsonl"))
    with open(path, "a") as f:
        f.write(json.dumps(sample, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
