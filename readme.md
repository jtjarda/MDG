# MDG mini-suite

Tento repository obsahuje Fiori/RAP mini-suite pro vyhledavani Business Partneru a zakladani MDG pozadavku.

## Architektonicke pravidlo

### UI pomaha, backend rozhoduje

Frontend aplikace (`mdg-search`, `mdg-create`) jsou tenky klient. Jejich role je zlepsit uzivatelsky komfort, posbirat kontext, spustit akci a zajistit plynulou navigaci. Frontend muze filtrovat nabidky, skryvat irelevantni volby a pomahat uzivateli, ale neni nositelem tvrdych business pravidel ani bezpecnostnich kontrol.

ABAP RAP backend je ultimatni strazce business logiky. Factory action `CreateRequest(...)` rozhoduje, zda jde o Create nebo Change pozadavek, overuje opravneni, kontroluje business pravidla a zaklada draft. Jakakoliv omezeni, ktera maji byt skutecne vynucena, musi byt validovana na backendu.

Odmitnute operace backend vraci standardnim RAP mechanismem pres `FAILED` a `REPORTED`. Fiori Elements tyto zpravy zpracuje standardnim zpusobem, bez nutnosti duplikovat validacni logiku ve frontendovem TypeScriptu.

## Aplikace

### `mdg-search`

Fiori Elements aplikace pro vyhledavani Business Partneru.

Hlavni odpovednosti:

- vyhledani BP a zobrazeni detailu
- vyber ciloveho systemu pro create/change request
- zavolani RAP factory action `CreateRequest(...)` pres model `create`
- navigace na draft detail v aplikaci `mdg-create`

Launchpad:

```text
BSP/UI5 app: ZMDG_BP_SEARCH
Component ID: c4s.mdg.mdgsearch
Intent: #ZMDGBusinessPartner-search
```

### `mdg-create`

Fiori Elements aplikace pro praci s MDG pozadavky.

Hlavni odpovednosti:

- zobrazeni List Reportu pozadavku
- zobrazeni a editace Object Page draftu
- standardni Fiori Elements draft lifecycle
- navigace bez parametru zpet do `mdg-search` z List Reportu

Launchpad:

```text
BSP/UI5 app: ZMDG_CREATE_REQ
Component ID: c4p.mdg.mdgcreaterequest
Intent: #MDGBpRequest-create
```

## Deploy

Obe UI5 aplikace se deployuji do ABAP UI5 repository systemu `https://hsr.con4pas.cz`, klient `140`, package `ZMDG`, transport `HSRK900682`.

Priklad:

```powershell
cd C:\Users\JTikal\Documents\MDG\mdg-search
npm.cmd run deploy
```

```powershell
cd C:\Users\JTikal\Documents\MDG\mdg-create\mdgcreaterequest
npm.cmd run deploy
```

## Launchpad content

Pouzite katalogy:

```text
Technical catalog: ZMDG_TC_APPS
Business catalog: ZMDG_BC_APPS
Group/Page: MDG
```
