### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.CommenceEntitySearch (_Filter)

Führt eine benutzerdefinierte Suche nach Entities aus.

 <b>Achtung</b>: Die Reihenfolge der Abfragen im Filter hat direkten
 Einfluss auf die Dauer der Suche. Während Abfragen auf den Besitzer oder
 den Typ schnell gehen, dauern Gebietssuchen lange! Es ist daher klug, zuerst
 Kriterien auszuschließen, die schnell bestimmt werden können!


### API.SearchEntities (_PlayerID, _WithoutDefeatResistant)

Findet <u>alle</u> Entities.

### API.SearchEntitiesByScriptname (_Pattern)

Findet alle Entities deren Skriptname das Suchwort enthält.

### API.SearchEntitiesOfCategoryInArea (_Area, _Position, _Category, _PlayerID)

Findet alle Entities der Kategorie in einem Gebiet.

### API.SearchEntitiesOfCategoryInTerritory (_Territory, _Category, _PlayerID)

Findet alle Entities der Kategorie in einem Territorium.

### API.SearchEntitiesOfTypeInArea (_Area, _Position, _Type, _PlayerID)

Findet alle Entities des Typs in einem Gebiet.

### API.SearchEntitiesOfTypeInTerritory (_Territory, _Type, _PlayerID)

Findet alle Entities des Typs in einem Territorium.

### API.ThiefDisableCathedralEffect (_Flag)

Deaktiviert die Standardaktion wenn ein Dieb in eine Kirche eindringt.

 <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
 stattdessen Informationen.


### API.ThiefDisableCisternEffect (_Flag)

Deaktiviert die Standardaktion wenn ein Dieb einen Brunnen sabotiert.

 <b>Hinweis</b>: Brunnen können nur im Addon gebaut und sabotiert werden.


### API.ThiefDisableStorehouseEffect (_Flag)

Deaktiviert die Standardaktion wenn ein Dieb in ein Lagerhaus eindringt.

 <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
 stattdessen Informationen.


