# MDG Create - Working Code

Vychozi datovy model pro novou RAP aplikaci pozadavku na zalozeni BP.

Model pouziva technicky klic `request_uuid` pro draft/kompozice. Pole `request_id` zustava semanticke cislo pozadavku a bude se plnit az pri ulozeni.

## TypeScript support

Fiori aplikace `mdgcreaterequest` byla dodatecne prepnuta na TypeScript bez regenerovani projektu.

Runtime zdroj aplikace je nyni:

```text
mdgcreaterequest/webapp/Component.ts
```

Soubor obsahuje startup logiku pro parametr `ExternalSystem`, volani RAP factory action `CreateForSystem(...)` a navigaci na vytvoreny draft request.

Build a lokalni server prekladaji TypeScript pres `ui5-tooling-transpile`.
Konfigurace je v:

```text
mdgcreaterequest/package.json
mdgcreaterequest/tsconfig.json
mdgcreaterequest/ui5.yaml
mdgcreaterequest/ui5-local.yaml
mdgcreaterequest/ui5-mock.yaml
```

Kontrolni prikazy z adresare `mdgcreaterequest`:

```bash
npm run typecheck
npm run build
```

OPA/QUnit testy v `mdgcreaterequest/webapp/test` zustavaji v JavaScriptu. TypeScript podpora se tyka aplikacnich runtime modulu.

## Tables

### ZMDG_REQ

```abap
@EndUserText.label : 'MDG PoĂ„Ä…Ă„Äľadavek'
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
@EndUserText.label : 'MDG PoĂ„Ä…Ă„Äľadavek - Adresy'
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
@EndUserText.label : 'MDG poĂ„Ä…Ă„Äľadavek - daĂ„Ä…Ă‚ÂovĂ„â€šĂ‹â€ˇ Ä‚â€žÄąÂ¤Ă„â€šĂ‚Â­sla'
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

### ZMDG_C_SYS

```abap
@EndUserText.label : 'NastavenÄ‚Â­ pÄąâ„˘ipojenÄ‚Ëťch systÄ‚Â©mÄąĹ»'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #C
@AbapCatalog.dataMaintenance : #ALLOWED
define table zmdg_c_sys {

  key mandt   : mandt not null;
  key extsys  : zmdg_extsys not null;
  type        : zmdg_sys_type;
  description : zmdg_description;
  comm_class  : zmdg_comm_class;
  def_alpha   : zmdg_alpha;
  xcrea       : zmdg_xcrea;
  xenh        : zmdg_xenh;

}
```

### ZMDG_C_FIELDCAT

```abap
@EndUserText.label : 'MDG request fieldcat'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #C
@AbapCatalog.dataMaintenance : #ALLOWED
define table zmdg_c_fieldcat {

  key mandt        : mandt not null;
  key request_type : zmdg_creq_type not null;
  key extsys       : zmdg_extsys not null;
  key entityname   : zmdg_entity not null;
  key fieldname    : zmdg_fieldname not null;
  visible          : abap_boolean;
  editable         : abap_boolean;
  mandatory        : abap_boolean;

}
```

### ZMDG_C_BUGROUP

```abap
@EndUserText.label : 'SeskupovÄ‚Ë‡nÄ‚Â­ OP'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #C
@AbapCatalog.dataMaintenance : #ALLOWED
define table zmdg_c_bugroup {

  key mandt    : mandt not null;
  key extsys   : zmdg_extsys not null;
  key bu_group : zmdg_bu_group not null;
  nrind        : nrind;

}
```

## CDS Sources

## Current Source Snapshot

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
      @ObjectModel.text.element: [ 'Description' ]
  key extsys      as ExternalSystem,
      type        as SystemType,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      description as Description,
      comm_class  as CommunicationClass,
      def_alpha   as DefaultAlphabet,
      xcrea       as IsCreateAllowed,
      xenh        as IsEnhanceAllowed
}


```

### ZI_MDG_REQ.bdef
```abap
managed implementation in class ZBP_I_MDG_REQ unique;
strict ( 2 );
with draft;

define behavior for ZI_MDG_REQ alias Request
persistent table zmdg_req
draft table zmdg_req_d
lock master total etag LastChangedAt
authorization master ( global, instance )
etag master LocalLastChangedAt
with additional save
{
  create;
  update;
  delete ( features : instance );

  static factory action CreateRequest parameter ZI_MDG_REQ_CREATE_P [1];

  field ( readonly, numbering : managed ) RequestUuid;
  field ( readonly ) RequestId;
  field ( readonly ) RequestType, Status, ExternalSystem, PartnerGID;
  field ( readonly ) CreatedBy, CreatedAt, LastChangedBy, LastChangedAt, LocalLastChangedAt;
  field ( features : instance )
    ParentGid1, ParentGid2, FoundDate, Duns, LeiCode, Euid, PartnerId,
    BusinessPartnerType, BusinessPartnerGroup, LegalForm,
    TelephoneNumber, MobileNumber, EmailAddress, Vendor, Customer,
    IsInactive, InactiveReason,
    OrganizationName1, OrganizationName2, OrganizationName3, OrganizationName4,
    FirstName, LastName, SearchTerm1,
    Country, District, City, PostalCode, Street, HouseNumber, HouseNumberSupplement,
    OrganizationName, PersonName;

  draft action ( features : instance ) Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare
  {
    validation ValidateRequest;
  }

  determination PrepareRequestOnSave on save { create; }
  determination ClearPartnerId on modify { field BusinessPartnerGroup; }
  validation ValidateRequest on save { create; update; }

  side effects
  {
    field BusinessPartnerGroup affects field PartnerId, permissions ( field PartnerId );
    field IsInactive affects field InactiveReason, permissions ( field InactiveReason );
  }

  association _Address { create; with draft; }
  association _Tax     { create; with draft; }

  mapping for zmdg_req
  {
    RequestUuid          = request_uuid;
    RequestId            = request_id;
    RequestType          = request_type;
    ExternalSystem       = extsys;
    PartnerGid           = partner_gid;
    Status               = status;
    ParentGid1           = parent_gid1;
    ParentGid2           = parent_gid2;
    FoundDate            = found_date;
    Duns                 = duns;
    LeiCode              = lei_code;
    Euid                 = euid;
    PartnerId            = partner_id;
    BusinessPartnerType  = type;
    BusinessPartnerGroup = bu_group;
    LegalForm            = legal_form;
    TelephoneNumber      = tel_number;
    MobileNumber         = mob_number;
    EmailAddress         = smtpadress;
    IsInactive           = inactive;
    InactiveReason       = inactive_reason;
    Vendor               = vendor;
    Customer             = customer;
    OrganizationName1    = name_org1;
    OrganizationName2    = name_org2;
    OrganizationName3    = name_org3;
    OrganizationName4    = name_org4;
    FirstName            = name_first;
    LastName             = name_last;
    SearchTerm1          = bu_sort1;
    Street               = street;
    HouseNumber          = house_num1;
    HouseNumberSupplement = house_num2;
    City                 = city1;
    District             = city2;
    PostalCode           = post_code1;
    Country              = country;
    OrganizationName     = name_org;
    PersonName           = name_person;
    CreatedBy            = created_by;
    CreatedAt            = created_at;
    LastChangedBy        = last_changed_by;
    LastChangedAt        = last_changed_at;
    LocalLastChangedAt   = locl_last_changed_at;
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

### ZUI_MDG_REQ.srvd
```abap
@EndUserText.label: 'MDG: Create MDG Request'
define service ZUI_MDG_REQ {
  expose ZC_MDG_REQ                as Requests;
  expose ZC_MDG_REQADR             as AddressVariants;
  expose ZC_MDG_REQTAX             as TaxNumbers;
  expose ZI_MDG_C_SYS              as ConnectedSystems;
  expose ZI_MDG_C_SYS_CREATEVH     as CreateSystems;
  expose ZI_MDG_C_SYS_CHANGEVH     as ChangeSystems;
  expose ZI_MDG_USER               as Users;
  expose ZI_MDG_DOMAIN_VALUE_TEXT  as DomainValueTexts;
  expose ZI_MDG_COUNTRY_VH         as Countries;
  expose ZI_MDG_COUNTRY_TEXT       as CountryTexts;
  expose ZI_MDG_NATION_VH          as Nations;
  expose ZI_MDG_NATION_TEXT        as NationTexts;
  expose ZI_MDG_TAX_TYPE_VH        as TaxTypes;
  expose ZI_MDG_TAX_TYPE_TEXT      as TaxTypeTexts;
  expose ZI_MDG_PARTNER_TYPE_VH    as PartnerTypes;
  expose ZI_MDG_BU_GROUP_VH        as BusinessPartnerGroups;
}

```

### ZCL_MDG_SEND_API_OP
```abap
CLASS zcl_mdg_send_api_op DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_bgmc_op_single.

    METHODS constructor
      IMPORTING
        iv_request_uuid TYPE sysuuid_x16.

  PRIVATE SECTION.
    DATA mv_request_uuid TYPE sysuuid_x16.

    TYPES:
      BEGIN OF ty_api_payload,
        id     TYPE string,
        system TYPE string,
        type   TYPE string,
        status TYPE string,
      END OF ty_api_payload.

    METHODS build_payload
      IMPORTING
        is_request       TYPE zmdg_req
      RETURNING
        VALUE(rv_json)   TYPE string.

    METHODS send_payload
      IMPORTING
        iv_json          TYPE string
      RAISING
        cx_bgmc_operation.
ENDCLASS.

CLASS zcl_mdg_send_api_op IMPLEMENTATION.
  METHOD constructor.
    mv_request_uuid = iv_request_uuid.
  ENDMETHOD.

  METHOD if_bgmc_op_single~execute.
    SELECT SINGLE *
      FROM zmdg_req
      WHERE request_uuid = @mv_request_uuid
      INTO @DATA(request).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT *
      FROM zmdg_reqadr
      WHERE request_uuid = @mv_request_uuid
      INTO TABLE @DATA(addresses).

    SELECT *
      FROM zmdg_reqtax
      WHERE request_uuid = @mv_request_uuid
      INTO TABLE @DATA(tax_numbers).

    DATA(json) = build_payload( request ).

    " Addresses and tax numbers are already read here. They will be added to the
    " payload once the external API contract is fixed.
    send_payload( json ).
  ENDMETHOD.

  METHOD build_payload.
    DATA(payload) = VALUE ty_api_payload(
      id     = CONV #( is_request-request_id )
      system = CONV #( is_request-extsys )
      type   = CONV #( is_request-request_type )
      status = CONV #( is_request-status )
    ).

    rv_json = /ui2/cl_json=>serialize( data = payload ).
  ENDMETHOD.

  METHOD send_payload.
    cl_http_client=>create_by_destination(
      EXPORTING
        destination              = 'EXT_MDG_SYSTEM'
      IMPORTING
        client                   = DATA(http_client)
      EXCEPTIONS
        argument_not_found       = 1
        destination_not_found    = 2
        destination_no_authority = 3
        plugin_not_active        = 4
        internal_error           = 5
        OTHERS                   = 6
    ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW cx_bgmc_operation(
        retry_settings = VALUE #(
          delay_time = 60
          do_retry   = abap_true
        )
      ).
    ENDIF.

    http_client->request->set_method( if_http_request=>co_request_method_post ).
    http_client->request->set_header_field(
      name  = 'Content-Type'
      value = 'application/json'
    ).
    http_client->request->set_cdata( iv_json ).

    http_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        OTHERS                     = 5
    ).

    IF sy-subrc <> 0.
      http_client->close( ).
      RAISE EXCEPTION NEW cx_bgmc_operation(
        retry_settings = VALUE #(
          delay_time = 60
          do_retry   = abap_true
        )
      ).
    ENDIF.

    http_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4
    ).

    IF sy-subrc <> 0.
      http_client->close( ).
      RAISE EXCEPTION NEW cx_bgmc_operation(
        retry_settings = VALUE #(
          delay_time = 60
          do_retry   = abap_true
        )
      ).
    ENDIF.

    http_client->response->get_status(
      IMPORTING
        code = DATA(status_code)
    ).

    http_client->close( ).

    IF status_code <> 200 AND status_code <> 201.
      RAISE EXCEPTION NEW cx_bgmc_operation(
          retry_settings = VALUE #(
            delay_time = 60
            do_retry   = abap_true
          )
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

```

### mdgcreaterequest/README.md

```markdown
## Application Details
|               |
| ------------- |
|**Generation Date and Time**<br>Mon Jun 01 2026 09:42:21 GMT+0200 (Central European Summer Time)|
|**App Generator**<br>SAP Fiori Application Generator|
|**App Generator Version**<br>1.24.0|
|**Generation Platform**<br>Visual Studio Code|
|**Template Used**<br>List Report Page V4|
|**Service Type**<br>SAP System (ABAP On-Premise)|
|**Service URL**<br>https://hsr.con4pas.cz/sap/opu/odata4/sap/zui_mdg_req_o4/srvd/sap/zui_mdg_req/0001/|
|**Module Name**<br>mdgcreaterequest|
|**Application Title**<br>MDG request - create BP|
|**Namespace**<br>c4p.mdg|
|**UI5 Theme**<br>sap_horizon|
|**UI5 Version**<br>1.136.10|
|**Enable TypeScript**<br>False|
|**Add Eslint configuration**<br>True, see https://www.npmjs.com/package/@sap-ux/eslint-plugin-fiori-tools#rules for the eslint rules.|
|**Value Help Metadata**<br>Downloaded for external services|
|**Main Entity**<br>Requests|
|**Navigation Entity**<br>None|

## mdgcreaterequest

MDG request - create BP

### Starting the generated app

-   This app has been generated using the SAP Fiori tools - App Generator, as part of the SAP Fiori tools suite.  To launch the generated application, run the following from the generated application root folder:

```
    npm start
```

- It is also possible to run the application using mock data that reflects the OData Service URL supplied during application generation.  In order to run the application with Mock Data, run the following from the generated app root folder:

```
    npm run start-mock
```

#### Pre-requisites:

1. Active NodeJS LTS (Long Term Support) version and associated supported NPM version.  (See https://nodejs.org)
```

### ZI_MDG_USER.ddls
```abap
@EndUserText.label: 'MDG User'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_USER
  as select from I_User
{
      @ObjectModel.text.element: [ 'UserDescription' ]
  key UserID,
      @Semantics.text: true
      UserDescription
}

```

### ZI_MDG_DOMAIN_VALUE_TEXT.ddls
```abap
@EndUserText.label: 'MDG Domain Value Text'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_DOMAIN_VALUE_TEXT
  as select from dd07l as Value
    inner join   dd07t as Text on  Text.domname  = Value.domname
                               and Text.as4local = Value.as4local
                               and Text.as4vers  = Value.as4vers
                               and Text.valpos   = Value.valpos
{
  key Value.domname    as DomainName,
  key Text.ddlanguage  as Language,
      @ObjectModel.text.element: [ 'DomainValueText' ]
  key Value.domvalue_l as DomainValue,
      @Semantics.text: true
      Text.ddtext      as DomainValueText
}
where
      Value.as4local   = 'A'
  and Value.domvalue_l <> ''

```

### ZI_MDG_COUNTRY_VH.ddls
```abap
@EndUserText.label: 'MDG Country Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_COUNTRY_VH
  as select from t005  as Country
    inner join   t005t as Text on  Text.land1 = Country.land1
                               and Text.spras = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @ObjectModel.text.element: [ 'CountryName' ]
  key cast( Country.land1 as land1 ) as Country,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      Text.landx    as CountryName
}

```

### ZI_MDG_PARTNER_TYPE_VH.ddls
```abap
@EndUserText.label: 'MDG Partner Type Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_PARTNER_TYPE_VH
  as select from dd07l as Value
    inner join   dd07t as Text on  Text.domname  = Value.domname
                               and Text.as4local = Value.as4local
                               and Text.as4vers  = Value.as4vers
                               and Text.valpos   = Value.valpos
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @ObjectModel.text.element: [ 'BusinessPartnerTypeText' ]
      @UI.textArrangement: #TEXT_ONLY
  key cast( substring( Value.domvalue_l, 1, 1 ) as zmdg_bu_type ) as BusinessPartnerType,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      Text.ddtext as BusinessPartnerTypeText
}
where
      Value.domname    = 'ZMDG_D_BU_TYPE'
  and Value.as4local   = 'A'
  and Value.domvalue_l <> ''
  and Text.ddlanguage  = $session.system_language
```

### ZI_MDG_C_FIELDCAT.ddls
```abap
@EndUserText.label: 'MDG Request Field Control'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_C_FIELDCAT
  as select from zmdg_c_fieldcat
{
      @EndUserText.label: 'Request Type'
  key request_type as RequestType,

      @EndUserText.label: 'External System'
  key extsys       as ExternalSystem,

      @EndUserText.label: 'Entity Name'
  key entityname   as EntityName,

      @EndUserText.label: 'Field Name'
  key fieldname    as FieldName,

      @EndUserText.label: 'Visible'
      visible      as IsVisible,

      @EndUserText.label: 'Editable'
      editable     as IsEditable,

      @EndUserText.label: 'Mandatory'
      mandatory    as IsMandatory
}

```

### ZI_MDG_BU_GROUP_VH.ddls
```abap
@EndUserText.label: 'MDG Business Partner Group Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_BU_GROUP_VH
  as select from zmdg_c_bugroup
{
      @EndUserText.label: 'External System'
  key extsys   as ExternalSystem,

      @EndUserText.label: 'Partner Group'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key bu_group as BusinessPartnerGroup,

      @EndUserText.label: 'External Number Required'
      nrind    as IsExternalNumberRequired
}

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
      @ObjectModel.text.element: ['Description']   
      @UI.textArrangement: #TEXT_ONLY              
  key ExternalSystem,

      @Semantics.text: true                        
      Description,

      @UI.hidden: true                             
      SystemType,

      @UI.hidden: true                             
      DefaultAlphabet
}
where IsCreateAllowed = 'X'


```

### ZI_MDG_C_SYS_CHANGEVH.ddls
```abap
@EndUserText.label: 'MDG Change System Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_C_SYS_CHANGEVH
  as select from ZI_MDG_C_SYS
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @ObjectModel.text.element: ['Description']
      @UI.textArrangement: #TEXT_ONLY
  key ExternalSystem,

      @UI.hidden: true
  key cast( '' as zmdg_partner_gid ) as PartnerGID,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      Description,

      @UI.hidden: true
      SystemType,

      @UI.hidden: true
      DefaultAlphabet
}
where IsEnhanceAllowed = 'X'

union

select from ZI_MDG_C_SYS as System
  inner join zmdg_bpsys as BusinessPartnerSystem
    on BusinessPartnerSystem.extsys = System.ExternalSystem
{
  key System.ExternalSystem,

  key BusinessPartnerSystem.partner_gid as PartnerGID,

  System.Description,

  System.SystemType,

  System.DefaultAlphabet
}
where System.IsEnhanceAllowed <> 'X'

```

### ZI_MDG_TAX_TYPE_VH.ddls
```abap
@EndUserText.label: 'MDG Tax Type Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_TAX_TYPE_VH
  as select from tfktaxnumtype as TaxType
  association [0..1] to tfktaxnumtype_t as _Text
    on  _Text.taxtype = TaxType.taxtype
    and _Text.spras   = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @ObjectModel.text.element: [ 'TaxTypeText' ]
  key TaxType.taxtype as TaxType,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      _Text.text as TaxTypeText
}
```

### ZI_MDG_NATION_VH.ddls
```abap
@EndUserText.label: 'MDG Address Version Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_NATION_VH
  as select from zmdg_c_nation as Nation
  association [0..1] to zmdg_c_nationt as _Text
    on  _Text.nation = Nation.nation
    and _Text.langu  = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @ObjectModel.text.element: [ 'NationText' ]
  key Nation.nation as Nation,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      _Text.nation_text as NationText
}
where Nation.inactive <> 'X'

```

### ZI_MDG_REQ_CREATE_P.ddls
```abap
@EndUserText.label: 'Create MDG Request Parameters'
define abstract entity ZI_MDG_REQ_CREATE_P
{
  @EndUserText.label: 'External System'
  @Consumption.valueHelpDefinition: [
    {
      entity: { name: 'ZI_MDG_C_SYS_CREATEVH', element: 'ExternalSystem' }
    }
  ]
  ExternalSystem : zmdg_extsys;

  @EndUserText.label: 'Partner GID'
  @UI.hidden: true
  PartnerGID : zmdg_partner_gid;
}

```

### ZI_MDG_REQ.ddls
```abap
@EndUserText.label: 'MDG Request'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.semanticKey: [ 'RequestId' ]
@VDM.viewType: #BASIC
define root view entity ZI_MDG_REQ
  as select from zmdg_req
  composition [0..*] of ZI_MDG_REQADR as _Address
  composition [0..*] of ZI_MDG_REQTAX as _Tax
  association [0..1] to ZI_MDG_DOMAIN_VALUE_TEXT as _RequestTypeText
    on  _RequestTypeText.DomainName   = 'ZMDG_D_REQ_TYPE'
    and _RequestTypeText.Language     = $session.system_language
    and _RequestTypeText.DomainValue  = $projection.RequestType
  association [0..1] to ZI_MDG_DOMAIN_VALUE_TEXT as _StatusText
    on  _StatusText.DomainName   = 'ZMSG_D_REQ_STATUS'
    and _StatusText.Language     = $session.system_language
    and _StatusText.DomainValue  = $projection.Status
  association [0..1] to ZI_MDG_C_SYS as _ConnectedSystem
    on _ConnectedSystem.ExternalSystem = $projection.ExternalSystem
  association [0..1] to ZI_MDG_USER as _CreatedByUser
    on _CreatedByUser.UserID = $projection.CreatedBy
  association [0..1] to ZI_MDG_COUNTRY_TEXT as _CountryText
    on  $projection.Country = _CountryText.Country
    and _CountryText.Language = $session.system_language
{
  key request_uuid         as RequestUuid,
      request_id           as RequestId,
      @ObjectModel.foreignKey.association: '_RequestTypeText'
      @ObjectModel.text.association: '_RequestTypeText'
      request_type         as RequestType,
      @ObjectModel.foreignKey.association: '_ConnectedSystem'
      @ObjectModel.text.association: '_ConnectedSystem'
      extsys               as ExternalSystem,
      partner_gid          as PartnerGid,
      @ObjectModel.foreignKey.association: '_StatusText'
      @ObjectModel.text.association: '_StatusText'
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
      @ObjectModel.foreignKey.association: '_CreatedByUser'
      @ObjectModel.text.association: '_CreatedByUser'
      created_by           as CreatedBy,
      created_at           as CreatedAt,
      last_changed_by      as LastChangedBy,
      last_changed_at      as LastChangedAt,
      locl_last_changed_at as LocalLastChangedAt,

      _RequestTypeText,
      _StatusText,
      _ConnectedSystem,
      _CreatedByUser,
      _CountryText,
      _Address,
      _Tax
}


```

### ZI_MDG_REQADR.ddls
```abap
@EndUserText.label: 'MDG Request Address Variant'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_REQADR
  as select from zmdg_reqadr
  association to parent ZI_MDG_REQ as _Request
    on $projection.RequestUuid = _Request.RequestUuid
  association [0..1] to ZI_MDG_NATION_TEXT as _NationText
    on  $projection.Nation = _NationText.Nation
    and _NationText.Language = $session.system_language
  association [0..1] to ZI_MDG_COUNTRY_TEXT as _CountryText
    on  $projection.Country = _CountryText.Country
    and _CountryText.Language = $session.system_language
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
      _NationText,
      _CountryText,
      _Request
}

```

### ZI_MDG_REQTAX.ddls
```abap
@EndUserText.label: 'MDG Request Tax Number'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_MDG_REQTAX
  as select from zmdg_reqtax
  association to parent ZI_MDG_REQ as _Request
    on $projection.RequestUuid = _Request.RequestUuid
  association [0..1] to ZI_MDG_TAX_TYPE_TEXT as _TaxTypeText
    on  $projection.TaxType = _TaxTypeText.TaxType
    and _TaxTypeText.Language = $session.system_language
{
  key request_uuid as RequestUuid,
  key taxtype      as TaxType,
      taxnum       as TaxNumber,

      _TaxTypeText,
      _Request
}

```

### ZC_MDG_REQ.ddls
```abap
@EndUserText.label: 'MDG Request'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define root view entity ZC_MDG_REQ
  provider contract transactional_query
  as projection on ZI_MDG_REQ
{
  key RequestUuid,
      RequestId,
      @ObjectModel.virtualElement: true
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MDG_REQ_TITLE_VE'
      virtual ObjectPageTitle : abap.char(20),
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
      @ObjectModel.text.element: [ 'CountryName' ]
      Country,
      _CountryText.CountryName as CountryName,
      OrganizationName,
      PersonName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _RequestTypeText,
      _StatusText,
      _ConnectedSystem,
      _CreatedByUser,
      _CountryText,
      _Address : redirected to composition child ZC_MDG_REQADR,
      _Tax     : redirected to composition child ZC_MDG_REQTAX
}


```

### ZC_MDG_REQADR.ddls
```abap
@EndUserText.label: 'MDG Request Address Variant'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define view entity ZC_MDG_REQADR
  as projection on ZI_MDG_REQADR
{
  key RequestUuid,
      @ObjectModel.text.element: [ 'NationText' ]
  key Nation,
      _NationText.NationText as NationText,
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
      @ObjectModel.text.element: [ 'CountryName' ]
      Country,
      _CountryText.CountryName as CountryName,
      OrganizationName,
      PersonName,
      _NationText,
      _CountryText,
      _Request : redirected to parent ZC_MDG_REQ
}

```

### ZC_MDG_REQTAX.ddls
```abap
@EndUserText.label: 'MDG Request Tax Number'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define view entity ZC_MDG_REQTAX
  as projection on ZI_MDG_REQTAX
{
  key RequestUuid,
      @ObjectModel.text.element: [ 'TaxTypeText' ]
  key TaxType,
      _TaxTypeText.TaxTypeText as TaxTypeText,
      TaxNumber,

      _TaxTypeText,
      _Request : redirected to parent ZC_MDG_REQ
}

```

### ZC_MDG_REQ.bdef
```abap
projection;
strict ( 2 );
use draft;
use side effects;

define behavior for ZC_MDG_REQ alias Request
{
  use update;
  use delete;

  use action CreateRequest;

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

### ZC_MDG_REQ_UI.ddlx
```abap
@Metadata.layer: #CUSTOMER
@UI.headerInfo: {
  typeName: 'MDG Request',
  typeNamePlural: 'MDG Requests',
  title: { type: #STANDARD, value: 'ObjectPageTitle' }
}
@UI.createHidden: true
annotate entity ZC_MDG_REQ with
{
  @UI.hidden: true
  RequestUuid;


  @UI.hidden: true
  LocalLastChangedAt;

  @UI.facet: [
    {
      id: 'HeaderRequestType',
      purpose: #HEADER,
      type: #FIELDGROUP_REFERENCE,
      label: '',
      position: 10,
      targetQualifier: 'HeaderRequestType'
    },
    {
      id: 'HeaderRequestOrigin',
      purpose: #HEADER,
      type: #FIELDGROUP_REFERENCE,
      label: '',
      position: 20,
      targetQualifier: 'HeaderRequestOrigin'
    },
    {
      id: 'HeaderStatus',
      purpose: #HEADER,
      type: #FIELDGROUP_REFERENCE,
      label: '',
      position: 30,
      targetQualifier: 'HeaderStatus'
    },
    {
      id: 'HeaderCreatedBy',
      purpose: #HEADER,
      type: #FIELDGROUP_REFERENCE,
      label: '',
      position: 40,
      targetQualifier: 'HeaderCreatedBy'
    },
    {
      id: 'MainData',
      type: #COLLECTION,
      label: 'Main Data',
      position: 20
    },
    {
      id: 'MainDataIds',
      parentId: 'MainData',
      type: #FIELDGROUP_REFERENCE,
      position: 10,
      targetQualifier: 'MainDataIds'
    },
    {
      id: 'MainDataNames',
      parentId: 'MainData',
      type: #FIELDGROUP_REFERENCE,
      position: 20,
      targetQualifier: 'MainDataNames'
    },
    {
      id: 'IdentificationData',
      type: #COLLECTION,
      label: 'Identification Data',
      position: 30
    },
    {
      id: 'IdentificationDataFields',
      parentId: 'IdentificationData',
      type: #FIELDGROUP_REFERENCE,
      position: 10,
      targetQualifier: 'IdentificationData'
    },
    {
      id: 'TaxNumbers',
      parentId: 'IdentificationData',
      type: #LINEITEM_REFERENCE,
      position: 20,
      targetElement: '_Tax'
    },
    {
      id: 'CountrySpecificData',
      type: #FIELDGROUP_REFERENCE,
      label: 'Country Specific Data Detail',
      position: 60,
      targetQualifier: 'CountrySpecificData'
    },
    {
      id: 'Address',
      type: #FIELDGROUP_REFERENCE,
      label: 'Address',
      position: 40,
      targetQualifier: 'Address'
    },
    {
      id: 'AddressVariants',
      type: #LINEITEM_REFERENCE,
      label: 'Address Variants',
      position: 50,
      targetElement: '_Address'
    }
  ]
  @UI.lineItem: [
    {
      position: 5,
      type: #FOR_ACTION,
      dataAction: 'CreateRequest',
      label: 'Create'
    },
    { position: 10, label: 'Request ID' }
  ]
  @UI.identification: [{ position: 10, label: 'Request ID' }]
  @UI.selectionField: [{ position: 10 }]
  RequestId;

  @UI.lineItem: [{ position: 20, label: 'Request Type' }]
  @UI.fieldGroup: [{ qualifier: 'HeaderRequestType', position: 10, label: 'Request Type' }]
  @UI.selectionField: [{ position: 20 }]
  @UI.textArrangement: #TEXT_ONLY
  RequestType;

  @UI.lineItem: [{ position: 30, label: 'Request Origin' }]
  @UI.fieldGroup: [{ qualifier: 'HeaderRequestOrigin', position: 10, label: 'Request Origin' }]
  @UI.selectionField: [{ position: 30 }]
  @UI.textArrangement: #TEXT_ONLY
  ExternalSystem;

  @UI.lineItem: [{ position: 40, label: 'Status' }]
  @UI.fieldGroup: [{ qualifier: 'HeaderStatus', position: 10, label: 'Status' }]
  @UI.selectionField: [{ position: 40 }]
  @UI.textArrangement: #TEXT_ONLY
  Status;

  @UI.lineItem: [{ position: 50, label: 'Created By' }]
  @UI.fieldGroup: [{ qualifier: 'HeaderCreatedBy', position: 10, label: 'Created By' }]
  @UI.textArrangement: #TEXT_ONLY
  CreatedBy;

  @UI.lineItem: [{ position: 60, label: 'Partner GID' }]
  @UI.fieldGroup: [{ qualifier: 'MainDataIds', position: 10, label: 'Partner GID' }]
  PartnerGid;

  @UI.lineItem: [{ position: 70, label: 'DUNS Number' }]
  @UI.fieldGroup: [{ qualifier: 'IdentificationData', position: 30, label: 'DUNS Number' }]
  Duns;
  @UI.hidden: true
  CreatedAt;

  @UI.fieldGroup: [{ qualifier: 'MainDataIds', position: 20, label: 'Parent GID 1' }]
  ParentGid1;

  @UI.fieldGroup: [{ qualifier: 'MainDataIds', position: 30, label: 'Parent GID 2' }]
  ParentGid2;

  @UI.fieldGroup: [{ qualifier: 'MainDataNames', position: 30, label: 'Found Date' }]
  FoundDate;

  @UI.fieldGroup: [{ qualifier: 'IdentificationData', position: 20, label: 'LEI Code' }]
  LeiCode;

  @UI.fieldGroup: [{ qualifier: 'IdentificationData', position: 40, label: 'EUID' }]
  Euid;

  @Consumption.valueHelpDefinition: [
    {
      entity: { name: 'ZI_MDG_BU_GROUP_VH', element: 'BusinessPartnerGroup' },
      additionalBinding: [
        { localElement: 'ExternalSystem', element: 'ExternalSystem' }
      ]
    }
  ]
  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 10, label: 'Partner Group' }]
  BusinessPartnerGroup;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 20, label: 'Partner ID' }]
  PartnerId;

  @Consumption.valueHelpDefinition: [
    {
      entity: { name: 'ZI_MDG_PARTNER_TYPE_VH', element: 'BusinessPartnerType' }
    }
  ]
  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 30, label: 'Partner Category' }]
  @UI.textArrangement: #TEXT_ONLY
  BusinessPartnerType;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 40, label: 'Legal Form' }]
  LegalForm;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 50, label: 'Telephone No' }]
  TelephoneNumber;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 60, label: 'Mobile Tel. No' }]
  MobileNumber;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 70, label: 'E-mail Address' }]
  EmailAddress;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 80, label: 'Vendor' }]
  Vendor;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 90, label: 'Customer' }]
  Customer;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 100, label: 'Inactive' }]
  IsInactive;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 110, label: 'Inactive Reason' }]
  InactiveReason;

  @UI.fieldGroup: [{ qualifier: 'MainDataNames', position: 10, label: 'Company Name' }]
  OrganizationName1;

  @UI.fieldGroup: [{ qualifier: 'MainDataNames', position: 20, label: 'Search Term' }]
  SearchTerm1;

  @Consumption.valueHelpDefinition: [
    {
      entity: { name: 'ZI_MDG_COUNTRY_VH', element: 'Country' }
    }
  ]
  @UI.fieldGroup: [{ qualifier: 'Address', position: 10, label: 'Country' }]
  @UI.textArrangement: #TEXT_LAST
  Country;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 30, label: 'District' }]
  District;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 20, label: 'City' }]
  City;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 50, label: 'Postal Code' }]
  PostalCode;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 40, label: 'Street' }]
  Street;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 60, label: 'House No' }]
  HouseNumber;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 70, label: 'House No Suppl.' }]
  HouseNumberSupplement;
}
```

### ZC_MDG_REQADR_UI.ddlx
```abap
@Metadata.layer: #CUSTOMER
@UI.headerInfo: {
  typeName: 'Address Variant',
  typeNamePlural: 'Address Variants',
  title: { type: #STANDARD, value: 'Nation' },
  description: { type: #STANDARD, value: 'OrganizationName1' }
}
annotate entity ZC_MDG_REQADR with
{
  @UI.hidden: true
  RequestUuid;

  @UI.facet: [
    {
      id: 'AddressVariantDetail',
      purpose: #STANDARD,
      type: #IDENTIFICATION_REFERENCE,
      label: 'Address Details',
      position: 10
    }
  ]

  @Consumption.valueHelpDefinition: [
    {
      entity: { name: 'ZI_MDG_NATION_VH', element: 'Nation' }
    }
  ]
  @UI.textArrangement: #TEXT_ONLY
  @UI.lineItem: [{ position: 10, label: 'Nation' }]
  @UI.identification: [{ position: 10, label: 'Nation' }]
  Nation;

  @UI.lineItem: [{ position: 20, label: 'Company Name' }]
  @UI.identification: [{ position: 20, label: 'Company Name' }]
  OrganizationName1;

  @Consumption.valueHelpDefinition: [
    {
      entity: { name: 'ZI_MDG_COUNTRY_VH', element: 'Country' }
    }
  ]
  @UI.textArrangement: #TEXT_LAST
  @UI.lineItem: [{ position: 30, label: 'Country' }]
  @UI.identification: [{ position: 30, label: 'Country' }]
  Country;

  @UI.lineItem: [{ position: 40, label: 'City' }]
  @UI.identification: [{ position: 40, label: 'City' }]
  City;

  @UI.lineItem: [{ position: 50, label: 'Postal Code' }]
  @UI.identification: [{ position: 50, label: 'Postal Code' }]
  PostalCode;

  @UI.lineItem: [{ position: 60, label: 'Street' }]
  @UI.identification: [{ position: 60, label: 'Street' }]
  Street;
  @UI.lineItem: [{ position: 70, label: 'House No' }]
  @UI.identification: [{ position: 70, label: 'House No' }]
  HouseNumber;

  @UI.lineItem: [{ position: 80, label: 'House No Suppl.' }]
  @UI.identification: [{ position: 80, label: 'House No Suppl.' }]
  HouseNumberSupplement;
}
```

### ZC_MDG_REQTAX_UI.ddlx
```abap
@Metadata.layer: #CUSTOMER
@UI.headerInfo: {
  typeName: 'Tax Number',
  typeNamePlural: 'Tax Numbers',
  title: { type: #STANDARD, value: 'TaxType' },
  description: { type: #STANDARD, value: 'TaxNumber' }
}
annotate entity ZC_MDG_REQTAX with
{
  @UI.hidden: true
  RequestUuid;

  @UI.facet: [
    {
      id: 'TaxNumberDetail',
      purpose: #STANDARD,
      type: #IDENTIFICATION_REFERENCE,
      label: 'Tax Number Details',
      position: 10
    }
  ]

  @Consumption.valueHelpDefinition: [
    {
      entity: { name: 'ZI_MDG_TAX_TYPE_VH', element: 'TaxType' }
    }
  ]
  @UI.textArrangement: #TEXT_FIRST
  @UI.lineItem: [{ position: 10, label: 'Tax Type' }]
  @UI.identification: [{ position: 10, label: 'Tax Type' }]
  TaxType;

  @UI.lineItem: [{ position: 20, label: 'Tax Number' }]
  @UI.identification: [{ position: 20, label: 'Tax Number' }]
  TaxNumber;
}

```

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

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR request
      RESULT result.

    METHODS prepare_request_on_save FOR DETERMINE ON SAVE
      IMPORTING keys FOR request~PrepareRequestOnSave.

    METHODS clear_partner_id FOR DETERMINE ON MODIFY
      IMPORTING keys FOR request~ClearPartnerId.

    METHODS validate_request FOR VALIDATE ON SAVE
      IMPORTING keys FOR request~ValidateRequest.

    METHODS create_request FOR MODIFY
      IMPORTING keys FOR ACTION request~CreateRequest.

ENDCLASS.

CLASS lhc_request IMPLEMENTATION.
  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    READ ENTITIES OF zi_mdg_req IN LOCAL MODE
      ENTITY Request
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(requests).

    result = VALUE #(
      FOR request IN requests
      ( %tky    = request-%tky
        %update = COND #(
          WHEN request-Status = 'DRA'
            OR request-Status = 'ERR'
            THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized )
        %delete = COND #(
          WHEN request-Status = 'DRA'
            OR request-Status = 'ERR'
            THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ) )
    ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_mdg_req IN LOCAL MODE
      ENTITY Request
        FIELDS (
          RequestUuid RequestType ExternalSystem BusinessPartnerGroup Status IsInactive
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(requests).

    LOOP AT requests ASSIGNING FIELD-SYMBOL(<request>).
      DATA(request_data) =
        CORRESPONDING zmdg_req(
          <request> MAPPING FROM ENTITY
        ).

      DATA(request_context) =
        CORRESPONDING zcl_mdg_req_service=>ty_request(
          request_data
        ).
      request_context-mandt = sy-mandt.

      DATA(field_control) = zcl_mdg_req_service=>get_field_control( request_context ).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<features>).
      <features>-%tky = <request>-%tky.
      <features>-%action-Edit = COND #(
        WHEN <request>-Status = 'DRA'
          OR <request>-Status = 'ERR'
          THEN if_abap_behv=>fc-o-enabled
        ELSE if_abap_behv=>fc-o-disabled
      ).
      <features>-%delete = COND #(
        WHEN <request>-Status = 'DRA'
          OR <request>-Status = 'ERR'
          THEN if_abap_behv=>fc-o-enabled
        ELSE if_abap_behv=>fc-o-disabled
      ).

      LOOP AT field_control ASSIGNING FIELD-SYMBOL(<field_control>)
           WHERE entity_name = 'REQUEST'.

        ASSIGN COMPONENT <field_control>-field_name OF STRUCTURE <features>-%field TO FIELD-SYMBOL(<field_feature>).
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        <field_feature> = COND #(
          WHEN <field_control>-mandatory = abap_true THEN if_abap_behv=>fc-f-mandatory
          WHEN <field_control>-editable  = abap_true THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only
        ).
      ENDLOOP.

      <features>-%field-PartnerId = COND #(
        WHEN zcl_mdg_req_service=>is_partner_id_required( request_context ) = abap_true
          THEN if_abap_behv=>fc-f-mandatory
        ELSE if_abap_behv=>fc-f-read_only
      ).

      IF <request>-IsInactive <> abap_true.
        <features>-%field-InactiveReason = if_abap_behv=>fc-f-read_only.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD prepare_request_on_save.
    READ ENTITIES OF zi_mdg_req IN LOCAL MODE
      ENTITY Request
        FIELDS ( RequestId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(requests).

    DATA update_requests TYPE TABLE FOR UPDATE zi_mdg_req.

    LOOP AT requests ASSIGNING FIELD-SYMBOL(<request>)
         WHERE RequestId IS INITIAL
            OR RequestId = '0000000000'.

      TRY.
          DATA(request_id) = zcl_mdg_req_service=>get_next_request_id( ).
        CATCH cx_number_ranges.
          APPEND VALUE #(
            %tky = <request>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = 'Request ID could not be generated.' )
            %element-RequestId = if_abap_behv=>mk-on
          ) TO reported-request.
          CONTINUE.
      ENDTRY.

      IF request_id IS INITIAL.
        APPEND VALUE #(
          %tky = <request>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Request ID could not be generated.' )
          %element-RequestId = if_abap_behv=>mk-on
        ) TO reported-request.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky      = <request>-%tky
        RequestId = request_id
        Status    = 'INP'
      ) TO update_requests.
    ENDLOOP.

    IF update_requests IS NOT INITIAL.
      MODIFY ENTITIES OF zi_mdg_req IN LOCAL MODE
        ENTITY Request
          UPDATE FIELDS ( RequestId Status )
          WITH update_requests.
    ENDIF.
  ENDMETHOD.

  METHOD clear_partner_id.
    READ ENTITIES OF zi_mdg_req IN LOCAL MODE
      ENTITY Request
        FIELDS ( RequestUuid ExternalSystem BusinessPartnerGroup PartnerId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(requests).

    DATA update_requests TYPE TABLE FOR UPDATE zi_mdg_req.

    LOOP AT requests ASSIGNING FIELD-SYMBOL(<request>)
         WHERE PartnerId IS NOT INITIAL.

      DATA(request_data) =
        CORRESPONDING zmdg_req(
          <request> MAPPING FROM ENTITY
        ).

      DATA(request_context) =
        CORRESPONDING zcl_mdg_req_service=>ty_request(
          request_data
        ).
      request_context-mandt = sy-mandt.

      IF zcl_mdg_req_service=>is_partner_id_required( request_context ) = abap_true.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky      = <request>-%tky
        PartnerId = ''
      ) TO update_requests.
    ENDLOOP.

    IF update_requests IS NOT INITIAL.
      MODIFY ENTITIES OF zi_mdg_req IN LOCAL MODE
        ENTITY Request
          UPDATE FIELDS ( PartnerId )
          WITH update_requests.
    ENDIF.
  ENDMETHOD.

  METHOD validate_request.
    READ ENTITIES OF zi_mdg_req IN LOCAL MODE
      ENTITY Request
        FIELDS (
          RequestUuid RequestId RequestType ExternalSystem PartnerGid Status
          ParentGid1 ParentGid2 FoundDate Duns LeiCode Euid PartnerId
          BusinessPartnerType BusinessPartnerGroup LegalForm TelephoneNumber MobileNumber EmailAddress
          IsInactive InactiveReason Vendor Customer
          OrganizationName1 OrganizationName2 OrganizationName3 OrganizationName4 FirstName LastName
          SearchTerm1 Country District City PostalCode Street HouseNumber HouseNumberSupplement
          OrganizationName PersonName CreatedBy CreatedAt LastChangedBy LastChangedAt
        )
        WITH CORRESPONDING #( keys )
      RESULT DATA(requests)
      ENTITY Request BY \_Address
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(addresses)
      ENTITY Request BY \_Tax
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(tax_numbers).

    LOOP AT requests ASSIGNING FIELD-SYMBOL(<request>).
      DATA(request_data) =
        CORRESPONDING zmdg_req(
          <request> MAPPING FROM ENTITY
        ).

      DATA(request_context) =
        CORRESPONDING zcl_mdg_req_service=>ty_request(
          request_data
        ).
      request_context-mandt = sy-mandt.

      LOOP AT addresses ASSIGNING FIELD-SYMBOL(<address>) USING KEY entity WHERE RequestUuid = <request>-RequestUuid.
        DATA(address_context) =
          CORRESPONDING zmdg_reqadr(
            <address> MAPPING FROM ENTITY
          ).
        address_context-mandt = sy-mandt.
        APPEND address_context TO request_context-address.
      ENDLOOP.

      LOOP AT tax_numbers ASSIGNING FIELD-SYMBOL(<tax_number>) USING KEY entity WHERE RequestUuid = <request>-RequestUuid.
        DATA(tax_context) =
          CORRESPONDING zmdg_reqtax(
            <tax_number> MAPPING FROM ENTITY
          ).
        tax_context-mandt = sy-mandt.
        APPEND tax_context TO request_context-tax.
      ENDLOOP.

      DATA(messages) = zcl_mdg_req_service=>check_request( request_context ).

      LOOP AT messages ASSIGNING FIELD-SYMBOL(<message>).
        APPEND INITIAL LINE TO reported-request ASSIGNING FIELD-SYMBOL(<reported_request>).
        <reported_request>-%tky = <request>-%tky.
        <reported_request>-%msg = new_message_with_text(
          severity = <message>-severity
          text     = <message>-text
        ).

        ASSIGN COMPONENT <message>-field_name OF STRUCTURE <reported_request>-%element TO FIELD-SYMBOL(<element>).
        IF sy-subrc = 0.
          <element> = if_abap_behv=>mk-on.
        ENDIF.
      ENDLOOP.

      IF messages IS NOT INITIAL.
        APPEND VALUE #( %tky = <request>-%tky ) TO failed-request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_request.
    DATA create_requests  TYPE TABLE FOR CREATE zi_mdg_req.
    DATA create_addresses TYPE TABLE FOR CREATE zi_mdg_req\_Address.
    DATA create_taxes     TYPE TABLE FOR CREATE zi_mdg_req\_Tax.
    DATA business_partner TYPE zmdg_bp.
    DATA system_data      TYPE zmdg_bpsys.
    DATA display_address  TYPE zmdg_bpadr.
    DATA addresses        TYPE STANDARD TABLE OF zmdg_bpadr WITH EMPTY KEY.
    DATA tax_numbers      TYPE STANDARD TABLE OF zmdg_bptax WITH EMPTY KEY.
    DATA partner_gid      TYPE zmdg_partner_gid.
    DATA external_system  TYPE zmdg_extsys.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      CLEAR:
        business_partner,
        system_data,
        display_address,
        addresses,
        tax_numbers,
        partner_gid,
        external_system.

      external_system = <key>-%param-ExternalSystem.

      ASSIGN COMPONENT 'PartnerGid' OF STRUCTURE <key>-%param TO FIELD-SYMBOL(<partner_gid>).
      IF sy-subrc <> 0.
        ASSIGN COMPONENT 'PartnerGID' OF STRUCTURE <key>-%param TO <partner_gid>.
      ENDIF.
      IF sy-subrc <> 0.
        ASSIGN COMPONENT 'PARTNERGID' OF STRUCTURE <key>-%param TO <partner_gid>.
      ENDIF.
      IF sy-subrc = 0 AND <partner_gid> IS ASSIGNED.
        partner_gid = CONV #( <partner_gid> ).
      ENDIF.

      DATA(request_type) = COND #( WHEN partner_gid IS INITIAL THEN 'C' ELSE 'U' ).

      IF partner_gid IS NOT INITIAL.
        SELECT SINGLE *
          FROM zmdg_bp
          WHERE partner_gid = @partner_gid
          INTO @business_partner.

        SELECT SINGLE *
          FROM zmdg_bpsys
          WHERE partner_gid = @partner_gid
            AND extsys      = @external_system
          INTO @system_data.

        SELECT SINGLE *
          FROM zmdg_bpadr
          WHERE partner_gid = @partner_gid
            AND nation      = @space
          INTO @display_address.

        SELECT *
          FROM zmdg_bpadr
          WHERE partner_gid = @partner_gid
            AND nation      <> @space
          INTO TABLE @addresses.

        IF display_address IS INITIAL AND addresses IS NOT INITIAL.
          display_address = addresses[ 1 ].
        ENDIF.
      ENDIF.

      APPEND VALUE #(
        %cid                  = <key>-%cid
        %is_draft             = if_abap_behv=>mk-on
        RequestType           = request_type
        ExternalSystem        = external_system
        PartnerGid            = partner_gid
        Status                = 'DRA'
        CreatedBy             = cl_abap_context_info=>get_user_technical_name( )
        ParentGid1            = business_partner-parent_gid1
        ParentGid2            = business_partner-parent_gid2
        FoundDate             = business_partner-found_date
        Duns                  = business_partner-duns
        LeiCode               = business_partner-lei_code
        Euid                  = business_partner-euid
        PartnerId             = system_data-partner_id
        BusinessPartnerType   = system_data-type
        BusinessPartnerGroup  = system_data-bu_group
        LegalForm             = system_data-legal_form
        TelephoneNumber       = system_data-tel_number
        MobileNumber          = system_data-mob_number
        EmailAddress          = system_data-smtpadress
        IsInactive            = system_data-inactive
        InactiveReason        = system_data-inactive_reason
        OrganizationName1     = display_address-name_org1
        OrganizationName2     = display_address-name_org2
        OrganizationName3     = display_address-name_org3
        OrganizationName4     = display_address-name_org4
        FirstName             = display_address-name_first
        LastName              = display_address-name_last
        SearchTerm1           = display_address-bu_sort1
        Country               = display_address-country
        District              = display_address-city2
        City                  = display_address-city1
        PostalCode            = display_address-post_code1
        Street                = display_address-street
        HouseNumber           = display_address-house_num1
        HouseNumberSupplement = display_address-house_num2
        OrganizationName      = display_address-name_org
        PersonName            = display_address-name_person
      ) TO create_requests.
    ENDLOOP.

    MODIFY ENTITIES OF zi_mdg_req IN LOCAL MODE
      ENTITY Request
        CREATE FIELDS (
          RequestType ExternalSystem PartnerGid Status CreatedBy
          ParentGid1 ParentGid2 FoundDate Duns LeiCode Euid PartnerId
          BusinessPartnerType BusinessPartnerGroup LegalForm TelephoneNumber MobileNumber EmailAddress
          IsInactive InactiveReason
          OrganizationName1 OrganizationName2 OrganizationName3 OrganizationName4 FirstName LastName
          SearchTerm1 Country District City PostalCode Street HouseNumber HouseNumberSupplement
          OrganizationName PersonName
        )
        WITH create_requests
      MAPPED mapped
      FAILED failed
      REPORTED reported.

    IF mapped-request IS NOT INITIAL.
      READ ENTITIES OF zi_mdg_req IN LOCAL MODE
        ENTITY Request
          FIELDS ( RequestUuid PartnerGid )
          WITH CORRESPONDING #( mapped-request )
        RESULT DATA(created_requests).

      LOOP AT created_requests ASSIGNING FIELD-SYMBOL(<created_request>).
        IF <created_request>-PartnerGid IS INITIAL.
          CONTINUE.
        ENDIF.

        SELECT *
          FROM zmdg_bpadr
          WHERE partner_gid = @<created_request>-PartnerGid
            AND nation      <> @space
          INTO TABLE @addresses.

        IF addresses IS NOT INITIAL.
          APPEND VALUE #(
            %tky    = <created_request>-%tky
            %target = VALUE #(
              FOR address IN addresses INDEX INTO address_index
              ( %cid                  = |ADR{ address_index }|
                %is_draft             = if_abap_behv=>mk-on
                Nation                = address-nation
                OrganizationName1     = address-name_org1
                OrganizationName2     = address-name_org2
                OrganizationName3     = address-name_org3
                OrganizationName4     = address-name_org4
                FirstName             = address-name_first
                LastName              = address-name_last
                SearchTerm1           = address-bu_sort1
                Street                = address-street
                HouseNumber           = address-house_num1
                HouseNumberSupplement = address-house_num2
                City                  = address-city1
                District              = address-city2
                PostalCode            = address-post_code1
                Country               = address-country
                OrganizationName      = address-name_org
                PersonName            = address-name_person )
            )
          ) TO create_addresses.
        ENDIF.

        SELECT *
          FROM zmdg_bptax
          WHERE partner_gid = @<created_request>-PartnerGid
          INTO TABLE @tax_numbers.

        IF tax_numbers IS NOT INITIAL.
          APPEND VALUE #(
            %tky    = <created_request>-%tky
            %target = VALUE #(
              FOR tax_number IN tax_numbers INDEX INTO tax_index
              ( %cid      = |TAX{ tax_index }|
                %is_draft = if_abap_behv=>mk-on
                TaxType   = tax_number-taxtype
                TaxNumber = tax_number-taxnum )
            )
          ) TO create_taxes.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF create_addresses IS NOT INITIAL.
      MODIFY ENTITIES OF zi_mdg_req IN LOCAL MODE
        ENTITY Request
        CREATE BY \_Address FIELDS (
          Nation OrganizationName1 OrganizationName2 OrganizationName3 OrganizationName4
          FirstName LastName SearchTerm1 Street HouseNumber HouseNumberSupplement
          City District PostalCode Country OrganizationName PersonName
        )
        WITH create_addresses
        MAPPED DATA(mapped_addresses)
        FAILED DATA(failed_addresses)
        REPORTED DATA(reported_addresses).
    ENDIF.

    IF create_taxes IS NOT INITIAL.
      MODIFY ENTITIES OF zi_mdg_req IN LOCAL MODE
        ENTITY Request
        CREATE BY \_Tax FIELDS ( TaxType TaxNumber )
        WITH create_taxes
        MAPPED DATA(mapped_taxes)
        FAILED DATA(failed_taxes)
        REPORTED DATA(reported_taxes).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zi_mdg_req DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zi_mdg_req IMPLEMENTATION.
  METHOD save_modified.
    LOOP AT create-request ASSIGNING FIELD-SYMBOL(<created_request>).
      zcl_mdg_req_service=>request_saved_async(
        iv_request_uuid = <created_request>-RequestUuid
      ).
    ENDLOOP.

    LOOP AT update-request ASSIGNING FIELD-SYMBOL(<updated_request>).
      zcl_mdg_req_service=>request_saved_async(
        iv_request_uuid = <updated_request>-RequestUuid
      ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

```

### ZCL_MDG_REQ_SERVICE
```abap
CLASS zcl_mdg_req_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES tt_address TYPE STANDARD TABLE OF zmdg_reqadr WITH EMPTY KEY.
    TYPES tt_tax     TYPE STANDARD TABLE OF zmdg_reqtax WITH EMPTY KEY.

    TYPES BEGIN OF ty_request.
            INCLUDE TYPE zmdg_req.
    TYPES   address TYPE tt_address.
    TYPES   tax     TYPE tt_tax.
    TYPES END OF ty_request.

    TYPES:
      BEGIN OF ty_message,
        field_name TYPE string,
        severity   TYPE if_abap_behv_message=>t_severity,
        text       TYPE string,
      END OF ty_message,
      tt_message TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_field_control,
        entity_name TYPE zmdg_entity,
        field_name  TYPE zmdg_fieldname,
        visible     TYPE abap_boolean,
        editable    TYPE abap_boolean,
        mandatory   TYPE abap_boolean,
      END OF ty_field_control,
      tt_field_control TYPE SORTED TABLE OF ty_field_control
        WITH UNIQUE KEY entity_name field_name.

    TYPES:
      BEGIN OF ty_save_result,
        request  TYPE ty_request,
        messages TYPE tt_message,
        return_code TYPE i,
      END OF ty_save_result.

    CLASS-METHODS check_request
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rt_message) TYPE tt_message.

    CLASS-METHODS save_request
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_result)  TYPE ty_save_result.

    CLASS-METHODS get_next_request_id
      RETURNING VALUE(rv_request_id) TYPE zmdg_request_id
      RAISING   cx_number_ranges.

    CLASS-METHODS get_field_control
      IMPORTING is_request              TYPE ty_request
      RETURNING VALUE(rt_field_control) TYPE tt_field_control.

    CLASS-METHODS is_partner_id_required
      IMPORTING is_request       TYPE ty_request
      RETURNING VALUE(rv_result) TYPE abap_boolean.

    CLASS-METHODS request_created
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_result)  TYPE ty_save_result.

    CLASS-METHODS request_saved_async
      IMPORTING iv_request_uuid TYPE sysuuid_x16.

  PRIVATE SECTION.
    CLASS-METHODS check_mandatory_fields
      IMPORTING
        is_request       TYPE ty_request
        it_field_control TYPE tt_field_control
      CHANGING
        ct_message       TYPE tt_message.

    CLASS-METHODS get_request_component_name
      IMPORTING iv_field_name            TYPE zmdg_fieldname
      RETURNING VALUE(rv_component_name) TYPE string.

    CLASS-METHODS add_error
      IMPORTING
        iv_field_name     TYPE string
        iv_text           TYPE string
      CHANGING
        ct_message        TYPE tt_message.
ENDCLASS.

CLASS zcl_mdg_req_service IMPLEMENTATION.
  METHOD check_request.
    IF is_request-request_type IS INITIAL
       OR ( is_request-request_type <> 'C'
        AND is_request-request_type <> 'U' ).
      add_error(
        EXPORTING
          iv_field_name = 'RequestType'
          iv_text       = 'Request type must be C or U.'
        CHANGING
          ct_message    = rt_message
      ).
    ENDIF.

    IF is_request-extsys IS INITIAL.
      add_error(
        EXPORTING
          iv_field_name = 'ExternalSystem'
          iv_text       = 'External system is required.'
        CHANGING
          ct_message    = rt_message
      ).
    ENDIF.

    IF is_request-status IS INITIAL.
      add_error(
        EXPORTING
          iv_field_name = 'Status'
          iv_text       = 'Status is required.'
        CHANGING
          ct_message    = rt_message
      ).
    ENDIF.

    DATA(field_control) = get_field_control( is_request ).

    check_mandatory_fields(
      EXPORTING
        is_request       = is_request
        it_field_control = field_control
      CHANGING
        ct_message       = rt_message
    ).

    IF is_partner_id_required( is_request ) = abap_true
       AND is_request-partner_id IS INITIAL.
      add_error(
        EXPORTING
          iv_field_name = 'PartnerId'
          iv_text       = 'Partner ID is required for selected partner group.'
        CHANGING
          ct_message    = rt_message
      ).
    ENDIF.

    IF is_request-smtpadress IS NOT INITIAL.
      IF NOT matches(
          val   = is_request-smtpadress
          pcre  = `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$`
        ).
        add_error(
          EXPORTING
            iv_field_name = 'EmailAddress'
            iv_text       = 'E-mail address has invalid format.'
          CHANGING
            ct_message    = rt_message
        ).
      ENDIF.
    ENDIF.

    IF is_request-tel_number IS NOT INITIAL.
      IF NOT matches(
          val   = is_request-tel_number
          pcre  = `^\+?[0-9 ()/-]{6,30}$`
        ).
        add_error(
          EXPORTING
            iv_field_name = 'TelephoneNumber'
            iv_text       = 'Telephone number has invalid format.'
          CHANGING
            ct_message    = rt_message
        ).
      ENDIF.
    ENDIF.

    IF is_request-mob_number IS NOT INITIAL.
      IF NOT matches(
          val   = is_request-mob_number
          pcre  = `^\+?[0-9 ()/-]{6,30}$`
        ).
        add_error(
          EXPORTING
            iv_field_name = 'MobileNumber'
            iv_text       = 'Mobile number has invalid format.'
          CHANGING
            ct_message    = rt_message
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD save_request.
    rs_result-request = is_request.
    rs_result-messages = check_request( is_request ).

    IF rs_result-messages IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF rs_result-request-request_id IS NOT INITIAL
       AND rs_result-request-request_id <> '0000000000'.
      RETURN.
    ENDIF.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = '01'
            object      = 'ZMDG_REQ'
          IMPORTING
            number      = DATA(number)
        ).

        rs_result-request-request_id = |{ number ALPHA = OUT }|.
      CATCH cx_number_ranges.
        add_error(
          EXPORTING
            iv_field_name = 'RequestId'
            iv_text       = 'Request ID could not be generated.'
          CHANGING
            ct_message    = rs_result-messages
        ).
    ENDTRY.

    IF rs_result-messages IS INITIAL.
      DATA(created_result) = request_created( rs_result-request ).
      rs_result-return_code = created_result-return_code.
      APPEND LINES OF created_result-messages TO rs_result-messages.
    ENDIF.
  ENDMETHOD.

  METHOD get_next_request_id.
    cl_numberrange_runtime=>number_get(
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZMDG_REQ'
      IMPORTING
        number      = DATA(number)
    ).

    rv_request_id = |{ number ALPHA = OUT }|.
  ENDMETHOD.

  METHOD get_field_control.
    TYPES:
      BEGIN OF ty_ranked_field_control,
        entity_name TYPE zmdg_entity,
        field_name  TYPE zmdg_fieldname,
        visible     TYPE abap_boolean,
        editable    TYPE abap_boolean,
        mandatory   TYPE abap_boolean,
        priority    TYPE i,
      END OF ty_ranked_field_control.

    DATA(request_type) = COND zmdg_creq_type(
      WHEN is_request-request_type IS INITIAL THEN '*'
      ELSE CONV #( is_request-request_type )
    ).

    DATA(external_system) = COND zmdg_extsys(
      WHEN is_request-extsys IS INITIAL THEN '*'
      ELSE is_request-extsys
    ).

    SELECT FROM zi_mdg_c_fieldcat
      FIELDS
        RequestType,
        ExternalSystem,
        EntityName,
        FieldName,
        IsVisible,
        IsEditable,
        IsMandatory
      WHERE ( RequestType    = @request_type     OR RequestType    = '*' )
        AND ( ExternalSystem = @external_system  OR ExternalSystem = '*' )
      INTO TABLE @DATA(fieldcat).

    DATA ranked_field_control TYPE STANDARD TABLE OF ty_ranked_field_control WITH EMPTY KEY.

    LOOP AT fieldcat ASSIGNING FIELD-SYMBOL(<fieldcat>).
      DATA(priority) = COND i(
        WHEN <fieldcat>-RequestType = request_type
         AND <fieldcat>-ExternalSystem = external_system THEN 1
        WHEN <fieldcat>-RequestType = request_type
         AND <fieldcat>-ExternalSystem = '*'             THEN 2
        WHEN <fieldcat>-RequestType = '*'
         AND <fieldcat>-ExternalSystem = external_system THEN 3
        ELSE 4
      ).

      READ TABLE ranked_field_control ASSIGNING FIELD-SYMBOL(<ranked_field_control>)
        WITH KEY
          entity_name = <fieldcat>-EntityName
          field_name  = <fieldcat>-FieldName.

      IF sy-subrc = 0 AND <ranked_field_control>-priority <= priority.
        CONTINUE.
      ENDIF.

      IF sy-subrc = 0.
        <ranked_field_control>-visible   = <fieldcat>-IsVisible.
        <ranked_field_control>-editable  = <fieldcat>-IsEditable.
        <ranked_field_control>-mandatory = <fieldcat>-IsMandatory.
        <ranked_field_control>-priority  = priority.
      ELSE.
        APPEND VALUE #(
          entity_name = <fieldcat>-EntityName
          field_name  = <fieldcat>-FieldName
          visible     = <fieldcat>-IsVisible
          editable    = <fieldcat>-IsEditable
          mandatory   = <fieldcat>-IsMandatory
          priority    = priority
        ) TO ranked_field_control.
      ENDIF.
    ENDLOOP.

    rt_field_control = VALUE #(
      FOR field_control IN ranked_field_control
      ( entity_name = field_control-entity_name
        field_name  = field_control-field_name
        visible     = field_control-visible
        editable    = field_control-editable
        mandatory   = field_control-mandatory )
    ).
  ENDMETHOD.

  METHOD is_partner_id_required.
    IF is_request-extsys IS INITIAL
       OR is_request-bu_group IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE nrind
      FROM zmdg_c_bugroup
      WHERE extsys   = @is_request-extsys
        AND bu_group = @is_request-bu_group
      INTO @DATA(number_assignment).

    rv_result = xsdbool( number_assignment = abap_true ).
  ENDMETHOD.

  METHOD request_created.
    rs_result-request = is_request.
    rs_result-return_code = 0.
  ENDMETHOD.

  METHOD request_saved_async.
    TRY.
        TRY.
            cl_bgmc_process_factory=>get_default(
              )->create(
              )->set_name( 'MDG BP request outbound'
              )->set_operation( NEW zcl_mdg_send_api_op( iv_request_uuid = iv_request_uuid )
              )->save_for_execution( ).

          CATCH cx_bgmc INTO DATA(bgmc_error).
            TRY.
                DATA(log) = cl_bali_log=>create_with_header(
                  header = cl_bali_header_setter=>create(
                    object      = 'ZMDG'
                    subobject   = 'INTEGRATION'
                    external_id = 'MDG BP request outbound'
                  )
                ).

                log->add_item(
                  item = cl_bali_exception_setter=>create(
                    severity  = if_bali_constants=>c_severity_error
                    exception = bgmc_error
                  )
                ).

                log->add_item(
                  item = cl_bali_free_text_setter=>create(
                    severity = if_bali_constants=>c_severity_error
                    text     = 'BGPF scheduling for MDG BP request outbound failed.'
                  )
                ).

                cl_bali_log_db=>get_instance( )->save_log( log = log ).

              CATCH cx_bali_runtime.
                " Never block the RAP save if application logging is unavailable.
            ENDTRY.
        ENDTRY.

      CATCH cx_root.
        " Outbound scheduling must not block the RAP save.
    ENDTRY.
  ENDMETHOD.

  METHOD check_mandatory_fields.
    LOOP AT it_field_control ASSIGNING FIELD-SYMBOL(<field_control>)
         WHERE entity_name = 'REQUEST'
           AND mandatory   = abap_true.

      DATA(component_name) = get_request_component_name( <field_control>-field_name ).
      IF component_name IS INITIAL.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT component_name OF STRUCTURE is_request TO FIELD-SYMBOL(<field_value>).
      IF sy-subrc <> 0 OR <field_value> IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      add_error(
        EXPORTING
          iv_field_name = CONV #( <field_control>-field_name )
          iv_text       = |Field { <field_control>-field_name } is required.|
        CHANGING
          ct_message    = ct_message
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_request_component_name.
    rv_component_name = SWITCH #(
      iv_field_name
      WHEN 'RequestUuid'           THEN 'REQUEST_UUID'
      WHEN 'RequestId'             THEN 'REQUEST_ID'
      WHEN 'RequestType'           THEN 'REQUEST_TYPE'
      WHEN 'ExternalSystem'        THEN 'EXTSYS'
      WHEN 'PartnerGid'            THEN 'PARTNER_GID'
      WHEN 'Status'                THEN 'STATUS'
      WHEN 'ParentGid1'            THEN 'PARENT_GID1'
      WHEN 'ParentGid2'            THEN 'PARENT_GID2'
      WHEN 'FoundDate'             THEN 'FOUND_DATE'
      WHEN 'Duns'                  THEN 'DUNS'
      WHEN 'LeiCode'               THEN 'LEI_CODE'
      WHEN 'Euid'                  THEN 'EUID'
      WHEN 'PartnerId'             THEN 'PARTNER_ID'
      WHEN 'BusinessPartnerType'   THEN 'TYPE'
      WHEN 'BusinessPartnerGroup'  THEN 'BU_GROUP'
      WHEN 'LegalForm'             THEN 'LEGAL_FORM'
      WHEN 'TelephoneNumber'       THEN 'TEL_NUMBER'
      WHEN 'MobileNumber'          THEN 'MOB_NUMBER'
      WHEN 'EmailAddress'          THEN 'SMTPADRESS'
      WHEN 'IsInactive'            THEN 'INACTIVE'
      WHEN 'InactiveReason'        THEN 'INACTIVE_REASON'
      WHEN 'Vendor'                THEN 'VENDOR'
      WHEN 'Customer'              THEN 'CUSTOMER'
      WHEN 'OrganizationName1'     THEN 'NAME_ORG1'
      WHEN 'OrganizationName2'     THEN 'NAME_ORG2'
      WHEN 'OrganizationName3'     THEN 'NAME_ORG3'
      WHEN 'OrganizationName4'     THEN 'NAME_ORG4'
      WHEN 'FirstName'             THEN 'NAME_FIRST'
      WHEN 'LastName'              THEN 'NAME_LAST'
      WHEN 'SearchTerm1'           THEN 'BU_SORT1'
      WHEN 'Street'                THEN 'STREET'
      WHEN 'HouseNumber'           THEN 'HOUSE_NUM1'
      WHEN 'HouseNumberSupplement' THEN 'HOUSE_NUM2'
      WHEN 'City'                  THEN 'CITY1'
      WHEN 'District'              THEN 'CITY2'
      WHEN 'PostalCode'            THEN 'POST_CODE1'
      WHEN 'Country'               THEN 'COUNTRY'
      WHEN 'OrganizationName'      THEN 'NAME_ORG'
      WHEN 'PersonName'            THEN 'NAME_PERSON'
      WHEN 'CreatedBy'             THEN 'CREATED_BY'
      WHEN 'CreatedAt'             THEN 'CREATED_AT'
      WHEN 'LastChangedBy'         THEN 'LAST_CHANGED_BY'
      WHEN 'LastChangedAt'         THEN 'LAST_CHANGED_AT'
      WHEN 'LocalLastChangedAt'    THEN 'LOCL_LAST_CHANGED_AT'
      ELSE ''
    ).
  ENDMETHOD.

  METHOD add_error.
    READ TABLE ct_message TRANSPORTING NO FIELDS
      WITH KEY field_name = iv_field_name.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    APPEND VALUE #(
      field_name = iv_field_name
      severity   = if_abap_behv_message=>severity-error
      text       = iv_text
    ) TO ct_message.
  ENDMETHOD.
ENDCLASS.

```

### ZCL_MDG_REQ_TITLE_VE
```abap
CLASS zcl_mdg_req_title_ve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit.
    INTERFACES if_sadl_exit_calc_element_read.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_virtual_property,
        ObjectPageTitle TYPE c LENGTH 20,
      END OF ty_virtual_property.

    CONSTANTS:
      c_request_id        TYPE string VALUE 'REQUESTID',
      c_object_page_title TYPE string VALUE 'OBJECTPAGETITLE'.
ENDCLASS.

CLASS zcl_mdg_req_title_ve IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<calc_element>).
      CASE <calc_element>.
        WHEN c_object_page_title.
          INSERT c_request_id INTO TABLE et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA records TYPE STANDARD TABLE OF zc_mdg_req WITH EMPTY KEY.
    DATA virtual_properties TYPE STANDARD TABLE OF ty_virtual_property WITH EMPTY KEY.
    DATA virtual_property TYPE ty_virtual_property.

    records = CORRESPONDING #( it_original_data ).

    LOOP AT records ASSIGNING FIELD-SYMBOL(<record>).
      CLEAR virtual_property.

      IF <record>-RequestId IS INITIAL OR <record>-RequestId = '0000000000'.
        IF sy-langu = 'C'.
          virtual_property-ObjectPageTitle = 'Nový požadavek'.
        ELSE.
          virtual_property-ObjectPageTitle = 'New request'.
        ENDIF.
      ELSE.
        virtual_property-ObjectPageTitle = <record>-RequestId.
      ENDIF.

      APPEND virtual_property TO virtual_properties.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( virtual_properties ).
  ENDMETHOD.
ENDCLASS.

```

### mdgcreaterequest/webapp/Component.ts
```typescript
/* eslint-disable @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-return */
sap.ui.define(
    ["sap/fe/core/AppComponent", "sap/m/MessageBox"],
    function (Component: any, MessageBox: any) {
        "use strict";

        return Component.extend("c4p.mdg.mdgcreaterequest.Component", {
            metadata: {
                manifest: "json"
            },

            init: function () {
                Component.prototype.init.apply(this, arguments);
                this._handleStartupCreateRequest();
            },

            _getStartupParameter: function (sParameterName: string): string | null {
                const oComponentData = this.getComponentData && this.getComponentData();
                const oStartupParameters = oComponentData && oComponentData.startupParameters;
                const vParameter = oStartupParameters && oStartupParameters[sParameterName];

                if (Array.isArray(vParameter)) {
                    return vParameter[0];
                }

                if (vParameter) {
                    return vParameter;
                }

                return new URLSearchParams(window.location.search).get(sParameterName) ||
                    new URLSearchParams(window.location.hash.split("?")[1] || "").get(sParameterName);
            },

            _handleStartupCreateRequest: function (): void {
                const sExternalSystem = this._getStartupParameter("ExternalSystem");
                const sPartnerGid = this._getStartupParameter("PartnerGID") ||
                    this._getStartupParameter("PartnerGid");

                if ((!sExternalSystem && !sPartnerGid) || this._bStartupCreateRequestHandled || window.location.hash.indexOf("&/Requests(") > -1) {
                    return;
                }

                this._bStartupCreateRequestHandled = true;

                this.getModel().getMetaModel().requestObject("/")
                    .then(function () {
                        return this._createRequest(sExternalSystem, sPartnerGid);
                    }.bind(this))
                    .catch(function (oError: Error) {
                        MessageBox.error(
                            this._getText("createRequestDraftFailed"),
                            {
                                details: oError && (oError.message || String(oError))
                            }
                        );
                    }.bind(this));
            },

            _getText: function (sKey: string): string {
                const oResourceBundle = this.getModel("i18n")?.getResourceBundle?.();

                return oResourceBundle?.getText?.(sKey) || sKey;
            },

            _createRequest: function (sExternalSystem?: string, sPartnerGid?: string): Promise<void> {
                return this._executeCreateRequest(sExternalSystem, sPartnerGid);
            },

            _executeCreateRequest: function (sExternalSystem?: string, sPartnerGid?: string): Promise<void> {
                const oModel = this.getModel();
                const oRequestsBinding = oModel.bindList("/Requests");
                const oOperation = oModel.bindContext(
                    "com.sap.gateway.srvd.zui_mdg_req.v0001.CreateRequest(...)",
                    oRequestsBinding.getHeaderContext()
                );

                oOperation.setParameter("ExternalSystem", sExternalSystem || "");
                oOperation.setParameter("PartnerGID", sPartnerGid || "");
                oOperation.setParameter("ResultIsActiveEntity", false);

                return oOperation.execute().then(function () {
                    const oContext = oOperation.getBoundContext();

                    if (!oContext) {
                        throw new Error("CreateRequest did not return a request context.");
                    }

                    return oContext.requestObject().then(function (oRequest: { RequestUuid?: string; IsActiveEntity?: boolean }) {
                        if (!oRequest || !oRequest.RequestUuid) {
                            throw new Error("CreateRequest did not return RequestUuid.");
                        }

                        this._navigateToRequestByKey(oRequest.RequestUuid, oRequest.IsActiveEntity);
                    }.bind(this));
                }.bind(this));
            },

            _navigateToRequestByKey: function (sRequestUuid: string, bIsActiveEntity?: boolean): void {
                this._navigateToRequest(
                    "/Requests(RequestUuid=" + sRequestUuid +
                    ",IsActiveEntity=" + (bIsActiveEntity === true ? "true" : "false") + ")"
                );
            },

            _navigateToRequest: function (sCanonicalPath: string): void {
                const sKeyPredicate = sCanonicalPath
                    .replace(/^\/Requests\(/, "")
                    .replace(/\)$/, "");
                const oRouter = this.getRouter && this.getRouter();

                if (oRouter) {
                    oRouter.navTo("RequestsObjectPage", {
                        key: sKeyPredicate
                    }, true);
                }
            }
        });
    }
);

```

### mdgcreaterequest/webapp/manifest.json
```json
{
  "_version": "1.73.1",
  "sap.app": {
    "id": "c4p.mdg.mdgcreaterequest",
    "type": "application",
    "i18n": {
      "bundleUrl": "i18n/i18n.properties",
      "supportedLocales": [
        "",
        "cs",
        "en"
      ]
    },
    "applicationVersion": {
      "version": "0.0.1"
    },
    "title": "{{appTitle}}",
    "description": "{{appDescription}}",
    "resources": "resources.json",
    "sourceTemplate": {
      "id": "@sap/generator-fiori:lrop",
      "version": "1.24.0",
      "toolsId": "258fdd40-f6a4-477d-94b5-fd6a8cdb5b5e"
    },
    "dataSources": {
      "annotation": {
        "type": "ODataAnnotation",
        "uri": "annotations/annotation.xml",
        "settings": {
          "localUri": "annotations/annotation.xml"
        }
      },
      "mainService": {
        "uri": "/sap/opu/odata4/sap/zui_mdg_req_o4/srvd/sap/zui_mdg_req/0001/",
        "type": "OData",
        "settings": {
          "annotations": [
            "annotation"
          ],
          "localUri": "localService/mainService/metadata.xml",
          "odataVersion": "4.0"
        }
      }
    },
    "crossNavigation": {
      "inbounds": {
        "MDGBpRequest-create": {
          "semanticObject": "MDGBpRequest",
          "action": "create",
          "title": "{{appTitle}}",
          "signature": {
            "parameters": {
              "ExternalSystem": {
                "required": false
              },
              "PartnerGID": {
                "required": false
              },
              "PartnerGid": {
                "required": false
              }
            },
            "additionalParameters": "allowed"
          }
        }
      }
    }
  },
  "sap.ui": {
    "technology": "UI5",
    "icons": {
      "icon": "",
      "favIcon": "",
      "phone": "",
      "phone@2": "",
      "tablet": "",
      "tablet@2": ""
    },
    "deviceTypes": {
      "desktop": true,
      "tablet": true,
      "phone": true
    }
  },
  "sap.ui5": {
    "flexEnabled": true,
    "dependencies": {
      "minUI5Version": "1.136.10",
      "libs": {
        "sap.m": {},
        "sap.f": {},
        "sap.ui.core": {},
        "sap.fe.templates": {}
      }
    },
    "rootView": {
      "viewName": "sap.fe.templates.RootContainer.view.Fcl",
      "type": "XML",
      "async": true,
      "id": "appRootView"
    },
    "contentDensities": {
      "compact": true,
      "cozy": false
    },
    "models": {
      "i18n": {
        "type": "sap.ui.model.resource.ResourceModel",
        "settings": {
          "bundleName": "c4p.mdg.mdgcreaterequest.i18n.i18n",
          "supportedLocales": [
            "",
            "cs",
            "en"
          ]
        }
      },
      "": {
        "dataSource": "mainService",
        "preload": true,
        "settings": {
          "operationMode": "Server",
          "autoExpandSelect": true,
          "earlyRequests": true
        }
      },
      "@i18n": {
        "type": "sap.ui.model.resource.ResourceModel",
        "uri": "i18n/i18n.properties",
        "settings": {
          "supportedLocales": [
            "",
            "cs",
            "en"
          ]
        }
      }
    },
    "resources": {
      "css": []
    },
    "routing": {
      "config": {
        "routerClass": "sap.f.routing.Router",
        "flexibleColumnLayout": {
          "defaultTwoColumnLayoutType": "TwoColumnsBeginExpanded",
          "defaultThreeColumnLayoutType": "ThreeColumnsMidExpanded"
        }
      },
      "routes": [
        {
          "pattern": ":?query:",
          "name": "RequestsList",
          "target": [
            "RequestsList"
          ]
        },
        {
          "pattern": "Requests({key}):?query:",
          "name": "RequestsObjectPage",
          "target": [
            "RequestsObjectPage"
          ]
        },
        {
          "pattern": "Requests({key})/_Address({key2}):?query:",
          "name": "AddressVariantsObjectPage",
          "target": [
            "RequestsObjectPage",
            "AddressVariantsObjectPage"
          ]
        },
        {
          "pattern": "Requests({key})/_Tax({key2}):?query:",
          "name": "TaxNumbersObjectPage",
          "target": [
            "RequestsObjectPage",
            "TaxNumbersObjectPage"
          ]
        }
      ],
      "targets": {
        "RequestsList": {
          "type": "Component",
          "id": "RequestsList",
          "name": "sap.fe.templates.ListReport",
          "controlAggregation": "beginColumnPages",
          "contextPattern": "",
          "options": {
            "settings": {
              "contextPath": "/Requests",
              "variantManagement": "Page",
              "navigation": {
                "Requests": {
                  "detail": {
                    "route": "RequestsObjectPage"
                  }
                }
              },
              "controlConfiguration": {
                "@com.sap.vocabularies.UI.v1.LineItem": {
                  "tableSettings": {
                    "type": "ResponsiveTable"
                  }
                }
              }
            }
          }
        },
        "RequestsObjectPage": {
          "type": "Component",
          "id": "RequestsObjectPage",
          "name": "sap.fe.templates.ObjectPage",
          "controlAggregation": "beginColumnPages",
          "contextPattern": "/Requests({key})",
          "options": {
            "settings": {
              "editableHeaderContent": false,
              "contextPath": "/Requests",
              "navigation": {
                "_Address": {
                  "detail": {
                    "route": "AddressVariantsObjectPage"
                  }
                },
                "_Tax": {
                  "detail": {
                    "route": "TaxNumbersObjectPage"
                  }
                }
              }
            }
          }
        },
        "AddressVariantsObjectPage": {
          "type": "Component",
          "id": "AddressVariantsObjectPage",
          "name": "sap.fe.templates.ObjectPage",
          "controlAggregation": "midColumnPages",
          "contextPattern": "/Requests({key})/_Address({key2})",
          "options": {
            "settings": {
              "editableHeaderContent": false,
              "contextPath": "/Requests/_Address",
              "showRelatedApps": false
            }
          }
        },
        "TaxNumbersObjectPage": {
          "type": "Component",
          "id": "TaxNumbersObjectPage",
          "name": "sap.fe.templates.ObjectPage",
          "controlAggregation": "midColumnPages",
          "contextPattern": "/Requests({key})/_Tax({key2})",
          "options": {
            "settings": {
              "editableHeaderContent": false,
              "contextPath": "/Requests/_Tax",
              "showRelatedApps": false
            }
          }
        }
      }
    },
    "flexBundle": false
  },
  "sap.fiori": {
    "registrationIds": [],
    "archeType": "transactional"
  },
  "sap.fe": {
    "app": {
      "enableLazyLoading": true
    }
  }
}
```

### mdgcreaterequest/webapp/annotations/annotation.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx" Version="4.0">
  <edmx:Reference Uri="https://sap.github.io/odata-vocabularies/vocabularies/Common.xml">
    <edmx:Include Namespace="com.sap.vocabularies.Common.v1" Alias="Common" />
  </edmx:Reference>
  <edmx:Reference Uri="https://sap.github.io/odata-vocabularies/vocabularies/UI.xml">
    <edmx:Include Namespace="com.sap.vocabularies.UI.v1" Alias="UI" />
  </edmx:Reference>
  <edmx:Reference Uri="/sap/opu/odata4/sap/zui_mdg_req_o4/srvd/sap/zui_mdg_req/0001/$metadata">
    <edmx:Include Namespace="com.sap.gateway.srvd.zui_mdg_req.v0001" Alias="SAP__self" />
  </edmx:Reference>
  <edmx:DataServices>
    <Schema xmlns="http://docs.oasis-open.org/odata/ns/edm" Namespace="local">
      <Annotations Target="SAP__self.CreateRequest(Collection(SAP__self.RequestsType))">
        <Annotation Term="Common.Label" String="{@i18n>create}" />
      </Annotations>
      <Annotations Target="SAP__self.CreateRequest(Collection(SAP__self.RequestsType))/ExternalSystem">
        <Annotation Term="Common.Label" String="{@i18n>externalSystem}" />
      </Annotations>
      <Annotations Target="SAP__self.CreateRequest(Collection(SAP__self.RequestsType))/PartnerGID">
        <Annotation Term="Common.Label" String="{@i18n>partnerGid}" />
      </Annotations>
      <Annotations Target="SAP__self.CreateRequest(Collection(SAP__self.RequestsType))/ResultIsActiveEntity">
        <Annotation Term="Common.Label" String="{@i18n>resultIsActiveEntity}" />
      </Annotations>
      <Annotations Target="SAP__self.TaxNumbersType">
        <Annotation Term="UI.LineItem">
          <Collection>
            <Record Type="UI.DataField">
              <PropertyValue Property="Label" String="{@i18n>taxType}" />
              <PropertyValue Property="Value" Path="TaxType" />
              <Annotation Term="Common.FieldControl" EnumMember="Common.FieldControlType/ReadOnly" />
            </Record>
            <Record Type="UI.DataField">
              <PropertyValue Property="Label" String="{@i18n>taxNumber}" />
              <PropertyValue Property="Value" Path="TaxNumber" />
              <Annotation Term="Common.FieldControl" EnumMember="Common.FieldControlType/ReadOnly" />
            </Record>
          </Collection>
        </Annotation>
      </Annotations>
      <Annotations Target="SAP__self.AddressVariantsType">
        <Annotation Term="UI.HeaderInfo">
          <Record Type="UI.HeaderInfoType">
            <PropertyValue Property="TypeName" String="{@i18n>addressVariant}" />
            <PropertyValue Property="TypeNamePlural" String="{@i18n>addressVariants}" />
            <PropertyValue Property="Title">
              <Record Type="UI.DataField">
                <PropertyValue Property="Value" Path="_NationText/NationText" />
              </Record>
            </PropertyValue>
            <PropertyValue Property="Description">
              <Record Type="UI.DataField">
                <PropertyValue Property="Value" Path="OrganizationName1" />
              </Record>
            </PropertyValue>
          </Record>
        </Annotation>
        <Annotation Term="UI.LineItem">
          <Collection>
            <Record Type="UI.DataField">
              <PropertyValue Property="Label" String="{@i18n>nation}" />
              <PropertyValue Property="Value" Path="Nation" />
              <Annotation Term="Common.FieldControl" EnumMember="Common.FieldControlType/ReadOnly" />
            </Record>
            <Record Type="UI.DataField">
              <PropertyValue Property="Label" String="{@i18n>companyName}" />
              <PropertyValue Property="Value" Path="OrganizationName1" />
              <Annotation Term="Common.FieldControl" EnumMember="Common.FieldControlType/ReadOnly" />
            </Record>
            <Record Type="UI.DataField">
              <PropertyValue Property="Label" String="{@i18n>country}" />
              <PropertyValue Property="Value" Path="Country" />
              <Annotation Term="Common.FieldControl" EnumMember="Common.FieldControlType/ReadOnly" />
            </Record>
            <Record Type="UI.DataField">
              <PropertyValue Property="Label" String="{@i18n>city}" />
              <PropertyValue Property="Value" Path="City" />
              <Annotation Term="Common.FieldControl" EnumMember="Common.FieldControlType/ReadOnly" />
            </Record>
            <Record Type="UI.DataField">
              <PropertyValue Property="Label" String="{@i18n>postalCode}" />
              <PropertyValue Property="Value" Path="PostalCode" />
              <Annotation Term="Common.FieldControl" EnumMember="Common.FieldControlType/ReadOnly" />
            </Record>
            <Record Type="UI.DataField">
              <PropertyValue Property="Label" String="{@i18n>street}" />
              <PropertyValue Property="Value" Path="Street" />
              <Annotation Term="Common.FieldControl" EnumMember="Common.FieldControlType/ReadOnly" />
            </Record>
            <Record Type="UI.DataField">
              <PropertyValue Property="Label" String="{@i18n>houseNo}" />
              <PropertyValue Property="Value" Path="HouseNumber" />
              <Annotation Term="Common.FieldControl" EnumMember="Common.FieldControlType/ReadOnly" />
            </Record>
            <Record Type="UI.DataField">
              <PropertyValue Property="Label" String="{@i18n>houseNoSuppl}" />
              <PropertyValue Property="Value" Path="HouseNumberSupplement" />
              <Annotation Term="Common.FieldControl" EnumMember="Common.FieldControlType/ReadOnly" />
            </Record>
          </Collection>
        </Annotation>
      </Annotations>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>
```

### mdgcreaterequest/webapp/i18n/i18n.properties
```properties
# This is the resource bundle for c4p.mdg.mdgcreaterequest

#Texts for manifest.json

#XTIT: Application name
appTitle=MDG Request

#YDES: Application description
appDescription=MDG Request

#XMSG: Startup create request error
createRequestDraftFailed=MDG request draft could not be created.

#XTIT: Request object names
bpRequest=MDG Request
bpRequests=MDG Requests

#XTIT: Object page sections
general=General
globalData=Global Data (KID)
mainData=Main Data
identificationData=Identification Data
countrySpecificDataDetail=Country Specific Data Detail
address=Address
addressVariants=Address Variants
additionalTaxData=Additional Tax Data
addressDetails=Address Details
taxNumberDetails=Tax Number Details

#XBUT: Create request action
create=Create

#XFLD: Field labels
requestId=Request ID
requestType=Request Type
requestOrigin=Request Origin
status=Status
createdBy=Created By
createdAt=Created At
partnerGid=Partner GID
parentGid1=Parent GID 1
parentGid2=Parent GID 2
foundDate=Found Date
leiCode=LEI Code
dunsNumber=DUNS Number
euid=EUID
partnerGroup=Partner Group
partnerId=Partner ID
partnerCategory=Partner Category
legalForm=Legal Form
telephoneNo=Telephone No
mobileTelNo=Mobile Tel. No
emailAddress=E-mail Address
vendor=Vendor
customer=Customer
inactive=Inactive
inactiveReason=Inactive Reason
companyName=Company Name
searchTerm=Search Term
country=Country
district=District
city=City
postalCode=Postal Code
street=Street
houseNo=House No
houseNoSuppl=House No Suppl.
addressVariant=Address Variant
nation=Nation
taxNumber=Tax Number
taxNumbers=Tax Numbers
taxType=Tax Type
externalSystem=External System
resultIsActiveEntity=Result Is Active Entity

```

### mdgcreaterequest/webapp/i18n/i18n_en.properties
```properties
# This is the resource bundle for c4p.mdg.mdgcreaterequest

#Texts for manifest.json

#XTIT: Application name
appTitle=MDG Request

#YDES: Application description
appDescription=MDG Request

#XMSG: Startup create request error
createRequestDraftFailed=MDG request draft could not be created.

#XTIT: Request object names
bpRequest=MDG Request
bpRequests=MDG Requests

#XTIT: Object page sections
general=General
globalData=Global Data (KID)
mainData=Main Data
identificationData=Identification Data
countrySpecificDataDetail=Country Specific Data Detail
address=Address
addressVariants=Address Variants
additionalTaxData=Tax Data
addressDetails=Address Details
taxNumberDetails=Tax Number Details

#XBUT: Create request action
create=Create

#XFLD: Field labels
requestId=Request ID
requestType=Request Type
requestOrigin=Requesting Country
status=Status
createdBy=Created By
createdAt=Created At
partnerGid=Partner GID
parentGid1=Parent GID 1
parentGid2=Parent GID 2
foundDate=Found Date
leiCode=LEI Code
dunsNumber=DUNS Number
euid=EUID
partnerGroup=Partner Group
partnerId=Partner ID
partnerCategory=Partner Category
legalForm=Legal Form
telephoneNo=Telephone No
mobileTelNo=Mobile Tel. No
emailAddress=E-mail Address
vendor=Vendor
customer=Customer
inactive=Inactive
inactiveReason=Inactive Reason
companyName=Company Name
searchTerm=Search Term
country=Country
district=District
city=City
postalCode=Postal Code
street=Street
houseNo=House No
houseNoSuppl=House No Suppl.
addressVariant=Address Variant
nation=Nation
taxNumber=Tax Number
taxNumbers=Tax Numbers
taxType=Tax Type
externalSystem=Country/Region
resultIsActiveEntity=Result Is Active Entity

```

### mdgcreaterequest/webapp/i18n/i18n_cs.properties
```properties
# This is the resource bundle for c4p.mdg.mdgcreaterequest

#Texts for manifest.json

#XTIT: Application name
appTitle=MDG poĹľadavek

#YDES: Application description
appDescription=MDG poĹľadavek

#XMSG: Startup create request error
createRequestDraftFailed=Draft MDG poĹľadavku se nepodaĹ™ilo vytvoĹ™it.

#XTIT: Request object names
bpRequest=MDG poĹľadavek
bpRequests=MDG poĹľadavky

#XTIT: Object page sections
general=VĹˇeobecnĂ©
globalData=GlobĂˇlnĂ­ data (KID)
mainData=HlavnĂ­ data
identificationData=IdentifikaÄŤnĂ­ data
countrySpecificDataDetail=Detail dat pro danou zemi
address=Adresa
addressVariants=Varianty adres
additionalTaxData=DaĹovĂˇ data
addressDetails=Detaily adresy
taxNumberDetails=Detaily daĹovĂ©ho ÄŤĂ­sla

#XBUT: Create request action
create=VytvoĹ™it

#XFLD: Field labels
requestId=ID poĹľadavku
requestType=Typ poĹľadavku
requestOrigin=Ĺ˝ĂˇdajĂ­cĂ­ zemÄ›
status=Status
createdBy=VytvoĹ™il
createdAt=VytvoĹ™eno
partnerGid=Partner GID
parentGid1=NadĹ™azenĂ˝ GID 1
parentGid2=NadĹ™azenĂ˝ GID 2
foundDate=Datum zaloĹľenĂ­
leiCode=LEI kĂłd
dunsNumber=ÄŚĂ­slo D-U-N-S
euid=EUID
partnerGroup=Skupina partnera
partnerId=ID partnera
partnerCategory=Kategorie partnera
legalForm=PrĂˇvnĂ­ forma
telephoneNo=Telefon
mobileTelNo=MobilnĂ­ telefon
emailAddress=E-mailovĂˇ adresa
vendor=Dodavatel
customer=ZĂˇkaznĂ­k
inactive=NeaktivnĂ­
inactiveReason=DĹŻvod neaktivity
companyName=NĂˇzev organizace
searchTerm=HledanĂ˝ vĂ˝raz 1
country=KlĂ­ÄŤ stĂˇtu/regionu
district=MĂ­stnĂ­ ÄŤĂˇst
city=MÄ›sto
postalCode=PSÄŚ
street=Ulice
houseNo=ÄŚĂ­slo domu
houseNoSuppl=Dodatek
addressVariant=Varianta adresy
nation=Text verze
taxNumber=DaĹovĂ© ÄŤĂ­slo
taxNumbers=DaĹovĂˇ ÄŤĂ­sla
taxType=Typ danÄ›
externalSystem=ZemÄ›/Region
resultIsActiveEntity=VĂ˝sledek je aktivnĂ­

```

### mdgcreaterequest/package.json
```json
{
  "name": "mdgcreaterequest",
  "version": "0.0.1",
  "description": "MDG request - create BP",
  "keywords": [
    "ui5",
    "openui5",
    "sapui5"
  ],
  "main": "webapp/index.html",
  "dependencies": {},
  "devDependencies": {
    "@sap-ux/eslint-plugin-fiori-tools": "10.2.1",
    "@sap-ux/ui5-middleware-fe-mockserver": "2",
    "@sap/ux-ui5-tooling": "1",
    "@sapui5/types": "1.136.10",
    "@ui5/cli": "^4.0.33",
    "eslint": "10.4.0",
    "typescript": "^5.9.3",
    "typescript-eslint": "8.59.4",
    "ui5-tooling-transpile": "^3.7.5"
  },
  "scripts": {
    "start": "fiori run --port 8080 --open \"test/flp.html#app-preview\"",
    "start-local": "fiori run --config ./ui5-local.yaml --port 8080 --open \"test/flp.html#app-preview\"",
    "build": "ui5 build --config=ui5.yaml --clean-dest --dest dist",
    "typecheck": "tsc --noEmit",
    "lint": "eslint ./",
    "start-mock": "fiori run --config ./ui5-mock.yaml --open \"test/flp.html#app-preview\"",
    "deploy": "fiori verify",
    "deploy-config": "fiori add deploy-config",
    "start-noflp": "fiori run --open \"/index.html?sap-ui-xx-viewCache=false\"",
    "int-test": "fiori run --config ./ui5-mock.yaml --open \"/test/integration/opaTests.qunit.html\"",
    "start-variants-management": "fiori run --open \"/preview.html#app-preview\""
  },
  "sapuxLayer": "CUSTOMER_BASE",
  "sapux": true
}

```

### mdgcreaterequest/tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "lib": [
      "ES2022",
      "DOM"
    ],
    "types": [
      "@sapui5/types"
    ],
    "allowJs": false,
    "checkJs": false,
    "strict": false,
    "noEmit": true,
    "skipLibCheck": true,
    "paths": {
      "c4p/mdg/mdgcreaterequest/*": [
        "./webapp/*"
      ]
    }
  },
  "include": [
    "webapp/**/*.ts"
  ],
  "exclude": [
    "dist",
    "node_modules",
    "webapp/test"
  ]
}

```

### mdgcreaterequest/ui5.yaml
```yaml
# yaml-language-server: $schema=https://sap.github.io/ui5-tooling/schema/ui5.yaml.json

specVersion: "4.0"
metadata:
  name: c4p.mdg.mdgcreaterequest
type: application
builder:
  customTasks:
    - name: ui5-tooling-transpile-task
      afterTask: replaceVersion
server:
  customMiddleware:
    - name: ui5-tooling-transpile-middleware
      afterMiddleware: compression
    - name: fiori-tools-proxy
      afterMiddleware: compression
      configuration:
        ignoreCertErrors: false # If set to true, certificate errors will be ignored. E.g. self-signed certificates will be accepted
        ui5:
          path:
            - /resources
            - /test-resources
          url: https://ui5.sap.com
        backend:
          - path: /sap
            url: https://hsr.con4pas.cz
            client: '140'
    - name: fiori-tools-appreload
      afterMiddleware: compression
      configuration:
        port: 35729
        path: webapp
        delay: 300
    - name: fiori-tools-preview
      afterMiddleware: fiori-tools-appreload
      configuration:
        flp:
          theme: sap_horizon

```

### mdgcreaterequest/ui5-local.yaml
```yaml
# yaml-language-server: $schema=https://sap.github.io/ui5-tooling/schema/ui5.yaml.json

specVersion: "4.0"
metadata:
  name: c4p.mdg.mdgcreaterequest
type: application
builder:
  customTasks:
    - name: ui5-tooling-transpile-task
      afterTask: replaceVersion
framework:
  name: SAPUI5
  version: 1.136.10
  libraries:
    - name: sap.m
    - name: sap.ui.core
    - name: sap.fe.templates
    - name: sap.ushell
    - name: themelib_sap_horizon
server:
  customMiddleware:
    - name: ui5-tooling-transpile-middleware
      afterMiddleware: compression
    - name: fiori-tools-appreload
      afterMiddleware: compression
      configuration:
        port: 35729
        path: webapp
        delay: 300
    - name: fiori-tools-preview
      afterMiddleware: fiori-tools-appreload
      configuration:
        flp:
          theme: sap_horizon
    - name: fiori-tools-proxy
      afterMiddleware: compression
      configuration:
        ignoreCertErrors: true # Local development: allow backend certificates not trusted by Node.js
        backend:
          - path: /sap
            url: https://hsr.con4pas.cz
            client: '140'

```

### mdgcreaterequest/ui5-mock.yaml
```yaml
# yaml-language-server: $schema=https://sap.github.io/ui5-tooling/schema/ui5.yaml.json

specVersion: "4.0"
metadata:
  name: c4p.mdg.mdgcreaterequest
type: application
builder:
  customTasks:
    - name: ui5-tooling-transpile-task
      afterTask: replaceVersion
server:
  customMiddleware:
    - name: ui5-tooling-transpile-middleware
      afterMiddleware: compression
    - name: fiori-tools-proxy
      afterMiddleware: compression
      configuration:
        ignoreCertErrors: false # If set to true, certificate errors will be ignored. E.g. self-signed certificates will be accepted
        ui5:
          path:
            - /resources
            - /test-resources
          url: https://ui5.sap.com
        backend:
          - path: /sap
            url: https://hsr.con4pas.cz
            client: '140'
    - name: fiori-tools-appreload
      afterMiddleware: compression
      configuration:
        port: 35729
        path: webapp
        delay: 300
    - name: fiori-tools-preview
      afterMiddleware: fiori-tools-appreload
      configuration:
        flp:
          theme: sap_horizon
    - name: sap-fe-mockserver
      beforeMiddleware: csp
      configuration:
        mountPath: /
        services:
          - urlPath: /sap/opu/odata4/sap/zui_mdg_req_o4/srvd/sap/zui_mdg_req/0001
            metadataPath: ./webapp/localService/mainService/metadata.xml
            mockdataPath: ./webapp/localService/mainService/data
            generateMockData: true
            resolveExternalServiceReferences: true
        annotations: []

```

### mdgcreaterequest/eslint.config.mjs
```javascript
import fioriTools from '@sap-ux/eslint-plugin-fiori-tools';
import tseslint from 'typescript-eslint';

export default [
    {
        ignores: [
            'dist/**',
            'node_modules/**'
        ]
    },
    ...fioriTools.configs.recommended,
    {
        files: [
            '**/*.ts'
        ],
        languageOptions: {
            parser: tseslint.parser
        }
    }
];

```

### mdgcreaterequest/webapp/index.html
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>MDG Request</title>
    <style>
        html, body, body > div, #container, #container-uiarea {
            height: 100%;
        }
    </style>
    <script
        id="sap-ui-bootstrap"
        src="resources/sap-ui-core.js"
        data-sap-ui-theme="sap_horizon"
        data-sap-ui-resource-roots='{
            "c4p.mdg.mdgcreaterequest": "./"
        }'
        data-sap-ui-on-init="module:sap/ui/core/ComponentSupport"
        data-sap-ui-compat-version="edge"
        data-sap-ui-async="true"
        data-sap-ui-frame-options="trusted"
    ></script>
</head>
<body class="sapUiBody sapUiSizeCompact" id="content">
    <div
        data-sap-ui-component
        data-name="c4p.mdg.mdgcreaterequest"
        data-id="container"
        data-settings='{"id" : "c4p.mdg.mdgcreaterequest"}'
        data-handle-validation="true"
    ></div>
</body>
</html>
```

### mdgcreaterequest/.appGenInfo.json
```json
{
  "generationParameters": {
    "generationDate": "Mon Jun 01 2026 09:42:21 GMT+0200 (Central European Summer Time)",
    "generatorPlatform": "Visual Studio Code",
    "serviceType": "SAP System (ABAP On-Premise)",
    "metadataFilename": "",
    "serviceUrl": "https://hsr.con4pas.cz/sap/opu/odata4/sap/zui_mdg_req_o4/srvd/sap/zui_mdg_req/0001/",
    "appName": "mdgcreaterequest",
    "appTitle": "MDG request - create BP",
    "appDescription": "MDG request - create BP",
    "appNamespace": "c4p.mdg",
    "ui5Theme": "sap_horizon",
    "ui5Version": "1.136.10",
    "enableEslint": true,
    "enableTypeScript": false,
    "showMockDataInfo": true,
    "generatorVersion": "1.24.0",
    "template": "List Report Page V4",
    "generatorName": "SAP Fiori Application Generator",
    "entityRelatedConfig": [
      {
        "type": "Main Entity",
        "value": "Requests"
      },
      {
        "type": "Navigation Entity",
        "value": "None"
      }
    ],
    "launchText": "To launch the generated application, run the following from the generated application root folder:\n\n```\n    npm start\n```",
    "valueHelpDownloaded": true
  }
}

```



### ZI_MDG_COUNTRY_TEXT.ddls
```abap
@EndUserText.label: 'MDG Country Text'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@VDM.viewType: #BASIC
@ObjectModel.dataCategory: #TEXT
define view entity ZI_MDG_COUNTRY_TEXT
  as select from t005t
{
      @Semantics.language: true
  key spras as Language,
  key land1 as Country,

      @Semantics.text: true
      landx as CountryName
}

```

### ZI_MDG_NATION_TEXT.ddls
```abap
@EndUserText.label: 'MDG Nation Text'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.dataCategory: #TEXT
define view entity ZI_MDG_NATION_TEXT
  as select from zmdg_c_nationt
{
      @Semantics.language: true
  key langu       as Language,
  key nation      as Nation,
      @Semantics.text: true
      nation_text as NationText
}



```

### ZI_MDG_TAX_TYPE_TEXT.ddls
```abap
@EndUserText.label: 'MDG Tax Type Text'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.dataCategory: #TEXT
define view entity ZI_MDG_TAX_TYPE_TEXT
  as select from tfktaxnumtype_t
{
      @Semantics.language: true
  key spras   as Language,
  key taxtype as TaxType,
      @Semantics.text: true
      text    as TaxTypeText
}



```







