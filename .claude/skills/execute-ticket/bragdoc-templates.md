# Bragdoc Templates

Select the template that matches the ticket tier. Populate all fields from the session —
never fabricate metrics or impact. If a field has no real data, omit it rather than guessing.

---

## Tier 1 — Trivial
One-liner. Goes in a running monthly list.

```
- [TICKET-ID]: [what changed in plain English] → [PR URL]
```

**Example:**
```
- ENG-89: update "Sign in" button label to "Log in" across auth flows → PR #441
```

---

## Tier 2 — Standard
Brief entry. What shipped, why it matters, test signal.

```
### [TICKET-ID] — [Ticket Title]
[YYYY-MM-DD] | [PR URL]

- **What**: [2–3 bullets — what was implemented or fixed, specific not generic]
- **Impact**: [one sentence on user or business effect]
- **Testing**: [X tests added / scenario covered / regression prevented]
```

**Example:**
```
### ENG-412 — Fix AP invoice aging report calculation
2026-04-20 | PR #438

- **What**: Fixed off-by-one in aging bucket boundary logic; added vendor-level subtotals
- **Impact**: Aging report now matches accounting team's expected figures — removed a manual
  reconciliation step that was taking ~2h/week
- **Testing**: 6 unit tests covering all 5 aging buckets and the edge case at the boundary
```

---

## Tier 3 — Complex
Full entry. What shipped, technical decisions, business value, test coverage.

```
### [TICKET-ID] — [Ticket Title]
[YYYY-MM-DD] | [PR URL]

**What shipped**:
- [Main capability delivered — what can users or the system do now that it couldn't before]
- [Supporting implementation — key pieces that make the above work]
- [Notable technical decision or constraint handled]

**Business impact**: [1–2 sentences. What problem does this solve? Who benefits? Any metric?]

**Technical highlights**: [1–2 decisions worth remembering — tradeoffs made, non-obvious choices,
interesting constraints navigated]

**Testing**: [X tests added. Key scenarios covered. Any integration or contract tests. Coverage
signal if measurable.]
```

**Example:**
```
### PROC-1234 — Implement 3-way match validation for AP invoices
2026-04-20 | PR #421

**What shipped**:
- Three-way match validation engine comparing PO, invoice, and goods receipt amounts
- Configurable tolerance thresholds per vendor category (set in admin panel)
- Match status API endpoint with event webhook for downstream notification

**Business impact**: Reduces manual invoice review volume by ~40% for matched invoices.
AP team can focus audit time on exceptions rather than processing clean invoices line by line.

**Technical highlights**: Implemented as a pure validation service with no DB side effects,
so it's safely callable from the invoice ingestion pipeline, the manual review UI, and
background reconciliation jobs without risk of double-writes.

**Testing**: 24 unit tests across 3 validator classes; 4 integration tests covering
PO-missing, GR-partial, and amount-within-tolerance scenarios.
```
