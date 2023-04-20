# Module <code>qsb_3_cutscenesystem</code>
Fügt Behavior zur Steuerung von Cutscenes hinzu.




### Reprisal_Cutscene (_Name, _Cutscene)
source/qsb_3_cutscenesystem.lua.html#20

Ruft die Funktion auf und startet das enthaltene Cutscene.

 Jede Cutscene braucht einen eindeutigen Namen!






### Reward_Cutscene (_Name, _Cutscene)
source/qsb_3_cutscenesystem.lua.html#78

Ruft die Funktion auf und startet das enthaltene Cutscene.

 Jede Cutscene braucht einen eindeutigen Namen!






### Trigger_Cutscene (_Name, _PlayerID, _Waittime)
source/qsb_3_cutscenesystem.lua.html#105

Prüft, ob ein Cutscene beendet ist und startet dann den Quest.





### QSB.ScriptEvents
source/qsb_3_cutscenesystem.lua.html#203

Events, auf die reagiert werden kann.





### API.AddCutscenePages (_Cutscene)
source/qsb_3_cutscenesystem.lua.html#347

Erzeugt die Funktion zur Erstellung von Flights in einer Cutscene.  Diese
 Funktion muss vor dem Start einer Cutscene aufgerufen werden, damit Seiten
 gebunden werden können.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> AP = API.AddCutscenePages(Cutscene);</pre>


</ul>


### API.IsCutsceneActive (_PlayerID)
source/qsb_3_cutscenesystem.lua.html#328

Prüft ob für den Spieler gerade eine Cutscene aktiv ist.





### API.StartCutscene (_Cutscene, _Name, _PlayerID)
source/qsb_3_cutscenesystem.lua.html#282

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






### Beispiel:
<ul>


<pre class="example"><span class="keyword">function</span> Cutscene1(_Name, _PlayerID)
    <span class="keyword">local</span> Cutscene = {};
    <span class="keyword">local</span> AP = API.AddCutscenePages(Cutscene);

    <span class="comment">-- Aufrufe von AP um Seiten zu erstellen
</span>
    Cutscene.Starting = <span class="keyword">function</span>(_Data)
        <span class="comment">-- Mach was tolles hier wenn es anfängt.
</span>    <span class="keyword">end</span>
    Cutscene.Finished = <span class="keyword">function</span>(_Data)
        <span class="comment">-- Mach was tolles hier wenn es endet.
</span>    <span class="keyword">end</span>
    API.StartCutscene(Cutscene, _Name, _PlayerID);
<span class="keyword">end</span></pre>


</ul>


### AP (_Data)
source/qsb_3_cutscenesystem.lua.html#450

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






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Beispiel #1: Eine einfache Seite erstellen
</span>AP {
    <span class="comment">-- Dateiname der Cutscene ohne .cs
</span>    Flight       = <span class="string">"c02"</span>,
    <span class="comment">-- Maximale Renderdistanz
</span>    FarClipPlane = <span class="number">45000</span>,
    <span class="comment">-- Text
</span>    Title        = <span class="string">"Title"</span>,
    Text         = <span class="string">"Text of the flight."</span>,
};</pre>


</ul>


