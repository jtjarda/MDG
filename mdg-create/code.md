# MDG Create - Working Code

Vychozi datovy model pro novou RAP aplikaci pozadavku na zalozeni BP.

Model pouziva technicky klic `request_uuid` pro draft/kompozice. Pole `request_id` zustava semanticke cislo pozadavku a bude se plnit az pri ulozeni.

## Tables

### ZMDG_REQ

```abap
@EndUserText.label : 'MDG Požadavek'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zmdg_req {

  key mandt        : mandt not null;
  key request_uuid : sysuuid_x16 not null;
  request_id       : zmdg_request_id;
  request_type     : zmdg_req_type;
  extsys           : zmdg_extsys;
  partner_gid      : zmdg_partner_gid;
  status           : zmsg_req_status;
  parent_gid1      : bu_partner;
  parent_gid2      : bu_partner;
  found_date       : bu_found_dat;
  duns             : /sapht/rn_duns;
  lei_code         : zmdg_lei;
  euid             : zmdg_euid;
  partner_id       : bu_partner;
  type             : zmdg_bu_type;
  bu_group         : zmdg_bu_group;
  legal_form       : zmdg_bu_legenty;
  tel_number       : ad_tlnmbr1;
  mob_number       : ad_mbnmbr1;
  smtpadress       : ad_smtpadr;
  inactive         : zmdg_inative;
  inactive_reason  : zmdg_inact_reason;
  vendor           : zmdg_vendor;
  customer         : zmdg_customer;
  created_by       : zmdg_req_created_by;
  created_at       : zmdg_req_created_at;
  changed_by       : zmdg_req_changed_by;
  changed_at       : zmdg_req_changed_at;
  name_org1        : bu_nameor1;
  name_org2        : bu_nameor2;
  name_org3        : bu_nameor3;
  name_org4        : bu_nameor4;
  name_first       : bu_namep_f;
  name_last        : bu_namep_l;
  bu_sort1         : bu_sort1;
  street           : ad_street;
  house_num1       : ad_hsnm1;
  house_num2       : ad_hsnm2;
  city1            : ad_city1;
  city2            : ad_city2;
  post_code1       : ad_pstcd1;
  country          : land1;
  name_org         : zmdg_nameorg;
  name_person      : zmdg_person;

}
```

### ZMDG_REQADR

```abap
@EndUserText.label : 'MDG Požadavek'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zmdg_reqadr {

  key mandt        : mandt not null;
  key request_uuid : sysuuid_x16 not null;
  key nation       : ad_nation not null;
  request_id       : zmdg_request_id;
  name_org1        : bu_nameor1;
  name_org2        : bu_nameor2;
  name_org3        : bu_nameor3;
  name_org4        : bu_nameor4;
  name_first       : bu_namep_f;
  name_last        : bu_namep_l;
  bu_sort1         : bu_sort1;
  street           : ad_street;
  house_num1       : ad_hsnm1;
  house_num2       : ad_hsnm2;
  city1            : ad_city1;
  city2            : ad_city2;
  post_code1       : ad_pstcd1;
  country          : land1;
  name_org         : zmdg_nameorg;
  name_person      : zmdg_person;

}
```

### ZMDG_REQTAX

```abap
@EndUserText.label : 'MDG požadavek daňová čísla'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zmdg_reqtax {

  key mandt        : mandt not null;
  key request_uuid : sysuuid_x16 not null;
  key taxtype      : bptaxtype not null;
  taxnum           : bptaxnum;
  request_id       : zmdg_request_id;

}
```
