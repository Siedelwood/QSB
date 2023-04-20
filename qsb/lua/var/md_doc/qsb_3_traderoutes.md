# Module <code>qsb_3_traderoutes</code>
Ermöglicht einen KI-Spieler als Hafen einzurichten.
 <h5>Was ein Hafen macht</h5>
 Häfen werden zyklisch von Schiffen über Handelsrouten angesteuert. Ein Hafen
 kann prinzipiell ungebegrenzt viele Handelsrouten haben. Wenn ein Schiff im
 Hafen anlegt, werden die Waren den Angeboten hinzugefügt. Ist kein Platz
 mehr für ein weiteres Angebot, wird das jeweils älteste entfernt.</p>

<p> Die Angebote in einem Hafen werden nicht erneuert. Wenn alle Einheiten eines
 Angebotes gekauft wurden, wird das Angebot automatisch entfernt.</p>

<p> Handelsschiffe einer Handelsroute haben einen Geschwindigkeitsbonus erhalten,
 damit man bei langen Wegen nicht ewig auf die Ankunft warten muss.</p>

<p> Sollte ein KI-Spieler, welcher als Hafen eingerichtet ist, vernichtet werden,
 werden automatisch alle aktiven Routen gelöscht. Schiffe, welche sich auf
 dem Weg vom oder zum Hafen befinden, verschwinden ebenfalls.</p>

<p> <h5>Was ein Hafen NICHT macht</h5>
 Die Einrichtung eines KI-Spielers als Hafen bringt keine automatischen
 Änderungen des Diplomatiestatus mit sich. Des weiteren wird keine Nachricht
 versendet, wenn ein Schiff im Hafen anlegt oder diesen wieder verlässt. Bei
 vielen Handelsrouten würde sonst der Spieler in Nachrichten ersticken.</p>

<p> <p><b>Vorausgesetzte Module:</b></p>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.QSB_1_Trade.QSB_1_Trade.html">(1) Handelserweiterung</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_3_traderoutes.lua.html#48

Events, auf die reagiert werden kann.





### API.AddTradeRoute (_PlayerID, _Route)
source/qsb_3_traderoutes.lua.html#177

Fügt eine Handelsroute zu einem Hafen hinzu.

 Für jede Handelsroute eines Hafens erscheint ein Handelsschiff, das den Hafen
 zyklisch mit neuen Waren versorgt.

 Eine Handelsroute hat folgende Felder:
 <table border="1">
 <tr>
 <td><b>Feld</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>Name</td>
 <td>string</td>
 <td>Name der Handelsroute (Muss für die Partei eindeutig sein)</td>
 </tr>
 <tr>
 <td>Path</td>
 <td>table</td>
 <td>Liste der Wegpunkte des Handelsschiffs (mindestens 2)</td>
 </tr>
 <tr>
 <td>Offers</td>
 <td>table</td>
 <td>Liste mit Angeboten (Format: {_Angebot, _Menge})</td>
 </tr>
 <tr>
 <td>Amount</td>
 <td>number</td>
 <td>(Optional) Menge an ausgewählten Angeboten.</td>
 </tr>
 <tr>
 <td>Duration</td>
 <td>number</td>
 <td>(Option) Verweildauer im Hafen in Sekunden</td>
 </tr>
 <tr>
 <td>Interval</td>
 <td>number</td>
 <td>(Optional) Zeit bis zur Widerkehr in Sekunden</td>
 </tr>
 <tr>
 <td></td>
 <td></td>
 <td></td>
 </tr>
 </table>





### Verwandte Themen:
<ul>


<li><a href="qsb_3_traderoutes.html#API.InitHarbor">API.InitHarbor</a></li>


<li><a href="qsb_3_traderoutes.html#API.ChangeTradeRouteGoods">API.ChangeTradeRouteGoods</a></li>


<li><a href="qsb_3_traderoutes.html#API.RemoveTradeRoute">API.RemoveTradeRoute</a></li>


</ul>



### Beispiel:
<ul>


<pre class="example">API.AddTradeRoute(
    <span class="number">2</span>,
    {
        Name       = <span class="string">"Route3"</span>,
        <span class="comment">-- Wegpunkte - Der letzte sollte beim Hafen sein ;)
</span>        Path       = {<span class="string">"Spawn3"</span>, <span class="string">"Arrived3"</span>},
        <span class="comment">-- Schiff kommt alle 10 Minuten
</span>        Interval   = <span class="number">10</span>*<span class="number">60</span>,
        <span class="comment">-- Schiff bleibt 2 Minunten im Hafen
</span>        Duration   = <span class="number">2</span>*<span class="number">60</span>,
        <span class="comment">-- Menge pro Anfahrt
</span>        Amount     = <span class="number">2</span>,
        <span class="comment">-- Liste an Angeboten
</span>        Offers     = {
            {<span class="string">"G_Wool"</span>, <span class="number">5</span>},
            {<span class="string">"U_CatapultCart"</span>, <span class="number">1</span>},
            {<span class="string">"G_Beer"</span>, <span class="number">2</span>},
            {<span class="string">"G_Herb"</span>, <span class="number">5</span>},
            {<span class="string">"U_Entertainer_NA_StiltWalker"</span>, <span class="number">1</span>},
        }
    }
);</pre>


</ul>


### API.ChangeTradeRouteGoods (_PlayerID, _RouteName, _RouteOffers)
source/qsb_3_traderoutes.lua.html#245

Andert das Warenangebot einer Handelsroute.

 Es können nur bestehende Handelsrouten geändert werden. Die Änderung wird
 erst im nächsten Zyklus wirksam.





### Verwandte Themen:
<ul>


<li><a href="qsb_3_traderoutes.html#API.InitHarbor">API.InitHarbor</a></li>


<li><a href="qsb_3_traderoutes.html#API.RemoveTradeRoute">API.RemoveTradeRoute</a></li>


<li><a href="qsb_3_traderoutes.html#API.AddTradeRoute">API.AddTradeRoute</a></li>


</ul>



### Beispiel:
<ul>


<pre class="example">API.ChangeTradeRouteGoods(
    <span class="number">2</span>,
    <span class="string">"Route3"</span>,
    {{<span class="string">"G_Wool"</span>, <span class="number">3</span>},
     {<span class="string">"U_CatapultCart"</span>, <span class="number">5</span>},
     {<span class="string">"G_Beer"</span>, <span class="number">2</span>},
     {<span class="string">"G_Herb"</span>, <span class="number">3</span>},
     {<span class="string">"U_Entertainer_NA_StiltWalker"</span>, <span class="number">1</span>}}
);</pre>


</ul>


### API.DisposeHarbor (_PlayerID)
source/qsb_3_traderoutes.lua.html#88

Entfernt den Schiffshändler vom Lagerhaus des Spielers.

 <b>Hinweis</b>: Die Routen werden sofort gelöscht. Schiffe, die sich mitten
 in ihrem Zyklus befinden, werden ebenfalls gelöscht und alle aktiven Angebote
 im Lagerhaus des KI-Spielers werden sofort entfernt. Nutze dies, wenn z.B.
 der KI-Spieler feindlich wird.






### Beispiel:
<ul>


<pre class="example">API.DisposeHarbor(<span class="number">2</span>);</pre>


</ul>


### API.InitHarbor (_PlayerID, ...)
source/qsb_3_traderoutes.lua.html#63

Fügt einen Schiffshändler im Lagerhaus des Spielers hinzu.

 Optional kann eine Liste von Handelsrouten übergeben werden.





### Verwandte Themen:
<ul>


<a href="qsb_3_traderoutes.html#API.AddTradeRoute">API.AddTradeRoute</a>


</ul>



### Beispiel:
<ul>


<pre class="example">API.InitHarbor(<span class="number">2</span>);</pre>


</ul>


### API.RemoveTradeRoute (_PlayerID, _RouteName)
source/qsb_3_traderoutes.lua.html#284

Löscht eine Handelsroute, wenn ihr Zyklus beendet ist.

 Der Befehl erzeugt einen Job, welcher auf das Ende des Zyklus wartet und
 erst dann die Route löscht. Über die ID kann der Job abgebrochen werden.





### Verwandte Themen:
<ul>


<li><a href="qsb_3_traderoutes.html#API.InitHarbor">API.InitHarbor</a></li>


<li><a href="qsb_3_traderoutes.html#API.AddTradeRoute">API.AddTradeRoute</a></li>


<li><a href="qsb_3_traderoutes.html#API.ChangeTradeRouteGoods">API.ChangeTradeRouteGoods</a></li>


</ul>



### Beispiel:
<ul>


<pre class="example">API.RemoveTradeRoute(<span class="number">2</span>, <span class="string">"Route1"</span>);</pre>


</ul>


