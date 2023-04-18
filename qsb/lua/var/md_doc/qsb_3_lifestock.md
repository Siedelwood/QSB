### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.ActivateCattleBreeding (_Flag)

Erlaube oder verbiete dem Spieler Kühe zu züchten.

 Die Zucht wird immer synchron für alle Spieler erlaubt oder verboten.


### API.ActivateSheepBreeding (_Flag)

Erlaube oder verbiete dem Spieler Schafe zu züchten.

 Die Zucht wird immer synchron für alle Spieler erlaubt oder verboten.


### API.ConfigureCattleBreeding (_Data)

Konfiguriert die Zucht von Kühen.

 Die Konfiguration erfolgt immer synchron für alle Spieler.

 Mögliche Optionen:
 <table border="1">
 <tr>
 <td><b>Option</b></td>
 <td><b>Datentyp</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>RequiredAmount</td>
 <td>number</td>
 <td>Mindestanzahl an Tieren, die sich im Gebiet befinden müssen.
 (Default: 2)</td>
 </tr>
 <tr>
 <td>QuantityBoost</td>
 <td>number</td>
 <td>Menge an Sekunden, die jedes Tier im Gebiet die Zuchtauer verkürzt.
 (Default: 9)</td>
 </tr>
 <tr>
 <td>AreaSize</td>
 <td>number</td>
 <td>Größe des Gebietes, in dem Tiere für die Zucht vorhanden sein müssen.
 (Default: 4500)</td>
 </tr>
 <tr>
 <td>UseCalves</td>
 <td>boolean</td>
 <td>Gezüchtete Tiere erscheinen zuerst als Kälber und wachsen. Dies ist rein
 kosmetisch und hat keinen Einfluss auf die Produktion. (Default: true)</td>
 </tr>
 <tr>
 <td>CalvesSize</td>
 <td>number</td>
 <td>Bestimmt die initiale Größe der Kälber. Werden Kälber nicht benutzt, wird
 diese Option ignoriert. (Default: 0.45)</td>
 </tr>
 <tr>
 <td>FeedingTimer</td>
 <td>number</td>
 <td>Bestimmt die Zeit in Sekunden zwischen den Fütterungsperioden. Am Ende
 jeder Periode wird pro züchtendem Gatter 1 Getreide abgezogen, wenn das
 Gebäude nicht pausiert ist. (Default: 25)</td>
 </tr>
 <tr>
 <td>BreedingTimer</td>
 <td>number</td>
 <td>Bestimmt die Zeit in Sekunden, bis ein neues Tier erscheint. Wenn für
 eine Fütterung kein Getreide da ist, wird der Zähler zur letzten Fütterung
 zurückgesetzt. (Default: 150)</td>
 </tr>
 <tr>
 <td>GrothTimer</td>
 <td>number</td>
 <td>Bestimmt die Zeit in Sekunden zwischen den Wachstumsschüben eines
 Kalbs. Jeder Wachstumsschub ist +0.05 Gößenänderung. (Default: 15)</td>
 </tr>
 </table>


### API.ConfigureSheepBreeding (_Data)

Konfiguriert die Zucht von Schafen.

 Die Konfiguration erfolgt immer synchron für alle Spieler.

 Mögliche Optionen:
 <table border="1">
 <tr>
 <td><b>Option</b></td>
 <td><b>Datentyp</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>RequiredAmount</td>
 <td>number</td>
 <td>Mindestanzahl an Tieren, die sich im Gebiet befinden müssen.
 (Default: 2)</td>
 </tr>
 <tr>
 <td>QuantityBoost</td>
 <td>number</td>
 <td>Menge an Sekunden, die jedes Tier im Gebiet die Zuchtauer verkürzt.
 (Default: 9)</td>
 </tr>
 <tr>
 <td>AreaSize</td>
 <td>number</td>
 <td>Größe des Gebietes, in dem Tiere für die Zucht vorhanden sein müssen.
 (Default: 4500)</td>
 </tr>
 <tr>
 <td>UseCalves</td>
 <td>boolean</td>
 <td>Gezüchtete Tiere erscheinen zuerst als Kälber und wachsen. Dies ist rein
 kosmetisch und hat keinen Einfluss auf die Produktion. (Default: true)</td>
 </tr>
 <tr>
 <td>CalvesSize</td>
 <td>number</td>
 <td>Bestimmt die initiale Größe der Kälber. Werden Kälber nicht benutzt, wird
 diese Option ignoriert. (Default: 0.45)</td>
 </tr>
 <tr>
 <td>FeedingTimer</td>
 <td>number</td>
 <td>Bestimmt die Zeit in Sekunden zwischen den Fütterungsperioden. Am Ende
 jeder Periode wird pro züchtendem Gatter 1 Getreide abgezogen, wenn das
 Gebäude nicht pausiert ist. (Default: 30)</td>
 </tr>
 <tr>
 <td>BreedingTimer</td>
 <td>number</td>
 <td>Bestimmt die Zeit in Sekunden, bis ein neues Tier erscheint. Wenn für
 eine Fütterung kein Getreide da ist, wird der Zähler zur letzten Fütterung
 zurückgesetzt. (Default: 120)</td>
 </tr>
 <tr>
 <td>GrothTimer</td>
 <td>number</td>
 <td>Bestimmt die Zeit in Sekunden zwischen den Wachstumsschüben eines
 Kalbs. Jeder Wachstumsschub ist +0.05 Gößenänderung. (Default: 15)</td>
 </tr>
 </table>


