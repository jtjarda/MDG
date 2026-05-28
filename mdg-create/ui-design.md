# Návrh UI

Design má vycházet z jednoduché single-page obrazovky podobné referenčnímu obrázku: kompaktní formulář, sekce pod sebou, minimum navigace a jasné akce dole.

## Charakter Obrazovky

- Jedna Manage obrazovka pro založení nebo úpravu požadavku.
- Kompaktní layout s více sekcemi pod sebou.
- Sekce opticky oddělené linkou nebo panelem.
- Povinná pole označená hvězdičkou.
- Primární akce dole: `Save draft` a `Submit request`.
- Ve schvalovacím režimu místo toho akce `Approve`, `Reject`, případně `Return`.
- Pole se zobrazují, skrývají nebo nastavují jako read-only podle cílového systému a stavu požadavku.
- Aplikace nezakládá standardní BP objekt přímo; po kontrole volá integrační ABAP třídu nebo službu.

## Sekce

### Global Data

Odpovídá hlavičce požadavku a technickému řízení.

Pole:

- `Request type`
- `Created by`
- `BP Creation`
- `Requesting country`
- `Extsys`
- `Status`

Defaultování a editace:

- `Requesting country` se předvyplní podle country settings uživatele.
- Změna `Requesting country` bude omezená rolí.
- `Created by` se předvyplní podle uživatele, který request vytváří.
- Pro Belgii bude `Created by` technický uživatel.
- `Created by`, `Created at`, `Changed by`, `Changed at` mají být read-only a mohou být v hlavičce stránky nebo v technickém panelu.

### Main Data

Základní BP identifikace.

Pole:

- `Partner GID`
- `Parent GID 1`
- `Parent GID 2`
- `Company name`
- `Search term`

Mapování na tabulky:

- `ZMDG_REQ-PARTNER_GID`
- `ZMDG_REQ-PARENT_GID1`
- `ZMDG_REQ-PARENT_GID2`
- `ZMDG_REQADR-NAME_ORG1`
- `ZMDG_REQADR-BU_SORT1`

### Identification Data

Identifikátory a systémová čísla.

Pole:

- `Company ID`
- `VAT number`
- `VAT Registration Number`
- `LEI Code`
- `DUNS`

Mapování:

- `ZMDG_REQ-PARTNER_ID`
- `ZMDG_REQTAX-TAXNUM`
- `ZMDG_REQ-LEI_CODE`
- `ZMDG_REQ-DUNS`

Daňová čísla řešit jako malou tabulku nad `ZMDG_REQTAX` s možností přidat řádek.

### Address

Hlavní adresa.

Pole:

- `Country`
- `District`
- `City`
- `City postal code`
- `Street`
- `House no`
- `House no suppl`

Mapování na `ZMDG_REQADR`.

### Address Variants

Referenční obrazovka ukazuje malou tabulku pro varianty adres podle `Nation`. Cílový koncept upřesňuje, že detail varianty adresy slouží pro alphabet-specific address detail.

Address variants budou součástí první verze. Doporučený datový základ je `ZMDG_REQADR` s klíčem `REQUEST_ID + NATION`.

Chování tlačítka plus:

- Uživatel stiskne plus v tabulce `Address variants`.
- Aplikace otevře pravý detailní sloupec nebo detailní panel `Address variant detail`.
- Uživatel nejdříve zvolí alphabet/nation, ve kterém bude varianta adresy udržovaná.
- V detailu se vyplní `Nation` a stejná adresní pole jako u hlavní adresy: company name, search term, country, district, city, postal code, street, house number a house number supplement.
- Po uložení se pravý sloupec zavře nebo zůstane v detailu podle nastavení UI.
- Tabulka vlevo zobrazí řádek s `Nation` a `Address preview`.

Pro Fiori/UI5 je nejvhodnější použít dvousloupcové chování přes Flexible Column Layout nebo podobný detailní panel. Vlevo zůstane hlavní požadavek, vpravo se edituje konkrétní adresa.

### Country Specific Data Detail

Sekce pro systémově a země-specifická data.

Pole:

- `Partner`
- `Partner group`
- `Partner category`
- `Organization`
- `Language`
- `Legal form`
- `Telephone no`
- `Mobile tel. no`
- `E-mail address`
- `Vendor`
- `Customer`
- `Inactive`
- `Inactive reason`

Mapování hlavně na `ZMDG_REQ`.

Defaultování:

- `Language` se předvyplní programovou logikou pro CZ/SK země.
- Pokud je company registration address v CZ, jazyk bude `CS`.
- Pokud je company registration address v SK, jazyk bude `SK`.
- Pokud company registration address není CZ ani SK, jazyk bude `EN`.

## Ovládání

V dolní části:

- `Save draft`
- `Submit request`

Podle stavu:

- `Approve`
- `Reject`
- `Return`
- `Send`
- `Retry send`

Akce mají být dostupné podle statusu a oprávnění přes RAP feature control.

`Discard` nebude samostatná perzistentní akce; podle konceptu uživatel zahodí rozpracovaný požadavek zavřením aplikace. Pokud už existuje uložený draft, je vhodné později rozhodnout, zda má mít samostatnou akci `Delete draft` nebo `Cancel`.

## Doporučení Pro Fiori

V OData V4/RAP bych UI rozdělil jako object page s jednou hlavní stránkou:

- header: request id, status, request type, extsys
- form sections: global data, main data, identification, address, country specific data
- table subsection: tax numbers
- table subsection: address variants
- footer actions: draft/submit/approve/reject

Pokud půjdeme cestou freestyle UI5, může layout více kopírovat referenční obrázek. Pokud Fiori elements, bude výsledek více standardizovaný, ale stále lze dosáhnout podobného členění přes facets a field groups. Pro plus u address variants je u freestyle varianty přirozený pravý detailní sloupec; u Fiori elements lze podobné chování řešit navigací na child detail nebo rozšířením přes custom section.

## Field Control

Viditelnost a povinnost polí v obrázku je potřeba řídit dynamicky.

Zdroj pravidel:

- `ZMDG_C_SYS` pro cílový systém,
- doporučená `ZMDG_C_FIELD` pro úroveň polí,
- status požadavku,
- request type,
- partner category,
- oprávnění uživatele.

Backend validace musí povinná pole kontrolovat znovu při `Submit`, i když jsou už povinná v UI.
