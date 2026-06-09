CLASS zcl_mdg_req_title_ve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit.
    INTERFACES if_sadl_exit_calc_element_read.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_virtual_property,
        ObjectPageTitle TYPE c LENGTH 20,
      END OF ty_virtual_property.

    CONSTANTS:
      c_request_id        TYPE string VALUE 'REQUESTID',
      c_object_page_title TYPE string VALUE 'OBJECTPAGETITLE'.
ENDCLASS.

CLASS zcl_mdg_req_title_ve IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<calc_element>).
      CASE <calc_element>.
        WHEN c_object_page_title.
          INSERT c_request_id INTO TABLE et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA records TYPE STANDARD TABLE OF zc_mdg_req WITH EMPTY KEY.
    DATA virtual_properties TYPE STANDARD TABLE OF ty_virtual_property WITH EMPTY KEY.
    DATA virtual_property TYPE ty_virtual_property.

    records = CORRESPONDING #( it_original_data ).

    LOOP AT records ASSIGNING FIELD-SYMBOL(<record>).
      CLEAR virtual_property.

      IF <record>-RequestId IS INITIAL OR <record>-RequestId = '0000000000'.
        IF sy-langu = 'C'.
          virtual_property-ObjectPageTitle = 'Nový požadavek'.
        ELSE.
          virtual_property-ObjectPageTitle = 'New request'.
        ENDIF.
      ELSE.
        virtual_property-ObjectPageTitle = <record>-RequestId.
      ENDIF.

      APPEND virtual_property TO virtual_properties.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( virtual_properties ).
  ENDMETHOD.
ENDCLASS.
