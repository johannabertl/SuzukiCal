# SuzukiCal

## Formål

Dette repo indeholder en webapp til Aarhus Musikskolens Suzukiviolinelever (og deres forældre) til download af fællestimeplanen direkte i kalenderen. 

Appen skal altid have data fra den aktuelle fællestimeplan (som jeg uploader) og tage elevens gruppe (a, b, c, ...) og navn som input. Som output laves der et ics-fil med kalenderindkaldelser, som brugeren kan downloade og importere i sin kalender. Der er ingen data, der bliver gemt under brug af appen (navnet skal blot bruges til at navngive kalender-event'et - det er praktisk i tilfælde at man har flere børn i musikskolen). 

## Beskrivelse

Da input-data (pdf) kan ændre sig fra semester til semester, er jeg nød til at indlæse det manuelt og tjekke data undervejs ved at køre `data_prep.ipynb`. Det outputter et csv-fil med data, som jeg også oploader til repo'et (aktuel `plan_lang_efteraar_2026.csv`). 

Streamlit-appen i `streamlit_app.py` indlæser csv-filen og danner ics-filen ved hjælp af funktionen `generate_ics`. 

### Gammel kode

R-script'et `make_ics.R` er en R-prototype og bliver ikke brugt længere i appen.  

## Brug app

Appen kan bruges under [SuzukiCal.streamlit.app]. 
