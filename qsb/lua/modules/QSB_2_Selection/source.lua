--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleSelection = {
    Properties = {
        Name = "ModuleSelection",
        Version = "4.0.0 (ALPHA 1.0.0)",
    },

    Global = {
        TrebuchetIDToCart = {},
        SelectedEntities = {},
    },
    Local = {
        SelectedEntities = {},
        TrebuchetDisassemble = false,
        TrebuchetErect = false,
        ThiefRelease = false,
        SiegeEngineRelease = true,
        MilitaryRelease = true,
    },

    Shared = {
        Text = {
            Tooltips = {
                KnightButton = {
                    Title = {
                        de = "Ritter selektieren",
                        en = "Select Knight",
                        fr = "Sélectionner le chevalier",
                    },
                    Text = {
                        de = "- Klick selektiert den Ritter {cr}- Doppelklick springt zum Ritter{cr}- STRG halten selektiert alle Ritter",
                        en = "- Click selects the knight {cr}- Double click jumps to knight{cr}- Press CTRL to select all knights",
                        fr = "- Clic sélectionne le chevalier {cr}- Double-clic saute au chevalier{cr}- Maintenir CTRL sélectionne tous les chevaliers",
                    },
                },

                BattalionButton = {
                    Title = {
                        de = "Militär selektieren",
                        en = "Select Units",
                        fr = "Sélectionner les unitées",
                    },
                    Text = {
                        de = "- Selektiert alle Militäreinheiten {cr}- SHIFT halten um auch Diebe, Munitionswagen und Trebuchets auszuwählen",
                        en = "- Selects all military units {cr}- Press SHIFT to additionally select ammunition carts, thieves and trebuchets",
                        fr = "- Sélectionne toutes les unités militaires {cr}- Maintenir SHIFT pour sélectionner aussi les voleurs, les chariots de munitions et les trébuchets",
                    },
                },

                ReleaseSoldiers = {
                    Title = {
                        de = "Militär entlassen",
                        en = "Release military unit",
                        fr = "licencier l'unitées",
                    },
                    Text = {
                        de = "- Eine Militäreinheit entlassen {cr}- Soldaten werden nacheinander entlassen",
                        en = "- Dismiss a military unit {cr}- Soldiers will be dismissed each after another",
                        fr = "- Licencier une unité militaire {cr}- Les soldats sont licenciés les uns après les autres",
                    },
                    Disabled = {
                        de = "Kann nicht entlassen werden!",
                        en = "Releasing is impossible!",
                        fr = "Ne peut pas être licencié!",
                    },
                },

                TrebuchetCart = {
                    Title = {
                        de = "Trebuchetwagen",
                        en = "Trebuchet cart",
                        fr = "Chariot à trébuchet",
                    },
                    Text = {
                        de = "- Kann einmalig zum Trebuchet ausgebaut werden",
                        en = "- Can uniquely be transmuted into a trebuchet",
                        fr = "- Peut être transformé une seule fois en trébuchet",
                    },
                },

                Trebuchet = {
                    Title = {
                        de = "Trebuchet",
                        en = "Trebuchet",
                        fr = "Trébuchet",
                    },
                    Text = {
                        de = "- Kann über weite Strecken Gebäude angreifen {cr}- Kann Gebäude in Brand stecken {cr}- Trebuchet kann manuell zurückgeschickt werden",
                        en = "- Can perform long range attacks on buildings {cr}- Can set buildings on fire {cr}- The trebuchet can be manually send back to the city",
                        fr = "- Peut attaquer des bâtiments sur de longues distances {cr}- Peut mettre le feu à des bâtiments {cr}- Le trébuchet peut être renvoyé manuellement",
                    },
                },
            },
        }
    };
}

-- Global ------------------------------------------------------------------- --

function ModuleSelection.Global:OnGameStart()
    QSB.ScriptEvents.SelectionChanged = API.RegisterScriptEvent("Event_SelectionChanged");

    API.RegisterScriptCommand("Cmd_SelectionDestroyEntity", function(_Entity)
        DestroyEntity(_Entity);
    end);
    API.RegisterScriptCommand("Cmd_SelectionSetTaskList", function(_Entity)
        Logic.SetTaskList(GetID(_Entity), TaskLists.TL_NPC_IDLE);
    end);
    API.RegisterScriptCommand("Cmd_SelectionErectTrebuchet", function(_Entity)
        return ModuleSelection.Global:MilitaryErectTrebuchet(_Entity);
    end);
    API.RegisterScriptCommand("Cmd_SelectionDisambleTrebuchet", function(_Entity)
        return ModuleSelection.Global:MilitaryDisambleTrebuchet(_Entity);
    end);

    for i= 1, 8 do
        self.SelectedEntities[i] = {};
    end
end

function ModuleSelection.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.SelectionChanged then
        self.SelectedEntities[arg[1]] = arg[3];
    end
end

function ModuleSelection.Global:MilitaryDisambleTrebuchet(_EntityID)
    local x,y,z = Logic.EntityGetPos(_EntityID);
    local PlayerID = Logic.EntityGetPlayer(_EntityID);

    -- Extern callback for the mapscript
    if GameCallback_QSB_OnDisambleTrebuchet then
        GameCallback_QSB_OnDisambleTrebuchet(_EntityID, PlayerID, x, y, z);
        return;
    end

    Logic.CreateEffect(EGL_Effects.E_Shockwave01, x, y, 0);
    Logic.SetEntityInvulnerabilityFlag(_EntityID, 1);
    Logic.SetEntitySelectableFlag(_EntityID, 0);
    Logic.SetVisible(_EntityID, false);

    local TrebuchetCart = self.TrebuchetIDToCart[_EntityID];
    if TrebuchetCart ~= nil then
        Logic.SetEntityInvulnerabilityFlag(TrebuchetCart, 0);
        Logic.SetEntitySelectableFlag(TrebuchetCart, 1);
        Logic.SetVisible(TrebuchetCart, true);
    else
        TrebuchetCart = Logic.CreateEntity(Entities.U_SiegeEngineCart, x, y, 0, PlayerID);
        self.TrebuchetIDToCart[_EntityID] = TrebuchetCart;
    end

    Logic.DEBUG_SetSettlerPosition(TrebuchetCart, x, y);
    Logic.SetTaskList(TrebuchetCart, TaskLists.TL_NPC_IDLE);
    Logic.ExecuteInLuaLocalState(string.format(
        [[GUI.SelectEntity(%d)]], TrebuchetCart
    ));
end

function ModuleSelection.Global:MilitaryErectTrebuchet(_EntityID)
    local x,y,z = Logic.EntityGetPos(_EntityID);
    local PlayerID = Logic.EntityGetPlayer(_EntityID);

    -- Extern callback for the mapscript
    if GameCallback_QSB_OnErectTrebuchet then
        GameCallback_QSB_OnErectTrebuchet(_EntityID, PlayerID, x, y, z);
        return;
    end

    Logic.CreateEffect(EGL_Effects.E_Shockwave01, x, y, 0);
    Logic.SetEntityInvulnerabilityFlag(_EntityID, 1);
    Logic.SetEntitySelectableFlag(_EntityID, 0);
    Logic.SetVisible(_EntityID, false);

    local Trebuchet;
    for k, v in pairs(self.TrebuchetIDToCart) do
        if v == _EntityID then
            Trebuchet = tonumber(k);
        end
    end
    if Trebuchet == nil then
        Trebuchet = Logic.CreateEntity(Entities.U_Trebuchet, x, y, 0, PlayerID);
        self.TrebuchetIDToCart[Trebuchet] = _EntityID;
    end

    Logic.SetEntityInvulnerabilityFlag(Trebuchet, 0);
    Logic.SetEntitySelectableFlag(Trebuchet, 1);
    Logic.SetVisible(Trebuchet, true);
    Logic.DEBUG_SetSettlerPosition(Trebuchet, x, y);
    Logic.ExecuteInLuaLocalState([[
        GUI.SelectEntity(]]..Trebuchet..[[)
    ]]);
end

-- Local -------------------------------------------------------------------- --

function ModuleSelection.Local:OnGameStart()
    QSB.ScriptEvents.SelectionChanged = API.RegisterScriptEvent("Event_SelectionChanged");

    if API.IsHistoryEditionNetworkGame() then
        return;
    end
    self:OverrideSelection();
    self:OverwriteMilitaryCommands();
    self:OverwriteMilitaryErect();
    self:OverwriteMilitaryDisamble();
    self:OverwriteMultiselectIcon();
    self:OverwriteMilitaryDismount();
    self:OverwriteThiefDeliver();
    self:OverwriteSelectKnight();
    self:OverwriteSelectAllUnits();
    self:OverwriteNamesAndDescription();
end

function ModuleSelection.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

function ModuleSelection.Local:OverrideSelection()
    GameCallback_GUI_SelectionChanged_Orig_ModuleSelection = GameCallback_GUI_SelectionChanged;
    GameCallback_GUI_SelectionChanged = function(_Source)
        GameCallback_GUI_SelectionChanged_Orig_ModuleSelection(_Source);
        ModuleSelection.Local:OnSelectionCanged(_Source);
    end
end

function ModuleSelection.Local:OverwriteMilitaryCommands()
    GUI_Military.StandGroundClicked = function()
        Sound.FXPlay2DSound( "ui\\menu_click");
        local SelectedEntities = {GUI.GetSelectedEntities()};
        for i=1,#SelectedEntities do
            local LeaderID = SelectedEntities[i];
            local eType = Logic.GetEntityType(LeaderID);
            GUI.SendCommandStationaryDefend(LeaderID);
            if eType == Entities.U_Trebuchet then
                API.BroadcastScriptCommand(
                    QSB.ScriptCommands.SelectionSetTaskList,
                    LeaderID,
                    TaskLists.TL_NPC_IDLE
                );
            end
        end
    end

    GUI_Military.StandGroundUpdate = function()
        local WidgetAttack = "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military/Attack";
        local SelectedEntities = {GUI.GetSelectedEntities()};
        SetIcon(WidgetAttack, {12, 4});
        if #SelectedEntities == 1 then
            local eID = SelectedEntities[1];
            local eType = Logic.GetEntityType(eID);
            if eType == Entities.U_Trebuchet then
                if Logic.GetAmmunitionAmount(eID) > 0 then
                    XGUIEng.ShowWidget(WidgetAttack, 0);
                else
                    XGUIEng.ShowWidget(WidgetAttack, 1);
                end
                SetIcon(WidgetAttack, {1, 10});
            else
                XGUIEng.ShowWidget(WidgetAttack, 1);
            end
        end
    end
end

function ModuleSelection.Local:OverwriteMilitaryErect()
    GUI_Military.ErectClicked_Orig_ModuleSelection = GUI_Military.ErectClicked;
    GUI_Military.ErectClicked = function()
        GUI_Military.ErectClicked_Orig_ModuleSelection();
        local SelectedEntities = {GUI.GetSelectedEntities()};
        for i=1, #SelectedEntities, 1 do
            local EntityType = Logic.GetEntityType(SelectedEntities[i]);
            if EntityType == Entities.U_SiegeEngineCart then
                API.BroadcastScriptCommand(
                    QSB.ScriptCommands.SelectionErectTrebuchet,
                    SelectedEntities[i]
                );
            end
        end
    end

    GUI_Military.ErectUpdate_Orig_ModuleSelection = GUI_Military.ErectUpdate;
    GUI_Military.ErectUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local SiegeCartID = GUI.GetSelectedEntity();
        local EntityType = Logic.GetEntityType(SiegeCartID);
        if EntityType == Entities.U_SiegeEngineCart then
            local Disabled = (ModuleSelection.Local.TrebuchetErect and 0) or 1;
            XGUIEng.DisableButton(CurrentWidgetID, Disabled);
            SetIcon(CurrentWidgetID, {12, 6});
        else
            GUI_Military.ErectUpdate_Orig_ModuleSelection();
        end
    end

    GUI_Military.ErectMouseOver_Orig_ModuleSelection = GUI_Military.ErectMouseOver;
    GUI_Military.ErectMouseOver = function()
        local SiegeCartID = GUI.GetSelectedEntity();
        local TooltipTextKey;
        if Logic.GetEntityType(SiegeCartID) == Entities.U_SiegeEngineCart then
            TooltipTextKey = "ErectCatapult";
        else
            GUI_Military.ErectMouseOver_Orig_ModuleSelection();
            return;
        end
        GUI_Tooltip.TooltipNormal(TooltipTextKey, "Erect");
    end
end

function ModuleSelection.Local:OverwriteMilitaryDisamble()
    GUI_Military.DisassembleClicked_Orig_ModuleSelection = GUI_Military.DisassembleClicked;
    GUI_Military.DisassembleClicked = function()
        GUI_Military.DisassembleClicked_Orig_ModuleSelection();
        local SelectedEntities = {GUI.GetSelectedEntities()};
        for i=1, #SelectedEntities, 1 do
            local EntityType = Logic.GetEntityType(SelectedEntities[i]);
            if EntityType == Entities.U_Trebuchet then
                API.BroadcastScriptCommand(
                    QSB.ScriptCommands.SelectionDisambleTrebuchet,
                    SelectedEntities[i]
                );
            end
        end
    end

    GUI_Military.DisassembleMouseOver_Orig_ModuleSelection = GUI_Military.DisassembleMouseOver;
    GUI_Military.DisassembleMouseOver = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
        local PlayerID = GUI.GetPlayerID()
        local SiegeEngineID = GUI.GetSelectedEntity()
        local TooltipDisabledTextKey
        if Logic.IsSiegeEngineUnderConstruction(SiegeEngineID) == true then
            TooltipDisabledTextKey = "Disassemble"
        else
            TooltipDisabledTextKey = "DisassembleNoSoldiersAttached"
            if not ModuleSelection.Local.TrebuchetDisassemble then
                TooltipDisabledTextKey = "Disassemble";
            end
        end
        GUI_Tooltip.TooltipNormal(nil, TooltipDisabledTextKey)
    end

    GUI_Military.DisassembleUpdate_Orig_ModuleSelection = GUI_Military.DisassembleUpdate;
    GUI_Military.DisassembleUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local SiegeEngineID = GUI.GetSelectedEntity();
        local EntityType = Logic.GetEntityType(SiegeEngineID);
        if EntityType == Entities.U_Trebuchet then
            local Disabled = (ModuleSelection.Local.TrebuchetDisassemble and 0) or 1;
            XGUIEng.DisableButton(CurrentWidgetID, Disabled);
            SetIcon(CurrentWidgetID, {12, 9});
        else
            GUI_Military.DisassembleUpdate_Orig_ModuleSelection();
        end
    end
end

function ModuleSelection.Local:OnSelectionCanged(_Source)
    local OldSelection = self.SelectedEntities or {};
    local SelectedEntities = {GUI.GetSelectedEntities()};
    local PlayerID = GUI.GetPlayerID();
    local EntityID = GUI.GetSelectedEntity();
    local EntityType = Logic.GetEntityType(EntityID);

    local OldSelectionString = Swift.LuaBase:ConvertTableToString(self.SelectedEntities[PlayerID] or {});
    self.SelectedEntities[PlayerID] = SelectedEntities;
    local NewSelectionString = Swift.LuaBase:ConvertTableToString(self.SelectedEntities[PlayerID] or {});

    -- This event is only send on the local machine. Only the local player
    -- can select units, so the event musn't be send to other players!
    API.SendScriptEvent(
        QSB.ScriptEvents.SelectionChanged,
        PlayerID,
        OldSelection[PlayerID],
        SelectedEntities
    );
    API.SendScriptEventToGlobal(
        "SelectionChanged",
        PlayerID,
        OldSelection[PlayerID],
        SelectedEntities
    );

    if EntityID ~= nil then
        if EntityType == Entities.U_SiegeEngineCart then
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/BGMilitary", 1);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/DialogButtons", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/SiegeEngineCart", 1);
        elseif EntityType == Entities.U_Trebuchet then
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/BGMilitary", 1);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/DialogButtons", 0);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military", 1);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military", 1);
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military/Attack", 0);
            GUI_Military.StrengthUpdate();
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/SiegeEngine", 1);
        end
    end
end

function ModuleSelection.Local:OverwriteMultiselectIcon()
    GUI_MultiSelection.IconUpdate_Orig_ModuleSelection = GUI_MultiSelection.IconUpdate;
    GUI_MultiSelection.IconUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local CurrentMotherID = XGUIEng.GetWidgetsMotherID(CurrentWidgetID);
        local CurrentMotherName = XGUIEng.GetWidgetNameByID(CurrentMotherID);
        local Index = CurrentMotherName + 0;
        local CurrentMotherPath = XGUIEng.GetWidgetPathByID(CurrentMotherID);
        local HealthWidgetPath = CurrentMotherPath .. "/Health";
        local EntityID = g_MultiSelection.EntityList[Index];
        local EntityType = Logic.GetEntityType(EntityID);
        local HealthState = Logic.GetEntityHealth(EntityID);
        local EntityMaxHealth = Logic.GetEntityMaxHealth(EntityID);
        if EntityType ~= Entities.U_SiegeEngineCart and EntityType ~= Entities.U_Trebuchet then
            GUI_MultiSelection.IconUpdate_Orig_ModuleSelection();
            return;
        end
        if Logic.IsEntityAlive(EntityID) == false then
            XGUIEng.ShowWidget(CurrentMotherID, 0);
            GUI_MultiSelection.CreateEX();
            return;
        end
        SetIcon(CurrentWidgetID, g_TexturePositions.Entities[EntityType]);
        HealthState = math.floor(HealthState / EntityMaxHealth * 100);
        if HealthState < 50 then
            local green = math.floor(2*255* (HealthState/100));
            XGUIEng.SetMaterialColor(HealthWidgetPath,0,255,green, 20,255);
        else
            local red = 2*255 - math.floor(2*255* (HealthState/100));
            XGUIEng.SetMaterialColor(HealthWidgetPath,0,red, 255, 20,255);
        end
        XGUIEng.SetProgressBarValues(HealthWidgetPath,HealthState, 100);
    end

    GUI_MultiSelection.IconMouseOver_Orig_ModuleSelection = GUI_MultiSelection.IconMouseOver;
    GUI_MultiSelection.IconMouseOver = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local CurrentMotherID = XGUIEng.GetWidgetsMotherID(CurrentWidgetID);
        local CurrentMotherName = XGUIEng.GetWidgetNameByID(CurrentMotherID);
        local Index = tonumber(CurrentMotherName);
        local EntityID = g_MultiSelection.EntityList[Index];
        local EntityType = Logic.GetEntityType(EntityID);
        if EntityType ~= Entities.U_SiegeEngineCart and EntityType ~= Entities.U_Trebuchet then
            GUI_MultiSelection.IconMouseOver_Orig_ModuleSelection();
            return;
        end
        if EntityType == Entities.U_SiegeEngineCart then
            local TooltipData = API.Localize(ModuleSelection.Shared.Text.Tooltips.TrebuchetCart);
            API.SetTooltipNormal(TooltipData.Title, TooltipData.Text);
        elseif EntityType == Entities.U_Trebuchet then
            local TooltipData = API.Localize(ModuleSelection.Shared.Text.Tooltips.Trebuchet);
            API.SetTooltipNormal(TooltipData.Title, TooltipData.Text);
        end
    end
end

function ModuleSelection.Local:OverwriteMilitaryDismount()
    GUI_Military.DismountClicked_Orig_ModuleSelection = GUI_Military.DismountClicked;
    GUI_Military.DismountClicked = function()
        local Selected = GUI.GetSelectedEntity();
        local Type = Logic.GetEntityType(Selected);
        local Guarded = Logic.GetGuardedEntityID(Selected);
        local Guardian = Logic.GetGuardianEntityID(Selected);
        if Guarded ~= 0 and Logic.EntityGetPlayer(Guarded) ~= GUI.GetPlayerID() then
            GUI_Military.DismountClicked_Orig_ModuleSelection();
            return;
        end
        if Logic.IsKnight(Selected) or Logic.IsEntityInCategory(Selected, EntityCategories.AttackableMerchant) == 1 then
            GUI_Military.DismountClicked_Orig_ModuleSelection();
            return;
        end
        if Logic.IsLeader(Selected) == 1 and Guarded == 0 then
            if ModuleSelection.Local.MilitaryRelease then
                Sound.FXPlay2DSound( "ui\\menu_click");
                local Soldiers = {Logic.GetSoldiersAttachedToLeader(Selected)};
                API.BroadcastScriptCommand(QSB.ScriptCommands.SelectionDestroyEntity, Soldiers[#Soldiers]);
                return;
            end
        end
        if Type == Entities.U_AmmunitionCart or Type == Entities.U_BatteringRamCart
        or Type == Entities.U_CatapultCart or Type == Entities.U_SiegeTowerCart
        or Type == Entities.U_MilitaryBatteringRam or Entities.U_MilitaryCatapult
        or Type == Entities.U_MilitarySiegeTower then
            if ModuleSelection.Local.SiegeEngineRelease and Guardian == 0 then
                Sound.FXPlay2DSound( "ui\\menu_click");
                API.BroadcastScriptCommand(QSB.ScriptCommands.SelectionDestroyEntity, Selected);
            else
                GUI_Military.DismountClicked_Orig_ModuleSelection();
            end
        end
    end

    GUI_Military.DismountUpdate_Orig_ModuleSelection = GUI_Military.DismountUpdate;
    GUI_Military.DismountUpdate = function()
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local Selected = GUI.GetSelectedEntity();
        local Type = Logic.GetEntityType(Selected);
        local Guarded = Logic.GetGuardedEntityID(Selected);
        local Guardian = Logic.GetGuardianEntityID(Selected);
        SetIcon(CurrentWidgetID, {12, 1});
        if Guarded ~= 0 and Logic.EntityGetPlayer(Guarded) ~= GUI.GetPlayerID() then
            XGUIEng.DisableButton(CurrentWidgetID, 0);
            GUI_Military.DismountUpdate_Orig_ModuleSelection();
            return;
        end
        if Logic.IsKnight(Selected) or Logic.IsEntityInCategory(Selected, EntityCategories.AttackableMerchant) == 1 then
            XGUIEng.DisableButton(CurrentWidgetID, 0);
            GUI_Military.DismountUpdate_Orig_ModuleSelection();
            return;
        end
        SetIcon(CurrentWidgetID, {14, 12});
        if Type == Entities.U_MilitaryLeader then
            if not ModuleSelection.Local.MilitaryRelease then
                XGUIEng.DisableButton(CurrentWidgetID, 1);
            else
                XGUIEng.DisableButton(CurrentWidgetID, 0);
            end
            return;
        end
        if Type == Entities.U_AmmunitionCart or Type == Entities.U_BatteringRamCart
        or Type == Entities.U_CatapultCart or Type == Entities.U_SiegeTowerCart
        or Type == Entities.U_MilitaryBatteringRam or Entities.U_MilitaryCatapult
        or Type == Entities.U_MilitarySiegeTower then
            if Guardian ~= 0 then
                SetIcon(CurrentWidgetID, {12, 1});
                XGUIEng.DisableButton(CurrentWidgetID, 0);
            else
                if not ModuleSelection.Local.SiegeEngineRelease then
                    XGUIEng.DisableButton(CurrentWidgetID, 1);
                else
                    XGUIEng.DisableButton(CurrentWidgetID, 0);
                end
            end
        end
    end
end

function ModuleSelection.Local:OverwriteThiefDeliver()
    GUI_Thief.ThiefDeliverClicked_Orig_ModuleSelection = GUI_Thief.ThiefDeliverClicked;
    GUI_Thief.ThiefDeliverClicked = function()
        if not ModuleSelection.Local.ThiefRelease then
            GUI_Thief.ThiefDeliverClicked_Orig_ModuleSelection();
            return;
        end
        Sound.FXPlay2DSound( "ui\\menu_click");
        local ThiefID = GUI.GetSelectedEntity()
        if ThiefID == nil or Logic.GetEntityType(ThiefID) ~= Entities.U_Thief then
            return;
        end
        API.BroadcastScriptCommand(QSB.ScriptCommands.SelectionDestroyEntity, ThiefID);
    end

    GUI_Thief.ThiefDeliverMouseOver_Orig_ModuleSelection = GUI_Thief.ThiefDeliverMouseOver;
    GUI_Thief.ThiefDeliverMouseOver = function()
        if not ModuleSelection.Local.ThiefRelease then
            GUI_Thief.ThiefDeliverMouseOver_Orig_ModuleSelection();
            return;
        end
        local Text = API.Localize(ModuleSelection.Shared.Text.Tooltips.ReleaseSoldiers);
        API.SetTooltipNormal(Text.Title, Text.Text, Text.Disabled);
    end

    GUI_Thief.ThiefDeliverUpdate_Orig_ModuleSelection = GUI_Thief.ThiefDeliverUpdate;
    GUI_Thief.ThiefDeliverUpdate = function()
        if not ModuleSelection.Local.ThiefRelease then
            GUI_Thief.ThiefDeliverUpdate_Orig_ModuleSelection();
            return;
        end
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local ThiefID = GUI.GetSelectedEntity();
        if ThiefID == nil or Logic.GetEntityType(ThiefID) ~= Entities.U_Thief then
            XGUIEng.DisableButton(CurrentWidgetID, 1);
        else
            XGUIEng.DisableButton(CurrentWidgetID, 0);
        end
        SetIcon(CurrentWidgetID, {14, 12});
    end
end

function ModuleSelection.Local:OverwriteSelectKnight()
    GUI_Knight.JumpToButtonClicked = function()
        local PlayerID = GUI.GetPlayerID();
        local KnightID = Logic.GetKnightID(PlayerID);
        if KnightID > 0 then
            g_MultiSelection.EntityList = {};
            g_MultiSelection.Highlighted = {};
            GUI.ClearSelection();
            if XGUIEng.IsModifierPressed(Keys.ModifierControl) then
                local knights = {}
                Logic.GetKnights(PlayerID, knights);
                for i=1,#knights do
                    GUI.SelectEntity(knights[i]);
                end
            else
                GUI.SelectEntity(Logic.GetKnightID(PlayerID));
                if ((Framework.GetTimeMs() - g_Selection.LastClickTime ) < g_Selection.MaxDoubleClickTime) then
                    local pos = GetPosition(KnightID);
                    Camera.RTS_SetLookAtPosition(pos.X, pos.Y);
                else
                    Sound.FXPlay2DSound("ui\\mini_knight");
                end
                g_Selection.LastClickTime = Framework.GetTimeMs();
            end
            GUI_MultiSelection.CreateMultiSelection(g_SelectionChangedSource.User);
        else
            GUI.AddNote("Debug: You do not have a knight");
        end
    end
end

function ModuleSelection.Local:OverwriteSelectAllUnits()
    GUI_MultiSelection.SelectAllPlayerUnitsClicked = function()
        if XGUIEng.IsModifierPressed(Keys.ModifierShift) then
            ModuleSelection.Local:ExtendedLeaderSortOrder();
        else
            ModuleSelection.Local:NormalLeaderSortOrder();
        end
        Sound.FXPlay2DSound("ui\\menu_click");
        GUI.ClearSelection();
        local PlayerID = GUI.GetPlayerID()
        for i = 1, #LeaderSortOrder do
            local EntitiesOfThisType = GetPlayerEntities(PlayerID, LeaderSortOrder[i])
            for j = 1, #EntitiesOfThisType do
                GUI.SelectEntity(EntitiesOfThisType[j])
            end
        end
        local Knights = {}
        Logic.GetKnights(PlayerID, Knights)
        for k = 1, #Knights do
            GUI.SelectEntity(Knights[k])
        end
        GUI_MultiSelection.CreateMultiSelection(g_SelectionChangedSource.User);
    end
end

function ModuleSelection.Local:NormalLeaderSortOrder()
    g_MultiSelection = {};
    g_MultiSelection.EntityList = {};
    g_MultiSelection.Highlighted = {};

    LeaderSortOrder     = {};
    LeaderSortOrder[1]  = Entities.U_MilitarySword;
    LeaderSortOrder[2]  = Entities.U_MilitaryBow;
    LeaderSortOrder[3]  = Entities.U_MilitarySword_RedPrince;
    LeaderSortOrder[4]  = Entities.U_MilitaryBow_RedPrince;
    LeaderSortOrder[5]  = Entities.U_MilitaryBandit_Melee_ME;
    LeaderSortOrder[6]  = Entities.U_MilitaryBandit_Melee_NA;
    LeaderSortOrder[7]  = Entities.U_MilitaryBandit_Melee_NE;
    LeaderSortOrder[8]  = Entities.U_MilitaryBandit_Melee_SE;
    LeaderSortOrder[9]  = Entities.U_MilitaryBandit_Ranged_ME;
    LeaderSortOrder[10] = Entities.U_MilitaryBandit_Ranged_NA;
    LeaderSortOrder[11] = Entities.U_MilitaryBandit_Ranged_NE;
    LeaderSortOrder[12] = Entities.U_MilitaryBandit_Ranged_SE;
    LeaderSortOrder[13] = Entities.U_MilitaryCatapult;
    LeaderSortOrder[14] = Entities.U_MilitarySiegeTower;
    LeaderSortOrder[15] = Entities.U_MilitaryBatteringRam;
    LeaderSortOrder[16] = Entities.U_CatapultCart;
    LeaderSortOrder[17] = Entities.U_SiegeTowerCart;
    LeaderSortOrder[18] = Entities.U_BatteringRamCart;

    -- Asien wird nur in der Erweiterung gebraucht.
    if g_GameExtraNo >= 1 then
        table.insert(LeaderSortOrder,  4, Entities.U_MilitarySword_Khana);
        table.insert(LeaderSortOrder,  6, Entities.U_MilitaryBow_Khana);
        table.insert(LeaderSortOrder,  7, Entities.U_MilitaryBandit_Melee_AS);
        table.insert(LeaderSortOrder, 12, Entities.U_MilitaryBandit_Ranged_AS);
    end

    -- Community Patch
    if Entities.U_MilitaryCavalry then
        table.insert(LeaderSortOrder,  2, Entities.U_MilitaryCavalry);
    end
    if Entities.U_MilitaryPoleArm then
        table.insert(LeaderSortOrder,  2, Entities.U_MilitaryPoleArm);
    end
    if Entities.U_MilitaryCannon then
        table.insert(LeaderSortOrder,  17, Entities.U_MilitaryCannon);
    end
end

function ModuleSelection.Local:ExtendedLeaderSortOrder()
    g_MultiSelection = {};
    g_MultiSelection.EntityList = {};
    g_MultiSelection.Highlighted = {};

    LeaderSortOrder     = {};
    LeaderSortOrder[1]  = Entities.U_MilitarySword;
    LeaderSortOrder[2]  = Entities.U_MilitaryBow;
    LeaderSortOrder[3]  = Entities.U_MilitarySword_RedPrince;
    LeaderSortOrder[4]  = Entities.U_MilitaryBow_RedPrince;
    LeaderSortOrder[5]  = Entities.U_MilitaryBandit_Melee_ME;
    LeaderSortOrder[6]  = Entities.U_MilitaryBandit_Melee_NA;
    LeaderSortOrder[7]  = Entities.U_MilitaryBandit_Melee_NE;
    LeaderSortOrder[8]  = Entities.U_MilitaryBandit_Melee_SE;
    LeaderSortOrder[9]  = Entities.U_MilitaryBandit_Ranged_ME;
    LeaderSortOrder[10] = Entities.U_MilitaryBandit_Ranged_NA;
    LeaderSortOrder[11] = Entities.U_MilitaryBandit_Ranged_NE;
    LeaderSortOrder[12] = Entities.U_MilitaryBandit_Ranged_SE;
    LeaderSortOrder[13] = Entities.U_MilitaryCatapult;
    LeaderSortOrder[14] = Entities.U_Trebuchet;
    LeaderSortOrder[15] = Entities.U_MilitarySiegeTower;
    LeaderSortOrder[16] = Entities.U_MilitaryBatteringRam;
    LeaderSortOrder[17] = Entities.U_CatapultCart;
    LeaderSortOrder[18] = Entities.U_SiegeTowerCart;
    LeaderSortOrder[19] = Entities.U_BatteringRamCart;
    LeaderSortOrder[20] = Entities.U_AmmunitionCart;
    LeaderSortOrder[21] = Entities.U_Thief;

    -- Asien wird nur in der Erweiterung gebraucht.
    if g_GameExtraNo >= 1 then
        table.insert(LeaderSortOrder,  4, Entities.U_MilitarySword_Khana);
        table.insert(LeaderSortOrder,  6, Entities.U_MilitaryBow_Khana);
        table.insert(LeaderSortOrder,  7, Entities.U_MilitaryBandit_Melee_AS);
        table.insert(LeaderSortOrder, 12, Entities.U_MilitaryBandit_Ranged_AS);
    end

    -- Community Patch
    if Entities.U_MilitaryCavalry then
        table.insert(LeaderSortOrder,  2, Entities.U_MilitaryCavalry);
    end
    if Entities.U_MilitaryPoleArm then
        table.insert(LeaderSortOrder,  2, Entities.U_MilitaryPoleArm);
    end
    if Entities.U_MilitaryCannon then
        table.insert(LeaderSortOrder,  17, Entities.U_MilitaryCannon);
    end
end

function ModuleSelection.Local:OverwriteNamesAndDescription()
    GUI_Tooltip.SetNameAndDescription_Orig_ModuleSelection = GUI_Tooltip.SetNameAndDescription;
    GUI_Tooltip.SetNameAndDescription = function(
        _TooltipNameWidget, _TooltipDescriptionWidget, _OptionalTextKeyName,
        _OptionalDisabledTextKeyName, _OptionalMissionTextFileBoolean
    )
        local MotherWidget = "/InGame/Root/Normal/AlignBottomRight";
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();

        if XGUIEng.GetWidgetID(MotherWidget.. "/MapFrame/KnightButton") == CurrentWidgetID then
            local Text = API.Localize(ModuleSelection.Shared.Text.Tooltips.KnightButton);
            API.SetTooltipNormal(Text.Title, Text.Text);
            return;
        end

        if XGUIEng.GetWidgetID(MotherWidget.. "/MapFrame/BattalionButton") == CurrentWidgetID then
            local Text = API.Localize(ModuleSelection.Shared.Text.Tooltips.BattalionButton);
            API.SetTooltipNormal(Text.Title, Text.Text);
            return;
        end

        if XGUIEng.GetWidgetID(MotherWidget.. "/DialogButtons/SiegeEngineCart/Dismount") == CurrentWidgetID
        or XGUIEng.GetWidgetID(MotherWidget.. "/DialogButtons/AmmunitionCart/Dismount") == CurrentWidgetID
        or XGUIEng.GetWidgetID(MotherWidget.. "/DialogButtons/Military/Dismount") == CurrentWidgetID
        then
            local SelectedEntity = GUI.GetSelectedEntity();
            if SelectedEntity ~= 0 then
                if Logic.IsEntityInCategory(SelectedEntity, EntityCategories.Military) == 1 then
                    local GuardianEntity = Logic.GetGuardianEntityID(SelectedEntity);
                    local GuardedEntity = Logic.GetGuardedEntityID(SelectedEntity);
                    if GuardianEntity == 0 and GuardedEntity == 0 then
                        local Text = API.Localize(ModuleSelection.Shared.Text.Tooltips.ReleaseSoldiers);
                        API.SetTooltipNormal(Text.Title, Text.Text, Text.Disabled);
                        return;
                    end
                end
            end
        end

        GUI_Tooltip.SetNameAndDescription_Orig_ModuleSelection(
            _TooltipNameWidget, _TooltipDescriptionWidget, _OptionalTextKeyName,
            _OptionalDisabledTextKeyName, _OptionalMissionTextFileBoolean
        );
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleSelection);

