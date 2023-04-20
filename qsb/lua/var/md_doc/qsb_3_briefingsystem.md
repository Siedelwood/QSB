# Module <code>qsb_3_briefingsystem</code>
Fügt Behavior zur Steuerung von Briefings hinzu.




### Reprisal_Briefing (_Name, _Briefing)
source/qsb_3_briefingsystem.lua.html#20

Ruft die Funktion auf und startet das enthaltene Briefing.

 Jedes Briefing braucht einen eindeutigen Namen!






### Reward_Briefing (_Name, _Briefing)
source/qsb_3_briefingsystem.lua.html#78

Ruft die Funktion auf und startet das enthaltene Briefing.

 Jedes Briefing braucht einen eindeutigen Namen!






### Trigger_Briefing (_Name, _PlayerID, _Waittime)
source/qsb_3_briefingsystem.lua.html#105

Prüft, ob ein Briefing beendet ist und startet dann den Quest.





### QSB.ScriptEvents
source/qsb_3_briefingsystem.lua.html#204

Events, auf die reagiert werden kann.





### API.AddBriefingPages (_Briefing)
source/qsb_3_briefingsystem.lua.html#508

Erzeugt die Funktionen zur Erstellung von Seiten und Animationen in einem
 Briefing.  Diese Funktion muss vor dem Start eines Briefing aufgerufen werden,
 damit Seiten gebunden werden können. Je nach Bedarf können Rückgaben von
 rechts nach links weggelassen werden.





### Verwandte Themen:
<ul>


<a href="qsb_3_briefingsystem.html#API.StartBriefing">API.StartBriefing</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Wenn nur AP benötigt wird.
</span><span class="keyword">local</span> AP = API.AddBriefingPages(Briefing);
<span class="comment">-- Wenn zusätzlich ASP benötigt wird.
</span><span class="keyword">local</span> AP, ASP = API.AddBriefingPages(Briefing);</pre>


</ul>


### API.IsBriefingActive (_PlayerID)
source/qsb_3_briefingsystem.lua.html#483

Prüft ob für den Spieler gerade ein Briefing aktiv ist.





### API.StartBriefing (_Briefing, _Name, _PlayerID)
source/qsb_3_briefingsystem.lua.html#431

Startet ein Briefing.

 Die Funktion bekommt ein Table mit der Briefingdefinition, wenn sie
 aufgerufen wird.

 <p>(→ Beispiel #1)</p>

 <h5>Einstellungen</h5>
 Für ein Briefing können verschiedene spezielle Einstellungen vorgenommen
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
 <td>(Optional) Eine Funktion, die beim Start des Briefing ausgeführt wird.<br>
 Wird (im globalen Skript) vor QSB.ScriptEvents.BriefingStarted aufgerufen!
 </td>
 </tr>
 <tr>
 <td>Finished</td>
 <td>function</td>
 <td>(Optional) Eine Funktion, die nach Beendigung des Briefing ausgeführt wird.<br>
 Wird (im globalen Skript) nach QSB.ScriptEvents.BriefingEnded aufgerufen!
 </td>
 </tr>
 <tr>
 <td>RestoreCamera</td>
 <td>boolean</td>
 <td>(Optional) Stellt die Kameraposition am Ende des Dialog wieder her. <br>Standard: ein</td>
 </tr>
 <tr>
 <td>RestoreGameSpeed</td>
 <td>boolean</td>
 <td>(Optional) Stellt die Geschwindigkeit von vor dem Dialog wieder her. <br>Standard: ein</td>
 </tr>
 <tr>
 <td>EnableGlobalImmortality</td>
 <td>boolean</td>
 <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange das Briefing aktiv ist. <br>Standard: ein</td>
 </tr>
 <tr>
 <td>EnableSky</td>
 <td>boolean</td>
 <td>(Optional) Der Himmel wird während des Briefing angezeigt. <br>Standard: ein</td>
 </tr>
 <tr>
 <td>EnableFoW</td>
 <td>boolean</td>
 <td>(Optional) Der Nebel des Krieges wird während des Briefing angezeigt. <br>Standard: aus</td>
 </tr>
 <tr>
 <td>EnableBorderPins</td>
 <td>boolean</td>
 <td>(Optional) Die Grenzsteine werden während des Briefing angezeigt. <br>Standard: aus</td>
 </tr>
 </table>

 <h5>Animationen</h5>
 Kameraanimationen für Seiten eines Briefings können vom Text einer Page
 entkoppelt werden. Das hat den Charme, dass Spielfiguren erzählen und
 erzählen und die Kamera über die ganze Zeit die gleiche Animation zeigt,
 was das Lesen angenehmer macht.

 <b>Hinweis:</b> Animationen werden nur erzeugt, wenn die Page noch keine
 Position hat! Andernfalls werden die Werte für Angle, Rotation und Zoom
 aus der Page genommen und/oder Defaults verwendet.

 Animationen können über eine Table angegeben werden. Diese wird direkt
 in die Briefing Table geschrieben. Die Animation wird die Kamera dann von
 Position 1 zu Position 2 bewegen. Dabei ist die zweite Position optional
 und kann weggelassen werden.

 <p>(→ Beispiel #2)</p>
 <p>(→ Beispiel #3)</p>
 <p>(→ Beispiel #4)</p>

 <h5>Parallax</h5>
 Unter Parallax versteht man (im Kontext eines Videospiels) einen Hintergrund,
 dessen Bildausschnitt veränderlich ist. So wurden früher z.B. der Hintergrund
 eines Side Scrollers (Super Mario, Sonic, ...) realisiert.

 Während eines Briefings können bis zu 6 übereinander liegende Ebenen solcher
 Parallaxe verwendet werden. Dabei wird eine Grafik vorgegeben, die durch
 Angabe von UV-Koordinaten und Alphawert animiert werden kann. Diese Grafiken
 liegen hinter allen Elementen des Thronerooms.

 Parallaxe können über eine Table angegeben werden. Diese wird direkt in die
 Briefing Table geschrieben. Jede Ebene kann getrennt von den anderen agieren.
 Ein Parallax kann statisch ein Bild anzeigen oder animiert sein. In diesem
 Fall wird sich von Position 1 zu Position 2 bewegt, wobei Position 2 optional
 ist und weggelassen werden kann.

 Die UV-Koordinaten ergeben zwei Punkte auf der Grafik aus der ein Rechteck
 ergänzt wird. Die Koordinaten können entweder pixelgenau order relativ
 angegeben werden. Pixelgenau bedeutet, dass man einen Punkt exakt an einer
 bestimmten Position auf der Grafik auswählt und setzt (z.B. 100, 50). Gibt
 man relative Werte an, dann benutzt man Zahlen zwischen 0 und 1, wobei 0 für
 0% und 1 für 100% steht. In jedem Fall sind die Koordinaten absolut oder
 relativ zur Grafik und nicht zur Bildschirmgröße.

 <b>Achtung:</b> Die Grafiken müssen immer im 16:9 Format sein. Für den Fall,
 dass das Spiel in einer 4:3 Auflösung gespielt wird, werden automatisch die
 angegebenen Koordinaten umgerechnet und links und rechts abgeschnitten.
 Konzipiere Grafiken also stets so, dass sie auch im 4:3 Format noch das
 wichtigste zeigen.

 <p>(→ Beispiel #5)</p>
 <p>(→ Beispiel #6)</p>






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Grobes Gerüst eines Briefings
</span><span class="keyword">function</span> Briefing1(_Name, _PlayerID)
    <span class="keyword">local</span> Briefing = {
        <span class="comment">-- Hier können verschiedene Konfigurationen vorgenommen werden.
</span>    };
    <span class="keyword">local</span> AP, ASP = API.AddBriefingPages(Briefing);

    <span class="comment">-- Aufrufe von AP oder ASP um Seiten zu erstellen
</span>
    Briefing.Starting = <span class="keyword">function</span>(_Data)
        <span class="comment">-- Mach was tolles hier, wenn es anfängt.
</span>    <span class="keyword">end</span>
    Briefing.Finished = <span class="keyword">function</span>(_Data)
        <span class="comment">-- Mach was tolles hier, wenn es endet.
</span>    <span class="keyword">end</span>
    <span class="comment">-- Das Briefing wird gestartet
</span>    API.StartBriefing(Briefing, _Name, _PlayerID);
<span class="keyword">end</span></pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Angabe von Animationen
</span>Briefing.PageAnimations = {
    [<span class="string">"Page1"</span>] = {
        <span class="comment">-- Relativdarstellung
</span>        <span class="comment">-- Animationsdauer, Position1, Rotation1, Zoom1, Angle1, Position2, Rotation2, Zoom2, Angle2
</span>        {<span class="number">30</span>, <span class="string">"pos4"</span>, -<span class="number">60</span>, <span class="number">2000</span>, <span class="number">35</span>, <span class="string">"pos4"</span>, -<span class="number">30</span>, <span class="number">2000</span>, <span class="number">25</span>},
        <span class="comment">-- Hier können weitere Animationen folgen...
</span>    },
    [<span class="string">"Page3"</span>] = {
        <span class="comment">-- Vektordarstellung
</span>        <span class="comment">-- Animationsdauer, {Position1, Höhe}, {LookAt1, Höhe}, {Position2, Höhe}, {LookAt2, Höhe}
</span>        {<span class="number">30</span>, {<span class="string">"pos2"</span>, <span class="number">500</span>}, {<span class="string">"pos4"</span>, <span class="number">0</span>}, {<span class="string">"pos7"</span>, <span class="number">1000</span>}, {<span class="string">"pos8"</span>, <span class="number">0</span>}},
        <span class="comment">-- Hier können weitere Animationen folgen...
</span>    },
    <span class="comment">-- Hier können weitere Pages folgen...
</span>};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #3: Laufende Animationen ersetzen
</span>Briefing.PageAnimations = {
    [<span class="string">"Page1"</span>] = {
        <span class="comment">-- Löscht alle laufenden Animationen
</span>        Clear = <span class="keyword">true</span>,
        {<span class="number">30</span>, <span class="string">"pos4"</span>, -<span class="number">60</span>, <span class="number">2000</span>, <span class="number">35</span>, <span class="string">"pos4"</span>, -<span class="number">30</span>, <span class="number">2000</span>, <span class="number">25</span>},
    },
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #4: Animation in Endlosschleife
</span>Briefing.PageAnimations = {
    [<span class="string">"Page1"</span>] = {
        <span class="comment">-- Lässt die Animationen sich wiederholen
</span>        Repeat = <span class="keyword">true</span>,
        {<span class="number">30</span>, <span class="string">"pos4"</span>,   <span class="number">0</span>, <span class="number">4000</span>, <span class="number">35</span>, <span class="string">"pos4"</span>, <span class="number">180</span>, <span class="number">4000</span>, <span class="number">35</span>},
        {<span class="number">30</span>, <span class="string">"pos4"</span>, <span class="number">180</span>, <span class="number">4000</span>, <span class="number">35</span>, <span class="string">"pos4"</span>, <span class="number">360</span>, <span class="number">4000</span>, <span class="number">35</span>},
    },
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #5: Angabe von Parallaxen
</span>Briefing.PageParallax = {
    [<span class="string">"Page1"</span>] = {
        <span class="comment">-- Bilddatei, Anzeigedauer,
</span>        <span class="comment">-- U0Start, V0Start, U1Start, V1Start, AlphaStart,
</span>        <span class="comment">-- U0End, V0End, U1End, V1End, AlphaEnd
</span>        {<span class="string">"maps/externalmap/mapname/graphics/Parallax6.png"</span>, <span class="number">60</span>,
         <span class="number">0</span>, <span class="number">0</span>, <span class="number">0.8</span>, <span class="number">1</span>, <span class="number">255</span>,
         <span class="number">0.2</span>, <span class="number">0</span>, <span class="number">1</span>, <span class="number">1</span>, <span class="number">255</span>},
        <span class="comment">-- Hier können weitere Einträge folgen...
</span>    },
    [<span class="string">"Page3"</span>] = {
        <span class="comment">-- Bilddatei, Anzeigedauer,
</span>        <span class="comment">-- U0Start, V0Start, U1Start, V1Start, AlphaStart
</span>        {<span class="string">"maps/externalmap/mapname/graphics/Parallax1.png"</span>, <span class="number">1</span>,
         <span class="number">0</span>, <span class="number">0</span>, <span class="number">1</span>, <span class="number">1</span>, <span class="number">180</span>},
        <span class="comment">-- Hier können weitere Einträge folgen...
</span>    }
    <span class="comment">-- Hier können weitere Pages folgen...
</span>};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #6: Laufende Parallaxe ersetzen
</span>Briefing.PageParallax = {
    [<span class="string">"Page1"</span>] = {
        <span class="comment">-- Löscht alle laufenden Paralaxe
</span>        Clear = <span class="keyword">true</span>,
        {<span class="string">"maps/externalmap/mapname/graphics/Parallax6.png"</span>,
         <span class="number">60</span>, <span class="number">0</span>, <span class="number">0</span>, <span class="number">0.8</span>, <span class="number">1</span>, <span class="number">255</span>, <span class="number">0.2</span>, <span class="number">0</span>, <span class="number">1</span>, <span class="number">1</span>, <span class="number">255</span>},
    },
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #7: Parallaxe im Vordergrund
</span>Briefing.PageParallax = {
    [<span class="string">"Page1"</span>] = {
        <span class="comment">-- Parallaxe erscheinen im Vordergrund
</span>        Foreground = <span class="keyword">true</span>,
        {<span class="string">"maps/externalmap/mapname/graphics/Parallax6.png"</span>,
         <span class="number">60</span>, <span class="number">0</span>, <span class="number">0</span>, <span class="number">0.8</span>, <span class="number">1</span>, <span class="number">255</span>, <span class="number">0.2</span>, <span class="number">0</span>, <span class="number">1</span>, <span class="number">1</span>, <span class="number">255</span>},
    },
};</pre></li>


</ul>


### AP (_Data)
source/qsb_3_briefingsystem.lua.html#816

Erzeugt eine neue Seite für das Briefing.

 <b>Achtung</b>: Diese Funktion wird von
 <a href="#API.AddBriefingPages">API.AddBriefingPages</a> erzeugt und an
 das Briefing gebunden.

 <h5>Briefing Page</h5>
 Die Briefing Page definiert, was zum Zeitpunkt ihrer Anzeige dargestellt
 wird.

 <p>(→ Beispiel #1)</p>

 Folgende Parameter werden als Felder (Name = Wert) übergeben:
 <table border="1">
 <tr>
 <td><b>Feldname</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
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
 <td>Position</td>
 <td>string</td>
 <td>Striptname des Entity, welches die Kamera ansieht.</td>
 </tr>
 <tr>
 <td>Duration</td>
 <td>number</td>
 <td>(Optional) Bestimmt, wie lange die Page angezeigt wird. Wird es
 weggelassen, wird automatisch eine Anzeigezeit anhand der Textlänge bestimmt.
 Diese ist immer mindestens 6 Sekunden.</td>
 </tr>
 <tr>
 <td>DialogCamera</td>
 <td>boolean</td>
 <td>(Optional) Eine Boolean, welche angibt, ob Nah- oder Fernsicht benutzt
 wird.</td>
 </tr>
 <tr>
 <td>DisableSkipping</td>
 <td>boolean</td>
 <td>(Optional) Das Überspringen der Seite wird unterbunden.</td>
 </tr>
 <tr>
 <td>Action</td>
 <td>function</td>
 <td>(Optional) Eine Funktion, die jedes Mal ausgeführt wird, sobald
 die Seite angezeigt wird.</td>
 </tr>
 <tr>
 <td>FarClipPlane</td>
 <td>number</td>
 <td>(Optional) Renderdistanz für die Seite (Default 100000).
 wird.</td>
 </tr>
 <tr>
 <tr>
 <td>Rotation</td>
 <td>number</td>
 <td>(Optional) Rotation der Kamera gibt den Winkel an, indem die Kamera
 um das Ziel gedreht wird.</td>
 </tr>
 <tr>
 <td>Zoom</td>
 <td>number</td>
 <td>(Optional) Zoom bestimmt die Entfernung der Kamera zum Ziel.</td>
 </tr>
 <tr>
 <td>Angle</td>
 <td>number</td>
 <td>(Optional) Angle gibt den Winkel an, in dem die Kamera gekippt wird.
 </td>
 </tr>
 <tr>
 <td>FlyTo</td>
 <td>table</td>
 <td>(Optional) Kann ein zweites Set von Position, Rotation, Zoom und Angle
 enthalten, zudem sich die Kamera dann bewegt.
 </td>
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
 <td>BarOpacity</td>
 <td>number</td>
 <td>(Optional) Setzt den Alphawert der Bars (Zwischen 0 und 1).</td>
 </tr>
 <tr>
 <td>BigBars</td>
 <td>boolean</td>
 <td>(Optional) Schalted breite Balken ein oder aus.</td>
 </tr>
 <tr>
 <td>MC</td>
 <td>table</td>
 <td>(Optional) Liste von Optionen zur Verzweigung des Briefings. Dies kann
 benutzt werden, um z.B. Dialoge mit Antwortmöglichkeiten zu erstellen.</td>
 </tr>
 </table>

 <h5>Multiple Choice</h5>
 In einem Briefing kann der Spieler auch zur Auswahl einer Option gebeten
 werden. Dies wird als Multiple Choice bezeichnet. Schreibe die Optionen
 in eine Untertabelle MC.

 <p>(→ Beispiel #2)</p>

 Es kann der Name der Zielseite angegeben werden, oder eine Funktion, die
 den Namen des Ziels zurück gibt. In der Funktion können vorher beliebige
 Dinge getan werden, wie z.B. Variablen setzen.

 Eine Antwort kann markiert werden, dass sie auch bei einem Rücksprung,
 nicht mehrfach gewählt werden kann. In diesem Fall ist sie bei erneutem
 Aufsuchen der Seite nicht mehr gelistet.

 <p>(→ Beispiel #3)</p>

 Eine Option kann auch bedingt ausgeblendet werden. Dazu wird eine Funktion
 angegeben, welche über die Sichtbarkeit entscheidet.

 <p>(→ Beispiel #4)</p>

 Nachdem der Spieler eine Antwort gewählt hat, wird er auf die Seite mit
 dem angegebenen Namen geleitet.

 Um das Briefing zu beenden, nachdem ein Pfad beendet ist, wird eine leere
 AP-Seite genutzt. Auf diese Weise weiß das Briefing, das es an dieser
 Stelle zuende ist.

 <p>(→ Beispiel #5)</p>

 Soll stattdessen zu einer anderen Seite gesprungen werden, kann bei AP der
 Name der Seite angeben werden, zu der gesprungen werden soll.

 <p>(→ Beispiel #6)</p>

 Um später zu einem beliebigen Zeitpunkt die gewählte Antwort einer Seite zu
 erfahren, muss der Name der Seite genutzt werden.

 Die zurückgegebene Zahl ist die ID der Antwort, angefangen von oben. Wird 0
 zurückgegeben, wurde noch nicht geantwortet.

 <p>(→ Beispiel #7)</p>






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Eine einfache Seite erstellen
</span>AP {
   <span class="comment">-- Hier werden die Attribute der Page angegeben
</span>   Title        = <span class="string">"Marcus"</span>,
   Text         = <span class="string">"Das ist eine simple Seite."</span>,
   Position     = <span class="string">"Marcus"</span>,
   Rotation     = <span class="number">30</span>,
   DialogCamera = <span class="keyword">true</span>,
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Verwendung von Multiple Choice
</span>AP {
   Title        = <span class="string">"Marcus"</span>,
   Text         = <span class="string">"Das ist eine nicht so simple Seite."</span>,
   Position     = <span class="string">"Marcus"</span>,
   Rotation     = <span class="number">30</span>,
   DialogCamera = <span class="keyword">true</span>,
   <span class="comment">-- MC ist das Table mit den auswählbaren Antworten
</span>   MC = {
       <span class="comment">-- Zielseite ist der Name der Page, zu der gesprungen wird.
</span>       {<span class="string">"Antwort 1"</span>, <span class="string">"Zielseite"</span>},
       <span class="comment">-- Option2Clicked ist eine Funktion, die etwas macht und
</span>       <span class="comment">-- danach die Page zurückgibt, zu der gesprungen wird.
</span>       {<span class="string">"Antwort 2"</span>, Option2Clicked},
   },
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #3: Antwort, die nur einmal gewählt werden kann
</span>MC = {
    {<span class="string">"Antwort 3"</span>, <span class="string">"AnotherPage"</span>, Remove = <span class="keyword">true</span>},
}</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #4: Antwort mit gesteuerter Sichtbarkeit
</span>MC = {
    {<span class="string">"Antwort 3"</span>, <span class="string">"AnotherPage"</span>, Disable = OptionIsDisabled},
}</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #5: Abbruch des Briefings
</span>AP()</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #6: Sprung zu anderer Seite
</span>AP(<span class="string">"SomePageName"</span>)</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #7: Erfragen der gewählten Antwort
</span>Briefing.Finished = <span class="keyword">function</span>(_Data)
    <span class="keyword">local</span> Choosen = _Data:GetPage(<span class="string">"Choice"</span>):GetSelected();
    <span class="comment">-- In Choosen steht der Index der Antwort
</span><span class="keyword">end</span></pre></li>


</ul>


### ASP (...)
source/qsb_3_briefingsystem.lua.html#901

Erzeugt eine neue Seite für das Briefing in Kurzschreibweise.

 <b>Achtung</b>: Diese Funktion wird von
 <a href="#API.AddBriefingPages">API.AddBriefingPages</a> erzeugt und an
 das Briefing gebunden.

 Die Seite erhält automatisch einen Namen, entsprechend der Reihenfolge aller
 Seitenaufrufe von AP oder ASP. Werden also vor dem Aufruf bereits 2 Seiten
 erzeugt, so würde die Seite den Namen "Page3" erhalten.

 Folgende Parameter werden in <u>genau dieser Reihenfolge</u> an die Funktion
 übergeben:
 <table border="1">
 <tr>
 <td><b>Bezeichnung</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>Name</td>
 <td>string</td>
 <td>Der interne Name der Page.</td>
 </tr>
 <tr>
 <td>Title</td>
 <td>string|table</td>
 <td>Der angezeigte Titel der Seite. Es können auch Text Keys oder
 lokalisierte Tables übergeben werden.</td>
 </tr>
 <tr>
 <td>Text</td>
 <td>string|table</td>
 <td>Der angezeigte Text der Seite. Es können auch Text Keys oder
 lokalisierte Tables übergeben werden.</td>
 </tr>
 <tr>
 <td>DialogCamera</td>
 <td>boolean</td>
 <td>Die Kamera geht in Nahsicht und stellt Charaktere dar. Wird
 sie weggelassen, wird die Fernsicht verwendet.</td>
 </tr>
 <tr>
 <td>Position</td>
 <td>string</td>
 <td>(Optional) Skriptname des Entity zu das die Kamera springt.</td>
 </tr>
 <tr>
 <td>Action</td>
 <td>function</td>
 <td>(Optional) Eine Funktion, die jedes Mal ausgeführt wird, wenn die Seite
 angezeigt wird.</td>
 </tr>
 <tr>
 <td>EnableSkipping</td>
 <td>boolean</td>
 <td>(Optional) Steuert, ob die Seite übersprungen werden darf. Wenn es nicht
 angegeben wird, ist das Überspringen immer deaktiviert.</td>
 </tr>
 </table>






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Hinweis dazu: In Lua werden Parameter von links nach rechts aufgelöst.
</span><span class="comment">-- Will man also Parameter weglassen, wenn danach noch welche folgen, muss
</span><span class="comment">-- man die Leerstellen mit nil auffüllen.
</span>
<span class="comment">-- Fernsicht
</span>ASP(<span class="string">"Title"</span>, <span class="string">"Some important text."</span>, <span class="keyword">false</span>, <span class="string">"HQ"</span>);
<span class="comment">-- Page Name
</span>ASP(<span class="string">"Page1"</span>, <span class="string">"Title"</span>, <span class="string">"Some important text."</span>, <span class="keyword">false</span>, <span class="string">"HQ"</span>);
<span class="comment">-- Nahsicht
</span>ASP(<span class="string">"Title"</span>, <span class="string">"Some important text."</span>, <span class="keyword">true</span>, <span class="string">"Marcus"</span>);
<span class="comment">-- Aktion ausführen
</span>ASP(<span class="string">"Title"</span>, <span class="string">"Some important text."</span>, <span class="keyword">true</span>, <span class="string">"Marcus"</span>, MyFunction);
<span class="comment">-- Überspringen erlauben/verbieten
</span>ASP(<span class="string">"Title"</span>, <span class="string">"Some important text."</span>, <span class="keyword">true</span>, <span class="string">"HQ"</span>, <span class="keyword">nil</span>, <span class="keyword">true</span>);</pre>


</ul>


