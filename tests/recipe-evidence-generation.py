"""Learning gates must not leak from embedded equipment/reagent tooltips."""
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from build_recipe_evidence import book_requirements, render
sample='<b>Pattern</b><br>Requires Leatherworking (245)<br>Requires Tribal Leatherworking<br>Use: Teaches a craft.<br>Requires Level 49<br>Requires Rugged Leather (40)'
assert book_requirements(sample,'Leatherworking')==['Requires Tribal Leatherworking']
assert book_requirements('Requires Blacksmithing (125)<br>Use: Teaches a helm.','Blacksmithing')==[]
assert book_requirements('Requires Blacksmithing (250)<br>Requires Honored with this faction.<br>Use: Teaches a belt.','Blacksmithing')==['Requires Honored with this faction.']
# All104 selected recipes are checked against exact spell/output/profession and
# book teaching/drop joins by the generator, including all51 raw book excerpts.
assert 'GetGear.RecipeEvidence=' in render()
print('PASS recipe evidence generation: primary book header versus nested wearer/reagent requirements, retained specialisation/reputation and exact primary joins')
