#!/usr/bin/env python3
"""A reviewed Forever exception must survive obsolete generator inputs.

Run the real generator in a temporary repository fixture. The simulated
Classic and quality feeds still classify Adept's Gloves as green/BoE;
all network access is intercepted, and unrelated eligible IDs must remain.
"""
from pathlib import Path
import contextlib
import csv
import io
import json
import os
import re
import runpy
import shutil
import tempfile
from unittest.mock import patch

root=Path(__file__).resolve().parents[1]
source=root/"docs/source-audit-1-60/all_items.csv"
register=root/"docs/source-audit-1-60/worlddrop_boe_fallback_exclusions.json"
records={int(r["itemID"]):r for r in csv.DictReader(source.open())}
actual=set(map(int,re.findall(r"\[(\d+)\]=true",(root/"WorldDropBoEIndex.lua").read_text())))
assert 4768 not in actual and 727 in actual, "Shipped fallback must omit the reviewed Rare/BoP item"
ids=set(sorted(actual)[:101])|{4768}
assert len(ids)==102
classic={"items":[{"id":i,"name":records[i]["name"],"quality":"Uncommon",
                   "binding":"Binds when equipped"}for i in sorted(ids)]}
quality={"rows":[[i,records[i]["name"],"UNCOMMON"]for i in sorted(ids)]}
calls=[]

class Response:
    def __init__(self,value):self.value=json.dumps(value).encode()
    def __enter__(self):return self
    def __exit__(self,*args):return False
    def read(self,*args):return self.value

def fake_open(request,**kwargs):
    url=request.full_url
    calls.append(url)
    if url=="https://www.wowforeverfriends.org/items/items.json":return Response(classic)
    if url in {"https://ahledger.com/api/catalog?class="+c for c in
               ("armor","weapon","recipe","trade-goods")}:return Response(quality)
    raise AssertionError("Unexpected network request: "+url)

oldcwd=Path.cwd()
with tempfile.TemporaryDirectory(prefix="getgear-boe-regression-")as directory:
    fixture=Path(directory)
    audit=fixture/"docs/source-audit-1-60"
    audit.mkdir(parents=True)
    shutil.copyfile(source,audit/"all_items.csv")
    shutil.copyfile(register,audit/register.name)
    try:
        os.chdir(fixture)
        with patch("urllib.request.urlopen",side_effect=fake_open),contextlib.redirect_stdout(io.StringIO()):
            runpy.run_path(str(root/"tools/generate_worlddrop_boe_index.py"),run_name="__main__")
        generated=set(map(int,re.findall(r"\[(\d+)\]=true",(fixture/"WorldDropBoEIndex.lua").read_text())))
        assert generated==ids-{4768}, "Obsolete feeds must not reintroduce the exception or lose other IDs"
        assert len(calls)==5
        result=(audit/"BOE_FILTER_INDEX.md").read_text()
        assert "reviewed-forever-non-green-or-non-boe: 1"in result
        # Invalid exclusions must fail closed, instead of suppressing genuine
        # green BoEs using an unchecked exception register.
        invalid=json.loads(register.read_text())
        assert len(invalid)==1 and invalid[0]["itemID"]==4768
        invalid[0].update(quality=2,binding=2)
        (audit/register.name).write_text(json.dumps(invalid))
        calls.clear()
        try:
            with patch("urllib.request.urlopen",side_effect=fake_open),contextlib.redirect_stdout(io.StringIO()):
                runpy.run_path(str(root/"tools/generate_worlddrop_boe_index.py"),run_name="__main__")
        except AssertionError as error:
            assert "green BoE cannot be excluded"in str(error)
        else:raise AssertionError("Invalid green-BoE exclusion was accepted")
        assert not calls, "Invalid reviewed facts should fail before fetching feeds"
    finally:os.chdir(oldcwd)
print("PASS offline green-BoE generator: reviewed Rare/BoP exception beats obsolete feeds; other IDs retained; invalid exclusion rejected")
