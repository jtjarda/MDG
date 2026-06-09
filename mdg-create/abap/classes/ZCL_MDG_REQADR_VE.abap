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
        NationText  TYPE zmdg_c_nationt-nation_text,
        CountryName TYPE t005t-landx,
      END OF ty_virtual_property.

    CONSTANTS:
      c_nation       TYPE string VALUE 'NATION',
      c_nation_text  TYPE string VALUE 'NATIONTEXT',
      c_country      TYPE string VALUE 'COUNTRY',
      c_country_name TYPE string VALUE 'COUNTRYNAME'.
ENDCLASS.

CLASS zcl_mdg_reqadr_ve IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<calc_element>).
      CASE <calc_element>.
        WHEN c_nation_text.
          INSERT c_nation INTO TABLE et_requested_orig_elements.
        WHEN c_country_name.
          INSERT c_country INTO TABLE et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA records TYPE STANDARD TABLE OF zc_mdg_reqadr WITH EMPTY KEY.
    DATA virtual_properties TYPE STANDARD TABLE OF ty_virtual_property WITH EMPTY KEY.
    DATA virtual_property TYPE ty_virtual_property.

    TYPES:
      BEGIN OF ty_nation_text,
        nation      TYPE zmdg_c_nation-nation,
        nation_text TYPE zmdg_c_nationt-nation_text,
      END OF ty_nation_text,
      BEGIN OF ty_country_text,
        country     TYPE land1,
        countryName TYPE t005t-landx,
      END OF ty_country_text.

    DATA nation_texts TYPE HASHED TABLE OF ty_nation_text WITH UNIQUE KEY nation.
    DATA country_texts TYPE HASHED TABLE OF ty_country_text WITH UNIQUE KEY country.

    records = CORRESPONDING #( it_original_data ).

    IF records IS NOT INITIAL.
      SELECT nation,
             nation_text
        FROM zmdg_c_nationt
        FOR ALL ENTRIES IN @records
        WHERE nation = @records-Nation
          AND langu  = @sy-langu
        INTO TABLE @nation_texts.

      SELECT land1 AS country,
             landx AS countryName
        FROM t005t
        FOR ALL ENTRIES IN @records
        WHERE land1 = @records-Country
          AND spras = @sy-langu
        INTO TABLE @country_texts.
    ENDIF.

    LOOP AT records ASSIGNING FIELD-SYMBOL(<record>).
      CLEAR virtual_property.

      READ TABLE nation_texts ASSIGNING FIELD-SYMBOL(<nation_text>)
        WITH TABLE KEY nation = <record>-Nation.
      IF sy-subrc = 0.
        virtual_property-NationText = <nation_text>-nation_text.
      ENDIF.

      READ TABLE country_texts ASSIGNING FIELD-SYMBOL(<country_text>)
        WITH TABLE KEY country = <record>-Country.
      IF sy-subrc = 0.
        virtual_property-CountryName = <country_text>-countryName.
      ENDIF.

      APPEND virtual_property TO virtual_properties.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( virtual_properties ).
  ENDMETHOD.
ENDCLASS.
