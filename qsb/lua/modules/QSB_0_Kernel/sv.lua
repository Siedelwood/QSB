--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Scripting Values lesen und schreiben.
-- @set sort=true
-- @local
--

Revision.ScriptingValue = {
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
}

function Revision.ScriptingValue:Initalize()
    if Revision.GameVersion == QSB.GameVersion.HISTORY_EDITION then
        self.SV.Game = "HistoryEdition";
    end
    QSB.ScriptingValue = self.SV[self.SV.Game];
end

function Revision.ScriptingValue:OnSaveGameLoaded()
    -- Porting savegames between game versions
    -- (Not recommended but we try to support it)
    if Revision.GameVersion == QSB.GameVersion.HISTORY_EDITION then
        self.SV.Game = "HistoryEdition";
    end
    QSB.ScriptingValue = self.SV[self.SV.Game];
end

QSB.ScriptingValue = {};

-- -------------------------------------------------------------------------- --
-- Conversion Methods

function Revision.ScriptingValue:BitsInteger(num)
    local t = {};
    while num > 0 do
        rest = math.qmod(num, 2);
        table.insert(t,1,rest);
        num=(num-rest)/2;
    end
    table.remove(t, 1);
    return t;
end

function Revision.ScriptingValue:BitsFraction(num, t)
    for i = 1, 48 do
        num = num * 2;
        if(num >= 1) then
            table.insert(t, 1);
            num = num - 1;
        else
            table.insert(t, 0);
        end
        if(num == 0) then
            return t;
        end
    end
    return t;
end

function Revision.ScriptingValue:IntegerToFloat(num)
    if(num == 0) then
        return 0;
    end
    local sign = 1;
    if (num < 0) then
        num = 2147483648 + num;
        sign = -1;
    end
    local frac = math.qmod(num, 8388608);
    local headPart = (num-frac)/8388608;
    local expNoSign = math.qmod(headPart, 256);
    local exp = expNoSign-127;
    local fraction = 1;
    local fp = 0.5;
    local check = 4194304;
    for i = 23, 0, -1 do
        if (frac - check) > 0 then
            fraction = fraction + fp;
            frac = frac - check;
        end
        check = check / 2;
        fp = fp / 2;
    end
    return fraction * math.pow(2, exp) * sign;
end

function Revision.ScriptingValue:FloatToInteger(fval)
    if(fval == 0) then
        return 0;
    end
    local signed = false;
    if (fval < 0) then
        signed = true;
        fval = fval * -1;
    end
    local outval = 0;
    local bits;
    local exp = 0;
    if fval >= 1 then
        local intPart = math.floor(fval);
        local fracPart = fval - intPart;
        bits = self:BitsInteger(intPart);
        exp = #bits;
        self:BitsFraction(fracPart, bits);
    else
        bits = {};
        self:BitsFraction(fval, bits);
        while(bits[1] == 0) do
            exp = exp - 1;
            table.remove(bits, 1);
        end
        exp = exp - 1;
        table.remove(bits, 1);
    end
    local bitVal = 4194304;
    local start = 1;
    for bpos = start, 23 do
        local bit = bits[bpos];
        if(not bit) then
            break;
        end
        if(bit == 1) then
            outval = outval + bitVal;
        end
        bitVal = bitVal / 2;
    end
    outval = outval + (exp+127)*8388608;
    if(signed) then
        outval = outval - 2147483648;
    end
    return outval;
end

-- -------------------------------------------------------------------------- --
-- API

---
-- Gibt den Wert auf dem übergebenen Index für das Entity zurück.
--
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @return[type=number] Ermittelter Wert
-- @within ScriptingValue
--
-- @usage
-- local PlayerID = API.GetInteger("HansWurst", QSB.ScriptingValue.Player);
--
function API.GetInteger(_Entity, _SV)
    local ID = GetID(_Entity);
    if not IsExisting(ID) then
        return;
    end
    return Logic.GetEntityScriptingValue(ID, _SV);
end

---
-- Gibt den Wert auf dem übergebenen Index für das Entity zurück.
--
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @return[type=number] Ermittelter Wert
-- @within ScriptingValue
--
-- @usage
-- local Size = API.GetFloat("HansWurst", QSB.ScriptingValue.Size);
--
function API.GetFloat(_Entity, _SV)
    local ID = GetID(_Entity);
    if not IsExisting(ID) then
        return;
    end
    local Value = Logic.GetEntityScriptingValue(ID, _SV);
    return API.ConvertIntegerToFloat(Value);
end

---
-- Setzt den Wert auf dem übergebenen Index für das Entity.
-- 
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @param[type=number] _Value  Zu setzender Wert
-- @within ScriptingValue
--
-- @usage
-- API.SetInteger("HansWurst", QSB.ScriptingValue.Player, 2);
--
function API.SetInteger(_Entity, _SV, _Value)
    local ID = GetID(_Entity);
    if GUI or not IsExisting(ID) then
        return;
    end
    Logic.SetEntityScriptingValue(ID, _SV, _Value);
end

---
-- Setzt den Wert auf dem übergebenen Index für das Entity.
--
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @param[type=number] _Value  Zu setzender Wert
-- @within ScriptingValue
--
-- @usage
-- API.SetFloat("HansWurst", QSB.ScriptingValue.Size, 1.5);
--
function API.SetFloat(_Entity, _SV, _Value)
    local ID = GetID(_Entity);
    if GUI or not IsExisting(ID) then
        return;
    end
    Logic.SetEntityScriptingValue(ID, _SV, API.ConvertFloatToInteger(_Value));
end

---
-- Konvertirert den Wert in eine Ganzzahl.
--
-- @param[type=number] _Value Gleitkommazahl
-- @return[type=number] Konvertierte Ganzzahl
-- @within ScriptingValue
--
-- @usage
-- local Converted = API.ConvertIntegerToFloat(Value)
--
function API.ConvertIntegerToFloat(_Value)
    return Revision.ScriptingValue:IntegerToFloat(_Value);
end

---
-- Konvertirert den Wert in eine Gleitkommazahl.
--
-- @param[type=number] _Value Gleitkommazahl
-- @return[type=number] Konvertierte Ganzzahl
-- @within ScriptingValue
--
-- @usage
-- local Converted = API.ConvertFloatToInteger(Value)
--
function API.ConvertFloatToInteger(_Value)
    return Revision.ScriptingValue:FloatToInteger(_Value);
end
