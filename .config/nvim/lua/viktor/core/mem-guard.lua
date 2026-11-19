-- Memory guard: keep long-lived nvim instances from bloating to many GB.
--
-- Why: nvim's Lua heap (LuaJIT) never returns memory to the OS once it has
-- grown. Bursts of Lua allocation (LSP responses, pickers, plugins) leave
-- gigabytes of *freed but still mapped* memory behind, pinned by a few
-- long-lived objects. An nvim left open for a week was found holding 9.7G
-- (5.6G RAM + 4G swap) with only ~180M of live Lua data. The only real fix
-- is restarting the process; `:restart` (nvim 0.12+) does that while saving
-- and restoring the session (windows, tabs, buffers).
--
-- Behaviour (checked every 5 min and on focus):
--   * focused + over limit  -> warning suggesting :restart (max every 30 min)
--   * unfocused >= 15 min + over limit + nothing to lose -> automatic :restart
--
-- Tune:  vim.g.mem_guard_limit_mb (default 1500), vim.g.mem_guard_auto_restart (default true)

local LIMIT_MB = vim.g.mem_guard_limit_mb or 1500
local AUTO_RESTART = vim.g.mem_guard_auto_restart ~= false
local CHECK_MS = 5 * 60 * 1000
local IDLE_S = 15 * 60
local WARN_EVERY_S = 30 * 60

local focused = true
local unfocused_since = nil
local last_warn = 0

-- ===== Debug instrumentation (for scripts/memwatch.py investigation) =====
-- Disable with vim.g.mem_guard_debug = false once the leak hunt is over.
-- Events go to ~/.local/state/memwatch/nvim-events.jsonl.
local DEBUG = vim.g.mem_guard_debug ~= false
local EVENTS = vim.env.HOME .. "/.local/state/memwatch/nvim-events.jsonl"

local function log_event(kind, extra)
  if not DEBUG then
    return
  end
  local cur = vim.api.nvim_get_current_buf()
  local clients = {}
  for _, c in ipairs(vim.lsp.get_clients()) do
    clients[#clients + 1] = c.name
  end
  local wins = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
    if ft ~= "" then
      wins[ft] = true
    end
  end
  local ev = vim.tbl_extend("force", {
    ts = os.date("%Y-%m-%dT%H:%M:%S"),
    pid = vim.fn.getpid(),
    cwd = vim.fn.getcwd(),
    event = kind,
    lua_heap_mb = math.floor(collectgarbage("count") / 1024),
    file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(cur), ":~:."),
    filetype = vim.bo[cur].filetype,
    mode = vim.fn.mode(),
    last_cmd = vim.fn.histget(":", -1),
    window_filetypes = vim.tbl_keys(wins),
    lsp = clients,
    bufs = #vim.api.nvim_list_bufs(),
  }, extra or {})
  vim.fn.mkdir(vim.fs.dirname(EVENTS), "p")
  local f = io.open(EVENTS, "a")
  if f then
    f:write(vim.json.encode(ev), "\n")
    f:close()
  end
end

if DEBUG then
  -- Record where every timer is created, so a leak names its source.
  -- Weak keys: closed timers vanish from the table on their own.
  local trace = setmetatable({}, { __mode = "k" })
  _G.MemGuardDebug = { timer_trace = trace }
  local new_timer = vim.uv.new_timer
  vim.uv.new_timer = function(...)
    local t = new_timer(...)
    if t then
      local tb = {}
      for lvl = 2, 9 do
        local info = debug.getinfo(lvl, "Sl")
        if not info then
          break
        end
        if not info.short_src:match("^%[") then
          tb[#tb + 1] = info.short_src:gsub("^.*/lazy/", ""):gsub("^.*/%.config/nvim/", "") .. ":" .. info.currentline
          if #tb == 3 then
            break
          end
        end
      end
      trace[t] = table.concat(tb, " < ")
    end
    return t
  end
end

-- RSS + swap in MB. Swap counts: a bloated nvim gets pushed to swap and
-- looks small in `ps`, but it still occupies zram (= real RAM).
local function usage_mb()
  local f = io.open("/proc/self/status", "r")
  if not f then
    return vim.uv.resident_set_memory() / 1048576 -- macOS: RSS only
  end
  local kb = 0
  for line in f:lines() do
    local v = line:match("^VmRSS:%s+(%d+)") or line:match("^VmSwap:%s+(%d+)")
    if v then
      kb = kb + tonumber(v)
    end
  end
  f:close()
  return kb / 1024
end

-- Restarting is only safe when nothing would be lost.
local function safe_to_restart()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].modified then
      return false, "unsaved changes"
    end
  end
  for _, chan in ipairs(vim.api.nvim_list_chans()) do
    if chan.mode == "terminal" then
      return false, "terminal running"
    end
  end
  if package.loaded.dap and require("dap").session() then
    return false, "debug session active"
  end
  if vim.fn.mode() ~= "n" then
    return false, "not in normal mode"
  end
  return true
end

local function check()
  local mb = usage_mb()
  if mb < LIMIT_MB then
    return
  end
  local gb = ("%.1f GB"):format(mb / 1024)

  local idle = unfocused_since and (os.time() - unfocused_since) >= IDLE_S
  if AUTO_RESTART and idle then
    local ok = safe_to_restart()
    if ok then
      -- the message is shown inside the NEW nvim after it comes back up
      log_event("auto_restart", { total_mb = math.floor(mb) })
      local msg = ("mem-guard: restarted nvim to free %s (session restored)"):format(gb)
      vim.cmd("restart lua vim.notify(" .. vim.fn.string(msg) .. ")")
      return
    end
  end

  if focused and os.time() - last_warn >= WARN_EVERY_S then
    last_warn = os.time()
    local _, why = safe_to_restart()
    log_event("warn_over_limit", { total_mb = math.floor(mb), blocked_by = why })
    vim.notify(
      ("nvim is using %s of memory (limit %d MB).\nRun :restart to free it, windows and buffers are restored.%s"):format(
        gb,
        LIMIT_MB,
        why and ("\n(can't auto-restart: " .. why .. ")") or ""
      ),
      vim.log.levels.WARN,
      { title = "mem-guard" }
    )
  end
end

local timer = assert(vim.uv.new_timer())
timer:start(CHECK_MS, CHECK_MS, vim.schedule_wrap(check))

local group = vim.api.nvim_create_augroup("UserMemGuard", { clear = true })
vim.api.nvim_create_autocmd("FocusLost", {
  group = group,
  callback = function()
    focused = false
    unfocused_since = os.time()
  end,
})
vim.api.nvim_create_autocmd("FocusGained", {
  group = group,
  callback = function()
    focused = true
    unfocused_since = nil
    vim.schedule(check)
  end,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    if not timer:is_closing() then
      timer:close()
    end
  end,
})

-- Spike detector: every 15 s compare peak memory (VmHWM, Linux) and Lua heap
-- with the previous check. A jump means something just allocated a lot, so
-- log what was going on right then (file, mode, last command, pickers, LSPs).
if DEBUG then
  local SPIKE_MB = 150
  local function proc_kb(field)
    local f = io.open("/proc/self/status", "r")
    if not f then
      return 0
    end
    local s = f:read("*a")
    f:close()
    return tonumber(s:match(field .. ":%s+(%d+)")) or 0
  end
  local last_hwm = proc_kb("VmHWM") / 1024
  local last_heap = collectgarbage("count") / 1024
  local spike = assert(vim.uv.new_timer())
  spike:start(15000, 15000, vim.schedule_wrap(function()
    local hwm = proc_kb("VmHWM") / 1024
    local heap = collectgarbage("count") / 1024
    if hwm - last_hwm >= SPIKE_MB or heap - last_heap >= SPIKE_MB then
      log_event("spike", {
        peak_mb_before = math.floor(last_hwm),
        peak_mb_after = math.floor(hwm),
        heap_mb_before = math.floor(last_heap),
        rss_mb = math.floor(proc_kb("VmRSS") / 1024),
      })
    end
    last_hwm, last_heap = hwm, heap
  end))
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      log_event("exit", { rss_mb = math.floor(proc_kb("VmRSS") / 1024), peak_mb = math.floor(proc_kb("VmHWM") / 1024) })
      if not spike:is_closing() then
        spike:close()
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimEnter", { group = group, once = true, callback = function() log_event("start") end })
end

vim.api.nvim_create_user_command("MemGuard", function()
  local mb = usage_mb()
  local ok, why = safe_to_restart()
  print(
    ("nvim memory: %.0f MB (RSS+swap), Lua heap: %.0f MB, limit: %d MB, timers: %d, auto-restart safe: %s"):format(
      mb,
      collectgarbage("count") / 1024,
      LIMIT_MB,
      (function()
        local n = 0
        vim.uv.walk(function(h)
          if h:get_type() == "timer" then
            n = n + 1
          end
        end)
        return n
      end)(),
      ok and "yes" or ("no (" .. why .. ")")
    )
  )
end, { desc = "Show nvim memory usage" })
