--[[
Swift_2_CastleStore/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

SCP.CastleStore = {};

ModuleCastleStore = {
    Properties = {
        Name = "ModuleCastleStore",
    },

    Global = {
        UpdateCastleStoreInitalized = false,
        BackupGoods = {},

        CastleStore = {
            UpdateCastleStore = true,
            CapacityBase = 75,
            Goods = {
                -- [Ware] = {Menge, Einlager-Flag, Gesperrt-Flag, Untergrenze}
                [Goods.G_Wood]      = {0, true, false, 35},
                [Goods.G_Stone]     = {0, true, false, 35},
                [Goods.G_Iron]      = {0, true, false, 35},
                [Goods.G_Carcass]   = {0, true, false, 15},
                [Goods.G_Grain]     = {0, true, false, 15},
                [Goods.G_RawFish]   = {0, true, false, 15},
                [Goods.G_Milk]      = {0, true, false, 15},
                [Goods.G_Herb]      = {0, true, false, 15},
                [Goods.G_Wool]      = {0, true, false, 15},
                [Goods.G_Honeycomb] = {0, true, false, 15},
            }
        },
    },
    Local = {
        Shortcuts = {},
        CastleStore = {},
        Player = {},
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Text = {
            ShowCastle = {
                Text = {
                    de = "Finanzansicht",
                    en = "Financial view",
                    fr = "Vue financière",
                },
            },

            ShowCastleStore = {
                Text = {
                    de = "Lageransicht",
                    en = "Storeage view",
                    fr = "Vue de l'entrepôt",
                },
            },

            GoodButtonDisabled = {
                Text = {
                    de = "Diese Ware wird nicht angenommen.",
                    en = "This good will not be stored.",
                    fr = "Cette marchandise n'est pas acceptée.",
                },
            },

            CityTab = {
                Title = {
                    de = "Güter verwaren",
                    en = "Keep goods",
                    fr = "Garder les marchandises",
                },
                Text = {
                    de = "[UMSCHALT + N]{cr}- Lagert Waren im Burglager ein {cr}- Waren verbleiben auch im Lager, wenn Platz vorhanden ist",
                    en = "[SHIFT + N]{cr}- Stores goods inside the vault {cr}- Goods also remain in the warehouse when space is available",
                    fr = "[SHIFT + N]{cr}- Entrepose les marchandises dans l'entrepôt du château {cr}- Les marchandises restent aussi dans l'entrepôt s'il y a de la place",
                },
            },

            StorehouseTab = {
                Title = {
                    de = "Güter zwischenlagern",
                    en = "Store in vault",
                    fr = "Stockage temporaire des marchandises",
                },
                Text = {
                    de = "[UMSCHALT + B]{cr}- Lagert Waren im Burglager ein {cr}- Lagert waren wieder aus, sobald Platz frei wird",
                    en = "[SHIFT + B]{cr}- Stores goods inside the vault {cr}- Allows to extrac goods as soon as space becomes available",
                    fr = "[SHIFT + B]{cr}- Entrepose des marchandises dans l'entrepôt du château {cr}- Enlève des marchandises dès que l'espace est libre",
                },
            },

            MultiTab = {
                Title = {
                    de = "Lager räumen",
                    en = "Clear store",
                    fr = "Vider l'entrepôt",
                },
                Text = {
                    de = "[UMSCHALT + M]{cr}- Lagert alle Waren aus {cr}- Benötigt Platz im Lagerhaus",
                    en = "[Shift + M]{cr}- Removes all goods {cr}- Requires space in the storehouse",
                    fr = "[SHIFT + M]{cr}- Enlève toutes les marchandises {cr}- Nécessite de l'espace dans l'entrepôt",
                },
            },
        },
    },
}

QSB.CastleStoreObjects = {};
QSB.CastleStorePlayerData = {};

-- Global ------------------------------------------------------------------- --

function ModuleCastleStore.Global:OnGameStart()
    QSB.CastleStore = self.CastleStore;

    API.RegisterScriptCommand("Cmd_CastleStoreAcceptAllGoods", SCP.CastleStore.AcceptAllGoods);
    API.RegisterScriptCommand("Cmd_CastleStoreLockAllGoods", SCP.CastleStore.LockAllGoods);
    API.RegisterScriptCommand("Cmd_CastleStoreRefuseAllGoods", SCP.CastleStore.RefuseAllGoods);
    API.RegisterScriptCommand("Cmd_CastleStoreToggleGoodState", SCP.CastleStore.ToggleGoodState);
    API.RegisterScriptCommand("Cmd_CastleStoreObjectPayStep1", SCP.CastleStore.ObjectPayStep1);
    API.RegisterScriptCommand("Cmd_CastleStoreObjectPayStep3", SCP.CastleStore.ObjectPayStep3);

    for i= 1, 8 do
        self.BackupGoods[i] = {};
    end
    self:OverwriteGameFunctions();
end

function ModuleCastleStore.Global.CastleStore:New(_PlayerID)
    assert(self == ModuleCastleStore.Global.CastleStore, "Can not be used from instance!");
    local Store = table.copy(self);
    Store.PlayerID = _PlayerID;
    QSB.CastleStoreObjects[_PlayerID] = Store;

    if not self.UpdateCastleStoreInitalized then
        self.UpdateCastleStoreInitalized = true;
        API.StartHiResJob(function()
            ModuleCastleStore.Global.CastleStore:UpdateStores()
        end);
    end
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore:CreateStore(]] ..Store.PlayerID.. [[);
    ]])
    return Store;
end

function ModuleCastleStore.Global.CastleStore:GetInstance(_PlayerID)
    assert(self == ModuleCastleStore.Global.CastleStore, "Can not be used from instance!");
    return QSB.CastleStoreObjects[_PlayerID];
end

function ModuleCastleStore.Global.CastleStore:GetGoodAmountWithCastleStore(_Good, _PlayerID, _InSettlement)
    assert(self == ModuleCastleStore.Global.CastleStore, "Can not be used from instance!");
    local CastleStore = self:GetInstance(_PlayerID);
    local Amount = GetPlayerGoodsInSettlement(_Good, _PlayerID, _InSettlement);

    if CastleStore ~= nil and _Good ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(_Good) == GoodCategories.GC_Resource then
        Amount = Amount + CastleStore:GetAmount(_Good);
    end
    return Amount;
end

function ModuleCastleStore.Global.CastleStore:Dispose()
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore:DeleteStore(]] ..self.PlayerID.. [[);
    ]])
    QSB.CastleStoreObjects[self.PlayerID] = nil;
end

function ModuleCastleStore.Global.CastleStore:SetUperLimitInStorehouseForGoodType(_Good, _Limit)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    self.Goods[_Good][4] = _Limit;
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStorePlayerData[]] ..self.PlayerID.. [[].Goods[]] .._Good.. [[][4] = ]] .._Limit.. [[
    ]])
    return self;
end

function ModuleCastleStore.Global.CastleStore:SetStorageLimit(_Limit)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    self.CapacityBase = math.floor(_Limit/2);
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStorePlayerData[]] ..self.PlayerID.. [[].CapacityBase = ]] ..math.floor(_Limit/2).. [[
    ]])
    return self;
end

function ModuleCastleStore.Global.CastleStore:GetAmount(_Good)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    if self.Goods[_Good] then
        return self.Goods[_Good][1];
    end
    return 0;
end

function ModuleCastleStore.Global.CastleStore:GetTotalAmount()
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    local TotalAmount = 0;
    for k, v in pairs(self.Goods) do
        TotalAmount = TotalAmount + v[1];
    end
    return TotalAmount;
end

function ModuleCastleStore.Global.CastleStore:GetLimit()
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    local Level = 0;
    local Headquarters = Logic.GetHeadquarters(self.PlayerID);
    if Headquarters ~= 0 then
        Level = Logic.GetUpgradeLevel(Headquarters);
    end

    local Capacity = self.CapacityBase;
    for i= 1, (Level+1), 1 do
        Capacity = Capacity * 2;
    end
    return Capacity;
end

function ModuleCastleStore.Global.CastleStore:IsGoodAccepted(_Good)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    return self.Goods[_Good][2] == true;
end

function ModuleCastleStore.Global.CastleStore:SetGoodAccepted(_Good, _Flag)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    self.Goods[_Good][2] = _Flag == true;
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore:SetAccepted(
            ]] ..self.PlayerID.. [[, ]] .._Good.. [[, ]] ..tostring(_Flag == true).. [[
        )
    ]])
    return self;
end

function ModuleCastleStore.Global.CastleStore:IsGoodLocked(_Good)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    return self.Goods[_Good][3] == true;
end

function ModuleCastleStore.Global.CastleStore:SetGoodLocked(_Good, _Flag)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    self.Goods[_Good][3] = _Flag == true;
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore:SetLocked(
            ]] ..self.PlayerID.. [[, ]] .._Good.. [[, ]] ..tostring(_Flag == true).. [[
        )
    ]])
    return self;
end

function ModuleCastleStore.Global.CastleStore:ActivateTemporaryMode()
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore.OnStorehouseTabClicked(QSB.CastleStore, ]] ..self.PlayerID.. [[)
    ]])
    return self;
end

function ModuleCastleStore.Global.CastleStore:ActivateStockMode()
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore.OnCityTabClicked(QSB.CastleStore, ]] ..self.PlayerID.. [[)
    ]])
    return self;
end

function ModuleCastleStore.Global.CastleStore:ActivateOutsourceMode()
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore.OnMultiTabClicked(QSB.CastleStore, ]] ..self.PlayerID.. [[)
    ]])
    return self;
end

function ModuleCastleStore.Global.CastleStore:Store(_Good, _Amount)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    if self:IsGoodAccepted(_Good) then
        if self:GetLimit() >= self:GetTotalAmount() + _Amount then
            local Level = Logic.GetUpgradeLevel(Logic.GetHeadquarters(self.PlayerID));
            if GetPlayerResources(_Good, self.PlayerID) > (self.Goods[_Good][4] * (Level+1)) then
                AddGood(_Good, _Amount * (-1), self.PlayerID);
                self.Goods[_Good][1] = self.Goods[_Good][1] + _Amount;
                Logic.ExecuteInLuaLocalState([[
                    QSB.CastleStore:SetAmount(
                        ]] ..self.PlayerID.. [[, ]] .._Good.. [[, ]] ..self.Goods[_Good][1].. [[
                    )
                ]]);
            end
        end
    end
    return self;
end

function ModuleCastleStore.Global.CastleStore:Outsource(_Good, _Amount)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    local Level = Logic.GetUpgradeLevel(Logic.GetHeadquarters(self.PlayerID));
    if Logic.GetPlayerUnreservedStorehouseSpace(self.PlayerID) >= _Amount then
        if self:GetAmount(_Good) >= _Amount then
            AddGood(_Good, _Amount, self.PlayerID);
            self.Goods[_Good][1] = self.Goods[_Good][1] - _Amount;
            Logic.ExecuteInLuaLocalState([[
                QSB.CastleStore:SetAmount(
                    ]] ..self.PlayerID.. [[, ]] .._Good.. [[, ]] ..self.Goods[_Good][1].. [[
                )
            ]]);
        end
    end
    return self;
end

function ModuleCastleStore.Global.CastleStore:Add(_Good, _Amount)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    if self.Goods[_Good] then
        for i= 1, _Amount, 1 do
            if self:GetLimit() > self:GetTotalAmount() then
                self.Goods[_Good][1] = self.Goods[_Good][1] + 1;
            end
        end
        Logic.ExecuteInLuaLocalState([[
            QSB.CastleStore:SetAmount(
                ]] ..self.PlayerID.. [[, ]] .._Good.. [[, ]] ..self.Goods[_Good][1].. [[
            )
        ]]);
    end
    return self;
end

function ModuleCastleStore.Global.CastleStore:Remove(_Good, _Amount)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    if self.Goods[_Good] then
        if self:GetAmount(_Good) > 0 then
            local ToRemove = (_Amount <= self:GetAmount(_Good) and _Amount) or self:GetAmount(_Good);
            self.Goods[_Good][1] = self.Goods[_Good][1] - ToRemove;
            Logic.ExecuteInLuaLocalState([[
                QSB.CastleStore:SetAmount(
                    ]] ..self.PlayerID.. [[, ]] .._Good.. [[, ]] ..self.Goods[_Good][1].. [[
                )
            ]]);
        end
    end
    return self;
end

function ModuleCastleStore.Global.CastleStore:EnableStore(_Flag)
    assert(self ~= ModuleCastleStore.Global.CastleStore, "Can not be used in static context!");
    self.UpdateCastleStore = _Flag == true;
end

function ModuleCastleStore.Global.CastleStore:UpdateStores()
    for k, v in pairs(QSB.CastleStoreObjects) do
        if v ~= nil and v.UpdateCastleStore and Logic.GetStoreHouse(k) ~= 0 then
            local Level = Logic.GetUpgradeLevel(Logic.GetHeadquarters(v.PlayerID));
            for kk, vv in pairs(v.Goods) do
                if vv ~= nil then
                    -- Ware wird angenommen
                    if vv[2] == true then
                        local AmountInStore  = GetPlayerResources(kk, v.PlayerID)
                        local AmountInCastle = v:GetAmount(kk)
                        -- Auslagern, wenn möglich
                        if AmountInStore < (v.Goods[kk][4] * (Level+1)) then
                            if vv[3] == false then
                                v:Outsource(kk, 1);
                            end
                        -- Einlagern, falls möglich
                        else
                            v:Store(kk, 1);
                        end
                    -- Ware ist gebannt
                    else
                        v:Outsource(kk, 1);
                    end
                end
            end
        end
    end
end

function ModuleCastleStore.Global:OverwriteGameFunctions()
    QuestTemplate.IsObjectiveCompleted_Orig_QSB_CastleStore = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        local data = objective.Data;

        if objective.Completed ~= nil then
            return objective.Completed;
        end

        if objectiveType == Objective.Produce then
            local GoodAmount = GetPlayerGoodsInSettlement(data[1], self.ReceivingPlayer, true);
            local CastleStore = QSB.CastleStore:GetInstance(self.ReceivingPlayer);
            if CastleStore and Logic.GetGoodCategoryForGoodType(data[1]) == GoodCategories.GC_Resource then
                GoodAmount = GoodAmount + CastleStore:GetAmount(data[1]);
            end
            if (not data[3] and GoodAmount >= data[2]) or (data[3] and GoodAmount < data[2]) then
                objective.Completed = true;
            end
        else
            return QuestTemplate.IsObjectiveCompleted_Orig_QSB_CastleStore(self, objective);
        end
    end

    QuestTemplate.SendGoods = function(self)
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Deliver then
                if self.Objectives[i].Data[3] == nil then
                    local goodType = self.Objectives[i].Data[1]
                    local goodQuantity = self.Objectives[i].Data[2]

                    local amount = QSB.CastleStore:GetGoodAmountWithCastleStore(goodType, self.ReceivingPlayer, true);
                    if amount >= goodQuantity then
                        local Sender = self.ReceivingPlayer
                        local Target = self.Objectives[i].Data[6] and self.Objectives[i].Data[6] or self.SendingPlayer

                        local expectedMerchant = {}
                        expectedMerchant.Good = goodType
                        expectedMerchant.Amount = goodQuantity
                        expectedMerchant.PlayerID = Target
                        expectedMerchant.ID = nil
                        self.Objectives[i].Data[5] = expectedMerchant
                        self.Objectives[i].Data[3] = 1
                        QuestMerchants[#QuestMerchants+1] = expectedMerchant

                        if goodType == Goods.G_Gold then
                            local BuildingID = Logic.GetHeadquarters(Sender)
                            if BuildingID == 0 then
                                BuildingID = Logic.GetStoreHouse(Sender)
                            end
                            self.Objectives[i].Data[3] = Logic.CreateEntityAtBuilding(Entities.U_GoldCart, BuildingID, 0, Target)
                            Logic.HireMerchant(self.Objectives[i].Data[3], Target, goodType, goodQuantity, self.ReceivingPlayer)
                            Logic.RemoveGoodFromStock(BuildingID,goodType,goodQuantity)
                            if MapCallback_DeliverCartSpawned then
                                MapCallback_DeliverCartSpawned( self, self.Objectives[i].Data[3], goodType )
                            end

                        elseif goodType == Goods.G_Water then
                            local BuildingID = Logic.GetMarketplace(Sender)

                            self.Objectives[i].Data[3] = Logic.CreateEntityAtBuilding(Entities.U_Marketer, BuildingID, 0, Target)
                            Logic.HireMerchant(self.Objectives[i].Data[3], Target, goodType, goodQuantity, self.ReceivingPlayer)
                            Logic.RemoveGoodFromStock(BuildingID,goodType,goodQuantity)
                            if MapCallback_DeliverCartSpawned then
                                MapCallback_DeliverCartSpawned( self, self.Objectives[i].Data[3], goodType )
                            end

                        else
                            if Logic.GetGoodCategoryForGoodType(goodType) == GoodCategories.GC_Resource then
                                local CartType = Entities.U_ResourceMerchant;
                                if goodType == Goods.G_MusicalInstrument
                                or goodType == Goods.G_Olibanum
                                or goodType == Goods.G_Gems
                                or goodType == Goods.G_Dye
                                or goodType == Goods.G_Salt then
                                    CartType = Entities.U_Marketer;
                                end
                                local StorehouseID = Logic.GetStoreHouse(Target)
                                local NumberOfGoodTypes = Logic.GetNumberOfGoodTypesOnOutStock(StorehouseID)
                                if NumberOfGoodTypes ~= nil then
                                    for j = 0, NumberOfGoodTypes-1 do
                                        local StoreHouseGoodType = Logic.GetGoodTypeOnOutStockByIndex(StorehouseID,j)
                                        local Amount = Logic.GetAmountOnOutStockByIndex(StorehouseID, j)
                                        if Amount >= goodQuantity then
                                            Logic.RemoveGoodFromStock(StorehouseID, StoreHouseGoodType, goodQuantity, false)
                                        end
                                    end
                                end

                                local SenderStorehouse = Logic.GetStoreHouse(Sender);
                                local AmountInStorehouse = GetPlayerResources(goodType, Sender);
                                if AmountInStorehouse < goodQuantity then
                                    -- Entferne aus Lager
                                    local AmountDifference = goodQuantity - AmountInStorehouse;
                                    AddGood(goodType, AmountInStorehouse * (-1), Sender);
                                    -- Entferne aus Burg
                                    local StoreInstance = QSB.CastleStore:GetInstance(self.ReceivingPlayer);
                                    if StoreInstance then
                                        StoreInstance:Remove(goodType, AmountDifference);
                                    end
                                else
                                    -- Entferne aus Lager
                                    AddGood(goodType, goodQuantity * (-1), Sender);
                                end
                                self.Objectives[i].Data[3] = Logic.CreateEntityAtBuilding(CartType, SenderStorehouse, 0, Target);
                                Logic.HireMerchant(self.Objectives[i].Data[3], Target, goodType, goodQuantity, self.ReceivingPlayer);
                            else
                                Logic.StartTradeGoodGathering(Sender, Target, goodType, goodQuantity, 0);
                            end
                        end
                    end
                end
            end
        end
    end
end

function ModuleCastleStore.Global:InteractiveObjectPayStep1(_PlayerID, _EntityID, _CostType1, _CostAmount1, _CostType2, _CostAmount2)
    -- Burglager abschalten
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    Store:EnableStore(false);
    -- Alle Waren zwischenspeichern
    self.BackupGoods[_PlayerID] = {};
    for k, v in pairs(Store.Goods) do
        local Amount = GetPlayerResources(k, _PlayerID);
        self.BackupGoods[_PlayerID][k] = Amount;
        AddGood(k, (-1) * Amount, _PlayerID);
    end
    -- Kosten ins Lagerhaus legen
    if _CostType1 then
        local Type = _CostType1;
        if self.BackupGoods[_PlayerID][Type] then
            AddGood(Type, _CostAmount1, _PlayerID);
            self.BackupGoods[_PlayerID][Type] = self.BackupGoods[_PlayerID][Type] - _CostAmount1;
            if self.BackupGoods[_PlayerID][Type] < 0 then
                QSB.CastleStore:GetInstance(_PlayerID):Remove(Type, (-1) * self.BackupGoods[_PlayerID][Type]);
                self.BackupGoods[_PlayerID][Type] = 0;
            end
        end
    end
    if _CostType2 then
        local Type = _CostType2;
        if self.BackupGoods[_PlayerID][Type] then
            AddGood(Type, _CostAmount2, _PlayerID);
            self.BackupGoods[_PlayerID][Type] = self.BackupGoods[_PlayerID][Type] - _CostAmount2;
            if self.BackupGoods[_PlayerID][Type] < 0 then
                QSB.CastleStore:GetInstance(_PlayerID):Remove(Type, (-1) * self.BackupGoods[_PlayerID][Type]);
                self.BackupGoods[_PlayerID][Type] = 0;
            end
        end
    end
    -- Objektinteraktion ausführen
    Logic.ExecuteInLuaLocalState(string.format(
        "ModuleCastleStore.Local:InteractiveObjectPayStep2(%d, %d)",
        _PlayerID,
        _EntityID
    ));
end

function ModuleCastleStore.Global:InteractiveObjectPayStep3(_PlayerID, _EntityID)
    if _EntityID == nil then
        return;
    end
    -- Burglager einschalten
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    Store:EnableStore(true);
    -- Lagerhaus zurücksetzen
    for k, v in pairs(Store.Goods) do
        local Amount = self.BackupGoods[_PlayerID][k];
        AddGood(k, Amount, _PlayerID);
    end
    self.BackupGoods[_PlayerID] = {};
end

-- Local -------------------------------------------------------------------- --

function ModuleCastleStore.Local:OnGameStart()
    for i= 1, 8 do
        self.Shortcuts[i] = {};
    end
    QSB.CastleStore = self.CastleStore;
    self:OverwriteGameFunctions();
    self:OverwriteGetStringTableText();
    self:OverwriteInteractiveObject();
end

function ModuleCastleStore.Local:OnEvent(_ID, _Event, _Text)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:OverwriteGetStringTableText();
        self.CastleStore:ActivateHotkeys();
    end
end



function ModuleCastleStore.Local:DescribeHotkeys(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    if not self.Shortcuts[_PlayerID].StoreGoods then
        self.Shortcuts[_PlayerID].StoreGoods = API.AddShortcut(
            {de = "Umschalt + B",               en = "Shift + B",           fr = "Shift + B"},
            {de = "Burglager: Waren einlagern", en = "Vault: Store goods",  fr = "Entrepôt du château : stocker des marchandises"}
        );
    end
    if not self.Shortcuts[_PlayerID].LockGoods then
        self.Shortcuts[_PlayerID].LockGoods = API.AddShortcut(
            {de = "Umschalt + N",               en = "Shift + N",           fr = "Shift + N"},
            {de = "Burglager: Waren sperren",   en = "Vault: Lock goods",   fr = "Entrepôt du château : bloquer les marchandises"}
        );
    end
    if not self.Shortcuts[_PlayerID].EmptyWarehouse then
        self.Shortcuts[_PlayerID].EmptyWarehouse = API.AddShortcut(
            {de = "Umschalt + M",               en = "Shift + M",           fr = "Shift + M"},
            {de = "Burglager: Lager räumen",    en = "Vault: Empty store",  fr = "Entrepôt du château : vider l'entrepôt"}
        );
    end
end

function ModuleCastleStore.Local:UndescriveHotkeys(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    if self.Shortcuts[_PlayerID].StoreGoods then
        API.RemoveShortcut(self.Shortcuts[_PlayerID].StoreGoods);
        self.Shortcuts[_PlayerID].StoreGoods = nil;
    end
    if self.Shortcuts[_PlayerID].LockGoods then
        API.RemoveShortcut(self.Shortcuts[_PlayerID].LockGoods);
        self.Shortcuts[_PlayerID].LockGoods = nil;
    end
    if self.Shortcuts[_PlayerID].EmptyWarehouse then
        API.RemoveShortcut(self.Shortcuts[_PlayerID].EmptyWarehouse);
        self.Shortcuts[_PlayerID].EmptyWarehouse = nil;
    end
end

function ModuleCastleStore.Local.CastleStore:CreateStore(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    local Store = {
        StoreMode = 1,
        CapacityBase = 75,
        Goods = {
            [Goods.G_Wood]      = {0, true, false, 35},
            [Goods.G_Stone]     = {0, true, false, 35},
            [Goods.G_Iron]      = {0, true, false, 35},
            [Goods.G_Carcass]   = {0, true, false, 15},
            [Goods.G_Grain]     = {0, true, false, 15},
            [Goods.G_RawFish]   = {0, true, false, 15},
            [Goods.G_Milk]      = {0, true, false, 15},
            [Goods.G_Herb]      = {0, true, false, 15},
            [Goods.G_Wool]      = {0, true, false, 15},
            [Goods.G_Honeycomb] = {0, true, false, 15},
        }
    }
    QSB.CastleStorePlayerData[_PlayerID] = Store;

    ModuleCastleStore.Local:DescribeHotkeys(_PlayerID);
    self:ActivateHotkeys();
end

function ModuleCastleStore.Local.CastleStore:DeleteStore(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    ModuleCastleStore.Local:UndescriveHotkeys(_PlayerID);
    QSB.CastleStorePlayerData[_PlayerID] = nil;
end

function ModuleCastleStore.Local.CastleStore:GetAmount(_PlayerID, _Good)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) or not QSB.CastleStorePlayerData[_PlayerID].Goods[_Good] then
        return 0;
    end
    return QSB.CastleStorePlayerData[_PlayerID].Goods[_Good][1];
end

function ModuleCastleStore.Local.CastleStore:GetGoodAmountWithCastleStore(_Good, _PlayerID, _InSettlement)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    local Amount = GetPlayerGoodsInSettlement(_Good, _PlayerID, _InSettlement);
    if self:HasCastleStore(_PlayerID) then
        if _Good ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(_Good) == GoodCategories.GC_Resource then
            Amount = Amount + self:GetAmount(_PlayerID, _Good);
        end
    end
    return Amount;
end

function ModuleCastleStore.Local.CastleStore:GetTotalAmount(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) then
        return 0;
    end
    local TotalAmount = 0;
    for k, v in pairs(QSB.CastleStorePlayerData[_PlayerID].Goods) do
        TotalAmount = TotalAmount + v[1];
    end
    return TotalAmount;
end

function ModuleCastleStore.Local.CastleStore:SetAmount(_PlayerID, _Good, _Amount)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) or not QSB.CastleStorePlayerData[_PlayerID].Goods[_Good] then
        return;
    end
    QSB.CastleStorePlayerData[_PlayerID].Goods[_Good][1] = _Amount;
    return self;
end

function ModuleCastleStore.Local.CastleStore:IsAccepted(_PlayerID, _Good)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) or not QSB.CastleStorePlayerData[_PlayerID].Goods[_Good] then
        return false;
    end
    return QSB.CastleStorePlayerData[_PlayerID].Goods[_Good][2] == true;
end

function ModuleCastleStore.Local.CastleStore:SetAccepted(_PlayerID, _Good, _Flag)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if self:HasCastleStore(_PlayerID) and QSB.CastleStorePlayerData[_PlayerID].Goods[_Good] then
        QSB.CastleStorePlayerData[_PlayerID].Goods[_Good][2] = _Flag == true;
    end
    return self;
end

function ModuleCastleStore.Local.CastleStore:IsLocked(_PlayerID, _Good)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) or not QSB.CastleStorePlayerData[_PlayerID].Goods[_Good] then
        return false;
    end
    return QSB.CastleStorePlayerData[_PlayerID].Goods[_Good][3] == true;
end

function ModuleCastleStore.Local.CastleStore:SetLocked(_PlayerID, _Good, _Flag)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if self:HasCastleStore(_PlayerID) and QSB.CastleStorePlayerData[_PlayerID].Goods[_Good] then
        QSB.CastleStorePlayerData[_PlayerID].Goods[_Good][3] = _Flag == true;
    end
    return self;
end

function ModuleCastleStore.Local.CastleStore:HasCastleStore(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    return QSB.CastleStorePlayerData[_PlayerID] ~= nil;
end

function ModuleCastleStore.Local.CastleStore:GetStore(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    return QSB.CastleStorePlayerData[_PlayerID];
end

function ModuleCastleStore.Local.CastleStore:GetLimit(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    local Level = 0;
    local Headquarters = Logic.GetHeadquarters(_PlayerID);
    if Headquarters ~= 0 then
        Level = Logic.GetUpgradeLevel(Headquarters);
    end

    local Capacity = QSB.CastleStorePlayerData[_PlayerID].CapacityBase;
    for i= 1, (Level+1), 1 do
        Capacity = Capacity * 2;
    end
    return Capacity;
end

function ModuleCastleStore.Local.CastleStore:OnStorehouseTabClicked(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    QSB.CastleStorePlayerData[_PlayerID].StoreMode = 1;
    self:UpdateBehaviorTabs(_PlayerID);
    API.BroadcastScriptCommand(QSB.ScriptCommands.CastleStoreAcceptAllGoods, _PlayerID);
end

function ModuleCastleStore.Local.CastleStore:OnCityTabClicked(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    QSB.CastleStorePlayerData[_PlayerID].StoreMode = 2;
    self:UpdateBehaviorTabs(_PlayerID);
    API.BroadcastScriptCommand(QSB.ScriptCommands.CastleStoreLockAllGoods, _PlayerID);
end

function ModuleCastleStore.Local.CastleStore:OnMultiTabClicked(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    QSB.CastleStorePlayerData[_PlayerID].StoreMode = 3;
    self:UpdateBehaviorTabs(_PlayerID);
    API.BroadcastScriptCommand(QSB.ScriptCommands.CastleStoreRefuseAllGoods, _PlayerID);
end

function ModuleCastleStore.Local.CastleStore:GoodClicked(_PlayerID, _GoodType)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if self:HasCastleStore(_PlayerID) then
        API.BroadcastScriptCommand(QSB.ScriptCommands.CastleStoreToggleGoodState, _PlayerID, _GoodType);
    end
end

function ModuleCastleStore.Local.CastleStore:DestroyGoodsClicked(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if self:HasCastleStore(_PlayerID) then
        QSB.CastleStore.ToggleStore();
    end
end

function ModuleCastleStore.Local.CastleStore:SelectionChanged(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if self:HasCastleStore(_PlayerID) then
        local SelectedID = GUI.GetSelectedEntity();
        if Logic.GetHeadquarters(_PlayerID) == SelectedID then
            self:ShowCastleMenu();
        else
            self:RestoreStorehouseMenu();
        end
    end
end

function ModuleCastleStore.Local.CastleStore:UpdateBehaviorTabs(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not QSB.CastleStore:HasCastleStore(_PlayerID) then
        return;
    end
    XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons", 0);
    if QSB.CastleStorePlayerData[_PlayerID].StoreMode == 1 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/StorehouseTabButtonUp", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/CityTabButtonDown", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/Tab03Down", 1);
    elseif QSB.CastleStorePlayerData[_PlayerID].StoreMode == 2 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/StorehouseTabButtonDown", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/CityTabButtonUp", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/Tab03Down", 1);
    else
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/StorehouseTabButtonDown", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/CityTabButtonDown", 1);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/Tab03Up", 1);
    end
end

function ModuleCastleStore.Local.CastleStore:UpdateGoodsDisplay(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) then
        return;
    end

    local MotherContainer  = "/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InStorehouse/Goods";
    local WarningColor = "";
    if self:GetLimit(_PlayerID) == self:GetTotalAmount(_PlayerID) then
        WarningColor = "{@color:255,32,32,255}";
    end
    for k, v in pairs(QSB.CastleStorePlayerData[_PlayerID].Goods) do
        local GoodTypeName = Logic.GetGoodTypeName(k);
        local AmountWidget = MotherContainer.. "/" ..GoodTypeName.. "/Amount";
        local ButtonWidget = MotherContainer.. "/" ..GoodTypeName.. "/Button";
        local BGWidget = MotherContainer.. "/" ..GoodTypeName.. "/BG";
        XGUIEng.SetText(AmountWidget, "{center}" .. WarningColor .. v[1]);
        XGUIEng.DisableButton(ButtonWidget, 0)

        -- Ware ist gesperrt
        if self:IsAccepted(_PlayerID, k) and self:IsLocked(_PlayerID, k) then
            XGUIEng.SetMaterialColor(ButtonWidget, 0, 230, 180, 120, 255);
            XGUIEng.SetMaterialColor(ButtonWidget, 1, 230, 180, 120, 255);
            XGUIEng.SetMaterialColor(ButtonWidget, 7, 230, 180, 120, 255);
        -- Ware wird nicht angenommen
        elseif not self:IsAccepted(_PlayerID, k) and not self:IsLocked(_PlayerID, k) then
            XGUIEng.SetMaterialColor(ButtonWidget, 0, 190, 90, 90, 255);
            XGUIEng.SetMaterialColor(ButtonWidget, 1, 190, 90, 90, 255);
            XGUIEng.SetMaterialColor(ButtonWidget, 7, 190, 90, 90, 255);
        -- Ware wird eingelagert
        else
            XGUIEng.SetMaterialColor(ButtonWidget, 0, 255, 255, 255, 255);
            XGUIEng.SetMaterialColor(ButtonWidget, 1, 255, 255, 255, 255);
            XGUIEng.SetMaterialColor(ButtonWidget, 7, 255, 255, 255, 255);
        end
    end
end

function ModuleCastleStore.Local.CastleStore:UpdateStorageLimit(_PlayerID)
    assert(self == ModuleCastleStore.Local.CastleStore, "Can not be used from instance!");
    if not self:HasCastleStore(_PlayerID) then
        return;
    end
    local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
    local PlayerID = GUI.GetPlayerID();
    local StorageUsed = QSB.CastleStore:GetTotalAmount(PlayerID);
    local StorageLimit = QSB.CastleStore:GetLimit(PlayerID);
    local StorageLimitText = XGUIEng.GetStringTableText("UI_Texts/StorageLimit_colon");
    local Text = "{center}" ..StorageLimitText.. " " ..StorageUsed.. "/" ..StorageLimit;
    XGUIEng.SetText(CurrentWidgetID, Text);
end

function ModuleCastleStore.Local.CastleStore:ToggleStore()
    assert(self == nil, "This function is procedural!");
    if QSB.CastleStore:HasCastleStore(GUI.GetPlayerID()) then
        if Logic.GetHeadquarters(GUI.GetPlayerID()) == GUI.GetSelectedEntity() then
            if XGUIEng.IsWidgetShown("/InGame/Root/Normal/AlignBottomRight/Selection/Castle") == 1 then
                QSB.CastleStore.ShowCastleStoreMenu(QSB.CastleStore);
            else
                QSB.CastleStore.ShowCastleMenu(QSB.CastleStore);
            end
        end
    end
end

function ModuleCastleStore.Local.CastleStore:RestoreStorehouseMenu()
    XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons", 1);
    XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InCity/Goods", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InCity", 0);
    SetIcon("/InGame/Root/Normal/AlignBottomRight/DialogButtons/PlayerButtons/DestroyGoods", {16, 8});

    local MotherPath = "/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/";
    SetIcon(MotherPath.. "StorehouseTabButtonUp/up/B_StoreHouse", {3, 13});
    SetIcon(MotherPath.. "StorehouseTabButtonDown/down/B_StoreHouse", {3, 13});
    SetIcon(MotherPath.. "CityTabButtonUp/up/CityBuildingsNumber", {8, 1});
    SetIcon(MotherPath.. "CityTabButtonDown/down/CityBuildingsNumber", {8, 1});
    SetIcon(MotherPath.. "Tab03Up/up/B_Castle_ME", {3, 14});
    SetIcon(MotherPath.. "Tab03Down/down/B_Castle_ME", {3, 14});

    for k, v in ipairs {"G_Carcass", "G_Grain", "G_Milk", "G_RawFish", "G_Iron","G_Wood", "G_Stone", "G_Honeycomb", "G_Herb", "G_Wool"} do
        local MotherPath = "/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InStorehouse/Goods/";
        XGUIEng.SetMaterialColor(MotherPath.. v.. "/Button", 0, 255, 255, 255, 255);
        XGUIEng.SetMaterialColor(MotherPath.. v.. "/Button", 1, 255, 255, 255, 255);
        XGUIEng.SetMaterialColor(MotherPath.. v.. "/Button", 7, 255, 255, 255, 255);
    end
end

function ModuleCastleStore.Local.CastleStore:ShowCastleMenu()
    local MotherPath = "/InGame/Root/Normal/AlignBottomRight/";
    XGUIEng.ShowWidget(MotherPath.. "Selection/BGBig", 0)
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse", 0)
    XGUIEng.ShowWidget(MotherPath.. "Selection/BGSmall", 1)
    XGUIEng.ShowWidget(MotherPath.. "Selection/Castle", 1)

    if g_HideSoldierPayment ~= nil then
        XGUIEng.ShowWidget(MotherPath.. "Selection/Castle/Treasury/Payment", 0)
        XGUIEng.ShowWidget(MotherPath.. "Selection/Castle/LimitSoldiers", 0)
    end
    GUI_BuildingInfo.PaymentLevelSliderUpdate()
    GUI_BuildingInfo.TaxationLevelSliderUpdate()
    GUI_Trade.StorehouseSelected()
    local AnchorInfoForSmallX, AnchorInfoForSmallY = XGUIEng.GetWidgetLocalPosition(MotherPath.. "Selection/AnchorInfoForSmall")
    XGUIEng.SetWidgetLocalPosition(MotherPath.. "Selection/Info", AnchorInfoForSmallX, AnchorInfoForSmallY)

    XGUIEng.ShowWidget(MotherPath.. "DialogButtons/PlayerButtons", 1)
    XGUIEng.ShowWidget(MotherPath.. "DialogButtons/PlayerButtons/DestroyGoods", 1)
    XGUIEng.DisableButton(MotherPath.. "DialogButtons/PlayerButtons/DestroyGoods", 0)
    SetIcon(MotherPath.. "DialogButtons/PlayerButtons/DestroyGoods", {10, 9})
end

function ModuleCastleStore.Local.CastleStore:ShowCastleStoreMenu()
    local MotherPath = "/InGame/Root/Normal/AlignBottomRight/";
    XGUIEng.ShowWidget(MotherPath.. "Selection/Selection/BGSmall", 0);
    XGUIEng.ShowWidget(MotherPath.. "Selection/Castle", 0);
    XGUIEng.ShowWidget(MotherPath.. "Selection/BGSmall", 0);
    XGUIEng.ShowWidget(MotherPath.. "Selection/BGBig", 1);
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse", 1);
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/AmountContainer", 0);
    XGUIEng.ShowAllSubWidgets(MotherPath.. "Selection/Storehouse/TabButtons", 1);
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/TabButtons", 1);

    GUI_Trade.StorehouseSelected()
    local AnchorInfoForBigX, AnchorInfoForBigY = XGUIEng.GetWidgetLocalPosition(MotherPath.. "Selection/AnchorInfoForBig")
    XGUIEng.SetWidgetLocalPosition(MotherPath.. "Selection/Info", AnchorInfoForBigX, AnchorInfoForBigY)

    XGUIEng.ShowWidget(MotherPath.. "DialogButtons/PlayerButtons", 1)
    XGUIEng.ShowWidget(MotherPath.. "DialogButtons/PlayerButtons/DestroyGoods", 1)
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/InStorehouse", 1)
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/InMulti", 0)
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/InCity", 1)
    XGUIEng.ShowAllSubWidgets(MotherPath.. "Selection/Storehouse/InCity/Goods", 0);
    XGUIEng.ShowWidget(MotherPath.. "Selection/Storehouse/InCity/Goods/G_Beer", 1)

    XGUIEng.DisableButton(MotherPath.. "DialogButtons/PlayerButtons/DestroyGoods", 0)

    local MotherPathDialog = MotherPath.. "DialogButtons/PlayerButtons/";
    local MotherPathTabs = MotherPath.. "Selection/Storehouse/TabButtons/";
    SetIcon(MotherPathDialog.. "DestroyGoods", {3, 14});
    SetIcon(MotherPathTabs.. "StorehouseTabButtonUp/up/B_StoreHouse", {10, 9});
    SetIcon(MotherPathTabs.. "StorehouseTabButtonDown/down/B_StoreHouse", {10, 9});
    SetIcon(MotherPathTabs.. "CityTabButtonUp/up/CityBuildingsNumber", {15, 6});
    SetIcon(MotherPathTabs.. "CityTabButtonDown/down/CityBuildingsNumber", {15, 6});
    SetIcon(MotherPathTabs.. "Tab03Up/up/B_Castle_ME", {7, 1});
    SetIcon(MotherPathTabs.. "Tab03Down/down/B_Castle_ME", {7, 1});

    self:UpdateBehaviorTabs(GUI.GetPlayerID());
end

function ModuleCastleStore.Local:OverwriteInteractiveObject()
    GUI_Interaction.InteractiveObjectClicked_Orig_CastleStore = GUI_Interaction.InteractiveObjectClicked;
    GUI_Interaction.InteractiveObjectClicked = function()
        local i = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local EntityID = g_Interaction.ActiveObjectsOnScreen[i];
        local PlayerID = GUI.GetPlayerID()
        if not EntityID then
            return;
        end
        if not QSB.CastleStore:HasCastleStore(PlayerID) then
            GUI_Interaction.InteractiveObjectClicked_Orig_CastleStore();
            return;
        end
        local Costs = {Logic.InteractiveObjectGetEffectiveCosts(EntityID, PlayerID)}
        local CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs, false);
        if self:OnObjectClicked_CanPlayerPayCosts(Costs) then
            CanBuyBoolean = true;
        end
        if not CanBuyBoolean then
            Message(CanNotBuyString);
            return;
        end

        if not Mission_Callback_OverrideObjectInteraction or not Mission_Callback_OverrideObjectInteraction(EntityID, PlayerID, Costs) then
            if Costs and Costs[1] then
                CanBuyBoolean = CanBuyBoolean and GetPlayerResources(Costs[1], PlayerID) >= Costs[2];
                if Costs[3] then
                    CanBuyBoolean = CanBuyBoolean and GetPlayerResources(Costs[3], PlayerID) >= Costs[4];
                end
            end
            -- Trigger normal interaction
            if CanBuyBoolean then
                GUI_Interaction.InteractiveObjectClicked_Orig_CastleStore();
                return;
            end
            -- Invoke the castle store
            API.BroadcastScriptCommand(
                QSB.ScriptCommands.CastleStoreObjectPayStep1,
                PlayerID,
                EntityID,
                unpack(Costs)
            );
        end
    end
end

function ModuleCastleStore.Local:OnObjectClicked_CanPlayerPayCosts(_Costs)
    local PlayerID = GUI.GetPlayerID();
    local CanBuyBoolean = true;
    if not _Costs or type(_Costs[1]) ~= "number" then
        return CanBuyBoolean;
    end
    if _Costs[1] then
        local Amount = GetPlayerResources(_Costs[1], GUI.GetPlayerID());
        if not QSB.CastleStore:IsLocked(PlayerID, _Costs[1]) then
            Amount = QSB.CastleStore:GetGoodAmountWithCastleStore(_Costs[1], GUI.GetPlayerID(), true);
        end
        CanBuyBoolean = CanBuyBoolean and (Amount >= _Costs[2]);
    end
    if _Costs[3] then
        local Amount = GetPlayerResources(_Costs[3], GUI.GetPlayerID());
        if not QSB.CastleStore:IsLocked(PlayerID, _Costs[3]) then
            Amount = QSB.CastleStore:GetGoodAmountWithCastleStore(_Costs[3], GUI.GetPlayerID(), true);
        end
        CanBuyBoolean = CanBuyBoolean and (Amount >= _Costs[4]);
    end
    if not CanBuyBoolean then
        local CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources");
        Message(CanNotBuyString);
    end
    return CanBuyBoolean;
end

function ModuleCastleStore.Local.CastleStore:HotkeyStoreGoods()
    local PlayerID = GUI.GetPlayerID();
    if ModuleCastleStore.Local.CastleStore:HasCastleStore(PlayerID) == false then 
        return;
    end
    ModuleCastleStore.Local.CastleStore:OnStorehouseTabClicked(PlayerID);
end

function ModuleCastleStore.Local.CastleStore:HotkeyLockGoods()
    local PlayerID = GUI.GetPlayerID();
    if ModuleCastleStore.Local.CastleStore:HasCastleStore(PlayerID) == false then 
        return;
    end
    ModuleCastleStore.Local.CastleStore:OnCityTabClicked(PlayerID);
end

function ModuleCastleStore.Local.CastleStore:HotkeyEmptyStore()
    local PlayerID = GUI.GetPlayerID();
    if ModuleCastleStore.Local.CastleStore:HasCastleStore(PlayerID) == false then 
        return;
    end
    ModuleCastleStore.Local.CastleStore:OnMultiTabClicked(PlayerID);
end

function ModuleCastleStore.Local.CastleStore:ActivateHotkeys()
    -- Waren einlagern
    Input.KeyBindDown(
        Keys.ModifierShift + Keys.B,
        "ModuleCastleStore.Local.CastleStore:HotkeyStoreGoods()",
        2,
        false
    );

    -- Waren verwahren
    Input.KeyBindDown(
        Keys.ModifierShift + Keys.N,
        "ModuleCastleStore.Local.CastleStore:HotkeyLockGoods()",
        2,
        false
    );

    -- Lager räumen
    Input.KeyBindDown(
        Keys.ModifierShift + Keys.M,
        "ModuleCastleStore.Local.CastleStore:HotkeyEmptyStore()",
        2,
        false
    );
end

function ModuleCastleStore.Local:OverwriteGetStringTableText()
    GetStringTableText_Orig_QSB_CatsleStore = XGUIEng.GetStringTableText;
    XGUIEng.GetStringTableText = function(_key)
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID = GUI.GetPlayerID();
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();

        if _key == "UI_ObjectNames/DestroyGoods" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                if XGUIEng.IsWidgetShown("/InGame/Root/Normal/AlignBottomRight/Selection/Castle") == 1 then
                    return API.Localize(ModuleCastleStore.Shared.Text.ShowCastleStore.Text);
                else
                    return API.Localize(ModuleCastleStore.Shared.Text.ShowCastle.Text);
                end
            end
        end
        if _key == "UI_ObjectDescription/DestroyGoods" then
            return "";
        end

        if _key == "UI_ObjectNames/CityBuildingsNumber" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return API.Localize(ModuleCastleStore.Shared.Text.CityTab.Title);
            end
        end
        if _key == "UI_ObjectDescription/CityBuildingsNumber" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return API.Localize(ModuleCastleStore.Shared.Text.CityTab.Text);
            end
        end

        if _key == "UI_ObjectNames/B_StoreHouse" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return API.Localize(ModuleCastleStore.Shared.Text.StorehouseTab.Title);
            end
        end
        if _key == "UI_ObjectDescription/B_StoreHouse" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return API.Localize(ModuleCastleStore.Shared.Text.StorehouseTab.Text);
            end
        end

        if _key == "UI_ObjectNames/B_Castle_ME" then
            local WidgetMotherName = "/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/";
            local WidgetDownButton = WidgetMotherName.. "Tab03Down/down/B_Castle_ME";
            local WidgetUpButton = WidgetMotherName.. "Tab03Up/up/B_Castle_ME";
            if XGUIEng.GetWidgetPathByID(CurrentWidgetID) == WidgetDownButton or XGUIEng.GetWidgetPathByID(CurrentWidgetID) == WidgetUpButton then
                if Logic.GetHeadquarters(PlayerID) == SelectedID then
                    return API.Localize(ModuleCastleStore.Shared.Text.MultiTab.Title);
                end
            end
        end
        if _key == "UI_ObjectDescription/B_Castle_ME" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return API.Localize(ModuleCastleStore.Shared.Text.MultiTab.Text);
            end
        end

        if _key == "UI_ButtonDisabled/NotEnoughGoods" then
            if Logic.GetHeadquarters(PlayerID) == SelectedID then
                return API.Localize(ModuleCastleStore.Shared.Text.GoodButtonDisabled.Text);
            end
        end

        return GetStringTableText_Orig_QSB_CatsleStore(_key);
    end
end

function ModuleCastleStore.Local:OverwriteGameFunctions()
    GameCallback_GUI_SelectionChanged_Orig_QSB_CastleStore = GameCallback_GUI_SelectionChanged;
    GameCallback_GUI_SelectionChanged = function(_Source)
        GameCallback_GUI_SelectionChanged_Orig_QSB_CastleStore(_Source);
        QSB.CastleStore:SelectionChanged(GUI.GetPlayerID());
    end

    GUI_Trade.GoodClicked_Orig_QSB_CastleStore = GUI_Trade.GoodClicked;
    GUI_Trade.GoodClicked = function()
        local GoodType = Goods[XGUIEng.GetWidgetNameByID(XGUIEng.GetWidgetsMotherID(XGUIEng.GetCurrentWidgetID()))];
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.GoodClicked_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:GoodClicked(PlayerID, GoodType);
    end

    GUI_Trade.DestroyGoodsClicked_Orig_QSB_CastleStore = GUI_Trade.DestroyGoodsClicked;
    GUI_Trade.DestroyGoodsClicked = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.DestroyGoodsClicked_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:DestroyGoodsClicked(PlayerID);
    end

    GUI_Trade.SellUpdate_Orig_QSB_CastleStore = GUI_Trade.SellUpdate;
    GUI_Trade.SellUpdate = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.SellUpdate_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:UpdateGoodsDisplay(PlayerID);
    end

    GUI_Trade.CityTabButtonClicked_Orig_QSB_CastleStore = GUI_Trade.CityTabButtonClicked;
    GUI_Trade.CityTabButtonClicked = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.CityTabButtonClicked_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:OnCityTabClicked(PlayerID);
    end

    GUI_Trade.StorehouseTabButtonClicked_Orig_QSB_CastleStore = GUI_Trade.StorehouseTabButtonClicked;
    GUI_Trade.StorehouseTabButtonClicked = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.StorehouseTabButtonClicked_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:OnStorehouseTabClicked(PlayerID);
    end

    GUI_Trade.MultiTabButtonClicked_Orig_QSB_CastleStore = GUI_Trade.MultiTabButtonClicked;
    GUI_Trade.MultiTabButtonClicked = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_Trade.MultiTabButtonClicked_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:OnMultiTabClicked(PlayerID);
    end

    GUI_BuildingInfo.StorageLimitUpdate_Orig_QSB_CastleStore = GUI_BuildingInfo.StorageLimitUpdate;
    GUI_BuildingInfo.StorageLimitUpdate = function()
        local SelectedID = GUI.GetSelectedEntity();
        local PlayerID   = GUI.GetPlayerID();

        if Logic.IsEntityInCategory(SelectedID, EntityCategories.Storehouse) == 1 then
            GUI_BuildingInfo.StorageLimitUpdate_Orig_QSB_CastleStore();
            return;
        end
        QSB.CastleStore:UpdateStorageLimit(PlayerID);
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    GUI_Interaction.SendGoodsClicked = function()
        local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(g_Interaction.CurrentMessageQuestIndex);
        if not Quest then
            return;
        end
        local QuestIndex = GUI_Interaction.GetPotentialSubQuestIndex(g_Interaction.CurrentMessageQuestIndex);
        local GoodType = Quest.Objectives[1].Data[1];
        local GoodAmount = Quest.Objectives[1].Data[2];
        local Costs = {GoodType, GoodAmount};
        local CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs, true);

        local PlayerID = GUI.GetPlayerID();
        if Logic.GetGoodCategoryForGoodType(GoodType) == GoodCategories.GC_Resource then
            CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources");
            CanBuyBoolean = false;
            if QSB.CastleStore:IsLocked(PlayerID, GoodType) then
                CanBuyBoolean = GetPlayerResources(GoodType, PlayerID) >= GoodAmount;
            else
                CanBuyBoolean = (GetPlayerResources(GoodType, PlayerID) + QSB.CastleStore:GetAmount(PlayerID, GoodType)) >= GoodAmount;
            end
        end

        local TargetPlayerID = Quest.Objectives[1].Data[6] and Quest.Objectives[1].Data[6] or Quest.SendingPlayer;
        local PlayerSectorType = PlayerSectorTypes.Thief;
        local IsReachable = CanEntityReachTarget(TargetPlayerID, Logic.GetStoreHouse(GUI.GetPlayerID()), Logic.GetStoreHouse(TargetPlayerID), nil, PlayerSectorType);
        if IsReachable == false then
            local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericUnreachable");
            Message(MessageText);
            return
        end

        if CanBuyBoolean == true then
            Sound.FXPlay2DSound( "ui\\menu_click");
            GUI.QuestTemplate_SendGoods(QuestIndex);
            GUI_FeedbackSpeech.Add("SpeechOnly_CartsSent", g_FeedbackSpeech.Categories.CartsUnderway, nil, nil);
        else
            Message(CanNotBuyString);
        end
    end

    GUI_Tooltip.SetCosts = function(_TooltipCostsContainer, _Costs, _GoodsInSettlementBoolean)
        local TooltipCostsContainerPath = XGUIEng.GetWidgetPathByID(_TooltipCostsContainer);
        local Good1ContainerPath = TooltipCostsContainerPath .. "/1Good";
        local Goods2ContainerPath = TooltipCostsContainerPath .. "/2Goods";
        local NumberOfValidAmounts = 0;
        local Good1Path;
        local Good2Path;

        for i = 2, #_Costs, 2 do
            if _Costs[i] ~= 0 then
                NumberOfValidAmounts = NumberOfValidAmounts + 1;
            end
        end
        if NumberOfValidAmounts == 0 then
            XGUIEng.ShowWidget(Good1ContainerPath, 0);
            XGUIEng.ShowWidget(Goods2ContainerPath, 0);
            return
        elseif NumberOfValidAmounts == 1 then
            XGUIEng.ShowWidget(Good1ContainerPath, 1);
            XGUIEng.ShowWidget(Goods2ContainerPath, 0);
            Good1Path = Good1ContainerPath .. "/Good1Of1";
        elseif NumberOfValidAmounts == 2 then
            XGUIEng.ShowWidget(Good1ContainerPath, 0);
            XGUIEng.ShowWidget(Goods2ContainerPath, 1);
            Good1Path = Goods2ContainerPath .. "/Good1Of2";
            Good2Path = Goods2ContainerPath .. "/Good2Of2";
        elseif NumberOfValidAmounts > 2 then
            GUI.AddNote("Debug: Invalid Costs table. Not more than 2 GoodTypes allowed.");
        end

        local ContainerIndex = 1;
        for i = 1, #_Costs, 2 do
            if _Costs[i + 1] ~= 0 then
                local CostsGoodType = _Costs[i];
                local CostsGoodAmount = _Costs[i + 1];
                local IconWidget;
                local AmountWidget;
                if ContainerIndex == 1 then
                    IconWidget = Good1Path .. "/Icon";
                    AmountWidget = Good1Path .. "/Amount";
                else
                    IconWidget = Good2Path .. "/Icon";
                    AmountWidget = Good2Path .. "/Amount";
                end
                SetIcon(IconWidget, g_TexturePositions.Goods[CostsGoodType], 44);
                local PlayerID = GUI.GetPlayerID();
                local PlayersGoodAmount = GetPlayerGoodsInSettlement(CostsGoodType, PlayerID, _GoodsInSettlementBoolean);
                if Logic.GetGoodCategoryForGoodType(CostsGoodType) == GoodCategories.GC_Resource and CostsGoodType ~= Goods.G_Gold then
                    if not QSB.CastleStore:IsLocked(PlayerID, CostsGoodType) then
                        PlayersGoodAmount = PlayersGoodAmount + QSB.CastleStore:GetAmount(PlayerID, CostsGoodType);
                    end
                end
                local Color = "";
                if PlayersGoodAmount < CostsGoodAmount then
                    Color = "{@script:ColorRed}";
                end
                if CostsGoodAmount > 0 then
                    XGUIEng.SetText(AmountWidget, "{center}" .. Color .. CostsGoodAmount);
                else
                    XGUIEng.SetText(AmountWidget, "");
                end
                ContainerIndex = ContainerIndex + 1;
            end
        end
    end
end

function ModuleCastleStore.Local:InteractiveObjectPayStep2(_PlayerID, _EntityID)
    if _EntityID == nil then
        return;
    end
    GUI.ExecuteObjectInteraction(_EntityID, _PlayerID);
    API.BroadcastScriptCommand(QSB.ScriptCommands.CastleStoreObjectPayStep3, _PlayerID, _EntityID);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleCastleStore);

