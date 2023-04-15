-- -------------------------------------------------------------------------- --

Addon_Template = {
    Properties = {
        Name = "Addon_Template",
        Version = "1.0.0",
    },

    Global = {
        -- Die Globalen Funktionen und Daten des Addons
        Data = {},
    },

    Local = {
        -- Die Lokalen Funktionen und Daten des Addons
    },

    Shared = {
        -- Funktionen und Daten des Addons die jeweils in beiden Scripten
        -- vorhanden sein sollen
    },
}

-- Global ------------------------------------------------------------------- --

function Addon_Template.Global:OnGameStart()
    -- Was zum Spielstart im Globalen Script ausgeführt werden sollte
end

function Addon_Template.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        -- Was nach dem laden eines Spielstandes ausgeführt werden sollte
        return
    end
end

function Addon_Template.Global:DemoFunktion(_Parameter1, _Parameter2)
    -- Diese Funktion wird von der öffentlichen Schnittstelle genutzt
    -- Hier kann nun beliebig mit den Parametern gearbeitet werden, hier speichern
    self.Data.Param1 = _Parameter1
    if _Parameter2 then -- _Parameter2 ist in der Schnittstelle als Optional definiert
        self.Data.Param2 = _Parameter2
    end
end

-- Local -------------------------------------------------------------------- --

function Addon_Template.Local:OnGameStart()
    -- Was zum Spielstart im Lokalen Script ausgeführt werden sollte
end

function Addon_Template.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        -- Was nach dem laden eines Spielstandes ausgeführt werden sollte
        return
    end
end

-- Shared ------------------------------------------------------------------- --

function Addon_Template.Shared:RelevantInBothScripts()
    -- Hier definierte Funktionen sollten entweder statisch sein oder es sollte
    -- sichergestellt werden, dasssind in beiden Scripten verfügbar.
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(Addon_Template)