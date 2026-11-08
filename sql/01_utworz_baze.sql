/* =====================================================================
   Projekt: Zdrojowa – raport sprzedaży w Power BI
   Krok 2: utworzenie bazy i załadowanie eksportu z ERP
   Uruchom w SSMS całość (F5). Plik CSV musi leżeć w:
   C:\Projekty\Zdrojowa_PowerBI\dane\sprzedaz_erp.csv
   ===================================================================== */

-- 1. Baza danych
IF DB_ID('Zdrojowa') IS NULL
    CREATE DATABASE Zdrojowa;
GO
USE Zdrojowa;
GO

-- 2. Tabela sprzedaży (tak jak przychodzi z ERP – jedna linia faktury = jeden wiersz)
DROP TABLE IF EXISTS dbo.Sprzedaz;
CREATE TABLE dbo.Sprzedaz (
    NrFaktury      VARCHAR(20)    NOT NULL,
    LiniaFaktury   INT            NOT NULL,
    DataFaktury    DATE           NOT NULL,
    KlientID       VARCHAR(10)    NOT NULL,
    SKU            VARCHAR(20)    NOT NULL,
    Ilosc          INT            NOT NULL,
    CenaCennikowa  DECIMAL(10,2)  NOT NULL,
    RabatKwota     DECIMAL(12,2)  NOT NULL,
    CONSTRAINT PK_Sprzedaz PRIMARY KEY (NrFaktury, LiniaFaktury)
);

-- 3. Import pliku CSV
BULK INSERT dbo.Sprzedaz
FROM 'C:\Projekty\Zdrojowa_PowerBI\dane\sprzedaz_erp.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,          -- pomijamy nagłówek
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',     -- koniec linii w stylu Unix
    CODEPAGE        = '65001',    -- UTF-8
    TABLOCK
);

-- 4. Słownik województw i regionów sprzedażowych
DROP TABLE IF EXISTS dbo.Wojewodztwa;
CREATE TABLE dbo.Wojewodztwa (
    Wojewodztwo  NVARCHAR(30) NOT NULL PRIMARY KEY,
    Region       NVARCHAR(20) NOT NULL
);
INSERT INTO dbo.Wojewodztwa (Wojewodztwo, Region) VALUES
 (N'pomorskie', N'Północ'), (N'zachodniopomorskie', N'Północ'),
 (N'warmińsko-mazurskie', N'Północ'), (N'kujawsko-pomorskie', N'Północ'),
 (N'wielkopolskie', N'Zachód'), (N'lubuskie', N'Zachód'),
 (N'dolnośląskie', N'Zachód'), (N'opolskie', N'Zachód'),
 (N'małopolskie', N'Południe'), (N'śląskie', N'Południe'),
 (N'świętokrzyskie', N'Południe'), (N'podkarpackie', N'Południe'),
 (N'mazowieckie', N'Centrum-Wschód'), (N'łódzkie', N'Centrum-Wschód'),
 (N'lubelskie', N'Centrum-Wschód'), (N'podlaskie', N'Centrum-Wschód');

-- 5. Kontrola: porównaj wynik z liczbami kontrolnymi z czatu
SELECT
    COUNT(*)                                        AS LiczbaWierszy,
    SUM(Ilosc * CenaCennikowa)                      AS SprzedazBrutto,
    SUM(Ilosc * CenaCennikowa - RabatKwota)         AS SprzedazNetto,
    MIN(DataFaktury)                                AS OdDaty,
    MAX(DataFaktury)                                AS DoDaty
FROM dbo.Sprzedaz;
