-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Global Script - <MAPNAME>                                              # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end
    Mission_OnQsbLoaded();
end

function Mission_InitPlayers()
end

function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

function Mission_InitMerchants()
end

function Mission_LoadFiles()
    local Path = "E:/Repositories/revision/qsb/lua/var/build/modules/";
    return {
        Path.. "qsb_1_gui/qsb_1_gui.lua",
        Path.. "qsb_1_movement/qsb_1_movement.lua",
        Path.. "qsb_1_entity/qsb_1_entity.lua",
        Path.. "qsb_1_requester/qsb_1_requester.lua",
        Path.. "qsb_1_sound/qsb_1_sound.lua",
        Path.. "qsb_1_trade/qsb_1_trade.lua",
        Path.. "qsb_2_buildingui/qsb_2_buildingui.lua",
        Path.. "qsb_2_npc/qsb_2_npc.lua",
        Path.. "qsb_2_objects/qsb_2_objects.lua",
        Path.. "qsb_2_promotion/qsb_2_promotion.lua",
        Path.. "qsb_2_quest/qsb_2_quest.lua",
        Path.. "qsb_3_lifestock/qsb_3_lifestock.lua",
        Path.. "qsb_5_weather/qsb_5_weather.lua",
    };
end

function Mission_OnQsbLoaded()
    API.ActivateDebugMode(true, false, true, true);

    local Position;
    Position = GetPosition("PathStart");
    Logic.CreateEffect(EGL_Effects.E_Questmarker_low, Position.X, Position.Y, 0);
    Position = GetPosition("PathEnd");
    Logic.CreateEffect(EGL_Effects.E_Questmarker_low, Position.X, Position.Y, 0);
end

GameCallback_QSB_OnEventReceived = function(_EventID, ...)
    if _EventID == QSB.ScriptEvents.PathFindingFailed then
        API.Note("Path failed: " ..arg[1]);
    elseif _EventID == QSB.ScriptEvents.PathFindingFinished then
        API.Note("Path found: " ..arg[1]);
        local Path = ModuleEntityMovement.Global.PathFinder:GetPath(arg[1]);
        Path = Path:Reduce(6);
        LuaDebugger.Log(Path);
        if Path then
            Path:Show();
        end
    end
end

-- > CreateSimplePath()

function CreateSimplePath()
    API.Note(ModuleEntityMovement.Global.PathFinder:Insert("PathStart", "PathEnd", 400, 30));
end

-- > CreateRoadPathWithTwoAlternatives()

function CreateRoadPathWithTwoAlternatives()
    API.Note(ModuleEntityMovement.Global.PathFinder:Insert(
        "PathEnd",
        "PathStart",
        300,
        30,
        function(_Node, _Siblings, _Start)
            local x,y,z = Logic.EntityGetPos(GetID(_Start));
            local e1, l1 = Logic.DoesRoadConnectionExist(_Node.X, _Node.Y, x, y, false, 10, nil);
            if e1 then
                for i= 1, #_Siblings do
                    if _Node.ID ~= _Siblings[i].ID then
                        local e2, l2 = Logic.DoesRoadConnectionExist(_Siblings[i].X, _Siblings[i].Y, x, y, false, 10, nil);
                        if e2 and l2 < l1 and l2 - l1 < 400 then
                            return false;
                        end
                    end
                end
                return true;
            end
            return false;
        end,
        "PathStart"
    ));
end

-- > CreateRoadPathWithBlockedAlternative()

function CreateRoadPathWithBlockedAlternative()
    ReplaceEntity("PathBlock", Entities.B_Storehouse_Rubble);

    API.Note(ModuleEntityMovement.Global.PathFinder:Insert(
        "PathEnd",
        "PathStart",
        500,
        30,
        function(_Node, _Siblings, _Start)
            if Logic.DEBUG_GetSectorAtPosition(_Node.X, _Node.Y) == 0 then
                return false;
            end

            local x,y,z = Logic.EntityGetPos(GetID(_Start));
            local e1, l1 = Logic.DoesRoadConnectionExist(_Node.X, _Node.Y, x, y, false, 10, nil);
            if e1 then
                for i= 1, #_Siblings do
                    if _Node.ID ~= _Siblings[i].ID then
                        local e2, l2 = Logic.DoesRoadConnectionExist(_Siblings[i].X, _Siblings[i].Y, x, y, false, 10, nil);
                        if e2 and l2 < l1 and l2 - l1 < 400 then
                            return false;
                        end
                    end
                end
                return true;
            end
            return false;
        end,
        "PathStart"
    ));
end