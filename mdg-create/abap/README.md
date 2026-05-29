# ABAP RAP Artifacts

Prvni navrh zdrojaku pro RAP/OData V4 sluzbu nad request tabulkami.

## Poradi vytvareni v ADT

1. Interface CDS:
   - `ZI_MDG_C_SYS`
   - `ZI_MDG_REQ`
   - `ZI_MDG_REQADR`
   - `ZI_MDG_REQTAX`
2. Projection CDS:
   - `ZC_MDG_REQ`
   - `ZC_MDG_REQADR`
   - `ZC_MDG_REQTAX`
   - `provider contract transactional_query` patri jen na root projekci `ZC_MDG_REQ`; child projekce s `redirected to parent` ho mit nemaji.
   - Child projekce vystavuji `_Request : redirected to parent ZC_MDG_REQ`, aby slo projektovat lock/authorization dependency.
3. Metadata extension:
   - `ZC_MDG_REQ_UI`
   - `ZC_MDG_REQADR_UI`
   - `ZC_MDG_REQTAX_UI`
4. Behavior definitions:
   - `ZI_MDG_REQ`
   - `ZC_MDG_REQ`
   - behavior implementation class `ZBP_I_MDG_REQ`
5. Service definition:
   - `ZUI_MDG_REQ`
   - expose root i child projekce, aby se child `@UI.lineItem` anotace dostaly do OData metadata.
6. Service binding:
   - vytvorit v ADT jako OData V4 - UI nad `ZUI_MDG_REQ`

## Predpoklady

- `ZMDG_REQADR` ma klic `REQUEST_ID + NATION`.
- `ZMDG_REQTAX` ma klic `REQUEST_ID + TAXTYPE`.
- Draft tabulky musi mit pole podle CDS element names, napr. `REQUESTID`, `EXTERNALSYSTEM`, `BUSINESSPARTNERGROUP`, ne podle DB poli `REQUEST_ID`, `EXTSYS`, `BU_GROUP`.
- Pole `Requesting country` a `Language` zatim nejsou v dodanych tabulkach, proto nejsou soucasti CDS.
