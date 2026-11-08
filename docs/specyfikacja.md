# Specyfikacja wymagań – raport sprzedaży Zdrojowa

## 1. Cel
Zastąpienie comiesięcznych zestawień w Excelu jednym raportem Power BI, który jest jedynym źródłem prawdy o sprzedaży, eliminuje ręczne przygotowanie raportu (ok. 3 dni pracy kontrolingu miesięcznie) i wspiera decyzje na comiesięcznym spotkaniu sprzedażowym.

## 2. Użytkownicy
- **Dyrektor sprzedaży** – widzi wszystkie dane.
- **Kierownicy regionalni (4 regiony)** – mają widzieć tylko swój region.
- **Kontroling** – weryfikuje liczby i utrzymuje plan.

## 3. Pytania biznesowe
1. Czy realizujemy plan sprzedaży i gdzie są największe odchylenia (kanał, region, kategoria)?
2. Które marki i kategorie rosną, a które spadają rok do roku?
3. Na których klientach i kanałach rabaty obniżają marżę poniżej 30%?
4. Które produkty (SKU) sprzedają się najsłabiej lub wcale i są kandydatami do wycofania?
5. Jak sprzedaż rozkłada się w czasie (sezonowość)?

## 4. KPI i definicje

| Miara | Definicja |
|---|---|
| Sprzedaż brutto | ilość × cena cennikowa |
| Rabaty | suma rabatów z faktur |
| Rabat % | rabaty / sprzedaż brutto |
| **Sprzedaż netto** | sprzedaż brutto − rabaty (główna miara) |
| Wolumen | liczba sprzedanych sztuk |
| Koszt wytworzenia | ilość × koszt jednostkowy z kartoteki |
| Marża | sprzedaż netto − koszt wytworzenia |
| Marża % | marża / sprzedaż netto (próg zarządu: 30%) |
| Plan | budżet sprzedaży netto |
| Wykonanie planu % | sprzedaż netto / plan do daty |
| Odchylenie od planu | sprzedaż netto − plan do daty |
| Zmiana r/r % | zmiana względem tego samego okresu rok wcześniej |
| Sprzedaż YTD | od początku roku do wybranej daty |
| SKU bez sprzedaży | aktywne produkty bez sprzedaży w ostatnich 3 miesiącach |

Koszty logistyki i marketingu oraz zwroty są poza zakresem.

## 5. Wymiary analizy
- **Czas:** dzień, tydzień, miesiąc, kwartał, rok
- **Produkt:** SKU, marka, kategoria, opakowanie
- **Klient:** klient, sieć, kanał (dyskonty, hipermarkety, handel tradycyjny, HoReCa)
- **Geografia:** województwo (16) → region sprzedażowy (4)

## 6. Źródła danych

| Źródło | Lokalizacja | Szczegółowość |
|---|---|---|
| Sprzedaż | ERP → SQL Server | linia faktury (dzień × klient × SKU) |
| Produkty | Excel | 1 wiersz = 1 SKU |
| Klienci | Excel | 1 wiersz = 1 klient |
| Plan | Excel (arkusz na rok) | miesiąc × region × kategoria |

Zakres danych: 01.2024–09.2026. Waluta: PLN.

## 7. Kryteria akceptacji
- Sprzedaż netto w raporcie zgadza się z danymi z ERP co do złotówki.
- Kierownik regionalny widzi tylko swój region.
- Raport otwiera się i filtruje w ciągu kilku sekund.
