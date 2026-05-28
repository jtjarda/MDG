# Databazove tabulky - pole, datove elementy, typy a delky

Poznamka: U standardnich SAP datovych elementu jsou uvedene obvykle technicke
typy a delky. U zakaznickych `Z*` datovych elementu je nutne delku overit v DDIC
transakci `SE11` nebo v ADT, protoze z definice tabulky neni videt domena.

## ZMDG_BP

| Pole | Klic | Datovy element | Technicky typ | Delka |
|---|---:|---|---|---:|
| MANDT | ano | `MANDT` | `CLNT` | 3 |
| PARTNER_GID | ano | `ZMDG_PARTNER_GID` | `TODO_DDIC` | `TODO` |
| PARENT_GID1 | ne | `ZMDG_PARENT1_GID` | `TODO_DDIC` | `TODO` |
| PARENT_GID2 | ne | `ZMDG_PARENT2_GID` | `TODO_DDIC` | `TODO` |
| FOUND_DATE | ne | `BU_FOUND_DAT` | `DATS` | 8 |
| DUNS | ne | `/SAPHT/RN_DUNS` | `CHAR` | 9 |
| LEI_CODE | ne | `ZMDG_LEI_CODE` | `TODO_DDIC` | `TODO` |
| EUID | ne | `ZMDG_EUID` | `TODO_DDIC` | `TODO` |

## ZMDG_BPADR

| Pole | Klic | Datovy element | Technicky typ | Delka |
|---|---:|---|---|---:|
| MANDT | ano | `MANDT` | `CLNT` | 3 |
| PARTNER_GID | ano | `ZMDG_PARTNER_GID` | `TODO_DDIC` | `TODO` |
| NATION | ano | `AD_NATION` | `CHAR` | 1 |
| NAME_ORG1 | ne | `BU_NAMEOR1` | `CHAR` | 40 |
| NAME_ORG2 | ne | `BU_NAMEOR2` | `CHAR` | 40 |
| NAME_ORG3 | ne | `BU_NAMEOR3` | `CHAR` | 40 |
| NAME_ORG4 | ne | `BU_NAMEOR4` | `CHAR` | 40 |
| NAME_ORG | ne | `ZMDG_NAMEORG` | `CHAR` | 180 |
| NAME_FIRST | ne | `BU_NAMEP_F` | `CHAR` | 40 |
| NAME_LAST | ne | `BU_NAMEP_L` | `CHAR` | 40 |
| NAME_PERSON | ne | `ZMDG_NAMEPERS` | `CHAR` | 100 |
| BU_SORT1 | ne | `BU_SORT1` | `CHAR` | 20 |
| STREET | ne | `AD_STREET` | `CHAR` | 60 |
| HOUSE_NUM1 | ne | `AD_HSNM1` | `CHAR` | 10 |
| HOUSE_NUM2 | ne | `AD_HSNM2` | `CHAR` | 10 |
| CITY1 | ne | `AD_CITY1` | `CHAR` | 40 |
| CITY2 | ne | `AD_CITY2` | `CHAR` | 40 |
| POST_CODE1 | ne | `AD_PSTCD1` | `CHAR` | 10 |
| COUNTRY | ne | `LAND1` | `CHAR` | 3 |

## ZMDG_BPSYS

| Pole | Klic | Datovy element | Technicky typ | Delka |
|---|---:|---|---|---:|
| MANDT | ano | `MANDT` | `CLNT` | 3 |
| PARTNER_GID | ano | `ZMDG_PARTNER_GID` | `TODO_DDIC` | `TODO` |
| EXTSYS | ano | `ZMDG_EXTSYS` | `TODO_DDIC` | `TODO` |
| PARTNER_ID | ne | `BU_PARTNER` | `CHAR` | 10 |
| TYPE | ne | `ZMDG_BU_TYPE` | `TODO_DDIC` | `TODO` |
| BU_GROUP | ne | `ZMDG_BU_GROUP` | `TODO_DDIC` | `TODO` |
| LANGU | ne | `LANGU` | `LANG` | 1 |
| LEGAL_FORM | ne | `ZMDG_BU_LEGENTY` | `TODO_DDIC` | `TODO` |
| TEL_NUMBER | ne | `AD_TLNMBR1` | `CHAR` | 30 |
| MOB_NUMBER | ne | `AD_MBNMBR1` | `CHAR` | 30 |
| SMTPADRESS | ne | `AD_SMTPADR` | `CHAR` | 241 |
| INACTIVE | ne | `ZMDG_INACTIVE` | `TODO_DDIC` | `TODO` |
| INACTIVE_REASON | ne | `ZMDG_INACT_REASON` | `TODO_DDIC` | `TODO` |

## ZMDG_BPTAX

| Pole | Klic | Datovy element | Technicky typ | Delka |
|---|---:|---|---|---:|
| MANDT | ano | `MANDT` | `CLNT` | 3 |
| PARTNER_GID | ano | `ZMDG_PARTNER_GID` | `TODO_DDIC` | `TODO` |
| TAXTYPE | ano | `BPTAXTYPE` | `CHAR` | 4 |
| TAXNUM | ne | `BPTAXNUM` | `CHAR` | 20 |
