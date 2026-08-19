# SuzukiCal

## Formål

Dette repo skal blive til en webapp til Aarhus Musikskolens Suzukiviolinelever (og deres forældre) til download af fællestimeplanen direkte i kalenderen. 

Appen skal altid have data fra den aktuelle fællestimeplan (som jeg uploader) og tage elevens gruppe (a, b, c, ...) og navn som input. Som output laves der et zip-fil med kalenderindkaldelser (ics-filer), som brugeren kan downloade og importere i sin kalender. Der er ingen data, der bliver gemt under brug af appen (navnet skal blot bruges til at navngive kalender-event'et - det er praktisk i tilfælde at man har flere børn i musikskolen). 

## Status og plan

Aktuel bestå koden af et R-script, der indlæser fællestimeplanen og producerer en ics-fil for en given gruppe og elevnavn. Det bliver lavet om til en webapp (R/shiny eller python/streamlit) for at være mere brugervenligt). 
