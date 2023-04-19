# Module <code>qsb_1_guicontrol</code>
Ermöglicht, die Anzeige von Menüoptionen zu steuern.
 Es können verschiedene Anzeigen ausgetauscht werden.
 <ul>
 <li>Spielerfrabe</li>
 <li>Spielername</li>
 <li>Spielerportrait</li>
 <li>Territorienname</li>
 </ul></p>

<p> Es können verschiedene Zugriffsoptionen für den Spieler gesetzt werden.
 <ul>
 <li>Minimap anzeigen/deaktivieren</li>
 <li>Minimap umschalten anzeigen/deaktivieren</li>
 <li>Diplomatiemenü anzeigen/deaktivieren</li>
 <li>Produktionsmenü anzeigen/deaktivieren</li>
 <li>Wettermenü anzeigen/deaktivieren</li>
 <li>Baumenü anzeigen/deaktivieren</li>
 <li>Territorium einnehmen anzeigen/deaktivieren</li>
 <li>Ritterfähigkeit anzeigen/deaktivieren</li>
 <li>Ritter selektieren anzeigen/deaktivieren</li>
 <li>Militär selektieren anzeigen/deaktivieren</li>
 </ul></p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_1_guicontrol.lua.html#42

Events, auf die reagiert werden kann.





### API.GetPlayerName (_PlayerID)
source/qsb_1_guicontrol.lua.html#76

Gibt den Namen des Spielers zurück.





### API.GetTerritoryName (_TerritoryID)
source/qsb_1_guicontrol.lua.html#51

Gibt den Namen des Territoriums zurück.





### API.HideBuildMenu (_Flag)
source/qsb_1_guicontrol.lua.html#530

Versteckt das Baumenü oder blendet es ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>






### API.HideBuyTerritory (_Flag)
source/qsb_1_guicontrol.lua.html#448

Versteckt den Button zum Territorienkauf oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>






### API.HideDiplomacyMenu (_Flag)
source/qsb_1_guicontrol.lua.html#394

Versteckt den Button des Diplomatiemenü oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>






### API.HideKnightAbility (_Flag)
source/qsb_1_guicontrol.lua.html#466

Versteckt den Button der Heldenfähigkeit oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>






### API.HideKnightButton (_Flag)
source/qsb_1_guicontrol.lua.html#485

Versteckt den Button zur Heldenselektion oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>






### API.HideMinimap (_Flag)
source/qsb_1_guicontrol.lua.html#357

Graut die Minimap aus oder macht sie wieder verwendbar.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>






### API.HideProductionMenu (_Flag)
source/qsb_1_guicontrol.lua.html#412

Versteckt den Button des Produktionsmenü oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>






### API.HideSelectionButton (_Flag)
source/qsb_1_guicontrol.lua.html#510

Versteckt den Button zur Selektion des Militärs oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>






### API.HideToggleMinimap (_Flag)
source/qsb_1_guicontrol.lua.html#376

Versteckt den Umschaltknopf der Minimap oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>






### API.HideWeatherMenu (_Flag)
source/qsb_1_guicontrol.lua.html#430

Versteckt den Button des Wettermenüs oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>






### API.SetIcon (_WidgetID, _Coordinates, _Size, _Name)
source/qsb_1_guicontrol.lua.html#295

Setzt einen Icon aus einer Icon Matrix.

 Es ist möglich, eine benutzerdefinierte Icon Matrix zu verwenden.
 Dafür müssen die Quellen nach gui_768, gui_920 und gui_1080 in der
 entsprechenden Größe gepackt werden, da das Spiel für unterschiedliche
 Auflösungen in verschiedene Verzeichnisse schaut.

 Die Dateien müssen in <i>graphics/textures</i> liegen, was auf gleicher
 Ebene ist, wie <i>maps/externalmap</i>.
 Jede Map muss einen eigenen eindeutigen Namen für jede Grafik verwenden, da
 diese Grafiken solange geladen werden, wie die Map im Verzeichnis liegt.

 Es können 3 verschiedene Icon-Größen angegeben werden. Je nach dem welche
 Größe gefordert wird, wird nach einer anderen Datei gesucht. Es entscheidet
 der als Name angegebene Präfix.
 <ul>
 <li>keine: siehe 64</li>
 <li>44: [Dateiname].png</li>
 <li>64: [Dateiname]big.png</li>
 <li>1200: [Dateiname]verybig.png</li>
 </ul>






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Setzt eine Originalgrafik
</span>API.SetIcon(AnyWidgetID, {<span class="number">1</span>, <span class="number">1</span>, <span class="number">1</span>});

<span class="comment">-- Setzt eine benutzerdefinierte Grafik
</span>API.SetIcon(AnyWidgetID, {<span class="number">8</span>, <span class="number">5</span>}, <span class="keyword">nil</span>, <span class="string">"meinetollenicons"</span>);
<span class="comment">-- (Es wird als Datei gesucht: meinetolleniconsbig.png)
</span>
<span class="comment">-- Setzt eine benutzerdefinierte Grafik
</span>API.SetIcon(AnyWidgetID, {<span class="number">8</span>, <span class="number">5</span>}, <span class="number">128</span>, <span class="string">"meinetollenicons"</span>);
<span class="comment">-- (Es wird als Datei gesucht: meinetolleniconsverybig.png)</span></pre>


</ul>


### API.SetPlayerColor (_PlayerID, _Color, _Logo, _Pattern)
source/qsb_1_guicontrol.lua.html#135

Setzt eine andere Spielerfarbe.





### API.SetPlayerName (_PlayerID, _Name)
source/qsb_1_guicontrol.lua.html#110

Gibt dem Spieler einen neuen Namen.

 <b>hinweis</b>: Die Änderung des Spielernamens betrifft sowohl die Anzeige
 bei den Quests als auch im Diplomatiemenü.






### API.SetPlayerPortrait (_PlayerID, _Portrait)
source/qsb_1_guicontrol.lua.html#184

Setzt das Portrait eines Spielers.

 Dabei gibt es 3 verschiedene Varianten:
 <ul>
 <li>Wenn _Portrait nicht gesetzt wird, wird das Portrait des Primary
 Knight genommen.</li>
 <li>Wenn _Portrait ein existierendes Entity ist, wird anhand des Typs
 das Portrait bestimmt.</li>
 <li>Wenn _Portrait der Modellname eines Portrait ist, wird der Wert
 als Portrait gesetzt.</li>
 </ul>

 Wenn kein Portrait bestimmt werden kann, wird H_NPC_Generic_Trader verwendet.

 <b>Trivia</b>: Diese Funktionalität wird Umgangssprachlich als "Kopf
 tauschen" oder "Kopf wechseln" bezeichnet.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Kopf des Primary Knight
</span>API.SetPlayerPortrait(<span class="number">2</span>);
<span class="comment">-- Kopf durch Entity bestimmen
</span>API.SetPlayerPortrait(<span class="number">2</span>, <span class="string">"amma"</span>);
<span class="comment">-- Kopf durch Modelname setzen
</span>API.SetPlayerPortrait(<span class="number">2</span>, <span class="string">"H_NPC_Monk_AS"</span>);</pre>


</ul>


### API.SetTooltipCosts (_Title, _Text, _DisabledText, _Costs, _InSettlement)
source/qsb_1_guicontrol.lua.html#341

Ändert den Beschreibungstext und die Kosten eines Button.

 Wichtig ist zu beachten, dass diese Funktion in der Tooltip-Funktion des
 Button oder Icon ausgeführt werden muss.





### Verwandte Themen:
<ul>


<a href="qsb_1_guicontrol.html#API.SetTooltipNormal">API.SetTooltipNormal</a>


</ul>



### API.SetTooltipNormal (_Title, _Text, _DisabledText)
source/qsb_1_guicontrol.lua.html#319

Ändert den Beschreibungstext eines Button oder eines Icon.

 Wichtig ist zu beachten, dass diese Funktion in der Tooltip-Funktion des
 Button oder Icon ausgeführt werden muss.

 Die Funktion kann auch mit deutsch/english lokalisierten Tabellen als
 Text gefüttert werden. In diesem Fall wird der deutsche Text genommen,
 wenn es sich um eine deutsche Spielversion handelt. Andernfalls wird
 immer der englische Text verwendet.






### API.SpeedLimitActivate (_Flag)
source/qsb_1_guicontrol.lua.html#555

Setzt die Spielgeschwindigkeit auf Stufe 1 fest oder gibt sie wieder frei.

 <b>Hinweis</b>: Die Geschwindigkeitsbeschränkung wirkt sich ebenfalls auf
 Cheats aus. Es ist generell nicht mehr möglich, das Spiel zu beschleunigen,
 wenn die "Speedbremse" aktiv ist.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Geschwindigkeit auf Stufe 1 festsetzen
</span>API.SpeedLimitActivate(<span class="keyword">true</span>);
<span class="comment">-- Geschwindigkeit freigeben
</span>API.SpeedLimitActivate(<span class="keyword">false</span>);</pre>


</ul>


