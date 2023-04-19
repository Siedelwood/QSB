# Module <code>qsb_1_guieffects</code>
Ermöglicht die Nutzung von verschiedenen Anzeigeeffekte.
 <h5>Cinematic Event</h5>
 <u>Ein Kinoevent hat nichts mit den Script Events zu tun!</u> <br>
 Es handelt sich um eine Markierung, ob für einen Spieler gerade ein Ereignis
 stattfindet, das das normale Spielinterface manipuliert und den normalen
 Spielfluss einschränkt. Es wird von der QSB benutzt um festzustellen, ob
 bereits ein solcher veränderter Zustand aktiv ist und entsorechend darauf
 zu reagieren, damit sichergestellt ist, dass beim Zurücksetzen des normalen
 Zustandes keine Fehler passieren.</p>

<p> Der Anwender braucht sich damit nicht zu befassen, es sei denn man plant
 etwas, das mit Kinoevents kollidieren kann. Wenn ein Feature ein Kinoevent
 auslöst, ist dies in der Dokumentation ausgewiesen.</p>

<p> Während eines Kinoevent kann zusätzlich nicht gespeichert werden.</p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_1_guieffects.lua.html#52

Events, auf die reagiert werden kann.





### API.ActivateBorderScroll (_PlayerID)
source/qsb_1_guieffects.lua.html#154

Akliviert border Scroll wieder und löst die Fixierung auf ein Entity auf.





### API.ActivateImageScreen (_PlayerID, _Image, _Red, _Green, _Blue, _Alpha)
source/qsb_1_guieffects.lua.html#77

Blendet eine Graphic über der Spielwelt aber hinter dem Interface ein.
 Die Grafik muss im 16:9-Format sein. Bei 4:3-Auflösungen wird
 links und rechts abgeschnitten.






### API.ActivateNormalInterface (_PlayerID)
source/qsb_1_guieffects.lua.html#118

Zeigt das normale Interface an.





### API.DeactivateBorderScroll (_PlayerID, _Position)
source/qsb_1_guieffects.lua.html#173

Deaktiviert Randscrollen und setzt die Kamera optional auf das Ziel





### API.DeactivateImageScreen (_PlayerID)
source/qsb_1_guieffects.lua.html#100

Deaktiviert ein angezeigtes Bild, wenn dieses angezeigt wird.





### API.DeactivateNormalInterface (_PlayerID)
source/qsb_1_guieffects.lua.html#136

Blendet das normale Interface aus.





### API.FinishCinematicEvent (_Name, _PlayerID)
source/qsb_1_guieffects.lua.html#216

Propagiert das Ende des Kinoevent.





### API.GetCinematicEvent (_Identifier, _PlayerID)
source/qsb_1_guieffects.lua.html#235

Gibt den Zustand des Kinoevent zurück.





### API.IsCinematicEventActive (_PlayerID)
source/qsb_1_guieffects.lua.html#260

Prüft ob gerade ein Kinoevent für den Spieler aktiv ist.





### API.StartCinematicEvent (_Name, _PlayerID)
source/qsb_1_guieffects.lua.html#199

Propagiert den Beginn des Kinoevent und bindet es an den Spieler.

 <b>Hinweis:</b>Während des aktiven Kinoevent kann nicht gespeichert werden.






### API.StartTypewriter (_Data)
source/qsb_1_guieffects.lua.html#361

Blendet einen Text Zeichen für Zeichen ein.

 Der Effekt startet erst, nachdem die Map geladen ist. Wenn ein anderes
 Cinematic Event läuft, wird gewartet, bis es beendet ist. Wärhend der Effekt
 läuft, können wiederrum keine Cinematic Events starten.

 Mögliche Werte:
 <table border="1">
 <tr>
 <td><b>Feldname</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>Text</td>
 <td>string|table</td>
 <td>Der anzuzeigene Text</td>
 </tr>
 <tr>
 <td>PlayerID</td>
 <td>number</td>
 <td>(Optional) Spieler, dem der Effekt angezeigt wird (Default: Menschlicher Spieler)</td>
 </tr>
 <tr>
 <td>Callback</td>
 <td>function</td>
 <td>(Optional) Funktion nach Abschluss der Textanzeige (Default: nil)</td>
 </tr>
 <tr>
 <td>TargetEntity</td>
 <td>string|number</td>
 <td>(Optional) TargetEntity der Kamera (Default: nil)</td>
 </tr>
 <tr>
 <td>CharSpeed</td>
 <td>number</td>
 <td>(Optional) Die Schreibgeschwindigkeit (Default: 1.0)</td>
 </tr>
 <tr>
 <td>Waittime</td>
 <td>number</td>
 <td>(Optional) Initiale Wartezeigt bevor der Effekt startet</td>
 </tr>
 <tr>
 <td>Opacity</td>
 <td>number</td>
 <td>(Optional) Durchsichtigkeit des Hintergrund (Default: 1)</td>
 </tr>
 <tr>
 <td>Color</td>
 <td>table</td>
 <td>(Optional) Farbe des Hintergrund (Default: {R= 0, G= 0, B= 0}}</td>
 </tr>
 <tr>
 <td>Image</td>
 <td>string</td>
 <td>(Optional) Pfad zur anzuzeigenden Grafik</td>
 </tr>
 </table>

 <b>Hinweis</b>: Steuerzeichen wie {cr} oder {@color} werden als ein Token
 gewertet und immer sofort eingeblendet. Steht z.B. {cr}{cr} im Text, werden
 die Zeichen atomar behandelt, als seien sie ein einzelnes Zeichen.
 Gibt es mehr als 1 Leerzeichen hintereinander, werden alle zusammenhängenden
 Leerzeichen (vom Spiel) auf ein Leerzeichen reduziert!






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> EventName = API.StartTypewriter {
    PlayerID = <span class="number">1</span>,
    Text     = <span class="string">"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "</span>..
               <span class="string">"sed diam nonumy eirmod tempor invidunt ut labore et dolore"</span>..
               <span class="string">"magna aliquyam erat, sed diam voluptua. At vero eos et"</span>..
               <span class="string">" accusam et justo duo dolores et ea rebum. Stet clita kasd"</span>..
               <span class="string">" gubergren, no sea takimata sanctus est Lorem ipsum dolor"</span>..
               <span class="string">" sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"</span>..
               <span class="string">" elitr, sed diam nonumy eirmod tempor invidunt ut labore et"</span>..
               <span class="string">" dolore magna aliquyam erat, sed diam voluptua. At vero eos"</span>..
               <span class="string">" et accusam et justo duo dolores et ea rebum. Stet clita"</span>..
               <span class="string">" kasd gubergren, no sea takimata sanctus est Lorem ipsum"</span>..
               <span class="string">" dolor sit amet."</span>,
    Callback = <span class="keyword">function</span>(_Data)
        <span class="comment">-- Hier kann was passieren
</span>    <span class="keyword">end</span>
};</pre>


</ul>


