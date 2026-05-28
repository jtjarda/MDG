# CDS presun UI anotaci bez _AllAddresses filtru

Tento soubor popisuje, co lze presunout z lokalnich Fiori anotaci do ABAP CDS.
Filtry pres kolekci `_AllAddresses` zde zamerne nepresouvame. Ty zustavaji ve
Fiori projektu jako local annotation/custom filter.

## 1) Address interface

Adresni interface musi vystavit `PersonName`, protoze tabulka adres uz pole
`NAME_PERSON` ma a neni potreba ho ve frontendu skladat.

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
      Address.name_org1   as CompanyName1,
      Address.name_org2   as CompanyName2,
      Address.name_org3   as CompanyName3,
      Address.name_org4   as CompanyName4,
      Address.name_org    as CompanyName,
      Address.name_first  as FirstName,
      Address.name_last   as LastName,
      Address.name_person as PersonName,
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

## 2) Display address

Display adresa vraci jeden radek pro partnera. Pokud ma byt `NAME_PERSON`
viditelny v hlavni vysledkove tabulce bez custom sloupce, musi byt vystaven
primo pres display/search entitu.

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
      Address.PersonName,
      Address.City,
      Address.District,
      Address.Street,
      Address.HouseNo,
      Address.HouseNoSuppl,
      Address.CityPostal
}
where Address.Nation = ''
```

## 3) Search interface

Search interface vystavi sloupce, ktere chce Fiori List Report zobrazit. Toto
je ploche API pro hlavni tabulku. `_AllAddresses` zustava vystavena jen pro
lokalni lambda filtry ve Fiori aplikaci.

```abap
@EndUserText.label: 'MDG BP Search Interface'
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
define view entity ZI_MDG_BP_SEARCH
  as select from ZI_MDG_BP as BP
  association [0..1] to ZI_MDG_BP_DISPLAY_ADDRESS as _DisplayAddress
    on _DisplayAddress.PartnerGID = BP.PartnerGID
  association [0..1] to ZI_MDG_BP_TAX_AGG as _Tax
    on _Tax.PartnerGID = BP.PartnerGID
  association [0..*] to ZI_MDG_BP_ADDRESS as _AllAddresses
    on _AllAddresses.PartnerGID = BP.PartnerGID
{
  key BP.PartnerGID,
      _DisplayAddress.Country,
      _Tax.TaxNumber,
      _DisplayAddress.CompanyName,
      _DisplayAddress.PersonName as PersonName,
      _DisplayAddress.City,
      _DisplayAddress.District,
      _DisplayAddress.Street,
      _DisplayAddress.HouseNo,
      _DisplayAddress.HouseNoSuppl,
      _DisplayAddress.CityPostal,
      BP.LeiCode,
      BP.Duns,

      _AllAddresses
}
```

## 4) Consumption CDS UI anotace

Toto nahrazuje lokalni `UI.LineItem` pro hlavni tabulku. Selection fields zde
nechavame jen pro primy filtr `PartnerGID` a `TaxNumber`. Filtry pres
`_AllAddresses/Country`, `_AllAddresses/City`, `_AllAddresses/Street` a custom
`Address Name` zustavaji ve Fiori projektu.

Pokud aktivace hlasi `PersonName` jako nezname pole, zkontroluj hlavne
predchozi view `ZI_MDG_BP_SEARCH`: musi obsahovat alias
`_DisplayAddress.PersonName as PersonName`. Nestačí, ze pole existuje pouze v
`ZI_MDG_BP_ADDRESS` nebo za asociaci `_DisplayAddress`.

```abap
@EndUserText.label: 'MDG BP Search Consumption'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@UI: {
  headerInfo: {
    typeName: 'Business Partner',
    typeNamePlural: 'Business Partners',
    title: { type: #STANDARD, value: 'PartnerGID' }
  }
}
define view entity ZC_MDG_BP_SEARCH
  as select from ZI_MDG_BP_SEARCH
{
  @EndUserText.label: 'Partner GID'
  @UI.lineItem: [{ position: 10, label: 'Partner GID' }]
  @UI.selectionField: [{ position: 10 }]
  key PartnerGID,

  @EndUserText.label: 'Country'
  @UI.lineItem: [{ position: 20, label: 'Country' }]
  Country,

  @EndUserText.label: 'Tax Number'
  @UI.lineItem: [{ position: 30, label: 'Tax Number' }]
  @UI.selectionField: [{ position: 20 }]
  TaxNumber,

  @EndUserText.label: 'Name Org'
  @UI.lineItem: [{ position: 40, label: 'Name Org' }]
  CompanyName,

  @EndUserText.label: 'NAME_PERSON'
  @UI.lineItem: [{ position: 50, label: 'NAME_PERSON' }]
  PersonName,

  @EndUserText.label: 'City1'
  @UI.lineItem: [{ position: 60, label: 'City1' }]
  City,

  @EndUserText.label: 'Street'
  @UI.lineItem: [{ position: 70, label: 'Street' }]
  Street,

  @EndUserText.label: 'house_num1'
  @UI.lineItem: [{ position: 80, label: 'house_num1' }]
  HouseNo,

  @EndUserText.label: 'house_num2'
  @UI.lineItem: [{ position: 90, label: 'house_num2' }]
  HouseNoSuppl,

  @EndUserText.label: 'post_code1'
  @UI.lineItem: [{ position: 100, label: 'post_code1' }]
  CityPostal,

  @EndUserText.label: 'lei_code'
  @UI.lineItem: [{ position: 110, label: 'lei_code' }]
  LeiCode,

  @EndUserText.label: 'duns'
  @UI.lineItem: [{ position: 120, label: 'duns' }]
  Duns,

  _AllAddresses
}
```

## 5) Country value help

Country value help pro filtr `_AllAddresses/Country` muze zustat lokalne ve
Fiori anotaci. Pokud ale chces value help pro prime pole `Country` na hlavni
entite, lze ho presunout do CDS takto:

```abap
@EndUserText.label: 'MDG BP Country Value Help'
@ObjectModel.dataCategory: #VALUE_HELP
@Search.searchable: true
define view entity ZI_MDG_BP_COUNTRY_VH
  as select distinct from zmdg_bpadr as Address
{
  @Search.defaultSearchElement: true
  key Address.country as Country
}
where Address.country is not initial
```

```abap
@Consumption.valueHelpDefinition: [{
  entity: {
    name: 'ZI_MDG_BP_COUNTRY_VH',
    element: 'Country'
  }
}]
Country,
```

Service definition musi value help vystavit:

```abap
@EndUserText.label: 'MDG BP Search Service Definition'
define service ZUI_MDG_BP_SEARCH {
  expose ZC_MDG_BP_SEARCH       as BusinessPartnerSearch;
  expose ZI_MDG_BP_ADDRESS      as BusinessPartnerAddress;
  expose ZI_MDG_BP_COUNTRY_VH   as CountryValueHelp;
}
```

## 6) Co zustava ve Fiori projektu

V `webapp/annotations/annotation.xml` zatim nech:

```xml
<PropertyPath>_AllAddresses/Country</PropertyPath>
<PropertyPath>_AllAddresses/City</PropertyPath>
<PropertyPath>_AllAddresses/Street</PropertyPath>
```

Ve `manifest.json` zatim nech custom filtr `AddressNameSearch`, protoze sklada
OR hledani pres vice poli a pres `_AllAddresses`.

Po aktivaci CDS anotaci v backendu lze z lokalni `annotation.xml` odstranit
lokalni `UI.LineItem`, aby se sloupce braly z CDS.
