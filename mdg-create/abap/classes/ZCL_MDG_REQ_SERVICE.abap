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

    CLASS-METHODS request_created
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_result)  TYPE ty_save_result.

  PRIVATE SECTION.
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

    IF is_request-name_org1 IS INITIAL.
      add_error(
        EXPORTING
          iv_field_name = 'OrganizationName1'
          iv_text       = 'Company name is required.'
        CHANGING
          ct_message    = rt_message
      ).
    ENDIF.

    IF is_request-bu_sort1 IS INITIAL.
      add_error(
        EXPORTING
          iv_field_name = 'SearchTerm1'
          iv_text       = 'Search term is required.'
        CHANGING
          ct_message    = rt_message
      ).
    ENDIF.

    IF is_request-country IS INITIAL.
      add_error(
        EXPORTING
          iv_field_name = 'Country'
          iv_text       = 'Country is required.'
        CHANGING
          ct_message    = rt_message
      ).
    ENDIF.

    IF is_request-city1 IS INITIAL.
      add_error(
        EXPORTING
          iv_field_name = 'City'
          iv_text       = 'City is required.'
        CHANGING
          ct_message    = rt_message
      ).
    ENDIF.

    IF is_request-post_code1 IS INITIAL.
      add_error(
        EXPORTING
          iv_field_name = 'PostalCode'
          iv_text       = 'Postal code is required.'
        CHANGING
          ct_message    = rt_message
      ).
    ENDIF.

    IF is_request-street IS INITIAL.
      add_error(
        EXPORTING
          iv_field_name = 'Street'
          iv_text       = 'Street is required.'
        CHANGING
          ct_message    = rt_message
      ).
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

  METHOD request_created.
    rs_result-request = is_request.
    rs_result-return_code = 0.
  ENDMETHOD.

  METHOD add_error.
    APPEND VALUE #(
      field_name = iv_field_name
      severity   = if_abap_behv_message=>severity-error
      text       = iv_text
    ) TO ct_message.
  ENDMETHOD.
ENDCLASS.
