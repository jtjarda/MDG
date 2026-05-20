# Návrh RAP/Fiori - vyhledání Business Partnerů (MDG)

Níže je upravený návrh **basic/interface CDS** + **consumption CDS** pro generování OData služby pro Fiori Elements List Report.

Hlavní změna proti první variantě: ve VDM vrstvě nepoužíváme explicitní `join`, ale modelujeme vztahy přes **CDS asociace**. Databázový join si HANA/CDS runtime samozřejmě technicky vygeneruje při použití polí z asociace, ale v modelu zůstává jasná semantika: `ZMDG_BP` je root a adresa, systémová data i agregovaná daňová čísla jsou připojené objekty.

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
  association [0..1] to ZI_MDG_BP_ADDRESS       as _Address
    on  _Address.PartnerGID = BP.partner_gid
    and _Address.Nation     = 'I'
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

      _Address,
      _System,
      _TaxAgg
}
```

> `Nation = 'I'` ponechávám jako ukázku výběru jedné adresy pro list report. Pokud v datech existuje přesnější pravidlo pro hlavní adresu nebo mezinárodní verzi adresy, doporučuji ho dát sem, aby asociace zůstala kardinality `[0..1]`.

## 2) Search interface přes path expressions

Tato vrstva připraví plochý dataset pro Fiori Elements. Pořád není napsaná jako explicitní `join`; pole z adresy a tax agregace se čtou přes asociace.

```abap
@EndUserText.label: 'MDG BP Search Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
@Search.searchable: true
define view entity ZI_MDG_BP_SEARCH
  as select from ZI_MDG_BP as BP
{
  @Search.defaultSearchElement: true
  key BP.PartnerGID,

  cast(
    case
      when BP._Address.CompanyName is not initial then '2'
      else '1'
    end as abap.char(1)
  )                               as PartnerCategory,

  @Search.defaultSearchElement: true
  BP._Address.Country             as Country,

  @Search.defaultSearchElement: true
  BP._TaxAgg.TaxNumber            as TaxNumber,

  @Search.defaultSearchElement: true
  BP._Address.CompanyName         as CompanyName,

  @Search.defaultSearchElement: true
  BP._Address.FirstName           as FirstName,

  @Search.defaultSearchElement: true
  BP._Address.LastName            as LastName,

  @Search.defaultSearchElement: true
  BP._Address.City                as City,

  BP._Address.District            as District,

  @Search.defaultSearchElement: true
  BP._Address.Street              as Street,

  BP._Address.HouseNo             as HouseNo,
  BP._Address.HouseNoSuppl        as HouseNoSuppl,
  BP._Address.CityPostal          as CityPostal,
  BP.LeiCode,
  BP.Duns,

  BP._Address,
  BP._System,
  BP._TaxAgg
}
```

Pokud chceš kromě standardního `$search` ještě jedno samostatné pole `Fulltext`, dá se doplnit parametrická varianta. Pro Fiori Elements List Report ale preferuji `@Search.searchable` + `@Search.defaultSearchElement`, protože to lépe zapadá do standardního search field v aplikaci.

## 3) Consumption CDS pro Fiori Elements

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
  as projection on ZI_MDG_BP_SEARCH
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

## 4) Service definition + binding

```abap
@EndUserText.label: 'MDG BP Search Service Definition'
define service ZUI_MDG_BP_SEARCH {
  expose ZC_MDG_BP_SEARCH;
}
```

Pak vytvořit **Service Binding** typu **OData V4 - UI** nad `ZUI_MDG_BP_SEARCH`.

## 5) Filtrování a vyhledávání

- `PARTNER_GID` je klíč a zároveň selection field.
- `TAX_NUMBER` je agregované pole `TaxNumber`, které obsahuje všechny dostupné typy daňových čísel oddělené čárkou.
- `NAME` je pokryté přes `CompanyName`, `FirstName`, `LastName` v default search. Uživatel tak může zadat název firmy i celé jméno osoby.
- `COUNTRY`, `CITY`, `STREET` jsou přímá selection fields.
- Fulltext ve Fiori Elements standardně použije `$search` nad poli označenými `@Search.defaultSearchElement`.

## 6) Proč asociace

Asociace jsou lepší volba pro tento návrh, protože:

1. Root `ZI_MDG_BP` zůstává čistý a stabilní.
2. Spotřební view si bere jen ta pole, která opravdu potřebuje.
3. Kardinalita vztahů je vidět přímo v modelu (`[0..1]` adresa, `[0..*]` systémová data).
4. Pokud později přibude object page nebo navigace na detail daňových čísel/systémů, asociace se dají přirozeně vystavit.

## 7) Doporučení k výkonu

1. Přidat nebo ověřit indexy:
   - `zmdg_bpadr(partner_gid, nation)`
   - `zmdg_bptax(partner_gid, taxtype, taxnum)`
   - `zmdg_bpsys(partner_gid)`
2. U velkých objemů dat preferovat HANA fulltext indexy pro jmenná a adresní pole.
3. Agregované `TaxNumber` je praktické pro výsledkový list, ale pro velmi velká data může být výhodné doplnit samostatnou neagregovanou search help/query variantu nad `ZMDG_BPTAX`.
4. Pravidlo pro výběr adresy (`Nation = 'I'`) ber jako placeholder, který by měl odpovídat reálnému MDG pravidlu pro hlavní/display adresu.
