-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --
-- ||||                          LOKALES SKRIPT                          |||| --
-- ||||                    --------------------------                    |||| --
-- ||||                            QSB Testmap                           |||| --
-- ||||                           totalwarANGEL                          |||| --
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --

-- ========================================================================== --

function Mission_LocalOnMapStart()
end

function Mission_LocalVictory()
end

-- ========================================================================== --

-- -------------------------------------------------------------------------- --
-- Diese Funktion läd Skriptdateien bevor die Module initalisiert werden.
-- (der Pfad zur Map steht in der Variable gvMission.ContentPath)
--
-- Beispiel:
-- return {
--    gvMission.ContentPath .. "promotion.lua",
-- };
--
function Mission_LoadFiles()
    local MapPath = "maps/externalmap/demomap/";
    if false then
        MapPath = "E:/Repositories/revision/qsb/demo/QSB_2_Promotion/demomap.s6xmap.unpacked/" ..MapPath;
    end
    return {
        MapPath.. "script/requirements.lua",
        MapPath.. "script/requirements_alternate.lua",
        MapPath.. "script/localmapscript.lua",
    };
end

-- -------------------------------------------------------------------------- --
-- Diese Funktion wird nach Spielstart aufgerufen.
--
function Mission_LocalOnQsbLoaded()
    StartScript();
end

