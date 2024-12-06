-- -------------------------------------------------------------------------- --

---
-- Schafe und Kühe können vom Spieler gezüchtet werden.
-- 
-- Es wird der klassische Kaufbutton an Gehegen angebracht, über den für eine
-- bestimmte Menge Getreide ein neues Tier gekauft werden kann. Tiere können 
-- ebenso Getreide verbrauchen, aber es gibt keine Konsequenzen, wenn Getreide
-- ausgeht.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Ankeigekontrolle</a></li>
-- <li><a href="modules.QSB_2_BuildingUI.QSB_2_BuildingUI.html">(2) Gebäudeschalter</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Aktiviert/Deaktiviert die Zucht von Kühen.
--
-- @param[type=table] _PlayerID ID des Spielers
-- @param[type=table] _Flag Zucht ist aktiv
-- @within Anwenderfunktionen
--
function API.ActivateCattleBreeding(_PlayerID, _Flag)
    if (IsLocalScript()) then
        error("Can not be used in local script!");
        return;
    end

    ModuleLifestockBreeding.Global.PlayerData[_PlayerID].CattleActive = _Flag == true;
    local Command = string.format(
        [[ModuleLifestockBreeding.Global.PlayerData[%d].CattleActive = %s]],
        _PlayerID, tostring(_Flag == true)
    );
    Logic.ExecuteInLuaLocalState(Command);
end

---
-- Aktiviert/Deaktiviert die Zucht von Schafen.
--
-- @param[type=table] _PlayerID ID des Spielers
-- @param[type=table] _Flag Zucht ist aktiv
-- @within Anwenderfunktionen
--
function API.ActivateSheepBreeding(_PlayerID, _Flag)
    if (IsLocalScript()) then
        error("Can not be used in local script!");
        return;
    end

    ModuleLifestockBreeding.Global.PlayerData[_PlayerID].SheepActive = _Flag == true;
    local Command = string.format(
        [[ModuleLifestockBreeding.Global.PlayerData[%d].SheepActive = %s]],
        _PlayerID, tostring(_Flag == true)
    );
    Logic.ExecuteInLuaLocalState(Command);
end

---
-- Konfiguriert die Zucht von Kühen.
--
-- Die Konfiguration erfolgt immer synchron für alle Spieler.
--
-- Mögliche Optionen:
-- <table border="1">
-- <tr>
-- <td><b>Option</b></td>
-- <td><b>Datentyp</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>BasePrice</td>
-- <td>integer</td>
-- <td>Basispreis für Tiere bei Händlern
-- (Default: 300)</td>
-- </tr>
-- <tr>
-- <td>GrainCost</td>
-- <td>integer</td>
-- <td>Initiale Menge, benötigt um ein Tier zu züchten.
-- (Default: 10)</td>
-- </tr>
-- <tr>
-- <td>GrainUpkeep</td>
-- <td>integer</td>
-- <td>Menge an Getreide, das ein Tier konsumiert.
-- (Default: 1)</td>
-- </tr>
-- <tr>
-- <td>FeedingTimer</td>
-- <td>integer</td>
-- <td>Zeit, bis Tiere gefüttert werden. (0 = aus)
-- (Default: 0)</td>
-- </tr>
-- </table>
-- 
-- @param[type=table] _Data Konfiguration der Zucht
-- @within Anwenderfunktionen
--
-- @usage
-- API.ConfigureCattleBreeding{
--     -- Es werden keine Tiere benötigt
--     GrainCost = 0,
--     -- 2 Getreide werden konsumiert
--     GrainUpkeep = 2,
--     -- Fütterungsinterval
--     FeedingTimer = 3*60,
-- }
--
function API.ConfigureCattleBreeding(_Data)
    if (IsLocalScript()) then
        error("Can not be used in local script!");
        return;
    end
    if (type(_Data) ~= "table") then
        error("Malformed data passed!");
        return;
    end

    local CattleBasePrice = _Data.BasePrice or 300;
    local CattleGrainCost = _Data.GrainCost or 10;
    local CattleGrainUpkeep = _Data.GrainUpkeep or 1;
    local CattleFeedingTimer = _Data.FeedingTimer or 0;

    local Command = string.format([[ModuleLifestockBreeding.Global.CattleBasePrice = %d]], CattleBasePrice);
    Logic.ExecuteInLuaLocalState(Command);
    ModuleLifestockBreeding.Global.CattleBasePrice = CattleBasePrice;

    local Command = string.format([[MerchantSystem.BasePrices[Goods.G_Cow] = %d]], CattleGrainCost);
    Logic.ExecuteInLuaLocalState(Command);
    MerchantSystem.BasePrices[Goods.G_Cow] = CattleBasePrice;

    local Command = string.format([[ModuleLifestockBreeding.Global.CattleGrainCost = %d]], CattleGrainCost);
    Logic.ExecuteInLuaLocalState(Command);
    ModuleLifestockBreeding.Global.CattleGrainCost = CattleGrainCost;

    local Command = string.format([[ModuleLifestockBreeding.Global.CattleGrainUpkeep = %d]], CattleGrainUpkeep);
    Logic.ExecuteInLuaLocalState(Command);
    ModuleLifestockBreeding.Global.CattleGrainUpkeep = CattleGrainUpkeep;

    local Command = string.format([[ModuleLifestockBreeding.Global.CattleFeedingTimer = %d]], CattleFeedingTimer);
    Logic.ExecuteInLuaLocalState(Command);
    ModuleLifestockBreeding.Global.CattleFeedingTimer = CattleFeedingTimer;
end

---
-- Konfiguriert die Zucht von Schafen.
--
-- Die Konfiguration erfolgt immer synchron für alle Spieler.
--
-- Mögliche Optionen:
-- <table border="1">
-- <tr>
-- <td><b>Option</b></td>
-- <td><b>Datentyp</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>BasePrice</td>
-- <td>integer</td>
-- <td>Basispreis für Tiere bei Händlern
-- (Default: 300)</td>
-- </tr>
-- <tr>
-- <td>GrainCost</td>
-- <td>integer</td>
-- <td>Initiale Menge, benötigt um ein Tier zu züchten.
-- (Default: 10)</td>
-- </tr>
-- <tr>
-- <td>GrainUpkeep</td>
-- <td>integer</td>
-- <td>Menge an Getreide, das ein Tier konsumiert.
-- (Default: 1)</td>
-- </tr>
-- <tr>
-- <td>FeedingTimer</td>
-- <td>integer</td>
-- <td>Zeit, bis Tiere gefüttert werden. (0 = aus)
-- (Default: 0)</td>
-- </tr>
-- </table>
-- 
-- @param[type=table] _Data Konfiguration der Zucht
-- @within Anwenderfunktionen
--
-- @usage
-- API.ConfigureSheepBreeding{
--     -- Es werden keine Tiere benötigt
--     GrainCost = 0,
--     -- 2 Getreide werden konsumiert
--     GrainUpkeep = 2,
--     -- Fütterungsinterval
--     FeedingTimer = 3*60,
-- }
--
function API.ConfigureSheepBreeding(_Data)
    if (IsLocalScript()) then
        error("Can not be used in local script!");
        return;
    end
    if (type(_Data) ~= "table") then
        error("Malformed data passed!");
        return;
    end

    local SheepBasePrice = _Data.SheepBasePrice or 300;
    local SheepGrainCost = _Data.SheepGrainCost or 10;
    local SheepGrainUpkeep = _Data.SheepGrainUpkeep or 1;
    local SheepFeedingTimer = _Data.SheepFeedingTimer or 0;

    local Command = string.format([[ModuleLifestockBreeding.Global.SheepBasePrice = %d]], SheepBasePrice);
    Logic.ExecuteInLuaLocalState(Command);
    ModuleLifestockBreeding.Global.SheepBasePrice = SheepBasePrice;

    local Command = string.format([[MerchantSystem.BasePrices[Goods.G_Sheep] = %d]], SheepBasePrice);
    Logic.ExecuteInLuaLocalState(Command);
    MerchantSystem.BasePrices[Goods.G_Sheep] = SheepBasePrice;

    local Command = string.format([[ModuleLifestockBreeding.Global.SheepGrainCost = %d]], SheepGrainCost);
    Logic.ExecuteInLuaLocalState(Command);
    ModuleLifestockBreeding.Global.SheepGrainCost = SheepGrainCost;

    local Command = string.format([[ModuleLifestockBreeding.Global.SheepGrainUpkeep = %d]], SheepGrainUpkeep);
    Logic.ExecuteInLuaLocalState(Command);
    ModuleLifestockBreeding.Global.SheepGrainUpkeep = SheepGrainUpkeep;

    local Command = string.format([[ModuleLifestockBreeding.Global.SheepFeedingTimer = %d]], SheepFeedingTimer);
    Logic.ExecuteInLuaLocalState(Command);
    ModuleLifestockBreeding.Global.SheepFeedingTimer = SheepFeedingTimer;
end

