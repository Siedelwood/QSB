### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.MoveEntity (_Entity, _Target, _IgnoreBlocking)

Bewegt ein Entity zum Zielpunkt.

 Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
 Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.

 Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
 wird das Event QSB.ScriptEvents.EntityArrived geworfen.


### API.MoveEntityAndExecute (_Entity, _Target, _Action, _IgnoreBlocking)

Bewegt ein Entity zum Zielpunkt und führt die Funktion aus.

 Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
 Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.

 Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
 wird das Event QSB.ScriptEvents.EntityArrived geworfen.


### API.MoveEntityAndLookAt (_Entity, _Target, _LookAt, _IgnoreBlocking)

Bewegt ein Entity zum Zielpunkt und lässt es das Ziel anschauen.

 Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
 Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.

 Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
 wird das Event QSB.ScriptEvents.EntityArrived geworfen.


### API.MoveEntityOnCheckpoints (_Entity, _WaypointList, _IgnoreBlocking)

Bewegt ein Entity über den angegebenen Pfad.

 Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
 Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.

 Jedes Mal wenn das Entity einen Wegpunkt erreicht hat, wird das Event
 QSB.ScriptEvents.EntityAtCheckpoint geworfen.

 Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
 wird das Event QSB.ScriptEvents.EntityArrived geworfen.


### API.MoveEntityToPosition (_Entity, _Target, _Distance, _Angle, _IgnoreBlocking)

Bewegt ein Entity relativ zu einer Position.

 Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
 Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.

 Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
 wird das Event QSB.ScriptEvents.EntityArrived geworfen.


### API.PlaceEntityAndLookAt (_Entity, _Target, _LookAt)

Positioniert ein Entity und lässt es einen Ort ansehen.

### API.PlaceEntityToPosition (_Entity, _Target, _Distance, _Angle)

Positioniert ein Entity relativ zu einer Position.

### API.IsPathBeingCalculated (_ID)

Prüft ob ein Pfad mit der ID noch gesucht wird.

### API.IsPathExisting (_ID)

Prüft ob ein Pfad mit der ID existiert.

### API.RetrievePath (_ID)

Gibt den Pfad mit der ID als Liste von Entity-IDs zurück.

### API.StartPathfinding (_StartPosition, _EndPosition, _NodeFilter)

Beginnt die Wegsuche zwischen zwei Punkten.

 Der Pfad wird nicht sofort zurückgegeben. Stattdessen eine ID. Der Pfad wird
 asynchron gesucht, damit das Spiel nicht einfriert. Wenn die Pfadsuche
 abgeschlossen wird, werden entsprechende Events ausgelöst.

 <ul>
 <li><b>QSB.ScriptEvents.PathFindingFinished</b><br/>
 Ein Pfad zwischen den Punkten wurde gefunden.</li>
 <li><b>QSB.ScriptEvents.PathFindingFailed</b><br/>
 Es konnte kein Pfad gefunden werden.</li>
 </ul>

 Wird der Node Filter weggelassen, wird automatisch eine Funktion erstellt,
 die alle Positionen ausschließt, die geblockt sind.


