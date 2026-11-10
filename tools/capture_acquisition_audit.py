#!/usr/bin/env python3
"""Capture the reconciler's actual feed responses without requesting them twice.

This optional research command runs the unchanged reconciliation entry point.
Every fetch still uses its original implementation and returns its original bytes;
there is no response replacement, replay, retry or network-failure fallback.
"""

import argparse
import datetime
import hashlib
import importlib.util
import json
from pathlib import Path
import urllib.error


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("checkpoint", help="Alphanumeric audit label, such as 8ad")
    parser.add_argument("--output-root", type=Path, required=True)
    args = parser.parse_args()
    if not args.checkpoint.isalnum():
        parser.error("checkpoint must be alphanumeric")

    root = Path(__file__).resolve().parent.parent
    output = args.output_root / (args.checkpoint + "-http-capture")
    output.mkdir(parents=True, exist_ok=True)
    spec = importlib.util.spec_from_file_location(
        "getgear_reconciliation", root / "tools/reconcile_acquisition_1_60.py"
    )
    reconciler = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reconciler)
    original_fetch = reconciler.fetch
    manifest, payloads = {}, {}

    def recording_fetch(url, *fetch_args, **fetch_kwargs):
        body = original_fetch(url, *fetch_args, **fetch_kwargs)
        if "playfulls.com/db/" in url or "everloot.app/api/" in url:
            digest = hashlib.sha256(body).hexdigest()
            target = output / (digest + ".body")
            target.write_bytes(body)
            assert target.read_bytes() == body
            fingerprint = {"bytes": len(body), "sha256": digest}
            assert reconciler.provenance[url] == fingerprint
            manifest[url] = {
                **fingerprint,
                "workspacePath": str(target.resolve()),
                "capturedUTC": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            }
            payloads[url] = {**fingerprint, "data": json.loads(body)}
        return body

    reconciler.fetch = recording_fetch
    try:
        reconciler.main()
    except urllib.error.HTTPError as error:
        if error.code == 429:
            print("RATE LIMIT: respect Retry-After", error.headers.get("Retry-After"))
        raise
    finally:
        # A failed run leaves partial diagnostic evidence, never a PASS claim.
        (output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
        (args.output_root / (args.checkpoint + "-raw-payloads.json")).write_text(
            json.dumps(payloads) + "\n"
        )
    print("PASS exact HTTP capture: original fetch/bytes/fingerprints;", len(manifest),
          "responses; no duplicate diagnostic feed requests")


if __name__ == "__main__":
    main()
