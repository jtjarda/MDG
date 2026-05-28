# Řízení Polí Podle Systému

Požadavek má měnit dostupnost, povinnost a viditelnost polí podle cílového systému. `ZMDG_C_SYS` je dobrý základ pro seznam systémů a jejich integrační chování, ale pro řízení jednotlivých polí doporučuji doplnit samostatný customizing.

## Proč nestačí pouze ZMDG_C_SYS

`ZMDG_C_SYS` umí říct, zda systém existuje, jakého je typu a zda podporuje založení nebo rozšíření. Neobsahuje ale úroveň pole.

Potřebujeme například vyjádřit:

- pro systém `ECC_CZ` je `taxnum` povinné,
- pro systém `CRM` je `duns` dostupné, ale nepovinné,
- pro založení vendora je `vendor` skryté a doplní se až po odeslání/zpracování externí službou,
- pro rozšíření je `partner_id` povinné,
- pro typ osoby se skryjí organizační názvy a zobrazí se jméno/příjmení.
- `Requesting country` je editovatelné jen pro role, které smějí měnit předvyplněnou zemi uživatele.

## Návrh Customizing Tabulky

Navržená tabulka: `ZMDG_C_FIELD`

```abap
@EndUserText.label : 'MDG field control podle systému'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #C
@AbapCatalog.dataMaintenance : #ALLOWED
define table zmdg_c_field {

  key mandt        : mandt not null;
  key extsys       : zmdg_extsys not null;
  key request_type : zmdg_req_type not null;
  key entity_name  : zmdg_entity_name not null;
  key field_name   : zmdg_field_name not null;
  bp_category      : bu_type;
  visible          : abap_boolean;
  editable         : abap_boolean;
  mandatory        : abap_boolean;
  default_value    : zmdg_default_value;
  sequence         : zmdg_sequence;

}
```

## Entity a Field Name

`entity_name` by mělo odpovídat logické části requestu, například:

- `REQ` pro `ZMDG_REQ`
- `ADR` pro `ZMDG_REQADR`
- `TAX` pro `ZMDG_REQTAX`

`field_name` by mělo odpovídat CDS property, ne nutně technickému názvu databázového pole. UI a RAP metadata pak budou pracovat se stejným názvoslovím.

## Použití v RAP

Dynamické řízení polí v RAP lze řešit přes feature control v behavior implementation.

Příklad zamýšleného toku:

```text
UI načte request
  -> RAP get_instance_features
     -> ZCL_MDG_BP_REQ_FIELDCONTROL
        -> načte ZMDG_C_SYS
        -> načte ZMDG_C_FIELD
        -> vrátí enabled/disabled/hidden pro akce a pole
```

Povinnost polí je potřeba řešit také v backend validaci, nejen v UI. UI field control zlepší ergonomii, ale validační třída musí být zdroj pravdy.

## Doporučené Třídy

- `ZCL_MDG_BP_REQ_FIELDCONTROL` - vyhodnocení viditelnosti, editovatelnosti a povinnosti.
- `ZCL_MDG_BP_REQ_VALIDATOR` - finální kontrola povinných polí a konzistence.
- `ZCL_MDG_BP_REQ_DEFAULTS` - předvyplnění země, created by a jazyka.
- `ZCL_MDG_BP_REQ_CUSTOMIZING` - načtení a cachování customizingu.

## Pravidla Priority

Doporučená priorita pravidel:

1. Konkrétní `extsys + request_type + bp_category + entity + field`.
2. Konkrétní `extsys + request_type + entity + field`.
3. Obecné `extsys + entity + field`.
4. Default v kódu nebo CDS metadatech.

Tím se dá začít jednoduše a později doplnit jemnější rozdíly bez přestavby celé aplikace.
