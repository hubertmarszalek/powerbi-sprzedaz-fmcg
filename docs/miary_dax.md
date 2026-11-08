# Miary i obiekty DAX

Wszystkie miary znajdują się w tabeli `_Miary`. Miary budowane są z innych miar, dzięki czemu każda definicja biznesowa istnieje w jednym miejscu.

## Tabela dat

```dax
DimData =
VAR Kalendarz =
    SELECTCOLUMNS (
        CALENDAR ( DATE ( 2024, 1, 1 ), DATE ( 2026, 12, 31 ) ),
        "Data", [Date]
    )
RETURN
    ADDCOLUMNS (
        Kalendarz,
        "Rok", YEAR ( [Data] ),
        "Kwartal", "Q" & QUARTER ( [Data] ),
        "MiesiacNr", MONTH ( [Data] ),
        "Miesiac", FORMAT ( [Data], "mmmm", "pl-PL" ),
        "RokMiesiac", FORMAT ( [Data], "yyyy-mm" ),
        "TydzienISO", WEEKNUM ( [Data], 21 ),
        "DzienTygodniaNr", WEEKDAY ( [Data], 2 )
    )
```

Kolumna obliczeniowa – znacznik dni, dla których są już dane sprzedażowe:

```dax
CzyOkresZDanymi = DimData[Data] <= MAX ( FaktSprzedaz[DataFaktury] )
```

## Sprzedaż i marża

```dax
Sprzedaż Brutto = SUM ( FaktSprzedaz[SprzedazBrutto] )

Rabat = SUM ( FaktSprzedaz[Rabat] )

Sprzedaż Netto = [Sprzedaż Brutto] - [Rabat]

Wolumen = SUM ( FaktSprzedaz[Ilosc] )

Rabat % = DIVIDE ( [Rabat], [Sprzedaż Brutto] )
```

Koszt liczony wiersz po wierszu – ilość z faktury × koszt jednostkowy z kartoteki produktu:

```dax
Koszt Wytworzenia =
SUMX (
    FaktSprzedaz,
    FaktSprzedaz[Ilosc] * RELATED ( DimProdukt[KosztJednostkowy] )
)

Marża = [Sprzedaż Netto] - [Koszt Wytworzenia]

Marża % = DIVIDE ( [Marża], [Sprzedaż Netto] )
```

## Plan

Plan istnieje tylko na poziomie miesiąc × region × kategoria. Poniżej tego poziomu miara zwraca pustą wartość zamiast mylącej liczby:

```dax
Plan =
VAR PonizejPoziomuPlanu =
    ISFILTERED ( DimKlient )
        || ISFILTERED ( DimProdukt )
        || ISFILTERED ( DimData[Data] )
        || ISFILTERED ( DimData[TydzienISO] )
        || ISFILTERED ( DimData[DzienTygodniaNr] )
RETURN
    IF ( NOT PonizejPoziomuPlanu, SUM ( FaktPlan[PlanNetto] ) )
```

Wykonanie liczone jest względem planu do ostatniego dnia z danymi, a nie planu rocznego:

```dax
Plan do daty =
CALCULATE ( [Plan], DimData[CzyOkresZDanymi] = TRUE () )

Wykonanie Planu % = DIVIDE ( [Sprzedaż Netto], [Plan do daty] )

Odchylenie od Planu = [Sprzedaż Netto] - [Plan do daty]
```

## Analiza czasowa

Porównanie rok do roku dla niepełnego roku: bieżący okres jest najpierw zawężany do dni z danymi, a dopiero potem przesuwany o rok wstecz (np. 01.01–30.09.2026 vs 01.01–30.09.2025):

```dax
Sprzedaż Netto RR =
CALCULATE (
    [Sprzedaż Netto],
    CALCULATETABLE (
        SAMEPERIODLASTYEAR ( DimData[Data] ),
        DimData[CzyOkresZDanymi] = TRUE ()
    )
)
```

Zmiana r/r ma sens tylko w obrębie jednego roku – w wierszu sumy wielu lat miara zwraca pustą wartość:

```dax
Zmiana RR % =
IF (
    HASONEVALUE ( DimData[Rok] ),
    DIVIDE ( [Sprzedaż Netto] - [Sprzedaż Netto RR], [Sprzedaż Netto RR] )
)

Sprzedaż Netto YTD = TOTALYTD ( [Sprzedaż Netto], DimData[Data] )
```

Dynamiczny tytuł wykresu, gdy brak danych za poprzedni rok:

```dax
Tytuł Zmiana RR =
IF (
    ISBLANK ( [Sprzedaż Netto RR] ),
    "Zmiana r/r wg marki – brak danych za poprzedni rok",
    "Zmiana sprzedaży r/r wg marki"
)
```

## Klienci i produkty

```dax
Klienci poniżej progu marży =
COUNTROWS (
    FILTER (
        VALUES ( DimKlient[KlientID] ),
        NOT ISBLANK ( [Sprzedaż Netto] ) && [Marża %] < 0.3
    )
)

Aktywne SKU =
CALCULATE ( COUNTROWS ( DimProdukt ), DimProdukt[Status] = "Aktywny" )

Ostatnia sprzedaż =
CALCULATE ( MAX ( FaktSprzedaz[DataFaktury] ), REMOVEFILTERS ( DimData ) )
```

Liczba aktywnych produktów bez sprzedaży w ostatnich 3 miesiącach. `CALCULATE` wewnątrz `FILTER` wykorzystuje przejście kontekstu – każdy wiersz produktu staje się filtrem:

```dax
SKU bez sprzedaży 3M =
VAR OstatniaData =
    CALCULATE ( MAX ( FaktSprzedaz[DataFaktury] ), REMOVEFILTERS () )
VAR Ostatnie3M =
    DATESINPERIOD ( DimData[Data], OstatniaData, -3, MONTH )
RETURN
    COUNTROWS (
        FILTER (
            DimProdukt,
            DimProdukt[Status] = "Aktywny"
                && ISBLANK ( CALCULATE ( [Sprzedaż Netto], Ostatnie3M ) )
        )
    )
```

## Kontrola jakości danych

Sprzedaż przypisana do SKU, którego nie ma w kartotece produktów (oczekiwana wartość: 0):

```dax
Sprzedaż bez produktu w kartotece =
CALCULATE ( [Sprzedaż Netto], ISBLANK ( DimProdukt[SKU] ) ) + 0
```
