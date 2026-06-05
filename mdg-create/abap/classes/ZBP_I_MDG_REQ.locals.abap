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
          RequestUuid RequestType ExternalSystem BusinessPartnerGroup Status
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
    DATA key_index        TYPE i.
    DATA partner_gid      TYPE zmdg_partner_gid.
    DATA external_system  TYPE zmdg_extsys.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      key_index += 1.

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
          INTO TABLE @addresses.

        SELECT *
          FROM zmdg_bptax
          WHERE partner_gid = @partner_gid
          INTO TABLE @tax_numbers.

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

      IF addresses IS NOT INITIAL.
        APPEND VALUE #(
          %cid_ref = <key>-%cid
          %target  = VALUE #(
            FOR address IN addresses INDEX INTO address_index
            ( %cid                  = |ADR{ key_index }_{ address_index }|
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

      IF tax_numbers IS NOT INITIAL.
        APPEND VALUE #(
          %cid_ref = <key>-%cid
          %target  = VALUE #(
            FOR tax_number IN tax_numbers INDEX INTO tax_index
            ( %cid      = |TAX{ key_index }_{ tax_index }|
              %is_draft = if_abap_behv=>mk-on
              TaxType   = tax_number-taxtype
              TaxNumber = tax_number-taxnum )
          )
        ) TO create_taxes.
      ENDIF.
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
        CREATE BY \_Address FIELDS (
          Nation OrganizationName1 OrganizationName2 OrganizationName3 OrganizationName4
          FirstName LastName SearchTerm1 Street HouseNumber HouseNumberSupplement
          City District PostalCode Country OrganizationName PersonName
        )
        WITH create_addresses
        CREATE BY \_Tax FIELDS ( TaxType TaxNumber )
        WITH create_taxes
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
