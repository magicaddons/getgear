# GetGear data model (0.11.3)

The addon is loaded from `Interface/AddOns/GetGear/GetGear.toc`.
Lua modules share the `GetGear` table supplied via WoW's addon `...` varargs.

- `ClassProfiles.lua` implements `GetGear.ItemCatalog` and class recommendation
  tables: `GetGear.Recommendations.PRIEST`, `...ROGUE`, etc.
- `GetGear:RegisterItem` holds reusable item facts while
  `GetGear:AddRecommendation` holds class/spec/level-specific objectives.
- `GetGear:GetPreviewRecommendations(class, spec)` builds read-only planning
  lists separately from `GetGear.Gear` (the live character guide).
- `Core.lua` initialises the current character via `ADDON_LOADED` where
  `arg1 == addonName` (which is `GetGear`), and initialises UI last.
- The per-character saved-variable table is `GetGear_CharacterDB` and is
  declared in `GetGear.toc` as `SavedVariablesPerCharacter`.
- Objective persistence keys (`item_<ID>` or the distinct Rogue
  `item_<ID>_offhand` entries) remain stable from v0.11.2.
- `UI.lua` references `Interface\AddOns\GetGear\MapPin` for map artwork.

**Migration note:** v0.11.3's rename of the addon folder and saved-variable
name intentionally does not import the former beta's character settings.
Future production releases must preserve the `GetGear` addon identity and
`GetGear_CharacterDB` table, and should migrate data explicitly if changing
saved-variable schemas or objective IDs.
