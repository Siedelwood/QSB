
---
-- Gibt die ID des kontrollierenden Spielers zurück. Der erste als menschlich
-- definierte Spieler wird als kontrollierender Spieler angenommen.
--
-- <p><b>Alias:</b> PlayerGetPlayerID</p>
--
-- @return[type=number] PlayerID
-- @within QSB_2_NewBehavior
--
function API.GetControllingPlayer()
    if not GUI then
        return ModuleBehaviorCollection.Global.Data.PlayerID or 1
    else
        return GUI.GetPlayerID();
    end
end
PlayerGetPlayerID = API.GetControllingPlayer;