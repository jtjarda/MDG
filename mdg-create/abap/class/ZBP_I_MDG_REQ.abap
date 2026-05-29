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

      DATA lv_request_id TYPE zmdg_request_id.

      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '01'
          object                  = 'ZMDG_REQ'
        IMPORTING
          number                  = lv_request_id
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      APPEND CORRESPONDING #( ls_entity ) TO mapped-request ASSIGNING FIELD-SYMBOL(<mapped>).
      <mapped>-RequestId = lv_request_id.

    ENDLOOP.

  ENDMETHOD.

  METHOD createforsystem.

    LOOP AT keys INTO DATA(ls_key).

      SELECT SINGLE @abap_true
        FROM zmdg_c_sys
        WHERE extsys = @ls_key-%param-ExternalSystem
          AND xcrea  = @abap_true
        INTO @DATA(lv_is_create_allowed).

      IF sy-subrc <> 0.
        APPEND VALUE #(
          %cid = ls_key-%cid
        ) TO failed-request.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zi_mdg_req IN LOCAL MODE
        ENTITY Request
          CREATE FIELDS ( RequestType ExternalSystem Status CreatedBy )
          WITH VALUE #(
            ( %cid           = ls_key-%cid
              RequestType    = 'C'
              ExternalSystem = ls_key-%param-ExternalSystem
              Status         = 'DRA'
              CreatedBy      = sy-uname )
          )
          CREATE BY \_Address
          FIELDS ( Nation OrganizationName1 SearchTerm1 )
          WITH VALUE #(
            ( %cid_ref = ls_key-%cid
              %target = VALUE #(
                ( %cid             = |{ ls_key-%cid }_ADR|
                  Nation           = ''
                  OrganizationName1 = ''
                  SearchTerm1      = '' )
              ) )
          )
        MAPPED DATA(ls_mapped)
        FAILED failed
        REPORTED reported.

      mapped-request = VALUE #( BASE mapped-request ( LINES OF ls_mapped-request ) ).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
