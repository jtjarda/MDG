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
