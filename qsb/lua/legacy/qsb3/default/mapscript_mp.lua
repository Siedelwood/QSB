--[[
    ***********************************************************************
    Global Multiplayer Skript

    Kartenname: 
    Autor:      
    Version:    
    ***********************************************************************     
]]

-- Diese Funktion nicht löschen!!
function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");

    -- Mapeditor-Einstellungen werden geladen
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end
end

-- -------------------------------------------------------------------------- --
-- Mit dieser Funktion können KI-Spieler gesteuert werden.
--
-- Beispiel:
-- DoNotStartAIForPlayer(2); -> Keine KI (oder Banditenskript) für Spieler 2
--
function Mission_InitPlayers()
end

-- -------------------------------------------------------------------------- --
-- Diese Funktion setzt den Startmonat. Es muss zwingend immer einmalig ein
-- Startmonat gesetzt werden. Die Zahl steht für den Monat, wobei die Zahlen
-- 1 bis 12 für die Monate Januar bis Dezember stehen.
function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

-- -------------------------------------------------------------------------- --
-- In dieser Funktion können Angebote für Lagerhäuser und Handelsposten
-- erstellt werden.
--
-- Beispiel: Setzt Handelsangebote für Spieler 3
--
-- local SHID = Logic.GetStoreHouse(3);
-- AddMercenaryOffer(SHID, 2, Entities.U_MilitaryBandit_Melee_NA);
-- AddMercenaryOffer(SHID, 2, Entities.U_MilitaryBandit_Ranged_NA);
-- AddOffer(SHID, 1, Goods.G_Beer);
-- AddOffer(SHID, 1, Goods.G_Cow);

-- Beispiel: Setzt Tauschangebote für den Handelsposten von Spieler 3
--
-- local TPID = GetID("TP3");
-- Logic.TradePost_SetTradePartnerGenerateGoodsFlag(TPID, true);
-- Logic.TradePost_SetTradePartnerPlayerID(TPID, 3);
-- Logic.TradePost_SetTradeDefinition(TPID, 0, Goods.G_Carcass, 18, Goods.G_Milk, 18);
-- Logic.TradePost_SetTradeDefinition(TPID, 1, Goods.G_Grain, 18, Goods.G_Honeycomb, 18);
-- Logic.TradePost_SetTradeDefinition(TPID, 2, Goods.G_RawFish, 24, Goods.G_Salt, 12);
-- Logic.TradePost_SetTradeDefinition(TPID, 3, Goods.G_Wood, 24, Goods.G_Iron, 12);
--
function Mission_InitMerchants()
end

-- -------------------------------------------------------------------------- --
-- Lade zusätzliche Skriptdateien automatisch nach dem Laden der QSB aber
-- bevor die Mission beginnt.
-- Füge für jede Datei einen absoluten Pfad zum Speicherort hinzu. Dateien
-- werden aus der Map geladen oder während der Entwicklung aus dem Datei-
-- system. Das Root-Verzeichnis der Map ist in gvMission.ContentPath
-- gespeichert.
--
-- Beispiel:
-- return {
--    gvMission.ContentPath .. "promotion.lua",
--    gvMission.ContentPath .. "briefings.lua",
--    gvMission.ContentPath .. "quests.lua"
-- };
--
function Mission_LoadFiles()
    return {};
end

-- -------------------------------------------------------------------------- --
-- In dieser Funktion können eigene Funktionrn aufgerufen werden. Sie werden
-- atomatisch dann gestartet, wenn alle Spieler ins Spiel geladen haben.

function Mission_MP_OnQsbLoaded()
    -- Testmodus aktivieren
    -- (Auskommentieren, wenn nicht benötigt)
    API.ActivateDebugMode(true, false, true, true);

    -- Standard Quests starten
    -- (Auskommentieren, wenn nicht benötigt)
    -- SetupNPCQuests()

    -- Assistenten Quests starten
    -- (Auskommentieren, wenn nicht benötigt)
    CreateQuests();
end

-- -------------------------------------------------------------------------- --

