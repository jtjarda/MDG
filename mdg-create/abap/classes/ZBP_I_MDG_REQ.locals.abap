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
      RESULT DATA(requests).

    LOOP AT requests ASSIGNING FIELD-SYMBOL(<request>)
         WHERE RequestId IS INITIAL
            OR RequestId = '0000000000'.

      DATA(save_result) = zcl_mdg_req_service=>save_request(
        VALUE #(
          request_uuid       = <request>-RequestUuid
          request_id         = <request>-RequestId
          request_type       = <request>-RequestType
          extsys             = <request>-ExternalSystem
          partner_gid        = <request>-PartnerGid
          status             = <request>-Status
          parent_gid1        = <request>-ParentGid1
          parent_gid2        = <request>-ParentGid2
          found_date         = <request>-FoundDate
          duns               = <request>-Duns
          lei_code           = <request>-LeiCode
          euid               = <request>-Euid
          partner_id         = <request>-PartnerId
          type               = <request>-BusinessPartnerType
          bu_group           = <request>-BusinessPartnerGroup
          legal_form         = <request>-LegalForm
          tel_number         = <request>-TelephoneNumber
          mob_number         = <request>-MobileNumber
          smtpadress         = <request>-EmailAddress
          inactive           = <request>-IsInactive
          inactive_reason    = <request>-InactiveReason
          vendor             = <request>-Vendor
          customer           = <request>-Customer
          name_org1          = <request>-OrganizationName1
          name_org2          = <request>-OrganizationName2
          name_org3          = <request>-OrganizationName3
          name_org4          = <request>-OrganizationName4
          name_first         = <request>-FirstName
          name_last          = <request>-LastName
          bu_sort1           = <request>-SearchTerm1
          country            = <request>-Country
          city2              = <request>-District
          city1              = <request>-City
          post_code1         = <request>-PostalCode
          street             = <request>-Street
          house_num1         = <request>-HouseNumber
          house_num2         = <request>-HouseNumberSupplement
          name_org           = <request>-OrganizationName
          name_person        = <request>-PersonName
          created_by         = <request>-CreatedBy
          created_at         = <request>-CreatedAt
          last_changed_by    = <request>-LastChangedBy
          last_changed_at    = <request>-LastChangedAt
        )
      ).

      LOOP AT save_result-messages ASSIGNING FIELD-SYMBOL(<message>) WHERE field_name = 'RequestId'.
        APPEND VALUE #(
          %tky = <request>-%tky
          %msg = new_message_with_text(
            severity = <message>-severity
            text     = <message>-text )
          %element-RequestId = if_abap_behv=>mk-on
        ) TO reported-request.
      ENDLOOP.

      IF save_result-messages IS NOT INITIAL
         OR save_result-request-request_id IS INITIAL.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zi_mdg_req IN LOCAL MODE
        ENTITY Request
          UPDATE FIELDS ( RequestId )
          WITH VALUE #(
            ( %tky      = <request>-%tky
              RequestId = save_result-request-request_id )
          ).
    ENDLOOP.
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
      DATA(request_context) = VALUE zcl_mdg_req_service=>ty_request(
        mandt              = sy-mandt
        request_uuid       = <request>-RequestUuid
        request_id         = <request>-RequestId
        request_type       = <request>-RequestType
        extsys             = <request>-ExternalSystem
        partner_gid        = <request>-PartnerGid
        status             = <request>-Status
        parent_gid1        = <request>-ParentGid1
        parent_gid2        = <request>-ParentGid2
        found_date         = <request>-FoundDate
        duns               = <request>-Duns
        lei_code           = <request>-LeiCode
        euid               = <request>-Euid
        partner_id         = <request>-PartnerId
        type               = <request>-BusinessPartnerType
        bu_group           = <request>-BusinessPartnerGroup
        legal_form         = <request>-LegalForm
        tel_number         = <request>-TelephoneNumber
        mob_number         = <request>-MobileNumber
        smtpadress         = <request>-EmailAddress
        inactive           = <request>-IsInactive
        inactive_reason    = <request>-InactiveReason
        vendor             = <request>-Vendor
        customer           = <request>-Customer
        name_org1          = <request>-OrganizationName1
        name_org2          = <request>-OrganizationName2
        name_org3          = <request>-OrganizationName3
        name_org4          = <request>-OrganizationName4
        name_first         = <request>-FirstName
        name_last          = <request>-LastName
        bu_sort1           = <request>-SearchTerm1
        country            = <request>-Country
        city2              = <request>-District
        city1              = <request>-City
        post_code1         = <request>-PostalCode
        street             = <request>-Street
        house_num1         = <request>-HouseNumber
        house_num2         = <request>-HouseNumberSupplement
        name_org           = <request>-OrganizationName
        name_person        = <request>-PersonName
        created_by         = <request>-CreatedBy
        created_at         = <request>-CreatedAt
        last_changed_by    = <request>-LastChangedBy
        last_changed_at    = <request>-LastChangedAt
      ).

      LOOP AT addresses ASSIGNING FIELD-SYMBOL(<address>) USING KEY entity WHERE RequestUuid = <request>-RequestUuid.
        APPEND VALUE #(
          mandt        = sy-mandt
          request_uuid = <address>-RequestUuid
          nation       = <address>-Nation
          name_org1    = <address>-OrganizationName1
          name_org2    = <address>-OrganizationName2
          name_org3    = <address>-OrganizationName3
          name_org4    = <address>-OrganizationName4
          name_first   = <address>-FirstName
          name_last    = <address>-LastName
          bu_sort1     = <address>-SearchTerm1
          street       = <address>-Street
          house_num1   = <address>-HouseNumber
          house_num2   = <address>-HouseNumberSupplement
          city1        = <address>-City
          city2        = <address>-District
          post_code1   = <address>-PostalCode
          country      = <address>-Country
          name_org     = <address>-OrganizationName
          name_person  = <address>-PersonName
        ) TO request_context-address.
      ENDLOOP.

      LOOP AT tax_numbers ASSIGNING FIELD-SYMBOL(<tax_number>) USING KEY entity WHERE RequestUuid = <request>-RequestUuid.
        APPEND VALUE #(
          mandt        = sy-mandt
          request_uuid = <tax_number>-RequestUuid
          taxtype      = <tax_number>-TaxType
          taxnum       = <tax_number>-TaxNumber
        ) TO request_context-tax.
      ENDLOOP.

      DATA(messages) = zcl_mdg_req_service=>check_request( request_context ).

      LOOP AT messages ASSIGNING FIELD-SYMBOL(<message>).
        APPEND VALUE #(
          %tky = <request>-%tky
          %msg = new_message_with_text(
            severity = <message>-severity
            text     = <message>-text )
          %element-RequestType        = COND #( WHEN <message>-field_name = 'RequestType' THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off )
          %element-ExternalSystem     = COND #( WHEN <message>-field_name = 'ExternalSystem' THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off )
          %element-Status             = COND #( WHEN <message>-field_name = 'Status' THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off )
          %element-OrganizationName1  = COND #( WHEN <message>-field_name = 'OrganizationName1' THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off )
          %element-SearchTerm1        = COND #( WHEN <message>-field_name = 'SearchTerm1' THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off )
          %element-Country            = COND #( WHEN <message>-field_name = 'Country' THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off )
          %element-City               = COND #( WHEN <message>-field_name = 'City' THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off )
          %element-PostalCode         = COND #( WHEN <message>-field_name = 'PostalCode' THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off )
          %element-Street             = COND #( WHEN <message>-field_name = 'Street' THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off )
        ) TO reported-request.
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
