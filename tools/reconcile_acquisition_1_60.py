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
# Explicit per-item WoW Forever Dungeon Journal links, NOT extrapolated
# from Classic NPC rank or an encounter name alone. Each journal page directly
# lists the *finished equipment* against the named rare-boss loot table.
# Journal presence is not a live observed drop or a drop-rate guarantee.
SCARLET_GRAVEYARD_RARES = {
    "Ironspine": {
        "url":"https://www.wowhead.com/forever/dungeon-journal/scarlet-monastery-graveyard/ironspine-rare",
        "items":{7686:"Ironspine's Eye",7687:"Ironspine's Fist",7688:"Ironspine's Ribcage"},
    },
    "Fallen Champion": {
        "url":"https://www.wowhead.com/forever/dungeon-journal/scarlet-monastery-graveyard/fallen-champion-rare",
        "items":{7689:"Morbid Dawn",7690:"Ebon Vise",7691:"Embalmed Shroud"},
    },
    "Azshir the Sleepless": {
        "url":"https://www.wowhead.com/forever/dungeon-journal/scarlet-monastery-graveyard/azshir-the-sleepless-rare",
        "items":{7708:"Necrotic Wand",7709:"Blighted Leggings",7731:"Ghostshard Talisman"},
    },
}
JOURNAL_RARE_LOOT={
    iid:(itemname,boss,record["url"])
    for boss,record in SCARLET_GRAVEYARD_RARES.items()
    for iid,itemname in record["items"].items()
}
# Forever-specific loot references identify these two *trash* NPCs.
# The source pages also name the exact finished item. NPC attribution is
# published source evidence only, not a verified current-server drop rate.
FOREVER_TRASH_DROPS = {
    3569: {
        "name":"Vicar's Robe","npc":"Death's Head Priest","zone":"Razorfen Kraul",
        "url":"https://www.wowhead.com/forever/zone=491/razorfen-kraul",
    },
    5943: {
        "name":"Rift Bracers","npc":"Arugal's Voidwalker","zone":"Shadowfang Keep",
        "url":"https://azeroth.wiki/forever/items/rift-bracers",
    },
}
# Checkpoint 4: item-ID/name-locked encounter-role references. Published Forever
# guides can recycle older loot mappings; no live drop/spawn percentage is claimed.
FOREVER_DUNGEON_ROLE_REFERENCES = {
    9457: {"name":"Royal Diplomatic Scepter","actor":"Dark Iron Ambassador","zone":"Gnomeregan","role":"rare-boss","url":"https://www.wowhead.com/forever/dungeon-journal/gnomeregan/dark-iron-ambassador-rare","confidence":"published-forever-dungeon-journal","basis":"Forever Dungeon Journal item listing","warning":"rare spawn"},
    10804: {"name":"Fist of the Damned","actor":"Ogom the Wretched","zone":"The Temple of Atal'Hakkar","role":"boss","url":"https://www.wowhead.com/forever/guide/the-temple-of-atalhakkar-dungeon-overview-location-rewards","confidence":"forever-encounter-historic-loot-reference","basis":"Forever boss encounter and historic item-to-NPC lead","warning":"item loot in Forever unconfirmed"},
    11633: {"name":"Spiderfang Carapace","actor":"Hedrum the Creeper","zone":"Blackrock Depths","role":"boss","url":"https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards","confidence":"published-forever-dungeon-guide","basis":"Forever guide encounter loot reference","warning":"random Ring of Law encounter"},
    11726: {"name":"Savage Gladiator Chain","actor":"Gorosh the Dervish","zone":"Blackrock Depths","role":"boss","url":"https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards","confidence":"published-forever-dungeon-guide","basis":"Forever guide encounter loot reference","warning":"random Ring of Law encounter"},
    11728: {"name":"Savage Gladiator Leggings","actor":"Ok'thor the Breaker","zone":"Blackrock Depths","role":"boss","url":"https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards","confidence":"published-forever-dungeon-guide","basis":"Forever guide encounter loot reference","warning":"random Ring of Law encounter"},
    11729: {"name":"Savage Gladiator Helm","actor":"Hedrum the Creeper","zone":"Blackrock Depths","role":"boss","url":"https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards","confidence":"published-forever-dungeon-guide","basis":"Forever guide encounter loot reference","warning":"random Ring of Law encounter"},
    11730: {"name":"Savage Gladiator Grips","actor":"Eviscerator","zone":"Blackrock Depths","role":"boss","url":"https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards","confidence":"published-forever-dungeon-guide","basis":"Forever guide encounter loot reference","warning":"random Ring of Law encounter"},
    11731: {"name":"Savage Gladiator Greaves","actor":"Anub'shiah","zone":"Blackrock Depths","role":"boss","url":"https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards","confidence":"published-forever-dungeon-guide","basis":"Forever guide encounter loot reference","warning":"random Ring of Law encounter"},
    12952: {"name":"Gyth's Skull","actor":"Gyth","zone":"Upper Blackrock Spire","role":"boss","url":"https://www.wowhead.com/forever/guide/upper-blackrock-spire-dungeon-overview-location-rewards","confidence":"published-forever-dungeon-guide","basis":"Forever guide encounter loot reference","warning":""},
    16669: {"name":"Pauldrons of Elements","actor":"Gyth","zone":"Upper Blackrock Spire","role":"boss","url":"https://www.wowhead.com/forever/guide/upper-blackrock-spire-dungeon-overview-location-rewards","confidence":"published-forever-dungeon-guide","basis":"Forever guide encounter loot reference","warning":""},
    16695: {"name":"Devout Mantle","actor":"Solakar Flamewreath","zone":"Upper Blackrock Spire","role":"boss","url":"https://www.wowhead.com/forever/guide/upper-blackrock-spire-dungeon-overview-location-rewards","confidence":"published-forever-dungeon-guide","basis":"Forever guide encounter loot reference","warning":"Father Flame encounter"},
    18760: {"name":"Necromantic Band","actor":"Death Knight Darkreaver","zone":"Scholomance","role":"boss","url":"https://www.wowhead.com/forever/item=18760/necromantic-band","confidence":"forever-item-historic-loot-reference","basis":"Forever item page with historic NPC loot reference","warning":"quest-summoned"},
    22242: {"name":"Verek's Leash","actor":"Verek","zone":"Blackrock Depths","role":"rare-boss","url":"https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards","confidence":"published-forever-dungeon-guide","basis":"Forever guide encounter loot reference","warning":"rare spawn"},
    23169: {"name":"Scorn's Icy Choker","actor":"Scorn","zone":"Scarlet Monastery: Graveyard","role":"rare-boss","url":"https://www.wowhead.com/forever/guide/classes/warlock/demonology/level-30-dps-overview","confidence":"published-forever-beta-class-guide","basis":"Forever beta class-guide rare-elite item reference","warning":"historical Scourge-event spawn availability unverified"},
}
# Dark/Relic Coffer is a *container*. The item link is only a historic lead.
DUNGEON_CONTAINER_LEADS = {
    11945: {"name":"Dark Iron Ring","url":"https://foreverchanges.pro/item/11945/dark-iron-ring"},
    11946: {"name":"Fire Opal Necklace","url":"https://www.wowhead.com/forever/item=11946/fire-opal-necklace"},
}
UA="GetGear-Open-Source-Acquisition-Audit/1.0 (github.com/magicaddons/getgear)"
# Historically tagged as dungeon equipment, but the client recipe creates it.
# Keep the original record in the historic dungeon report without treating it as loot.
MISCLASSIFIED_DUNGEON_CRAFTS = {
    220606: ("Enchanting", "https://www.wowhead.com/forever/spell=1249128/idol-of-the-dream"),
}
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
            if (norm(actor) not in bossnames
                and any(norm(c["name"])==norm(actor)
                        and c["rank"] not in ("Boss","World Boss")
                        for c in classic_leads)):
                # Elite dungeon enemies often are trash; an NPC-rank
                # lookup alone must not be mistaken for a boss record.
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
    assert len(JOURNAL_RARE_LOOT)==9 and set(JOURNAL_RARE_LOOT).issubset(dungeon_ids)
    assert len(FOREVER_DUNGEON_ROLE_REFERENCES)==14 and set(FOREVER_DUNGEON_ROLE_REFERENCES).issubset(dungeon_ids)
    assert len(DUNGEON_CONTAINER_LEADS)==2 and set(DUNGEON_CONTAINER_LEADS).issubset(dungeon_ids)
    assert not set(FOREVER_DUNGEON_ROLE_REFERENCES).intersection(JOURNAL_RARE_LOOT)
    assert len(FOREVER_TRASH_DROPS)==2 and set(FOREVER_TRASH_DROPS).issubset(dungeon_ids)
    recipe_by_id={int(r["itemID"]):r for r in recipes}
    reviewed_path=REPORT/"reviewed_recipe_sources.json"
    reviewed_bytes=reviewed_path.read_bytes()
    reviewed_rows=json.loads(reviewed_bytes)
    reviewed={r["itemID"]:r for r in reviewed_rows}
    assert len(reviewed)==len(reviewed_rows), "Duplicate reviewed recipe identity"
    provenance["reviewed_recipe_sources.json"]={"bytes":len(reviewed_bytes),
        "sha256":hashlib.sha256(reviewed_bytes).hexdigest()}
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
        generated_hyjal_vendor_reference=False
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
        craft_pattern_route=is_dungeon and iid in recipe_by_id
        result=None
        if is_dungeon:
            if iid in MISCLASSIFIED_DUNGEON_CRAFTS:
                profession,url=MISCLASSIFIED_DUNGEON_CRAFTS[iid]
                result={"role":"crafted-item","actor":"","zone":"Crafting ("+profession+")",
                        "confidence":"published-forever-recipe",
                        "summary":profession+" | Crafted equipment (not a dungeon drop; live recipe stock unverified)",
                        "sourceURL":url,"observations":[],"foreverBoss":[]}
            elif craft_pattern_route:
                # Prior audits conflated a craftable item's dungeon-LOOTED
                # PATTERN with the finished gear being a dungeon loot drop.
                # These remain dungeon-associated for historic audit parity,
                # but cannot be assigned a boss/trash equipment drop.
                result={"role":"crafted-pattern","actor":"","zone":item["zone"],
                        "confidence":"recipe-origin-unverified","summary":"",
                        "sourceURL":"","observations":[],"foreverBoss":[]}
            elif iid in JOURNAL_RARE_LOOT:
                expected_name,actor,journal_url=JOURNAL_RARE_LOOT[iid]
                assert norm(name)==norm(expected_name),(
                    "Dungeon Journal item ID/name changed",iid,name,expected_name)
                result={"role":"rare-boss","actor":actor,
                        "zone":"Scarlet Monastery: Graveyard",
                        "confidence":"published-forever-dungeon-journal",
                        "summary":f"Scarlet Monastery: Graveyard | Rare boss: {actor} "
                                  "(Forever Dungeon Journal; live drop unverified)",
                        "sourceURL":journal_url,"observations":[],
                        "foreverBoss":[actor]}
            elif iid in FOREVER_DUNGEON_ROLE_REFERENCES:
                ref=FOREVER_DUNGEON_ROLE_REFERENCES[iid]
                assert norm(name)==norm(ref["name"]), ("Checkpoint 4 item name drift",iid,name,ref["name"])
                label="Rare boss" if ref["role"]=="rare-boss" else "Boss"
                warning=("; "+ref["warning"]) if ref["warning"] else ""
                result={"role":ref["role"],"actor":ref["actor"],"zone":ref["zone"],
                        "confidence":ref["confidence"],
                        "summary":f'{ref["zone"]} | {label}: {ref["actor"]} '
                                  f'({ref["basis"]}; live drop unverified{warning})',
                        "sourceURL":ref["url"],"observations":[],"foreverBoss":[ref["actor"]]}
            elif iid in DUNGEON_CONTAINER_LEADS:
                ref=DUNGEON_CONTAINER_LEADS[iid]
                assert norm(name)==norm(ref["name"]), ("Coffer item name drift",iid,name,ref["name"])
                result={"role":"container-lead","actor":"Dark/Relic Coffer",
                        "zone":"Blackrock Depths","confidence":"historic-container-reference",
                        "summary":"Blackrock Depths | Container lead: Dark/Relic Coffer "
                                  "(Classic-era item source only; Forever coffer loot unverified)",
                        "sourceURL":ref["url"],"observations":[],"foreverBoss":[]}
            elif iid in FOREVER_TRASH_DROPS:
                src=FOREVER_TRASH_DROPS[iid]
                assert norm(name)==norm(src["name"]),(
                    "Forever trash item ID/name changed",iid,name,src["name"])
                result={"role":"trash","actor":src["npc"],
                        "zone":src["zone"],
                        "confidence":"published-forever-trash-reference",
                        "summary":f'{src["zone"]} | Trash: {src["npc"]} '
                                  "(Forever loot reference; live drop unverified)",
                        "sourceURL":src["url"],"observations":[],
                        "foreverBoss":[str(v) for v in (cache or {}).get("bossNames",[])
                                       if isinstance(v,str)]}
            else:
                result=evidence_route(item,ps,cache,observed,classic_leads,bossnames)
            d_stats[(result["role"],result["confidence"])]+=1
            dungeon_rows.append({
                "itemID":iid,"name":name,"level":item["level"],
                "existingType":item["sourceType"],"existingRoute":item["source"],
                "existingEvidence":item["sourceEvidence"],"dungeon":result["zone"],
                "sourceIsCraftedPattern":craft_pattern_route,
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
            manual_exception=iid in (1943,1951,220606,271098)
            # The observed Blighted Leggings entry has no separate summary.
            # Its original observed confidence, instructions and source remain
            # untouched; the journal may *add* a human-readable rare-boss hint.
            journal_summary_addition=(iid in JOURNAL_RARE_LOOT
                and item["sourceEvidence"]=="observed")
            # Item-locked Forever role evidence may be added alongside an older
            # Classic/manual source; AcquisitionEvidence never overwrites it.
            checkpoint4_additive=(iid in FOREVER_DUNGEON_ROLE_REFERENCES
                and not highmanual)
            if ((generic and not highmanual) or journal_summary_addition
                or checkpoint4_additive) \
                and not manual_exception and result["confidence"]!="unresolved" \
                and result["summary"]:
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
                category=("trainer-reference-with-pattern-item" if book
                          else "trainer-reference")
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
                if (book>=273952 and book<=274019 and
                    norm(vendor_actor)=="aisarranightmeadow" and method=="vendor"):
                    generated_hyjal_vendor_reference=(
                        conf=="forever-community-reference"
                        and category=="vendor-reference")
                    detail=("Recipe: Aisarra Nightmeadow, Mount Hyjal "
                            "(reputation/quest/slot gates may apply; vendor stock unverified)")
                else:
                    detail=f"Recipe: {action} plans/pattern — {vendor_actor} (Forever ref.; live unverified)"
                changes[iid]={"summary":detail,"confidence":"forever-community-reference",
                              "url":PLAY_URL,"patternID":book}
            elif iid not in changes and book and "unresolved" in existing_method:
                changes[iid]={"summary":f"Recipe: plans/pattern #{book} (source unverified)",
                              "confidence":"client-pattern-unknown","url":"","patternID":book}
        # Item/book/spell locked publication research supplements an unknown
        # learning route. Never rewrite the original classification, learning
        # gates, ingredients, or a stronger observed/manual source.
        if iid in reviewed:
            ref=reviewed[iid]
            assert recipe and name==ref["name"], ("Reviewed recipe identity drift",iid)
            assert int(recipe["spellID"])==ref["spellID"]
            assert recipe["profession"]==ref["profession"]
            assert recipe["recipeItems"]==str(ref["bookItemID"])
            assert ref["liveVerified"] is False
            assert "unverified" in ref["summary"]
            # Reviewed publication-level recipes may already have manual
            # instructions. Supplement those facts without replacing their
            # source/confidence/summary; AcquisitionEvidence preserves them.
            # Existing observations and source text remain primary at runtime;
            # an independently researched book route is additive metadata.
            # Exact reviewed Hyjal book gates may replace this iteration's
            # generic generated vendor hint. Observed/manual/dungeon entries
            # never set that marker and keep their original precedence.
            if iid not in changes or generated_hyjal_vendor_reference:
                changes[iid]={"summary":ref["summary"],"confidence":ref["confidence"],
                    "url":ref["bookURL"],
                    "patternID":None if (ref.get("warningOnly") or ref.get("bookOriginUnknown")) else ref["bookItemID"],
                    "recipeReference":True,"details":ref.get("details","")}
        # Actionable vendor and quest research beyond the dungeon/recipe
        # queues. Only enrich already vendor/quest/undocumented catalogue
        # records; never turn a generic world-drop into an assumed vendor
        # source (which would also conflict with the BoE overlay filter).
        if iid not in changes and not is_dungeon and not recipe:
            genericType=str(item["sourceType"] or "").lower()
            manualQuality=item["sourceEvidence"] in (
                "observed","forever","published-forever",
                "published-forever-dungeon-journal","reported")
            wanted=None
            if genericType.startswith("vendor") or "source not documented" in genericType:
                wanted=("vendor","merchant_favor")
            elif genericType.startswith("quest") or "quest reward" in genericType:
                wanted=("quest",)
            if wanted and not manualQuality:
                found=next((s for s in ps if s["type"] in wanted and s["npc"]
                            and s["zone"] and "(horde)" not in s["zone"].lower()),None)
                if found:
                    if found["type"]=="quest":
                        detail=("Quest: "+found["npc"]+" — "+found["zone"]
                                +" (Forever reference; quest eligibility unverified)")
                    else:
                        detail=("Vendor: "+found["npc"]+" — "+found["zone"]
                                +" (Forever reference; live stock unverified)")
                    changes[iid]={"summary":detail,
                                  "confidence":"forever-community-reference",
                                  "url":PLAY_URL}
        all_rows.append({
            "itemID":iid,"name":name,"level":item["level"],
            "existingSourceType":item["sourceType"],"existingConfidence":item["sourceEvidence"],
            "ForeverCacheTypes":";".join(type_data),
            "ForeverCacheSources":";".join((cache or {}).get("sourceLabels",[])),
            "PlayfullsTypes":";".join(pf_types),
            "PlayfullsSourceCount":len(ps),
            "PlayfullsFirstSource":(
                str(ps[0]["type"])+": "+str(ps[0]["npc"])+", "+str(ps[0]["zone"])
                if ps else ""),
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
                  (",recipeReference=true" if row.get("recipeReference") else "")+
                  (",details="+lua_str(row["details"]) if row.get("details") else "")+
                  "},\n" for iid,row in sorted(changes.items()))
        + "}\n",encoding="utf8")
    write_csv("all_items_reconciled.csv",all_rows,list(all_rows[0]))
    write_csv("dungeon_items_reconciled.csv",dungeon_rows,list(dungeon_rows[0]))
    true_dungeon=[r for r in dungeon_rows if r["reconciledRole"] not in ("crafted-pattern","crafted-item")]
    write_csv("dungeon_equipment_drops.csv",true_dungeon,list(dungeon_rows[0]))
    write_csv("recipes_reconciled.csv",recipe_rows,list(recipe_rows[0]))
    unresolved=[r for r in dungeon_rows if r["reconciledRole"] in
                ("unknown","dungeon-general","dungeon-enemy","enemy","container-lead")]
    write_csv("dungeon_source_followups.csv",unresolved,list(dungeon_rows[0]))
    # Reference-only vendors or trainers have NOT been verified live; keep
    # their high-priority plan books in the follow-up list.
    unresolved_books=[r for r in recipe_rows if r["bookItemID"]
                      and ("reference" in r["classification"]
                           or "unverified" in r["classification"])]
    write_csv("recipe_source_followups.csv",unresolved_books,list(recipe_rows[0]))
    named_vendor=[r for r in recipe_rows if r["classification"]=="vendor-reference"]
    trainer_books=[r for r in recipe_rows
                   if r["classification"]=="trainer-reference-with-pattern-item"]
    write_csv("recipe_vendor_book_checks.csv",named_vendor,list(recipe_rows[0]))
    write_csv("recipe_trainer_book_checks.csv",trainer_books,list(recipe_rows[0]))
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
        f.write("The 68 consecutive level-60 item IDs 273884–273951 have book IDs "
                "and are listed by Playfulls under **Aisarra Nightmeadow, Mount Hyjal "
                "(Alliance)** as a provisional VENDOR lead. The public listing does "
                "**not** prove live vendor stock, accessible inventory or current "
                "availability. Do not mislabel these as trainer-taught. "
                "No user verification is needed until that content is encountered.\n")
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
        f"- All **{len(dungeon):,} / 577** historically dungeon-associated records examined, "
        f"including **{roles['crafted-pattern']:,}** crafted items with possible dungeon pattern routes "
        f"and **{roles['crafted-item']:,}** item incorrectly catalogued as dungeon loot.",
        f"- New, conservative in-addon acquisition summaries generated: **{len(changes):,}**.",
        f"- Combined Forever cache entries: **{len(fcache):,}**; Playfulls item entries: **{len(play):,}**.",
        f"- Published player-observed relationships: **{sum(len(x) for x in observations.values()):,}**.",
        f"- True dungeon-equipment records: **{len(true_dungeon):,}**; "
        f"still requiring encounter or container-loot confirmation: **{len(unresolved):,}**.",
        f"- Recipe book origins that still require live verification: **{len(unresolved_books):,}** "
        f"({len(named_vendor):,} named vendor references; {len(trainer_books):,} "
        "trainer-labelled recipes with separate pattern-book IDs).",
        f"- Item ID name mismatches against Forever cache: **{len(duplicate_identity)}**.",
        "- Nine Scarlet Monastery Graveyard rare-boss loot references are attributed "
        "to the Forever Dungeon Journal, with no live drop-rate claims.",
        "- Two named dungeon trash equipment sources (Vicar's Robe and Rift Bracers) "
        "are now labelled from published Forever loot references; no live drop rates.",
        "- Checkpoint 4 identifies **14** more encounter roles from Forever-published guides, "
        "journal and beta references; none establishes live drop rates.",
        "- **2** Dark/Relic Coffer leads are containers, not enemies, and remain unresolved "
        "because Forever item-to-coffer loot is unverified.",
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
        "- *Published Forever trash reference* names a specific equipment item and "
        "trash NPC in a Forever zone/item listing, but is **not** a live drop observation.",
        "- *Classic reference* is used only as an explicitly uncertain farming lead.",
        "- Encounter names in the client identify NPCs, not their loot tables.",
        "- An unobserved recipe book is not evidence that a trainer teaches it or "
        "that a live vendor currently offers it.",
        "- The 68 new level-60 book items have a published *Aisarra Nightmeadow* "
        "(Mount Hyjal) vendor lead, **not** live confirmed stock.",
        "- Example Forever plan tooltips independently identify requirements beyond "
        "the vendor: Grovekeeper Leggings requires Friendly status and the "
        "Friendly Advice quest; Grovekeeper Mantle requires reputation "
        "progress and shoulder specialization. Other books may have their "
        "own reputation or specialization gates.",
        "- A trainer-labelled recipe with a pattern item is marked for a teaching-method "
        "check; the two routes could both exist and should not be called contradictory "
        "without server evidence.",
        "- Non-dungeon vendor/quest details only supplement imported generic vendor/quest entries and are explicitly labelled reference-only.",
        "- Original 1,252 indexed crafting ingredient lists are **untouched**; one additional "
        "client-confirmed craft is corrected in SourceEnrichment.lua.",
        "- Higher-confidence manually reviewed source text and item-ID exceptions "
        "take priority over this generated evidence.",
        "- The index does not alter class eligibility, player status, equipment quality, "
        "recipe availability gates, or the two overlay filters.",
        "",
        "## Audit files",
        "- [All equipment records](all_items_reconciled.csv) — one row per item, including raw published source relationships and observation records.",
        "- [All historically dungeon-associated records](dungeon_items_reconciled.csv), "
        "including separately classified crafted-pattern and misclassified crafted-item entries.",
        "- [Actual dungeon equipment drops](dungeon_equipment_drops.csv) — "
        "boss, trash, enemy, confidence and observed sources.",
        "- [Unresolved dungeon sources](dungeon_source_followups.csv).",
        "- [Recipe acquisition and pattern book reconciliation](recipes_reconciled.csv).",
        "- [Unresolved recipe sources](recipe_source_followups.csv).",
        "- [68 named-vendor pattern-book verification leads](recipe_vendor_book_checks.csv).",
        "- [Recipes with both trainer-classified references and pattern books](recipe_trainer_book_checks.csv).",
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
        "- [WoWhead Grovekeeper Leggings pattern](https://www.wowhead.com/forever/item=273964) "
        "and [Grovekeeper Mantle pattern](https://www.wowhead.com/forever/item=273958) "
        "— published plan tooltips with class/reputation/quest specialization requirements.",
        "- [AHledger](https://ahledger.com) — supplemental recipe acquisition reference.",
        "- [WoWhead Forever Razorfen Kraul](https://www.wowhead.com/forever/zone=491/razorfen-kraul) "
        "and [Forever caster guide](https://www.wowhead.com/forever/guide/classes/warlock/affliction/level-30-dps-overview) "
        "— Vicar's Robe attributed to Death's Head Priest, classed as trash.",
        "- [Azeroth.wiki Forever Rift Bracers](https://azeroth.wiki/forever/items/rift-bracers) "
        "— Arugal's Voidwalker in Shadowfang Keep listed as trash; "
        "the published listing does not establish current drop probability.",
    ])
    (REPORT/"README.md").write_text("\n".join(lines)+"\n",encoding="utf8")
    for book in (273952,273968,273976,273988,274019):
        print("BOOK_SOURCE_SAMPLE",book,json.dumps(play_entries(book),ensure_ascii=False)[:1000],flush=True)
    print("RECONCILE DONE",len(all_rows),"items",len(dungeon_rows),"dungeon",
          len(recipe_rows),"recipes",len(changes),"in-addon summaries",flush=True)
    print("DUNGEON ROLES",dict(roles),"true_dungeon",len(true_dungeon),flush=True)
    print("DUNGEON CONFIDENCE",dict(counts),flush=True)
    print("RECIPE STATUS",dict(coverage),flush=True)
    print("UNRESOLVED",len(unresolved),"true dungeon",len(unresolved_books),"recipe",
          "vendor_books",len(named_vendor),"trainer_books",len(trainer_books),flush=True)
    assert len(all_rows)==7707 and len(dungeon_rows)==577 and len(recipe_rows)==1252
    assert roles["crafted-item"]==1 and roles["crafted-pattern"]==24
    assert roles["rare-boss"]==12 and roles["trash"]>=137
    assert roles["container-lead"]==2
    assert len(true_dungeon)==552 and len(unresolved)==6
    assert len(changes)>=100,"Insufficient actionable source evidence; fail closed"

if __name__=="__main__":main()
