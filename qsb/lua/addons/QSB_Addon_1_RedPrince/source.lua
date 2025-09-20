-- -------------------------------------------------------------------------- --

Addon_RedPrince = {
    Properties = {
        Name = "Addon_RedPrince",
        Version = "1.0.0",
    },

    Global = {
        -- Die Globalen Funktionen und Daten des Addons
        Data = {},
    },

    Local = {
        -- Die Lokalen Funktionen und Daten des Addons
        Data = {
            RechargeTime = 4 * 60,
            ActionPoints = 4 * 60,
            Icon = {5, 16},
            Description = {
                Title = {de = "Epidemie",
                         en = "Epidemic"},
                Text  = {de = "- Macht die Siedler einer beliebigen anderen Partei krank.",
                         en = "- Makes the settlers of another player sick."},
            }
        }
    },

    Shared = {
        -- Funktionen und Daten des Addons die jeweils in beiden Scripten
        -- vorhanden sein sollen
    },
}

-- Global ------------------------------------------------------------------- --

function Addon_RedPrince.Global:OnGameStart()
    -- Was zum Spielstart im Globalen Script ausgeführt werden sollte
end

function Addon_RedPrince.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        -- Was nach dem laden eines Spielstandes ausgeführt werden sollte
        return
    end
end


function Addon_RedPrince.Global:UseKnightAbility(_ID)
    local PlayerID = Logic.EntityGetPlayer(_ID);
    local TerritoryID = GetTerritoryUnderEntity(_ID);
    local TerritoryOwner = Logic.GetTerritoryPlayerID(TerritoryID);
    local Targets = self:GetTargets(TerritoryOwner, TerritoryID);
    for i= 1, #Targets, 1 do
        if math.random(1, 100) <= 30 then
            Logic.MakeBuildingIll(Targets[i]);
        end
    end
end

function Addon_RedPrince.Global:GetTargets(_PlayerID, _TerritoryID)
    local City = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)};
    City = Array_Append(City, {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)});

    local Buildings = {};
    for i= 1, #City, 1 do
        if Logic.IsConstructionComplete(City[i]) == 1 and GetTerritoryUnderEntity(City[i]) == _TerritoryID then
            table.insert(Buildings, City[i]);
        end
    end
    return Buildings;
end

-- Local -------------------------------------------------------------------- --

function Addon_RedPrince.Local:OnGameStart()
    g_MilitaryFeedback.Knights[Entities.U_KnightRedPrince]    = "H_Knight_RedPrince";
    g_HeroAbilityFeedback.Knights[Entities.U_KnightRedPrince] = "RedPrince";
    self:OverwriteKnightAbilityButton()
    self:RechargeAbility();
end

function Addon_RedPrince.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        -- Was nach dem laden eines Spielstandes ausgeführt werden sollte
        return
    end
end

function Addon_RedPrince.Local:RechargeAbility()
    StartSimpleJobEx(function()
        if Addon_RedPrince.Local.Data.ActionPoints < Addon_RedPrince.Local.Data.RechargeTime then
            Addon_RedPrince.Local.Data.ActionPoints = Addon_RedPrince.Local.Data.ActionPoints +1;
        end
    end)
end

function Addon_RedPrince.Local:KnightAbilityClicked(_ID, _WidgetID)
    local PlayerID = Logic.EntityGetPlayer(_ID);
    local TerritoryID = GetTerritoryUnderEntity(_ID);
    local TerritoryOwner = Logic.GetTerritoryPlayerID(TerritoryID);
    if TerritoryOwner == 0 or TerritoryOwner == PlayerID or self.Data.ActionPoints < self.Data.RechargeTime then
        return;
    end
    GUI.SendScriptCommand("Addon_RedPrince.Global:UseKnightAbility('" .._ID.."')");
    self.Data.ActionPoints = 0;
end

function Addon_RedPrince.Local:KnightAbilityTooltip(_ID, _WidgetID)
    _title = API.Localize(self.Data.Description.Title[QSB.Language] or "");
    _text = API.Localize(self.Data.Description.Text[QSB.Language] or "");
    _disabledText = "";

    local TooltipContainerPath = "/InGame/Root/Normal/TooltipNormal"
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath)
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name")
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text")
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG")
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn")
    local PositionWidget = XGUIEng.GetCurrentWidgetID()
    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget)
    local TooltipContainerSizeWidgets = {TooltipBGWidget}
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget)
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer)

    local disabled = "";
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _disabledText ~= "" and _text ~= "" then
        disabled = disabled .. "{cr}{@color:255,32,32,255}" .. _disabledText
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. _title)
    XGUIEng.SetText(TooltipDescriptionWidget, _text .. disabled)
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true)
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget)
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height)
end

function Addon_RedPrince.Local:KnightAbilityUpdate(_ID, _WidgetID)
    SetIcon(_WidgetID, self.Data.Icon);
    local RechargeTime = self.Data.RechargeTime;
    local ActionPoints = self.Data.ActionPoints;
    if ActionPoints < RechargeTime then
        XGUIEng.DisableButton(_WidgetID, 1);
    else
        XGUIEng.DisableButton(_WidgetID, 0);
    end
end

function Addon_RedPrince.Local:KnightAbilityProgress(_ID, _WidgetID)
    local TotalRechargeTime  = self.Data.RechargeTime;
    local ActionPoints       = self.Data.ActionPoints;
    local TimeAlreadyCharged = ActionPoints or TotalRechargeTime;
    TimeAlreadyCharged = (TimeAlreadyCharged > TotalRechargeTime and TotalRechargeTime) or TimeAlreadyCharged;
    if TimeAlreadyCharged == TotalRechargeTime then
        XGUIEng.SetMaterialColor(_WidgetID, 0, 255, 255, 255, 0);
    else
        XGUIEng.SetMaterialColor(_WidgetID, 0, 255, 255, 255, 150);
        local Progress = math.floor((TimeAlreadyCharged / TotalRechargeTime) * 100);
        XGUIEng.SetProgressBarValues(_WidgetID, Progress + 10, 110);
    end
end

function Addon_RedPrince.Local:OverwriteKnightAbilityButton()
    GUI_Knight.StartAbilityClicked_OrigRP = GUI_Knight.StartAbilityClicked;
    GUI_Knight.StartAbilityClicked = function(_Ability)
        local ID = GUI.GetSelectedEntity();
        if ID == 0 then
            return;
        end
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local Type = Logic.GetEntityType(ID);
        if Type ~= Entities.U_KnightRedPrince then
            return GUI_Knight.StartAbilityClicked_OrigRP(_Ability);
        end
        Addon_RedPrince.Local:KnightAbilityClicked(ID, WidgetID);
    end

    GUI_Knight.StartAbilityMouseOver_OrigRP = GUI_Knight.StartAbilityMouseOver;
    GUI_Knight.StartAbilityMouseOver = function()
        local ID = GUI.GetSelectedEntity();
        if ID == 0 then
            return;
        end
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local Type = Logic.GetEntityType(ID);
        if Type ~= Entities.U_KnightRedPrince then
            return GUI_Knight.StartAbilityMouseOver_OrigRP();
        end
        Addon_RedPrince.Local:KnightAbilityTooltip(ID, WidgetID);
    end

    GUI_Knight.StartAbilityUpdate_OrigRP = GUI_Knight.StartAbilityUpdate;
    GUI_Knight.StartAbilityUpdate = function()
        local ID = GUI.GetSelectedEntity();
        if ID == 0 then
            return;
        end
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local Type = Logic.GetEntityType(ID);
        if Type ~= Entities.U_KnightRedPrince then
            return GUI_Knight.StartAbilityUpdate_OrigRP();
        end
        Addon_RedPrince.Local:KnightAbilityUpdate(ID, WidgetID);
    end

    GUI_Knight.AbilityProgressUpdate_OrigRP = GUI_Knight.AbilityProgressUpdate;
    GUI_Knight.AbilityProgressUpdate = function()
        local ID = GUI.GetSelectedEntity();
        if ID == 0 then
            return;
        end
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local Type = Logic.GetEntityType(ID);
        if Type ~= Entities.U_KnightRedPrince then
            return GUI_Knight.AbilityProgressUpdate_OrigRP();
        end
        Addon_RedPrince.Local:KnightAbilityProgress(ID, WidgetID);
    end
end

-- Shared ------------------------------------------------------------------- --

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(Addon_RedPrince)