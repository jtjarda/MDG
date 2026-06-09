CLASS zcl_mdg_reqtax_ve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit.
    INTERFACES if_sadl_exit_calc_element_read.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_virtual_property,
        TaxTypeText TYPE tfktaxnumtype_t-text,
      END OF ty_virtual_property.

    CONSTANTS:
      c_tax_type      TYPE string VALUE 'TAXTYPE',
      c_tax_type_text TYPE string VALUE 'TAXTYPETEXT'.
ENDCLASS.

CLASS zcl_mdg_reqtax_ve IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<calc_element>).
      CASE <calc_element>.
        WHEN c_tax_type_text.
          INSERT c_tax_type INTO TABLE et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA records TYPE STANDARD TABLE OF zc_mdg_reqtax WITH EMPTY KEY.
    DATA virtual_properties TYPE STANDARD TABLE OF ty_virtual_property WITH EMPTY KEY.
    DATA virtual_property TYPE ty_virtual_property.

    TYPES:
      BEGIN OF ty_tax_type_text,
        taxType     TYPE tfktaxnumtype-taxtype,
        taxTypeText TYPE tfktaxnumtype_t-text,
      END OF ty_tax_type_text.

    DATA tax_type_texts TYPE HASHED TABLE OF ty_tax_type_text WITH UNIQUE KEY taxType.

    records = CORRESPONDING #( it_original_data ).

    IF records IS NOT INITIAL.
      SELECT taxtype AS taxType,
             text    AS taxTypeText
        FROM tfktaxnumtype_t
        FOR ALL ENTRIES IN @records
        WHERE taxtype = @records-TaxType
          AND spras   = @sy-langu
        INTO TABLE @tax_type_texts.
    ENDIF.

    LOOP AT records ASSIGNING FIELD-SYMBOL(<record>).
      CLEAR virtual_property.

      READ TABLE tax_type_texts ASSIGNING FIELD-SYMBOL(<tax_type_text>)
        WITH TABLE KEY taxType = <record>-TaxType.
      IF sy-subrc = 0.
        virtual_property-TaxTypeText = <tax_type_text>-taxTypeText.
      ENDIF.

      APPEND virtual_property TO virtual_properties.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( virtual_properties ).
  ENDMETHOD.
ENDCLASS.