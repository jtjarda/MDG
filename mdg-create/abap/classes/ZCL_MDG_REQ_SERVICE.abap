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
