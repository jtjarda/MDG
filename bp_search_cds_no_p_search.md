# Navrh RAP/Fiori - BP search bez parametru P_SEARCH

Tento soubor popisuje druhou variantu navrhu. Puvodni soubor `bp_search_cds.md`
zustava zachovany. Hlavni rozdil je, ze tato varianta nepouziva CDS parametr
`P_SEARCH`. Globalni vyhledavani ve Fiori Elements List Reportu se resi
standardne pres OData `$search` a CDS anotace `@Search.*`.

Cil zustava stejny:

- hledat partnera pres vsechny adresy v `ZMDG_BPADR`,
- hledat pres vsechna danova cisla v `ZMDG_BPTAX`,
- ve vysledku zobrazit pouze jeden unikatni radek pro jeden `PARTNER_GID`,
- pro zobrazeni pouzit jednu display adresu, typicky `NATION = ''`,
- nevystavovat technicke search pole uzivateli.

## Princip reseni

Kdyz se finalni consumption view napoji primo na `ZMDG_BPADR` jako `1:n`, vznikne
vice radku pro jednoho partnera. Proto finalni search entity nesmi byt zalozena
na prostem joinu `BP -> ADDRESS`.

Misto toho se pouziji dve agregovane pomocne vrstvy:

1. `ZI_MDG_BP_SEARCH_TEXT`
   - jeden radek pro `PARTNER_GID`,
   - obsahuje slouceny text ze vsech adres a vsech danovych cisel,
   - slouzi jen pro `$search`.

2. `ZI_MDG_BP_DISPLAY_ADDRESS`
   - jeden radek pro `PARTNER_GID`,
   - obsahuje adresu pro vystup v tabulce,
   - typicky adresa s `NATION = ''`.

Finalni `ZC_MDG_BP_SEARCH` je tedy porad unikatni podle `PARTNER_GID`, ale skryte
pole `SearchText` obsahuje texty ze vsech adres. Fiori Elements pak posle
standardni `$search` a RAP/CDS runtime hleda v tomto poli.

## 1) Interface/BASIC CDS

### 1.1 BP root

```abap
@EndUserText.label: 'MDG BP Root Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory: #L,
  dataClass: #MASTER
}
define root view entity ZI_MDG_BP
  as select from zmdg_bp as BP
{
  key BP.partner_gid  as PartnerGID,
      BP.parent_gid1  as ParentGID1,
      BP.parent_gid2  as ParentGID2,
      BP.found_date   as FoundDate,
      BP.lei_code     as LeiCode,
      BP.duns         as Duns
}
```

### 1.2 Address interface

```abap
@EndUserText.label: 'MDG BP Address Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_BP_ADDRESS
  as select from zmdg_bpadr as Address
{
  key Address.partner_gid as PartnerGID,
  key Address.nation      as Nation,
      Address.name_org1   as CompanyName,
      Address.name_org2   as CompanyName2,
      Address.name_org3   as CompanyName3,
      Address.name_org4   as CompanyName4,
      Address.name_first  as FirstName,
      Address.name_last   as LastName,
      Address.bu_sort1    as SearchTerm1,
      Address.street      as Street,
      Address.house_num1  as HouseNo,
      Address.house_num2  as HouseNoSuppl,
      Address.city1       as City,
      Address.city2       as District,
      Address.post_code1  as CityPostal,
      Address.country     as Country
}
```

### 1.3 System data interface

```abap
@EndUserText.label: 'MDG BP System Data Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_BP_SYSTEM
  as select from zmdg_bpsys as SystemData
{
  key SystemData.partner_gid as PartnerGID,
  key SystemData.extsys      as ExternalSystem,
      SystemData.partner_id  as PartnerId,
      SystemData.type        as PartnerCategory,
      SystemData.bu_group    as BusinessPartnerGroup,
      SystemData.legal_form  as LegalForm,
      SystemData.tel_number  as Telephone,
      SystemData.mob_number  as MobilePhone,
      SystemData.smtpadress  as EmailAddress,
      SystemData.inactive    as IsInactive
}
```

## 2) Agregace danovych cisel

Pole `TaxNumber` ma zobrazit vsechna danova cisla partnera v jednom stringu
oddelenem carkou. Zaroven se ma pres toto pole hledat.

```abap
@EndUserText.label: 'MDG BP Tax Numbers Aggregated'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZTF_MDG_BP_TAX_AGG
  returns {
    mandt       : mandt;
    partner_gid : zmdg_partner_gid;
    tax_number  : abap.string;
  }
  implemented by method zcl_mdg_bp_tax_agg=>get_data;
```

AMDP skeleton:

```abap
CLASS zcl_mdg_bp_tax_agg DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    CLASS-METHODS get_data
      FOR TABLE FUNCTION ztf_mdg_bp_tax_agg.
ENDCLASS.

CLASS zcl_mdg_bp_tax_agg IMPLEMENTATION.
  METHOD get_data BY DATABASE FUNCTION
                  FOR HDB
                  LANGUAGE SQLSCRIPT
                  OPTIONS READ-ONLY
                  USING zmdg_bptax.

    RETURN
      SELECT mandt,
             partner_gid,
             STRING_AGG( taxnum, ', ' ORDER BY taxtype ) AS tax_number
        FROM zmdg_bptax
       WHERE taxnum IS NOT NULL
         AND taxnum <> ''
       GROUP BY mandt, partner_gid;

  ENDMETHOD.
ENDCLASS.
```

Wrapper CDS:

```abap
@EndUserText.label: 'MDG BP Tax Numbers Aggregated Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_BP_TAX_AGG
  as select from ZTF_MDG_BP_TAX_AGG( )
{
  key partner_gid as PartnerGID,
      tax_number  as TaxNumber
}
```

## 3) Display adresa

Tato view vraci jednu adresu pro zobrazeni ve vysledkove tabulce. Zakladni
varianta bere adresu s `NATION = ''`.

```abap
@EndUserText.label: 'MDG BP Display Address'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_BP_DISPLAY_ADDRESS
  as select from ZI_MDG_BP_ADDRESS as Address
{
  key Address.PartnerGID,
      Address.Country,
      Address.CompanyName,
      Address.CompanyName2,
      Address.CompanyName3,
      Address.CompanyName4,
      Address.FirstName,
      Address.LastName,
      Address.City,
      Address.District,
      Address.Street,
      Address.HouseNo,
      Address.HouseNoSuppl,
      Address.CityPostal
}
where Address.Nation = ''
```

Pokud v datech nemusi existovat `NATION = ''`, doporucuji doplnit fallback pres
AMDP/table function nebo CDS view s rankingem:

1. nejdriv `NATION = ''`,
2. jinak prvni dostupna adresa podle stabilniho razeni.

Tim se porad zachova pravidlo jeden vystupni radek pro `PARTNER_GID`.

## 4) Search text pres vsechny adresy

Toto je klicova cast varianty bez `P_SEARCH`. Misto parametrickeho `where`
se vytvori jedno skryte textove pole, ktere obsahuje vsechny hodnoty, pres ktere
ma globalni search hledat.

```abap
@EndUserText.label: 'MDG BP Search Text'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZTF_MDG_BP_SEARCH_TEXT
  returns {
    mandt       : mandt;
    partner_gid : zmdg_partner_gid;
    search_text : abap.string;
  }
  implemented by method zcl_mdg_bp_search_text=>get_data;
```

AMDP skeleton:

```abap
CLASS zcl_mdg_bp_search_text DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    CLASS-METHODS get_data
      FOR TABLE FUNCTION ztf_mdg_bp_search_text.
ENDCLASS.

CLASS zcl_mdg_bp_search_text IMPLEMENTATION.
  METHOD get_data BY DATABASE FUNCTION
                  FOR HDB
                  LANGUAGE SQLSCRIPT
                  OPTIONS READ-ONLY
                  USING zmdg_bp zmdg_bpadr zmdg_bptax.

    RETURN
      SELECT BP.mandt,
             BP.partner_gid,
             STRING_AGG(
               COALESCE( BP.partner_gid, '' ) || ' ' ||
               COALESCE( BP.lei_code, '' )    || ' ' ||
               COALESCE( BP.duns, '' )        || ' ' ||
               COALESCE( Adr.name_org1, '' )  || ' ' ||
               COALESCE( Adr.name_org2, '' )  || ' ' ||
               COALESCE( Adr.name_org3, '' )  || ' ' ||
               COALESCE( Adr.name_org4, '' )  || ' ' ||
               COALESCE( Adr.name_first, '' ) || ' ' ||
               COALESCE( Adr.name_last, '' )  || ' ' ||
               COALESCE( Adr.bu_sort1, '' )   || ' ' ||
               COALESCE( Adr.country, '' )    || ' ' ||
               COALESCE( Adr.city1, '' )      || ' ' ||
               COALESCE( Adr.city2, '' )      || ' ' ||
               COALESCE( Adr.street, '' )     || ' ' ||
               COALESCE( Tax.taxnum, '' ),
               ' '
             ) AS search_text
        FROM zmdg_bp AS BP
        LEFT OUTER JOIN zmdg_bpadr AS Adr
          ON  Adr.mandt       = BP.mandt
          AND Adr.partner_gid = BP.partner_gid
        LEFT OUTER JOIN zmdg_bptax AS Tax
          ON  Tax.mandt       = BP.mandt
          AND Tax.partner_gid = BP.partner_gid
       GROUP BY BP.mandt, BP.partner_gid;

  ENDMETHOD.
ENDCLASS.
```

Wrapper CDS:

```abap
@EndUserText.label: 'MDG BP Search Text Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_BP_SEARCH_TEXT
  as select from ZTF_MDG_BP_SEARCH_TEXT( )
{
  key partner_gid as PartnerGID,
      search_text as SearchText
}
```

Poznamka k vykonu: Pokud bude dat hodne, je vhodne zvazit materializovanou
pomocnou tabulku pro search text, plnenou pri zmene BP/adres/tax dat. Z pohledu
RAP/Fiori modelu zustane API stejne, jen se misto table function cte z tabulky.

## 5) Composite search projection

Composite view spoji root data, display adresu, agregovana danova cisla a search
text. Porad vraci jeden radek pro jednoho partnera.

```abap
@EndUserText.label: 'MDG BP Search Composite'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
define view entity ZI_MDG_BP_SEARCH
  as select from ZI_MDG_BP as BP
    left outer join ZI_MDG_BP_DISPLAY_ADDRESS as DisplayAddress
      on DisplayAddress.PartnerGID = BP.PartnerGID
    left outer join ZI_MDG_BP_TAX_AGG as TaxAgg
      on TaxAgg.PartnerGID = BP.PartnerGID
    left outer join ZI_MDG_BP_SEARCH_TEXT as SearchText
      on SearchText.PartnerGID = BP.PartnerGID
    left outer join ZI_MDG_BP_SYSTEM as SystemData
      on SystemData.PartnerGID = BP.PartnerGID
{
  key BP.PartnerGID,

      SystemData.PartnerCategory,
      DisplayAddress.Country,
      TaxAgg.TaxNumber,
      DisplayAddress.CompanyName,
      DisplayAddress.FirstName,
      DisplayAddress.LastName,
      DisplayAddress.City,
      DisplayAddress.District,
      DisplayAddress.Street,
      DisplayAddress.HouseNo,
      DisplayAddress.HouseNoSuppl,
      DisplayAddress.CityPostal,
      BP.LeiCode,
      BP.Duns,

      SearchText.SearchText
}
```

Pozor: Pokud `ZMDG_BPSYS` muze mit vice zaznamu pro jednoho partnera, je nutne
urcit, ktery systemovy zaznam se ma zobrazit. Jinak by `ZI_MDG_BP_SEARCH`
zase rozmnozila radky. Nejbezpecnejsi je pridat filtr na konkretni `EXTSYS`,
nebo vytvorit analogickou `ZI_MDG_BP_DISPLAY_SYSTEM` view s jednim zaznamem pro
partnera.

## 6) Consumption CDS pro Fiori Elements

```abap
@EndUserText.label: 'Business Partner Search'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory: #L,
  dataClass: #MASTER
}
define root view entity ZC_MDG_BP_SEARCH
  as projection on ZI_MDG_BP_SEARCH
{
  @UI.lineItem: [{ position: 10 }]
  @UI.selectionField: [{ position: 10 }]
  key PartnerGID,

  @UI.lineItem: [{ position: 20 }]
  PartnerCategory,

  @UI.lineItem: [{ position: 30 }]
  @UI.selectionField: [{ position: 50 }]
  Country,

  @UI.lineItem: [{ position: 40 }]
  @UI.selectionField: [{ position: 30 }]
  TaxNumber,

  @UI.lineItem: [{ position: 50 }]
  @UI.selectionField: [{ position: 20 }]
  CompanyName,

  @UI.lineItem: [{ position: 60 }]
  FirstName,

  @UI.lineItem: [{ position: 70 }]
  LastName,

  @UI.lineItem: [{ position: 80 }]
  @UI.selectionField: [{ position: 60 }]
  City,

  @UI.lineItem: [{ position: 90 }]
  District,

  @UI.lineItem: [{ position: 100 }]
  @UI.selectionField: [{ position: 70 }]
  Street,

  @UI.lineItem: [{ position: 110 }]
  HouseNo,

  @UI.lineItem: [{ position: 120 }]
  HouseNoSuppl,

  @UI.lineItem: [{ position: 130 }]
  CityPostal,

  @UI.lineItem: [{ position: 140 }]
  LeiCode,

  @UI.lineItem: [{ position: 150 }]
  Duns,

  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.hidden: true
  SearchText
}
```

Vysledek:

- globalni search nahore ve Fiori List Reportu hleda pres `SearchText`,
- `SearchText` obsahuje vsechny adresy i vsechna danova cisla,
- tabulka porad zobrazuje jeden radek pro `PARTNER_GID`,
- samostatne filtry ve Filter Baru zustavaji jako normalni filtry nad poli
  `PartnerGID`, `TaxNumber`, `CompanyName`, `Country`, `City`, `Street`.

## 7) Service definition

```abap
@EndUserText.label: 'MDG BP Search Service'
define service ZUI_MDG_BP_SEARCH {
  expose ZC_MDG_BP_SEARCH as BusinessPartnerSearch;
}
```

## 8) Doporuceni k realne implementaci

1. Pokud ma byt search pres vsechny adresy opravdu rychly, zvazil bych
   persistentni search index tabulku misto vypoctu `SearchText` za behu.
2. Pokud `ZMDG_BPSYS` obsahuje vice externich systemu pro partnera, je potreba
   vybrat jeden display zaznam, jinak se porusi uniktnost vysledku.
3. Pokud `NATION = ''` neni vzdy dostupne, doplnil bych display-address fallback
   pres ranking.
4. `@Search.defaultSearchElement` bych nechal pouze na skrytem `SearchText`.
   Kdyby se oznacila jednotliva display pole, hledalo by se jen v display adrese,
   ne ve vsech adresach.
