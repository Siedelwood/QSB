### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.AddBuildingButton (_Action, _Tooltip, _Update)

Fügt einen allgemeinen Gebäudeschalter hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion.


### API.AddBuildingButtonAtPosition (_X, _Y, _Action, _Tooltip, _Update)

Fügt einen allgemeinen Gebäudeschalter an der Position hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion.

 Die Position wird lokal zur linken oberen Ecke des Fensters angegeben.


### API.AddBuildingButtonByEntity (_ScriptName, _Action, _Tooltip, _Update)

Fügt einen Gebäudeschalter für das Entity hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion. Wenn ein Entity einen Button zugewiesen bekommt, werden
 alle allgemeinen Buttons und alle Buttons für Typen für das Entity ignoriert.


### API.AddBuildingButtonByEntityAtPosition (_ScriptName, _X, _Y, _Action, _Tooltip, _Update)

Fügt einen Gebäudeschalter für das Entity hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion. Wenn ein Entity einen Button zugewiesen bekommt, werden
 alle allgemeinen Buttons und alle Buttons für Typen für das Entity ignoriert.


### API.AddBuildingButtonByType (_Type, _Action, _Tooltip, _Update)

Fügt einen Gebäudeschalter für den Entity-Typ hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion. Wenn ein Typ einen Button zugewiesen bekommt, werden alle
 allgemeinen Buttons für den Typ ignoriert.


### API.AddBuildingButtonByTypeAtPosition (_Type, _X, _Y, _Action, _Tooltip, _Update)

Fügt einen Gebäudeschalter für den Entity-Typ hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion. Wenn ein Typ einen Button zugewiesen bekommt, werden alle
 allgemeinen Buttons für den Typ ignoriert.


### API.DropBuildingButton (_ID)

Entfernt einen allgemeinen Gebäudeschalter.

### API.DropBuildingButtonFromEntity (_ScriptName, _ID)

Entfernt einen Gebäudeschalter vom benannten Gebäude.

### API.DropBuildingButtonFromType (_Type, _ID)

Entfernt einen Gebäudeschalter vom Gebäudetypen.

