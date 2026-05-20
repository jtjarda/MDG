# Návrh RAP/Fiori – vyhledání Business Partnerů (MDG)

Níže je návrh **basic/interface CDS** + **consumption CDS** pro generování OData služby pro Fiori Elements (List Report).

> Poznámka: Používám moderní VDM styl (`ZI_*`, `ZC_*`), read-only scénář a fulltext přes `contains` + parametr `P_SEARCH`.

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
  as select from zmdg_bp as bp
    left outer join zmdg_bpadr as adr
      on  adr.partner_gid = bp.partner_gid
      and adr.nation      = 'I'
{
  key bp.partner_gid                                       as PartnerGID,
      bp.lei_code                                          as LeiCode,
      bp.duns                                              as Duns,
      adr.country                                          as Country,
      adr.city1                                            as City,
      adr.city2                                            as District,
      adr.street                                           as Street,
      adr.house_num1                                       as HouseNo,
      adr.house_num2                                       as HouseNoSuppl,
      adr.post_code1                                       as CityPostal,

      adr.name_org1                                        as CompanyName,
      adr.name_first                                       as FirstName,
      adr.name_last                                        as LastName,

      cast(
        case
          when adr.name_org1 is not initial then '2'
          else '1'
        end as abap.char(1)
      )                                                    as PartnerCategory
}
```

### 1.2 Tax numbers aggregation (all taxtypes do jednoho pole)

> Na S/4HANA je nejčistší použít CDS table function a agregaci v AMDP (`STRING_AGG`).

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
             STRING_AGG( taxnum, ',' ORDER BY taxtype ) AS tax_number
        FROM zmdg_bptax
       WHERE taxnum IS NOT NULL
       GROUP BY mandt, partner_gid;

  ENDMETHOD.
ENDCLASS.
```

### 1.3 Composite search interface (join root + sys + tax agg)

```abap
@EndUserText.label: 'MDG BP Search Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
define view entity ZI_MDG_BP_SEARCH
  with parameters
    P_SEARCH : abap.char(100)
  as select from ZI_MDG_BP as bp
    left outer join zmdg_bpsys as sys
      on sys.partner_gid = bp.PartnerGID
    left outer join ZTF_MDG_BP_TAX_AGG( ) as tax
      on tax.partner_gid = bp.PartnerGID
{
  key bp.PartnerGID,
      bp.PartnerCategory,
      bp.Country,
      tax.tax_number                                         as TaxNumber,
      bp.CompanyName,
      bp.FirstName,
      bp.LastName,
      bp.City,
      bp.District,
      bp.Street,
      bp.HouseNo,
      bp.HouseNoSuppl,
      bp.CityPostal,
      bp.LeiCode,
      bp.Duns,
      sys.partner_id                                         as PartnerId,
      sys.type                                               as PartnerType
}
where
      :P_SEARCH is initial
   or bp.PartnerGID   like '%' || :P_SEARCH || '%'
   or bp.CompanyName  like '%' || :P_SEARCH || '%'
   or bp.FirstName    like '%' || :P_SEARCH || '%'
   or bp.LastName     like '%' || :P_SEARCH || '%'
   or bp.Country      like '%' || :P_SEARCH || '%'
   or bp.City         like '%' || :P_SEARCH || '%'
   or bp.Street       like '%' || :P_SEARCH || '%'
   or tax.tax_number  like '%' || :P_SEARCH || '%'
```

---

## 2) Consumption CDS pro Fiori Elements

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
  City,

  @UI.lineItem: [{ position: 90 }]
  District,

  @UI.lineItem: [{ position: 100 }]
  @UI.selectionField: [{ position: 60 }]
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

---

## 3) Service definition + binding

```abap
@EndUserText.label: 'MDG BP Search Service Definition'
define service ZUI_MDG_BP_SEARCH {
  expose ZC_MDG_BP_SEARCH;
}
```

Pak vytvořit **Service Binding** typu **OData V4 - UI** nad `ZUI_MDG_BP_SEARCH`.

---

## 4) Jak splnit požadavky na filtrování

- `PARTNER_GID` – přes `@UI.selectionField` + `@Search.defaultSearchElement`.
- `TAX_NUMBER` – agregované pole `TaxNumber` (všechna DIČ/IČ/ostatní taxtype oddělené čárkou).
- `NAME` – jednotné chování přes `CompanyName`, `FirstName`, `LastName` v default search.
- `COUNTRY`, `CITY`, `STREET` – přímá selection fields.
- Fulltext – buď parametr `P_SEARCH` (v interface view), nebo Fiori `$search` (díky `@Search.searchable`).

---

## 5) Doporučení k výkonu (best practice)

1. Přidat indexy:
   - `zmdg_bpadr(partner_gid, nation)`
   - `zmdg_bptax(partner_gid, taxtype, taxnum)`
   - `zmdg_bpsys(partner_gid)`
2. Pokud je objem dat velký, preferovat `contains( ... )` nad `%like%` (HANA fulltext index).
3. U adres zvážit pravidlo pro výběr „primární“ adresy místo natvrdo `nation = 'I'`.
4. U `TaxNumber` zvážit limit délky (UI) + tooltip/full object page detail.

