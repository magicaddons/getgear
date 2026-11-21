"""Offline source-boundary checks; observation IDs below are synthetic fixtures."""
import pathlib
import runpy

root=pathlib.Path(__file__).resolve().parents[1]
api=runpy.run_path(str(root/"tools/reconcile_acquisition_1_60.py"))
route=api["evidence_route"]
norm=api["norm"]

def source(actor):
    return {"type":"boss","npc":actor,"zone":"Fixture dungeon"}

def item(iid,name):
    return {"itemID":str(iid),"name":name,"zone":"Fixture dungeon"}

pending=(
    (10801,"Slitherscale Boots","Spawn of Hakkar"),
    (14525,"Boneclenched Gauntlets","Ras Frostwhisper"),
    (23173,"Abomination Skin Leggings","Sever"),
    (273044,"Arcanowisp Robes","Arcanic Enigma"),
)
for iid,name,actor in pending:
    result=route(item(iid,name),[source(actor)],{"bossNames":[actor]},[],[],{norm(actor)})
    assert result["role"]=="dungeon-enemy",(iid,result)
    assert result["confidence"]=="forever-community-reference"
    assert "item-to-NPC link/live drop unverified" in result["summary"]
    assert result["actor"]==actor and result["sourceURL"]==api["PLAY_URL"]

# The boundary is specific to reviewed gaps, not a ban on community references.
result=route(item(13387,"Foresight Girdle"),[source("Archivist Galford")],None,[],[],set())
assert result["role"]=="boss" and result["confidence"]=="forever-community-reference"

fixture_npc=900001
lead={"npcID":fixture_npc,"name":"Ras Frostwhisper","rank":"Boss"}
edge={"rel":"dropped_by","toKind":"npc","toId":fixture_npc,"installs":3,"lastSeen":"fixture"}
result=route(item(14525,"Boneclenched Gauntlets"),[source("Ras Frostwhisper")],None,[edge],[lead],set())
assert result["role"]=="boss" and result["confidence"]=="forever-observed-npc"

# Evidence for another candidate must not confirm the selected boss's link.
other={"npcID":fixture_npc,"name":"Other fixture actor","rank":"Boss"}
result=route(item(14525,"Boneclenched Gauntlets"),
             [source("Ras Frostwhisper"),source(other["name"])],None,[edge],[other],set())
assert result["role"]=="dungeon-enemy" and result["observations"][0]["name"]==other["name"]
print("PASS offline dungeon-link boundaries: reviewed gaps, publication leads, exact actor observations")
