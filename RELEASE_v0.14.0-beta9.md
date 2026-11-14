## What's new in this beta?

This is a substantial update to GetGear, focused on making gear recommendations more useful, improving acquisition information and cleaning up the interface.

**Highlights**

- **Smarter gear recommendations:** Improved class-aware filtering to reduce unsuitable gear suggestions, including equipment with irrelevant stats or weapons a class cannot use.
- **Less overlay clutter:** Unhelpful recommendations, such as negative-only upgrades and random uncommon world drops, are filtered more intelligently by default.
- **Cleaner acquisition information:** Shorter, clearer descriptions of where to obtain equipment and crafting recipes, without unnecessary technical labels or repetitive text.
- **Improved map navigation:** Better access to locations for relevant vendors, quests, dungeon sources and recipes, with clearer handling of multiple possible sources.
- **Crafting improvements:** Clearer trainer requirements, recipe sources, specialisations, reputation requirements and materials.
- **Extensive catalogue cleanup:** All 7,707 catalogue items were included in the latest presentation audit, with thousands of descriptions and source labels improved.

**Please help test!**

GetGear is still in beta, and community feedback is welcome. If you find incorrect recommendations, missing items, inaccurate acquisition information or interface problems, please report them through [GitHub Issues](https://github.com/magicaddons/getgear/issues).

When reporting a problem, please include your class, level, the affected item and a screenshot if possible. Your GetGear version, relevant settings and any Lua error are also helpful.

**Known limitations**

Some recipe-learning sources and item acquisition locations remain unverified. Map destinations and certain acquisition details still require testing against the live WoW Forever client.

## Installation or upgrade

1. Exit WoW Forever.
2. Back up your existing `GetGear` addon folder and GetGear account/character SavedVariables in `WTF`.
3. Download **GetGear-v0.14.0-beta9.zip** from this release's Assets and extract its single `GetGear` folder into your WoW Forever `Interface/AddOns` directory.
4. Replace the previous addon folder after backing it up. Confirm `Interface/AddOns/GetGear/GetGear.toc` exists, without an extra nested folder.
5. Launch the game and use `/getgear`.

**Do not install multiple copies simultaneously.** Move backup copies outside `AddOns`. The version in the AddOns list should be **0.14.0-beta9**. No third-party navigation addon is required.

This is a **pre-release for WoW Forever**. Alliance remains the documented route focus. It preserves the functionality and approved acquisition dataset from the user-tested PRIVATE TEST 4; the 900 held candidates are not included. Only versioning, packaging and publication documentation changed after that tested build.
