--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleKnightTitleRequirements = {
    Properties = {
        Name = "ModuleKnightTitleRequirements",
        Version = "4.0.0 (ALPHA 1.0.0)",
    },

    Global = {};
    Local  = {};

    Shared = {};
};

QSB.RequirementTooltipTypes = {};
QSB.ConsumedGoodsCounter = {};

-- Global Script ------------------------------------------------------------ --

function ModuleKnightTitleRequirements.Global:OnGameStart()
    QSB.ScriptEvents.KnightTitleChanged = API.RegisterScriptEvent("Event_KnightTitleChanged");
    QSB.ScriptEvents.GoodsConsumed = API.RegisterScriptEvent("Event_GoodsConsumed");

    self:OverrideKnightTitleChanged();
    self:OverwriteConsumedGoods();
end

function ModuleKnightTitleRequirements.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.KnightTitleChanged then
        local Consume = QSB.ConsumedGoodsCounter[arg[1]];
        QSB.ConsumedGoodsCounter[arg[1]] = Consume or {};
        for k,v in pairs(QSB.ConsumedGoodsCounter[arg[1]]) do
            QSB.ConsumedGoodsCounter[arg[1]][k] = 0;
        end
    elseif _ID == QSB.ScriptEvents.GoodsConsumed then
        local PlayerID = Logic.EntityGetPlayer(arg[1]);
        self:RegisterConsumedGoods(PlayerID, arg[2]);
    end
end

function ModuleKnightTitleRequirements.Global:RegisterConsumedGoods(_PlayerID, _Good)
    QSB.ConsumedGoodsCounter[_PlayerID]        = QSB.ConsumedGoodsCounter[_PlayerID] or {};
    QSB.ConsumedGoodsCounter[_PlayerID][_Good] = QSB.ConsumedGoodsCounter[_PlayerID][_Good] or 0;
    QSB.ConsumedGoodsCounter[_PlayerID][_Good] = QSB.ConsumedGoodsCounter[_PlayerID][_Good] +1;
end

function ModuleKnightTitleRequirements.Global:OverrideKnightTitleChanged()
    GameCallback_KnightTitleChanged_Orig_QSB_Requirements = GameCallback_KnightTitleChanged;
    GameCallback_KnightTitleChanged = function(_PlayerID, _TitleID)
        GameCallback_KnightTitleChanged_Orig_QSB_Requirements(_PlayerID, _TitleID);

        -- Send event
        API.SendScriptEvent(QSB.ScriptEvents.KnightTitleChanged, _PlayerID, _TitleID);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.KnightTitleChanged, %d, %d)]],
            _PlayerID, _TitleID
        ));
    end
end

function ModuleKnightTitleRequirements.Global:OverwriteConsumedGoods()
    GameCallback_ConsumeGood_Orig_QSB_Requirements = GameCallback_ConsumeGood;
    GameCallback_ConsumeGood = function(_Consumer, _Good, _Building)
        GameCallback_ConsumeGood_Orig_QSB_Requirements(_Consumer, _Good, _Building)

        -- Send event
        API.SendScriptEvent(QSB.ScriptEvents.GoodsConsumed, _Consumer, _Good, _Building);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.GoodsConsumed, %d, %d, %d)]],
            _Consumer, _Good, _Building
        ));
    end
end

-- Local Script ------------------------------------------------------------- --

function ModuleKnightTitleRequirements.Local:OnGameStart()
    QSB.ScriptEvents.KnightTitleChanged = API.RegisterScriptEvent("Event_KnightTitleChanged");
    QSB.ScriptEvents.GoodsConsumed = API.RegisterScriptEvent("Event_GoodsConsumed");

    self:OverwriteTooltips();
    self:InitTexturePositions();
    self:OverwriteUpdateRequirements();
end

function ModuleKnightTitleRequirements.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.KnightTitleChanged then
        local Consume = QSB.ConsumedGoodsCounter[arg[1]];
        QSB.ConsumedGoodsCounter[arg[1]] = Consume or {};
        for k,v in pairs(QSB.ConsumedGoodsCounter[arg[1]]) do
            QSB.ConsumedGoodsCounter[arg[1]][k] = 0;
        end
    elseif _ID == QSB.ScriptEvents.GoodsConsumed then
        local PlayerID = Logic.EntityGetPlayer(arg[1]);
        self:RegisterConsumedGoods(PlayerID, arg[2]);
    end
end

function ModuleKnightTitleRequirements.Local:RegisterConsumedGoods(_PlayerID, _Good)
    QSB.ConsumedGoodsCounter[_PlayerID]        = QSB.ConsumedGoodsCounter[_PlayerID] or {};
    QSB.ConsumedGoodsCounter[_PlayerID][_Good] = QSB.ConsumedGoodsCounter[_PlayerID][_Good] or 0;
    QSB.ConsumedGoodsCounter[_PlayerID][_Good] = QSB.ConsumedGoodsCounter[_PlayerID][_Good] +1;
end

function ModuleKnightTitleRequirements.Local:InitTexturePositions()
    g_TexturePositions.EntityCategories[EntityCategories.GC_Food_Supplier]          = { 1, 1};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Clothes_Supplier]       = { 1, 2};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Hygiene_Supplier]       = {16, 1};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Entertainment_Supplier] = { 1, 4};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Luxury_Supplier]        = {16, 3};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Weapon_Supplier]        = { 1, 7};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Medicine_Supplier]      = { 2,10};
    g_TexturePositions.EntityCategories[EntityCategories.Outpost]                   = {12, 3};
    g_TexturePositions.EntityCategories[EntityCategories.Spouse]                    = { 5,15};
    g_TexturePositions.EntityCategories[EntityCategories.CattlePasture]             = { 3,16};
    g_TexturePositions.EntityCategories[EntityCategories.SheepPasture]              = { 4, 1};
    g_TexturePositions.EntityCategories[EntityCategories.Soldier]                   = { 7,12};
    g_TexturePositions.EntityCategories[EntityCategories.GrainField]                = {14, 2};
    g_TexturePositions.EntityCategories[EntityCategories.BeeHive]                   = { 2, 1};
    g_TexturePositions.EntityCategories[EntityCategories.OuterRimBuilding]          = { 3, 4};
    g_TexturePositions.EntityCategories[EntityCategories.CityBuilding]              = { 8, 1};
    g_TexturePositions.EntityCategories[EntityCategories.Leader]                    = { 7, 11};
    g_TexturePositions.EntityCategories[EntityCategories.Range]                     = { 9, 8};
    g_TexturePositions.EntityCategories[EntityCategories.Melee]                     = { 9, 7};
    g_TexturePositions.EntityCategories[EntityCategories.SiegeEngine]               = { 2,15};

    g_TexturePositions.Entities[Entities.B_Beehive]                                 = { 2, 1};
    g_TexturePositions.Entities[Entities.B_Cathedral_Big]                           = { 3,12};
    g_TexturePositions.Entities[Entities.B_CattlePasture]                           = { 3,16};
    g_TexturePositions.Entities[Entities.B_GrainField_ME]                           = { 1,13};
    g_TexturePositions.Entities[Entities.B_GrainField_NA]                           = { 1,13};
    g_TexturePositions.Entities[Entities.B_GrainField_NE]                           = { 1,13};
    g_TexturePositions.Entities[Entities.B_GrainField_SE]                           = { 1,13};
    g_TexturePositions.Entities[Entities.U_MilitaryBallista]                        = {10, 5};
    g_TexturePositions.Entities[Entities.B_Outpost]                                 = {12, 3};
    g_TexturePositions.Entities[Entities.B_Outpost_ME]                              = {12, 3};
    g_TexturePositions.Entities[Entities.B_Outpost_NA]                              = {12, 3};
    g_TexturePositions.Entities[Entities.B_Outpost_NE]                              = {12, 3};
    g_TexturePositions.Entities[Entities.B_Outpost_SE]                              = {12, 3};
    g_TexturePositions.Entities[Entities.B_SheepPasture]                            = { 4, 1};
    g_TexturePositions.Entities[Entities.U_SiegeEngineCart]                         = { 9, 4};
    g_TexturePositions.Entities[Entities.U_Trebuchet]                               = { 9, 1};
    if Framework.GetGameExtraNo() ~= 0 then
        g_TexturePositions.Entities[Entities.B_GrainField_AS]                       = { 1,13};
        g_TexturePositions.Entities[Entities.B_Outpost_AS]                          = {12, 3};
    end

    g_TexturePositions.Needs[Needs.Medicine]                                        = { 2,10};

    g_TexturePositions.Technologies[Technologies.R_Castle_Upgrade_1]                = { 4, 7};
    g_TexturePositions.Technologies[Technologies.R_Castle_Upgrade_2]                = { 4, 7};
    g_TexturePositions.Technologies[Technologies.R_Castle_Upgrade_3]                = { 4, 7};
    g_TexturePositions.Technologies[Technologies.R_Cathedral_Upgrade_1]             = { 4, 5};
    g_TexturePositions.Technologies[Technologies.R_Cathedral_Upgrade_2]             = { 4, 5};
    g_TexturePositions.Technologies[Technologies.R_Cathedral_Upgrade_3]             = { 4, 5};
    g_TexturePositions.Technologies[Technologies.R_Storehouse_Upgrade_1]            = { 4, 6};
    g_TexturePositions.Technologies[Technologies.R_Storehouse_Upgrade_2]            = { 4, 6};
    g_TexturePositions.Technologies[Technologies.R_Storehouse_Upgrade_3]            = { 4, 6};

    g_TexturePositions.Buffs = g_TexturePositions.Buffs or {};

    g_TexturePositions.Buffs[Buffs.Buff_ClothesDiversity]                           = { 1, 2};
    g_TexturePositions.Buffs[Buffs.Buff_EntertainmentDiversity]                     = { 1, 4};
    g_TexturePositions.Buffs[Buffs.Buff_FoodDiversity]                              = { 1, 1};
    g_TexturePositions.Buffs[Buffs.Buff_HygieneDiversity]                           = { 1, 3};
    g_TexturePositions.Buffs[Buffs.Buff_Colour]                                     = { 5,11};
    g_TexturePositions.Buffs[Buffs.Buff_Entertainers]                               = { 5,12};
    g_TexturePositions.Buffs[Buffs.Buff_ExtraPayment]                               = { 1, 8};
    g_TexturePositions.Buffs[Buffs.Buff_Sermon]                                     = { 4,14};
    g_TexturePositions.Buffs[Buffs.Buff_Spice]                                      = { 5,10};
    g_TexturePositions.Buffs[Buffs.Buff_NoTaxes]                                    = { 1, 6};
    if Framework.GetGameExtraNo() ~= 0 then
        g_TexturePositions.Buffs[Buffs.Buff_Gems]                                   = { 1, 1, 1};
        g_TexturePositions.Buffs[Buffs.Buff_MusicalInstrument]                      = { 1, 3, 1};
        g_TexturePositions.Buffs[Buffs.Buff_Olibanum]                               = { 1, 2, 1};
    end

    g_TexturePositions.GoodCategories = g_TexturePositions.GoodCategories or {};

    g_TexturePositions.GoodCategories[GoodCategories.GC_Ammunition]                 = {10, 6};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Animal]                     = { 4,16};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Clothes]                    = { 1, 2};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Document]                   = { 5, 6};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Entertainment]              = { 1, 4};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Food]                       = { 1, 1};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Gold]                       = { 1, 8};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Hygiene]                    = {16, 1};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Luxury]                     = {16, 3};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Medicine]                   = { 2,10};
    g_TexturePositions.GoodCategories[GoodCategories.GC_None]                       = {15,16};
    g_TexturePositions.GoodCategories[GoodCategories.GC_RawFood]                    = { 3, 4};
    g_TexturePositions.GoodCategories[GoodCategories.GC_RawMedicine]                = { 2, 2};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Research]                   = { 5, 6};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Resource]                   = { 3, 4};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Tools]                      = { 4,12};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Water]                      = { 1,16};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Weapon]                     = { 8, 5};
end

function ModuleKnightTitleRequirements.Local:OverwriteUpdateRequirements()
    GUI_Knight.UpdateRequirements = function()
        local WidgetPos = ModuleKnightTitleRequirements.Local.RequirementWidgets;
        local RequirementsIndex = 1;

        local PlayerID = GUI.GetPlayerID();
        local CurrentTitle = Logic.GetKnightTitle(PlayerID);
        local NextTitle = CurrentTitle + 1;

        -- Headline
        local KnightID = Logic.GetKnightID(PlayerID);
        local KnightType = Logic.GetEntityType(KnightID);
        XGUIEng.SetText("/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/NextKnightTitle", "{center}" .. GUI_Knight.GetTitleNameByTitleID(KnightType, NextTitle));
        XGUIEng.SetText("/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/NextKnightTitleWhite", "{center}" .. GUI_Knight.GetTitleNameByTitleID(KnightType, NextTitle));

        -- show Settlers
        if KnightTitleRequirements[NextTitle].Settlers ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {5,16})
            local IsFulfilled, CurrentAmount, NeededAmount = DoesNeededNumberOfSettlersForKnightTitleExist(PlayerID, NextTitle)
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount)
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1)
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0)
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1)

            QSB.RequirementTooltipTypes[RequirementsIndex] = "Settlers";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- show rich buildings
        if KnightTitleRequirements[NextTitle].RichBuildings ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {8,4});
            local IsFulfilled, CurrentAmount, NeededAmount = DoNeededNumberOfRichBuildingsForKnightTitleExist(PlayerID, NextTitle);
            if NeededAmount == -1 then
                NeededAmount = Logic.GetNumberOfPlayerEntitiesInCategory(PlayerID, EntityCategories.CityBuilding);
            end
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "RichBuildings";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Castle
        if KnightTitleRequirements[NextTitle].Headquarters ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {4,7});
            local IsFulfilled, CurrentAmount, NeededAmount = DoNeededSpecialBuildingUpgradeForKnightTitleExist(PlayerID, NextTitle, EntityCategories.Headquarters);
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount + 1 .. "/" .. NeededAmount + 1);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "Headquarters";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Storehouse
        if KnightTitleRequirements[NextTitle].Storehouse ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {4,6});
            local IsFulfilled, CurrentAmount, NeededAmount = DoNeededSpecialBuildingUpgradeForKnightTitleExist(PlayerID, NextTitle, EntityCategories.Storehouse);
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount + 1 .. "/" .. NeededAmount + 1);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "Storehouse";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Cathedral
        if KnightTitleRequirements[NextTitle].Cathedrals ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {4,5});
            local IsFulfilled, CurrentAmount, NeededAmount = DoNeededSpecialBuildingUpgradeForKnightTitleExist(PlayerID, NextTitle, EntityCategories.Cathedrals);
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount + 1 .. "/" .. NeededAmount + 1);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "Cathedrals";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Volldekorierte Gebäude
        if KnightTitleRequirements[NextTitle].FullDecoratedBuildings ~= nil then
            local IsFulfilled, CurrentAmount, NeededAmount = DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist(PlayerID, NextTitle);
            local EntityCategory = KnightTitleRequirements[NextTitle].FullDecoratedBuildings;
            SetIcon(WidgetPos[RequirementsIndex].."/Icon"  , g_TexturePositions.Needs[Needs.Wealth]);

            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] , 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "FullDecoratedBuildings";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Stadtruf
        if KnightTitleRequirements[NextTitle].Reputation ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {5,14});
            local IsFulfilled, CurrentAmount, NeededAmount = DoesNeededCityReputationForKnightTitleExist(PlayerID, NextTitle);
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "Reputation";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Güter sammeln
        if KnightTitleRequirements[NextTitle].Goods ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Goods do
                local GoodType = KnightTitleRequirements[NextTitle].Goods[i][1];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.Goods[GoodType]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoesNeededNumberOfGoodTypesForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Goods" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Kategorien
        if KnightTitleRequirements[NextTitle].Category ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Category do
                local Category = KnightTitleRequirements[NextTitle].Category[i][1];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.EntityCategories[Category]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                local EntitiesInCategory = {Logic.GetEntityTypesInCategory(Category)};
                if Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.GC_Weapon_Supplier) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Weapons" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.SiegeEngine) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "HeavyWeapons" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.Spouse) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Spouse" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.Worker) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Worker" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.Soldier) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Soldiers" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.Leader) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Leader" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.Outpost) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Outposts" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.CattlePasture) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Cattle" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.SheepPasture) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Sheep" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.CityBuilding) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "CityBuilding" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.OuterRimBuilding) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "OuterRimBuilding" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.GrainField) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "FarmerBuilding" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.BeeHive) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "FarmerBuilding" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.AttackableBuilding) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Buildings" .. i;
                else
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "EntityCategoryDefault" .. i;
                end
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Entities
        if KnightTitleRequirements[NextTitle].Entities ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Entities do
                local EntityType = KnightTitleRequirements[NextTitle].Entities[i][1];
                local EntityTypeName = Logic.GetEntityTypeName(EntityType);
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.Entities[EntityType]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                local TopltipType = "Entities" .. i;
                if EntityTypeName == "B_Beehive" or EntityTypeName:find("GrainField") or EntityTypeName:find("Pasture") then
                    TopltipType = "FarmerBuilding" .. i;
                end
                QSB.RequirementTooltipTypes[RequirementsIndex] = TopltipType;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Güter konsumieren
        if KnightTitleRequirements[NextTitle].Consume ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Consume do
                local GoodType = KnightTitleRequirements[NextTitle].Consume[i][1];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.Goods[GoodType]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoNeededNumberOfConsumedGoodsForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Consume" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Güter aus Gruppe produzieren
        if KnightTitleRequirements[NextTitle].Products ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Products do
                local Product = KnightTitleRequirements[NextTitle].Products[i][1];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.GoodCategories[Product]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoNumberOfProductsInCategoryExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Products" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Bonus aktivieren
        if KnightTitleRequirements[NextTitle].Buff ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Buff do
                local Buff = KnightTitleRequirements[NextTitle].Buff[i];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.Buffs[Buff]);
                local IsFulfilled = DoNeededDiversityBuffForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "");
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Buff" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Selbstdefinierte Bedingung
        if KnightTitleRequirements[NextTitle].Custom ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Custom do
                local FileBaseName;
                local Icon = table.copy(KnightTitleRequirements[NextTitle].Custom[i][2]);
                if type(Icon[3]) == "string" then
                    FileBaseName = Icon[3];
                    Icon[3] = 0;
                end
                API.SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", Icon, nil, FileBaseName);
                local IsFulfilled, CurrentAmount, NeededAmount = DoCustomFunctionForKnightTitleSucceed(PlayerID, NextTitle, i);
                if CurrentAmount and NeededAmount then
                    XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                else
                    XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "");
                end
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Custom" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Dekorationselemente
        if KnightTitleRequirements[NextTitle].DecoratedBuildings ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].DecoratedBuildings do
                local GoodType = KnightTitleRequirements[NextTitle].DecoratedBuildings[i][1];
                SetIcon(WidgetPos[RequirementsIndex].."/Icon", g_TexturePositions.Goods[GoodType]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoNeededNumberOfDecoratedBuildingsForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "DecoratedBuildings" ..i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Übrige ausblenden
        for i=RequirementsIndex, 6 do
            XGUIEng.ShowWidget(WidgetPos[i], 0);
        end
    end
end

function ModuleKnightTitleRequirements.Local:OverwriteTooltips()
    GUI_Tooltip.SetNameAndDescription_Orig_QSB_Requirements = GUI_Tooltip.SetNameAndDescription;
    GUI_Tooltip.SetNameAndDescription = function(_TooltipNameWidget, _TooltipDescriptionWidget, _OptionalTextKeyName, _OptionalDisabledTextKeyName, _OptionalMissionTextFileBoolean)
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local Selected = GUI.GetSelectedEntity();
        local PlayerID = GUI.GetPlayerID();

        for k,v in pairs(ModuleKnightTitleRequirements.Local.RequirementWidgets) do
            if v .. "/Icon" == XGUIEng.GetWidgetPathByID(CurrentWidgetID) then
                local key = QSB.RequirementTooltipTypes[k];
                local num = tonumber(string.sub(key, string.len(key)));
                if num ~= nil then
                    key = string.sub(key, 1, string.len(key)-1);
                end
                ModuleKnightTitleRequirements.Local:RequirementTooltipWrapped(key, num);
                return;
            end
        end
        GUI_Tooltip.SetNameAndDescription_Orig_QSB_Requirements(_TooltipNameWidget, _TooltipDescriptionWidget, _OptionalTextKeyName, _OptionalDisabledTextKeyName, _OptionalMissionTextFileBoolean);
    end

    GUI_Knight.RequiredGoodTooltip = function()
        local key = QSB.RequirementTooltipTypes[2];
        local num = tonumber(string.sub(key, string.len(key)));
        if num ~= nil then
            key = string.sub(key, 1, string.len(key)-1);
        end
        ModuleKnightTitleRequirements.Local:RequirementTooltipWrapped(key, num);
    end

    if Framework.GetGameExtraNo() ~= 0 then
        ModuleKnightTitleRequirements.Local.BuffTypeNames[Buffs.Buff_Gems] = {
            de = "Edelsteine beschaffen",
            en = "Obtain gems",
            fr = "Se procurer des Gemmes",
        }
        ModuleKnightTitleRequirements.Local.BuffTypeNames[Buffs.Buff_Olibanum] = {
            de = "Weihrauch beschaffen",
            en = "Obtain olibanum",
            fr = "Se procurer de l'encens",
        }
        ModuleKnightTitleRequirements.Local.BuffTypeNames[Buffs.Buff_MusicalInstrument] = {
            de = "Muskinstrumente beschaffen",
            en = "Obtain instruments",
            fr = "Se procurer des instruments de musique",
        }
    end
end

function ModuleKnightTitleRequirements.Local:RequirementTooltipWrapped(_key, _i)
    local PlayerID = GUI.GetPlayerID();
    local KnightTitle = Logic.GetKnightTitle(PlayerID);
    local Title = ""
    local Text = "";

    if _key == "Consume" or _key == "Goods" or _key == "DecoratedBuildings" then
        local GoodType     = KnightTitleRequirements[KnightTitle+1][_key][_i][1];
        local GoodTypeName = Logic.GetGoodTypeName(GoodType);
        local GoodName     = XGUIEng.GetStringTableText("UI_ObjectNames/" .. GoodTypeName);

        if GoodName == nil then
            GoodName = "Goods." .. GoodTypeName;
        end
        Title = GoodName;
        Text  = ModuleKnightTitleRequirements.Local.Description[_key].Text;

    elseif _key == "Products" then
        local GoodCategoryNames = ModuleKnightTitleRequirements.Local.GoodCategoryNames;
        local Category = KnightTitleRequirements[KnightTitle+1][_key][_i][1];
        local CategoryName = API.Localize(GoodCategoryNames[Category]);

        if CategoryName == nil then
            CategoryName = "ERROR: Name missng!";
        end
        Title = CategoryName;
        Text  = ModuleKnightTitleRequirements.Local.Description[_key].Text;

    elseif _key == "Entities" then
        local EntityType     = KnightTitleRequirements[KnightTitle+1][_key][_i][1];
        local EntityTypeName = Logic.GetEntityTypeName(EntityType);
        local EntityName = XGUIEng.GetStringTableText("Names/" .. EntityTypeName);

        if EntityName == nil then
            EntityName = "Entities." .. EntityTypeName;
        end

        Title = EntityName;
        Text  = ModuleKnightTitleRequirements.Local.Description[_key].Text;

    elseif _key == "Custom" then
        local Custom = KnightTitleRequirements[KnightTitle+1].Custom[_i];
        Title = Custom[3];
        Text  = Custom[4];

    elseif _key == "Buff" then
        local BuffTypeNames = ModuleKnightTitleRequirements.Local.BuffTypeNames;
        local BuffType = KnightTitleRequirements[KnightTitle+1][_key][_i];
        local BuffTitle = API.Localize(BuffTypeNames[BuffType]);

        if BuffTitle == nil then
            BuffTitle = "ERROR: Name missng!";
        end
        Title = BuffTitle;
        Text  = ModuleKnightTitleRequirements.Local.Description[_key].Text;

    else
        Title = ModuleKnightTitleRequirements.Local.Description[_key].Title;
        Text  = ModuleKnightTitleRequirements.Local.Description[_key].Text;
    end
    API.SetTooltipNormal(API.Localize(Title), API.Localize(Text), nil);
end

-- -------------------------------------------------------------------------- --

ModuleKnightTitleRequirements.Local.RequirementWidgets = {
    [1] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Settlers",
    [2] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Goods",
    [3] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/RichBuildings",
    [4] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Castle",
    [5] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Storehouse",
    [6] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Cathedral",
};

ModuleKnightTitleRequirements.Local.GoodCategoryNames = {
    [GoodCategories.GC_Ammunition]      = {de = "Munition",         en = "Ammunition",      fr = "Munition"},
    [GoodCategories.GC_Animal]          = {de = "Nutztiere",        en = "Livestock",       fr = "Animaux d'élevage"},
    [GoodCategories.GC_Clothes]         = {de = "Kleidung",         en = "Clothes",         fr = "Vêtements"},
    [GoodCategories.GC_Document]        = {de = "Dokumente",        en = "Documents",       fr = "Documents"},
    [GoodCategories.GC_Entertainment]   = {de = "Unterhaltung",     en = "Entertainment",   fr = "Divertissement"},
    [GoodCategories.GC_Food]            = {de = "Nahrungsmittel",   en = "Food",            fr = "Nourriture"},
    [GoodCategories.GC_Gold]            = {de = "Gold",             en = "Gold",            fr = "Or"},
    [GoodCategories.GC_Hygiene]         = {de = "Hygieneartikel",   en = "Hygiene",         fr = "Hygiène"},
    [GoodCategories.GC_Luxury]          = {de = "Dekoration",       en = "Decoration",      fr = "Décoration"},
    [GoodCategories.GC_Medicine]        = {de = "Medizin",          en = "Medicine",        fr = "Médecine"},
    [GoodCategories.GC_None]            = {de = "Nichts",           en = "None",            fr = "Rien"},
    [GoodCategories.GC_RawFood]         = {de = "Nahrungsmittel",   en = "Food",            fr = "Nourriture"},
    [GoodCategories.GC_RawMedicine]     = {de = "Medizin",          en = "Medicine",        fr = "Médecine"},
    [GoodCategories.GC_Research]        = {de = "Forschung",        en = "Research",        fr = "Recherche"},
    [GoodCategories.GC_Resource]        = {de = "Rohstoffe",        en = "Resource",        fr = "Ressources"},
    [GoodCategories.GC_Tools]           = {de = "Werkzeug",         en = "Tools",           fr = "Outils"},
    [GoodCategories.GC_Water]           = {de = "Wasser",           en = "Water",           fr = "Eau"},
    [GoodCategories.GC_Weapon]          = {de = "Waffen",           en = "Weapon",          fr = "Armes"},
};

ModuleKnightTitleRequirements.Local.BuffTypeNames = {
    [Buffs.Buff_ClothesDiversity]        = {de = "Vielfältige Kleidung",        en = "Clothes variety",         fr = "Diversité vestimentaire"},
    [Buffs.Buff_Colour]                  = {de = "Farben beschaffen",           en = "Obtain color",            fr = "Se procurer des couleurs"},
    [Buffs.Buff_Entertainers]            = {de = "Gaukler anheuern",            en = "Hire entertainer",        fr = "Engager des saltimbanques"},
    [Buffs.Buff_EntertainmentDiversity]  = {de = "Vielfältige Unterhaltung",    en = "Entertainment variety",   fr = "Diversité des divertissements"},
    [Buffs.Buff_ExtraPayment]            = {de = "Sonderzahlung",               en = "Extra payment",           fr = "Paiement supplémentaire"},
    [Buffs.Buff_Festival]                = {de = "Fest veranstalten",           en = "Hold Festival",           fr = "Organiser une fête"},
    [Buffs.Buff_FoodDiversity]           = {de = "Vielfältige Nahrung",         en = "Food variety",            fr = "Diversité alimentaire"},
    [Buffs.Buff_HygieneDiversity]        = {de = "Vielfältige Hygiene",         en = "Hygiene variety",         fr = "Diversité hygiénique"},
    [Buffs.Buff_NoTaxes]                 = {de = "Steuerbefreiung",             en = "No taxes",                fr = "Exonération fiscale"},
    [Buffs.Buff_Sermon]                  = {de = "Pregigt abhalten",            en = "Hold sermon",             fr = "Tenir des prêches"},
    [Buffs.Buff_Spice]                   = {de = "Salz beschaffen",             en = "Obtain salt",             fr = "Se procurer du sel"},
};

ModuleKnightTitleRequirements.Local.Description = {
    Settlers = {
        Title = {
            de = "Benötigte Siedler",
            en = "Needed settlers",
            fr = "Settlers nécessaires",
        },
        Text = {
            de = "- Benötigte Menge an Siedlern",
            en = "- Needed number of settlers",
            fr = "- Quantité de settlers nécessaire",
        },
    },

    RichBuildings = {
        Title = {
            de = "Reiche Häuser",
            en = "Rich city buildings",
            fr = "Bâtiments riches",
        },
        Text = {
            de = "- Menge an reichen Stadtgebäuden",
            en = "- Needed amount of rich city buildings",
            fr = "- Quantité de bâtiments de la ville riches",
        },
    },

    Goods = {
        Title = {
            de = "Waren lagern",
            en = "Store Goods",
            fr = "Entreposer des marchandises",
        },
        Text = {
            de = "- Benötigte Menge",
            en = "- Needed amount",
            fr = "- Quantité nécessaire",
        },
    },

    FullDecoratedBuildings = {
        Title = {
            de = "Dekorierte Häuser",
            en = "Decorated City buildings",
            fr = "Bâtiments décorés",
        },
        Text = {
            de = "- Menge an voll dekorierten Gebäuden",
            en = "- Amount of full decoraded city buildings",
            fr = "- Quantité de bâtiments entièrement décorés",
        },
    },

    DecoratedBuildings = {
        Title = {
            de = "Dekoration",
            en = "Decoration",
            fr = "Décoration",
        },
        Text = {
            de = "- Menge an Dekorationsgütern in der Siedlung",
            en = "- Amount of decoration goods in settlement",
            fr = "- Quantité de biens de décoration dans la ville",
        },
    },

    Headquarters = {
        Title = {
            de = "Burgstufe",
            en = "Castle level",
            fr = "Niveau du château",
        },
        Text = {
            de = "- Benötigte Ausbauten der Burg",
            en = "- Needed castle upgrades",
            fr = "- Améliorations nécessaires du château",
        },
    },

    Storehouse = {
        Title = {
            de = "Lagerhausstufe",
            en = "Storehouse level",
            fr = "Niveau de l'entrepôt",
        },
        Text = {
            de = "- Benötigte Ausbauten des Lagerhauses",
            en = "- Needed storehouse upgrades",
            fr = "- Améliorations nécessaires de l'entrepôt",
        },
    },

    Cathedrals = {
        Title = {
            de = "Kirchenstufe",
            en = "Cathedral level",
            fr = "Niveau de la cathédrale",
        },
        Text = {
            de = "- Benötigte Ausbauten der Kirche",
            en = "- Needed cathedral upgrades",
            fr = "- Améliorations nécessaires de la cathédrale",
        },
    },

    Reputation = {
        Title = {
            de = "Ruf der Stadt",
            en = "City reputation",
            fr = "Réputation de la ville",
        },
        Text = {
            de = "- Benötigter Ruf der Stadt",
            en = "- Needed city reputation",
            fr = "- Réputation de la ville nécessaire",
        },
    },

    EntityCategoryDefault = {
        Title = {
            de = "",
            en = "",
            fr = "",
        },
        Text = {
            de = "- Benötigte Anzahl",
            en = "- Needed amount",
            fr = "- Nombre requis",
        },
    },

    Cattle = {
        Title = {
            de = "Kühe",
            en = "Cattle",
            fr = "Vaches",
        },
        Text = {
            de = "- Benötigte Menge an Kühen",
            en = "- Needed amount of cattle",
            fr = "- Quantité de vaches nécessaire",
        },
    },

    Sheep = {
        Title = {
            de = "Schafe",
            en = "Sheeps",
            fr = "Moutons",
        },
        Text = {
            de = "- Benötigte Menge an Schafen",
            en = "- Needed amount of sheeps",
            fr = "- Quantité de moutons nécessaire",
        },
    },

    Outposts = {
        Title = {
            de = "Territorien",
            en = "Territories",
            fr = "Territoires",
        },
        Text = {
            de = "- Zu erobernde Territorien",
            en = "- Territories to claim",
            fr = "- Territoires à conquérir",
        },
    },

    CityBuilding = {
        Title = {
            de = "Stadtgebäude",
            en = "City buildings",
            fr = "Bâtiment de la ville",
        },
        Text = {
            de = "- Menge benötigter Stadtgebäude",
            en = "- Needed amount of city buildings",
            fr = "- Quantité de bâtiments urbains nécessaires",
        },
    },

    OuterRimBuilding = {
        Title = {
            de = "Rohstoffgebäude",
            en = "Gatherer",
            fr = "Cueilleur",
        },
        Text = {
            de = "- Menge benötigter Rohstoffgebäude",
            en = "- Needed amount of gatherer",
            fr = "- Quantité de bâtiments de matières premières nécessaires",
        },
    },

    FarmerBuilding = {
        Title = {
            de = "Farmeinrichtungen",
            en = "Farming structure",
            fr = "Installations de la ferme",
        },
        Text = {
            de = "- Menge benötigter Nutzfläche",
            en = "- Needed amount of farming structure",
            fr = "- Quantité de surface utile nécessaire",
        },
    },

    Consume = {
        Title = {
            de = "",
            en = "",
            fr = "",
        },
        Text = {
            de = "- Durch Siedler zu konsumierende Menge",
            en = "- Amount to be consumed by the settlers",
            fr = "- Quantité à consommer par les settlers",
        },
    },

    Products = {
        Title = {
            de = "",
            en = "",
            fr = "",
        },
        Text = {
            de = "- Benötigte Menge",
            en = "- Needed amount",
            fr = "- Quantité nécessaire",
        },
    },

    Buff = {
        Title = {
            de = "Bonus aktivieren",
            en = "Activate Buff",
            fr = "Activer bonus",
        },
        Text = {
            de = "- Aktiviere diesen Bonus auf den Ruf der Stadt",
            en = "- Raise the city reputatition with this buff",
            fr = "- Active ce bonus sur la réputation de la ville",
        },
    },

    Leader = {
        Title = {
            de = "Batalione",
            en = "Battalions",
            fr = "Battalions",
        },
        Text = {
            de = "- Menge an Batalionen unterhalten",
            en = "- Battalions you need under your command",
            fr = "- Maintenir une quantité de bataillons",
        },
    },

    Soldiers = {
        Title = {
            de = "Soldaten",
            en = "Soldiers",
            fr = "Soldats",
        },
        Text = {
            de = "- Menge an Streitkräften unterhalten",
            en = "- Soldiers you need under your command",
            fr = "- Maintenir une quantité de forces armées",
        },
    },

    Worker = {
        Title = {
            de = "Arbeiter",
            en = "Workers",
            fr = "Travailleurs",
        },
        Text = {
            de = "- Menge an arbeitender Bevölkerung",
            en = "- Workers you need under your reign",
            fr = "- Quantité de population au travail",
        },
    },

    Entities = {
        Title = {
            de = "",
            en = "",
            fr = "",
        },
        Text = {
            de = "- Benötigte Menge",
            en = "- Needed Amount",
            fr = "- Quantité nécessaire",
        },
    },

    Buildings = {
        Title = {
            de = "Gebäude",
            en = "Buildings",
            fr = "Bâtiments",
        },
        Text = {
            de = "- Gesamtmenge an Gebäuden",
            en = "- Amount of buildings",
            fr = "- Total des bâtiments",
        },
    },

    Weapons = {
        Title = {
            de = "Waffen",
            en = "Weapons",
            fr = "Armes",
        },
        Text = {
            de = "- Benötigte Menge an Waffen",
            en = "- Needed amount of weapons",
            fr = "- Quantité d'armes nécessaire",
        },
    },

    HeavyWeapons = {
        Title = {
            de = "Belagerungsgeräte",
            en = "Siege Engines",
            fr = "Matériel de siège",
        },
        Text = {
            de = "- Benötigte Menge an Belagerungsgeräten",
            en = "- Needed amount of siege engine",
            fr = "- Quantité de matériel de siège nécessaire",
        },
    },

    Spouse = {
        Title = {
            de = "Ehefrauen",
            en = "Spouses",
            fr = "Épouses",
        },
        Text = {
            de = "- Benötigte Anzahl Ehefrauen in der Stadt",
            en = "- Needed amount of spouses in your city",
            fr = "- Nombre d'épouses nécessaires dans la ville",
        },
    },
};

-- -------------------------------------------------------------------------- --

Revision:RegisterModule(ModuleKnightTitleRequirements);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ermöglicht das Anpassen der Aufstiegsbedingungen.
--
-- Die Aufstiegsbedingungen werden in der Funktion InitKnightTitleTables
-- angegeben und bearbeitet.
--
-- <b>Achtung</b>: es können maximal 6 Bedingungen angezeigt werden!
--
-- <p>Mögliche Aufstiegsbedingungen:
-- <ul>
-- <li><b>Entitytyp besitzen</b><br/>
-- Der Spieler muss eine bestimmte Anzahl von Entities eines Typs besitzen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Entities = {
--     {Entities.B_Bakery, 2},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Entitykategorie besitzen</b><br/>
-- Der Spieler muss eine bestimmte Anzahl von Entities einer Kategorie besitzen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Category = {
--     {EntitiyCategories.CattlePasture, 10},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Gütertyp besitzen</b><br/>
-- Der Spieler muss Rohstoffe oder Güter eines Typs besitzen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Goods = {
--     {Goods.G_RawFish, 35},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Produkte erzeugen</b><br/>
-- Der Spieler muss Gebrauchsgegenstände für ein Bedürfnis bereitstellen. Hier
-- werden nicht die Warentypen sonderen deren Kategorie angegeben.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Products = {
--     {GoodCategories.GC_Clothes, 6},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Güter konsumieren</b><br/>
-- Die Siedler müssen eine Menge einer bestimmten Waren konsumieren.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Consume = {
--     {Goods.G_Bread, 30},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Buffs aktivieren</b><br/>
-- Der Spieler muss einen Buff aktivieren.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Buff = {
--     Buffs.Buff_FoodDiversity,
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Stadtruf erreichen</b><br/>
-- Der Ruf der Stadt muss einen bestimmten Wert erreichen oder überschreiten.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Reputation = 20
-- </code></pre>
--
-- <li><b>Anzahl an Dekorationen</b><br/>
-- Der Spieler muss mindestens die Anzahl der angegebenen Dekoration besitzen.
-- <code><pre>
-- KnightTitleRequirements[KnightTitles.Mayor].DecoratedBuildings = {
--     {Goods.G_Banner, 9 },
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Anzahl voll dekorierter Gebäude</b><br/>
-- Anzahl an Gebäuden, an die alle vier Dekorationen angebracht sein müssen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].FullDecoratedBuildings = 12
-- </code></pre>
-- </li>
--
-- <li><b>Spezialgebäude ausbauen</b><br/>
-- Ein Spezielgebäude muss ausgebaut werden.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Headquarters = 1
-- KnightTitleRequirements[KnightTitles.Mayor].Storehouse = 1
-- KnightTitleRequirements[KnightTitles.Mayor].Cathedrals = 1
-- </code></pre>
-- </li>
--
-- <li><b>Anzahl Siedler</b><br/>
-- Der Spieler benötigt eine Gesamtzahl an Siedlern.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Settlers = 40
-- </code></pre>
-- </li>
--
-- <li><b>Anzahl reiche Stadtgebäude</b><br/>
-- Eine Anzahl an Gebäuden muss durch Einnahmen Reichtum erlangen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].RichBuildings = 30
-- </code></pre>
-- </li>
--
-- <li><b>Benutzerdefiniert</b><br/>
-- Eine benutzerdefinierte Funktion, die entweder als Schalter oder als Zähler
-- fungieren kann und true oder false zurückgeben muss. Soll ein Zähler
-- angezeigt werden, muss nach dem Wahrheitswert der aktuelle und der maximale
-- Wert des Zählers folgen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Custom = {
--     {SomeFunction, {1, 1}, "Überschrift", "Beschreibung"}
--     ...
-- }
--
-- -- Funktion prüft Schalter
-- function SomeFunction(_PlayerID, _NextTitle, _Index)
--     return gvMission.MySwitch == true;
-- end
-- -- Funktion prüft Zähler
-- function SomeFunction(_PlayerID, _NextTitle, _Index)
--     return gvMission.MyCounter == 6, gvMission.MyCounter, 6;
-- end
-- </code></pre>
-- </li>
-- </ul></p>
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- </ul>
-- 
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field KnightTitleChanged Der Spieler hat einen neuen Titel erlangt (Parameter: PlayerID, TitleID)
-- @field GoodsConsumed      Güter werden von Siedlern konsumiert (Parameter: ConsumerID, GoodType, BuildingID)
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

-- Internal ----------------------------------------------------------------- --

---
-- Prüft, ob genug Entities in einer bestimmten Kategorie existieren.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Category == nil then
        return;
    end
    if _i then
        local EntityCategory = KnightTitleRequirements[_KnightTitle].Category[_i][1];
        local NeededAmount = KnightTitleRequirements[_KnightTitle].Category[_i][2];

        local ReachedAmount = 0;
        if EntityCategory == EntityCategories.Spouse then
            ReachedAmount = Logic.GetNumberOfSpouses(_PlayerID);
        else
            local Buildings = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategory)};
            for i=1, #Buildings do
                if Logic.IsBuilding(Buildings[i]) == 1 then
                    if Logic.IsConstructionComplete(Buildings[i]) == 1 then
                        ReachedAmount = ReachedAmount +1;
                    end
                else
                    ReachedAmount = ReachedAmount +1;
                end
            end
        end

        if ReachedAmount >= NeededAmount then
            return true, ReachedAmount, NeededAmount;
        end
        return false, ReachedAmount, NeededAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Category do
            bool, reach, need = DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob genug Entities eines bestimmten Typs existieren.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Entities == nil then
        return;
    end
    if _i then
        local EntityType = KnightTitleRequirements[_KnightTitle].Entities[_i][1];
        local NeededAmount = KnightTitleRequirements[_KnightTitle].Entities[_i][2];
        local Buildings = GetPlayerEntities(_PlayerID, EntityType);

        local ReachedAmount = 0;
        for i=1, #Buildings do
            if Logic.IsBuilding(Buildings[i]) == 1 then
                if Logic.IsConstructionComplete(Buildings[i]) == 1 then
                    ReachedAmount = ReachedAmount +1;
                end
            else
                ReachedAmount = ReachedAmount +1;
            end
        end

        if ReachedAmount >= NeededAmount then
            return true, ReachedAmount, NeededAmount;
        end
        return false, ReachedAmount, NeededAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Entities do
            bool, reach, need = DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob es genug Einheiten eines Warentyps gibt.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoesNeededNumberOfGoodTypesForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Goods == nil then
        return;
    end
    if _i then
        local GoodType = KnightTitleRequirements[_KnightTitle].Goods[_i][1];
        local NeededAmount = KnightTitleRequirements[_KnightTitle].Goods[_i][2];
        local ReachedAmount = GetPlayerGoodsInSettlement(GoodType, _PlayerID, true);

        if ReachedAmount >= NeededAmount then
            return true, ReachedAmount, NeededAmount;
        end
        return false, ReachedAmount, NeededAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Goods do
            bool, reach, need = DoesNeededNumberOfGoodTypesForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob die Siedler genug Einheiten einer Ware konsumiert haben.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNeededNumberOfConsumedGoodsForKnightTitleExist = function( _PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Consume == nil then
        return;
    end
    if _i then
        QSB.ConsumedGoodsCounter[_PlayerID] = QSB.ConsumedGoodsCounter[_PlayerID] or {};

        local GoodType = KnightTitleRequirements[_KnightTitle].Consume[_i][1];
        local GoodAmount = QSB.ConsumedGoodsCounter[_PlayerID][GoodType] or 0;
        local NeededGoodAmount = KnightTitleRequirements[_KnightTitle].Consume[_i][2];
        if GoodAmount >= NeededGoodAmount then
            return true, GoodAmount, NeededGoodAmount;
        else
            return false, GoodAmount, NeededGoodAmount;
        end
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Consume do
            bool, reach, need = DoNeededNumberOfConsumedGoodsForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return false, reach, need
            end
        end
        return true, reach, need;
    end
end

---
-- Prüft, ob genug Waren der Kategorie hergestellt wurde.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNumberOfProductsInCategoryExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Products == nil then
        return;
    end
    if _i then
        local GoodAmount = 0;
        local NeedAmount = KnightTitleRequirements[_KnightTitle].Products[_i][2];
        local GoodCategory = KnightTitleRequirements[_KnightTitle].Products[_i][1];
        local GoodsInCategory = {Logic.GetGoodTypesInGoodCategory(GoodCategory)};

        for i=1, #GoodsInCategory do
            GoodAmount = GoodAmount + GetPlayerGoodsInSettlement(GoodsInCategory[i], _PlayerID, true);
        end
        return (GoodAmount >= NeedAmount), GoodAmount, NeedAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Products do
            bool, reach, need = DoNumberOfProductsInCategoryExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob ein bestimmter Buff für den Spieler aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNeededDiversityBuffForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Buff == nil then
        return;
    end
    if _i then
        local buff = KnightTitleRequirements[_KnightTitle].Buff[_i];
        if Logic.GetBuff(_PlayerID,buff) and Logic.GetBuff(_PlayerID,buff) ~= 0 then
            return true;
        end
        return false;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Buff do
            bool, reach, need = DoNeededDiversityBuffForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob die Custom Function true vermeldet.
--
-- <b>Hinweis</b>: Die Funktion wird innerhalb eines GUI Update aufgerufen.
-- Schreibe daher effizienten Lua Code!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoCustomFunctionForKnightTitleSucceed = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Custom == nil then
        return;
    end
    if _i then
        return KnightTitleRequirements[_KnightTitle].Custom[_i][1](_PlayerID, _KnightTitle, _i);
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Custom do
            bool, reach, need = DoCustomFunctionForKnightTitleSucceed(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob genug Dekoration eines Typs angebracht wurde.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNeededNumberOfDecoratedBuildingsForKnightTitleExist = function( _PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].DecoratedBuildings == nil then
        return
    end

    if _i then
        local CityBuildings = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)}
        local DecorationGoodType = KnightTitleRequirements[_KnightTitle].DecoratedBuildings[_i][1]
        local NeededBuildingsWithDecoration = KnightTitleRequirements[_KnightTitle].DecoratedBuildings[_i][2]
        local BuildingsWithDecoration = 0

        for i=1, #CityBuildings do
            local BuildingID = CityBuildings[i]
            local GoodState = Logic.GetBuildingWealthGoodState(BuildingID, DecorationGoodType)
            if GoodState > 0 then
                BuildingsWithDecoration = BuildingsWithDecoration + 1
            end
        end

        if BuildingsWithDecoration >= NeededBuildingsWithDecoration then
            return true, BuildingsWithDecoration, NeededBuildingsWithDecoration
        else
            return false, BuildingsWithDecoration, NeededBuildingsWithDecoration
        end
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].DecoratedBuildings do
            bool, reach, need = DoNeededNumberOfDecoratedBuildingsForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob die Spezialgebäude weit genug ausgebaut sind.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _EntityCategory Entity Category
-- @within Originalfunktionen
-- @local
--
DoNeededSpecialBuildingUpgradeForKnightTitleExist = function( _PlayerID, _KnightTitle, _EntityCategory)
    local SpecialBuilding
    local SpecialBuildingName
    if _EntityCategory == EntityCategories.Headquarters then
        SpecialBuilding = Logic.GetHeadquarters(_PlayerID)
        SpecialBuildingName = "Headquarters"
    elseif _EntityCategory == EntityCategories.Storehouse then
        SpecialBuilding = Logic.GetStoreHouse(_PlayerID)
        SpecialBuildingName = "Storehouse"
    elseif _EntityCategory == EntityCategories.Cathedrals then
        SpecialBuilding = Logic.GetCathedral(_PlayerID)
        SpecialBuildingName = "Cathedrals"
    else
        return
    end
    if KnightTitleRequirements[_KnightTitle][SpecialBuildingName] == nil then
        return
    end
    local NeededUpgradeLevel = KnightTitleRequirements[_KnightTitle][SpecialBuildingName]
    if SpecialBuilding ~= nil then
        local SpecialBuildingUpgradeLevel = Logic.GetUpgradeLevel(SpecialBuilding)
        if SpecialBuildingUpgradeLevel >= NeededUpgradeLevel then
            return true, SpecialBuildingUpgradeLevel, NeededUpgradeLevel
        else
            return false, SpecialBuildingUpgradeLevel, NeededUpgradeLevel
        end
    else
        return false, 0, NeededUpgradeLevel
    end
end

---
-- Prüft, ob der Ruf der Stadt hoch genug ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @within Originalfunktionen
-- @local
--
DoesNeededCityReputationForKnightTitleExist = function(_PlayerID, _KnightTitle)
    if KnightTitleRequirements[_KnightTitle].Reputation == nil then
        return;
    end
    local NeededAmount = KnightTitleRequirements[_KnightTitle].Reputation;
    if not NeededAmount then
        return;
    end
    local ReachedAmount = math.floor((Logic.GetCityReputation(_PlayerID) * 100) + 0.5);
    if ReachedAmount >= NeededAmount then
        return true, ReachedAmount, NeededAmount;
    end
    return false, ReachedAmount, NeededAmount;
end

---
-- Prüft, ob genug Gebäude vollständig dekoriert sind.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @within Originalfunktionen
-- @local
--
DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist = function( _PlayerID, _KnightTitle)
    if KnightTitleRequirements[_KnightTitle].FullDecoratedBuildings == nil then
        return
    end
    local CityBuildings = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)}
    local NeededBuildingsWithDecoration = KnightTitleRequirements[_KnightTitle].FullDecoratedBuildings
    local BuildingsWithDecoration = 0

    for i=1, #CityBuildings do
        local BuildingID = CityBuildings[i]
        local AmountOfWealthGoodsAtBuilding = 0

        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Banner ) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Sign  ) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Candle) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Ornament  ) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if AmountOfWealthGoodsAtBuilding >= 4 then
            BuildingsWithDecoration = BuildingsWithDecoration + 1
        end
    end

    if BuildingsWithDecoration >= NeededBuildingsWithDecoration then
        return true, BuildingsWithDecoration, NeededBuildingsWithDecoration
    else
        return false, BuildingsWithDecoration, NeededBuildingsWithDecoration
    end
end

---
-- Prüft, ob der Spieler befördert werden kann.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @within Originalfunktionen
-- @local
--
CanKnightBePromoted = function(_PlayerID, _KnightTitle)
    if _KnightTitle == nil then
        _KnightTitle = Logic.GetKnightTitle(_PlayerID) + 1;
    end

    if Logic.CanStartFestival(_PlayerID, 1) == true then
        if  KnightTitleRequirements[_KnightTitle] ~= nil
        and DoesNeededNumberOfSettlersForKnightTitleExist(_PlayerID, _KnightTitle) ~= false
        and DoNeededNumberOfGoodsForKnightTitleExist( _PlayerID, _KnightTitle)  ~= false
        and DoNeededSpecialBuildingUpgradeForKnightTitleExist( _PlayerID, _KnightTitle, EntityCategories.Headquarters) ~= false
        and DoNeededSpecialBuildingUpgradeForKnightTitleExist( _PlayerID, _KnightTitle, EntityCategories.Storehouse) ~= false
        and DoNeededSpecialBuildingUpgradeForKnightTitleExist( _PlayerID, _KnightTitle, EntityCategories.Cathedrals)  ~= false
        and DoNeededNumberOfRichBuildingsForKnightTitleExist( _PlayerID, _KnightTitle)  ~= false
        and DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoNeededNumberOfDecoratedBuildingsForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededCityReputationForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededNumberOfGoodTypesForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoNeededDiversityBuffForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoCustomFunctionForKnightTitleSucceed( _PlayerID, _KnightTitle) ~= false
        and DoNeededNumberOfConsumedGoodsForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoNumberOfProductsInCategoryExist( _PlayerID, _KnightTitle) ~= false then
            return true;
        end
    end
    return false;
end

---
-- Der Spieler gewinnt das Spiel
-- @within Originalfunktionen
-- @local
--
VictroryBecauseOfTitle = function()
    QuestTemplate:TerminateEventsAndStuff();
    Victory(g_VictoryAndDefeatType.VictoryMissionComplete);
end

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

--
-- Definiert den Standard der Aufstiegsbedingungen für den Spieler.
--

---
-- Diese Funktion muss entweder in der QSB modifiziert oder sowohl im globalen
-- als auch im lokalen Skript überschrieben werden. Ideal ist laden des
-- angepassten Skriptes als separate Datei. Bei Modifikationen muss das Schema
-- für Aufstiegsbedingungen und Rechtevergabe immer beibehalten werden.
--
-- <b>Hinweis</b>: Diese Funktion wird <b>automatisch</b> vom Code ausgeführt.
-- Du rufst sie <b>niemals</b> selbst auf!
--
-- @within Originalfunktionen
--
-- @usage
-- -- Dies ist ein Beispiel zum herauskopieren. Hier sind die üblichen
-- -- Bedingungen gesetzt. Wenn du diese Funktion in dein Skript kopierst, muss
-- -- sie im globalen und lokalen Skript stehen oder dort geladen werden!
-- InitKnightTitleTables = function()
--     KnightTitles = {}
--     KnightTitles.Knight     = 0
--     KnightTitles.Mayor      = 1
--     KnightTitles.Baron      = 2
--     KnightTitles.Earl       = 3
--     KnightTitles.Marquees   = 4
--     KnightTitles.Duke       = 5
--     KnightTitles.Archduke   = 6
--
--     -- ---------------------------------------------------------------------- --
--     -- Rechte und Pflichten                                                   --
--     -- ---------------------------------------------------------------------- --
--
--     NeedsAndRightsByKnightTitle = {}
--
--     -- Ritter ------------------------------------------------------------------
--
--     NeedsAndRightsByKnightTitle[KnightTitles.Knight] = {
--         ActivateNeedForPlayer,
--         {
--             Needs.Nutrition,                                    -- Bedürfnis: Nahrung
--             Needs.Medicine,                                     -- Bedürfnis: Medizin
--         },
--         ActivateRightForPlayer,
--         {
--             Technologies.R_Gathering,                           -- Recht: Rohstoffsammler
--             Technologies.R_Woodcutter,                          -- Recht: Holzfäller
--             Technologies.R_StoneQuarry,                         -- Recht: Steinbruch
--             Technologies.R_HuntersHut,                          -- Recht: Jägerhütte
--             Technologies.R_FishingHut,                          -- Recht: Fischerhütte
--             Technologies.R_CattleFarm,                          -- Recht: Kuhfarm
--             Technologies.R_GrainFarm,                           -- Recht: Getreidefarm
--             Technologies.R_SheepFarm,                           -- Recht: Schaffarm
--             Technologies.R_IronMine,                            -- Recht: Eisenmine
--             Technologies.R_Beekeeper,                           -- Recht: Imkerei
--             Technologies.R_HerbGatherer,                        -- Recht: Kräutersammler
--             Technologies.R_Nutrition,                           -- Recht: Nahrung
--             Technologies.R_Bakery,                              -- Recht: Bäckerei
--             Technologies.R_Dairy,                               -- Recht: Käserei
--             Technologies.R_Butcher,                             -- Recht: Metzger
--             Technologies.R_SmokeHouse,                          -- Recht: Räucherhaus
--             Technologies.R_Clothes,                             -- Recht: Kleidung
--             Technologies.R_Tanner,                              -- Recht: Ledergerber
--             Technologies.R_Weaver,                              -- Recht: Weber
--             Technologies.R_Construction,                        -- Recht: Konstruktion
--             Technologies.R_Wall,                                -- Recht: Mauer
--             Technologies.R_Pallisade,                           -- Recht: Palisade
--             Technologies.R_Trail,                               -- Recht: Pfad
--             Technologies.R_KnockDown,                           -- Recht: Abriss
--             Technologies.R_Sermon,                              -- Recht: Predigt
--             Technologies.R_SpecialEdition,                      -- Recht: Special Edition
--             Technologies.R_SpecialEdition_Pavilion,             -- Recht: Pavilion AeK SE
--         }
--     }
--
--     -- Landvogt ----------------------------------------------------------------
--
--     NeedsAndRightsByKnightTitle[KnightTitles.Mayor] = {
--         ActivateNeedForPlayer,
--         {
--             Needs.Clothes,                                      -- Bedürfnis: KLeidung
--         },
--         ActivateRightForPlayer, {
--             Technologies.R_Hygiene,                             -- Recht: Hygiene
--             Technologies.R_Soapmaker,                           -- Recht: Seifenmacher
--             Technologies.R_BroomMaker,                          -- Recht: Besenmacher
--             Technologies.R_Military,                            -- Recht: Militär
--             Technologies.R_SwordSmith,                          -- Recht: Schwertschmied
--             Technologies.R_Barracks,                            -- Recht: Schwertkämpferkaserne
--             Technologies.R_Thieves,                             -- Recht: Diebe
--             Technologies.R_SpecialEdition_StatueFamily,         -- Recht: Familienstatue Aek SE
--         },
--         StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
--     }
--
--     -- Baron -------------------------------------------------------------------
--
--     NeedsAndRightsByKnightTitle[KnightTitles.Baron] = {
--         ActivateNeedForPlayer,
--         {
--             Needs.Hygiene,                                      -- Bedürfnis: Hygiene
--         },
--         ActivateRightForPlayer, {
--             Technologies.R_SiegeEngineWorkshop,                 -- Recht: Belagerungswaffenschmied
--             Technologies.R_BatteringRam,                        -- Recht: Ramme
--             Technologies.R_Medicine,                            -- Recht: Medizin
--             Technologies.R_Entertainment,                       -- Recht: Unterhaltung
--             Technologies.R_Tavern,                              -- Recht: Taverne
--             Technologies.R_Festival,                            -- Recht: Fest
--             Technologies.R_Street,                              -- Recht: Straße
--             Technologies.R_SpecialEdition_Column,               -- Recht: Säule AeK SE
--         },
--         StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
--     }
--
--     -- Graf --------------------------------------------------------------------
--
--     NeedsAndRightsByKnightTitle[KnightTitles.Earl] = {
--         ActivateNeedForPlayer,
--         {
--             Needs.Entertainment,                                -- Bedürfnis: Unterhaltung
--             Needs.Prosperity,                                   -- Bedürfnis: Reichtum
--         },
--         ActivateRightForPlayer, {
--             Technologies.R_BowMaker,                            -- Recht: Bogenmacher
--             Technologies.R_BarracksArchers,                     -- Recht: Bogenschützenkaserne
--             Technologies.R_Baths,                               -- Recht: Badehaus
--             Technologies.R_AmmunitionCart,                      -- Recht: Munitionswagen
--             Technologies.R_Prosperity,                          -- Recht: Reichtum
--             Technologies.R_Taxes,                               -- Recht: Steuern einstellen
--             Technologies.R_Ballista,                            -- Recht: Mauerkatapult
--             Technologies.R_SpecialEdition_StatueSettler,        -- Recht: Siedlerstatue AeK SE
--         },
--         StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
--     }
--
--     -- Marquees ----------------------------------------------------------------
--
--     NeedsAndRightsByKnightTitle[KnightTitles.Marquees] = {
--         ActivateNeedForPlayer,
--         {
--             Needs.Wealth,                                       -- Bedürfnis: Verschönerung
--         },
--         ActivateRightForPlayer, {
--             Technologies.R_Theater,                             -- Recht: Theater
--             Technologies.R_Wealth,                              -- Recht: Schmuckgebäude
--             Technologies.R_BannerMaker,                         -- Recht: Bannermacher
--             Technologies.R_SiegeTower,                          -- Recht: Belagerungsturm
--             Technologies.R_SpecialEdition_StatueProduction,     -- Recht: Produktionsstatue AeK SE
--         },
--         StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
--     }
--
--     -- Herzog ------------------------------------------------------------------
--
--     NeedsAndRightsByKnightTitle[KnightTitles.Duke] = {
--         ActivateNeedForPlayer, nil,
--         ActivateRightForPlayer, {
--             Technologies.R_Catapult,                            -- Recht: Katapult
--             Technologies.R_Carpenter,                           -- Recht: Tischler
--             Technologies.R_CandleMaker,                         -- Recht: Kerzenmacher
--             Technologies.R_Blacksmith,                          -- Recht: Schmied
--             Technologies.R_SpecialEdition_StatueDario,          -- Recht: Dariostatue AeK SE
--         },
--         StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
--     }
--
--     -- Erzherzog ---------------------------------------------------------------
--
--     NeedsAndRightsByKnightTitle[KnightTitles.Archduke] = {
--         ActivateNeedForPlayer,nil,
--         ActivateRightForPlayer, {
--             Technologies.R_Victory                              -- Sieg
--         },
--         -- VictroryBecauseOfTitle,                              -- Sieg wegen Titel
--         StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
--     }
--
--
--
--     -- Reich des Ostens --------------------------------------------------------
--
--     if g_GameExtraNo >= 1 then
--         local TechnologiesTableIndex = 4;
--         table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Cistern);
--         table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Beautification_Brazier);
--         table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Beautification_Shrine);
--         table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Baron][TechnologiesTableIndex],Technologies.R_Beautification_Pillar);
--         table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Earl][TechnologiesTableIndex],Technologies.R_Beautification_StoneBench);
--         table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Earl][TechnologiesTableIndex],Technologies.R_Beautification_Vase);
--         table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Marquees][TechnologiesTableIndex],Technologies.R_Beautification_Sundial);
--         table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Archduke][TechnologiesTableIndex],Technologies.R_Beautification_TriumphalArch);
--         table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Duke][TechnologiesTableIndex],Technologies.R_Beautification_VictoryColumn);
--     end
--
--
--
--     -- ---------------------------------------------------------------------- --
--     -- Bedingungen                                                            --
--     -- ---------------------------------------------------------------------- --
--
--     KnightTitleRequirements = {}
--
--     -- Ritter ------------------------------------------------------------------
--
--     KnightTitleRequirements[KnightTitles.Mayor] = {}
--     KnightTitleRequirements[KnightTitles.Mayor].Headquarters = 1
--     KnightTitleRequirements[KnightTitles.Mayor].Settlers = 10
--     KnightTitleRequirements[KnightTitles.Mayor].Products = {
--         {GoodCategories.GC_Clothes, 6},
--     }
--
--     -- Baron -------------------------------------------------------------------
--
--     KnightTitleRequirements[KnightTitles.Baron] = {}
--     KnightTitleRequirements[KnightTitles.Baron].Settlers = 30
--     KnightTitleRequirements[KnightTitles.Baron].Headquarters = 1
--     KnightTitleRequirements[KnightTitles.Baron].Storehouse = 1
--     KnightTitleRequirements[KnightTitles.Baron].Cathedrals = 1
--     KnightTitleRequirements[KnightTitles.Baron].Products = {
--         {GoodCategories.GC_Hygiene, 12},
--     }
--
--     -- Graf --------------------------------------------------------------------
--
--     KnightTitleRequirements[KnightTitles.Earl] = {}
--     KnightTitleRequirements[KnightTitles.Earl].Settlers = 50
--     KnightTitleRequirements[KnightTitles.Earl].Headquarters = 2
--     KnightTitleRequirements[KnightTitles.Earl].Goods = {
--         {Goods.G_Beer, 18},
--     }
--
--     -- Marquess ----------------------------------------------------------------
--
--     KnightTitleRequirements[KnightTitles.Marquees] = {}
--     KnightTitleRequirements[KnightTitles.Marquees].Settlers = 70
--     KnightTitleRequirements[KnightTitles.Marquees].Headquarters = 2
--     KnightTitleRequirements[KnightTitles.Marquees].Storehouse = 2
--     KnightTitleRequirements[KnightTitles.Marquees].Cathedrals = 2
--     KnightTitleRequirements[KnightTitles.Marquees].RichBuildings = 20
--
--     -- Herzog ------------------------------------------------------------------
--
--     KnightTitleRequirements[KnightTitles.Duke] = {}
--     KnightTitleRequirements[KnightTitles.Duke].Settlers = 90
--     KnightTitleRequirements[KnightTitles.Duke].Storehouse = 2
--     KnightTitleRequirements[KnightTitles.Duke].Cathedrals = 2
--     KnightTitleRequirements[KnightTitles.Duke].Headquarters = 3
--     KnightTitleRequirements[KnightTitles.Duke].DecoratedBuildings = {
--         {Goods.G_Banner, 9 },
--     }
--
--     -- Erzherzog ---------------------------------------------------------------
--
--     KnightTitleRequirements[KnightTitles.Archduke] = {}
--     KnightTitleRequirements[KnightTitles.Archduke].Settlers = 150
--     KnightTitleRequirements[KnightTitles.Archduke].Storehouse = 3
--     KnightTitleRequirements[KnightTitles.Archduke].Cathedrals = 3
--     KnightTitleRequirements[KnightTitles.Archduke].Headquarters = 3
--     KnightTitleRequirements[KnightTitles.Archduke].RichBuildings = 30
--     KnightTitleRequirements[KnightTitles.Archduke].FullDecoratedBuildings = 30
--
--     -- Einstellungen Aktivieren
--     CreateTechnologyKnightTitleTable()
-- end
--
InitKnightTitleTables = function()
    KnightTitles = {}
    KnightTitles.Knight     = 0
    KnightTitles.Mayor      = 1
    KnightTitles.Baron      = 2
    KnightTitles.Earl       = 3
    KnightTitles.Marquees   = 4
    KnightTitles.Duke       = 5
    KnightTitles.Archduke   = 6

    -- ---------------------------------------------------------------------- --
    -- Rechte und Pflichten                                                   --
    -- ---------------------------------------------------------------------- --

    NeedsAndRightsByKnightTitle = {}

    -- Ritter ------------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Knight] = {
        ActivateNeedForPlayer,
        {
            Needs.Nutrition,                                    -- Bedürfnis: Nahrung
            Needs.Medicine,                                     -- Bedürfnis: Medizin
        },
        ActivateRightForPlayer,
        {
            Technologies.R_Gathering,                           -- Recht: Rohstoffsammler
            Technologies.R_Woodcutter,                          -- Recht: Holzfäller
            Technologies.R_StoneQuarry,                         -- Recht: Steinbruch
            Technologies.R_HuntersHut,                          -- Recht: Jägerhütte
            Technologies.R_FishingHut,                          -- Recht: Fischerhütte
            Technologies.R_CattleFarm,                          -- Recht: Kuhfarm
            Technologies.R_GrainFarm,                           -- Recht: Getreidefarm
            Technologies.R_SheepFarm,                           -- Recht: Schaffarm
            Technologies.R_IronMine,                            -- Recht: Eisenmine
            Technologies.R_Beekeeper,                           -- Recht: Imkerei
            Technologies.R_HerbGatherer,                        -- Recht: Kräutersammler
            Technologies.R_Nutrition,                           -- Recht: Nahrung
            Technologies.R_Bakery,                              -- Recht: Bäckerei
            Technologies.R_Dairy,                               -- Recht: Käserei
            Technologies.R_Butcher,                             -- Recht: Metzger
            Technologies.R_SmokeHouse,                          -- Recht: Räucherhaus
            Technologies.R_Clothes,                             -- Recht: Kleidung
            Technologies.R_Tanner,                              -- Recht: Ledergerber
            Technologies.R_Weaver,                              -- Recht: Weber
            Technologies.R_Construction,                        -- Recht: Konstruktion
            Technologies.R_Wall,                                -- Recht: Mauer
            Technologies.R_Pallisade,                           -- Recht: Palisade
            Technologies.R_Trail,                               -- Recht: Pfad
            Technologies.R_KnockDown,                           -- Recht: Abriss
            Technologies.R_Sermon,                              -- Recht: Predigt
            Technologies.R_SpecialEdition,                      -- Recht: Special Edition
            Technologies.R_SpecialEdition_Pavilion,             -- Recht: Pavilion AeK SE
        }
    }

    -- Landvogt ----------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Mayor] = {
        ActivateNeedForPlayer,
        {
            Needs.Clothes,                                      -- Bedürfnis: KLeidung
        },
        ActivateRightForPlayer, {
            Technologies.R_Hygiene,                             -- Recht: Hygiene
            Technologies.R_Soapmaker,                           -- Recht: Seifenmacher
            Technologies.R_BroomMaker,                          -- Recht: Besenmacher
            Technologies.R_Military,                            -- Recht: Militär
            Technologies.R_SwordSmith,                          -- Recht: Schwertschmied
            Technologies.R_Barracks,                            -- Recht: Schwertkämpferkaserne
            Technologies.R_Thieves,                             -- Recht: Diebe
            Technologies.R_SpecialEdition_StatueFamily,         -- Recht: Familienstatue Aek SE
        },
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }

    -- Baron -------------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Baron] = {
        ActivateNeedForPlayer,
        {
            Needs.Hygiene,                                      -- Bedürfnis: Hygiene
        },
        ActivateRightForPlayer, {
            Technologies.R_SiegeEngineWorkshop,                 -- Recht: Belagerungswaffenschmied
            Technologies.R_BatteringRam,                        -- Recht: Ramme
            Technologies.R_Medicine,                            -- Recht: Medizin
            Technologies.R_Entertainment,                       -- Recht: Unterhaltung
            Technologies.R_Tavern,                              -- Recht: Taverne
            Technologies.R_Festival,                            -- Recht: Fest
            Technologies.R_Street,                              -- Recht: Straße
            Technologies.R_SpecialEdition_Column,               -- Recht: Säule AeK SE
        },
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }

    -- Graf --------------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Earl] = {
        ActivateNeedForPlayer,
        {
            Needs.Entertainment,                                -- Bedürfnis: Unterhaltung
            Needs.Prosperity,                                   -- Bedürfnis: Reichtum
        },
        ActivateRightForPlayer, {
            Technologies.R_BowMaker,                            -- Recht: Bogenmacher
            Technologies.R_BarracksArchers,                     -- Recht: Bogenschützenkaserne
            Technologies.R_Baths,                               -- Recht: Badehaus
            Technologies.R_AmmunitionCart,                      -- Recht: Munitionswagen
            Technologies.R_Prosperity,                          -- Recht: Reichtum
            Technologies.R_Taxes,                               -- Recht: Steuern einstellen
            Technologies.R_Ballista,                            -- Recht: Mauerkatapult
            Technologies.R_SpecialEdition_StatueSettler,        -- Recht: Siedlerstatue AeK SE
        },
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }

    -- Marquees ----------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Marquees] = {
        ActivateNeedForPlayer,
        {
            Needs.Wealth,                                       -- Bedürfnis: Verschönerung
        },
        ActivateRightForPlayer, {
            Technologies.R_Theater,                             -- Recht: Theater
            Technologies.R_Wealth,                              -- Recht: Schmuckgebäude
            Technologies.R_BannerMaker,                         -- Recht: Bannermacher
            Technologies.R_SiegeTower,                          -- Recht: Belagerungsturm
            Technologies.R_SpecialEdition_StatueProduction,     -- Recht: Produktionsstatue AeK SE
        },
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }

    -- Herzog ------------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Duke] = {
        ActivateNeedForPlayer, nil,
        ActivateRightForPlayer, {
            Technologies.R_Catapult,                            -- Recht: Katapult
            Technologies.R_Carpenter,                           -- Recht: Tischler
            Technologies.R_CandleMaker,                         -- Recht: Kerzenmacher
            Technologies.R_Blacksmith,                          -- Recht: Schmied
            Technologies.R_SpecialEdition_StatueDario,          -- Recht: Dariostatue AeK SE
        },
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }

    -- Erzherzog ---------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Archduke] = {
        ActivateNeedForPlayer,nil,
        ActivateRightForPlayer, {
            Technologies.R_Victory                              -- Sieg
        },
        -- VictroryBecauseOfTitle,                              -- Sieg wegen Titel
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }



    -- Reich des Ostens --------------------------------------------------------

    if g_GameExtraNo >= 1 then
        local TechnologiesTableIndex = 4;
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Cistern);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Beautification_Brazier);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Beautification_Shrine);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Baron][TechnologiesTableIndex],Technologies.R_Beautification_Pillar);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Earl][TechnologiesTableIndex],Technologies.R_Beautification_StoneBench);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Earl][TechnologiesTableIndex],Technologies.R_Beautification_Vase);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Marquees][TechnologiesTableIndex],Technologies.R_Beautification_Sundial);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Archduke][TechnologiesTableIndex],Technologies.R_Beautification_TriumphalArch);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Duke][TechnologiesTableIndex],Technologies.R_Beautification_VictoryColumn);
    end



    -- ---------------------------------------------------------------------- --
    -- Bedingungen                                                            --
    -- ---------------------------------------------------------------------- --

    KnightTitleRequirements = {}

    -- Ritter ------------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Mayor] = {}
    KnightTitleRequirements[KnightTitles.Mayor].Headquarters = 1
    KnightTitleRequirements[KnightTitles.Mayor].Settlers = 10
    KnightTitleRequirements[KnightTitles.Mayor].Products = {
        {GoodCategories.GC_Clothes, 6},
    }

    -- Baron -------------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Baron] = {}
    KnightTitleRequirements[KnightTitles.Baron].Settlers = 30
    KnightTitleRequirements[KnightTitles.Baron].Headquarters = 1
    KnightTitleRequirements[KnightTitles.Baron].Storehouse = 1
    KnightTitleRequirements[KnightTitles.Baron].Cathedrals = 1
    KnightTitleRequirements[KnightTitles.Baron].Products = {
        {GoodCategories.GC_Hygiene, 12},
    }

    -- Graf --------------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Earl] = {}
    KnightTitleRequirements[KnightTitles.Earl].Settlers = 50
    KnightTitleRequirements[KnightTitles.Earl].Headquarters = 2
    KnightTitleRequirements[KnightTitles.Earl].Goods = {
        {Goods.G_Beer, 18},
    }

    -- Marquess ----------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Marquees] = {}
    KnightTitleRequirements[KnightTitles.Marquees].Settlers = 70
    KnightTitleRequirements[KnightTitles.Marquees].Headquarters = 2
    KnightTitleRequirements[KnightTitles.Marquees].Storehouse = 2
    KnightTitleRequirements[KnightTitles.Marquees].Cathedrals = 2
    KnightTitleRequirements[KnightTitles.Marquees].RichBuildings = 20

    -- Herzog ------------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Duke] = {}
    KnightTitleRequirements[KnightTitles.Duke].Settlers = 90
    KnightTitleRequirements[KnightTitles.Duke].Storehouse = 2
    KnightTitleRequirements[KnightTitles.Duke].Cathedrals = 2
    KnightTitleRequirements[KnightTitles.Duke].Headquarters = 3
    KnightTitleRequirements[KnightTitles.Duke].DecoratedBuildings = {
        {Goods.G_Banner, 9 },
    }

    -- Erzherzog ---------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Archduke] = {}
    KnightTitleRequirements[KnightTitles.Archduke].Settlers = 150
    KnightTitleRequirements[KnightTitles.Archduke].Storehouse = 3
    KnightTitleRequirements[KnightTitles.Archduke].Cathedrals = 3
    KnightTitleRequirements[KnightTitles.Archduke].Headquarters = 3
    KnightTitleRequirements[KnightTitles.Archduke].RichBuildings = 30
    KnightTitleRequirements[KnightTitles.Archduke].FullDecoratedBuildings = 30

    -- Einstellungen Aktivieren
    CreateTechnologyKnightTitleTable()
end

