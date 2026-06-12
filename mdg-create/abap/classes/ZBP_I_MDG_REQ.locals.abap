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
          WHEN zcl_mdg_req_service=>is_editable_status( request-Status ) = abap_true
            THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized )
        %delete = COND #(
          WHEN zcl_mdg_req_service=>is_editable_status( request-Status ) = abap_true
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
        WHEN zcl_mdg_req_service=>is_editable_status( <request>-Status ) = abap_true
          THEN if_abap_behv=>fc-o-enabled
        ELSE if_abap_behv=>fc-o-disabled
      ).
      <features>-%delete = COND #(
        WHEN zcl_mdg_req_service=>is_editable_status( <request>-Status ) = abap_true
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
        Status    = zcl_mdg_req_service=>gc_status_in_process
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
    TYPES:
      BEGIN OF ty_create_context,
        cid     TYPE abp_behv_cid,
        request TYPE zcl_mdg_req_service=>ty_request,
      END OF ty_create_context.

    DATA create_requests  TYPE TABLE FOR CREATE zi_mdg_req.
    DATA create_addresses TYPE TABLE FOR CREATE zi_mdg_req\_Address.
    DATA create_taxes     TYPE TABLE FOR CREATE zi_mdg_req\_Tax.
    DATA create_contexts  TYPE STANDARD TABLE OF ty_create_context WITH EMPTY KEY.
    DATA partner_gid      TYPE zmdg_partner_gid.
    DATA external_system  TYPE zmdg_extsys.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      CLEAR:
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

      DATA(create_result) = zcl_mdg_req_service=>build_create_request(
        iv_external_system = external_system
        iv_partner_gid     = partner_gid
      ).

      LOOP AT create_result-messages ASSIGNING FIELD-SYMBOL(<create_message>).
        APPEND INITIAL LINE TO reported-request ASSIGNING FIELD-SYMBOL(<reported_create_request>).
        <reported_create_request>-%cid = <key>-%cid.
        <reported_create_request>-%msg = new_message_with_text(
          severity = <create_message>-severity
          text     = <create_message>-text
        ).

        ASSIGN COMPONENT <create_message>-field_name OF STRUCTURE <reported_create_request>-%element TO FIELD-SYMBOL(<create_element>).
        IF sy-subrc = 0.
          <create_element> = if_abap_behv=>mk-on.
        ENDIF.
      ENDLOOP.

      IF create_result-messages IS NOT INITIAL.
        APPEND VALUE #( %cid = <key>-%cid ) TO failed-request.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        cid     = <key>-%cid
        request = create_result-request
      ) TO create_contexts.

      APPEND VALUE #(
        %cid                  = <key>-%cid
        %is_draft             = if_abap_behv=>mk-on
        RequestType           = create_result-request-request_type
        ExternalSystem        = create_result-request-extsys
        PartnerGid            = create_result-request-partner_gid
        Status                = zcl_mdg_req_service=>gc_status_draft
        CreatedBy             = create_result-request-created_by
        ParentGid1            = create_result-request-parent_gid1
        ParentGid2            = create_result-request-parent_gid2
        FoundDate             = create_result-request-found_date
        Duns                  = create_result-request-duns
        LeiCode               = create_result-request-lei_code
        Euid                  = create_result-request-euid
        PartnerId             = create_result-request-partner_id
        BusinessPartnerType   = create_result-request-type
        BusinessPartnerGroup  = create_result-request-bu_group
        LegalForm             = create_result-request-legal_form
        TelephoneNumber       = create_result-request-tel_number
        MobileNumber          = create_result-request-mob_number
        EmailAddress          = create_result-request-smtpadress
        IsInactive            = create_result-request-inactive
        InactiveReason        = create_result-request-inactive_reason
        OrganizationName1     = create_result-request-name_org1
        OrganizationName2     = create_result-request-name_org2
        OrganizationName3     = create_result-request-name_org3
        OrganizationName4     = create_result-request-name_org4
        FirstName             = create_result-request-name_first
        LastName              = create_result-request-name_last
        SearchTerm1           = create_result-request-bu_sort1
        Country               = create_result-request-country
        District              = create_result-request-city2
        City                  = create_result-request-city1
        PostalCode            = create_result-request-post_code1
        Street                = create_result-request-street
        HouseNumber           = create_result-request-house_num1
        HouseNumberSupplement = create_result-request-house_num2
        OrganizationName      = create_result-request-name_org
        PersonName            = create_result-request-name_person
      ) TO create_requests.
    ENDLOOP.

    IF create_requests IS INITIAL.
      RETURN.
    ENDIF.

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
      LOOP AT mapped-request ASSIGNING FIELD-SYMBOL(<mapped_request>).
        READ TABLE create_contexts ASSIGNING FIELD-SYMBOL(<create_context>)
          WITH KEY cid = <mapped_request>-%cid.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF <create_context>-request-partner_gid IS INITIAL.
          CONTINUE.
        ENDIF.

        IF <create_context>-request-address IS NOT INITIAL.
          APPEND VALUE #(
            %tky    = <mapped_request>-%tky
            %target = VALUE #(
              FOR address IN <create_context>-request-address INDEX INTO address_index
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

        IF <create_context>-request-tax IS NOT INITIAL.
          APPEND VALUE #(
            %tky    = <mapped_request>-%tky
            %target = VALUE #(
              FOR tax_number IN <create_context>-request-tax INDEX INTO tax_index
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
