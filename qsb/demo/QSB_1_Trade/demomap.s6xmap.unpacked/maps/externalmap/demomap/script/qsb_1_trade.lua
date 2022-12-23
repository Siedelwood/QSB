--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleTrade = {
    Properties = {
        Name = "ModuleTrade",
        Version = "4.0.0 (ALPHA 1.0.0)",
    },

    Global = {
        Analysis = {
            PlayerOffersAmount = {
                [1] = {}, [2] = {}, [3] = {}, [4] = {},
                [5] = {}, [6] = {}, [7] = {}, [8] = {},
            };
        },
        Lambda = {},
        Event = {},
    },
    Local = {
        Lambda = {
            PurchaseTraderAbility = {},
            PurchaseBasePrice     = {},
            PurchaseInflation     = {},
            PurchaseAllowed       = {},
            SaleTraderAbility     = {},
            SaleBasePrice         = {},
            SaleDeflation         = {},
            SaleAllowed           = {},
        },
        ShowKnightTraderAbility = true;
    },

    Shared = {},
};

QSB.TraderTypes = {
    GoodTrader        = 0,
    MercenaryTrader   = 1,
    EntertainerTrader = 2,
    Unknown           = 3,
};

-- Global ------------------------------------------------------------------- --

function ModuleTrade.Global:OnGameStart()
    QSB.ScriptEvents.GoodsSold = API.RegisterScriptEvent("Event_GoodsSold");
    QSB.ScriptEvents.GoodsPurchased = API.RegisterScriptEvent("Event_GoodsPurchased");
    self:OverwriteBasePricesAndRefreshRates();
end

function ModuleTrade.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.GoodsPurchased then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.GoodsPurchased, %d, %d, %d, %d, %d, %d, %d)]],
            arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7]
        ))
        self:PerformFakeTrade(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7]);
    elseif _ID == QSB.ScriptEvents.GoodsSold then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.GoodsSold, %d, %d, %d, %d, %d, %d)]],
            arg[1], arg[2], arg[3], arg[4], arg[5], arg[6]
        ))
    end
end

function ModuleTrade.Global:OverwriteBasePricesAndRefreshRates()
    MerchantSystem.BasePrices[Entities.U_CatapultCart] = MerchantSystem.BasePrices[Entities.U_CatapultCart] or 1000;
    MerchantSystem.BasePrices[Entities.U_BatteringRamCart] = MerchantSystem.BasePrices[Entities.U_BatteringRamCart] or 450;
    MerchantSystem.BasePrices[Entities.U_SiegeTowerCart] = MerchantSystem.BasePrices[Entities.U_SiegeTowerCart] or 600;
    MerchantSystem.BasePrices[Entities.U_AmmunitionCart] = MerchantSystem.BasePrices[Entities.U_AmmunitionCart] or 150;
    MerchantSystem.BasePrices[Entities.U_MilitarySword_RedPrince] = MerchantSystem.BasePrices[Entities.U_MilitarySword_RedPrince] or 200;
    MerchantSystem.BasePrices[Entities.U_MilitarySword] = MerchantSystem.BasePrices[Entities.U_MilitarySword] or 200;
    MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince] or 350;
    MerchantSystem.BasePrices[Entities.U_MilitaryBow] = MerchantSystem.BasePrices[Entities.U_MilitaryBow] or 350;

    MerchantSystem.RefreshRates[Entities.U_CatapultCart] = MerchantSystem.RefreshRates[Entities.U_CatapultCart] or 270;
    MerchantSystem.RefreshRates[Entities.U_BatteringRamCart] = MerchantSystem.RefreshRates[Entities.U_BatteringRamCart] or 190;
    MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart] = MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart] or 220;
    MerchantSystem.RefreshRates[Entities.U_AmmunitionCart] = MerchantSystem.RefreshRates[Entities.U_AmmunitionCart] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.RefreshRates[Entities.U_MilitarySword_RedPrince] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitarySword] = MerchantSystem.RefreshRates[Entities.U_MilitarySword] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow] or 150;

    if g_GameExtraNo >= 1 then
        MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana] = MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana] or 350;
        MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana] = MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana] or 200;

        MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] or 150;
        MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] = MerchantSystem.RefreshRates[Entities.U_MilitarySword_Khana] or 150;
    end
end

function ModuleTrade.Global:PerformFakeTrade(_OfferID, _TraderType, _Good, _Amount, _Price, _P1, _P2)
    local StoreHouse1 = Logic.GetStoreHouse(_P1);
    local StoreHouse2 = Logic.GetStoreHouse(_P2);

    -- Perform transaction
    local Orientation = Logic.GetEntityOrientation(StoreHouse2) - 90;
    if _TraderType == 0 then
        if Logic.GetGoodCategoryForGoodType(_Good) ~= GoodCategories.GC_Animal then
            API.SendCart(StoreHouse2, _P1, _Good, _Amount, nil, false);
        else
            StartSimpleJobEx(function(_Time, _SHID, _Good, _PlayerID)
                if Logic.GetTime() > _Time+5 then
                    return true;
                end
                local x,y = Logic.GetBuildingApproachPosition(_SHID);
                local Type = (_Good ~= Goods.G_Cow and Entities.A_X_Sheep01) or Entities.A_X_Cow01;
                Logic.CreateEntityOnUnblockedLand(Type, x, y, 0, _PlayerID);
            end, Logic.GetTime(), StoreHouse2, _Good, _P1);
        end
    elseif _TraderType == 1 then
        local x,y = Logic.GetBuildingApproachPosition(StoreHouse2);
        local ID  = Logic.CreateBattalionOnUnblockedLand(_Good, x, y, Orientation, _P1);
        Logic.MoveSettler(ID, x, y, -1);
    else
        local x,y = Logic.GetBuildingApproachPosition(StoreHouse2);
        Logic.HireEntertainer(_Good, _P1, x, y);
    end
    API.SendCart(StoreHouse1, _P2, Goods.G_Gold, _Price, nil, false);
    AddGood(Goods.G_Gold, (-1) * _Price, _P1);

    -- Alter offer amount
    local NewAmount = 0;
    local OfferInfo = self:GetStorehouseInformation(_P2);
    for i= 1, #OfferInfo[1] do
        if OfferInfo[1][i][3] == _Good and OfferInfo[1][i][5] > 0 then
            NewAmount = OfferInfo[1][i][5] -1;
        end
    end
    self:ModifyTradeOffer(_P2, _Good, NewAmount);

    -- Update local
    Logic.ExecuteInLuaLocalState(string.format(
        "GameCallback_MerchantInteraction(%d, %d, %d)",
        StoreHouse2,
        _P1,
        _OfferID
    ))
end

function ModuleTrade.Global:GetStorehouseInformation(_PlayerID)
    local BuildingID = Logic.GetStoreHouse(_PlayerID);

    local StorehouseData = {
        Player      = _PlayerID,
        Storehouse  = BuildingID,
        OfferCount  = 0,
        {},
    };

    local NumberOfMerchants = Logic.GetNumberOfMerchants(Logic.GetStoreHouse(_PlayerID));
    local AmountOfOffers = 0;

    if BuildingID ~= 0 then
        for Index = 0, NumberOfMerchants, 1 do
            local Offers = {Logic.GetMerchantOfferIDs(BuildingID, Index, _PlayerID)};
            for i= 1, #Offers, 1 do
                local type, goodAmount, offerAmount, prices = 0, 0, 0, 0;
                if Logic.IsGoodTrader(BuildingID, Index) then
                    type, goodAmount, offerAmount, prices = Logic.GetGoodTraderOffer(BuildingID, Offers[i], _PlayerID);
                    if type == Goods.G_Sheep or type == Goods.G_Cow then
                        goodAmount = 5;
                    end
                elseif Logic.IsMercenaryTrader(BuildingID, Index) then
                    type, goodAmount, offerAmount, prices = Logic.GetMercenaryOffer(BuildingID, Offers[i], _PlayerID);
                elseif Logic.IsEntertainerTrader(BuildingID, Index) then
                    type, goodAmount, offerAmount, prices = Logic.GetEntertainerTraderOffer(BuildingID, Offers[i], _PlayerID);
                end

                AmountOfOffers = AmountOfOffers +1;
                local OfferData = {Index, Offers[i], type, goodAmount, offerAmount, prices};
                table.insert(StorehouseData[1], OfferData);
            end
        end
    end

    StorehouseData.OfferCount = AmountOfOffers;
    return StorehouseData;
end

function ModuleTrade.Global:GetOfferCount(_PlayerID)
    local Offers = self:GetStorehouseInformation(_PlayerID);
    if Offers then
        return Offers.OfferCount;
    end
    return 0;
end

function ModuleTrade.Global:GetOfferAndTrader(_PlayerID, _GoodOrEntityType)
    local Info = self:GetStorehouseInformation(_PlayerID);
    if Info then
        for j=1, #Info[1], 1 do
            if Info[1][j][3] == _GoodOrEntityType then
                return Info[1][j][2], Info[1][j][1], Info.Storehouse;
            end
        end
    end
    return -1, -1, -1;
end

function ModuleTrade.Global:GetTraderType(_BuildingID, _TraderID)
    if Logic.IsGoodTrader(_BuildingID, _TraderID) == true then
        return QSB.TraderTypes.GoodTrader;
    elseif Logic.IsMercenaryTrader(_BuildingID, _TraderID) == true then
        return QSB.TraderTypes.MercenaryTrader;
    elseif Logic.IsEntertainerTrader(_BuildingID, _TraderID) == true then
        return QSB.TraderTypes.EntertainerTrader;
    else
        return QSB.TraderTypes.Unknown;
    end
end

function ModuleTrade.Global:RemoveTradeOffer(_PlayerID, _GoodOrEntityType)
    local OfferID, TraderID, BuildingID = self:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
    if not IsExisting(BuildingID) then
        return;
    end
    -- Trader IDs are mixed up in Logic.RemoveOffer
    local MappedTraderID = (TraderID == 1 and 2) or (TraderID == 2 and 1) or 0;
    Logic.RemoveOffer(BuildingID, MappedTraderID, OfferID);
end

function ModuleTrade.Global:RemoveTradeOfferByData(_Data, _Index)
    local OfferID = _Data[1][_Index][2];
    local TraderID = _Data[1][_Index][1];
    local BuildingID = _Data.Storehouse;
    if not IsExisting(BuildingID) then
        return;
    end
    -- Trader IDs are mixed up in Logic.RemoveOffer
    local MappedTraderID = (TraderID == 1 and 2) or (TraderID == 2 and 1) or 0;
    Logic.RemoveOffer(BuildingID, MappedTraderID, OfferID);
end

function ModuleTrade.Global:ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount)
    local OfferID, TraderID, BuildingID = self:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
    if not IsExisting(BuildingID) then
        return;
    end

    -- Amount == -1 or amount == nil means maximum
    if _NewAmount == nil or _NewAmount == -1 then
        _NewAmount = self.Analysis.PlayerOffersAmount[_PlayerID][_GoodOrEntityType];
    end
    -- Values greater than the maximum will not respawn!
    if self.Analysis.PlayerOffersAmount[_PlayerID][_GoodOrEntityType] and self.Analysis.PlayerOffersAmount[_PlayerID][_GoodOrEntityType] < _NewAmount then
        _NewAmount = self.Analysis.PlayerOffersAmount[_PlayerID][_GoodOrEntityType];
    end
    Logic.ModifyTraderOffer(BuildingID, OfferID, _NewAmount, TraderID);
end

-- Local -------------------------------------------------------------------- --

function ModuleTrade.Local:OnGameStart()
    QSB.ScriptEvents.GoodsSold = API.RegisterScriptEvent("Event_GoodsSold");
    QSB.ScriptEvents.GoodsPurchased = API.RegisterScriptEvent("Event_GoodsPurchased");

    g_Merchant.BuyFromPlayer = {};

    if API.IsHistoryEditionNetworkGame() then
        return;
    end
    self:OverrideMerchantComputePurchasePrice();
    self:OverrideMerchantComputeSellingPrice();
    self:OverrideMerchantSellGoodsClicked();
    self:OverrideMerchantPurchaseOfferUpdate();
    self:OverrideMerchantPurchaseOfferClicked();
end

function ModuleTrade.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

function ModuleTrade.Local:GetTraderType(_BuildingID, _TraderID)
    if Logic.IsGoodTrader(_BuildingID, _TraderID) == true then
        return QSB.TraderTypes.GoodTrader;
    elseif Logic.IsMercenaryTrader(_BuildingID, _TraderID) == true then
        return QSB.TraderTypes.MercenaryTrader;
    elseif Logic.IsEntertainerTrader(_BuildingID, _TraderID) == true then
        return QSB.TraderTypes.EntertainerTrader;
    else
        return QSB.TraderTypes.Unknown;
    end
end

function ModuleTrade.Local:OverrideMerchantPurchaseOfferUpdate()
    GUI_Merchant.OfferUpdate = function(_ButtonIndex)
        local CurrentWidgetID   = XGUIEng.GetCurrentWidgetID();
        local CurrentWidgetMotherID = XGUIEng.GetWidgetsMotherID(CurrentWidgetID);
        local PlayerID          = GUI.GetPlayerID();
        local BuildingID        = g_Merchant.ActiveMerchantBuilding;
        if BuildingID == 0
        or Logic.IsEntityDestroyed(BuildingID) == true then
            return;
        end
        if g_Merchant.Offers[_ButtonIndex] == nil then
            XGUIEng.ShowWidget(CurrentWidgetMotherID,0);
            return;
        else
            XGUIEng.ShowWidget(CurrentWidgetMotherID,1);
        end
        local TraderType = g_Merchant.Offers[_ButtonIndex].TraderType;
        local OfferIndex = g_Merchant.Offers[_ButtonIndex].OfferIndex;
        local GoodType, OfferGoodAmount, OfferAmount, AmountPrices = 0,0,0,0;
        if TraderType == g_Merchant.GoodTrader then
            GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetGoodTraderOffer(BuildingID,OfferIndex,PlayerID);
            if GoodType == Goods.G_Sheep
            or GoodType == Goods.G_Cow then
                OfferGoodAmount = 5;
            end
            SetIcon(CurrentWidgetID, g_TexturePositions.Goods[GoodType]);
        elseif TraderType == g_Merchant.MercenaryTrader then
            GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetMercenaryOffer(BuildingID,OfferIndex,PlayerID);
            local TypeName = Logic.GetEntityTypeName(GoodType);
            if GoodType == Entities.U_Thief then
                OfferGoodAmount = 1;
            elseif string.find(TypeName, "U_MilitarySword")
            or     string.find(TypeName, "U_MilitaryBow") then
                OfferGoodAmount = 6;
            elseif string.find(TypeName, "Cart") then
                OfferGoodAmount = 1;
            else
                OfferGoodAmount = OfferGoodAmount;
            end
            SetIcon(CurrentWidgetID, g_TexturePositions.Entities[GoodType]);
        elseif TraderType == g_Merchant.EntertainerTrader then
            GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetEntertainerTraderOffer(BuildingID,OfferIndex,PlayerID);
            if not (Logic.CanHireEntertainer(PlayerID) == true
            and Logic.EntertainerIsOnTheMap(GoodType) == false) then
                OfferAmount = 0;
            end
            SetIcon(CurrentWidgetID, g_TexturePositions.Entities[GoodType]);
        end

        local OfferAmountWidget = XGUIEng.GetWidgetPathByID(CurrentWidgetMotherID) .. "/OfferAmount";
        XGUIEng.SetText(OfferAmountWidget, "{center}" .. OfferAmount);
        local OfferGoodAmountWidget = XGUIEng.GetWidgetPathByID(CurrentWidgetMotherID) .. "/OfferGoodAmount";
        XGUIEng.SetText(OfferGoodAmountWidget, "{center}" .. OfferGoodAmount);

        if OfferAmount == 0 then
            XGUIEng.DisableButton(CurrentWidgetID,1);
        else
            XGUIEng.DisableButton(CurrentWidgetID,0);
        end
    end
end

function ModuleTrade.Local:OverrideMerchantPurchaseOfferClicked()
    -- Set special conditions
    local PurchaseAllowedLambda = function(_Type, _Good, _Amount, _Price, _P1, _P2)
        return true;
    end
    self.Lambda.PurchaseAllowed.Default = PurchaseAllowedLambda;

    local BuyLock = {Locked = false};

    GameCallback_MerchantInteraction = function(_BuildingID, _PlayerID, _OfferID)
        if _PlayerID == GUI.GetPlayerID() then
            BuyLock.Locked = false;
        end
    end

    GUI_Merchant.OfferClicked = function(_ButtonIndex)
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local PlayerID   = GUI.GetPlayerID();
        local BuildingID = g_Merchant.ActiveMerchantBuilding;
        if BuildingID == 0 or BuyLock.Locked then
            return;
        end
        local PlayersMarketPlaceID  = Logic.GetMarketplace(PlayerID);
        local TraderPlayerID        = Logic.EntityGetPlayer(BuildingID);
        local TraderType            = g_Merchant.Offers[_ButtonIndex].TraderType;
        local OfferIndex            = g_Merchant.Offers[_ButtonIndex].OfferIndex;

        local CanBeBought = true;
        local GoodType, OfferGoodAmount, OfferAmount, AmountPrices = 0,0,0,0;
        if TraderType == g_Merchant.GoodTrader then
            GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetGoodTraderOffer(BuildingID, OfferIndex, PlayerID);
            if Logic.GetGoodCategoryForGoodType(GoodType) == GoodCategories.GC_Resource then
                if Logic.GetPlayerUnreservedStorehouseSpace(PlayerID) < OfferGoodAmount then
                    CanBeBought = false;
                    local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_MerchantStorehouseSpace");
                    Message(MessageText);
                end
            elseif Logic.GetGoodCategoryForGoodType(GoodType) == GoodCategories.GC_Animal then
                CanBeBought = true;
            else
                if Logic.CanFitAnotherMerchantOnMarketplace(PlayersMarketPlaceID) == false then
                    CanBeBought = false;
                    local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_MerchantMarketplaceFull");
                    Message(MessageText);
                end
            end
        elseif TraderType == g_Merchant.EntertainerTrader then
            GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetEntertainerTraderOffer(BuildingID, OfferIndex, BuildingID);
            if Logic.CanFitAnotherEntertainerOnMarketplace(PlayersMarketPlaceID) == false then
                CanBeBought = false;
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_MerchantMarketplaceFull");
                Message(MessageText);
            end
        elseif TraderType == g_Merchant.MercenaryTrader then
            GoodType, OfferGoodAmount, OfferAmount, AmountPrices = Logic.GetMercenaryOffer(BuildingID, OfferIndex, PlayerID);
            local GoodTypeName        = Logic.GetEntityTypeName(GoodType);
            local CurrentSoldierCount = Logic.GetCurrentSoldierCount(PlayerID);
            local CurrentSoldierLimit = Logic.GetCurrentSoldierLimit(PlayerID);
            local SoldierSize;
            if GoodType == Entities.U_Thief then
                SoldierSize = 1;
            elseif string.find(GoodTypeName, "U_MilitarySword")
            or     string.find(GoodTypeName, "U_MilitaryBow") then
                SoldierSize = 6;
            elseif string.find(GoodTypeName, "Cart") then
                SoldierSize = 0;
            else
                SoldierSize = OfferGoodAmount;
            end
            if (CurrentSoldierCount + SoldierSize) > CurrentSoldierLimit then
                CanBeBought = false;
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_SoldierLimitReached");
                Message(MessageText);
            end
        end

        -- Special sales conditions
        if CanBeBought then
            if ModuleTrade.Local.Lambda.PurchaseAllowed[TraderPlayerID] then
                CanBeBought = ModuleTrade.Local.Lambda.PurchaseAllowed[TraderPlayerID](TraderType, GoodType, OfferGoodAmount, PlayerID, TraderPlayerID);
            else
                CanBeBought = ModuleTrade.Local.Lambda.PurchaseAllowed.Default(TraderType, GoodType, OfferGoodAmount, PlayerID, TraderPlayerID);
            end
            if not CanBeBought then
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericNotReadyYet");
                Message(MessageText);
                return;
            end
        end

        if CanBeBought == true then
            local Price = ComputePrice( BuildingID, OfferIndex, PlayerID, TraderType);
            local GoldAmountInCastle = GetPlayerGoodsInSettlement(Goods.G_Gold, PlayerID);
            local PlayerSectorType = PlayerSectorTypes.Civil;
            local IsReachable = CanEntityReachTarget(PlayerID, Logic.GetStoreHouse(TraderPlayerID), Logic.GetStoreHouse(PlayerID), nil, PlayerSectorType);
            if IsReachable == false then
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericUnreachable");
                Message(MessageText);
                return;
            end
            if Price <= GoldAmountInCastle then
                BuyLock.Locked = true;
                GUI.ChangeMerchantOffer(BuildingID, PlayerID, OfferIndex, Price);
                Sound.FXPlay2DSound("ui\\menu_click");
                if ModuleTrade.Local.ShowKnightTraderAbility then
                    StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightTrading);
                end

                -- Manually log in local state
                g_Merchant.BuyFromPlayer[TraderPlayerID] = g_Merchant.BuyFromPlayer[TraderPlayerID] or {};
                g_Merchant.BuyFromPlayer[TraderPlayerID][GoodType] = (g_Merchant.BuyFromPlayer[TraderPlayerID][GoodType] or 0) +1;

                API.BroadcastScriptEventToGlobal(
                    "GoodsPurchased",
                    OfferIndex,
                    TraderType,
                    GoodType,
                    OfferGoodAmount,
                    Price,
                    PlayerID,
                    TraderPlayerID
                );
            else
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_G_Gold");
                Message(MessageText);
            end
        end
    end
end

function ModuleTrade.Local:OverrideMerchantSellGoodsClicked()
    -- Set special conditions
    local SaleAllowedLambda = function(_Type, _Good, _Amount, _Price, _P1, _P2)
        return true;
    end
    self.Lambda.SaleAllowed.Default = SaleAllowedLambda;

    GUI_Trade.SellClicked = function()
        Sound.FXPlay2DSound( "ui\\menu_click");
        if g_Trade.GoodAmount == 0 then
            return;
        end
        local PlayerID = GUI.GetPlayerID();
        local ButtonIndex = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetWidgetsMotherID(XGUIEng.GetCurrentWidgetID())));
        local TargetID = g_Trade.TargetPlayers[ButtonIndex];
        local PlayerSectorType = PlayerSectorTypes.Civil;
        if g_Trade.GoodType == Goods.G_Gold then
            PlayerSectorType = PlayerSectorTypes.Thief;
        end
        local IsReachable = CanEntityReachTarget(TargetID, Logic.GetStoreHouse(PlayerID), Logic.GetStoreHouse(TargetID), nil, PlayerSectorType);
        if IsReachable == false then
            local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericUnreachable");
            Message(MessageText);
            return;
        end
        if g_Trade.GoodType == Goods.G_Gold then
            -- FIXME: check for treasury space in castle?
        elseif Logic.GetGoodCategoryForGoodType(g_Trade.GoodType) == GoodCategories.GC_Resource then
            local SpaceForNewGoods = Logic.GetPlayerUnreservedStorehouseSpace(TargetID);
            if SpaceForNewGoods < g_Trade.GoodAmount then
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_TargetFactionStorehouseSpace");
                Message(MessageText);
                return;
            end
        else
            if Logic.GetNumberOfTradeGatherers(PlayerID) >= 1 then
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_TradeGathererUnderway");
                Message(MessageText);
                return;
            end
            if Logic.CanFitAnotherMerchantOnMarketplace(Logic.GetMarketplace(TargetID)) == false then
                local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_TargetFactionMarketplaceFull");
                Message(MessageText);
                return;
            end
        end

        -- Special sales conditions
        local CanBeSold = true;
        if ModuleTrade.Local.Lambda.SaleAllowed[TargetID] then
            CanBeSold = ModuleTrade.Local.Lambda.SaleAllowed[TargetID](g_Merchant.GoodTrader, g_Trade.GoodType, g_Trade.GoodAmount, PlayerID, TargetID);
        else
            CanBeSold = ModuleTrade.Local.Lambda.SaleAllowed.Default(g_Merchant.GoodTrader, g_Trade.GoodType, g_Trade.GoodAmount, PlayerID, TargetID);
        end
        if not CanBeSold then
            local MessageText = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericNotReadyYet");
            Message(MessageText);
            return;
        end

        local Price;
        local PricePerUnit;
        if Logic.PlayerGetIsHumanFlag(TargetID) then
            Price = 0;
            PricePerUnit = 0;
        else
            Price = GUI_Trade.ComputeSellingPrice(TargetID, g_Trade.GoodType, g_Trade.GoodAmount);
            PricePerUnit = Price / g_Trade.GoodAmount;
        end

        GUI.StartTradeGoodGathering(PlayerID, TargetID, g_Trade.GoodType, g_Trade.GoodAmount, PricePerUnit);
        GUI_FeedbackSpeech.Add("SpeechOnly_CartsSent", g_FeedbackSpeech.Categories.CartsUnderway, nil, nil);
        StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightTrading);

        if PricePerUnit ~= 0 then
            if g_Trade.SellToPlayers[TargetID] == nil then
                g_Trade.SellToPlayers[TargetID] = {};
            end
            if g_Trade.SellToPlayers[TargetID][g_Trade.GoodType] == nil then
                g_Trade.SellToPlayers[TargetID][g_Trade.GoodType] = g_Trade.GoodAmount;
            else
                g_Trade.SellToPlayers[TargetID][g_Trade.GoodType] = g_Trade.SellToPlayers[TargetID][g_Trade.GoodType] + g_Trade.GoodAmount;
            end
            API.BroadcastScriptEventToGlobal(
                "GoodsSold",
                g_Merchant.GoodTrader,
                g_Trade.GoodType,
                g_Trade.GoodAmount,
                Price,
                PlayerID,
                TargetID
            );
        end
    end
end

function ModuleTrade.Local:OverrideMerchantComputePurchasePrice()
    -- Override factor of hero ability
    local AbilityTraderLambda = function(_TraderType, _OfferType, _BasePrice, _PlayerID, _TraderPlayerID)
        local Modifier = Logic.GetKnightTraderAbilityModifier(_PlayerID);
        return math.ceil(_BasePrice / Modifier);
    end
    self.Lambda.PurchaseTraderAbility.Default = AbilityTraderLambda;

    -- Override base price calculation
    local BasePriceLambda = function(_TraderType, _OfferType, _PlayerID, _TraderPlayerID)
        local BasePrice = MerchantSystem.BasePrices[_OfferType];
        return (BasePrice == nil and 3) or BasePrice;
    end
    self.Lambda.PurchaseBasePrice.Default = BasePriceLambda;

    -- Override max inflation
    local InflationLambda = function(_TraderType, _GoodType, _OfferCount, _Price, _PlayerID, _TraderPlayerID)
        _OfferCount = (_OfferCount > 8 and 8) or _OfferCount;
        local Result = _Price + (math.ceil(_Price / 4) * _OfferCount);
        return (Result < _Price and _Price) or Result;
    end
    self.Lambda.PurchaseInflation.Default = InflationLambda;

    -- Override function
    ComputePrice = function(BuildingID, OfferID, PlayerID, TraderType)
        local TraderPlayerID = Logic.EntityGetPlayer(BuildingID);
        local Type = Logic.GetGoodOfOffer(BuildingID, OfferID, PlayerID, TraderType);

        -- Calculate the base price
        local BasePrice;
        if ModuleTrade.Local.Lambda.PurchaseBasePrice[TraderPlayerID] then
            BasePrice = ModuleTrade.Local.Lambda.PurchaseBasePrice[TraderPlayerID](TraderType, Type, PlayerID, TraderPlayerID)
        else
            BasePrice = ModuleTrade.Local.Lambda.PurchaseBasePrice.Default(TraderType, Type, PlayerID, TraderPlayerID)
        end

        -- Calculate price
        local Price
        if ModuleTrade.Local.Lambda.PurchaseTraderAbility[TraderPlayerID] then
            Price = ModuleTrade.Local.Lambda.PurchaseTraderAbility[TraderPlayerID](TraderType, Type, BasePrice, PlayerID, TraderPlayerID)
        else
            Price = ModuleTrade.Local.Lambda.PurchaseTraderAbility.Default(TraderType, Type, BasePrice, PlayerID, TraderPlayerID)
        end

        -- Invoke price inflation
        local OfferCount = 0;
        if g_Merchant.BuyFromPlayer[TraderPlayerID] and g_Merchant.BuyFromPlayer[TraderPlayerID][Type] then
            OfferCount = g_Merchant.BuyFromPlayer[TraderPlayerID][Type];
        end
        local FinalPrice;
        if ModuleTrade.Local.Lambda.PurchaseInflation[TraderPlayerID] then
            FinalPrice = ModuleTrade.Local.Lambda.PurchaseInflation[TraderPlayerID](TraderType, Type, OfferCount, Price, PlayerID, TraderPlayerID);
        else
            FinalPrice = ModuleTrade.Local.Lambda.PurchaseInflation.Default(TraderType, Type, OfferCount, Price, PlayerID, TraderPlayerID);
        end
        return FinalPrice;
    end
end

function ModuleTrade.Local:OverrideMerchantComputeSellingPrice()
    -- Override factor of hero ability
    local AbilityTraderLambda = function(_TraderType, _OfferType, _BasePrice, _PlayerID, _TraderPlayerID)
        -- No change by default
        return _BasePrice;
    end
    self.Lambda.SaleTraderAbility.Default = AbilityTraderLambda;

    -- Override base price calculation
    local BasePriceLambda = function(_TraderType, _OfferType, _PlayerID, _TargetPlayerID)
        local BasePrice = MerchantSystem.BasePrices[_OfferType];
        return (BasePrice == nil and 3) or BasePrice;
    end
    self.Lambda.SaleBasePrice.Default = BasePriceLambda;

    -- Override max deflation
    local DeflationLambda = function(_TraderType, _OfferType, _WagonsSold, _Price, _PlayerID, _TargetPlayerID)
        return _Price - math.ceil(_Price / 4);
    end
    self.Lambda.SaleDeflation.Default = DeflationLambda;

    GUI_Trade.ComputeSellingPrice = function(_TargetPlayerID, _GoodType, _GoodAmount)
        if _GoodType == Goods.G_Gold then
            return 0;
        end
        local PlayerID = GUI.GetPlayerID();
        local Waggonload = MerchantSystem.Waggonload;

        -- Calculate the base price
        local BasePrice;
        if ModuleTrade.Local.Lambda.SaleBasePrice[_TargetPlayerID] then
            BasePrice = ModuleTrade.Local.Lambda.SaleBasePrice[_TargetPlayerID](g_Merchant.GoodTrader, _GoodType, PlayerID, _TargetPlayerID);
        else
            BasePrice = ModuleTrade.Local.Lambda.SaleBasePrice.Default(g_Merchant.GoodTrader, _GoodType, PlayerID, _TargetPlayerID);
        end

        -- Calculate price
        local Price = BasePrice;
        if ModuleTrade.Local.Lambda.SaleTraderAbility[_TargetPlayerID] then
            Price = ModuleTrade.Local.Lambda.SaleTraderAbility[_TargetPlayerID](g_Merchant.GoodTrader, _GoodType, BasePrice, PlayerID, _TargetPlayerID)
        else
            Price = ModuleTrade.Local.Lambda.SaleTraderAbility.Default(g_Merchant.GoodTrader, _GoodType, BasePrice, PlayerID, _TargetPlayerID)
        end

        local GoodsSoldToTargetPlayer = 0
        if  g_Trade.SellToPlayers[_TargetPlayerID] ~= nil
        and g_Trade.SellToPlayers[_TargetPlayerID][_GoodType] ~= nil then
            GoodsSoldToTargetPlayer = g_Trade.SellToPlayers[_TargetPlayerID][_GoodType];
        end
        local Modifier = math.ceil(Price / 4);
        local WaggonsToSell = math.ceil(_GoodAmount / Waggonload);
        local WaggonsSold = math.ceil(GoodsSoldToTargetPlayer / Waggonload);

        -- Calculate the max deflation
        local MaxToSubstract
        if ModuleTrade.Local.Lambda.SaleDeflation[_TargetPlayerID] then
            MaxToSubstract = ModuleTrade.Local.Lambda.SaleDeflation[_TargetPlayerID](g_Merchant.GoodTrader, _GoodType, WaggonsSold, Price, PlayerID, _TargetPlayerID);
        else
            MaxToSubstract = ModuleTrade.Local.Lambda.SaleDeflation.Default(g_Merchant.GoodTrader, _GoodType, WaggonsSold, Price, PlayerID, _TargetPlayerID);
        end

        local PriceToSubtract = 0;
        for i = 1, WaggonsToSell do
            PriceToSubtract = PriceToSubtract + math.min(WaggonsSold * Modifier, MaxToSubstract);
            WaggonsSold = WaggonsSold + 1;
        end

        return (WaggonsToSell * BasePrice) - PriceToSubtract;
    end
end

-- -------------------------------------------------------------------------- --

Revision:RegisterModule(ModuleTrade);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Es kann in den Ablauf von Kauf und Verkauf eingegriffen werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field GoodsPurchased Güter werden bei einem Händler gekauft (Parameter: OfferID, TraderType, GoodType, OfferGoodAmount, Price, PlayerID, TraderPlayerID)
-- @field GoodsSold      Güter werden im eigenen Lagerhaus verkauft (Parameter: TraderType, GoodType, GoodAmount, Price, PlayerID, TargetPlayerID)
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Typen der Händler
--
-- @field GoodTrader        Es werden Güter verkauft
-- @field MercenaryTrader   Es werden Söldner verkauft
-- @field EntertainerTrader Es werden Entertainer verkauft
-- @field Unknown           Unbekannter Typ (Fehler)
--
QSB.TraderTypes = QSB.TraderTypes or {};

---
-- Setzt die Funktion zur Kalkulation des Einkaufspreisfaktors des Helden. Die
-- Änderung betrifft nur den angegebenen Spieler.
-- Die Funktion muss den angepassten Preis zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_BasePrice</td><td>number</td><td></td>Basispreis</tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=number] _PlayerID Player ID des Händlers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.PurchaseSetTraderAbilityForPlayer(2, MyCalculationFunction);
--
function API.PurchaseSetTraderAbilityForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTrade.Local.Lambda.PurchaseTraderAbility[_PlayerID] = _Function;
    else
        ModuleTrade.Local.Lambda.PurchaseTraderAbility.Default = _Function;
    end
end

---
-- Setzt die allgemeine Funktion zur Kalkulation des Einkaufspreisfaktors des
-- Helden. Die Funktion muss den angepassten Preis zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_BasePrice</td><td>number</td><td></td>Basispreis</tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.PurchaseSetDefaultTraderAbility(MyCalculationFunction);
--
function API.PurchaseSetDefaultTraderAbility(_Function)
    API.PurchaseSetTraderAbilityForPlayer(nil, _Function);
end

---
-- Setzt die Funktion zur Bestimmung des Basispreis. Die Änderung betrifft nur
-- den angegebenen Spieler.
-- Die Funktion muss den Basispreis der Ware zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=number] _PlayerID Player ID des Händlers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.PurchaseSetBasePriceForPlayer(2, MyCalculationFunction);
--
function API.PurchaseSetBasePriceForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTrade.Local.Lambda.PurchaseBasePrice[_PlayerID] = _Function;
    else
        ModuleTrade.Local.Lambda.PurchaseBasePrice.Default = _Function;
    end
end

---
-- Setzt die Funktion zur Bestimmung des Basispreis.
-- Die Funktion muss den Basispreis der Ware zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.PurchaseSetDefaultBasePrice(MyCalculationFunction);
--
function API.PurchaseSetDefaultBasePrice(_Function)
    API.PurchaseSetBasePriceForPlayer(nil, _Function);
end

---
-- Setzt die Funktion zur Berechnung der Preisinflation. Die Änderung betrifft
-- nur den angegebenen Spieler.
-- Die Funktion muss den von der Inflation beeinflussten Preis zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Anzahl bereits gekaufter Angebote</td></tr>
-- <tr><td>_Price</td><td>number</td><td></td>Einkaufspreis</tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=number] _PlayerID Player ID des Händlers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.PurchaseSetInflationForPlayer(2, MyCalculationFunction);
--
function API.PurchaseSetInflationForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTrade.Local.Lambda.PurchaseInflation[_PlayerID] = _Function;
    else
        ModuleTrade.Local.Lambda.PurchaseInflation.Default = _Function;
    end
end

---
-- Setzt die Funktion zur Berechnung der Preisinflation.
-- Die Funktion muss den von der Inflation beeinflussten Preis zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Anzahl bereits gekaufter Angebote</td></tr>
-- <tr><td>_Price</td><td>number</td><td></td>Einkaufspreis</tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.PurchaseSetDefaultInflation(MyCalculationFunction);
--
function API.PurchaseSetDefaultInflation(_Function)
    API.PurchaseSetInflationForPlayer(nil, _Function)
end

---
-- Setzt eine Funktion zur Festlegung spezieller Ankaufsbedingungen. Diese
-- Bedingungen betreffen nur den angegebenen Spieler.
-- Die Funktion muss true zurückgeben, wenn gekauft werden darf.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=number] _PlayerID Player ID des Händlers
-- @param[type=number] _Function Evaluationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.PurchaseSetConditionForPlayer(2, MyCalculationFunction);
--
function API.PurchaseSetConditionForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTrade.Local.Lambda.PurchaseAllowed[_PlayerID] = _Function;
    else
        ModuleTrade.Local.Lambda.PurchaseAllowed.Default = _Function;
    end
end

---
-- Setzt eine Funktion zur Festlegung spezieller Verkaufsbedingungen.
-- Die Funktion muss true zurückgeben, wenn verkauft werden darf.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Evaluationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.PurchaseSetDefaultCondition(MyCalculationFunction);
--
function API.PurchaseSetDefaultCondition(_Function)
    API.PurchaseSetConditionForPlayer(nil, _Function)
end

---
-- Setzt die Funktion zur Kalkulation des Verkreisfaktors des Helden. Die
-- Änderung betrifft nur den angegebenen Spieler.
-- Die Funktion muss den angepassten Preis zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td></td>Typ des Händlers</tr>
-- <tr><td>_Good</td><td>number</td><td></td>Typ des Angebot</tr>
-- <tr><td>_BasePrice</td><td>number</td><td></td>Basispreis</tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=number] _PlayerID Player ID des Händlers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.SaleSetTraderAbilityForPlayer(2, MyCalculationFunction);
--
function API.SaleSetTraderAbilityForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTrade.Local.Lambda.SaleTraderAbility[_PlayerID] = _Function;
    else
        ModuleTrade.Local.Lambda.SaleTraderAbility.Default = _Function;
    end
end

---
-- Setzt die allgemeine Funktion zur Kalkulation des Verkreisfaktors des Helden.
-- Die Funktion muss den angepassten Preis zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td></td>Typ des Händlers</tr>
-- <tr><td>_Good</td><td>number</td><td></td>Typ des Angebot</tr>
-- <tr><td>_BasePrice</td><td>number</td><td></td>Basispreis</tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.SaleSetDefaultTraderAbility(MyCalculationFunction);
--
function API.SaleSetDefaultTraderAbility(_Function)
    API.SaleSetTraderAbilityForPlayer(nil, _Function);
end

---
-- Setzt die Funktion zur Bestimmung des Basispreis. Die Änderung betrifft nur
-- den angegebenen Spieler.
-- Die Funktion muss den Basispreis der Ware zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=number] _PlayerID Player ID des Händlers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.SaleSetBasePriceForPlayer(2, MyCalculationFunction);
--
function API.SaleSetBasePriceForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTrade.Local.Lambda.SaleBasePrice[_PlayerID] = _Function;
    else
        ModuleTrade.Local.Lambda.SaleBasePrice.Default = _Function;
    end
end

---
-- Setzt die Funktion zur Bestimmung des Basispreis.
-- Die Funktion muss den Basispreis der Ware zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.SaleSetDefaultBasePrice(MyCalculationFunction);
--
function API.SaleSetDefaultBasePrice(_Function)
    API.SaleSetBasePriceForPlayer(nil, _Function);
end

---
-- Setzt die Funktion zur Berechnung des minimalen Verkaufserlös. Die Änderung
-- betrifft nur den angegebenen Spieler.
-- Die Funktion muss den von der Deflation beeinflussten Erlös zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_SaleCount</td><td>number</td><td>Amount of sold waggons</td></tr>
-- <tr><td>_Price</td><td>number</td><td>Verkaufspreis</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=number] _PlayerID Player ID des Händlers
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.SaleSetDeflationForPlayer(2, MyCalculationFunction);
--
function API.SaleSetDeflationForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTrade.Local.Lambda.SaleDeflation[_PlayerID] = _Function;
    else
        ModuleTrade.Local.Lambda.SaleDeflation.Default = _Function;
    end
end

---
-- Setzt die Funktion zur Berechnung des minimalen Verkaufserlös.
-- Die Funktion muss den von der Deflation beeinflussten Erlös zurückgeben.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_SaleCount</td><td>number</td><td>Amount of sold waggons</td></tr>
-- <tr><td>_Price</td><td>number</td><td>Verkaufspreis</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Kalkulationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.SaleSetDefaultDeflation(MyCalculationFunction);
--
function API.SaleSetDefaultDeflation(_Function)
    API.SaleSetDeflationForPlayer(nil, _Function);
end

---
-- Setzt eine Funktion zur Festlegung spezieller Verkaufsbedingungen. Diese
-- Bedingungen betreffen nur den angegebenen Spieler.
-- Die Funktion muss true zurückgeben, wenn verkauft werden darf.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
-- übergeben werden.
--
-- @param[type=number] _PlayerID Player ID des Händlers
-- @param[type=number] _Function Evaluationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.SaleSetConditionForPlayer(2, MyCalculationFunction);
--
function API.SaleSetConditionForPlayer(_PlayerID, _Function)
    if not GUI then
        return;
    end
    if _PlayerID then
        ModuleTrade.Local.Lambda.SaleAllowed[_PlayerID] = _Function;
    else
        ModuleTrade.Local.Lambda.SaleAllowed.Default = _Function;
    end
end

---
-- Setzt eine Funktion zur Festlegung spezieller Verkaufsbedingungen.
-- Die Funktion muss true zurückgeben, wenn verkauft werden darf.
--
-- Parameter der Funktion:
-- <table border="1">
-- <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
-- <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
-- <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
-- <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
-- <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
-- <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
-- </table>
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _Function Evaluationsfunktion
-- @within Anwenderfunktionen
--
-- @usage
-- API.SaleSetDefaultCondition(MyCalculationFunction);
--
function API.SaleSetDefaultCondition(_Function)
    API.SaleSetConditionForPlayer(nil, _Function);
end

---
-- Lässt einen NPC-Spieler Waren anbieten.
--
-- @param[type=number] _VendorID    Spieler-ID des Verkäufers
-- @param[type=number] _OfferType   Typ der Angebote
-- @param[type=number] _OfferAmount Menge an Angeboten
-- @param[type=number] _RefreshRate (Optional) Regenerationsrate des Angebot
-- @within Anwenderfunktionen
-- @local
--
-- @usage
-- -- Spieler 2 bietet Brot an
-- API.AddGoodOffer(2, Goods.G_Bread, 1, 2);
--
function API.AddGoodOffer(_VendorID, _OfferType, _OfferAmount, _RefreshRate)
    _OfferType = (type(_OfferType) == "string" and Goods[_OfferType]) or _OfferType;
    local OfferID, TraderID = ModuleTrade.Global:GetOfferAndTrader(_VendorID, _OfferType);
    if OfferID ~= -1 and TraderID ~= -1 then
        warn(string.format(
            "Good offer for type %s already exists for player %d!",
            Logic.GetGoodTypeName(_OfferType),
            _VendorID
        ));
        return;
    end

    local VendorStoreID = Logic.GetStoreHouse(_VendorID);
    AddGoodToTradeBlackList(_VendorID, _OfferType);

    -- Good cart type
    local MarketerType = Entities.U_Marketer;
    if _OfferType == Goods.G_Medicine then
        MarketerType = Entities.U_Medicus;
    end
    -- Refresh rate
    if _RefreshRate == nil then
        _RefreshRate = MerchantSystem.RefreshRates[_OfferType] or 0;
    end

    local LogicOfferID = Logic.AddGoodTraderOffer(
        VendorStoreID,
        _OfferAmount,
        Goods.G_Gold,
        0,
        _OfferType,
        MerchantSystem.Waggonload,
        1,
        _RefreshRate,
        MarketerType,
        Entities.U_ResourceMerchant
    );
    Logic.ExecuteInLuaLocalState(string.format(
        "GameCallback_CloseNPCInteraction(GUI.GetPlayerID(), %d)",
        VendorStoreID
    ));
    return LogicOfferID;
end
-- Compability option
function AddOffer(_Merchant, _NumberOfOffers, _GoodType, _RefreshRate)
    local VendorID = Logic.EntityGetPlayer(GetID(_Merchant));
    return API.AddGoodOffer(VendorID, _GoodType, _NumberOfOffers, _RefreshRate);
end

---
-- Lässt einen NPC-Spieler Söldner anbieten.
--
-- <b>Hinweis</b>: Stadtlagerhäuser können keine Söldner anbieten!
--
-- @param[type=number] _VendorID    Spieler-ID des Verkäufers
-- @param[type=number] _OfferType   Typ der Söldner
-- @param[type=number] _OfferAmount Menge an Söldnern
-- @param[type=number] _RefreshRate (Optional) Regenerationsrate des Angebot
-- @within Anwenderfunktionen
-- @local
--
-- @usage
-- -- Spieler 2 bietet Sölder an
-- API.AddMercenaryOffer(2, Entities.U_MilitaryBandit_Melee_SE, 1, 3);
--
function API.AddMercenaryOffer(_VendorID, _OfferType, _OfferAmount, _RefreshRate)
    _OfferType = (type(_OfferType) == "string" and Entities[_OfferType]) or _OfferType;
    local OfferID, TraderID = ModuleTrade.Global:GetOfferAndTrader(_VendorID, _OfferType);
    if OfferID ~= -1 and TraderID ~= -1 then
        warn(string.format(
            "Mercenary offer for type %s already exists for player %d!",
            Logic.GetEntityTypeName(_OfferType),
            _VendorID
        ));
        return;
    end

    local VendorStoreID = Logic.GetStoreHouse(_VendorID);

    -- Refresh rate
    if _RefreshRate == nil then
        _RefreshRate = MerchantSystem.RefreshRates[_OfferType] or 0;
    end
    -- Soldier count (Display hack for unusual mercenaries)
    local SoldierCount = 3;
    local TypeName = Logic.GetEntityTypeName(_OfferType);
    if string.find(TypeName, "MilitaryBow") or string.find(TypeName, "MilitarySword") then
        SoldierCount = 6;
    elseif string.find(TypeName,"Cart") then
        SoldierCount = 0;
    end

    local LogicOfferID = Logic.AddMercenaryTraderOffer(
        VendorStoreID,
        _OfferAmount,
        Goods.G_Gold,
        0,
        _OfferType,
        SoldierCount,
        1,
        _RefreshRate
    );
    Logic.ExecuteInLuaLocalState(string.format(
        "GameCallback_CloseNPCInteraction(GUI.GetPlayerID(), %d)",
        VendorStoreID
    ));
    return LogicOfferID;
end
-- Compability option
function AddMercenaryOffer(_Mercenary, _Amount, _Type, _RefreshRate)
    local VendorID = Logic.EntityGetPlayer(GetID(_Mercenary));
    return API.AddMercenaryOffer(VendorID, _Type, _Amount, _RefreshRate);
end

---
-- Lässt einen NPC-Spieler einen Entertainer anbieten.
--
-- @param[type=number] _VendorID    Spieler-ID des Verkäufers
-- @param[type=number] _OfferType   Typ des Entertainer
-- @within Anwenderfunktionen
-- @local
--
-- @usage
-- -- Spieler 2 bietet einen Feuerschlucker an
-- API.AddEntertainerOffer(2, Entities.U_Entertainer_NA_FireEater);
--
function API.AddEntertainerOffer(_VendorID, _OfferType)
    _OfferType = (type(_OfferType) == "string" and Entities[_OfferType]) or _OfferType;
    local OfferID, TraderID = ModuleTrade.Global:GetOfferAndTrader(_VendorID, _OfferType);
    if OfferID ~= -1 and TraderID ~= -1 then
        warn(string.format(
            "Entertainer offer for type %s already exists for player %d!",
            Logic.GetEntityTypeName(_OfferType),
            _VendorID
        ));
        return;
    end

    local VendorStoreID = Logic.GetStoreHouse(_VendorID);
    local LogicOfferID = Logic.AddEntertainerTraderOffer(
        VendorStoreID,
        1,
        Goods.G_Gold,
        0,
        _OfferType,
        1,
        0
    );
    Logic.ExecuteInLuaLocalState(string.format(
        "GameCallback_CloseNPCInteraction(GUI.GetPlayerID(), %d)",
        VendorStoreID
    ));
    return LogicOfferID;
end
-- Compability option
function AddEntertainerOffer(_Merchant, _EntertainerType)
    local VendorID = Logic.EntityGetPlayer(GetID(_Merchant));
    return API.AddEntertainerOffer(VendorID, _EntertainerType);
end

---
-- Gibt die Angebotsinformationen des Spielers aus. In dem Table stehen
-- ID des Spielers, ID des Lagerhaus, Menge an Angeboten insgesamt und
-- alle Angebote der Händlertypen.
--
-- @param[type=number] _PlayerID Player ID
-- @return[type=table] Angebotsinformationen
-- @within Anwenderfunktionen
-- @local
--
-- @usage
-- local Info = API.GetOfferInformation(2);
--
-- -- Info enthält:
-- -- Info = {
-- --      Player = 2,
-- --      Storehouse = 26796.
-- --      OfferCount = 2,
-- --      {
-- --          Händler-ID, Angebots-ID, Angebotstyp, Wagenladung, Angebotsmenge
-- --          {0, 0, Goods.G_Gems, 9, 2},
-- --          {0, 1, Goods.G_Milk, 9, 4},
-- --      },
-- -- };
--
function API.GetOfferInformation(_PlayerID)
    if GUI then
        return;
    end
    return ModuleTrade.Global:GetStorehouseInformation(_PlayerID);
end

---
-- Gibt die Menge an Angeboten im Lagerhaus des Spielers zurück. Wenn
-- der Spieler kein Lagerhaus hat, wird 0 zurückgegeben.
--
-- @param[type=number] _PlayerID Player ID
-- @return[type=number] Anzahl angebote
-- @within Anwenderfunktionen
-- @local
--
-- @usage
-- -- Angebote von Spieler 5 zählen
-- local Count = API.GetOfferCount(5);
--
function API.GetOfferCount(_PlayerID)
    if GUI then
        return;
    end
    return ModuleTrade.Global:GetOfferCount(_PlayerID);
end

---
-- Gibt zurück, ob das Angebot vom angegebenen Spieler im Lagerhaus zum
-- Verkauf angeboten wird.
--
-- @param[type=number] _PlayerID Player ID
-- @param[type=number] _GoodOrEntityType Warentyp oder Entitytyp
-- @return[type=boolean] Ware wird angeboten
-- @within Anwenderfunktionen
-- @local
--
-- @usage
-- -- Wird die Ware angeboten?
-- if API.IsGoodOrUnitOffered(4, Goods.G_Bread) then
--     Logic.DEBUG_AddNote("Brot wird von Spieler 4 angeboten.");
-- end
--
function API.IsGoodOrUnitOffered(_PlayerID, _GoodOrEntityType)
    if GUI then
        return;
    end
    local OfferID, TraderID = ModuleTrade.Global:GetOfferAndTrader(_PlayerID, _GoodOrEntityType);
    return OfferID ~= 1 and TraderID ~= 1;
end

---
-- Gibt die aktuelle Anzahl an Angeboten des Typs zurück.
--
-- @param[type=number] _PlayerID Player ID
-- @param[type=number] _GoodOrEntityType Warentyp oder Entitytyp
-- @return[type=number] Menge an Angeboten
-- @within Anwenderfunktionen
-- @local
--
-- @usage
-- -- Wie viel wird aktuell angeboten?
-- local CurrentAmount = API.IsGoodOrUnitOffered(4, Goods.G_Bread);
--
function API.GetTradeOfferWaggonAmount(_PlayerID, _GoodOrEntityType)
    local Amount = -1;
    local OfferInfo = ModuleTrade.Global:GetStorehouseInformation(_PlayerID);
    for i= 1, #OfferInfo[4] do
        if OfferInfo[4][i][3] == _GoodOrEntityType and OfferInfo[4][i][5] > 0 then
            Amount = OfferInfo[4][i][5];
        end
    end
    return Amount;
end

---
-- Entfernt das Angebot vom Lagerhaus des Spielers, wenn es vorhanden
-- ist. Es wird immer nur das erste Angebot des Typs entfernt.
--
-- @param[type=number] _PlayerID Player ID
-- @param[type=number] _GoodOrEntityType Warentyp oder Entitytyp
-- @within Anwenderfunktionen
--
-- @usage
-- -- Keinen Käse mehr verkaufen
-- API.RemoveTradeOffer(7, Goods.G_Cheese);
--
function API.RemoveTradeOffer(_PlayerID, _GoodOrEntityType)
    if GUI then
        return;
    end
    return ModuleTrade.Global:RemoveTradeOffer(_PlayerID, _GoodOrEntityType);
end

---
-- Ändert die aktuelle Menge des Angebots im Händelrgebäude.
--
-- Es kann ein beliebiger positiver Wert gesetzt werden. Es gibt keine
-- Beschränkungen.
--
-- <b>Hinweis</b>: Wird eine höherer Wert gesetzt, als das ursprüngliche
-- Maximum, regenerieren sich die Angebote nicht, bis die zusätzlichen
-- Angebote verkauft wurden.
--
-- @param[type=number] _PlayerID Player ID
-- @param[type=number] _GoodOrEntityType ID des Händlers im Gebäude
-- @param[type=number] _NewAmount Neue Menge an Angeboten
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel #1: Angebote voll auffüllen
-- API.ModifyTradeOffer(7, Goods.G_Cheese, -1);
--
-- @usage
-- -- Beispiel #2: Angebote auffüllen
-- API.ModifyTradeOffer(7, Goods.G_Dye, 2);
--
function API.ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount)
    if GUI then
        return;
    end
    return ModuleTrade.Global:ModifyTradeOffer(_PlayerID, _GoodOrEntityType, _NewAmount);
end

