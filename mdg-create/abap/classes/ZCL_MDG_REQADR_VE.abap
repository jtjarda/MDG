CLASS zcl_mdg_reqadr_ve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit.
    INTERFACES if_sadl_exit_calc_element_read.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_virtual_property,
        NationText TYPE c LENGTH 60,
      END OF ty_virtual_property.

    CONSTANTS:
      c_nation      TYPE string VALUE 'NATION',
      c_nation_text TYPE string VALUE 'NATIONTEXT'.
ENDCLASS.

CLASS zcl_mdg_reqadr_ve IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<calc_element>).
      CASE <calc_element>.
        WHEN c_nation_text.
          INSERT c_nation INTO TABLE et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA records TYPE STANDARD TABLE OF zc_mdg_reqadr WITH EMPTY KEY.
    DATA virtual_properties TYPE STANDARD TABLE OF ty_virtual_property WITH EMPTY KEY.
    DATA virtual_property TYPE ty_virtual_property.

    TYPES:
      BEGIN OF ty_nation_text,
        nation     TYPE tsadv-nation,
        nationText TYPE c LENGTH 60,
      END OF ty_nation_text.

    DATA nation_texts TYPE HASHED TABLE OF ty_nation_text WITH UNIQUE KEY nation.

    records = CORRESPONDING #( it_original_data ).

    IF records IS NOT INITIAL.
      SELECT nation,
             nation_tex AS nationText
        FROM tsadvt
        FOR ALL ENTRIES IN @records
        WHERE nation = @records-Nation
          AND langu  = @sy-langu
        INTO TABLE @nation_texts.
    ENDIF.

    LOOP AT records ASSIGNING FIELD-SYMBOL(<record>).
      CLEAR virtual_property.

      READ TABLE nation_texts ASSIGNING FIELD-SYMBOL(<nation_text>)
        WITH TABLE KEY nation = <record>-Nation.
      IF sy-subrc = 0.
        virtual_property-NationText = CONV #( <nation_text>-nationText ).
      ENDIF.

      APPEND virtual_property TO virtual_properties.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( virtual_properties ).
  ENDMETHOD.
ENDCLASS.
