# Module <code>qsb_4_iosites</code>
Ermöglicht mit interaktiven Objekten Baustellen zu setzen.
 Die Baustelle muss durch den Helden aktiviert werden. Ein Siedler wird aus
 dem Lagerhaus kommen und das Gebäude bauen.</p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
 <li><a href="modules.QSB_2_Objects.QSB_2_Objects.html">(2) Interaktive Objekte</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_4_iosites.lua.html#27

Events, auf die reagiert werden kann.





### API.CreateIOBuildingSite (_Data)
source/qsb_4_iosites.lua.html#81

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






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Eine einfache Baustelle erzeugen
</span>API.CreateIOBuildingSite {
    Name     = <span class="string">"haus"</span>,
    PlayerID = <span class="number">1</span>,
    Type     = Entities.B_Bakery
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Baustelle mit Kosten erzeugen
</span>API.CreateIOBuildingSite {
    Name     = <span class="string">"haus"</span>,
    PlayerID = <span class="number">1</span>,
    Type     = Entities.B_Bakery,
    Costs    = {Goods.G_Wood, <span class="number">4</span>},
    Distance = <span class="number">1000</span>
};</pre></li>


</ul>


