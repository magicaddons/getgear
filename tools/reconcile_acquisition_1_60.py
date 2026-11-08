#!/usr/bin/env python3
"""GetGear comprehensive acquisition reconciliation against public Forever evidence.

Writes one row per GetGear item and per recipe, plus a conservative Lua evidence
overlay for targeted dungeon/recipe sources.  Never changes eligibility,
item stats, reagent lists, or user SavedVariables.  Public data is not treated
as proof of live realm loot unless independent player observations support it.
"""
import collections,csv,datetime,hashlib,html,json,pathlib,re,urllib.request,urllib.parse
from html.parser import HTMLParser

ROOT=pathlib.Path(".")
REPORT=ROOT/"docs/source-audit-1-60/reconciliation-20261109"
CATALOGUE=ROOT/"docs/source-audit-1-60/all_items.csv"
RECIPES=ROOT/"docs/source-audit-1-60/recipes.csv"
DUNGEON=ROOT/"docs/source-audit-1-60/dungeon_sources.csv"
OUTPUT=ROOT/"AcquisitionEvidenceIndex.lua"
PLAY_URL="https://playfulls.com/database"
CACHE_URL="https://raw.githubusercontent.com/Napalmsteak/WoW-Classic-Item-Caches/main/Forever%20Cache.json"
CLASSIC_URL="https://www.wowforeverfriends.org/items/items.json"
NPC_URL="https://www.wowforeverfriends.org/library/data/npcs.json"
ENCOUNTER_URL="https://raw.githubusercontent.com/Everloot/everloot/main/web/src/data/game-data/client-encounters.json"
EVER_URL="https://everloot.app/api/edges?evidence=observed&limit=500"
LEVELS={"observed":5,"forever":4,"published-forever-dungeon-journal":4,"reported":3,
        "published-forever":3,"classic-reference":1,"client":1}
PROFESSIONS=("Blacksmithing","Leatherworking","Tailoring","Enchanting","Engineering","Alchemy","Cooking","First Aid")
UA="GetGear-Open-Source-Acquisition-Audit/1.0 (github.com/magicaddons/getgear)"
provenance={}
failures={}

def fetch(url,maxbytes=30_000_000):
    req=urllib.request.Request(url,headers={"User-Agent":UA,"Accept":"application/json,text/html"})
    with urllib.request.urlopen(req,timeout=55) as res:
        data=res.read(maxbytes)
        assert res.status==200
    provenance[url]={"bytes":len(data),"sha256":hashlib.sha256(data).hexdigest()}
    return data

def data(url):
    return json.loads(fetch(url))

def norm(value):
    return re.sub(r"[^a-z0-9]","",str(value or "").lower())

def indexrows(url):
    with open(url,encoding="utf-8",newline="") as stream:
        return list(csv.DictReader(stream))

def write_csv(filename,rows,fields):
    with (REPORT/filename).open("w",encoding="utf-8",newline="") as f:
        writer=csv.DictWriter(f,fieldnames=fields,extrasaction="ignore")
        writer.writeheader();writer.writerows(rows)

def lua_str(value):
    return json.dumps(str(value),ensure_ascii=False).replace("\\u2028"," ")

def playfulls():
    page=fetch(PLAY_URL).decode("utf-8","replace")
    found=re.search(r'<script[^>]*id="db-data"[^>]*>(.*?)</script>',page,re.S)
    assert found,"Playfulls database metadata unavailable"
    cfg=json.loads(html.unescape(found.group(1)))
    assert isinstance(cfg.get("shards"),list) and len(cfg["shards"])>=1
    def url(path):return urllib.parse.urljoin("https://playfulls.com",path)
    meta=data(url(cfg["meta"]))
    kinds=meta["sk"]
    sources=meta["so"]
    rows={}
    for shard in cfg["shards"]:
        for row in data(url(shard)):
            if isinstance(row,list) and len(row)>15 and isinstance(row[0],int):
                rows[row[0]]=row
    assert len(rows)>=20000,("Playfulls index unexpectedly small",len(rows))
    print("SOURCE Playfulls",len(rows),"items",len(sources),"published source labels",flush=True)
    def entries(itemid):
        row=rows.get(itemid,[])
        indices=row[15] if len(row)>15 and isinstance(row[15],list) else []
        entries=[]
        for offset in indices:
            if not isinstance(offset,int) or offset<0 or offset>=len(sources):continue
            s=sources[offset]
            if len(s)<6 or not isinstance(s[0],int) or s[0]>=len(kinds):continue
            kind=kinds[s[0]][0]
            entries.append({"type":kind,"npc":str(s[2] or "").strip(),
                "zone":str(s[4] or "").strip(),"path":str(s[5] or "").strip(),
                "note":str(s[3] or "").strip(),"sourceRow":offset,
                "label":str(kinds[s[0]][1] or "")})
        return entries
    return rows,entries,cfg

def everloot():
    out=[];url=EVER_URL;seen=set();meta={}
    while url and url not in seen and len(out)<16000:
        seen.add(url);obj=data(url)
        assert isinstance(obj,dict) and isinstance(obj.get("edges"),list)
        out.extend(obj["edges"])
        meta={"dataAsOf":obj.get("dataAsOf"),"total":obj.get("total"),
              "attribution":obj.get("attribution"),"complete":obj.get("next") is None}
        url=obj.get("next")
    if url:meta["complete"]=False
    assert len(out)>=500,("Everloot observed records unexpectedly sparse",len(out))
    edges=collections.defaultdict(list)
    for e in out:
        if not isinstance(e,dict):continue
        if (e.get("evidence")=="observed" and e.get("fromKind")=="item"
            and isinstance(e.get("fromId"),int) and int(e.get("installs",0))>=3):
            edges[e["fromId"]].append(e)
    print("SOURCE Everloot",len(out),"observed edges",sum(map(len,edges.values())),"item relationships",flush=True)
    return edges,meta

def classic():
    ci=data(CLASSIC_URL).get("items",[])
    nc=data(NPC_URL).get("records",[])
    return ({r["id"]:r for r in ci if isinstance(r,dict) and isinstance(r.get("id"),int)},
            {r["id"]:r for r in nc if isinstance(r,dict) and isinstance(r.get("id"),int)})

def roles_from_play(sources,bossnames):
    for s in sources:
        if s["type"]=="boss" and s["npc"]:
            return "boss",s
    for s in sources:
        if s["type"]=="dungeon":
            npc=s["npc"]
            if norm(npc)=="trashmobs":return "trash",s
            if npc and norm(npc) in bossnames:return "boss-reference",s
            if npc:return "dungeon-enemy",s
            return "dungeon-general",s
    return "none",None

def classic_monsters(item,ci,npcs):
    row=ci.get(item)
    if not row:return []
    return [{"npcID":npcid,"name":str(npcs.get(npcid,{}).get("name","")),
             "rank":str(npcs.get(npcid,{}).get("rank","")),
             "source":CLASSIC_URL} for npcid in row.get("dropNpcIds",[]) if isinstance(npcid,int)][:15]

def evidence_route(catalogue,sources,cacheitem,observed,classic_leads,bossnames):
    is_dungeon=True
    pfkind,pf=roles_from_play(sources,bossnames)
    forever=[str(v) for v in (cacheitem or {}).get("bossNames",[]) if isinstance(v,str) and v.strip()]
    matched=[]
    for e in observed:
        if e.get("rel")!="dropped_by" or e.get("toKind")!="npc":continue
        npc=e.get("toId")
        if not isinstance(npc,int):continue
        name=next((c["name"] for c in classic_leads if c["npcID"]==npc),"")
        # A named NPC ID and source/instance corroboration are required for
        # dungeon-specific claims. Observed edges by themselves lack zone.
        if name and any(norm(name)==norm(s["npc"]) for s in sources if s["type"] in ("boss","dungeon")):
            matched.append({"name":name,"npcID":npc,"installs":e.get("installs"),
                            "lastSeen":e.get("lastSeen"),"evidence":"everloot-3plus-installs"})
    zone=str(catalogue.get("zone") or "").strip()
    if pf:
        zone=pf["zone"] or zone
        actor=pf["npc"] or "dungeon enemies"
        role=pfkind
        if pfkind=="boss-reference":role="boss"
        elif pfkind=="dungeon-enemy":
            # If a specific Classic loot NPC is independently listed as a
            # normal mob of the same name, it can be a *trash lead*, not
            # confirmed Forever loot.  Do not treat an unknown enemy as boss.
            if any(norm(c["name"])==norm(actor) and c["rank"]=="Normal"
                   for c in classic_leads):
                role="trash"
        if matched:
            matched_names={norm(m["name"]) for m in matched}
            if norm(actor) in matched_names:
                status="forever-observed-npc"
                qualified="Forever observed"
            else:
                status="forever-community-reference"
                qualified="Forever reference; live unverified"
        else:
            status="forever-community-reference"
            qualified="Forever reference; live unverified"
        if role=="boss":
            summary=f"{zone} | Boss: {actor} ({qualified})"
        elif role=="trash":
            if norm(actor)=="trashmobs":summary=f"{zone} | Trash drop ({qualified})"
            else:summary=f"{zone} | Trash: {actor} ({qualified})"
        elif role=="dungeon-enemy":
            summary=f"{zone} | Enemy: {actor}; boss/trash unverified"
        else:summary=f"{zone} | Dungeon drop (enemy unverified)"
        return dict(role=role,actor=actor,zone=zone,confidence=status,
                    summary=summary,sourceURL=PLAY_URL,observations=matched,foreverBoss=forever)
    if forever:
        encounter=[n for n in forever if norm(n) in bossnames]
        if encounter:
            actor=encounter[0]
            return dict(role="boss",actor=actor,zone=zone,confidence="forever-reference-unverified",
                        summary=f"{zone} | Boss: {actor} (Forever reference; live unverified)",
                        sourceURL=CACHE_URL,observations=[],foreverBoss=forever)
        actor=forever[0]
        return dict(role="dungeon-enemy",actor=actor,zone=zone,
                    confidence="forever-reference-unverified",
                    summary=f"{zone} | Enemy: {actor} (boss/trash unverified)",
                    sourceURL=CACHE_URL,observations=[],foreverBoss=forever)
    if len(classic_leads)==1 and classic_leads[0]["name"]:
        actor=classic_leads[0]["name"]
        role="trash" if classic_leads[0]["rank"]=="Normal" else "enemy"
        return dict(role=role,actor=actor,zone=zone,confidence="classic-reference",
                    summary=f"{zone} | {('Trash' if role=='trash' else 'Enemy')}: {actor} (Classic ref.; verify Forever)",
                    sourceURL=CLASSIC_URL,observations=[],foreverBoss=[])
    return dict(role="unknown",actor="",zone=zone,confidence="unresolved",
                summary="",sourceURL="",observations=[],foreverBoss=forever)

def recipe_routes(book,play_sources,observed,npcs):
    source=play_sources.get(book,[]) if book else []
    observed_notes=[]
    for e in observed.get(book,[]):
        if e.get("rel") in ("dropped_by","sold_by","reward_from"):
            npc=npcs.get(e.get("toId"),{})
            observed_notes.append({"relation":e["rel"],"targetID":e.get("toId"),
                                   "targetType":e.get("toKind"),
                                   "targetName":npc.get("name",""),
                                   "installs":e.get("installs"),"lastSeen":e.get("lastSeen")})
    if observed_notes:
        kinds={e["relation"] for e in observed_notes}
        if "sold_by" in kinds:method="vendor"
        elif "reward_from" in kinds:method="quest"
        else:method="drop"
        return method,"forever-observed",observed_notes,source
    for kind in ("merchant_favor","vendor","boss","dungeon","worlddrop","drop","quest","questdrop"):
        for s in source:
            if s["type"]==kind:
                method=("vendor" if kind in ("merchant_favor","vendor") else
                        "quest" if kind in ("quest","questdrop") else "drop")
                return method,"forever-community-reference",[],source
    return "unresolved","unresolved",[],source

def main():
    REPORT.mkdir(parents=True,exist_ok=True)
    items=indexrows(CATALOGUE)
    recipes=indexrows(RECIPES)
    dungeon=indexrows(DUNGEON)
    assert len(items)==7707 and len(recipes)==1252 and len(dungeon)==577
    dungeon_ids={int(r["itemID"]) for r in dungeon}
    recipe_by_id={int(r["itemID"]):r for r in recipes}
    play,play_entries,play_config=playfulls()
    fcache={r["itemId"]:r for r in data(CACHE_URL) if isinstance(r,dict) and isinstance(r.get("itemId"),int)}
    encounters=data(ENCOUNTER_URL).get("instances",{})
    bossnames={norm(e.get("name")) for r in encounters.values() for e in r if e.get("name")}
    observations,evermeta=everloot()
    classicitems,npcs=classic()
    print("DATASET",len(fcache),"Forever items",len(classicitems),"classic-reference items",
          len(npcs),"Classic NPC names",len(bossnames),"client encounter names",flush=True)

    all_rows=[];dungeon_rows=[];recipe_rows=[];changes={}
    d_stats=collections.Counter();r_stats=collections.Counter()
    unmatched_forever=[];duplicate_identity=[]
    for item in items:
        iid=int(item["itemID"])
        name=item["name"]
        cache=fcache.get(iid)
        if cache and norm(cache.get("name"))!=norm(name):
            duplicate_identity.append([iid,name,cache.get("name")])
            cache=None
        if not cache:unmatched_forever.append(iid)
        ps=play_entries(iid)
        if iid in play and norm(play[iid][1])!=norm(name):
            ps=[]
        classic_leads=classic_monsters(iid,classicitems,npcs)
        observed=observations.get(iid,[])
        pf_types=sorted(set(s["type"] for s in ps))
        type_data=sorted(set((cache or {}).get("sourceTypes",[])))
        is_dungeon=iid in dungeon_ids
        result=None
        if is_dungeon:
            result=evidence_route(item,ps,cache,observed,classic_leads,bossnames)
            d_stats[(result["role"],result["confidence"])]+=1
            dungeon_rows.append({
                "itemID":iid,"name":name,"level":item["level"],
                "existingType":item["sourceType"],"existingRoute":item["source"],
                "existingEvidence":item["sourceEvidence"],"dungeon":result["zone"],
                "reconciledRole":result["role"],"enemy":result["actor"],
                "confidence":result["confidence"],"sourceSummary":result["summary"],
                "playerObservedNPCs":json.dumps(result["observations"],ensure_ascii=False),
                "ForeverCacheBossNames":";".join(result["foreverBoss"]),
                "ClassicMobLeads":json.dumps(classic_leads,ensure_ascii=False),
                "PlayfullsRoutes":json.dumps(ps,ensure_ascii=False),
                "sourceURL":result["sourceURL"],
                "needsLiveVerification":result["confidence"]!="forever-observed-npc",
            })
            # Only add new display detail where the old generic import did not
            # have an editorial item-specific source. Retain all manual patch
            # descriptions and all strong observations.
            generic=("unverified" in item["sourceType"].lower()
                     or item["source"]==item["sourceType"]
                     or item["source"].lower().startswith("dungeon enemy:"))
            highmanual=item["sourceEvidence"] in ("observed","forever",
                "published-forever-dungeon-journal","published-forever")
            # Never overwrite SourceEnrichment's hand-reviewed examples.
            manual_exception=iid in (1943,1951,271098)
            if (generic and not highmanual and not manual_exception
                and result["confidence"]!="unresolved"
                and result["summary"]):
                changes[iid]={"summary":result["summary"],
                              "confidence":result["confidence"],
                              "url":result["sourceURL"]}
        recipe=recipe_by_id.get(iid)
        recipeStatus=""
        if recipe:
            # Crucial: the crafted item isn't the teachable plan. Resolve
            # recipe book IDs independently; don't label every craft trainer.
            books=[int(x) for x in recipe.get("recipeItems","").split(";")
                   if x.isdigit()]
            book=books[0] if len(books)==1 else None
            method,conf,recipe_observed,recipe_sources=recipe_routes(book,
                         {book:play_entries(book)} if book else {},observations,npcs)
            research_method=recipe["method"]
            existing_method=research_method.lower()
            if "forever-observed" in existing_method:
                category="forever-observed"
            elif existing_method.startswith("vendor recipe") or existing_method=="dropped recipe":
                category="manual-researched"
            elif existing_method.startswith("trainer"):
                category="trainer-reference"
            elif existing_method=="initial profession":
                category="initial"
            elif method!="unresolved":
                category=method+"-reference" if conf!="forever-observed" else method+"-observed"
            elif book:
                category="recipe-item; origin unverified"
            else:category="learning source unverified"
            recipeStatus=category
            r_stats[category]+=1
            recipe_rows.append({
                "itemID":iid,"name":name,"level":item["level"],"profession":recipe["profession"],
                "existingLearning":research_method,"candidateMethod":method,
                "classification":category,"evidence":conf if method!="unresolved" else recipe["methodEvidence"],
                "bookItemID":book or "","spellID":recipe["spellID"],
                "bookSources":json.dumps(recipe_sources,ensure_ascii=False),
                "observedBookAcquisition":json.dumps(recipe_observed,ensure_ascii=False),
                "AHledgerMethod":recipe["AHLedgerMethod"],
                "materialsStatus":recipe["materialStatus"],
                "requiresLiveCheck":category not in ("forever-observed","initial","drop-observed","vendor-observed","quest-observed"),
            })
            if (iid not in changes and book and
                ("unresolved" in existing_method or "plans/pattern" in existing_method)
                and recipe_sources and method!="unresolved"):
                candidate=recipe_sources[0]
                vendor_actor=candidate["npc"] or candidate["zone"] or "vendor/enemy"
                action=("vendor" if method=="vendor" else "dropped" if method=="drop" else "quest")
                detail=f"Recipe: {action} plans/pattern — {vendor_actor} (Forever ref.; live unverified)"
                changes[iid]={"summary":detail,"confidence":"forever-community-reference",
                              "url":PLAY_URL,"patternID":book}
            elif iid not in changes and book and "unresolved" in existing_method:
                changes[iid]={"summary":f"Recipe: plans/pattern #{book} (source unverified)",
                              "confidence":"client-pattern-unknown","url":"","patternID":book}
        all_rows.append({
            "itemID":iid,"name":name,"level":item["level"],
            "existingSourceType":item["sourceType"],"existingConfidence":item["sourceEvidence"],
            "ForeverCacheTypes":";".join(type_data),
            "PlayfullsTypes":";".join(pf_types),
            "PlayfullsSourceCount":len(ps),
            "EverlootObservedEdges":len(observed),
            "Dungeon":is_dungeon,"dungeonRole":result["role"] if result else "",
            "dungeonConfidence":result["confidence"] if result else "",
            "RecipeClassification":recipeStatus,
            "additiveSummary":changes.get(iid,{}).get("summary",""),
            "unresolvedSource":(not ps and not observed and not type_data),
        })
    # All source discoveries are non-destructive: only add labelled summaries,
    # never change sourceType, source, item levels, eligibility, or reagents.
    OUTPUT.write_text(
        "local addonName, GetGear = ...\n"
        "-- Generated 1–60 source *reference* evidence, not guaranteed live loot.\n"
        "-- See docs/source-audit-1-60/reconciliation-20261109 for provenance.\n"
        "GetGear.AcquisitionEvidenceIndex = {\n"
        + "".join("  ["+str(iid)+"]={summary="+lua_str(row["summary"])+
                  ",confidence="+lua_str(row["confidence"])+
                  ",url="+lua_str(row.get("url",""))+
                  (",patternID="+str(row["patternID"]) if row.get("patternID") else "")+
                  "},\n" for iid,row in sorted(changes.items()))
        + "}\n",encoding="utf8")
    write_csv("all_items_reconciled.csv",all_rows,list(all_rows[0]))
    write_csv("dungeon_items_reconciled.csv",dungeon_rows,list(dungeon_rows[0]))
    write_csv("recipes_reconciled.csv",recipe_rows,list(recipe_rows[0]))
    unresolved=[r for r in dungeon_rows if r["reconciledRole"] in
                ("unknown","dungeon-general","dungeon-enemy","enemy")]
    write_csv("dungeon_source_followups.csv",unresolved,list(dungeon_rows[0]))
    # Reference-only vendors or trainers have NOT been verified live; keep
    # their high-priority plan books in the follow-up list.
    unresolved_books=[r for r in recipe_rows if r["bookItemID"]
                      and (r["classification"].endswith("-reference")
                           or "unverified" in r["classification"])]
    write_csv("recipe_source_followups.csv",unresolved_books,list(recipe_rows[0]))
    # Prioritize active 1–30, specific unknown-source patterns, then 31–60.
    manual=sorted(unresolved,key=lambda r:(int(r["level"])>30,int(r["level"]),r["name"]))[:40]
    with (REPORT/"OPTIONAL_IN_GAME_CHECKS.md").open("w",encoding="utf8") as f:
        f.write("# Optional, targeted WoW Forever verification\n\n")
        f.write("These are **optional**, not prerequisites for continued research. "
                "Check an item only if you naturally encounter its boss or recipe vendor. "
                "Never farm long hours solely for this audit.\n\n")
        f.write("## Early-level dungeon leads still missing a confirmed boss/trash source\n\n")
        f.write("| Level | Item ID | Item | Reported dungeon | Best current source |\n|---:|---:|---|---|---|\n")
        for r in manual[:20]:
            f.write(f"| {r['level']} | {r['itemID']} | {r['name']} | "
                    f"{r['dungeon']} | {r['reconciledRole']} ({r['confidence']}) |\n")
        f.write("\n## Recipe verification\n\n")
        f.write("The 68 consecutive level-60 item IDs 273884–273951 have recipe book IDs "
                "but still need live availability evidence. Do **not** assume their recipes "
                "are trainer-taught or currently obtainable. "
                "No user verification needed until that content is actually encountered.\n")
    counts=collections.Counter(r["confidence"] for r in dungeon_rows)
    roles=collections.Counter(r["reconciledRole"] for r in dungeon_rows)
    coverage=collections.Counter(r["RecipeClassification"] for r in all_rows if r["RecipeClassification"])
    source_counts=collections.Counter(r["PlayfullsTypes"] for r in all_rows if r["PlayfullsTypes"])
    provenance["lastRunUTC"]=datetime.datetime.now(datetime.timezone.utc).isoformat()
    provenance["sourceCrediting"]={
        "Everloot":"CC BY-SA 4.0; https://everloot.app; source records credited",
        "Playfulls":"Public community loot reference; https://playfulls.com/methodology; boss loot not live guaranteed",
        "Napalmsteak":"Forever Wowhead client tooltip cache; source identities reference-only",
        "WoW Forever Friends":"ClassicDB reference only; Classic NPC ranks do not prove Forever loot",
        "AHledger":"Forever client recipe acquisition reference, not observed trainer inventories"}
    provenance["Everloot"]=evermeta
    provenance["Playfulls"]={"items":len(play),"sourceRecords":len(play_config["shards"]),"database":PLAY_URL}
    provenance["DataLimitations"]={"unmatchedForeverItems":len(unmatched_forever),
           "mismatchedItemNames":len(duplicate_identity),
           "noLiveDropClaims":True,"liveTrainerConfirmations":False}
    (REPORT/"provenance.json").write_text(json.dumps(provenance,indent=2,ensure_ascii=False)+"\n",encoding="utf8")
    lines=[
        "# GetGear acquisition-source reconciliation — 1–60",
        "",
        "This is a comprehensive **evidence reconciliation**; it does not assert that all "
        "acquisition sources are confirmed in a live Forever realm.",
        "",
        "## Catalogue and recipes",
        f"- All **{len(items):,} / 7,707** equipment records examined.",
        f"- All **{len(recipes):,} / 1,252** crafting recipes examined.",
        f"- All **{len(dungeon):,} / 577** dungeon-associated equipment records examined.",
        f"- New, conservative in-addon acquisition summaries generated: **{len(changes):,}**.",
        f"- Combined Forever cache entries: **{len(fcache):,}**; Playfulls item entries: **{len(play):,}**.",
        f"- Published player-observed relationships: **{sum(len(x) for x in observations.values()):,}**.",
        f"- Dungeon rows needing exact enemy/boss/trash verification: **{len(unresolved):,}**.",
        f"- Recipe book origins that still require live verification: **{len(unresolved_books):,}**.",
        f"- Item ID name mismatches against Forever cache: **{len(duplicate_identity)}**.",
        "",
        "## Dungeon source classifications (reference quality, not drop-rate proof)",
    ]
    for k,n in roles.most_common():lines.append(f"- {k}: {n:,}")
    lines.extend(["","## Dungeon evidence confidence"])
    for k,n in counts.most_common():lines.append(f"- {k}: {n:,}")
    lines.extend(["","## Recipe learning (do not conflate *crafting* and *learning*)"])
    for k,n in coverage.most_common():lines.append(f"- {k}: {n:,}")
    lines.extend(["","## Critical policy",
        "- *Forever observed* means at least three Everloot installations independently "
        "recorded the item-to-NPC edge, and a published dungeon listing linked that NPC "
        "to this specific dungeon. These observations may still be incomplete.",
        "- *Forever community reference* is a loot-list claim checked against client "
        "item IDs; it is **not** evidence of a live drop chance.",
        "- *Classic reference* is used only as an explicitly uncertain farming lead.",
        "- Encounter names in the client identify NPCs, not their loot tables.",
        "- An unobserved recipe book is not evidence that a trainer teaches it or "
        "that a live vendor currently offers it.",
        "- Original 1,252 crafting ingredient lists are **untouched**.",
        "- Higher-confidence manually reviewed source text and item-ID exceptions "
        "take priority over this generated evidence.",
        "- The index does not alter class eligibility, player status, equipment quality, "
        "recipe availability gates, or the two overlay filters.",
        "",
        "## Audit files",
        "- [All equipment records](all_items_reconciled.csv) — one row per item.",
        "- [Dungeon acquisitions](dungeon_items_reconciled.csv) — boss, trash, "
        "named enemy, uncertainty, observations and source references.",
        "- [Unresolved dungeon sources](dungeon_source_followups.csv).",
        "- [Recipe acquisition and pattern book reconciliation](recipes_reconciled.csv).",
        "- [Unresolved recipe sources](recipe_source_followups.csv).",
        "- [Optional in-game verification](OPTIONAL_IN_GAME_CHECKS.md).",
        "- [Source versions, hashes, attribution and limitations](provenance.json).",
        "",
        "## Sources and licence notes",
        "- [Playfulls](https://playfulls.com/database), "
        "[methodology](https://playfulls.com/methodology) — client + community loot sources "
        "(no live drop rates).",
        "- [Everloot](https://everloot.app) — player-observed edges; "
        "[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) "
        "attribution and share-alike on derived Everloot observations.",
        "- [Forever item cache](https://github.com/Napalmsteak/WoW-Classic-Item-Caches) "
        "— published Forever-specific tooltips and source references.",
        "- [WoW Forever Friends](https://www.wowforeverfriends.org/library/sources/) "
        "— Classic baseline NPC/item lookup explicitly labelled unverified for Forever.",
        "- [AHledger](https://ahledger.com) — supplemental recipe acquisition reference.",
    ])
    (REPORT/"README.md").write_text("\n".join(lines)+"\n",encoding="utf8")
    for book in (273952,273968,273976,273988,274019):
        print("BOOK_SOURCE_SAMPLE",book,json.dumps(play_entries(book),ensure_ascii=False)[:1000],flush=True)
    print("RECONCILE DONE",len(all_rows),"items",len(dungeon_rows),"dungeon",
          len(recipe_rows),"recipes",len(changes),"in-addon summaries",flush=True)
    print("DUNGEON ROLES",dict(roles),flush=True)
    print("DUNGEON CONFIDENCE",dict(counts),flush=True)
    print("RECIPE STATUS",dict(coverage),flush=True)
    print("UNRESOLVED",len(unresolved),"dungeon",len(unresolved_books),"recipe",flush=True)
    assert len(all_rows)==7707 and len(dungeon_rows)==577 and len(recipe_rows)==1252
    assert len(changes)>=100,"Insufficient actionable source evidence; fail closed"

if __name__=="__main__":main()
