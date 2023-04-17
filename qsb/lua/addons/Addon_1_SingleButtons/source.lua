-- -------------------------------------------------------------------------- --

Addon_SingleButtons = {
    Properties = {
        Name = "Addon_SingleButtons",
        Version = "1.0.0",
    },

    Global = {
        Data = {},
    },

    Local = {
        Data = {},
    },
}

-- Global ------------------------------------------------------------------- --

function Addon_SingleButtons.Global:OnGameStart()
    -- Was zum Spielstart im Globalen Script ausgeführt werden sollte
end

function Addon_SingleButtons.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        -- Was nach dem laden eines Spielstandes ausgeführt werden sollte
        return
    end
end

-- Local -------------------------------------------------------------------- --

function Addon_SingleButtons.Local:OnGameStart()
    -- Was zum Spielstart im Lokalen Script ausgeführt werden sollte
end

function Addon_SingleButtons.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        -- Was nach dem laden eines Spielstandes ausgeführt werden sollte
        return
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(Addon_SingleButtons)