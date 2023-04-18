### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.ActivateBorderScroll (_PlayerID)

Akliviert border Scroll wieder und löst die Fixierung auf ein Entity auf.

### API.ActivateImageScreen (_PlayerID, _Image, _Red, _Green, _Blue, _Alpha)

Blendet eine Graphic über der Spielwelt aber hinter dem Interface ein.
 Die Grafik muss im 16:9-Format sein. Bei 4:3-Auflösungen wird
 links und rechts abgeschnitten.


### API.ActivateNormalInterface (_PlayerID)

Zeigt das normale Interface an.

### API.DeactivateBorderScroll (_PlayerID, _Position)

Deaktiviert Randscrollen und setzt die Kamera optional auf das Ziel

### API.DeactivateImageScreen (_PlayerID)

Deaktiviert ein angezeigtes Bild, wenn dieses angezeigt wird.

### API.DeactivateNormalInterface (_PlayerID)

Blendet das normale Interface aus.

### API.FinishCinematicEvent (_Name, _PlayerID)

Propagiert das Ende des Kinoevent.

### API.GetCinematicEvent (_Identifier, _PlayerID)

Gibt den Zustand des Kinoevent zurück.

### API.IsCinematicEventActive (_PlayerID)

Prüft ob gerade ein Kinoevent für den Spieler aktiv ist.

### API.StartCinematicEvent (_Name, _PlayerID)

Propagiert den Beginn des Kinoevent und bindet es an den Spieler.

 <b>Hinweis:</b>Während des aktiven Kinoevent kann nicht gespeichert werden.


### API.StartTypewriter (_Data)

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


