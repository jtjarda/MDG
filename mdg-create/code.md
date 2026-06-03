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

## Behavior Definitions

### ZI_MDG_REQ_CREATE_P.ddls

```abap
@EndUserText.label: 'Create BP Request Parameters'
define abstract entity ZI_MDG_REQ_CREATE_P
{
  @EndUserText.label: 'External System'
  @Consumption.valueHelpDefinition: [
    {
      entity: { name: 'ZI_MDG_C_SYS_CREATEVH', element: 'ExternalSystem' }
    }
  ]
  ExternalSystem : zmdg_extsys;
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
  delete;

  static factory action CreateForSystem parameter ZI_MDG_REQ_CREATE_P [1];

  field ( readonly, numbering : managed ) RequestUuid;
  field ( readonly ) RequestId;
  field ( readonly ) RequestType, PartnerId, Vendor, Customer, ExternalSystem, PartnerGID;
  field ( readonly ) CreatedBy, CreatedAt, LastChangedBy, LastChangedAt, LocalLastChangedAt;
  field ( mandatory ) OrganizationName1, SearchTerm1, Country, City, PostalCode, Street;

  draft action Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare
  {
    validation ValidateRequest;
  }

  determination CalculateRequestId on save { create; }
  validation ValidateRequest on save { create; update; }

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
  use update;
  use delete;

  use action CreateForSystem;

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

    CLASS-METHODS request_created
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_result)  TYPE ty_save_result.

    CLASS-METHODS request_saved_async
      IMPORTING iv_request_uuid TYPE sysuuid_x16.

  PRIVATE SECTION.
    CLASS-METHODS add_error
      IMPORTING
        iv_field_name TYPE string
        iv_text       TYPE string
      CHANGING
        ct_message    TYPE tt_message.
ENDCLASS.

CLASS zcl_mdg_req_service IMPLEMENTATION.
  METHOD check_request.
    " See file abap/classes/ZCL_MDG_REQ_SERVICE.abap for full implementation.
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

  METHOD add_error.
    APPEND VALUE #(
      field_name = iv_field_name
      severity   = if_abap_behv_message=>severity-error
      text       = iv_text
    ) TO ct_message.
  ENDMETHOD.
ENDCLASS.
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

    METHODS calculate_request_id FOR DETERMINE ON SAVE
      IMPORTING keys FOR request~CalculateRequestId.

    METHODS validate_request FOR VALIDATE ON SAVE
      IMPORTING keys FOR request~ValidateRequest.

    METHODS create_for_system FOR MODIFY
      IMPORTING keys FOR ACTION request~CreateForSystem.
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

  METHOD calculate_request_id.
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
      ) TO update_requests.
    ENDLOOP.

    IF update_requests IS NOT INITIAL.
      MODIFY ENTITIES OF zi_mdg_req IN LOCAL MODE
        ENTITY Request
          UPDATE FIELDS ( RequestId )
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

  METHOD create_for_system.
    MODIFY ENTITIES OF zi_mdg_req IN LOCAL MODE
      ENTITY Request
        CREATE FIELDS ( RequestType ExternalSystem Status CreatedBy )
        WITH VALUE #(
          FOR key IN keys
          ( %cid           = key-%cid
            %is_draft      = if_abap_behv=>mk-on
            RequestType    = 'C'
            ExternalSystem = key-%param-ExternalSystem
            Status         = 'DRA'
            CreatedBy      = cl_abap_context_info=>get_user_technical_name( ) )
        )
      MAPPED mapped
      FAILED failed
      REPORTED reported.
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
        is_request     TYPE zmdg_req
      RETURNING
        VALUE(rv_json) TYPE string.

    METHODS send_payload
      IMPORTING
        iv_json TYPE string
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

## Service Definition

### ZUI_MDG_REQ.srvd

```abap
@EndUserText.label: 'MDG: Create BP Request'
define service ZUI_MDG_REQ {
  expose ZC_MDG_REQ                as Requests;
  expose ZC_MDG_REQADR             as AddressVariants;
  expose ZC_MDG_REQTAX             as TaxNumbers;
  expose ZI_MDG_C_SYS              as ConnectedSystems;
  expose ZI_MDG_C_SYS_CREATEVH     as CreateSystems;
  expose ZI_MDG_USER               as Users;
  expose ZI_MDG_DOMAIN_VALUE_TEXT  as DomainValueTexts;
}
```

## Fiori App Cross-App Startup

Generated UI project:

```text
C:\Users\JTikal\Documents\MDG\mdg-create\mdgcreaterequest
```

Inbound used by `mdg-search`:

```text
Semantic Object: MDGBpRequest
Action:          create
Parameter:       ExternalSystem
```

`webapp/manifest.json` contains:

```json
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
          }
        },
        "additionalParameters": "allowed"
      }
    }
  }
}
```

`webapp/Component.js` reads the startup parameter and invokes the RAP factory action:

```js
var oRequestsBinding = oModel.bindList("/Requests");
var oOperation = oModel.bindContext(
  "com.sap.gateway.srvd.zui_mdg_req.v0001.CreateForSystem(...)",
  oRequestsBinding.getHeaderContext()
);

oOperation.setParameter("ExternalSystem", sExternalSystem);
oOperation.setParameter("ResultIsActiveEntity", false);
```

After the action returns the draft request data, the app navigates to the draft Object Page by using the returned `RequestUuid` and `IsActiveEntity`.

Local test URL:

```text
test/flp.html#app-preview?ExternalSystem=S4HCLNT140
```


## Metadata Extensions

### ZC_MDG_REQ_UI.ddlx

```abap
@Metadata.layer: #CUSTOMER
@UI.headerInfo: {
  typeName: 'BP Request',
  typeNamePlural: 'BP Requests',
  title: { type: #STANDARD, value: 'RequestId' },
  description: { type: #STANDARD, value: 'Status' }
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
      id: 'General',
      type: #COLLECTION,
      label: 'General',
      position: 10
    },
    {
      id: 'GlobalData',
      parentId: 'General',
      type: #FIELDGROUP_REFERENCE,
      label: 'Global Data',
      position: 10,
      targetQualifier: 'GlobalData'
    },
    {
      id: 'MainData',
      parentId: 'General',
      type: #FIELDGROUP_REFERENCE,
      label: 'Main Data',
      position: 20,
      targetQualifier: 'MainData'
    },
    {
      id: 'IdentificationData',
      parentId: 'General',
      type: #FIELDGROUP_REFERENCE,
      label: 'Identification Data',
      position: 30,
      targetQualifier: 'IdentificationData'
    },
    {
      id: 'CountrySpecificData',
      type: #FIELDGROUP_REFERENCE,
      label: 'Country Specific Data Detail',
      position: 20,
      targetQualifier: 'CountrySpecificData'
    },
    {
      id: 'Address',
      type: #FIELDGROUP_REFERENCE,
      label: 'Address',
      position: 30,
      targetQualifier: 'Address'
    },
    {
      id: 'AddressVariants',
      type: #LINEITEM_REFERENCE,
      label: 'Address Variants',
      position: 40,
      targetElement: '_Address'
    },
    {
      id: 'TaxNumbers',
      type: #LINEITEM_REFERENCE,
      label: 'Additional Tax Data',
      position: 50,
      targetElement: '_Tax'
    }
  ]

  @UI.lineItem: [
    {
      position: 5,
      type: #FOR_ACTION,
      dataAction: 'CreateForSystem',
      label: 'Create for System'
    },
    { position: 10, label: 'Request ID' }
  ]
  @UI.identification: [{ position: 10, label: 'Request ID' }]
  @UI.selectionField: [{ position: 10 }]
  RequestId;

  @UI.lineItem: [{ position: 20, label: 'Request Type' }]
  @UI.fieldGroup: [{ qualifier: 'GlobalData', position: 10, label: 'Request Type' }]
  @UI.selectionField: [{ position: 20 }]
  @UI.textArrangement: #TEXT_ONLY
  RequestType;

  @UI.lineItem: [{ position: 30, label: 'External System' }]
  @UI.fieldGroup: [{ qualifier: 'GlobalData', position: 20, label: 'External System' }]
  @UI.selectionField: [{ position: 30 }]
  @UI.textArrangement: #TEXT_ONLY
  ExternalSystem;

  @UI.lineItem: [{ position: 40, label: 'Status' }]
  @UI.fieldGroup: [{ qualifier: 'GlobalData', position: 30, label: 'Status' }]
  @UI.selectionField: [{ position: 40 }]
  Status;

  @UI.lineItem: [{ position: 50, label: 'Created By' }]
  @UI.fieldGroup: [{ qualifier: 'GlobalData', position: 40, label: 'Created By' }]
  @UI.textArrangement: #TEXT_ONLY
  CreatedBy;

  @UI.lineItem: [{ position: 60, label: 'Partner GID' }]
  @UI.fieldGroup: [{ qualifier: 'MainData', position: 10, label: 'Partner GID' }]
  PartnerGid;

  @UI.lineItem: [{ position: 70, label: 'DUNS Number' }]
  @UI.fieldGroup: [{ qualifier: 'IdentificationData', position: 30, label: 'DUNS Number' }]
  Duns;

  @UI.fieldGroup: [{ qualifier: 'GlobalData', position: 50, label: 'Created At' }]
  CreatedAt;

  @UI.fieldGroup: [{ qualifier: 'MainData', position: 20, label: 'Parent GID 1' }]
  ParentGid1;

  @UI.fieldGroup: [{ qualifier: 'MainData', position: 30, label: 'Parent GID 2' }]
  ParentGid2;

  @UI.fieldGroup: [{ qualifier: 'MainData', position: 40, label: 'Found Date' }]
  FoundDate;

  @UI.fieldGroup: [{ qualifier: 'IdentificationData', position: 10, label: 'Partner ID' }]
  PartnerId;

  @UI.fieldGroup: [{ qualifier: 'IdentificationData', position: 20, label: 'LEI Code' }]
  LeiCode;

  @UI.fieldGroup: [{ qualifier: 'IdentificationData', position: 40, label: 'EUID' }]
  Euid;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 10, label: 'Partner Group' }]
  BusinessPartnerGroup;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 20, label: 'Partner Category' }]
  BusinessPartnerType;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 30, label: 'Legal Form' }]
  LegalForm;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 40, label: 'Telephone No' }]
  TelephoneNumber;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 50, label: 'Mobile Tel. No' }]
  MobileNumber;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 60, label: 'E-mail Address' }]
  EmailAddress;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 70, label: 'Vendor' }]
  Vendor;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 80, label: 'Customer' }]
  Customer;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 90, label: 'Inactive' }]
  IsInactive;

  @UI.fieldGroup: [{ qualifier: 'CountrySpecificData', position: 100, label: 'Inactive Reason' }]
  InactiveReason;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 10, label: 'Company Name' }]
  OrganizationName1;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 20, label: 'Search Term' }]
  SearchTerm1;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 30, label: 'Country' }]
  Country;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 40, label: 'District' }]
  District;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 50, label: 'City' }]
  City;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 60, label: 'Postal Code' }]
  PostalCode;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 70, label: 'Street' }]
  Street;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 80, label: 'House No' }]
  HouseNumber;

  @UI.fieldGroup: [{ qualifier: 'Address', position: 90, label: 'House No Suppl.' }]
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

  @UI.lineItem: [{ position: 10, label: 'Nation' }]
  @UI.identification: [{ position: 10, label: 'Nation' }]
  Nation;

  @UI.lineItem: [{ position: 20, label: 'Company Name' }]
  @UI.identification: [{ position: 20, label: 'Company Name' }]
  OrganizationName1;

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

  @UI.lineItem: [{ position: 10, label: 'Tax Type' }]
  @UI.identification: [{ position: 10, label: 'Tax Type' }]
  TaxType;

  @UI.lineItem: [{ position: 20, label: 'Tax Number' }]
  @UI.identification: [{ position: 20, label: 'Tax Number' }]
  TaxNumber;
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
  key ExternalSystem,
      Description,
      SystemType,
      DefaultAlphabet
}
where IsCreateAllowed = 'X'

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
  association [0..1] to ZI_MDG_DOMAIN_VALUE_TEXT as _RequestTypeText
    on  _RequestTypeText.DomainName   = 'ZMDG_REQ_TYPE'
    and _RequestTypeText.Language     = $session.system_language
    and _RequestTypeText.DomainValue  = $projection.RequestType
  association [0..1] to ZI_MDG_C_SYS as _ConnectedSystem
    on _ConnectedSystem.ExternalSystem = $projection.ExternalSystem
  association [0..1] to ZI_MDG_USER as _CreatedByUser
    on _CreatedByUser.UserID = $projection.CreatedBy
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
      _ConnectedSystem,
      _CreatedByUser,
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

      _RequestTypeText,
      _ConnectedSystem,
      _CreatedByUser,
      _Address : redirected to composition child ZC_MDG_REQADR,
      _Tax     : redirected to composition child ZC_MDG_REQTAX
}

```


