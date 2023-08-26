---
-- Fügt eine Beschreibung zu einem selbst gewählten Hotkey hinzu.
--
-- Ist der Hotkey bereits vorhanden, wird -1 zurückgegeben.
--
-- <b>QSB:</b> API.AddShortcutEntry(_Key, _Description)
--
-- @param[type=string] _Key         Tastenkombination
-- @param[type=string] _Description Beschreibung des Hotkey
-- @return[type=number] Index oder Fehlercode
-- @within QSB_1_GuiControl
--
function API.AddHotKey(_Key, _Description)
    return API.AddShortcutEntry(_Key, _Description)
end

---
-- Entfernt eine Beschreibung eines selbst gewählten Hotkeys.
--
-- <b>QSB:</b> API.RemoveShortcutEntry(_ID)
--
-- @param[type=number] _ID Index in Table
-- @within QSB_1_GuiControl
--
function API.RemoveHotKey(_ID)
    API.RemoveShortcutEntry(_ID)
end

---
-- Versteckt das Baumenü oder blendet es ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- <b>QSB:</b> API.HideBuildMenu(_Flag)
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within QSB_1_GuiControl
--
function API.InterfaceHideBuildMenu(_Flag)
    API.HideBuildMenu(_Flag)
end

---
-- Graut die Minimap aus oder macht sie wieder verwendbar.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- <b>QSB:</b> API.HideMinimap(_Flag)
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within QSB_1_GuiControl
--
function API.InterfaceHideMinimap(_Flag)
    API.HideMinimap(_Flag)
end

---
-- Versteckt den Umschaltknopf der Minimap oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- <b>QSB:</b> API.HideToggleMinimap(_Flag)
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within QSB_1_GuiControl
--
function API.InterfaceHideToggleMinimap(_Flag)
    API.HideToggleMinimap(_Flag)
end

---
-- Versteckt den Button des Diplomatiemenü oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- <b>QSB:</b> API.HideDiplomacyMenu(_Flag)
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within QSB_1_GuiControl
--
function API.InterfaceHideDiplomacyMenu(_Flag)
    API.HideDiplomacyMenu(_Flag)
end

---
-- Versteckt den Button des Produktionsmenü oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- <b>QSB:</b> API.HideProductionMenu(_Flag)
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within QSB_1_GuiControl
--
function API.InterfaceHideProductionMenu(_Flag)
    API.HideProductionMenu(_Flag)
end

---
-- Versteckt den Button des Wettermenüs oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- <b>QSB:</b> API.HideWeatherMenu(_Flag)
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within QSB_1_GuiControl
--
function API.InterfaceHideWeatherMenu(_Flag)
    API.HideWeatherMenu(_Flag)
end

---
-- Versteckt den Button zum Territorienkauf oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- <b>QSB:</b> API.HideBuyTerritory(_Flag)
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within QSB_1_GuiControl
--
function API.InterfaceHideBuyTerritory(_Flag)
    API.HideBuyTerritory(_Flag)
end

---
-- Versteckt den Button der Heldenfähigkeit oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- <b>QSB:</b> API.HideKnightAbility(_Flag)
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within QSB_1_GuiControl
--
function API.InterfaceHideKnightAbility(_Flag)
    API.HideKnightAbility(_Flag)
end

---
-- Versteckt den Button zur Heldenselektion oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- <b>QSB:</b> API.HideKnightButton(_Flag)
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within QSB_1_GuiControl
--
function API.InterfaceHideKnightButton(_Flag)
    API.HideKnightButton(_Flag)
end

---
-- Versteckt den Button zur Selektion des Militärs oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- <b>QSB:</b> API.HideSelectionButton(_Flag)
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within QSB_1_GuiControl
--
function API.InterfaceHideSelectionButton(_Flag)
    API.HideSelectionButton(_Flag)
end

---
-- Diese Funktion setzt die maximale Spielgeschwindigkeit bis zu der das Spiel
-- beschleunigt werden kann.
--
-- <b>QSB:</b> API.SetSpeedLimit(_Limit)
--
-- @param[type=number] _Limit Obergrenze für Spielgeschwindigkeit
-- @within QSB_1_GuiControl
--
function API.SpeedLimitSet(_Limit)
    API.SetSpeedLimit(_Limit)
end

---
-- Setzt einen Icon aus einer benutzerdefinierten Icon Matrix.
--
-- Es wird also die Grafik eines Button oder Icon mit einer neuen Grafik
-- ausgetauscht.
--
-- Dabei müssen die Quellen nach gui_768, gui_920 und gui_1080 in der
-- entsprechenden Größe gepackt werden. Die Ordner liegen in graphics/textures.
-- Jede Map muss einen eigenen eindeutigen Namen für jede Grafik verwenden.
--
-- <u>Größen:</u>
-- Die Gesamtgröße ergibt sich aus der Anzahl der Buttons und der Pixelbreite
-- für die jeweilige Grö0e. z.B. 64 Buttons -> Größe * 8 x Größe * 8
-- <ul>
-- <li>768: 41x41</li>
-- <li>960: 52x52</li>
-- <li>1200: 64x64</li>
-- </ul>
--
-- <u>Namenskonvention:</u>
-- Die Namenskonvention wird durch das Spiel vorgegeben. Je nach Größe sind
-- die Namen der Matrizen erweitert mit .png, big.png und verybig.png. Du
-- gibst also niemals die Dateiendung mit an!
-- <ul>
-- <li>Für normale Icons: _Name .. .png</li>
-- <li>Für große Icons: _Name .. big.png</li>
-- <li>Für riesige Icons: _Name .. verybig.png</li>
-- </ul>
--
-- <b>QSB:</b> API.SetIcon(_WidgetID, _Coordinates, _Size, _Name)
--
-- @param[type=string] _WidgetID Widgetpfad oder ID
-- @param[type=table]  _Coordinates Koordinaten
-- @param[type=number] _Size Größe des Icon
-- @param[type=string] _Name Name der Icon Matrix
-- @within QSB_1_GuiControl
--
function API.InterfaceSetIcon(_WidgetID, _Coordinates, _Size, _Name)
    API.SetIcon(_WidgetID, _Coordinates, _Size, _Name)
end

---
-- Ändert den Beschreibungstext eines Button oder eines Icon.
--
-- Wichtig ist zu beachten, dass diese Funktion in der Update-Funktion des
-- Button oder Icon ausgeführt werden muss.
--
-- Die Funktion kann auch mit deutsch/english lokalisierten Tabellen als
-- Text gefüttert werden. In diesem Fall wird der deutsche Text genommen,
-- wenn es sich um eine deutsche Spielversion handelt. Andernfalls wird
-- immer der englische Text verwendet.
--
-- <b>QSB:</b> API.SetTooltipNormal(_Title, _Text, _DisabledText)
--
-- @param[type=string] _Title        Titel des Tooltip
-- @param[type=string] _Text         Text des Tooltip
-- @param[type=string] _DisabledText Textzusatz wenn inaktiv
-- @within QSB_1_GuiControl
--
function API.InterfaceSetTooltipNormal(_Title, _Text, _DisabledText)
    API.SetTooltipNormal(_Title, _Text, _DisabledText)
end

---
-- Ändert den Beschreibungstext und die Kosten eines Button.
--
-- Wichtig ist zu beachten, dass diese Funktion in der Update-Funktion des
-- Button oder Icon ausgeführt werden muss.
--
-- <b>QSB:</b> API.SetTooltipCosts(_Title, _Text, _DisabledText, _Costs, _InSettlement)
--
-- @see API.InterfaceSetTooltipNormal
--
-- @param[type=string]  _Title        Titel des Tooltip
-- @param[type=string]  _Text         Text des Tooltip
-- @param[type=string]  _DisabledText Textzusatz wenn inaktiv
-- @param[type=table]   _Costs        Kostentabelle
-- @param[type=boolean] _InSettlement Kosten in Siedlung suchen
-- @within QSB_1_GuiControl
--
function API.InterfaceSetTooltipCosts(_Title, _Text, _DisabledText, _Costs, _InSettlement)
    API.SetTooltipCosts(_Title, _Text, _DisabledText, _Costs, _InSettlement)
end

---
-- Gibt den Namen des Territoriums zurück.
--
-- <b>QSB:</b> API.GetTerritoryName(_TerritoryID)
--
-- @param[type=number] _TerritoryID ID des Territoriums
-- @return[type=string]  Name des Territorium
-- @within QSB_1_GuiControl
--
function API.InterfaceGetTerritoryName(_TerritoryID)
    return API.GetTerritoryName(_TerritoryID)
end

---
-- Gibt den Namen des Spielers zurück.
--
-- <b>QSB:</b> API.GetPlayerName(_PlayerID)
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=string]  Name des Spielers
-- @within QSB_1_GuiControl
--
function API.InterfaceGetPlayerName(_PlayerID)
    return API.GetPlayerName(_PlayerID)
end

---
-- Gibt dem Spieler einen neuen Namen.
--
-- <b>QSB:</b> API.SetPlayerName(_PlayerID, _Name)
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=string] _Name Name des Spielers
-- @within QSB_1_GuiControl
--
function API.InterfaceSetPlayerName(_PlayerID, _Name)
    API.SetPlayerName(_PlayerID, _Name)
end

---
-- Setzt eine andere Spielerfarbe.
--
-- <b>QSB:</b> API.SetPlayerColor(_PlayerID, _Color, _Logo, _Pattern)
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Color Spielerfarbe
-- @param[type=number] _Logo Logo (optional)
-- @param[type=number] _Pattern Pattern (optional)
-- @within QSB_1_GuiControl
--
function API.InterfaceSetPlayerColor(_PlayerID, _Color, _Logo, _Pattern)
    API.SetPlayerColor(_PlayerID, _Color, _Logo, _Pattern)
end

---
-- Setzt das Portrait eines Spielers.
--
-- Dabei gibt es 3 verschiedene Varianten:
-- <ul>
-- <li>Wenn _Portrait nicht gesetzt wird, wird das Portrait des Primary
-- Knight genommen.</li>
-- <li>Wenn _Portrait ein existierendes Entity ist, wird anhand des Typs
-- das Portrait bestimmt.</li>
-- <li>Wenn _Portrait der Modellname eines Portrait ist, wird der Wert
-- als Portrait gesetzt.</li>
-- </ul>
--
-- Wenn kein Portrait bestimmt werden kann, wird H_NPC_Generic_Trader verwendet.
--
-- <b>QSB:</b> API.SetPlayerPortrait(_PlayerID, _Portrait)
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=string] _Portrait Name des Models
-- @within QSB_1_GuiControl
--
function API.InterfaceSetPlayerPortrait(_PlayerID, _Portrait)
    API.SetPlayerPortrait(_PlayerID, _Portrait)
end
