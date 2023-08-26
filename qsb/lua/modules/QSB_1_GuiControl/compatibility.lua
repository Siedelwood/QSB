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
