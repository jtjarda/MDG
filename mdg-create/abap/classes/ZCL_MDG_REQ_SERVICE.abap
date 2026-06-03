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
    IF is_request-request_type IS INITIAL OR is_request-request_type <> 'C'.
      add_error(
        EXPORTING
          iv_field_name = 'RequestType'
          iv_text       = 'Request type must be C.'
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
