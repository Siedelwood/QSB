# Module <code>qsb_3_dialogsystem</code>
Fügt Behavior zur Steuerung von Dialogs hinzu.




### Reprisal_Dialog (_Name, _Dialog)
source/qsb_3_dialogsystem.lua.html#20

Ruft die Funktion auf und startet das enthaltene Dialog.

 Jedes Dialog braucht einen eindeutigen Namen!






### Reward_Dialog (_Name, _Dialog)
source/qsb_3_dialogsystem.lua.html#78

Ruft die Funktion auf und startet das enthaltene Dialog.

 Jedes Dialog braucht einen eindeutigen Namen!






### Trigger_Dialog (_Name, _PlayerID, _Waittime)
source/qsb_3_dialogsystem.lua.html#105

Prüft, ob ein Dialog beendet ist und startet dann den Quest.





### QSB.ScriptEvents
source/qsb_3_dialogsystem.lua.html#204

Events, auf die reagiert werden kann.





### API.AddDialogPages (_Dialog)
source/qsb_3_dialogsystem.lua.html#363

Erzeugt die Funktionen zur Erstellung von Seiten in einem Dialog und bindet
 sie an selbigen.  Diese Funktion muss vor dem Start eines Dialog aufgerufen
 werden um Seiten hinzuzufügen.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Wenn nur AP benötigt wird.
</span><span class="keyword">local</span> AP = API.AddPages(Dialog);
<span class="comment">-- Wenn zusätzlich ASP benötigt wird.
</span><span class="keyword">local</span> AP, ASP = API.AddPages(Dialog);</pre>


</ul>


### API.IsDialogActive (_PlayerID)
source/qsb_3_dialogsystem.lua.html#340

Prüft ob für den Spieler gerade ein Dialog aktiv ist.





### API.StartDialog (_Dialog, _Name, _PlayerID)
source/qsb_3_dialogsystem.lua.html#288

Startet einen Dialog.

 Die Funktion bekommt ein Table mit der Dialogdefinition, wenn sie
 aufgerufen wird.

 <p>(→ Beispiel #1)</p>

 Für einen Dialog können verschiedene spezielle Einstellungen vorgenommen
 werden.<br>Mögliche Werte:
 <table border="1">
 <tr>
 <td><b>Einstellung</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>Starting</td>
 <td>function</td>
 <td>(Optional) Eine Funktion, die beim Start des Dialog ausgeführt wird.<br>
 Wird (im globalen Skript) vor QSB.ScriptEvents.DialogStarted aufgerufen!
 </td>
 </tr>
 <tr>
 <td>Finished</td>
 <td>function</td>
 <td>(Optional) Eine Funktion, die nach Beendigung des Dialog ausgeführt wird.<br>
 Wird (im globalen Skript) nach QSB.ScriptEvents.DialogEnded aufgerufen!
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
 <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange der Dialog aktiv ist. <br>Standard: ein</td>
 </tr>
 <tr>
 <td>EnableFoW</td>
 <td>boolean</td>
 <td>(Optional) Der Nebel des Krieges während des Dialog anzeigen. <br>Standard: aus</td>
 </tr>
 <tr>
 <td>EnableBorderPins</td>
 <td>boolean</td>
 <td>(Optional) Die Grenzsteine während des Dialog anzeigen. <br>Standard: aus</td>
 </tr>
 </table>






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Beispiel #1: Grobes Gerüst eines Briefings
</span><span class="keyword">function</span> Dialog1(_Name, _PlayerID)
    <span class="keyword">local</span> Dialog = {
        DisableFow = <span class="keyword">true</span>,
        DisableBoderPins = <span class="keyword">true</span>,
    };
    <span class="keyword">local</span> AP, ASP = API.AddDialogPages(Dialog);

    <span class="comment">-- Aufrufe von AP oder ASP um Seiten zu erstellen
</span>
    Dialog.Starting = <span class="keyword">function</span>(_Data)
        <span class="comment">-- Mach was tolles hier, wenn es anfängt.
</span>    <span class="keyword">end</span>
    Dialog.Finished = <span class="keyword">function</span>(_Data)
        <span class="comment">-- Mach was tolles hier, wenn es endet.
</span>    <span class="keyword">end</span>
    API.StartDialog(Dialog, _Name, _PlayerID);
<span class="keyword">end</span></pre>


</ul>


### AP (_Page)
source/qsb_3_dialogsystem.lua.html#602

Erstellt eine Seite für einen Dialog.

 <b>Achtung</b>: Diese Funktion wird von
 <a href="#API.AddPages">API.AddDialogPages</a> erzeugt und an
 den Dialog gebunden.

 <h5>Dialog Page</h5>
 Eine Dialog Page stellt den gesprochenen Text mit und ohne Akteur dar.

 <p>(→ Beispiel #1)</p>

 Mögliche Felder:
 <table border="1">
 <tr>
 <td><b>Einstellung</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>Actor</td>
 <td>number</td>
 <td>(optional) Spieler-ID des Akteur</td>
 </tr>
 <tr>
 <td>Titel</td>
 <td>string</td>
 <td>(optional) Zeigt den Namen des Sprechers an. (Nur mit Akteur)</td>
 </tr>
 <tr>
 <td>Text</td>
 <td>string</td>
 <td>(optional) Zeigt Text auf der Dialogseite an.</td>
 </tr>
 <tr>
 <td>Action</td>
 <td>function</td>
 <td>(optional) Führt eine Funktion aus, wenn die aktuelle Dialogseite angezeigt wird.</td>
 </tr>
 <tr>
 <td>Position</td>
 <td>any (string|number|table)</td>
 <td>Legt die Kameraposition der Seite fest.</td>
 </tr>
 <tr>
 <td>Target</td>
 <td>any (string|number)</td>
 <td>Legt das Entity fest, dem die Kamera folgt.</td>
 </tr>
 <tr>
 <td>Distance</td>
 <td>number</td>
 <td>(optional) Bestimmt die Entfernung der Kamera zur Position.</td>
 </tr>
 <tr>
 <td>Rotation</td>
 <td>number</td>
 <td>(optional) Rotationswinkel der Kamera. Werte zwischen 0 und 360 sind möglich.</td>
 </tr>
 <tr>
 <td>MC</td>
 <td>table</td>
 <td>(optional) Table mit möglichen Dialogoptionen. (Multiple Choice)</td>
 </tr>
 <tr>
 <td>FadeIn</td>
 <td>number</td>
 <td>(Optional) Dauer des Einblendens von Schwarz zu Beginn der Page.<br>
 Die Page benötigt eine Anzeigedauer!</td>
 </tr>
 <tr>
 <td>FadeOut</td>
 <td>number</td>
 <td>(Optional) Dauer des Abblendens zu Schwarz am Ende der Page.<br>
 Die Page benötigt eine Anzeigedauer!</td>
 </tr>
 <tr>
 <td>FaderAlpha</td>
 <td>number</td>
 <td>(Optional) Zeigt entweder die Blende an (1) oder nicht (0). Per Default
 wird die Blende nicht angezeigt. <br><b>Zwischen einer Seite mit FadeOut und
 der nächsten mit FadeIn muss immer eine Seite mit FaderAlpha sein!</b></td>
 </tr>
 </table>

 <br><h5>Multiple Choice</h5>
 In einem Dialog kann der Spieler auch zur Auswahl einer Option gebeten
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

 Um den Dialog zu beenden, nachdem ein Pfad beendet ist, wird eine leere
 AP-Seite genutzt. Auf diese Weise weiß der Dialog, das er an dieser
 Stelle zuende ist.

 <p>(→ Beispiel #5)</p>

 Soll stattdessen zu einer anderen Seite gesprungen werden, kann bei AP der
 Name der Seite angeben werden, zu der gesprungen werden soll.

 <p>(→ Beispiel #6)</p>

 Um später zu einem beliebigen Zeitpunkt die gewählte Antwort einer Seite zu
 erfahren, muss der Name der Seite genutzt werden.

 <p>(→ Beispiel #7)</p>

 Die zurückgegebene Zahl ist die ID der Antwort, angefangen von oben. Wird 0
 zurückgegeben, wurde noch nicht geantwortet.






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Eine einfache Seite erstellen
</span>AP {
    Title        = <span class="string">"Hero"</span>,
    Text         = <span class="string">"This page has an actor and a choice."</span>,
    Actor        = <span class="number">1</span>,
    Duration     = <span class="number">2</span>,
    FadeIn       = <span class="number">2</span>,
    Position     = <span class="string">"npc1"</span>,
    DialogCamera = <span class="keyword">true</span>,
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Verwendung von Multiple Choice
</span>AP {
    Title        = <span class="string">"Hero"</span>,
    Text         = <span class="string">"This page has an actor and a choice."</span>,
    Actor        = <span class="number">1</span>,
    Duration     = <span class="number">2</span>,
    FadeIn       = <span class="number">2</span>,
    Position     = <span class="string">"npc1"</span>,
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


<li><pre class="example"><span class="comment">-- Beispiel #5: Abbruch des Dialog
</span>AP()</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #6: Sprung zu anderer Seite
</span>AP(<span class="string">"SomePageName"</span>)</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #7: Erfragen der gewählten Antwort
</span>Dialog.Finished = <span class="keyword">function</span>(_Data)
    <span class="keyword">local</span> Choosen = _Data:GetPage(<span class="string">"Choice"</span>):GetSelected();
    <span class="comment">-- In Choosen steht der Index der Antwort
</span><span class="keyword">end</span></pre></li>


</ul>


### ASP (_Name, _Sender, _Target, _Title, _Text, _DialogCamera, _Action)
source/qsb_3_dialogsystem.lua.html#630

Erstellt eine Seite in vereinfachter Syntax.  Es wird davon ausgegangen, dass
 das Entity ein Siedler ist. Die Kamera schaut den Siedler an.

 <b>Achtung</b>: Diese Funktion wird von
 <a href="#API.AddPages">API.AddDialogPages</a> erzeugt und an
 den Dialog gebunden.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Beispiel ohne Page Name
</span>ASP(<span class="number">1</span>, <span class="string">"hans"</span>, <span class="string">"Hans"</span>, <span class="string">"Ich gehe in die weitel Welt hinein."</span>, <span class="keyword">true</span>);
<span class="comment">-- Beispiel mit Page Name
</span>ASP(<span class="string">"Page1"</span>, <span class="number">1</span>, <span class="string">"hans"</span>, <span class="string">"Hans"</span>, <span class="string">"Ich gehe in die weitel Welt hinein."</span>, <span class="keyword">true</span>);</pre>


</ul>


