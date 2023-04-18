--[[
Swift_0_Core/LuaBase

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

Swift.LuaBase = {};

function Swift.LuaBase:OverrideBaseLua()
    self:OverrideTable();
    self:OverrideString();
    self:OverrideMath();
end

function Swift.LuaBase:OverrideTable()
    table.compare = function(t1, t2, fx)
        assert(type(t1) == "table");
        assert(type(t2) == "table");
        fx = fx or function(t1, t2)
            return tostring(t1) < tostring(t2);
        end
        assert(type(fx) == "function");
        return fx(t1, t2);
    end

    table.equals = function(t1, t2)
        assert(type(t1) == "table");
        assert(type(t2) == "table");
        for k, v in pairs(t1) do
            if type(v) == "table" then
                if not t2[k] or not table.equals(t2[k], v) then
                    return false;
                end
            elseif type(v) ~= "thread" and type(v) ~= "userdata" then
                if not t2[k] or t2[k] ~= v then
                    return false;
                end
            end
        end
        return true;
    end

    table.contains = function (t, e)
        assert(type(t) == "table");
        for k, v in pairs(t) do
            if v == e then
                return true;
            end
        end
        return false;
    end

    table.length = function(t)
        local c = 0;
        for k, v in pairs(t) do
            if tonumber(k) then
                c = c +1;
            end
        end
        return c;
    end

    table.size = function(t)
        local c = 0;
        for k, v in pairs(t) do
            -- Ignore n if set
            if k ~= "n" or (k == "n" and type(v) ~= "number") then
                c = c +1;
            end
        end
        return c;
    end

    table.isEmpty = function(t)
        return table.size(t) == 0;
    end

    table.copy = function (t1, t2)
        t2 = t2 or {};
        assert(type(t1) == "table");
        assert(type(t2) == "table");
        return Swift.LuaBase:CopyTable(t1, t2);
    end

    table.invert = function (t1)
        assert(type(t1) == "table");
        local t2 = {};
        for i= table.length(t1), 1, -1 do
            table.insert(t2, t1[i]);
        end
        return t2;
    end

    table.push = function (t, e)
        assert(type(t) == "table");
        table.insert(t, 1, e);
    end

    table.pop = function (t)
        assert(type(t) == "table");
        return table.remove(t, 1);
    end

    table.tostring = function(t)
        return Swift.LuaBase:ConvertTableToString(t);
    end

    table.insertAll = function(t, ...)
        for i= 1, #arg do
            if not table.contains(t, arg[i]) then
                table.insert(t, arg[i]);
            end
        end
        return t;
    end

    table.removeAll = function(t, ...)
        for i= 1, #arg do
            for k, v in pairs(t) do
                if type(v) == "table" and type(arg[i]) then
                    if table.equals(v, arg[i]) then
                        t[k] = nil;
                    end
                else
                    if v == arg[i] then
                        t[k] = nil;
                    end
                end
            end
        end
        -- Set n as table remove would do
        t.n = table.length(t);
        return t;
    end

    table.setMetatable = function(t, meta)
        assert(type(t) == "table");
        assert(type(meta) == "table" or meta == nil);

        local oldmeta = meta;
        meta = {};
        for k,v in pairs(oldmeta) do
            meta[k] = v;
        end
        oldmeta = getmetatable(t);
        setmetatable(t, meta);
        local k = 0;
        if oldmeta and oldmeta.KeySave and t == QSB.Metatable.Weak[oldmeta.KeySave] then
            k = oldmeta.KeySave;
            if meta == nil then
                QSB.Metatable.Weak[k] = nil;
                QSB.Metatablele.Metas[k] = nil;
                return;
            end
        else
            k = QSB.Metatable.Key + 1;
            QSB.Metatable.Key = k;
        end
        QSB.Metatable.Weak[k] = t;
        QSB.Metatable.Metas[k] = meta;
        meta.KeySave = k;
    end

    table.restoreMetatables = function()
        for k, tab in pairs(QSB.Metatable.Weak) do
            setmetatable(tab, QSB.Metatable.Metas[k]);
        end
        setmetatable(QSB.Metatable.Weak, {__mode = "v"});
        setmetatable(QSB.Metatable.Metas, {__mode = "v"});
    end
    table.restoreMetatables();
end

function Swift.LuaBase:OverrideString()
    string.contains = function (self, s)
        return self:find(s) ~= nil;
    end

    string.indexOf = function (self, s)
        return self:find(s);
    end

    string.slice = function(self, _sep)
        _sep = _sep or "%s";
        if self then
            local t = {};
            for str in self:gmatch("([^".._sep.."]+)") do
                table.insert(t, str);
            end
            return t;
        end
    end

    string.join = function(self, ...)
        local s = "";
        local parts = {self, unpack(arg)};
        for i= 1, #parts do
            if type("part") == "table" then
                s = s .. string.join(unpack(parts[i]));
            else
                s = s .. tostring(parts[i]);
            end
        end
        return s;
    end

    string.replace = function(self, p, r)
        return self:gsub(p, r, 1);
    end

    string.replaceAll = function(self, p, r)
        return self:gsub(p, r);
    end
end

function Swift.LuaBase:OverrideMath()
    math.lerp = function(s, c, e)
        local f = (c - s) / e;
        return (f > 1 and 1) or f;
    end
end

function Swift.LuaBase:ConvertTableToString(_Table)
    assert(type(_Table) == "table");
    local String = "{";
    for k, v in pairs(_Table) do
        local key;
        if (tonumber(k)) then
            key = ""..k;
        else
            key = "\""..k.."\"";
        end
        if type(v) == "table" then
            String = String .. "[" .. key .. "] = " .. table.tostring(v) .. ", ";
        elseif type(v) == "number" then
            String = String .. "[" .. key .. "] = " .. v .. ", ";
        elseif type(v) == "string" then
            String = String .. "[" .. key .. "] = \"" .. v .. "\", ";
        elseif type(v) == "boolean" or type(v) == "nil" then
            String = String .. "[" .. key .. "] = " .. tostring(v) .. ", ";
        else
            String = String .. "[" .. key .. "] = \"" .. tostring(v) .. "\", ";
        end
    end
    String = String .. "}";
    return String;
end

function Swift.LuaBase:CopyTable(_Table1, _Table2)
    _Table1 = _Table1 or {};
    _Table2 = _Table2 or {};
    for k, v in pairs(_Table1) do
        if "table" == type(v) then
            _Table2[k] = _Table2[k] or {};
            for kk, vv in pairs(self:CopyTable(v, _Table2[k])) do
                _Table2[k][kk] = _Table2[k][kk] or vv;
            end
        else
            _Table2[k] = v;
        end
    end
    return _Table2;
end

function Swift.LuaBase:ToBoolean(_Input)
    if type(_Input) == "boolean" then
        return _Input;
    end
    if _Input == 1 or string.find(string.lower(tostring(_Input)), "^[1tjy\\+].*$") then
        return true;
    end
    return false;
end

