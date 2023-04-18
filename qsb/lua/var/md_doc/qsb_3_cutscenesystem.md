### Reprisal_Cutscene (_Name, _Cutscene)

Ruft die Funktion auf und startet das enthaltene Cutscene.

 Jede Cutscene braucht einen eindeutigen Namen!


### Reward_Cutscene (_Name, _Cutscene)

Ruft die Funktion auf und startet das enthaltene Cutscene.

 Jede Cutscene braucht einen eindeutigen Namen!


### Trigger_Cutscene (_Name, _PlayerID, _Waittime)

Prüft, ob ein Cutscene beendet ist und startet dann den Quest.

### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.AddCutscenePages (_Cutscene)

Erzeugt die Funktion zur Erstellung von Flights in einer Cutscene.  Diese
 Funktion muss vor dem Start einer Cutscene aufgerufen werden, damit Seiten
 gebunden werden können.


### API.IsCutsceneActive (_PlayerID)

Prüft ob für den Spieler gerade eine Cutscene aktiv ist.

### API.StartCutscene (_Cutscene, _Name, _PlayerID)

Startet eine Cutscene.

 Die Funktion bekommt ein Table mit der Definition der Cutscene, wenn sie
 aufgerufen wird.

 <p>(→ Beispiel #1)</p>

 <h5>Einstellungen</h5>
 Für eine Cutscene können verschiedene spezielle Einstellungen vorgenommen
 werden.

 Mögliche Werte:
 <table border="1">
 <tr>
 <td><b>Feldname</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>Starting</td>
 <td>function</td>
 <td>(Optional) Eine Funktion, die beim Start der Cutscene ausgeführt wird.<br>
 Wird (im globalen Skript) vor QSB.ScriptEvents.CutsceneStarted aufgerufen!
 </td>
 </tr>
 <tr>
 <td>Finished</td>
 <td>function</td>
 <td>(Optional) Eine Funktion, die nach Beendigung der Cutscene ausgeführt wird.<br>
 Wird (im globalen Skript) nach QSB.ScriptEvents.CutsceneEnded aufgerufen!
 </td>
 </tr>
 <tr>
 <td>EnableGlobalImmortality</td>
 <td>boolean</td>
 <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange die Cutscene aktiv ist. <br>Standard: ein</td>
 </tr>
 <tr>
 <td>EnableSky</td>
 <td>boolean</td>
 <td>(Optional) Der Himmel wird während der Cutscene angezeigt. <br>Standard: ein</td>
 </tr>
 <tr>
 <td>EnableFoW</td>
 <td>boolean</td>
 <td>(Optional) Der Nebel des Krieges wird während der Cutscene angezeigt. <br>Standard: aus</td>
 </tr>
 <tr>
 <td>EnableBorderPins</td>
 <td>boolean</td>
 <td>(Optional) Die Grenzsteine werden während der Cutscene angezeigt. <br>Standard: aus</td>
 </tr>
 </table>


### AP (_Data)

Erzeugt einen neuen Flight für die Cutscene.

 <p>(→ Beispiel #1)</p>

 <b>Achtung</b>: Diese Funktion wird von
 <a href="#API.AddCutscenePages">API.AddCutscenePages</a> erzeugt und an
 die Cutscene gebunden.

 Folgende Parameter werden als Felder (Name = Wert) übergeben:
 <table border="1">
 <tr>
 <td><b>Feldname</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>Flight</td>
 <td>string</td>
 <td>Name der CS-Datei ohne Dateiendung</td>
 </tr>
 <tr>
 <td>Title</td>
 <td>string|table</td>
 <td>Der Titel, der oben angezeigt wird. Es ist möglich eine Table mit
 deutschen und englischen Texten anzugeben.</td>
 </tr>
 <tr>
 <td>Text</td>
 <td>string|table</td>
 <td>Der Text, der unten angezeigt wird. Es ist möglich eine Table mit
 deutschen und englischen Texten anzugeben.</td>
 </tr>
 <tr>
 <td>Action</td>
 <td>function</td>
 <td>(Optional) Eine Funktion, die ausgeführt wird, sobald der Flight
 angezeigt wird.</td>
 </tr>
 <tr>
 <td>FarClipPlane</td>
 <td>number</td>
 <td>(Optional) Renderdistanz für die Seite (Default 35000).
 wird.</td>
 </tr>
 <tr>
 <td>FadeIn</td>
 <td>number</td>
 <td>(Optional) Dauer des Einblendens von Schwarz zu Beginn des Flight.</td>
 </tr>
 <tr>
 <td>FadeOut</td>
 <td>number</td>
 <td>(Optional) Dauer des Abblendens zu Schwarz am Ende des Flight.</td>
 </tr>
 <tr>
 <td>FaderAlpha</td>
 <td>number</td>
 <td>(Optional) Zeigt entweder die Blende an (1) oder nicht (0). Per Default
 wird die Blende nicht angezeigt. <br><b>Zwischen einer Seite mit FadeOut und
 der nächsten mit Fade In muss immer eine Seite mit FaderAlpha sein!</b></td>
 </tr>
 <tr>
 <td>DisableSkipping</td>
 <td>boolean</td>
 <td>(Optional) Die Fast Forward Aktion wird unterbunden. Außerdem wird die Beschleunigung automatisch aufgehoben.</td>
 </tr>
 <tr>
 <td>BigBars</td>
 <td>boolean</td>
 <td>(Optional) Schalted breite Balken ein oder aus.</td>
 </tr>
 <tr>
 <td>BarOpacity</td>
 <td>number</td>
 <td>(Optional) Setzt den Alphawert der Bars (Zwischen 0 und 1).</td>
 </tr>
 </table>


