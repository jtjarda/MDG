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
