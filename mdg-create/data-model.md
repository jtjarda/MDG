# Návrh Datového Modelu

Tento dokument vychází z aktuálně navržených transparentních tabulek pro požadavek na založení Business Partnera.

## Request Header

`ZMDG_REQ` je root tabulka požadavku. V managed RAP scénáři by nad ní měl vzniknout root interface view, například `ZI_MDG_REQ`.

```abap
@EndUserText.label : 'MDG Požadavek'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zmdg_req {

  key mandt       : mandt not null;
  key request_id  : zmdg_request_id not null;
  request_type    : zmdg_req_type;
  extsys          : zmdg_extsys;
  partner_gid     : zmdg_partner_gid;
  status          : zmsg_req_status;
  parent_gid1     : bu_partner;
  parent_gid2     : bu_partner;
  found_date      : bu_found_dat;
  duns            : /sapht/rn_duns;
  lei_code        : zmdg_lei;
  euid            : zmdg_euid;
  partner_id      : bu_partner;
  type            : zmdg_bu_type;
  bu_group        : zmdg_bu_group;
  legal_form      : zmdg_bu_legenty;
  tel_number      : ad_tlnmbr1;
  mob_number      : ad_mbnmbr1;
  smtpadress      : ad_smtpadr;
  inactive        : zmdg_inative;
  inactive_reason : zmdg_inact_reason;
  vendor          : zmdg_vendor;
  customer        : zmdg_customer;
  created_by      : zmdg_req_created_by;
  created_at      : zmdg_req_created_at;
  changed_by      : zmdg_req_changed_by;
  changed_at      : zmdg_req_changed_at;

}
```

### Poznámky

- `extsys` je v hlavičce, takže jeden požadavek zatím míří na jeden připojený systém. Pokud bude jeden request zakládat BP do více systémů, bude potřeba samostatná položková tabulka pro systémy.
- Cílový koncept pracuje s polem `Requesting country`. V aktuální `ZMDG_REQ` pro něj nevidím samostatné pole; doporučuji doplnit například `request_country : land1`, pokud má být nezávislé na adrese.
- `partner_id`, `vendor`, `customer` jsou pravděpodobně výstupní identifikátory po založení nebo rozšíření. V RAP UI bych je u draftu držel jako read-only.
- `inactive` a `inactive_reason` dávají smysl spíš pro změnový nebo rozšiřovací scénář. Pro čisté založení mohou být skryté podle typu požadavku.
- Ověřit doménu `zmsg_req_status`, zda nejde o překlep a nemá být `zmdg_req_status`.

## Request Address

`ZMDG_REQADR` drží adresní a jmenná data požadavku.

```abap
@EndUserText.label : 'MDG Požadavek'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zmdg_reqadr {

  key mandt      : mandt not null;
  key request_id : zmdg_request_id not null;
  key nation     : ad_nation not null;
  name_org1      : bu_nameor1;
  name_org2      : bu_nameor2;
  name_org3      : bu_nameor3;
  name_org4      : bu_nameor4;
  name_first     : bu_namep_f;
  name_last      : bu_namep_l;
  bu_sort1       : bu_sort1;
  street         : ad_street;
  house_num1     : ad_hsnm1;
  house_num2     : ad_hsnm2;
  city1          : ad_city1;
  city2          : ad_city2;
  post_code1     : ad_pstcd1;
  country        : land1;
  name_org       : zmdg_nameorg;
  name_person    : zmdg_person;

}
```

### Poznámky

- Protože address variants budou součástí první verze, doporučuji mít `nation` v klíči. Hlavní adresa může používat iniciální `nation`, varianty adres vyplněné hodnoty podle jazyka/národní verze adresy.
- Pokud by v budoucnu mohlo existovat více variant pro stejnou hodnotu `nation`, bude potřeba doplnit ještě `address_id` nebo `addr_type`.
- Cílový koncept pracuje s polem `Language`. V aktuálních tabulkách pro něj nevidím samostatné pole; doporučuji doplnit například `langu : spras`, pokud má být hodnota uložená a odesílaná dál.
- `name_org` a `name_person` mohou být výpočtová/display pole. Pokud se mají jen zobrazovat, lze je řešit přes CDS expression místo persistování.

## Request Tax Numbers

`ZMDG_REQTAX` drží daňová čísla požadavku.

```abap
@EndUserText.label : 'MDG požadavek daňová čísla'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zmdg_reqtax {

  key mandt       : mandt not null;
  key request_id  : zmdg_request_id not null;
  key taxtype     : bptaxtype not null;
  taxnum          : bptaxnum;

}
```

### Poznámky

- Klíč `request_id + taxtype` znamená jedno číslo pro jeden typ daně. Pokud může být více hodnot stejného typu, bude potřeba doplnit pořadí nebo `tax_id`.
- Zvážil bych doplnění `country`, pokud bude validace daňového čísla závislá na zemi a typu.

## Připojené Systémy

`ZMDG_C_SYS` je customizing tabulka pro připojené systémy.

```abap
@EndUserText.label : 'Nastavení připojených systémů'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #C
@AbapCatalog.dataMaintenance : #ALLOWED
define table zmdg_c_sys {

  key mandt   : mandt not null;
  key extsys  : zmdg_extsys not null;
  type        : zmdg_sys_type;
  description : zmdg_description;
  comm_class  : zmdg_comm_class;
  def_alpha   : zmdg_alpha;
  xcrea       : zmdg_xcrea;
  xenh        : zmdg_xenh;

}
```

### Použití

- `extsys` určí cílový systém požadavku.
- `type` může řídit typ integrace nebo logiku systému.
- `comm_class` může obsahovat ABAP třídu pro odeslání nebo založení v externím systému.
- `def_alpha` může nastavovat výchozí hodnotu pro search/konverzní logiku.
- `xcrea` může řídit, zda je pro systém povolené založení.
- `xenh` může řídit, zda je pro systém povolené rozšíření.

Samotná `ZMDG_C_SYS` ale nestačí pro detailní řízení jednotlivých polí. K tomu je vhodná samostatná field-control customizing tabulka popsaná v `field-control.md`.

## Rozsah První Verze

- Aplikace řeší pouze založení požadavku.
- Nebude přímo zakládat standardní BP/customer/vendor objekt.
- Po uložení požadavku se provedou kontroly a data se odešlou do externích systémů voláním ABAP třídy nebo služby dodané jiným týmem.
- Bankovní data, kontaktní osoby, přílohy a komentáře nejsou v rozsahu první verze.

## Doporučené Doplňkové Tabulky

- `ZMDG_REQ_LOG` - aplikační log požadavku.
- `ZMDG_REQ_APPR` - schvalovací kroky, rozhodnutí a komentáře.
- `ZMDG_REQ_OUTB` - volitelná outbound/logovací tabulka pro externí systémy, pokud bude potřeba evidovat jednotlivé pokusy o odeslání.
- `ZMDG_C_FIELD` - nastavení dostupnosti, editovatelnosti a povinnosti polí podle systému a typu požadavku.
