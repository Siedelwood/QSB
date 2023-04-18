### API.DisposeObject (_ScriptName)

Zerstört die Interation mit dem Objekt.

 <b>Hinweis</b>: Das Entity selbst wird nicht zerstört.


### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.SetupObject (_Description)

Erzeugt ein einfaches interaktives Objekt.

 Dabei können alle Entities als interaktive Objekte behandelt werden, nicht
 nur die, die eigentlich dafür vorgesehen sind.

 Die Parameter des interaktiven Objektes werden durch seine Beschreibung
 festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
 Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.

 <b>Achtung</b>: Wird eine Straße über einem Objekt platziert, während die
 Kosten bereits bezahlt und auf dem Weg sind, läuft die Aktivierung ins Leere.
 Zwar wird das Objekt zurückgesetzt, doch die bereits geschickten Waren sind
 dann futsch.

 Mögliche Angaben:
 <table border="1">
 <tr>
 <td><b>Feldname</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 <td><b>Optional</b></td>
 </tr>
 <tr>
 <td>Name</td>
 <td>string</td>
 <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
 <td>nein</td>
 </tr>
 <tr>
 <td>Texture</td>
 <td>table</td>
 <td>Angezeigtes Icon des Buttons. Die Icons können auf die Icons des Spiels
 oder auf eigene Icons zugreifen.
 <br>- Spiel-Icons: {x, y, Spielversion}
 <br>- Benutzerdefinierte Icons: {x, y, Dateinamenpräfix}</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Title</td>
 <td>string</td>
 <td>Angezeigter Titel des Objekt</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Text</td>
 <td>string</td>
 <td>Angezeigte Beschreibung des Objekt</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Distance</td>
 <td>number</td>
 <td>Die minimale Entfernung zum Objekt, die ein Held benötigt um das
 objekt zu aktivieren.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Player</td>
 <td>number|table</td>
 <td>Spieler, der/die das Objekt aktivieren kann/können.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Waittime</td>
 <td>number</td>
 <td>Die Zeit, die ein Held benötigt, um das Objekt zu aktivieren.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Replacement</td>
 <td>number</td>
 <td>Entity, mit der das Objekt nach Aktivierung ersetzt wird.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Costs</td>
 <td></td>
 <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Reward</td>
 <td>table</td>
 <td>Der Warentyp und die Menge der gefundenen Waren im Objekt. (Format: {Typ, Menge})</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>State</td>
 <td>number</td>
 <td>Bestimmt, wie sich der Button des interaktiven Objektes verhält.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Condition</td>
 <td>function</td>
 <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ConditionInfo</td>
 <td>string</td>
 <td>Nachricht, die angezeigt wird, wenn die Bedinung nicht erfüllt ist.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Action</td>
 <td>function</td>
 <td>Eine Funktion, die nach der Aktivierung aufgerufen wird.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>RewardResourceCartType</td>
 <td>number</td>
 <td>Erlaubt, einen anderern Karren für Rohstoffkosten einstellen.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>RewardGoldCartType</td>
 <td>number</td>
 <td>Erlaubt, einen anderern Karren für Goldkosten einstellen.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>CostResourceCartType</td>
 <td>number</td>
 <td>Erlaubt, einen anderern Karren für Rohstoffbelohnungen einstellen.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>CostGoldCartType</td>
 <td>number</td>
 <td>Erlaubt, einen anderern Karren für Goldbelohnung einstellen.</td>
 <td>ja</td>
 </tr>
 </table>


### API.ResetObject (_ScriptName)

Setzt das interaktive Objekt zurück.  Dadurch verhält es sich, wie vor der
 Aktivierung durch den Spieler.

 <b>Hinweis</b>: Das Objekt muss wieder per Skript aktiviert werden, damit es
 im Spiel ausgelöst werden.


### API.InteractiveObjectActivate (_ScriptName, _State, ...)

Aktiviert ein Interaktives Objekt, sodass es von den Spielern
 aktiviert werden kann.

 Optional kann das Objekt nur für einen bestimmten Spieler aktiviert werden.

 Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
 einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
 Held das Objekt aktivieren.


### API.InteractiveObjectDeactivate (_ScriptName, ...)

Deaktiviert ein interaktives Objekt, sodass es nicht mehr von den Spielern
 benutzt werden kann.

 Optional kann das Objekt nur für einen bestimmten Spieler deaktiviert werden.


### API.InteractiveObjectSetQuestName (_Key, _Text)

Erzeugt eine Beschriftung für Custom Objects.

 Im Questfenster werden die Namen von Custom Objects als ungesetzt angezeigt.
 Mit dieser Funktion kann ein Name angelegt werden.


