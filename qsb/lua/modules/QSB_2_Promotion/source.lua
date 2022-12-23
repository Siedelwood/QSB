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

