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
3. Metadata extension:
   - `ZC_MDG_REQ_UI`
   - `ZC_MDG_REQADR_UI`
   - `ZC_MDG_REQTAX_UI`
4. Behavior definitions:
   - `ZI_MDG_REQ`
   - `ZC_MDG_REQ`
5. Service definition:
   - `ZUI_MDG_REQ`
6. Service binding:
   - vytvorit v ADT jako OData V4 - UI nad `ZUI_MDG_REQ`

## Predpoklady

- `ZMDG_REQADR` ma klic `REQUEST_ID + NATION`.
- `ZMDG_REQTAX` ma klic `REQUEST_ID + TAXTYPE`.
- Draft tabulky nejsou v tomto navrhu vytvorene; v ADT je potreba doplnit draft persistence podle pouziteho release.
- Pole `Requesting country` a `Language` zatim nejsou v dodanych tabulkach, proto nejsou soucasti CDS.
