# Confirmed causes and ruled-out hypotheses

## Commerce regression

The accepted previous fix added capital containment and selected reputation
affiliations. Barrens is not a capital, so a source there correctly did not meet
that old capital rule. The catalogue contained exact shared recipe-book/vendor
joins for both factions, but eight of the ten commerce actors used by equipment
recipes had no service-side value. Mivin/Jim'bek were exceptions with explicit
side metadata. Missing values were preserved as unknown by generation, not
proven neutral and not demonstrably lost after a populated join.

`GetAcquisitionRouteFactionSide` read route/offer/actor/offer-index metadata.
For these missing fields it returned no side. `routesForCharacter` consequently
retained both vendor routes. `compactRecipeSummary` selected the first named
eligible seller. Prefect's Waistguard's first recorded seller was Gor'mak,
followed by Stondry Darkhammer. Thus a correct recipe identity could produce an
incorrect Alliance seller recommendation without any item-stat or class error.

The previous fix did not inspect ACA/DSL affiliation or exact camp vendor
inventories. Correcting RFC and saved-star access therefore could not solve
the missing commerce-service join. An explicit offer-side value could also
override contradictory actor metadata in the older precedence chain. The new
method-aware service decision rejects that conflict before route presentation.

## Presentation and requirements

The recipe formatter could emit generic routine-trainer text before checking
whether any teacher route survived. The wrapper also exempted routine text from
its empty-eligible-route replacement. The profession label separately used raw
trainer classifications when a skill requirement was missing. Those bypasses
are corrected; confirmed learned recipes and finished-item trade remain separate.

Legacy descriptions and action navigation had different fallback handling.
Some source-less commerce routes used structured NPC labels and stale inline
locations rather than actor IDs. Raw historical recipe paragraphs also named
both factions even after typed route filtering. Exact published joins now
project those routes to ACA actors, and commerce descriptions use the normalized
eligible summary; historical paragraphs stay in audit data. New
source-policy holds and the shared unverified fallback prevent a rejected route
from reappearing as legacy vendor text or a map choice. Bag overlay handling
also returned before shared hard-access checks; it now validates use/source
eligibility, while an owned usable bag needs no new acquisition route.

The old travel heuristic applied only below level 30 and only suppressed minor
gains. It treated missing neutral/vendor metadata as uncertain. It was a
convenience heuristic, not the newly requested restrictive territory default.
The new data table applies that default independently of upgrade magnitude.

## Source integrity

Historical generators directly downloaded unapproved provider APIs and accepted
dated derivative caches. Some verification labels describe those historical
audits, not current policy compliance. Domain/redirect/platform checks did not
previously gate research promotion. Those entry points now share the source
boundary; cache origins are not exempt. Old evidence remains retained for audit.

The fresh item-level corrections exposed another propagation requirement:
class objectives copy `targetLevel` before the later policy overlay loads.
Raising the catalogue field alone would leave those copied levels stale. The
three corrected requirements now also raise and re-sort affected class targets
once at load; material names and item IDs are preserved.

## Not established as causes

No evidence established that previously populated commerce faction metadata was
lost by serialization, that an item ID/spell ID misjoin created the reported
vendor, or that a persistent recommendation cache caused it. The two supported
price shapes were already understood by the old price renderer; they were not
the old defect. They are explicitly covered by the new service policy. No
ownership relationship between MAF2414 and wowforevertalents.com was established.
Automated test failures caused by new source holds/point corrections were
reviewed as intended output changes, not claimed as client failures.
