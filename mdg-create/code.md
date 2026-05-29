# MDG Create - Working Code

Vychozi datovy model pro novou RAP aplikaci pozadavku na zalozeni BP.

Model pouziva technicky klic `request_uuid` pro draft/kompozice. Pole `request_id` zustava semanticke cislo pozadavku a bude se plnit az pri ulozeni.

## Tables

### ZMDG_REQ

```abap
@EndUserText.label : 'MDG PoĹľadavek'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zmdg_req {

  key mandt            : mandt not null;
  key request_uuid     : sysuuid_x16 not null;
  request_id           : zmdg_request_id;
  request_type         : zmdg_req_type;
  extsys               : zmdg_extsys;
  partner_gid          : zmdg_partner_gid;
  status               : zmsg_req_status;
  parent_gid1          : bu_partner;
  parent_gid2          : bu_partner;
  found_date           : bu_found_dat;
  duns                 : /sapht/rn_duns;
  lei_code             : zmdg_lei;
  euid                 : zmdg_euid;
  partner_id           : bu_partner;
  type                 : zmdg_bu_type;
  bu_group             : zmdg_bu_group;
  legal_form           : zmdg_bu_legenty;
  tel_number           : ad_tlnmbr1;
  mob_number           : ad_mbnmbr1;
  smtpadress           : ad_smtpadr;
  inactive             : zmdg_inative;
  inactive_reason      : zmdg_inact_reason;
  vendor               : zmdg_vendor;
  customer             : zmdg_customer;
  name_org1            : bu_nameor1;
  name_org2            : bu_nameor2;
  name_org3            : bu_nameor3;
  name_org4            : bu_nameor4;
  name_first           : bu_namep_f;
  name_last            : bu_namep_l;
  bu_sort1             : bu_sort1;
  street               : ad_street;
  house_num1           : ad_hsnm1;
  house_num2           : ad_hsnm2;
  city1                : ad_city1;
  city2                : ad_city2;
  post_code1           : ad_pstcd1;
  country              : land1;
  name_org             : zmdg_nameorg;
  name_person          : zmdg_person;
  created_by           : abp_creation_user;
  created_at           : abp_creation_tstmpl;
  last_changed_by      : abp_lastchange_user;
  last_changed_at      : abp_lastchange_tstmpl;
  locl_last_changed_at : abp_locinst_lastchange_tstmpl;

}
```

### ZMDG_REQADR

```abap
@EndUserText.label : 'MDG PoĹľadavek - Adresy'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zmdg_reqadr {

  key mandt        : mandt not null;
  key request_uuid : sysuuid_x16 not null;
  key nation       : ad_nation not null;
  name_org1        : bu_nameor1;
  name_org2        : bu_nameor2;
  name_org3        : bu_nameor3;
  name_org4        : bu_nameor4;
  name_first       : bu_namep_f;
  name_last        : bu_namep_l;
  bu_sort1         : bu_sort1;
  street           : ad_street;
  house_num1       : ad_hsnm1;
  house_num2       : ad_hsnm2;
  city1            : ad_city1;
  city2            : ad_city2;
  post_code1       : ad_pstcd1;
  country          : land1;
  name_org         : zmdg_nameorg;
  name_person      : zmdg_person;

}
```

### ZMDG_REQTAX

```abap
@EndUserText.label : 'MDG poĹľadavek - daĹovĂˇ ÄŤĂ­sla'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zmdg_reqtax {

  key mandt        : mandt not null;
  key request_uuid : sysuuid_x16 not null;
  key taxtype      : bptaxtype not null;
  taxnum           : bptaxnum;

}
```

## CDS Sources


### ZI_MDG_C_SYS.ddls

```abap
@EndUserText.label: 'MDG Connected System'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_C_SYS
  as select from zmdg_c_sys
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key extsys      as ExternalSystem,
      type        as SystemType,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      description as Description,
      comm_class  as CommunicationClass,
      def_alpha   as DefaultAlphabet,
      xcrea       as IsCreateAllowed,
      xenh        as IsEnhanceAllowed
}

```


## Behavior Definitions

### ZI_MDG_REQ.bdef

```abap
managed implementation in class ZBP_I_MDG_REQ unique;
strict ( 2 );
with draft;

define behavior for ZI_MDG_REQ alias Request
persistent table zmdg_req
draft table zmdg_req_d
lock master
authorization master ( global, instance )
etag master LocalLastChangedAt
total etag LastChangedAt
{
  create;
  update;
  delete;

  field ( readonly, numbering : managed ) RequestUuid;
  field ( readonly ) RequestId;
  field ( readonly ) PartnerId, Vendor, Customer;
  field ( readonly ) CreatedBy, CreatedAt, LastChangedBy, LastChangedAt, LocalLastChangedAt;

  draft action Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare;

  association _Address { create; with draft; }
  association _Tax     { create; with draft; }

  mapping for zmdg_req
  {
    RequestUuid           = request_uuid;
    RequestId             = request_id;
    RequestType           = request_type;
    ExternalSystem        = extsys;
    PartnerGid            = partner_gid;
    Status                = status;
    ParentGid1            = parent_gid1;
    ParentGid2            = parent_gid2;
    FoundDate             = found_date;
    Duns                  = duns;
    LeiCode               = lei_code;
    Euid                  = euid;
    PartnerId             = partner_id;
    BusinessPartnerType   = type;
    BusinessPartnerGroup  = bu_group;
    LegalForm             = legal_form;
    TelephoneNumber       = tel_number;
    MobileNumber          = mob_number;
    EmailAddress          = smtpadress;
    IsInactive            = inactive;
    InactiveReason        = inactive_reason;
    Vendor                = vendor;
    Customer              = customer;
    OrganizationName1     = name_org1;
    OrganizationName2     = name_org2;
    OrganizationName3     = name_org3;
    OrganizationName4     = name_org4;
    FirstName             = name_first;
    LastName              = name_last;
    SearchTerm1           = bu_sort1;
    Street                = street;
    HouseNumber           = house_num1;
    HouseNumberSupplement = house_num2;
    City                  = city1;
    District              = city2;
    PostalCode            = post_code1;
    Country               = country;
    OrganizationName      = name_org;
    PersonName            = name_person;
    CreatedBy             = created_by;
    CreatedAt             = created_at;
    LastChangedBy         = last_changed_by;
    LastChangedAt         = last_changed_at;
    LocalLastChangedAt    = locl_last_changed_at;
  }
}

define behavior for ZI_MDG_REQADR alias Address
persistent table zmdg_reqadr
draft table zmdg_reqadr_d
lock dependent by _Request
authorization dependent by _Request
etag dependent by _Request
{
  update;
  delete;

  field ( readonly ) RequestUuid;
  field ( readonly : update ) Nation;

  association _Request { with draft; }

  mapping for zmdg_reqadr
  {
    RequestUuid           = request_uuid;
    Nation                = nation;
    OrganizationName1     = name_org1;
    OrganizationName2     = name_org2;
    OrganizationName3     = name_org3;
    OrganizationName4     = name_org4;
    FirstName             = name_first;
    LastName              = name_last;
    SearchTerm1           = bu_sort1;
    Street                = street;
    HouseNumber           = house_num1;
    HouseNumberSupplement = house_num2;
    City                  = city1;
    District              = city2;
    PostalCode            = post_code1;
    Country               = country;
    OrganizationName      = name_org;
    PersonName            = name_person;
  }
}

define behavior for ZI_MDG_REQTAX alias Tax
persistent table zmdg_reqtax
draft table zmdg_reqtax_d
lock dependent by _Request
authorization dependent by _Request
etag dependent by _Request
{
  update;
  delete;

  field ( readonly ) RequestUuid;
  field ( readonly : update ) TaxType;

  association _Request { with draft; }

  mapping for zmdg_reqtax
  {
    RequestUuid = request_uuid;
    TaxType     = taxtype;
    TaxNumber   = taxnum;
  }
}
```


### ZC_MDG_REQ.bdef

```abap
projection;
strict ( 2 );
use draft;

define behavior for ZC_MDG_REQ alias Request
{
  use create;
  use update;
  use delete;

  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;

  use association _Address { create; with draft; }
  use association _Tax     { create; with draft; }
}

define behavior for ZC_MDG_REQADR alias Address
{
  use update;
  use delete;

  use association _Request { with draft; }
}

define behavior for ZC_MDG_REQTAX alias Tax
{
  use update;
  use delete;

  use association _Request { with draft; }
}
```


## Behavior Implementation

### ZBP_I_MDG_REQ locals

```abap
CLASS lhc_request DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR request
      RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING
                keys REQUEST requested_authorizations FOR request
      RESULT    result.
ENDCLASS.

CLASS lhc_request IMPLEMENTATION.
  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    result = VALUE #(
      FOR key IN keys
      ( %tky    = key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed )
    ).
  ENDMETHOD.
ENDCLASS.
```


### ZI_MDG_C_SYS_CREATEVH.ddls

```abap
@EndUserText.label: 'MDG Create System Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_C_SYS_CREATEVH
  as select from ZI_MDG_C_SYS
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key ExternalSystem,
      Description,
      SystemType,
      DefaultAlphabet
}
where IsCreateAllowed = 'X'

```


### ZI_MDG_REQADR.ddls

```abap
@EndUserText.label: 'MDG BP Request Address Variant'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_REQADR
  as select from zmdg_reqadr
  association to parent ZI_MDG_REQ as _Request
    on $projection.RequestUuid = _Request.RequestUuid
{
  key request_uuid as RequestUuid,
  key nation       as Nation,
      name_org1    as OrganizationName1,
      name_org2    as OrganizationName2,
      name_org3    as OrganizationName3,
      name_org4    as OrganizationName4,
      name_first   as FirstName,
      name_last    as LastName,
      bu_sort1     as SearchTerm1,
      street       as Street,
      house_num1   as HouseNumber,
      house_num2   as HouseNumberSupplement,
      city1        as City,
      city2        as District,
      post_code1   as PostalCode,
      country      as Country,
      name_org     as OrganizationName,
      name_person  as PersonName,

      _Request
}

```


### ZI_MDG_REQTAX.ddls

```abap
@EndUserText.label: 'MDG BP Request Tax Number'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_REQTAX
  as select from zmdg_reqtax
  association to parent ZI_MDG_REQ as _Request
    on $projection.RequestUuid = _Request.RequestUuid
{
  key request_uuid as RequestUuid,
  key taxtype      as TaxType,
      taxnum       as TaxNumber,

      _Request
}

```


### ZI_MDG_REQ.ddls

```abap
@EndUserText.label: 'MDG BP Request'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.semanticKey: [ 'RequestId' ]
@VDM.viewType: #BASIC
define root view entity ZI_MDG_REQ
  as select from zmdg_req
  composition [0..*] of ZI_MDG_REQADR as _Address
  composition [0..*] of ZI_MDG_REQTAX as _Tax
  association [0..1] to ZI_MDG_C_SYS as _ConnectedSystem
    on _ConnectedSystem.ExternalSystem = $projection.ExternalSystem
{
  key request_uuid         as RequestUuid,
      request_id           as RequestId,
      request_type         as RequestType,
      @ObjectModel.text.association: '_ConnectedSystem'
      extsys               as ExternalSystem,
      partner_gid          as PartnerGid,
      status               as Status,
      parent_gid1          as ParentGid1,
      parent_gid2          as ParentGid2,
      found_date           as FoundDate,
      duns                 as Duns,
      lei_code             as LeiCode,
      euid                 as Euid,
      partner_id           as PartnerId,
      type                 as BusinessPartnerType,
      bu_group             as BusinessPartnerGroup,
      legal_form           as LegalForm,
      tel_number           as TelephoneNumber,
      mob_number           as MobileNumber,
      smtpadress           as EmailAddress,
      inactive             as IsInactive,
      inactive_reason      as InactiveReason,
      vendor               as Vendor,
      customer             as Customer,
      name_org1            as OrganizationName1,
      name_org2            as OrganizationName2,
      name_org3            as OrganizationName3,
      name_org4            as OrganizationName4,
      name_first           as FirstName,
      name_last            as LastName,
      bu_sort1             as SearchTerm1,
      street               as Street,
      house_num1           as HouseNumber,
      house_num2           as HouseNumberSupplement,
      city1                as City,
      city2                as District,
      post_code1           as PostalCode,
      country              as Country,
      name_org             as OrganizationName,
      name_person          as PersonName,
      created_by           as CreatedBy,
      created_at           as CreatedAt,
      last_changed_by      as LastChangedBy,
      last_changed_at      as LastChangedAt,
      locl_last_changed_at as LocalLastChangedAt,

      _ConnectedSystem,
      _Address,
      _Tax
}

```


### ZC_MDG_REQADR.ddls

```abap
@EndUserText.label: 'MDG BP Request Address Variant'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define view entity ZC_MDG_REQADR
  as projection on ZI_MDG_REQADR
{
  key RequestUuid,
  key Nation,
      OrganizationName1,
      OrganizationName2,
      OrganizationName3,
      OrganizationName4,
      FirstName,
      LastName,
      SearchTerm1,
      Street,
      HouseNumber,
      HouseNumberSupplement,
      City,
      District,
      PostalCode,
      Country,
      OrganizationName,
      PersonName,

      _Request : redirected to parent ZC_MDG_REQ
}

```


### ZC_MDG_REQTAX.ddls

```abap
@EndUserText.label: 'MDG BP Request Tax Number'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define view entity ZC_MDG_REQTAX
  as projection on ZI_MDG_REQTAX
{
  key RequestUuid,
  key TaxType,
      TaxNumber,

      _Request : redirected to parent ZC_MDG_REQ
}

```


### ZC_MDG_REQ.ddls

```abap
@EndUserText.label: 'MDG BP Request'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define root view entity ZC_MDG_REQ
  provider contract transactional_query
  as projection on ZI_MDG_REQ
{
  key RequestUuid,
      RequestId,
      RequestType,
      ExternalSystem,
      PartnerGid,
      Status,
      ParentGid1,
      ParentGid2,
      FoundDate,
      Duns,
      LeiCode,
      Euid,
      PartnerId,
      BusinessPartnerType,
      BusinessPartnerGroup,
      LegalForm,
      TelephoneNumber,
      MobileNumber,
      EmailAddress,
      IsInactive,
      InactiveReason,
      Vendor,
      Customer,
      OrganizationName1,
      OrganizationName2,
      OrganizationName3,
      OrganizationName4,
      FirstName,
      LastName,
      SearchTerm1,
      Street,
      HouseNumber,
      HouseNumberSupplement,
      City,
      District,
      PostalCode,
      Country,
      OrganizationName,
      PersonName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _ConnectedSystem,
      _Address : redirected to composition child ZC_MDG_REQADR,
      _Tax     : redirected to composition child ZC_MDG_REQTAX
}

```


