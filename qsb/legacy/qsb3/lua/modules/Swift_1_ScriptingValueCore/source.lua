--[[
Swift_1_ScriptingValueCore/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleScriptingValue = {
    Properties = {
        Name = "ModuleScriptingValue",
    },

    Global = {};
    Local  = {};
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        SV = {
            Game = "Vanilla",
            Vanilla = {
                Destination = {X = 19, Y= 20},
                Health      = -41,
                Player      = -71,
                Size        = -45,
                Visible     = -50,
                NPC         = 6,
            },
            HistoryEdition = {
                Destination = {X = 17, Y= 18},
                Health      = -38,
                Player      = -68,
                Size        = -42,
                Visible     = -47,
                NPC         = 6,
            }
        }
    };
};

-- Global ------------------------------------------------------------------- --

function ModuleScriptingValue.Global:OnGameStart()
    if API.IsHistoryEdition() then
        ModuleScriptingValue.Shared.SV.Game = "HistoryEdition";
    end
    QSB.ScriptingValue = ModuleScriptingValue.Shared.SV[ModuleScriptingValue.Shared.SV.Game];
end

-- Local -------------------------------------------------------------------- --

function ModuleScriptingValue.Local:OnGameStart()
    if API.IsHistoryEdition() then
        ModuleScriptingValue.Shared.SV.Game = "HistoryEdition";
    end
    QSB.ScriptingValue = ModuleScriptingValue.Shared.SV[ModuleScriptingValue.Shared.SV.Game];
end

-- Shared ------------------------------------------------------------------- --

function ModuleScriptingValue.Shared:qmod(a, b)
    return a - math.floor(a/b)*b
end

function ModuleScriptingValue.Shared:ScriptingValueBitsInteger(num)
    local t={}
    while num>0 do
        rest=self:qmod(num, 2) table.insert(t,1,rest) num=(num-rest)/2
    end
    table.remove(t, 1)
    return t
end

function ModuleScriptingValue.Shared:ScriptingValueBitsFraction(num, t)
    for i = 1, 48 do
        num = num * 2
        if(num >= 1) then table.insert(t, 1); num = num - 1 else table.insert(t, 0) end
        if(num == 0) then return t end
    end
    return t
end

function ModuleScriptingValue.Shared:ScriptingValueIntegerToFloat(num)
    if(num == 0) then return 0 end
    local sign = 1
    if(num < 0) then num = 2147483648 + num; sign = -1 end
    local frac = self:qmod(num, 8388608)
    local headPart = (num-frac)/8388608
    local expNoSign = self:qmod(headPart, 256)
    local exp = expNoSign-127
    local fraction = 1
    local fp = 0.5
    local check = 4194304
    for i = 23, 0, -1 do
        if(frac - check) > 0 then fraction = fraction + fp; frac = frac - check end
        check = check / 2; fp = fp / 2
    end
    return fraction * math.pow(2, exp) * sign
end

function ModuleScriptingValue.Shared:ScriptingValueFloatToInteger(fval)
    if(fval == 0) then return 0 end
    local signed = false
    if(fval < 0) then signed = true; fval = fval * -1 end
    local outval = 0;
    local bits
    local exp = 0
    if fval >= 1 then
        local intPart = math.floor(fval); local fracPart = fval - intPart;
        bits = self:ScriptingValueBitsInteger(intPart); exp = #bits; self:ScriptingValueBitsFraction(fracPart, bits)
    else
        bits = {}; self:ScriptingValueBitsFraction(fval, bits)
        while(bits[1] == 0) do exp = exp - 1; table.remove(bits, 1) end
        exp = exp - 1
        table.remove(bits, 1)
    end
    local bitVal = 4194304; local start = 1
    for bpos = start, 23 do
        local bit = bits[bpos]
        if(not bit) then break; end
        if(bit == 1) then outval = outval + bitVal end
        bitVal = bitVal / 2
    end
    outval = outval + (exp+127)*8388608
    if(signed) then outval = outval - 2147483648 end
    return outval;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleScriptingValue);

