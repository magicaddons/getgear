# Validation receipt

The local integrated gate completed159 checks with zero failures: all29 runtime
modules,36 functional suites on each of Lua5.1 and5.4, the full cumulative feature
contract, build/release-tool tests, generators and complete navigation, source,
faction, recipe and presentation audits. The final frame-level range refinement
also passed direct renderer regressions on both interpreters, Lua5.1 syntax and
the updated exact navigation contract. No current-client acceptance is claimed.

Completed commands:

```sh
PATH=/workspace/tooling/lua54/usr/bin:$PATH python3 tools/validate_recommendations.py \
  --output /workspace/artifacts/navigation-integrity-final-local \
  --lua51 /workspace/tooling/lua51/usr/bin/lua5.1 \
  --luac51 /workspace/tooling/lua51/usr/bin/luac5.1
python3 tools/reconcile_presentation_snapshot.py --verify-only
PATH=/workspace/tooling/lua54/usr/bin:$PATH python3 tools/build_navigation_review.py --check
python3 tools/validate_feature_acceptance.py --root .
```

The full navigation audit retains7,732 audited item IDs,74,004 class/faction
checks,9,435 usable-location rows,820 distinct simulated marker destinations and
25,608 raw source-evidence checks. Usable locations without a button, raw evidence
without a button and item-cache queries are all zero. The approved17-file
snapshot is exact. Source/faction eligibility exports match their approved files.
All39 definitions/39 entrance choices/76 aliases and29 runtime modules remain.

The new rendering suite checks60 reported-route/zoom/UI-scale combinations,
physical screen geometry, native exploration ordering, a registered custom
200-level range, texture/label opacity and attachment, area semantics, viewport
intersection and invalid canvas diagnostics. The location suite checks every
one of975 sources,662 original nonzero bounds,70 fresh exact primary references,
28 geometry corrections, preserved observations/conflicts, map/entity joins,
unsupported average rejection and the64x64 RGBA asset. Existing lifecycle tests
continue to drive genuine Core quest events and real regenerated choices.

Exact commit/tree/remote checks, GitHub CI completion and the mandatory clean,
committed, frozen-source/extracted-runtime package gate are recorded after this
commit in the external delivery receipt. Those final records—not this file's
parent revision—identify the delivered ZIP and its SHA-256. Keep the complete
BUILD_INFO, manifest, checksum and validation directory together. No public
release/tag or main/integration advancement is authorized or performed.

An earlier preliminary local attempt was stopped while finalizing the renderer;
it is not counted as a passing gate. Complete successful logs are in the local
receipt directory above and, for the final installable runtime, in the verified
package delivery. See ACCEPTANCE.md for the remaining actual-client checks.

The secondary-evidence receipt follow-up replaces an accidentally saved tool
argument error with successful named extracts and corrects the Classic/indexed
qualifications. The159-check local implementation receipt above is retained;
targeted projection/location/feature/snapshot checks validate the follow-up.
Final CI and the immutable extraction gate repeat all159 checks against the
final corrected GitHub revision, recorded in the delivery receipt.
