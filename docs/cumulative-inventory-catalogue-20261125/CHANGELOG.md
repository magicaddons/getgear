# Cumulative private testing changelog — 25 November 2026

Version: `0.14.0-private-cumulative.inventory-catalogue.20261125.1`.
Branch: `dev/cumulative-inventory-catalogue-20261125`.
No mainline merge, tag or public release. Native Forever acceptance is pending.

This build combines the latest accepted Beta 11 production source
`de1037a8a20593430d1c27e123685980d6da909b`, the retained overlay idle/group
checkpoint `4d5fdb6e4171abf576735dcd0b48d36132da4e89`, the separate inventory
commit `4e314ffda1865847c5061c2eaf7482b4c02cf98e`, and the reviewed catalogue
checkpoint `9cab9ff7897fdcad98fa783cfed3e507446f5cfb`.

## Alt Inventory

- Same-realm/faction scope uses shared canonical realm, faction and character
  identity rules. Unknown identity never establishes transfer eligibility.
- Recover sufficient legacy metadata from existing ledger keys. Reconcile
  formatting aliases using storage-specific timestamps and bank completeness,
  retaining original evidence without counting snapshots twice.
- Retain known faction/realm ID/GUID through transient client API failures.
  Prior banks remain accessible; genuinely missing faction needs a character
  login, not another bank visit. Contradictions remain visible for review.
- Preserve whole snapshots when required bag reads or purchased bank tabs are
  unavailable. Capture the last readable open-bank state at logout.
- Scope changes refresh saved inventory immediately without collection or
  recommendation/material rebuilds. Existing transient scope defaults remain.

The independently tested inventory tree is unchanged by this integration. Its
remote commit matches local checkpoint `efe5a00e222f98fdb90ffe2031b3441770a65b39`
byte for byte. Earlier inventory reports describing upload blockage are historical;
the owner's explicit upload authorization resolved that blocker.

## Validated catalogue and commerce corrections

- Apply 30 current published item-name corrections, three required-level
  corrections and three quest-title corrections. Raised levels propagate to
  copied class objectives at load time.
- Use exact ACA book/vendor/currency joins and shared service eligibility in
  recommendations, text and navigation, preserving valid independent alternatives.
- Add 10 evidenced learning alternatives, fill 41 book associations and project
  42 source-less legacy routes onto evidenced commerce identities.
- Keep 54 published learning-skill disagreements explicit. Withhold unsupported
  precise coordinates for six ACA and seven other NPC disputes and the recorded
  unapproved trainer/entrance points. Written directions remain where supported.
- Retain historical records while holding 360 routes with unapproved evidence
  out of actionable acquisition. Preserve the research-source safeguards,
  generator checks and method-aware faction/territory rules from the reviewed
  checkpoint, including neutral services and shared quest/dungeon alternatives.
- Correct the research coverage prose to the exact existing machine ledger:
  7,423 route decisions, including 3,115 retained published-but-unverified rows.
  This fixes two off-by-one prose totals; it changes no acquisition record.

## Cumulative preservation and testing

- Retain All/Starred/Other groups, independent pages, idle/movement/combat event
  reductions, drag-only resize processing, saved stars, slot filters, stat modes,
  material planning, bag objectives and existing navigation lifecycle behavior.
- Include all 32 runtime modules and all 14 feature-contract groups. Preserve
  every required regression from each workstream, the 17-file approved historical
  acquisition snapshot and all historical candidate holds.
- Resolve the TOC version conflict using a new cumulative private identity;
  preserve both branches' independent changes in the shared UI and contract.
- Update the comparative performance runner to validate the pinned baseline's
  own TOC module list, allowing an implementation to add policy modules without
  falsely requiring them in the older production baseline.

## Research still unresolved

The research checkpoint implemented corrections; it did not verify every fact.
Outstanding: 92 missing equipment responses, 32 unmatched crafting joins,
54 learning-skill disagreements, one enchantment effect contradiction, six ACA
and seven other NPC coordinate disputes, and recorded live stock/teaching/loot/
quest-prerequisite/build questions. Zero complete records or native-client
observations are claimed independently verified by this work.

See [combined validation and review](VALIDATION.md), the preserved
[catalogue coverage](../source-integrity-20261124/COVERAGE.md) and
[inventory investigation](../inventory-scope/REPORT.md) for exact boundaries.
