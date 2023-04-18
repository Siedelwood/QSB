### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.GetPlayerName (_PlayerID)

Gibt den Namen des Spielers zurück.

### API.GetTerritoryName (_TerritoryID)

Gibt den Namen des Territoriums zurück.

### API.HideBuildMenu (_Flag)

Versteckt das Baumenü oder blendet es ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>


### API.HideBuyTerritory (_Flag)

Versteckt den Button zum Territorienkauf oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>


### API.HideDiplomacyMenu (_Flag)

Versteckt den Button des Diplomatiemenü oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>


### API.HideKnightAbility (_Flag)

Versteckt den Button der Heldenfähigkeit oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>


### API.HideKnightButton (_Flag)

Versteckt den Button zur Heldenselektion oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>


### API.HideMinimap (_Flag)

Graut die Minimap aus oder macht sie wieder verwendbar.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>


### API.HideProductionMenu (_Flag)

Versteckt den Button des Produktionsmenü oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>


### API.HideSelectionButton (_Flag)

Versteckt den Button zur Selektion des Militärs oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>


### API.HideToggleMinimap (_Flag)

Versteckt den Umschaltknopf der Minimap oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>


### API.HideWeatherMenu (_Flag)

Versteckt den Button des Wettermenüs oder blendet ihn ein.

 <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
 aktiv und muss explizit zurückgenommen werden!</p>


### API.SetIcon (_WidgetID, _Coordinates, _Size, _Name)

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


### API.SetPlayerColor (_PlayerID, _Color, _Logo, _Pattern)

Setzt eine andere Spielerfarbe.

### API.SetPlayerName (_PlayerID, _Name)

Gibt dem Spieler einen neuen Namen.

 <b>hinweis</b>: Die Änderung des Spielernamens betrifft sowohl die Anzeige
 bei den Quests als auch im Diplomatiemenü.


### API.SetPlayerPortrait (_PlayerID, _Portrait)

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


### API.SetTooltipCosts (_Title, _Text, _DisabledText, _Costs, _InSettlement)

Ändert den Beschreibungstext und die Kosten eines Button.

 Wichtig ist zu beachten, dass diese Funktion in der Tooltip-Funktion des
 Button oder Icon ausgeführt werden muss.


### API.SetTooltipNormal (_Title, _Text, _DisabledText)

Ändert den Beschreibungstext eines Button oder eines Icon.

 Wichtig ist zu beachten, dass diese Funktion in der Tooltip-Funktion des
 Button oder Icon ausgeführt werden muss.

 Die Funktion kann auch mit deutsch/english lokalisierten Tabellen als
 Text gefüttert werden. In diesem Fall wird der deutsche Text genommen,
 wenn es sich um eine deutsche Spielversion handelt. Andernfalls wird
 immer der englische Text verwendet.


### API.SpeedLimitActivate (_Flag)

Setzt die Spielgeschwindigkeit auf Stufe 1 fest oder gibt sie wieder frei.

 <b>Hinweis</b>: Die Geschwindigkeitsbeschränkung wirkt sich ebenfalls auf
 Cheats aus. Es ist generell nicht mehr möglich, das Spiel zu beschleunigen,
 wenn die "Speedbremse" aktiv ist.


