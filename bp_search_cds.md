# Návrh RAP/Fiori - vyhledání Business Partnerů (MDG)

Níže je upravený návrh **basic/interface CDS** + **consumption CDS** pro generování OData služby pro Fiori Elements List Report.

Hlavní změna proti první variantě: ve VDM vrstvě nepoužíváme explicitní `join`, ale modelujeme vztahy přes **CDS asociace**. Databázový join si HANA/CDS runtime samozřejmě technicky vygeneruje při použití polí z asociace, ale v modelu zůstává jasná semantika: `ZMDG_BP` je root a adresa, systémová data i agregovaná daňová čísla jsou připojené objekty.

Nově je návrh rozdělený na **předvýběr kandidátů** a **finální zobrazení**:

1. Nejdřív se hledá nad `ZMDG_BP` a všemi adresami `ZMDG_BPADR` bez omezení `NATION`.
2. Výsledkem předvýběru je unikátní seznam `PARTNER_GID`.
3. Teprve pro tyto partnery se dočte jeden reportovací/display řádek přes adresu `NATION = ''`.

> Poznámka: Agregace všech daňových čísel do jednoho textového pole je výpočetní logika. Tam je nejčistší použít CDS table function s AMDP a `STRING_AGG`.

## 1) Interface/BASIC CDS

### 1.1 Address interface

```abap
@EndUserText.label: 'MDG BP Address Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_BP_ADDRESS
  as select from zmdg_bpadr
{
  key partner_gid as PartnerGID,
  key nation      as Nation,
      name_org1   as CompanyName,
      name_org2   as CompanyName2,
      name_org3   as CompanyName3,
      name_org4   as CompanyName4,
      name_first  as FirstName,
      name_last   as LastName,
      bu_sort1    as SearchTerm1,
      street      as Street,
      house_num1  as HouseNo,
      house_num2  as HouseNoSuppl,
      city1       as City,
      city2       as District,
      post_code1  as CityPostal,
      country     as Country
}
```

### 1.2 System-dependent BP data interface

```abap
@EndUserText.label: 'MDG BP System Data Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_BP_SYSTEM
  as select from zmdg_bpsys
{
  key partner_gid as PartnerGID,
  key extsys      as ExternalSystem,
      partner_id  as PartnerId,
      type        as PartnerType,
      bu_group    as BusinessPartnerGroup,
      legal_form  as LegalForm,
      tel_number  as Telephone,
      mob_number  as MobilePhone,
      smtpadress  as EmailAddress,
      inactive    as IsInactive
}
```

### 1.3 Tax numbers aggregation

```abap
@EndUserText.label: 'MDG BP Tax Numbers Aggregated'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@VDM.viewType: #BASIC
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

Wrapper interface nad table function:

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

### 1.4 BP root interface s asociacemi

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
  association [0..*] to ZI_MDG_BP_ADDRESS       as _AllAddress
    on  _AllAddress.PartnerGID = BP.partner_gid
  association [0..1] to ZI_MDG_BP_ADDRESS       as _DisplayAddress
    on  _DisplayAddress.PartnerGID = BP.partner_gid
    and _DisplayAddress.Nation     = ''
  association [0..*] to ZI_MDG_BP_SYSTEM        as _System
    on  _System.PartnerGID = BP.partner_gid
  association [0..1] to ZI_MDG_BP_TAX_AGG       as _TaxAgg
    on  _TaxAgg.PartnerGID = BP.partner_gid
{
  key BP.partner_gid  as PartnerGID,
      BP.parent_gid1  as ParentGID1,
      BP.parent_gid2  as ParentGID2,
      BP.found_date   as FoundDate,
      BP.lei_code     as LeiCode,
      BP.duns         as Duns,

      _AllAddress,
      _DisplayAddress,
      _System,
      _TaxAgg
}
```

> `_AllAddress` slouží pro hledání přes všechny adresy a může mít více řádků. `_DisplayAddress` je naopak určena pro výstup v reportu a musí zůstat `[0..1]`, protože filtruje `Nation = ''`.

## 2) Předvýběr kandidátů

Tato vrstva provede vyhledání přes root data, všechna adresní data a agregovaná tax čísla. Vrací jen unikátní `PartnerGID`, takže vícenásobné adresy nerozmnoží řádky výsledného reportu.

```abap
@EndUserText.label: 'MDG BP Search Candidate'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
define view entity ZI_MDG_BP_SEARCH_HIT
  with parameters
    P_SEARCH : abap.char(100)
  as select distinct from ZI_MDG_BP as BP
{
  key BP.PartnerGID
}
where
      :P_SEARCH is initial
   or BP.PartnerGID                 like '%' || :P_SEARCH || '%'
   or BP.LeiCode                    like '%' || :P_SEARCH || '%'
   or BP.Duns                       like '%' || :P_SEARCH || '%'
   or BP._TaxAgg.TaxNumber          like '%' || :P_SEARCH || '%'
   or BP._AllAddress.CompanyName    like '%' || :P_SEARCH || '%'
   or BP._AllAddress.CompanyName2   like '%' || :P_SEARCH || '%'
   or BP._AllAddress.CompanyName3   like '%' || :P_SEARCH || '%'
   or BP._AllAddress.CompanyName4   like '%' || :P_SEARCH || '%'
   or BP._AllAddress.FirstName      like '%' || :P_SEARCH || '%'
   or BP._AllAddress.LastName       like '%' || :P_SEARCH || '%'
   or BP._AllAddress.SearchTerm1    like '%' || :P_SEARCH || '%'
   or BP._AllAddress.Country        like '%' || :P_SEARCH || '%'
   or BP._AllAddress.City           like '%' || :P_SEARCH || '%'
   or BP._AllAddress.District       like '%' || :P_SEARCH || '%'
   or BP._AllAddress.Street         like '%' || :P_SEARCH || '%'
```

> Důležité: protože se ve `where` používá asociace `_AllAddress` s kardinalitou `[0..*]`, databáze může interně najít více adresních hitů pro jednoho partnera. Projekce ale vrací jen klíč `PartnerGID`, takže výsledkem této vrstvy je unikátní seznam partnerů.

> Pokud konkrétní ABAP release nepovolí path expression přes `[0..*]` asociaci ve `where`, ponechal bych stejný koncept, ale předvýběr bych technicky realizoval pomocnou CDS view nad adresami nebo `exists` subquery. Semantika zůstává stejná: hledat ve všech adresách, vrátit jen `PartnerGID`.

## 3) Search interface pro report

Finální vrstva vezme jen partnery z předvýběru a pro výstup použije display adresu `Nation = ''`. Díky tomu report vrací jeden řádek za partnera.

```abap
@EndUserText.label: 'MDG BP Search Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
@Search.searchable: true
define view entity ZI_MDG_BP_SEARCH
  with parameters
    P_SEARCH : abap.char(100)
  as select distinct from ZI_MDG_BP_SEARCH_HIT( P_SEARCH: $parameters.P_SEARCH ) as Hit
  association [1..1] to ZI_MDG_BP as _BP
    on _BP.PartnerGID = Hit.PartnerGID
{
  @Search.defaultSearchElement: true
  key Hit.PartnerGID,

  cast(
    case
      when _BP._DisplayAddress.CompanyName is not initial then '2'
      else '1'
    end as abap.char(1)
  )                               as PartnerCategory,

  @Search.defaultSearchElement: true
  _BP._DisplayAddress.Country     as Country,

  @Search.defaultSearchElement: true
  _BP._TaxAgg.TaxNumber           as TaxNumber,

  @Search.defaultSearchElement: true
  _BP._DisplayAddress.CompanyName as CompanyName,

  @Search.defaultSearchElement: true
  _BP._DisplayAddress.FirstName   as FirstName,

  @Search.defaultSearchElement: true
  _BP._DisplayAddress.LastName    as LastName,

  @Search.defaultSearchElement: true
  _BP._DisplayAddress.City        as City,

  _BP._DisplayAddress.District    as District,

  @Search.defaultSearchElement: true
  _BP._DisplayAddress.Street      as Street,

  _BP._DisplayAddress.HouseNo     as HouseNo,
  _BP._DisplayAddress.HouseNoSuppl as HouseNoSuppl,
  _BP._DisplayAddress.CityPostal  as CityPostal,
  _BP.LeiCode,
  _BP.Duns,

  _BP
}
```

> Tady záměrně používáme `P_SEARCH`, protože potřebujeme řídit předvýběr nad všemi adresami, ale zobrazovat jen jednu adresu. Standardní `$search` ve Fiori Elements je dobré nechat jako doplněk pro hledání nad už zobrazeným plochým datasetem, ne jako jediný mechanismus pro tento scénář.

## 4) Consumption CDS pro Fiori Elements

```abap
@EndUserText.label: 'MDG BP Search Consumption'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
@UI: {
  headerInfo: {
    typeName: 'Business Partner',
    typeNamePlural: 'Business Partners',
    title: { type: #STANDARD, value: 'PartnerGID' }
  }
}
define root view entity ZC_MDG_BP_SEARCH
  provider contract transactional_query
  with parameters
    P_SEARCH : abap.char(100)
  as projection on ZI_MDG_BP_SEARCH( P_SEARCH: $parameters.P_SEARCH )
{
  @UI.lineItem: [{ position: 10 }]
  @UI.selectionField: [{ position: 10 }]
  @Search.defaultSearchElement: true
  key PartnerGID,

  @UI.lineItem: [{ position: 20 }]
  PartnerCategory,

  @UI.lineItem: [{ position: 30 }]
  @UI.selectionField: [{ position: 30 }]
  @Search.defaultSearchElement: true
  Country,

  @UI.lineItem: [{ position: 40 }]
  @UI.selectionField: [{ position: 20 }]
  @Search.defaultSearchElement: true
  TaxNumber,

  @UI.lineItem: [{ position: 50 }]
  @UI.selectionField: [{ position: 40 }]
  @Search.defaultSearchElement: true
  CompanyName,

  @UI.lineItem: [{ position: 60 }]
  @Search.defaultSearchElement: true
  FirstName,

  @UI.lineItem: [{ position: 70 }]
  @Search.defaultSearchElement: true
  LastName,

  @UI.lineItem: [{ position: 80 }]
  @UI.selectionField: [{ position: 50 }]
  @Search.defaultSearchElement: true
  City,

  @UI.lineItem: [{ position: 90 }]
  District,

  @UI.lineItem: [{ position: 100 }]
  @UI.selectionField: [{ position: 60 }]
  @Search.defaultSearchElement: true
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
  Duns
}
```

> Parametr `P_SEARCH` doporučuji v UI namapovat jako hlavní vyhledávací/selection pole. Pole `Country`, `TaxNumber`, `CompanyName`, `City`, `Street` mohou zůstat jako doplňkové filtry nad výsledným listem.

## 5) Service definition + binding

```abap
@EndUserText.label: 'MDG BP Search Service Definition'
define service ZUI_MDG_BP_SEARCH {
  expose ZC_MDG_BP_SEARCH;
}
```

Pak vytvořit **Service Binding** typu **OData V4 - UI** nad `ZUI_MDG_BP_SEARCH`.

## 6) Filtrování a vyhledávání

- `P_SEARCH` provede předvýběr přes `ZMDG_BP`, všechna jména/adresy v `ZMDG_BPADR` bez omezení `NATION`, `TaxNumber`, `LeiCode` a `Duns`.
- Finální report vždy zobrazuje hodnoty z `_DisplayAddress`, tedy z adresy `NATION = ''`.
- `PARTNER_GID` je klíč a zároveň selection field.
- `TAX_NUMBER` je agregované pole `TaxNumber`, které obsahuje všechny dostupné typy daňových čísel oddělené čárkou.
- `NAME` je při předvýběru pokryté přes `CompanyName`, `CompanyName2-4`, `FirstName`, `LastName` a `SearchTerm1` ze všech adresních variant.
- `COUNTRY`, `CITY`, `STREET` jsou přímá selection fields.
- Standardní `$search` může zůstat aktivní, ale pro tento scénář je hlavní mechanismus parametr `P_SEARCH`, protože řeší hledání přes všechny adresy a výstup přes jednu display adresu.

## 7) Proč asociace

Asociace jsou lepší volba pro tento návrh, protože:

1. Root `ZI_MDG_BP` zůstává čistý a stabilní.
2. Search část může používat `_AllAddress` a report část `_DisplayAddress`.
3. Kardinalita vztahů je vidět přímo v modelu (`[0..*]` všechny adresy, `[0..1]` display adresa, `[0..*]` systémová data).
4. Pokud později přibude object page nebo navigace na detail daňových čísel/systémů, asociace se dají přirozeně vystavit.

## 8) Doporučení k výkonu

1. Přidat nebo ověřit indexy:
   - `zmdg_bpadr(partner_gid, nation)`
   - `zmdg_bptax(partner_gid, taxtype, taxnum)`
   - `zmdg_bpsys(partner_gid)`
2. U velkých objemů dat preferovat HANA fulltext indexy pro jmenná a adresní pole.
3. Agregované `TaxNumber` je praktické pro výsledkový list, ale pro velmi velká data může být výhodné doplnit samostatnou neagregovanou search help/query variantu nad `ZMDG_BPTAX`.
4. Pravidlo pro výběr display adresy (`Nation = ''`) musí odpovídat skutečnému obsahu `ZMDG_BPADR`; pokud existuje více takových řádků pro jednoho partnera, je potřeba přidat další rozhodovací pravidlo.
