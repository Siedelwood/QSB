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
-- @within Anwenderfunktionen
--
function API.RemoveHotKey(_ID)
    API.RemoveShortcutEntry(_ID)
end
