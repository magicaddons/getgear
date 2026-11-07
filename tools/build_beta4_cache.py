#!/usr/bin/env python3
"""Rebuild only the broad Forever cache in Beta4's compact runtime format.

This does not overwrite 259 hand-researched item records or assert that
source labels are live-server verified. Review the upstream SHA, item count
and class eligibility BEFORE committing regenerated output.
"""
import argparse
import pathlib
import subprocess
import sys
import tempfile

ROOT=pathlib.Path(__file__).resolve().parents[1]
def run(*args):
    subprocess.run([sys.executable,*map(str,args)],check=True,cwd=ROOT)
def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--input",type=pathlib.Path,
                        help="Pinned Forever Cache.json; default downloads upstream")
    parser.add_argument("--output",type=pathlib.Path,default=ROOT/"EquipmentCache.lua")
    parser.add_argument("--report",type=pathlib.Path,default=ROOT/"docs/generated-forever-audit.json")
    args=parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="getgear-beta4-") as td:
        path=pathlib.Path(td)/"legacy-shape.lua"
        cmd=[ROOT/"tools/build_forever_catalog.py","--output",path,"--report",args.report]
        if args.input: cmd += ["--input",args.input]
        run(*cmd)
        run(ROOT/"tools/rewrite_beta4_generated.py","--input",path,
            "--output",args.output)
    output=args.output.read_text(encoding="utf8")
    assert "GetGear:AddRecommendation" not in output
    assert "GetGear.EquipmentEligibility" in output
    assert "GetGear.GeneratedForeverGear=audit" in output
    print("PASS Beta4 regenerated compact item cache; manual research overrides untouched.")
if __name__=="__main__":
    main()
