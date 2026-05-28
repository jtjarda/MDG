# Business Partner Request App

Samostatný projekt pro návrh aplikace na založení Business Partnera formou požadavku.

## Cíl

Aplikace má umožnit založit požadavek na nového Business Partnera, uložit jej jako draft, odeslat ke schválení a po schválení propsat data do cílových tabulek nebo standardního BP rozhraní.

## Základní směr

- OData V4 nad RAP business objektem.
- Preferovaný scénář: managed RAP with draft.
- Vlastní ABAP třídy pro validace, workflow akce, posting, field control a outbound integraci.
- Oddělit request/staging data od finálního BP masteru.
- UI pojmout jako Manage aplikaci nad životním cyklem požadavku.
- Pole řídit dynamicky podle připojeného systému a typu požadavku.

## Dokumenty

- [architecture.md](architecture.md) - architektura, stavový model a RAP/OData směr.
- [data-model.md](data-model.md) - aktuální návrh Z tabulek pro požadavek.
- [field-control.md](field-control.md) - návrh řízení dostupnosti, povinnosti a viditelnosti polí.
- [ui-design.md](ui-design.md) - návrh single-page formuláře podle referenční obrazovky.
- [open-questions.md](open-questions.md) - rozhodnutí, která je potřeba doplnit.
