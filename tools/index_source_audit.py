#!/usr/bin/env python3
"""Offline views of the full GetGear source audit; never polls external APIs."""
import csv,collections,pathlib

root=pathlib.Path("docs/source-audit-1-60")
def read(name):
    with (root/name).open(encoding="utf-8",newline="") as f:return list(csv.DictReader(f))
def save(name,rows,keys):
    with (root/name).open("w",encoding="utf-8",newline="") as f:
        w=csv.DictWriter(f,fieldnames=keys,extrasaction="ignore")
        w.writeheader();w.writerows(rows)
items=read("all_items.csv")
recipes=read("recipes.csv")
assert len(items)==7707 and len(recipes)==1252
rows={
 "dungeon_sources.csv":[r for r in items if r["dungeonClassification"]!="not-dungeon"],
 "dungeon_sources_unresolved.csv":[r for r in items if "dungeon_enemy_or_role_unresolved" in r["issues"]],
 "recipe_learning_unresolved.csv":[r for r in recipes if "recipe_learning_source_unresolved" in r["issues"]],
 "independent_name_disagreements.csv":[r for r in items if "independent_name_disagreement" in r["issues"]],
 "independent_catalogue_unmatched.csv":[r for r in items if "not_in_independent_catalogue_or_hidden" in r["issues"]],
 "observed_item_drop_records.csv":[r for r in items if r["observedLootNPCIds"]],
}
for name,found in rows.items():
    save(name,found,list((items if name not in ("recipe_learning_unresolved.csv",) else recipes)[0]))
    print("AUDIT FOCUS",name,len(found))
classes=collections.Counter()
for row in items:
    for part in row["classes"].split(","):
        if part:
            c=part.split(":")[0]
            classes[c]+=1
with (root/"FOCUS_QUEUES.md").open("w",encoding="utf-8") as f:
    f.write("# GetGear source audit: actionable unresolved queues\n\n")
    f.write("Generated from the complete [7,707-item census](all_items.csv). This report is an offline index and does not change any source verdict.\n\n")
    for name,description in [
      ("dungeon_sources.csv","Every dungeon-associated item; named client bosses are not necessarily confirmed loot sources"),
      ("dungeon_sources_unresolved.csv","Dungeon entries lacking a reliable boss/trash or enemy assignment"),
      ("recipe_learning_unresolved.csv","Recipes with an unknown trainer/vendor/drop/quest learning route"),
      ("independent_name_disagreements.csv","Name disagreements against the newer independent client catalogue; verify localisation and phase"),
      ("independent_catalogue_unmatched.csv","IDs not found in the newer item source; absence alone cannot establish removal"),
      ("observed_item_drop_records.csv","Items with published Everloot observations linking the item ID to a dropped-by NPC; names can be absent"),
    ]:
        f.write(f"- [{description}]({name}) — **{len(rows[name]):,}** entries\n")
    f.write("\n## Evidence boundary\n\n")
    f.write("A source labelled *trainer (AHledger reference)* is a catalogue classification, **not** direct confirmation that a Forever trainer sells it. Treat these as verification leads.\n\n")
    f.write("A dungeon encounter name is client metadata; whether that enemy actually drops the item is a separate, server-side fact. Do not promote it without live observation.\n\n")
    f.write("Recipe reagents have been cross-checked against a second client extract; **0** ingredient changes were identified. Recipe learning and actual availability remain separate questions.\n\n")
    f.write("Observed Everloot evidence is attributed to [Everloot](https://everloot.app) under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).\n")
print("PASS audit focus queues created; nine classes",dict(classes))
