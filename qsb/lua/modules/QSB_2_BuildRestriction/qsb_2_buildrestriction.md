### API.DeleteRestriction (_ID)

Löscht eine Baueinschränkung mit der angegebenen ID.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.RestrictBuildingCategoryInArea (_PlayerID, _Category, _Position, _Area)

Verhindert den Bau von Gebäuden der Kategorie innerhalb des Gebietes.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.RestrictBuildingCategoryInTerritory (_PlayerID, _Category, _Territory)

Verhindert den Bau von Gebäuden der Kategorie in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.RestrictBuildingCustomFunction (_PlayerID, _Function, _Message)

Verhindert den Bau Gebäuden anhand der übergebenen Funktion.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 Die angegebene Funktion muss eine Funktion im lokalen Skript sein. Es ist
 möglich Funktionen innerhalb Tables anzugeben. Die self-Referenz wird
 allerdings nicht unterstützt.

 Eine Funktion muss true zurückgeben, wenn der Bau geblockt werden soll.
 Die gleiche Funktion kann für alle Spieler benutzt werden, wenn als PlayerID
 -1 angegeben wird. Für welchen Spieler sie ausgeführt wird, wird stets als
 Parameter übergeben.


### API.RestrictBuildingTypeInArea (_PlayerID, _Type, _Position, _Area)

Verhindert den Bau von Gebäuden des Typs innerhalb des Gebietes.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.RestrictBuildingTypeInTerritory (_PlayerID, _Type, _Territory)

Verhindert den Bau von Gebäuden des Typs in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.RestrictRoadCustomFunction (_PlayerID, _Function, _Message)

Verhindert den Bau von Pfaden oder Straßen anhand der übergebenen Funktion.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 Die angegebene Funktion muss eine Funktion im lokalen Skript sein. Es ist
 möglich Funktionen innerhalb Tables anzugeben. Die self-Referenz wird
 allerdings nicht unterstützt.

 Eine Funktion muss true zurückgeben, wenn der Bau geblockt werden soll.
 Die gleiche Funktion kann für alle Spieler benutzt werden, wenn als PlayerID
 -1 angegeben wird. Für welchen Spieler sie ausgeführt wird, wird stets als
 Parameter übergeben.


### API.RestrictStreetInArea (_PlayerID, _Position, _Area)

Verhindert den Bau von Straßen innerhalb des Gebiets.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.RestrictStreetInTerritory (_PlayerID, _Territory)

Verhindert den Bau von Straßen in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.RestrictTrailInArea (_PlayerID, _Position, _Area)

Verhindert den Bau von Pfaden innerhalb des Gebiets.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.RestrictTrailInTerritory (_PlayerID, _Territory)

Verhindert den Bau von Pfaden in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.DeleteProtection (_ID)

Löscht einen Abrissschutz mit der angegebenen ID.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.ProtectBuildingCategoryInArea (_PlayerID, _Category, _Position, _Area)

Verhindert den Abriss aller Gebäude in der Kategorie innerhalb des Gebiets.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.ProtectBuildingCategoryInTerritory (_PlayerID, _Category, _Territory)

Verhindert den Abriss aller Gebäude in der Kategorie in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.ProtectBuildingCustomFunction (_PlayerID, _Function, _Message)

Verhindert den Abriss von Gebäuden anhand der übergebenen Funktion.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 Die angegebene Funktion muss eine Funktion im lokalen Skript sein. Es ist
 möglich Funktionen innerhalb Tables anzugeben. Die self-Referenz wird
 allerdings nicht unterstützt.

 Eine Funktion muss true zurückgeben, wenn der Abriss geblockt werden soll.
 Die gleiche Funktion kann für alle Spieler benutzt werden, wenn als PlayerID
 -1 angegeben wird. Für welchen Spieler sie ausgeführt wird, wird stets als
 Parameter übergeben.


### API.ProtectBuildingTypeInArea (_PlayerID, _Type, _Position, _Area)

Verhindert den Abriss aller Gebäude des Typs innerhalb des Gebiets.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.ProtectBuildingTypeInTerritory (_PlayerID, _Type, _Territory)

Verhindert den Abriss aller Gebäude des Typs in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


### API.ProtectNamedBuilding (_PlayerID, _ScriptName)

Verhindert den Abriss eines benannten Gebäudes.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!


