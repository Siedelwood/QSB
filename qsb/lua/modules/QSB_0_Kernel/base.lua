--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

API = {};
SCP = {Core = {}};

QSB = {};
QSB.Version = "4.0.0 (ALPHA 1.0.0)";

---
-- Stellt wichtige Kernfunktionen bereit.
--
-- <h5>Behobene Fehler</h5>
--
-- Die QSB kommt mit einigen Bugfixes mit, die Fehler im Spiel beheben.
--
-- <ul>
-- <li>NPC-Lagerhäuser können jetzt Salz und Farbe einlagern.</li>
-- <li>Die NPC-Kasernen von Mitteleuropa respawnen jetzt Soldaten.</li>
-- <li>Werden Waren im Zuge eines Quests gesandt, wird bei den Zielgebäuden von
-- der Position des Eingangs ausgegangen anstatt von der Gebäudemitte. Dadurch
-- schlagen Lieferungen bei bestimmten Lagerhäusern nicht mehr fehl.</li>
-- <li>Bei interaktiven Objekten können jetzt auch nur zwei Rohstoffe anstatt
-- von Gold und einem Rohstoff als Kosten benutzt werden.</li>
-- <li>Spezielle Script Entities werden nicht mehr fälschlich mitgezählt.</li>
-- </ul>
--
-- <h5>Scripting Values</h5>
-- Bei den Scripting Values handelt es sich um einige Werte, die direkt im
-- Arbeitsspeicher manipuliert werden können und Auswirkungen auf Entities
-- haben.
--
-- Liste der derzeit unterstützten Werte:
-- <ul>
-- <li><b>QSB.ScriptingValue.Destination.X</b><br>
-- Gibt die Z-Koordinate des Bewegungsziels als Float zurück.</li>
-- <li><b>QSB.ScriptingValue.Destination.Y</b><br>
-- Gibt die Y-Koordinate des Bewegungsziels als Float zurück.</li>
-- <li><b>QSB.ScriptingValue.Health</b><br>
-- Setzt die Gesundheit eines Entity ohne Folgeaktionen zu triggern.</li>
-- <li><b>QSB.ScriptingValue.Player</b><br>
-- Setzt den Besitzer des Entity ohne Plausibelitätsprüfungen.</li>
-- <li><b>QSB.ScriptingValue.Size</b><br>
-- Setzt den Größenfaktor eines Entities als Float.</li>
-- <li><b>QSB.ScriptingValue.Visible</b><br>
-- Sichtbarkeit eines Entities abfragen (801280 == sichtbar)</li>
-- <li><b>QSB.ScriptingValue.NPC</b><br>
-- NPC-Flag eines Siedlers setzen (0 = inaktiv, 1 - 4 = aktiv)</li>
-- </ul>
--
-- <h5>Platzhalter</h5>
--
-- <u>Mehrsprachige Texte:</u>
-- Anstatt eines Strings wird ein Table mit dem gleichen Text in verschiedenen
-- Sprachen angegeben. Der richtige Text wird anhand der eingestellten Sprache
-- gewählt. Wenn nichts vorgegeben wird, ist die Systemsprache voreingestellt.
-- Als Standard für nichtdeutsche Sprachen wird Englisch verwendet, wenn für
-- die Sprache selbst kein Text vorhanden ist. Es muss also immer wenigstens
-- English (en) und Deutsch (de) vorhanden sein. <br>
-- Einige Features lokalisieren Texte automatisch. <br>
-- (Siehe dazu: <a href="#API.Localize">API.Localize</a>)
--
-- <u>Platzhalter in Texten:</u>
-- In Texten können vordefinierte Farben, Namen für Entity-Typen und benannte
-- Entities, sowie Inhalte von Variablen ersetzt werden. Dies wird von einigen
-- QSB-Features automatisch vorgenommen. Es kann Mittels API-Funktion auch
-- manuell angestoßen werden. <br>
-- (Siehe dazu: <a href="#API.ConvertPlaceholders">API.ConvertPlaceholders</a>)
--
-- <h5>Entwicklungsmodus</h5>
--
-- Die QSB kann verschiedene Optionen zum schnelleren Testen und finden von
-- fehlern aktivieren. <br>
-- (Siehe dazu: <a href="#API.ActivateDebugMode">API.ActivateDebugMode</a>)
--
-- <b>Befehle:</b><br>
-- <i>Diese Befehle können über die Konsole (SHIFT + ^) eingegeben werden, wenn
-- der Debug Mode aktiviert ist.</i><br>
-- <table border="1">
-- <tr>
-- <td><b>Befehl</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>restartmap</td>
-- <td>Map sofort neu starten</td>
-- </tr>
-- <tr>
-- <td>&gt; [Befehl]</td>
-- <td>Einen Lua Befehl im globalen Skript ausführen.
-- (Die Zeichen", ', {, } können nicht verwendet werden)</td>
-- </tr>
-- <tr>
-- <td>&gt;&gt; [Befehl]</td>
-- <td>Einen Lua Befehl im lokalen Skript ausführen.
-- (Die Zeichen", ', {, } können nicht verwendet werden)</td>
-- </tr>
-- <tr>
-- <td>&lt; [Pfad]</td>
-- <td>Lua-Datei zur Laufzeit ins globale Skript laden.</td>
-- </tr>
-- <tr>
-- <td>&lt;&lt; [Pfad]</td>
-- <td>Lua-Datei zur Laufzeit ins lokale Skript laden.</td>
-- </tr>
-- </table>
--
-- <b>Cheats:</b><br>
-- <i>Bei aktivierten Debug Mode können diese Cheat Codes verwendet werden.</i><br>
-- <table border="1">
-- <tr>
-- <td><b>Cheat</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>SHIFT + ^</td>
-- <td>Konsole öffnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + ALT + R</td>
-- <td>Map sofort neu starten.</td>
-- </tr>
-- <td>CTRL + C</td>
-- <td>Zeitanzeige an/aus</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + A</td>
-- <td>Clutter (Gräser) anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + C</td>
-- <td>Grasobjekte anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + E</td>
-- <td>Laubbäume anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + F</td>
-- <td>FoW anzeigen (an/aus) <i>Gebiete werden dauerhaft erkundet!</i></td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + G</td>
-- <td>GUI anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + H</td>
-- <td>Steine und Tannen anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + R</td>
-- <td>Straßen anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + S</td>
-- <td>Schatten anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + T</td>
-- <td>Boden anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + U</td>
-- <td>FoW anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + W</td>
-- <td>Wasser anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + X</td>
-- <td>Render Mode des Wassers umschalten (Einfach und komplex)</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + Y</td>
-- <td>Himmel anzeigen (an/aus)</td>
-- </tr>
-- <tr>
-- <td>ALT + F10</td>
-- <td>Selektiertes Gebäude anzünden</td>
-- </tr>
-- <tr>
-- <td>ALT + F11</td>
-- <td>Selektierte Einheit verwunden</td>
-- </tr>
-- <tr>
-- <td>ALT + F12</td>
-- <td>Alle Rechte freigeben / wieder sperren</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + 1</td>
-- <td>FPS-Anzeige</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 4</td>
-- <td>Bogenschützen unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 5</td>
-- <td>Schwertkämpfer unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 6</td>
-- <td>Katapultkarren unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 7</td>
-- <td>Ramme unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 8</td>
-- <td>Belagerungsturm unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 9</td>
-- <td>Katapult unter der Maus spawnen</td>
-- </tr>
-- <tr>
-- <td>(Num) +</td>
-- <td>Spiel beschleunigen</td>
-- </tr>
-- <tr>
-- <td>(Num) -</td>
-- <td>Spiel verlangsamen</td>
-- </tr>
-- <tr>
-- <td>(Num) *</td>
-- <td>Geschwindigkeit zurücksetzen</td>
-- </tr>
-- <tr>
-- <td>CTRL + F1</td>
-- <td>+ 50 Gold</td>
-- </tr>
-- <tr>
-- <td>CTRL + F2</td>
-- <td>+ 10 Holz</td>
-- </tr>
-- <tr>
-- <td>CTRL + F3</td>
-- <td>+ 10 Stein</td>
-- </tr>
-- <tr>
-- <td>CTRL + F4</td>
-- <td>+ 10 Getreide</td>
-- </tr>
-- <tr>
-- <td>CTRL + F5</td>
-- <td>+ 10 Milch</td>
-- </tr>
-- <tr>
-- <td>CTRL + F6</td>
-- <td>+ 10 Kräuter</td>
-- </tr>
-- <tr>
-- <td>CTRL + F7</td>
-- <td>+ 10 Wolle</td>
-- </tr>
-- <tr>
-- <td>CTRL + F8</td>
-- <td>+ 10 auf alle Waren</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F1</td>
-- <td>+ 10 Honig</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F2</td>
-- <td>+ 10 Eisen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F3</td>
-- <td>+ 10 Fisch</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F4</td>
-- <td>+ 10 Wild</td>
-- </tr>
-- <tr>
-- <td>ALT + F5</td>
-- <td>Bedürfnis nach Nahrung in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>ALT + F6</td>
-- <td>Bedürfnis nach Kleidung in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>ALT + F7</td>
-- <td>Bedürfnis nach Hygiene in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>ALT + F8</td>
-- <td>Bedürfnis nach Unterhaltung in Gebäude aktivieren</td>
-- </tr>
-- <tr>
-- <td>CTRL + F9</td>
-- <td>Nahrung für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F9</td>
-- <td>Nahrung für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>CTRL + F10</td>
-- <td>Kleidung für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F10</td>
-- <td>Kleidung für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>CTRL + F11</td>
-- <td>Hygiene für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F11</td>
-- <td>Hygiene für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>CTRL + F12</td>
-- <td>Unterhaltung für selektiertes Gebäude erhöhen</td>
-- </tr>
-- <tr>
-- <td>SHIFT + F12</td>
-- <td>Unterhaltung für selektiertes Gebäude verringern</td>
-- </tr>
-- <tr>
-- <td>ALT + CTRL + F10</td>
-- <td>Einnahmen des selektierten Gebäudes erhöhen</td>
-- </tr>
-- <tr>
-- <td>ALT + (Num) 1</td>
-- <td>Burg selektiert → Gold verringern, Werkstatt selektiert → Ware verringern</td>
-- </tr>
-- <tr>
-- <td>ALT + (Num) 2</td>
-- <td>Burg selektiert → Gold erhöhen, Werkstatt selektiert → Ware erhöhen</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 1</td>
-- <td>Kontrolle über Spieler 1</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 2</td>
-- <td>Kontrolle über Spieler 2</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 3</td>
-- <td>Kontrolle über Spieler 3</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 4</td>
-- <td>Kontrolle über Spieler 4</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 5</td>
-- <td>Kontrolle über Spieler 5</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 6</td>
-- <td>Kontrolle über Spieler 6</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 7</td>
-- <td>Kontrolle über Spieler 7</td>
-- </tr>
-- <tr>
-- <td>CTRL + ALT + 8</td>
-- <td>Kontrolle über Spieler 8</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 0</td>
-- <td>Kamera durchschalten</td>
-- </tr>
-- <tr>
-- <td>CTRL + (Num) 1</td>
-- <td>Kamerasprünge im RTS-Mode</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + V</td>
-- <td>Territorien anzeigen</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + B</td>
-- <td>Blocking anzeigen</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + N</td>
-- <td>Gitter verstecken</td>
-- </tr>
-- <tr>
-- <td>CTRL + SHIFT + F9</td>
-- <td>DEBUG-Ausgabe einschalten</td>
-- </tr>
-- <tr>
-- <td>ALT + F9</td>
-- <td>Zufälligen Arbeiter verheiraten</td>
-- </tr>
-- </table>
--
-- @set sort=true
-- @within Beschreibung
--

ParameterType = ParameterType or {};
g_QuestBehaviorVersion = 1;
g_QuestBehaviorTypes = {};

g_GameExtraNo = 0;
if Framework then
    g_GameExtraNo = Framework.GetGameExtraNo();
elseif MapEditor then
    g_GameExtraNo = MapEditor.GetGameExtraNo();
end

---
-- Events, um auf Ereignisse zu reagieren.
--
-- <h5>Was sind Script Events</h5>
--
-- Um dem Mapper das (z.T. fehlerbehaftete) Überschreiben von Game Callbacks
-- oder anlegen von (echten) Triggern zu ersparen, wurden die Script Events
-- eingeführt. Sie vereinheitlichen alle diese Operationen. Ein Event kann
-- von einem Modul oder in den Skripten des Anwenders über einen Event Listener
-- oder ein spezielles Game Callback gefangen werden.
--
-- Ein Event zu fangen bedeutet auf ein eingetretenes Ereignis - z.B. Wenn ein
-- Spielstand geladen wurde - zu reagieren. Events werden immer sowohl im
-- globalen als auch lokalen Skript ausgelöst, wenn ein entsprechendes Ereignis
-- aufgetreten ist, anstatt vieler Callbacks, die auf eine spezifische Umgebung
-- beschränkt sind.
--
-- Module bringen manchmal Events mit. Jedes Modul, welches ein neues Event
-- einführt, wird es in seiner API-Beschreibung aufgführen.
--
-- <u>Script Events, die von der QSB direkt bereitgestellt werden:</u>
--
-- @field ChatOpened       Das Chatfenster wird angezeigt (Parameter: PlayerID)
-- @field ChatClosed       Die Chateingabe wird bestätigt (Parameter: Text, PlayerID)
-- @field LanguageSet      Die Sprache wurde geändert (Parameter: OldLanguage, NewLanguage)
-- @field QuestFailure     Ein Quest schlug fehl (Parameter: QuestID)
-- @field QuestInterrupt   Ein Quest wurde unterbrochen (Parameter: QuestID)
-- @field QuestReset       Ein Quest wurde zurückgesetzt (Parameter: QuestID)
-- @field QuestSuccess     Ein Quest wurde erfolgreich abgeschlossen (Parameter: QuestID)
-- @field QuestTrigger     Ein Quest wurde aktiviert (Parameter: QuestID)
-- @field LoadscreenClosed Der Ladebildschirm wurde beendet.
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

QSB.Environment = {
    GLOBAL = 1,
    LOCAL  = 2,
}

QSB.GameVersion = {
    ORIGINAL        = 1,
    HISTORY_EDITION = 2,
}

QSB.GameVariant = {
    VANILLA   = 1,
    COMMUNITY = 2,
}

-- -------------------------------------------------------------------------- --

Revision = {
    ModuleRegister = {},
    BehaviorRegister = {},
};

function Revision:LoadKernel()
    self.Environment = (GUI and QSB.Environment.LOCAL) or QSB.Environment.GLOBAL;
    self.GameVersion = (Network.IsNATReady and QSB.GameVersion.HISTORY_EDITION) or QSB.GameVersion.ORIGINAL;
    self.GameVariant = (Entities.U_PolarBear and QSB.GameVariant.COMMUNITY) or QSB.GameVariant.VANILLA;

    self.LuaBase:Initalize();
    self.Logging:Initalize();
    self.Job:Initalize();
    self.Event:Initalize();
    self.Save:Initalize();
    self.Chat:Initalize();
    self.Text:Initalize();
    self.Bugfix:Initalize();
    self.ScriptingValue:Initalize();
    self.Utils:Initalize();
    self.Quest:Initalize();
    self.Debug:Initalize();
    self.Behavior:Initalize();

    self:SetupSaveGameHandler();
    self:SetupEscapeHandler();
    self:SetupLoadscreenHandler();
    self:SetupQsbLoadedHandler();
    self:SetupRandomSeedHandler();

    self:LoadExternFiles();
    self:LoadBehaviors();
end

-- -------------------------------------------------------------------------- --
-- File Loading

function Revision:LoadExternFiles()
    if Mission_LoadFiles then
        local FilesList = Mission_LoadFiles();
        for i= 1, #FilesList, 1 do
            if type(FilesList[i]) == "function" then
                FilesList[i]();
            else
                Script.Load(FilesList[i]);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Multiplayer

function Revision:SetupRandomSeedHandler()
    if self.Environment == QSB.Environment.GLOBAL then
        Revision.Event:CreateScriptCommand("Cmd_ProclaimateRandomSeed", function(_Seed)
            if Revision.MP_Seed_Set then
                return;
            end
            Revision.MP_Seed_Set = true;
            math.randomseed(_Seed);
            local void = math.random(1, 100);
            Logic.ExecuteInLuaLocalState(string.format(
                [[math.randomseed(%d); math.random(1, 100);]],
                _Seed
            ));
            info("Created seed: " .._Seed);
        end);
    end
end

function Revision:CreateRandomSeed()
    for PlayerID = 1, 8 do
        -- Find first human player to generate random seed
        if Logic.PlayerGetIsHumanFlag(PlayerID) and Logic.PlayerGetGameState(PlayerID) ~= 0 then
            -- If the player ID of the local client matches the ID of the first
            -- human player create the seed and broadcast it to all players
            if GUI.GetPlayerID() == PlayerID then
                local Seed = self:BuildRandomSeed(PlayerID);
                if Framework.IsNetworkGame() then
                    Revision.Event:DispatchScriptCommand(QSB.ScriptCommands.ProclaimateRandomSeed, 0, Seed);
                else
                    math.randomseed(Seed);
                    math.random(1, 100);
                    GUI.SendScriptCommand(string.format(
                        [[math.randomseed(%d); math.random(1, 100);]],
                        Seed
                    ));
                end
            end
            break;
        end
    end
end

function Revision:BuildRandomSeed(_PlayerID)
    local PlayerName = Logic.GetPlayerName(_PlayerID);
    local MapName = Framework.GetCurrentMapName();
    local MapType = Framework.GetCurrentMapTypeAndCampaignName();
    local SeedString = Framework.GetMapGUID(MapName, MapType);
    local DateText = Framework.GetSystemTimeDateString();
    SeedString = SeedString .. PlayerName .. " " .. DateText;
    local Seed = 0;
    for s in SeedString:gmatch(".") do
        Seed = Seed + ((tonumber(s) ~= nil and tonumber(s)) or s:byte());
    end
    return Seed;
end

-- -------------------------------------------------------------------------- --
-- Save Game

function Revision:SetupQsbLoadedHandler()
    if self.Environment == QSB.Environment.GLOBAL then
        Revision.Event:CreateScriptCommand("Cmd_GlobalQsbLoaded", function()
            if Mission_MP_OnQsbLoaded and not Revision.MP_FMA_Loaded and Framework.IsNetworkGame() then
                Logic.ExecuteInLuaLocalState([[
                    if Mission_MP_LocalOnQsbLoaded then
                        Mission_MP_LocalOnQsbLoaded();
                    end
                ]]);
                Revision.MP_FMA_Loaded = true;
                Mission_MP_OnQsbLoaded();
            end
        end);
    end
end

function Revision:SetupSaveGameHandler()
    QSB.ScriptEvents.SaveGameLoaded = self.Event:CreateScriptEvent("Event_SaveGameLoaded");

    if self.Environment == QSB.Environment.GLOBAL then
        Mission_OnSaveGameLoaded_Orig_Revision = Mission_OnSaveGameLoaded;
        Mission_OnSaveGameLoaded = function()
            Mission_OnSaveGameLoaded_Orig_Revision();
            Revision:OnSaveGameLoaded();
        end
    end
end

function Revision:OnSaveGameLoaded()
    -- Trigger in local script
    if self.Environment == QSB.Environment.GLOBAL then
        Logic.ExecuteInLuaLocalState("Revision:OnSaveGameLoaded()");
    end
    -- Call shared
    self.LuaBase:OnSaveGameLoaded();
    self.Logging:OnSaveGameLoaded();
    self.Job:OnSaveGameLoaded();
    self.Event:OnSaveGameLoaded();
    self.Save:OnSaveGameLoaded();
    self.Chat:OnSaveGameLoaded();
    self.Text:OnSaveGameLoaded();
    self.Bugfix:OnSaveGameLoaded();
    self.ScriptingValue:OnSaveGameLoaded();
    self.Utils:OnSaveGameLoaded();
    self.Quest:OnSaveGameLoaded();
    self.Debug:OnSaveGameLoaded();
    self.Behavior:OnSaveGameLoaded();
    -- Call local
    if self.Environment == QSB.Environment.LOCAL then
        self:SetEscapeKeyTrigger();
        self:CreateRandomSeed();
    end
    -- Send event
    self.Event:DispatchScriptEvent(QSB.ScriptEvents.SaveGameLoaded);
end

-- -------------------------------------------------------------------------- --
-- Module Registration

function Revision:LoadModules()
    for i= 1, #self.ModuleRegister, 1 do
        if self.Environment == QSB.Environment.GLOBAL then
            self.ModuleRegister[i].Local = nil;
            if self.ModuleRegister[i].Global.OnGameStart then
                self.ModuleRegister[i].Global:OnGameStart();
            end
        end
        if self.Environment == QSB.Environment.LOCAL then
            self.ModuleRegister[i].Global = nil;
            if self.ModuleRegister[i].Local.OnGameStart then
                self.ModuleRegister[i].Local:OnGameStart();
            end
        end
    end
end

function Revision:RegisterModule(_Module)
    if (type(_Module) ~= "table") then
        assert(false, "Modules must be tables!");
        return;
    end
    if _Module.Properties == nil or _Module.Properties.Name == nil then
        assert(false, "Expected name for Module!");
        return;
    end
    table.insert(self.ModuleRegister, _Module);
end

function Revision:IsModuleRegistered(_Name)
    for k, v in pairs(self.ModuleRegister) do
        return v.Properties and v.Properties.Name == _Name;
    end
end

-- -------------------------------------------------------------------------- --
-- Behavior Registration

function Revision:LoadBehaviors()
    for i= 1, #self.BehaviorRegister, 1 do
        local Behavior = self.BehaviorRegister[i];

        if not _G["B_" .. Behavior.Name].new then
            _G["B_" .. Behavior.Name].new = function(self, ...)
                local arg = {...};
                local behavior = table.copy(self);
                -- Raw parameters
                behavior.i47ya_6aghw_frxil = {};
                -- Overhead parameters
                behavior.v12ya_gg56h_al125 = {};
                for i= 1, #arg, 1 do
                    table.insert(behavior.v12ya_gg56h_al125, arg[i]);
                    if self.Parameter and self.Parameter[i] ~= nil then
                        behavior:AddParameter(i-1, arg[i]);
                    else
                        table.insert(behavior.i47ya_6aghw_frxil, arg[i]);
                    end
                end
                return behavior;
            end
        end
    end
end

function Revision:RegisterBehavior(_Behavior)
    if self.Environment == QSB.Environment.LOCAL then
        return;
    end
    if type(_Behavior) ~= "table" or _Behavior.Name == nil then
        assert(false, "Behavior is invalid!");
        return;
    end
    if _Behavior.RequiresExtraNo and _Behavior.RequiresExtraNo > g_GameExtraNo then
        return;
    end
    if not _G["B_" .. _Behavior.Name] then
        error(string.format("Behavior %s does not exist!", _Behavior.Name));
        return;
    end

    for i= 1, #g_QuestBehaviorTypes, 1 do
        if g_QuestBehaviorTypes[i].Name == _Behavior.Name then
            return;
        end
    end
    table.insert(g_QuestBehaviorTypes, _Behavior);
    table.insert(self.BehaviorRegister, _Behavior);
end

-- -------------------------------------------------------------------------- --
-- Escape Capture

function Revision:SetupEscapeHandler()
    QSB.ScriptEvents.EscapePressed = self.Event:CreateScriptEvent("Event_EscapePressed");
    if self.Environment == QSB.Environment.LOCAL then
        self:SetEscapeKeyTrigger();
    end
end

function Revision:SetEscapeKeyTrigger()
    Input.KeyBindDown(Keys.Escape, "Revision:OnPlayerPressedEscape()", 30, false);
end

function Revision:OnPlayerPressedEscape()
    -- Global
    Revision.Event:DispatchScriptCommand(
        QSB.ScriptCommands.SendScriptEvent,
        0,
        "EscapePressed",
        GUI.GetPlayerID()
    );
    -- Local
    Revision.Event:DispatchScriptCommand(QSB.ScriptEvents.EscapePressed, 0, GUI.GetPlayerID());
end

-- -------------------------------------------------------------------------- --
-- Loadscreen

function Revision:SetupLoadscreenHandler()
    QSB.ScriptEvents.LoadscreenClosed = self.Event:CreateScriptEvent("Event_LoadscreenClosed");
    if self.Environment == QSB.Environment.GLOBAL then
        self.Event:CreateScriptCommand(
            "Cmd_RegisterLoadscreenHidden",
            function()
                API.SendScriptEvent(QSB.ScriptEvents.LoadscreenClosed);
                Logic.ExecuteInLuaLocalState([[
                    API.SendScriptEvent(QSB.ScriptEvents.LoadscreenClosed)
                ]]);
            end
        );
        return;
    end

    self.Job:CreateEventJob(
        Events.LOGIC_EVENT_EVERY_TURN,
        function()
            if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
                Revision.Event:DispatchScriptCommand(
                    QSB.ScriptCommands.RegisterLoadscreenHidden,
                    GUI.GetPlayerID()
                );
                return true;
            end
        end
    );
end

-- -------------------------------------------------------------------------- --
-- API

---
-- Installiert Revision.
--
-- @within Base
-- @local
--
function API.Install()
    Revision:LoadKernel();
    Revision:LoadModules();
    collectgarbage("collect");
end

---
-- Startet die Map sofort neu.
--
-- <b>Achtung</b>: Die Funktion Framework.RestartMap kann nicht mehr verwendet
-- werden, da es sonst zu Fehlern mit dem Ladebildschirm kommt!
--
-- @within System
--
function API.RestartMap()
    Camera.RTS_FollowEntity(0);
    Framework.SetLoadScreenNeedButton(1);
    Framework.RestartMap();
end

---
-- Prüft, ob das laufende Spiel eine Multiplayerpartie in der History Edition
-- ist.
--
-- <b>Hinweis</b>: Es ist unmöglich, dass Original und History Edition in einer
-- Partie aufeinander treffen, da die alten Server längst abgeschaltet und die
-- Option zum LAN-Spiel in der HE nicht verfügbar ist.
--
-- @return[type=boolean] Spiel ist History Edition
-- @within System
--
function API.IsHistoryEditionNetworkGame()
    return Revision.GameVersion == QSB.GameVersion.HISTORY_EDITION and Framework.IsNetworkGame();
end

---
-- Gibt den Slot zurück, den der Spieler einnimmt. Hat der Spieler keinen
-- Slot okkupiert oder ist nicht menschlich, wird -1 zurückgegeben.
--
-- <h5>Multiplayer</h5>
-- Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!
--
-- @return[type=number] ID des Player
-- @return[type=number] Slot ID des Player
-- @within Multiplayer
--
function API.GetPlayerSlotID(_PlayerID)
    for i= 1, 8 do
        if Network.IsNetworkSlotIDUsed(i) then
            local CurrentPlayerID = Logic.GetSlotPlayerID(i);
            if  Logic.PlayerGetIsHumanFlag(CurrentPlayerID)
            and CurrentPlayerID == _PlayerID then
                return i;
            end
        end
    end
    return -1;
end

---
-- Gibt den Spieler zurück, welcher den Slot okkupiert. Hat der Slot keinen
-- Spieler oder ist der Spieler nicht menschlich, wird -1 zurückgegeben.
--
-- <h5>Multiplayer</h5>
-- Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!
--
-- @return[type=number] Slot ID des Player
-- @return[type=number] ID des Player
-- @within Multiplayer
--
function API.GetSlotPlayerID(_SlotID)
    if Network.IsNetworkSlotIDUsed(_SlotID) then
        local CurrentPlayerID = Logic.GetSlotPlayerID(_SlotID);
        if Logic.PlayerGetIsHumanFlag(CurrentPlayerID)  then
            return CurrentPlayerID;
        end
    end
    return -1;
end

---
-- Gibt eine Liste aller Spieler im Spiel zurück.
--
-- <h5>Multiplayer</h5>
-- Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!
--
-- @return[type=table] Liste der aktiven Spieler
-- @within Multiplayer
--
function API.GetActivePlayers()
    local PlayerList = {};
    for i= 1, 8 do
        if Network.IsNetworkSlotIDUsed(i) then
            local PlayerID = Logic.GetSlotPlayerID(i);
            if Logic.PlayerGetIsHumanFlag(PlayerID) and Logic.PlayerGetGameState(PlayerID) ~= 0 then
                table.insert(PlayerList, PlayerID);
            end
        end
    end
    return PlayerList;
end

---
-- Gibt alle Spieler zurück, auf die gerade gewartet wird.
--
-- <h5>Multiplayer</h5>
-- Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!
--
-- @return[type=table] Liste der aktiven Spieler
-- @within Multiplayer
--
function API.GetDelayedPlayers()
    local PlayerList = {};
    for k, v in pairs(API.GetActivePlayers()) do
        if Network.IsWaitingForNetworkSlotID(API.GetPlayerSlotID(v)) then
            table.insert(PlayerList, v);
        end
    end
    return PlayerList;
end

