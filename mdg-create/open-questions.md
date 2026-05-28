# Otevřené Otázky

## Rozhodnutý Rozsah

- První verze řeší pouze založení požadavku.
- Nebude se zakládat žádný standardní BP/customer/vendor objekt přímo touto aplikací.
- Po uložení požadavku se provedou kontroly a data se odešlou do externích systémů voláním ABAP třídy nebo služby dodané jiným týmem.
- Bankovní data nebudou v první verzi.
- Kontaktní osoby nebudou v první verzi.
- Request nebude mít přílohy ani komentáře.
- Pole budou dynamická podle systému a dalších atributů požadavku.
- UI má být nad RAP OData V4.
- Address variants budou součástí první verze.

## Funkční Otázky

- Má být možné request po zamítnutí opravit a znovu odeslat?

## Workflow

- Použije se standardní SAP Workflow/Flexible Workflow, nebo vlastní jednoduchý schvalovací model?
  - Zatím neuzavřeno.
- Schvalování bude potřeba jen pro vybrané země.
  - U některých zemí nebude schvalování vůbec.
  - U jedné země bude pravděpodobně jednoúrovňové schvalování.
- Kdo smí provést ruční retry po chybě odeslání?
  - Zatím neuzavřeno.

## Technické Otázky

- Které kontroly duplicit se mají dělat před uložením a které až před odesláním?
  - Zatím neuzavřeno.
- Má být odeslání do externího systému technicky synchronní i v případě delší odezvy nebo chyby externí služby?
  - Aktuální směr: uložení a následné zpracování synchronně.
  - Doporučení: i při synchronním volání uložit technický výsledek a chybovou zprávu do requestu/logu.

## UI Otázky

- Address variants:
  - Po stisku tlačítka plus se má otevřít pravý detailní sloupec/formulář pro novou variantu adresy.
  - Uživatel tam vyplní všechna pole nové varianty.
  - Po uložení se varianta zobrazí v malé tabulce address variants jako řádek s `Nation` a náhledem adresy.

