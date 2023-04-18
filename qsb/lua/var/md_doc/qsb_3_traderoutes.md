### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.AddTradeRoute (_PlayerID, _Route)

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


### API.ChangeTradeRouteGoods (_PlayerID, _RouteName, _RouteOffers)

Andert das Warenangebot einer Handelsroute.

 Es können nur bestehende Handelsrouten geändert werden. Die Änderung wird
 erst im nächsten Zyklus wirksam.


### API.DisposeHarbor (_PlayerID)

Entfernt den Schiffshändler vom Lagerhaus des Spielers.

 <b>Hinweis</b>: Die Routen werden sofort gelöscht. Schiffe, die sich mitten
 in ihrem Zyklus befinden, werden ebenfalls gelöscht und alle aktiven Angebote
 im Lagerhaus des KI-Spielers werden sofort entfernt. Nutze dies, wenn z.B.
 der KI-Spieler feindlich wird.


### API.InitHarbor (_PlayerID, ...)

Fügt einen Schiffshändler im Lagerhaus des Spielers hinzu.

 Optional kann eine Liste von Handelsrouten übergeben werden.


### API.RemoveTradeRoute (_PlayerID, _RouteName)

Löscht eine Handelsroute, wenn ihr Zyklus beendet ist.

 Der Befehl erzeugt einen Job, welcher auf das Ende des Zyklus wartet und
 erst dann die Route löscht. Über die ID kann der Job abgebrochen werden.


