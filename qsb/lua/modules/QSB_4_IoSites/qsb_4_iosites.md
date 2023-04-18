### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.CreateIOBuildingSite (_Data)

Erzeugt eine Baustelle eines beliebigen Gebäudetyps an der Position.

 Diese Baustelle kann durch einen Helden aktiviert werden. Dann wird ein
 Siedler zur Baustelle eilen und das Gebäude aufbauen. Es ist egal, ob es
 sich um ein Territorium des Spielers oder einer KI handelt.

 Es ist dabei zu beachten, dass der Spieler, dem die Baustelle zugeordnet
 wird, das Territorium besitzt, auf dem er bauen soll. Des weiteren muss
 er über ein Lagerhaus/Hauptzelt verfügen.

 <p><b>Hinweis:</b> Es kann vorkommen, dass das Model der Baustelle nicht
 geladen wird. Dann ist der Boden der Baustelle schwarz. Sobald wenigstens
 ein reguläres Gebäude gebaut wurde, sollte die Textur jedoch vorhanden sein.
 </p>

 Mögliche Angaben für die Konfiguration:
 <table border="1">
 <tr><td><b>Feldname</b></td><td><b>Typ</b></td><td><b>Beschreibung</b></td></tr>
 <tr><td>Name</td><td>string</td><td>Position für die Baustelle</td></tr>
 <tr><td>PlayerID</td><td>number</td><td>Besitzer des Gebäudes</td></tr>
 <tr><td>Type</td><td>number</td><td>Typ des Gebäudes</td></tr>
 <tr><td>Costs</td><td>table</td><td>(optional) Eigene Gebäudekosten</td></tr>
 <tr><td>Distance</td><td>number</td><td>(optional) Aktivierungsentfernung</td></tr>
 <tr><td>Icon</td><td>table</td><td>(optional) Icon des Schalters</td></tr>
 <tr><td>Title</td><td>string</td><td>(optional) Titel der Beschreibung</td></tr>
 <tr><td>Text</td><td>string</td><td>(optional) Text der Beschreibung</td></tr>
 <tr><td>Condition</td><td>function</td><td>(optional) Optionale Aktivierungsbedingung</td></tr>
 <tr><td>Action</td><td>function</td><td>(optional) Optionale Funktion bei Aktivierung</td></tr>
 </table>


