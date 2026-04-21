---
name: execute-ticket
description: >
  Full ticket execution: loads company config, fetches ticket + standards + design in one
  parallel pass, classifies complexity, plans atomic commits, implements with tests, runs
  code review, takes UI screenshots, opens PR, writes bragdoc. Use when user says "work on
  ticket", "execute TICKET-ID", "implement this", "pick up this ticket", or runs /ticket.
---

# Execute Ticket

End-to-end ticket execution from analysis to bragdoc. Token-efficient by tier — a copy change
never spawns subagents. Complex features use Superpowers subagent-driven development.

---

## Phase 0: Config Check

The config file lives at `.claude/company.local.json` inside the **current project root**
(the directory Claude was started from — not the dotfiles directory). It is never committed.

The skill owns the full definition of this file: its structure, its fields, and their defaults.
There is no separate template file to find or copy. Everything is declared here.

### Step 1: Ensure file and .gitignore exist

If `.claude/company.local.json` does not exist, create it with all fields empty:
```json
{
  "companySlug": "",
  "ticketSystem": "",
  "codingStandardsNotionUrl": "",
  "testingStandardsNotionUrl": "",
  "bragdocNotionPageId": "",
  "bragdocScriptPath": "",
  "devServerUrl": "http://localhost:3000",
  "devServerStartCommand": "npm run dev"
}
```

Ensure `.gitignore` in the project root contains `.claude/company.local.json`.
Add it if missing. If there is no `.gitignore`, create one with that entry.

Also ensure `.claude/pr-screenshots/` is in `.gitignore`.

### Step 2: Identify missing fields

Read the file. Collect every field that is an empty string (except fields with usable defaults).

Fields with built-in defaults (skip if blank — no prompt needed):
- `devServerUrl` → defaults to `http://localhost:3000`
- `devServerStartCommand` → defaults to `npm run dev`

Fields that need values to work properly (prompt if blank):
| Field | What it enables |
|---|---|
| `companySlug` | Identification in logs |
| `ticketSystem` | Ticket fetching (auto-detected if blank, but confirm) |
| `codingStandardsNotionUrl` | Company-specific code standards |
| `testingStandardsNotionUrl` | Company-specific test requirements |
| `bragdocNotionPageId` | Appending to your Notion bragdoc |
| `bragdocScriptPath` | Running a local bragdoc script |

### Step 3: Prompt for missing fields (interactive)

If any fields from the prompt list above are blank, ask for them now — one question per field,
in the order listed. For each one:

  "What is your [field description]? (Press Enter to skip — [fallback behavior])"

Show the fallback so the user knows what happens if they skip.

Examples:
  "What is your coding standards Notion URL?
   (Skip → I'll follow existing patterns in the codebase)"

  "What is your bragdoc Notion page ID?
   (Skip → bragdoc entries will print to terminal for manual copy)"

  "What ticket system does this project use — jira or linear?
   (Skip → I'll auto-detect from active MCP servers)"

After each answer: write the value to `.claude/company.local.json` immediately.
If the user skips a field: leave it blank and note the fallback for Phase 4.

### Step 4: Confirm and continue

Once all fields are resolved (filled or skipped), print a one-line summary:
  "Config ready. Standards: [source]. Bragdoc: [destination]. Let's go."

Then proceed to Phase 1 — no re-reading of this file for the rest of the skill.

---

## Phase 1: Ticket Input

If the user provided a ticket ID (e.g., PROC-1234, ENG-12): use it.
If not: ask "Which ticket should I work on?"

Determine ticket system:
1. Check `ticketSystem` from config
2. If blank: detect from active MCP servers (Jira MCP present → jira, Linear → linear)
3. If still unclear: ask the user

---

## Phase 2: Complexity Classification

Fetch only the ticket title and description first (one lightweight call).

Classify into a tier:

**Tier 1 — Trivial**
Copy change, single config value, CSS tweak, label update, small visual fix.
Signals: ≤ 3 files, no logic changes, no new API, no new components, no data model change.
→ No subagents. Implement directly. Still requires one test and a UI screenshot if visual.

**Tier 2 — Standard**
Bug fix, small feature, UI component update, API endpoint addition, small refactor.
Signals: 3–10 files, logic changes, tests required, may have Figma design.
→ Single implementation pass. Code review. Playwright for all visual changes.

**Tier 3 — Complex**
New feature, architecture change, new data model, cross-service impact, major UI flow.
Signals: 10+ files, new abstractions, cross-service coordination, design required.
→ Superpowers subagent-driven-development. Full review loop per task.

State the tier and a one-line rationale. Ask: "Does this tier feel right?" before proceeding.

---

## Phase 3: Context Gathering (Single Pass, Parallel)

Fetch ALL of the following simultaneously. Nothing in this list is ever fetched twice.

### 3a. Full ticket details
Fetch: description, acceptance criteria, all comments, all attachments, all linked items.

Extract and categorize every linked item:
- **Linked tickets**: fetch status (Done / In Progress / Open / Blocked) + one-line summary
- **Notion links**: fetch and extract key content (standards, specs, decisions)
- **Figma links**: extract fileKey + nodeId for 3d
- **Slack links**: note as "manual context — check thread if needed" (cannot auto-fetch)
- **Other URLs**: fetch title + first paragraph

### 3b. Coding standards
If `codingStandardsNotionUrl` is set: fetch and extract as a condensed standards block.
If not set: use "follow existing patterns in the codebase; conventional commits; project CLAUDE.md".

### 3b-ii. Surrounding code patterns
Read the files most relevant to this ticket's scope — the ones that will be modified or that
the new code will live alongside. The goal is to make new code indistinguishable from existing
code by a reviewer who didn't know which lines were added.

Identify and extract patterns for:
- **Naming**: variable names, function names, component names, file names — casing, prefixes,
  verbosity level (e.g. `handleSubmit` vs `onSubmit` vs `submitForm`)
- **File and folder structure**: where similar files live, how they are grouped, index files
- **Component/function shape**: how similar components or functions are structured — props
  interface placement, return shape, internal ordering of hooks/logic/render
- **State management**: how state is handled in nearby code (local state, context, store calls)
- **API/data fetching**: how the surrounding code fetches data — hooks, utilities, error handling
- **Error handling style**: how errors are caught and surfaced in similar code
- **Import ordering**: how imports are grouped and ordered in adjacent files
- **Test patterns**: how nearby tests are structured — describe blocks, naming, setup/teardown,
  mock style
- **Comments**: whether surrounding code uses comments and how (inline, JSDoc, none)

This is read-only exploration — no changes yet. Summarize the patterns as a **code style
context block** stored in session. Reference it throughout implementation.

If the ticket touches an unfamiliar area of the codebase (no nearby similar files), note that
and fall back to the Notion standards from 3b.

### 3c. Testing standards
If `testingStandardsNotionUrl` is set: fetch and extract test requirements.
If not set: use "co-locate tests with implementation; cover happy path + key edge cases;
match the test framework and patterns already used in the project".

### 3d. Design (Figma)
If a Figma link exists in the ticket:
  Call `get_design_context` with the extracted fileKey + nodeId — ONE call, full extraction.
  Capture: component hierarchy, spacing, colors, type styles, interactive states, error states,
  responsive behavior, any designer annotations.
  Store this as a **design context block** in session. Never call Figma again for this ticket.

If no Figma link and the ticket involves visual changes (Tier 2+):
  Flag as uncertainty in Phase 4 — but do not block execution.

### 3e. Dependency analysis
For each linked ticket that is NOT Done:
  - Identify: which parts of THIS ticket require the dependency's output?
  - Identify: which parts can proceed right now without it?
  - Identify: can any shared work be done inside this ticket to unblock later?
    (e.g., define shared types/interfaces, write stub implementations, scaffold the UI,
    write tests against a contract, set up feature flags)

Summarize as: "Can proceed now: [X]. Blocked until [TICKET] is done: [Y]."

---

## Phase 4: Pre-flight Report

Present this once. User approves once. Then execution begins without further gates.

```
Ticket: [ID] — [Title]                                    Tier: [1/2/3]
──────────────────────────────────────────────────────────────────────
Context loaded:
  [✅/⚠️] Ticket: [N] linked resources processed
  [✅/⚠️] Coding standards: [Notion source | "using project patterns"]
  [✅/⚠️] Testing standards: [Notion source | "using project patterns"]
  [✅/⚠️] Design: [Figma captured — N components | not attached]

Config warnings (if any):
  ⚠️ [List any blank company.local.json fields and their fallback behavior]

Dependencies:
  [TICKET-ID] ([status]): [one-line summary]
    → Can do now: [what proceeds independently]
    → Blocked: [what waits] (or "nothing blocked — full proceed")

[Uncertainties — only include section if real blockers exist:]
  1. [Question — acceptance criteria absent, direct contradiction, visual with no design,
      unresolvable scope ambiguity, open dependency with no workaround]

Commit plan:
  1. [type(scope): description] — [files]
  2. [type(scope): description] — [files]
  3. test([scope]): add test suite — [test files]
  ...

Proceed? Or adjust anything first?
```

**What counts as a real uncertainty — flag it:**
- Acceptance criteria completely absent on a non-trivial ticket
- Visual change requested with no design and no existing pattern to derive from
- Two stated requirements directly contradict each other
- A blocking dependency is Open with no part of this ticket proceeding without it

**What does NOT count — do not flag:**
- Minor wording choices (pick the clearer option)
- Implementation approach when patterns exist in the codebase (follow them)
- Test coverage style (match what's already there)
- Small details inferable from context or existing code

If there are no uncertainties: omit that section entirely. Do not say "no uncertainties."

---

## Phase 5: Branch Setup

Use `superpowers:using-git-worktrees` to create an isolated workspace.

Branch naming:
- Feature: `feat/[TICKET-ID]-[short-slug]`
- Bug fix: `fix/[TICKET-ID]-[short-slug]`
- Refactor: `refactor/[TICKET-ID]-[short-slug]`

---

## Phase 6: Implementation

### Tier 1
Implement directly. Follow existing patterns. No subagents, no plan document.
Reference design context block if visual (no re-fetch).

### Tier 2
Implement in sequence per the commit plan from Phase 4.
After each logical chunk: run type check + linter before moving to the next.
Reference design context block for visual work — never re-fetch Figma.

### Tier 3
Use `superpowers:subagent-driven-development`.

As coordinator: provide each implementer subagent with:
- The specific task text (extracted upfront — subagent must NOT read the plan file itself)
- The relevant slice of the design context block (copied in, not re-fetched)
- Relevant standards excerpts from 3b and 3c
- The code style context block from 3b-ii (naming, structure, patterns)
- Scene-setting: where this task fits in the overall feature

Model selection (follow Superpowers guidance):
- Mechanical task (1-2 files, complete spec, isolated): Haiku
- Integration task (multi-file, pattern matching, judgment): Sonnet
- Architecture, design, broad review: Opus

Each task follows: implementer → spec reviewer → code quality reviewer.
Use `superpowers:test-driven-development` for each implementer subagent.

---

## Phase 7: Testing

All code must have tests. No exceptions regardless of tier.

Write tests in the same commit as the implementation or in an immediately following test commit.
Never defer tests to a separate PR or "follow-up".

Co-locate test files with implementation (e.g., `Validator.test.ts` next to `Validator.ts`).
Follow the testing standards from Phase 3c.

**Minimum coverage by tier:**
- Tier 1: At least one test confirming the change (snapshot test acceptable for copy-only)
- Tier 2: Happy path + 2–3 edge cases per changed function or component
- Tier 3: Full suite — happy path, error states, null/empty cases, integration where applicable

Run the full test suite before Phase 8:
```bash
# Use whichever test command exists in this project:
npm test / yarn test / pnpm test / pytest / go test ./... / cargo test
```

If tests fail: fix before proceeding. Never open a PR with failing tests.

---

## Phase 8: Code Review

Run `superpowers:requesting-code-review` across the full diff before the PR opens.

Focus areas:
- Logic correctness and edge cases
- Security: injection, exposed secrets, auth gaps
- Missing error handling at boundaries
- Performance: N+1 queries, unnecessary re-renders, large bundle additions
- Spec compliance: does the code match acceptance criteria from the ticket?
- Standards compliance: does the code match the Notion standards from Phase 3b?
- Style consistency: does the code blend with surrounding patterns from Phase 3b-ii?
  Flag anything that would stand out to a reviewer — naming that breaks local convention,
  structure that differs from adjacent files, patterns not used elsewhere in this area.
- Test coverage: are the tests meaningful, not just present?

Severity:
  🔴 Must fix — blocks PR. Fix, then re-run review on the changed files.
  🟡 Should fix — note in PR description as known debt. Does not block.
  🟢 Minor — record only, no action required.

Never open the PR with unfixed 🔴 issues.

---

## Phase 9: Screenshots

Take screenshots for ALL tickets that touch any UI — including Tier 1 copy changes.
Pure backend, config-only, and types-only changes: skip silently.

**Check dev server:**
```bash
curl -s -o /dev/null -w "%{http_code}" [devServerUrl] 2>/dev/null
```

If server is not running, tell the user:
  "Dev server isn't running. Start it with `[devServerStartCommand]` and confirm,
   or type 'skip' to skip screenshots."
Wait for response.

**Navigate to the changed UI:**
Determine the route from: router files, component tree, ticket description, design context.
If the path is ambiguous: ask the user for the URL path (one question only).

**Capture:**
- 1 screenshot of the changed component/page in its default/initial state
- 1 screenshot of a changed interactive state (hover, error, empty, loading) if applicable
- Maximum 2 screenshots total

Save to `.claude/pr-screenshots/[TICKET-ID]/` (this path must be gitignored).

---

## Phase 10: Commits

Follow the commit plan approved in Phase 4.

Each commit:
- Stages only the specific files for that logical unit
- Message: `type(scope): description [TICKET-ID]`
- Types: feat, fix, refactor, test, docs, chore, perf, style
- Must be independently buildable — run `tsc --noEmit` (or equivalent) per commit if fast

Examples:
  `feat(matching): add three-way match validator [PROC-1234]`
  `test(matching): validator — happy path and boundary cases [PROC-1234]`
  `fix(invoice): correct nil pointer on missing PO reference [PROC-1234]`
  `style(button): update "Sign in" label to "Log in" [ENG-89]`

Never mix refactors with feature changes in one commit.
Max 8 files per commit — split further if needed.

---

## Phase 11: PR

Use `superpowers:finishing-a-development-branch` for the merge/PR decision.

If creating a PR, structure the body as:

```markdown
## Issue
[TICKET-ID]: [Ticket Title]
[Full ticket URL]

## What changed
- [What was implemented or fixed — specific, not generic]
- [Second change if applicable]
- [Known debt or limitations from 🟡 review items — if any]

## How to test
1. [Step to set up the scenario]
2. [Action to take]
3. [What to verify]

## Screenshots
[Playwright screenshots here — visual tickets only. Omit section for backend-only changes.]

## Notes
[🟡 review items logged as intentional debt, or omit this section entirely]
```

Fill every section with real content. No placeholders. No "N/A".

---

## Phase 12: Bragdoc

After the PR URL is confirmed, write the bragdoc entry.

Determine destination (in order of priority):
1. `bragdocScriptPath` is set → pipe entry to that script
2. `bragdocNotionPageId` is set → append via Notion MCP if available
3. Neither set → print to terminal for manual copy

Select the entry format from `./bragdoc-templates.md` based on the ticket tier.

---

## Standing Rules

- Never commit or push to main/master — always use the feature branch
- Never push without explicit user confirmation
- Never post PR comments without user approval
- Never re-fetch Figma, standards, or ticket data after Phase 3
- Never open a PR with failing tests or unfixed 🔴 review issues
- Screenshots only against the local dev server — never staging or production
- `.claude/company.local.json` must be in `.gitignore` before Phase 5 — verify it
- `.claude/pr-screenshots/` must be in `.gitignore` before Phase 9 — verify it

---

## Configuration Reference

All values from `.claude/company.local.json` — local only, never committed.

| Key                       | Purpose                              | Fallback if blank              |
|---------------------------|--------------------------------------|--------------------------------|
| `companySlug`             | Identifier for logging               | Omitted from logs              |
| `ticketSystem`            | "jira" or "linear"                   | Auto-detected from MCP servers |
| `codingStandardsNotionUrl`| Notion page with code standards      | Use project patterns           |
| `testingStandardsNotionUrl`| Notion page with test requirements  | Use project test patterns      |
| `bragdocNotionPageId`     | Notion page ID for bragdoc           | Print to terminal              |
| `bragdocScriptPath`       | Path to local bragdoc append script  | Use Notion or terminal         |
| `devServerUrl`            | Local dev server base URL            | http://localhost:3000          |
| `devServerStartCommand`   | Command to start dev server          | npm run dev                    |
