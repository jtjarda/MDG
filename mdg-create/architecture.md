# Architektura Business Partner Request App

## Doporučený scénář

Pro objekt "požadavek na založení BP" dává největší smysl použít managed RAP scénář s draftem.

```text
Fiori/UI5 Manage BP Requests
        |
OData V4 UI service binding
        |
RAP business object: ZI_MDG_REQ
        |
Behavior implementation: ZBP_I_MDG_REQ
        |
+-- ZCL_MDG_BP_REQ_VALIDATOR
+-- ZCL_MDG_BP_REQ_WORKFLOW
+-- ZCL_MDG_BP_REQ_SENDER
+-- ZCL_MDG_BP_REQ_FIELDCONTROL
+-- ZCL_MDG_BP_REQ_DEFAULTS
+-- ZCL_MDG_BP_REQ_LOG
        |
ZMDG_REQ, ZMDG_REQADR, ZMDG_REQTAX, ZMDG_C_SYS
```

Managed RAP by měl spravovat persistenci requestových tabulek. Vlastní ABAP třídy se použijí pro business logiku, nikoliv jako náhrada celé RAP persistence vrstvy.

První verze nezakládá standardní BP/customer/vendor objekt přímo. Aplikace vytvoří a zkontroluje požadavek a následně zavolá ABAP třídu nebo službu jiného týmu pro odeslání dat do externích systémů.

## Root a Kompozice

Navržený RAP business object:

```text
ZI_MDG_REQ
  composition [0..*] _Address : ZI_MDG_REQADR
  composition [0..*] _Tax     : ZI_MDG_REQTAX
```

Protože address variants mají být součástí první verze, `ZMDG_REQADR` by měla mít v klíči `REQUEST_ID + NATION`. Hlavní adresa může mít iniciální `NATION`, varianty vyplněnou hodnotu.

## Kdy zůstat u managed RAP

- Request data jsou ukládaná do vlastních Z tabulek.
- Potřebujeme draft, locking, ETag a standardní save sequence.
- UI má pracovat s objektem požadavku, ne přímo se standardním BP masterem.
- Akce typu submit, approve, reject a post lze modelovat jako behavior actions.

## Kdy zvažovat unmanaged RAP

- Pokud by RAP objekt přímo reprezentoval standardního Business Partnera a persistenci by plně řídila standardní API/BAPI/CVI logika.
- Pokud by create/update/delete musely celé běžet přes legacy API a Z tabulky by nebyly primární persistence.
- Pokud by objekt byl projekcí nad externím systémem bez přímého ukládání do lokálních tabulek.

## Stavový model

```text
DRAFT
  -> SUBMITTED
  -> CHECKED
  -> IN_APPROVAL
  -> APPROVED
  -> SENDING
  -> SENT

Vedlejší větve:
  -> REJECTED
  -> CANCELLED
  -> ERROR
```

## RAP Akce

Navržené behavior actions:

```abap
action Submit result [1] $self;
action Approve result [1] $self;
action Reject parameter ZS_MDG_REQ_REJECT result [1] $self;
action Cancel result [1] $self;
action SendToExternal result [1] $self;
action RetrySend result [1] $self;
action Validate result [1] $self;
```

Akce `Submit`, `Approve` a `SendToExternal` by měly volat validační třídu a vracet zprávy přes RAP `reported`/`failed`, aby se chyby zobrazily přímo v UI.

## Field Control

Dostupnost, povinnost a viditelnost polí se bude řídit podle `extsys` a dalších atributů požadavku.

- `ZMDG_C_SYS` definuje připojený systém a základní integrační vlastnosti.
- Detailní field-control doporučuji řešit samostatnou customizing tabulkou, například `ZMDG_C_FIELD`.
- RAP implementace může field control vystavit přes `get_instance_features`.
- Backend validace musí povinnosti kontrolovat znovu při `Submit` a `SendToExternal`.

## Defaultování

Defaultování hodnot řešit přes RAP determinations nebo přes explicitní defaultovací třídu volanou při create.

Pravidla z cílového konceptu:

- `Requesting country` se předvyplní podle country settings uživatele.
- Změna `Requesting country` bude omezená rolí.
- `Created by` se předvyplní podle uživatele, který request vytváří.
- Pro Belgii bude `Created by` technický uživatel.
- `Language` se předvyplní programovou logikou:
  - company registration address CZ -> `CS`
  - company registration address SK -> `SK`
  - jiná země -> `EN`

## Validace

Validace rozdělit podle fáze:

- draft: technická konzistence, základní formáty
- submit: povinná pole, duplicity, daňové identifikátory, cílový systém
- approval: kontrola oprávnění a stavových přechodů
- sending: finální kontrola před odesláním dat do externí služby nebo ABAP třídy

Backend validace má být zdroj pravdy. UI validace použít jen pro okamžitou ergonomii.

## Odeslání a Integrace

Po uložení/submitu se provedou kontroly. Pokud pro danou zemi nebo systém není potřeba schválení, může aplikace rovnou zavolat integrační ABAP třídu/službu. Pokud je schválení potřeba, volání proběhne až po schválení.

```text
SUBMITTED
  -> validation
  -> approval needed?
     -> yes: IN_APPROVAL -> APPROVED -> SendToExternal
     -> no: SendToExternal
  -> update request status
  -> application log
```

Aktuální směr je synchronní zpracování. I tak doporučuji logovat výsledek volání a technickou chybovou zprávu do requestu nebo aplikačního logu, aby šlo ručně provést retry.
