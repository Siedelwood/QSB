API = API or {}
QSB.ScriptEvents = QSB.ScriptEvents or {}
---
-- @param[type=boolean] _enable Aktiviert den Button an Jägerhütten, um Weidetiere zu jagen!
-- @within Anwenderfunktionen
--
-- @usage
-- API.ToggleHuntableLifestock(true)
--
function API.ToggleHuntableLifestock(_enable)
    assert(_enable and type(_enable) == "boolean", "API.ToggleHuntableLifestock: Ungültiger Parameter!")

    if not GUI then
        return Addon_HuntableLifestock.Global:ToggleHuntableLifestock(_enable)
    else
        return Addon_HuntableLifestock.Local:ToggleHuntableLifestock(_enable)
    end
end