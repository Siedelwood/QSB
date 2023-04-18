--[[
    ***********************************************************************
    Lokales Multiplayer Skript

    Kartenname: 
    Autor:      
    Version:    
    ***********************************************************************     
]]

-- Diese Funktion nicht löschen!!
function Mission_LocalVictory()
end

-- -------------------------------------------------------------------------- --
-- Lade zusätzliche Skriptdateien automatisch nach dem Laden der QSB aber bevor
-- die Mission beginnt.
-- Füge für jede Datei einen absoluten Pfad zum Speicherort hinzu. Dateien
-- werden aus der Map geladen oder während der Entwicklung aus dem Dateisystem.
-- Das Root-Verzeichnis der Map ist in gvMission.ContentPath gespeichert.
--
-- Beispiel:
-- return {
--    gvMission.ContentPath .. "promotion.lua"
-- };
--
function Mission_LoadFiles()
    return {};
end

-- -------------------------------------------------------------------------- --
-- In dieser Funktion können eigene Funktionrn aufgerufen werden. Sie werden
-- atomatisch dann gestartet, wenn alle Spieler ins Spiel geladen haben.
function Mission_MP_LocalOnQsbLoaded()
    
end

-- -------------------------------------------------------------------------- --

