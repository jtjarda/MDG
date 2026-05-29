# Create Flow

## Problém

Standardní tlačítko `Create` ve Fiori Elements vytvoří nový draft objekt bez předchozího business kontextu. Pro tuto aplikaci ale musí uživatel nejdříve zvolit cílový systém (`EXTSYS`), protože podle systému se následně řídí:

- dostupnost polí,
- povinnost polí,
- skrytí polí,
- default alphabet,
- možnost založení (`ZMDG_C_SYS-XCREA`),
- integrační třída/služba (`ZMDG_C_SYS-COMM_CLASS`).

## Zdroj Systémů

Použít customizing tabulku `ZMDG_C_SYS`.

Pro založení filtrovat pouze systémy:

```text
XCREA = 'X'
```

Volitelně později doplnit i autorizační filtr podle role uživatele.

## Doporučená Varianta

Nepoužít standardní `Create` jako hlavní uživatelskou cestu. Místo něj vytvořit vlastní akci, například:

```text
Create Request
```

Akce otevře dialog s parametrem:

```text
External System
```

Po potvrzení akce:

1. ověří, že systém existuje v `ZMDG_C_SYS`,
2. ověří `XCREA = 'X'`,
3. založí draft požadavku,
4. předvyplní `ExternalSystem`, `RequestType`, `Status`, `CreatedBy`, případně defaulty,
5. naviguje uživatele na object page nového draftu,
6. field-control už pracuje podle vybraného systému.

## RAP Návrh

V interface BDEF ponechat technickou create schopnost, ale ve projection BDEF pro UI je možné standardní create nevystavit a místo něj vystavit factory/custom akci.

Konceptuálně:

```abap
factory action CreateForSystem
  parameter ZS_MDG_REQ_CREATE
  result [1] $self;
```

Parametr struktury:

```abap
define structure zs_mdg_req_create {
  extsys : zmdg_extsys;
}
```

Implementace akce by volala:

- `ZCL_MDG_BP_REQ_CUSTOMIZING` pro načtení `ZMDG_C_SYS`,
- `ZCL_MDG_BP_REQ_DEFAULTS` pro defaulty,
- `ZCL_MDG_BP_REQ_FIELDCONTROL` pro následnou dynamiku polí.

## Alternativy

### Varianta A: Standardní Create a povinné pole ExternalSystem

Nechat standardní `Create`. Uživatel se dostane na object page a jako první vyplní `ExternalSystem`.

Výhody:

- nejjednodušší RAP/Fiori Elements implementace,
- bez custom create akce.

Nevýhody:

- object page se otevře bez kontextu,
- dynamika polí se musí přepočítat až po změně `ExternalSystem`,
- uživatel může nejdřív vidět nerelevantní pole.

### Varianta B: Vlastní Create Request akce s dialogem

Skrýt standardní create v UI projekci a nabídnout vlastní create/factory akci.

Výhody:

- uživatel nejdřív zvolí systém,
- object page se otevře už správně přizpůsobená,
- odpovídá cílovému UX.

Nevýhody:

- více implementace v behavior handleru,
- je potřeba ověřit přesnou podporu factory action v použitém Fiori Elements release.

### Varianta C: Freestyle UI5 úvodní dialog

Nad RAP službou udělat freestyle úvodní dialog nebo custom page, která vybere systém a potom vytvoří draft.

Výhody:

- největší kontrola nad UX,
- snadno lze napodobit cílový formulář.

Nevýhody:

- více UI5 kódu,
- menší využití čistého Fiori Elements standardu.

## Doporučení

Pro cílovou aplikaci doporučuji variantu B:

```text
Create Request -> výběr systému -> založení draftu -> object page se systémově řízenými poli
```

Do první technické verze lze dočasně ponechat standardní `Create`, ale před cílovým předáním bych ho nahradil vlastním create flow.

## Prototyp: Dvě Tlačítka

V prototypu mohou být současně:

- standardní `Create`,
- vlastní `Create for System`.

`Create for System` má být pouze v list report toolbaru. Nemá být v object page hlavičce/detailu, protože na už existujícím požadavku nedává smysl.

Proto v metadata extension používat pouze:

```abap
@UI.lineItem: [
  {
    position: 5,
    type: #FOR_ACTION,
    dataAction: 'CreateForSystem',
    label: 'Create for System'
  }
]
```

Nepřidávat tuto akci do `@UI.identification`.

## Drop-down Pro Výběr Systému

Pro malý seznam systémů je vhodnější drop-down než velký value help dialog.

Value help view označit jako malý číselník:

```abap
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_MDG_C_SYS_CREATEVH
  as select from zmdg_c_sys
{
  key extsys      as ExternalSystem,
      description as Description,
      type        as SystemType,
      def_alpha   as DefaultAlphabet
}
where xcrea = 'X'
```

Fiori Elements z toho může vygenerovat fixed-values value help/drop-down podle použitého UI5/SAP release. Pokud i potom zůstane velký value help dialog, bude pro přesné menu/drop-down chování potřeba UI extension.
