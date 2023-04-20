# Module <code>qsb_2_camera</code>
Stellt Funktionen für die RTS-Camera bereit.
 <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
 <li><a href="modules.QSB_1_GuiEffects.QSB_1_GuiEffects.html">(1) Anzeigeeffekte</a></li>
 </ul>

### API.AllowExtendedZoom (_Flag)
source/qsb_2_camera.lua.html#33

Aktiviert oder deaktiviert den erweiterten Zoom.

 Der maximale Zoom wird erweitert. Dabei entsteht eine fast völlige
 Draufsicht. Dies kann nütztlich sein, wenn der Spieler ein größeres
 Sichtfeld benötigt.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Erweitere Kamera einschalten
</span>API.AllowExtendedZoom(<span class="keyword">true</span>);
<span class="comment">-- Erweitere Kamera abschalten
</span>API.AllowExtendedZoom(<span class="keyword">false</span>);</pre>


</ul>


### API.FocusCameraOnEntity (_Entity, _Rotation, _ZoomFactor)
source/qsb_2_camera.lua.html#78

Fokusiert die Kamera auf dem Entity.





### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Zentriert die Kamera über dem Entity mit dem Skriptnamen "HansWurst".
</span>API.FocusCameraOnKnight(<span class="string">"HansWurst"</span>, -<span class="number">45</span>, <span class="number">0.2</span>);</pre>


</ul>


### API.FocusCameraOnKnight (_Player, _Rotation, _ZoomFactor)
source/qsb_2_camera.lua.html#62

Fokusiert die Kamera auf dem Primärritter des Spielers.





### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Zentriert die Kamera über den Helden von Spieler 3.
</span>API.FocusCameraOnKnight(<span class="number">3</span>, <span class="number">90</span>, <span class="number">0.5</span>);</pre>


</ul>


