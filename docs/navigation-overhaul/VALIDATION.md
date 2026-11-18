# Validation checkpoint

The initial `.5` local integrated gate completed156 checks with zero failures, on Lua5.1
and Lua5.4:29 runtime modules,35 functional suites on each interpreter,
cumulative feature/build/source-integrity tests, source/recipe/faction/navigation
generation and catalogue audits, and release-tool regressions. The final
navigation/quest/bag regression was also rerun directly on both interpreters
after adding the real Night Elf vendor-bag and abandonment cases.
The `.6` follow-up adds initial-cache wording, native counter updates and
unavailable-API regressions, rerun directly on both interpreters. Its complete
immutable local extraction gate and GitHub CI receipts accompany final delivery;
the earlier checkpoint's passing receipt is not a substitute for those checks.

Commands (outputs deliberately outside the checkout):

```sh
python3 tools/reconcile_presentation_snapshot.py --verify-only
python3 tools/build_navigation_review.py --check
python3 tools/validate_recommendations.py \
  --output /workspace/artifacts/navigation-overhaul-committing-validation \
  --lua51 /workspace/.getgear-tools/lua/usr/bin/lua5.1 \
  --luac51 /workspace/.getgear-tools/lua/usr/bin/luac5.1
lua5.4 tests/navigation-overhaul.lua .
lua5.1 tools/release/lua51-harness.lua tests/navigation-overhaul.lua .
```

The full catalogue/source navigation audit records7,732 item IDs,74,004
class/faction checks,9,435 usable-location rows,820 distinct simulated marker
destinations and25,608 raw-source evidence checks. Usable locations without a
button, raw-source evidence without a button, and item-cache queries are all
zero. Every distinct rendered destination now exercises the real marker
revalidation path. The original17-file acquisition snapshot is exact.

The new scope covers39 definitions,39 entrance/approach choices and76 aliases;
14 descriptive catalogue labels join to canonical NPC identities. All reported
items have real-runtime regressions. NPC-name punctuation, map-frame separation,
native entrance upgrades, lazy opening, source regeneration, ordinary quest-log
events, stage changes and abandonment have positive/negative checks. A citation
with a valid-looking hash but unsupported coordinates is rejected.

The first presentation-audit attempt caught research wording leaking into the
primary labels of multi-entrance Wailing Caverns/Excavation routes. Those labels
were corrected, preserving qualification in directions; the full presentation
audit then passed. Failed attempts are retained outside the checkout and are
not reported as successful validation.

The exact remote checkpoint SHA, GitHub CI run/result and independently frozen
extracted-package validation receipts belong to the final delivery receipt. They
are verified after this commit and are not fabricated as a self-referential
hash in this file. The package gate repeats the complete suite against committed,
extracted source. See the companion BUILD_INFO, PACKAGE_MANIFEST and SHA256SUMS.

Actual Forever rendering, physical portal position, third-party map-addon
coexistence, and the specific installed-client Wizbang/Redridge failures remain
owner acceptance. No synthetic test is represented as an in-game observation.
