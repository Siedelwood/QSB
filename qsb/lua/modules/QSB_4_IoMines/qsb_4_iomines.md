### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.CreateIOIronMine (_Data)

Erstelle eine verschüttete Eisenmine.

 Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
 20 Holz.

 Die Parameter der interaktiven Mine werden durch ihre Beschreibung
 festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
 Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.

 Mögliche Angaben:
 <table border="1">
 <tr>
 <td><b>Feldname</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 <td><b>Optional</b></td>
 </tr>
 <tr>
 <td>Position</td>
 <td>string</td>
 <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
 <td>nein</td>
 </tr>
 <tr>
 <td>Title</td>
 <td>string</td>
 <td>Angezeigter Titel der Beschreibung für die Mine</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Text</td>
 <td>string</td>
 <td>Angezeigte Text der Beschreibung für die Mine</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Costs</td>
 <td>table</td>
 <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ResourceAmount</td>
 <td>number</td>
 <td>Menge an Rohstoffen nach der Aktivierung</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>RefillAmount</td>
 <td>number</td>
 <td>Menge an Rohstoffen, die ein Geologe auffüllt (0 == nicht nachfüllbar)</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ConstructionCondition</td>
 <td>function</td>
 <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ConstructionAction</td>
 <td>function</td>
 <td>Eine zusätzliche Aktion nach der Aktivierung.</td>
 <td>ja</td>
 </tr>
 </table>


### API.CreateIOStoneMine (_Data)

Erstelle eine verschüttete Steinmine.

 Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
 20 Holz.

 Die Parameter der interaktiven Mine werden durch ihre Beschreibung
 festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
 Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.

 Mögliche Angaben:
 <table border="1">
 <tr>
 <td><b>Feldname</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 <td><b>Optional</b></td>
 </tr>
 <tr>
 <td>Position</td>
 <td>string</td>
 <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
 <td>nein</td>
 </tr>
 <tr>
 <td>Title</td>
 <td>string</td>
 <td>Angezeigter Titel der Beschreibung für die Mine</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Text</td>
 <td>string</td>
 <td>Angezeigte Text der Beschreibung für die Mine</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Costs</td>
 <td>table</td>
 <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
 <td>ja</td>
 </tr>
 <tr>
 <tr>
 <td>ResourceAmount</td>
 <td>number</td>
 <td>Menge an Rohstoffen nach der Aktivierung</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>RefillAmount</td>
 <td>number</td>
 <td>Menge an Rohstoffen, die ein Geologe auffüllt (0 == nicht nachfüllbar)</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ConstructionCondition</td>
 <td>function</td>
 <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ConstructionAction</td>
 <td>function</td>
 <td>Eine zusätzliche Aktion nach der Aktivierung.</td>
 <td>ja</td>
 </tr>
 </table>


