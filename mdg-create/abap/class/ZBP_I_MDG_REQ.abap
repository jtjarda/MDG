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

    METHODS createforsystem FOR MODIFY
      IMPORTING keys FOR ACTION Request~CreateForSystem.

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

  METHOD createforsystem.

    MODIFY ENTITIES OF zi_mdg_req IN LOCAL MODE
      ENTITY Request
        CREATE FIELDS ( ExternalSystem Status CreatedBy )
        WITH VALUE #(
          FOR key IN keys
          ( %cid           = key-%cid
            ExternalSystem = key-%param-ExternalSystem
            Status         = 'DRA'
            CreatedBy      = sy-uname )
        )
      MAPPED DATA(ls_mapped)
      FAILED failed
      REPORTED reported.

    mapped-request = ls_mapped-request.

  ENDMETHOD.

ENDCLASS.
