CLASS zbp_i_mdg_req DEFINITION
  PUBLIC
  ABSTRACT
  FINAL
  FOR BEHAVIOR OF zi_mdg_req.

ENDCLASS.

CLASS zbp_i_mdg_req IMPLEMENTATION.

ENDCLASS.

CLASS lhc_Request DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
        REQUEST requested_authorizations FOR Request
      RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING
        keys REQUEST requested_authorizations FOR Request
      RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Request.

ENDCLASS.

CLASS lhc_Request IMPLEMENTATION.

  METHOD get_global_authorizations.

    result-%create = if_abap_behv=>auth-allowed.

  ENDMETHOD.

  METHOD get_instance_authorizations.

    result = VALUE #(
      FOR key IN keys
      ( %tky = key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed )
    ).

  ENDMETHOD.

  METHOD earlynumbering_create.

    LOOP AT entities INTO DATA(ls_entity).

      TRY.
          DATA(lv_request_id) = cl_system_uuid=>create_uuid_c32_static( ).
        CATCH cx_uuid_error.
          lv_request_id = sy-datum && sy-uzeit && '00000000000000'.
      ENDTRY.

      APPEND CORRESPONDING #( ls_entity ) TO mapped-request ASSIGNING FIELD-SYMBOL(<mapped>).
      <mapped>-RequestId = lv_request_id.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
