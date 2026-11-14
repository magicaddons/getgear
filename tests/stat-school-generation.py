"""Independent passive-school parsing and potential proficiency negative guards."""
import sys
sys.dont_write_bytecode=True
import importlib.util
from pathlib import Path
R=Path(__file__).resolve().parents[1]
def module(name,path):
 s=importlib.util.spec_from_file_location(name,R/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
m=module('flags','tools/generate_forever_stat_flags.py')
for school,bit in m.SCHOOL_BITS.items():
 assert m.school_facts(f'<td>+6 Intellect</td><br>Equip: Increases damage done by {school} spells and effects by up to 10.')[:3]==[bit,False,False]
assert m.school_facts('One-Hand Dagger +1 Agility Chance on hit: Causes 50 Fire damage.')[:3]==[0,False,False]
assert m.school_facts('Equip: Increases damage done by Shadow and Fire spells by up to 6.')[0]==5
assert m.school_facts('Equip: Increases damage and healing done by magical spells and effects by up to 12.')[:3]==[0,True,True]
assert m.school_facts('+6 Intellect Equip: Increases damage done by Frost spells by up to 10. Equip: Increases healing done by magical spells and effects by up to 4.')[:3]==[2,False,True]
# Importer must never reintroduce the one-/two-hand class-mask defect.
f=module('catalogue','tools/build_forever_catalog.py')
for subclass in ['Mace','Sword','Axe']:
 html=f'<b class="q2">Fixture</b><table><tr><td>Two-Hand</td><td>{subclass}</td></tr></table>Requires Level 23'
 row,reason=f.parse_equipment(dict(itemId=999000,name='Fixture',itemExpansion='Forever',tooltipHtml=html))
 assert row and not row['mask']&1 and not row['mask']&16,(subclass,row,reason)
print('PASS AH2 school extraction:attributes do not broaden school bonuses;generic/healing/mixed/procs separated;two-hand importer class restrictions')
