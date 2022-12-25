--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Schafe und Kühe können vom Spieler gezüchtet werden.
-- 
-- Verschiedene Kenngrößen können angepasst werden.
--
-- Es wird ein Button an Kuh- und Schafställe angebracht. Damit kann die
-- Zucht individuell angehalten oder fortgesetzt werden. Dieser Button
-- belegt einen der 6 möglichen zusätzlichen Buttons bei den Ställen.
--
-- Wird im Produktionsmenü die Produktion von Kuh- oder Schaffarmen gestoppt,
-- werden jeweils alle Kuh- oder Schafställe ebenfalls gestoppt. Wird die
-- Produktion fortgeführt, wird auch die Zucht fortgeführt.
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
-- Events, auf die reagiert werden kann.
--
-- @field AnimalBreed Ein Nutztier wurde erzeugt. (Parameter: PlayerID, EntityID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erlaube oder verbiete dem Spieler Kühe zu züchten.
--
-- Die Zucht wird immer synchron für alle Spieler erlaubt oder verboten.
--
-- @param[type=boolean] _Flag Kuhzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es können keine Kühe gezüchtet werden
-- API.UseBreedCattle(false);
--
function API.ActivateCattleBreeding(_Flag)
    if GUI then
        return;
    end

    ModuleLifestockBreeding.Global.Sheep.Breeding = _Flag == true;
    Logic.ExecuteInLuaLocalState("ModuleLifestockBreeding.Local.Sheep.Breeding = " ..tostring(_Flag == true));
    if _Flag ~= true then
        local Price = MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep];
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    else
        local Price = ModuleLifestockBreeding.Global.Sheep.MoneyCost;
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    end
end

---
-- Erlaube oder verbiete dem Spieler Schafe zu züchten.
--
-- Die Zucht wird immer synchron für alle Spieler erlaubt oder verboten.
--
-- @param[type=boolean] _Flag Schafzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Schafsaufzucht ist erlaubt
-- API.UseBreedSheeps(true);
--
function API.ActivateSheepBreeding(_Flag)
    if GUI then
        return;
    end

    ModuleLifestockBreeding.Global.Cattle.Breeding = _Flag == true;
    Logic.ExecuteInLuaLocalState("ModuleLifestockBreeding.Local.Cattle.Breeding = " ..tostring(_Flag == true));
    if _Flag ~= true then
        local Price = MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow];
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    else
        local Price = ModuleLifestockBreeding.Global.Cattle.MoneyCost;
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    end
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
-- <td>RequiredAmount</td>
-- <td>number</td>
-- <td>Mindestanzahl an Tieren, die sich im Gebiet befinden müssen.
-- (Default: 2)</td>
-- </tr>
-- <tr>
-- <td>QuantityBoost</td>
-- <td>number</td>
-- <td>Menge an Sekunden, die jedes Tier im Gebiet die Zuchtauer verkürzt.
-- (Default: 9)</td>
-- </tr>
-- <tr>
-- <td>AreaSize</td>
-- <td>number</td>
-- <td>Größe des Gebietes, in dem Tiere für die Zucht vorhanden sein müssen.
-- (Default: 4500)</td>
-- </tr>
-- <tr>
-- <td>UseCalves</td>
-- <td>boolean</td>
-- <td>Gezüchtete Tiere erscheinen zuerst als Kälber und wachsen. Dies ist rein
-- kosmetisch und hat keinen Einfluss auf die Produktion. (Default: true)</td>
-- </tr>
-- <tr>
-- <td>CalvesSize</td>
-- <td>number</td>
-- <td>Bestimmt die initiale Größe der Kälber. Werden Kälber nicht benutzt, wird
-- diese Option ignoriert. (Default: 0.45)</td>
-- </tr>
-- <tr>
-- <td>FeedingTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden zwischen den Fütterungsperioden. Am Ende
-- jeder Periode wird pro züchtendem Gatter 1 Getreide abgezogen, wenn das
-- Gebäude nicht pausiert ist. (Default: 25)</td>
-- </tr>
-- <tr>
-- <td>BreedingTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden, bis ein neues Tier erscheint. Wenn für
-- eine Fütterung kein Getreide da ist, wird der Zähler zur letzten Fütterung
-- zurückgesetzt. (Default: 150)</td>
-- </tr>
-- <tr>
-- <td>GrothTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden zwischen den Wachstumsschüben eines
-- Kalbs. Jeder Wachstumsschub ist +0.05 Gößenänderung. (Default: 15)</td>
-- </tr>
-- </table>
-- 
-- @param[type=table] _Data Konfiguration der Zucht
-- @within Anwenderfunktionen
--
-- @usage
-- API.ConfigureCattleBreeding{
--     -- Es werden keine Tiere benötigt
--     RequiredAmount = 0,
--     -- Mindestzeit sind 3 Minuten
--     BreedingTimer = 3*60
-- }
--
function API.ConfigureCattleBreeding(_Data)
    if _Data.CalvesSize ~= nil then
        ModuleLifestockBreeding.Global.Cattle.CalvesSize = _Data.CalvesSize;
    end
    if _Data.RequiredAmount ~= nil then
        ModuleLifestockBreeding.Global.Cattle.RequiredAmount = _Data.RequiredAmount;
    end
    if _Data.QuantityBoost ~= nil then
        ModuleLifestockBreeding.Global.Cattle.QuantityBoost = _Data.QuantityBoost;
    end
    if _Data.AreaSize ~= nil then
        ModuleLifestockBreeding.Global.Cattle.AreaSize = _Data.AreaSize;
    end
    if _Data.UseCalves ~= nil then
        ModuleLifestockBreeding.Global.Cattle.UseCalves = _Data.UseCalves;
    end
    if _Data.FeedingTimer ~= nil then
        ModuleLifestockBreeding.Global.Cattle.FeedingTimer = _Data.FeedingTimer;
    end
    if _Data.BreedingTimer ~= nil then
        ModuleLifestockBreeding.Global.Cattle.BreedingTimer = _Data.BreedingTimer;
    end
    if _Data.GrothTimer ~= nil then
        ModuleLifestockBreeding.Global.Cattle.GrothTimer = _Data.GrothTimer;
    end
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
-- <td>RequiredAmount</td>
-- <td>number</td>
-- <td>Mindestanzahl an Tieren, die sich im Gebiet befinden müssen.
-- (Default: 2)</td>
-- </tr>
-- <tr>
-- <td>QuantityBoost</td>
-- <td>number</td>
-- <td>Menge an Sekunden, die jedes Tier im Gebiet die Zuchtauer verkürzt.
-- (Default: 9)</td>
-- </tr>
-- <tr>
-- <td>AreaSize</td>
-- <td>number</td>
-- <td>Größe des Gebietes, in dem Tiere für die Zucht vorhanden sein müssen.
-- (Default: 4500)</td>
-- </tr>
-- <tr>
-- <td>UseCalves</td>
-- <td>boolean</td>
-- <td>Gezüchtete Tiere erscheinen zuerst als Kälber und wachsen. Dies ist rein
-- kosmetisch und hat keinen Einfluss auf die Produktion. (Default: true)</td>
-- </tr>
-- <tr>
-- <td>CalvesSize</td>
-- <td>number</td>
-- <td>Bestimmt die initiale Größe der Kälber. Werden Kälber nicht benutzt, wird
-- diese Option ignoriert. (Default: 0.45)</td>
-- </tr>
-- <tr>
-- <td>FeedingTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden zwischen den Fütterungsperioden. Am Ende
-- jeder Periode wird pro züchtendem Gatter 1 Getreide abgezogen, wenn das
-- Gebäude nicht pausiert ist. (Default: 30)</td>
-- </tr>
-- <tr>
-- <td>BreedingTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden, bis ein neues Tier erscheint. Wenn für
-- eine Fütterung kein Getreide da ist, wird der Zähler zur letzten Fütterung
-- zurückgesetzt. (Default: 120)</td>
-- </tr>
-- <tr>
-- <td>GrothTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden zwischen den Wachstumsschüben eines
-- Kalbs. Jeder Wachstumsschub ist +0.05 Gößenänderung. (Default: 15)</td>
-- </tr>
-- </table>
-- 
-- @param[type=table] _Data Konfiguration der Zucht
-- @within Anwenderfunktionen
--
-- @usage
-- API.ConfigureSheepBreeding{
--     -- Es werden keine Tiere benötigt
--     RequiredAmount = 0,
--     -- Mindestzeit sind 3 Minuten
--     BreedingTimer = 3*60
-- }
--
function API.ConfigureSheepBreeding(_Data)
    if _Data.CalvesSize ~= nil then
        ModuleLifestockBreeding.Global.Sheep.CalvesSize = _Data.CalvesSize;
    end
    if _Data.RequiredAmount ~= nil then
        ModuleLifestockBreeding.Global.Sheep.RequiredAmount = _Data.RequiredAmount;
    end
    if _Data.QuantityBoost ~= nil then
        ModuleLifestockBreeding.Global.Sheep.QuantityBoost = _Data.QuantityBoost;
    end
    if _Data.AreaSize ~= nil then
        ModuleLifestockBreeding.Global.Sheep.AreaSize = _Data.AreaSize;
    end
    if _Data.UseCalves ~= nil then
        ModuleLifestockBreeding.Global.Sheep.UseCalves = _Data.UseCalves;
    end
    if _Data.FeedingTimer ~= nil then
        ModuleLifestockBreeding.Global.Sheep.FeedingTimer = _Data.FeedingTimer;
    end
    if _Data.BreedingTimer ~= nil then
        ModuleLifestockBreeding.Global.Cattle.BreedingTimer = _Data.BreedingTimer;
    end
    if _Data.GrothTimer ~= nil then
        ModuleLifestockBreeding.Global.Sheep.GrothTimer = _Data.GrothTimer;
    end
end

