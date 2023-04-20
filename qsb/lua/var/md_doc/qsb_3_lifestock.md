# Module <code>qsb_3_lifestock</code>
Schafe und Kühe können vom Spieler gezüchtet werden.
 Verschiedene Kenngrößen können angepasst werden.</p>

<p> Es wird ein Button an Kuh- und Schafställe angebracht. Damit kann die
 Zucht individuell angehalten oder fortgesetzt werden. Dieser Button
 belegt einen der 6 möglichen zusätzlichen Buttons bei den Ställen.</p>

<p> Wird im Produktionsmenü die Produktion von Kuh- oder Schaffarmen gestoppt,
 werden jeweils alle Kuh- oder Schafställe ebenfalls gestoppt. Wird die
 Produktion fortgeführt, wird auch die Zucht fortgeführt.</p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Ankeigekontrolle</a></li>
 <li><a href="modules.QSB_2_BuildingUI.QSB_2_BuildingUI.html">(2) Gebäudeschalter</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_3_lifestock.lua.html#34

Events, auf die reagiert werden kann.





### API.ActivateCattleBreeding (_Flag)
source/qsb_3_lifestock.lua.html#48

Erlaube oder verbiete dem Spieler Kühe zu züchten.

 Die Zucht wird immer synchron für alle Spieler erlaubt oder verboten.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Es können keine Kühe gezüchtet werden
</span>API.UseBreedCattle(<span class="keyword">false</span>);</pre>


</ul>


### API.ActivateSheepBreeding (_Flag)
source/qsb_3_lifestock.lua.html#78

Erlaube oder verbiete dem Spieler Schafe zu züchten.

 Die Zucht wird immer synchron für alle Spieler erlaubt oder verboten.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Schafsaufzucht ist erlaubt
</span>API.UseBreedSheeps(<span class="keyword">true</span>);</pre>


</ul>


### API.ConfigureCattleBreeding (_Data)
source/qsb_3_lifestock.lua.html#171

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






### Beispiel:
<ul>


<pre class="example">API.ConfigureCattleBreeding{
    <span class="comment">-- Es werden keine Tiere benötigt
</span>    RequiredAmount = <span class="number">0</span>,
    <span class="comment">-- Mindestzeit sind 3 Minuten
</span>    BreedingTimer = <span class="number">3</span>*<span class="number">60</span>
}</pre>


</ul>


### API.ConfigureSheepBreeding (_Data)
source/qsb_3_lifestock.lua.html#273

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






### Beispiel:
<ul>


<pre class="example">API.ConfigureSheepBreeding{
    <span class="comment">-- Es werden keine Tiere benötigt
</span>    RequiredAmount = <span class="number">0</span>,
    <span class="comment">-- Mindestzeit sind 3 Minuten
</span>    BreedingTimer = <span class="number">3</span>*<span class="number">60</span>
}</pre>


</ul>


