--[[
Swift_5_Minimap/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleMinimap = {
    Properties = {
        Name = "ModuleMinimap",
    },

    Global = {
        MarkerCounter = 1000000,
        CreatedMinimapMarkers = {},
    },
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {},
};

-- Global ------------------------------------------------------------------- --

function ModuleMinimap.Global:OnGameStart()
end

function ModuleMinimap.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        for k, v in pairs(self.CreatedMinimapMarkers) do
            if v and v[4] ~= 7 then
                self:ShowMinimapMarker(k);
            end
        end
    end
end

function ModuleMinimap.Global:CreateMinimapMarker(_PlayerID, _PlayerIDOrColorTable, _X, _Y, _Type)
    local ID = self.MarkerCounter;
    self.MarkerCounter = self.MarkerCounter +1;
    self.CreatedMinimapMarkers[ID] = {_PlayerID, _PlayerIDOrColorTable, _X, _Y, _Type};
    self:ShowMinimapMarker(ID);
    return ID;
end

function ModuleMinimap.Global:DestroyMinimapMarker(_ID)
    self.CreatedMinimapMarkers[_ID] = nil;
    Logic.ExecuteInLuaLocalState(string.format(
        [[GUI.DestroyMinimapSignal(%d)]],
        _ID
    ));
end

function ModuleMinimap.Global:ShowMinimapMarker(_ID)
    local Data = self.CreatedMinimapMarkers[_ID];
    Logic.ExecuteInLuaLocalState(string.format(
        [[ModuleMinimap.Local:ShowMinimapMarker(%d, %d, %s, %f, %f, %d)]],
        _ID,
        Data[1],
        (type(Data[2]) == "table" and table.tostring(Data[2])) or tostring(Data[2]),
        Data[3],
        Data[4],
        Data[5]
    ))
end

-- Local -------------------------------------------------------------------- --

function ModuleMinimap.Local:OnGameStart()
end

function ModuleMinimap.Local:ShowMinimapMarker(_ID, _PlayerID, _PlayerIDOrColorTable, _X, _Y, _Type)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    local R, G, B, A = 0, 0, 0, 255;
    if type(_PlayerIDOrColorTable) == "number" then
        R, G, B = GUI.GetPlayerColor(_PlayerIDOrColorTable);
    else
        R = _PlayerIDOrColorTable[1];
        G = _PlayerIDOrColorTable[2];
        B = _PlayerIDOrColorTable[3];
        A = _PlayerIDOrColorTable[4] or A;
    end
    GUI.CreateMinimapSignalRGBA(_ID, _X, _Y, R, G, B, A, _Type);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleMinimap);

