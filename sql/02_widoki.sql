/* =====================================================================
   Projekt: Zdrojowa – raport sprzedaży w Power BI
   Widoki będące źródłem danych dla Power BI
   (wersja po optymalizacji modelu)
   ===================================================================== */
USE Zdrojowa;
GO

-- Fakt sprzedaży: tylko kolumny używane w modelu.
-- Sprzedaż netto liczona jest w DAX jako brutto − rabat.
CREATE OR ALTER VIEW dbo.vw_FaktSprzedaz AS
SELECT
    DataFaktury,
    KlientID,
    SKU,
    Ilosc,
    CAST(Ilosc * CenaCennikowa AS DECIMAL(14,2)) AS SprzedazBrutto,
    RabatKwota                                   AS Rabat
FROM dbo.Sprzedaz;
GO

-- Słownik województw i regionów sprzedażowych
CREATE OR ALTER VIEW dbo.vw_Wojewodztwa AS
SELECT Wojewodztwo, Region
FROM dbo.Wojewodztwa;
GO

-- Kontrola
SELECT
    COUNT(*)                          AS LiczbaWierszy,
    SUM(SprzedazBrutto)               AS SprzedazBrutto,
    SUM(SprzedazBrutto) - SUM(Rabat)  AS SprzedazNetto
FROM dbo.vw_FaktSprzedaz;
