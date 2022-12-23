--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Interne Funktionalität zum Schreiben von Ausgaben ins Log.
--
-- @set sort=true
-- @local
--

Revision.Logging = {
    FileLogLevel = 3,
    LogLevel = 2,
};

QSB.LogLevel = {
    ALL     = 4;
    INFO    = 3;
    WARNING = 2;
    ERROR   = 1;
    OFF     = 0;
}

function Revision.Logging:Initalize()
end

function Revision.Logging:OnSaveGameLoaded()
end

function Revision.Logging:Log(_Text, _Level, _Verbose)
    if self.FileLogLevel >= _Level then
        local Level = _Text:sub(1, _Text:find(":"));
        local Text = _Text:sub(_Text:find(":")+1);
        Text = string.format(
            " (%s) %s%s",
            (Revision.Environment == QSB.Environment.LOCAL and "local") or "global",
            Framework.GetSystemTimeDateString(),
            Text
        )
        Framework.WriteToLog(Level .. Text);
    end
    if _Verbose then
        if Revision.Environment == QSB.Environment.GLOBAL then
            if self.LogLevel >= _Level then
                Logic.ExecuteInLuaLocalState(string.format(
                    [[GUI.AddStaticNote("%s")]],
                    _Text
                ));
            end
            return;
        end
        if self.LogLevel >= _Level then
            GUI.AddStaticNote(_Text);
        end
    end
end

function Revision.Logging:SetLogLevel(_ScreenLogLevel, _FileLogLevel)
    if Revision.Environment == QSB.Environment.GLOBAL then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Revision.Logging.FileLogLevel = %d]],
            (_FileLogLevel or 0)
        ));
        Logic.ExecuteInLuaLocalState(string.format(
            [[Revision.Logging.LogLevel = %d]],
            (_ScreenLogLevel or 0)
        ));
        self.FileLogLevel = (_FileLogLevel or 0);
        self.LogLevel = (_ScreenLogLevel or 0);
    end
end

function debug(_Text, _Silent)
    Revision.Logging:Log("DEBUG: " .._Text, QSB.LogLevel.ALL, not _Silent);
end
function info(_Text, _Silent)
    Revision.Logging:Log("INFO: " .._Text, QSB.LogLevel.INFO, not _Silent);
end
function warn(_Text, _Silent)
    Revision.Logging:Log("WARNING: " .._Text, QSB.LogLevel.WARNING, not _Silent);
end
function error(_Text, _Silent)
    Revision.Logging:Log("ERROR: " .._Text, QSB.LogLevel.ERROR, not _Silent);
end

-- -------------------------------------------------------------------------- --
-- API

---
-- Setzt, ab wann Log-Nachrichten geschrieben werden.
--
-- Es wird zwischen der Ausgabe am Bildschirm und dem Wegschreiben ins Log
-- unterschieden. Die Anzeige am Bildschirm kann strenger eingestellt sein,
-- als das Speichern in der Log-Datei.
--
-- Mögliche Level:
-- <table border=1>
-- <tr>
-- <td><b>Name</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>QSB.LogLevel.ALL</td>
-- <td>Alle Stufen ausgeben (Debug, Info, Warning, Error)</td>
-- </tr>
-- <tr>
-- <td>QSB.LogLevel.INFO</td>
-- <td>Erst ab Stufe Info ausgeben (Info, Warning, Error)</td>
-- </tr>
-- <tr>
-- <td>QSB.LogLevel.WARNING</td>
-- <td>Erst ab Stufe Warning ausgeben (Warning, Error)</td>
-- </tr>
-- <tr>
-- <td>QSB.LogLevel.ERROR</td>
-- <td>Erst ab Stufe Error ausgeben (Error)</td>
-- </tr>
-- <tr>
-- <td>QSB.LogLevel.OFF</td>
-- <td>Keine Meldungen ausgeben</td>
-- </tr>
-- </table>
--
-- @param[type=number] _ScreenLogLevel Level für Bildschirmausgabe
-- @param[type=number] _FileLogLevel   Level für Dateiausgaabe
-- @within Base
-- @local
--
-- @usage
-- API.SetLogLevel(QSB.LogLevel.ERROR, QSB.LogLevel.WARNING);
--
function API.SetLogLevel(_ScreenLogLevel, _FileLogLevel)
    Revision.Logging:SetLogLevel(_ScreenLogLevel, _FileLogLevel);
end

