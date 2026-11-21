# Permanent filtering, eligibility and regression policy

Every bug report is a reproduction case for an investigation of the underlying
rule throughout GetGear. Apply this policy automatically to future work.

Before implementation, identify the root cause and applicable classes, factions,
levels, slots, professions, acquisition methods and UI surfaces. Audit analogous
records. Prefer one shared rule and validated source data over item-name lists,
class-specific patches or duplicated filtering. An isolated correction requires
evidence that its cause is unique and a written explanation.

Keep these decisions separate: equipment/use eligibility; legitimate acquisition
through any supported route; practical access; build relevance; net improvement
under Balanced/Priority/Advanced; and presentation in tracker versus guide.
Faction-specific item/reputation restrictions and source-specific restrictions
are different facts. A hostile seller must not hide a shared drop or verified
tradeable alternative, and trade must not bypass actual item-use restrictions.
Unknown facts are audit gaps, not inferred faction exclusions. Zone ownership,
NPC name, item family/name and offensive stat presence do not establish access.

For each change, add positive and negative table-driven checks across its full
applicable scope. Include all nine classes with faction-valid original class
combinations, both factions, relevant levels/slots/source methods, shared and
exclusive records, variants and alternatives, user settings/builds and all
recommendation surfaces. Preserve historical progress and player-directed
browsing. Never claim actual-client rendering or access from synthetic tests.

Review/release checklist:

- Root cause and scope documented; analogous catalogue paths audited.
- Shared eligibility/relevance boundaries remain explicit and consistent.
- Affected and uncertain record counts recorded with source evidence.
- Known-invalid recommendations excluded; legitimate alternatives retained.
- Settings, progress, materials, bags, maps and earlier fixes preserved.
- New records automatically enter the same catalogue-wide regression matrix.
- Local and applicable non-release CI checks pass; full CI log reviewed.
- Manual client checks and unresolved evidence listed in the completion report.
- Follow the current task's packaging/publication permissions; this policy
  grants no permission to build a ZIP, tag, release or merge.
