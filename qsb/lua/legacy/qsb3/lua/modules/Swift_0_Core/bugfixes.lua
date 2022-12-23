--[[
Swift_0_Core/Bugfixes

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- This portion of the QSB is reserved for fixing bugs in the game.

Swift = Swift or {};
Swift.Bugfix = {};

-- Initalize bugfixes in global env
function Swift.Bugfix:InitalizeBugfixesGlobal()
    self:FixResourceSlotsInStorehouses();
    self:OverrideConstructionCompleteCallback();
    self:OverrideIsMerchantArrived();
end

-- Reload bugfixes after loading in global env
function Swift.Bugfix:GlobalRestoreBugfixesAfterLoad()
end

-- Adds salt and dye to all storehouses. This fixes the problem that luxury
-- can not be sold to AI players.
function Swift.Bugfix:FixResourceSlotsInStorehouses()
    for i= 1, 8 do
        local StoreHouseID = Logic.GetStoreHouse(i);
        if StoreHouseID ~= 0 then
            Logic.AddGoodToStock(StoreHouseID, Goods.G_Salt, 0, true, true);
            Logic.AddGoodToStock(StoreHouseID, Goods.G_Dye, 0, true, true);
        end
    end
end

-- Adds respawning capability to the ME barracks of villages.
function Swift.Bugfix:OverrideConstructionCompleteCallback()
    GameCallback_OnBuildingConstructionComplete_Orig_QSB_Core = GameCallback_OnBuildingConstructionComplete;
    GameCallback_OnBuildingConstructionComplete = function(_PlayerID, _EntityID)
        GameCallback_OnBuildingConstructionComplete_Orig_QSB_Core(_PlayerID, _EntityID);
        local EntityType = Logic.GetEntityType(_EntityID);
        if EntityType == Entities.B_NPC_Barracks_ME then
            Logic.RespawnResourceSetMaxSpawn(_EntityID, 0.01);
            Logic.RespawnResourceSetMinSpawn(_EntityID, 0.01);
        end
    end

    for k, v in pairs(Logic.GetEntitiesOfType(Entities.B_NPC_Barracks_ME)) do
        Logic.RespawnResourceSetMaxSpawn(v, 0.01);
        Logic.RespawnResourceSetMinSpawn(v, 0.01);
    end
end

-- The check if a quest delivery has arrived uses the approach position of
-- the buildings as area center because any cart must pass it before it can
-- enter the building to despawn.
function Swift.Bugfix:OverrideIsMerchantArrived()
    function QuestTemplate:IsMerchantArrived(objective)
        if objective.Data[3] ~= nil then
            if objective.Data[3] == 1 then
                if objective.Data[5].ID ~= nil then
                    objective.Data[3] = objective.Data[5].ID;
                    DeleteQuestMerchantWithID(objective.Data[3]);
                    if MapCallback_DeliverCartSpawned then
                        MapCallback_DeliverCartSpawned(self, objective.Data[3], objective.Data[1]);
                    end
                end
            elseif Logic.IsEntityDestroyed(objective.Data[3]) then
                DeleteQuestMerchantWithID(objective.Data[3]);
                objective.Data[3] = nil;
                objective.Data[5].ID = nil;
            else
                local Target = objective.Data[6] and objective.Data[6] or self.SendingPlayer;
                local StorehouseID = Logic.GetStoreHouse(Target);
                local MarketplaceID = Logic.GetStoreHouse(Target);
                local HeadquartersID = Logic.GetStoreHouse(Target);
                local HasArrived = nil;

                if StorehouseID > 0 then
                    local x,y = Logic.GetBuildingApproachPosition(StorehouseID);
                    HasArrived = API.GetDistance(objective.Data[3], {X= x, Y= y}) < 1000;
                end
                if MarketplaceID > 0 then
                    local x,y = Logic.GetBuildingApproachPosition(MarketplaceID);
                    HasArrived = HasArrived or API.GetDistance(objective.Data[3], {X= x, Y= y}) < 1000;
                end
                if HeadquartersID > 0 then
                    local x,y = Logic.GetBuildingApproachPosition(HeadquartersID);
                    HasArrived = HasArrived or API.GetDistance(objective.Data[3], {X= x, Y= y}) < 1000;
                end
                return HasArrived;
            end
        end
        return false;
    end
end

-- -------------------------------------------------------------------------- --

-- Initalize bugfixes in local env
function Swift.Bugfix:InitalizeBugfixesLocal()
    self:FixInteractiveObjectClicked();
end

-- Reload bugfixes after loading in local env
function Swift.Bugfix:LocalRestoreBugfixesAfterLoad()
end

function Swift.Bugfix:FixInteractiveObjectClicked()
    GUI_Interaction.InteractiveObjectClicked = function()
        local ButtonNumber = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local ObjectID = g_Interaction.ActiveObjectsOnScreen[ButtonNumber];
        if ObjectID == nil or not Logic.InteractiveObjectGetAvailability(ObjectID) then
            return;
        end
        local PlayerID = GUI.GetPlayerID();
        local Costs = {Logic.InteractiveObjectGetEffectiveCosts(ObjectID, PlayerID)};
        local CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources");

        -- Check activation costs
        local Affordable = true;
        if Affordable and Costs ~= nil and Costs[1] ~= nil then
            if Costs[1] == Goods.G_Gold then
                CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_G_Gold");
            end
            if Costs[1] ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(Costs[1]) ~= GoodCategories.GC_Resource then
                error("Only resources can be used as costs for objects!");
                Affordable = false;
            end
            Affordable = Affordable and GetPlayerGoodsInSettlement(Costs[1], PlayerID, false) >= Costs[2];
        end
        if Affordable and Costs ~= nil and Costs[3] ~= nil then
            if Costs[3] == Goods.G_Gold then
                CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_G_Gold");
            end
            if Costs[3] ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(Costs[3]) ~= GoodCategories.GC_Resource then
                error("Only resources can be used as costs for objects!");
                Affordable = false;
            end
            Affordable = Affordable and GetPlayerGoodsInSettlement(Costs[3], PlayerID, false) >= Costs[4];
        end
        if not Affordable then
            Message(CanNotBuyString);
            return;
        end

        -- Check click override
        if not GUI_Interaction.InteractionClickOverride
        or not GUI_Interaction.InteractionClickOverride(ObjectID) then
            Sound.FXPlay2DSound( "ui\\menu_click");
        end
        -- Check feedback speech override
        if not GUI_Interaction.InteractionSpeechFeedbackOverride
        or not GUI_Interaction.InteractionSpeechFeedbackOverride(ObjectID) then
            GUI_FeedbackSpeech.Add("SpeechOnly_CartsSent", g_FeedbackSpeech.Categories.CartsUnderway, nil, nil);
        end
        -- Check action override and perform action
        if not Mission_Callback_OverrideObjectInteraction
        or not Mission_Callback_OverrideObjectInteraction(ObjectID, PlayerID, Costs) then
            GUI.ExecuteObjectInteraction(ObjectID, PlayerID);
        end
    end
end

