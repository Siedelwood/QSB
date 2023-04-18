-- -------------------------------------------------------------------------- --

---
-- Stellt Minen bereit, die wie Ruinen aktiviert werden können.
-- 
-- Der Spieler kann eine Stein- oder Eisenmine restaurieren, die zuerst durch
-- Begleichen der Kosten aufgebaut werden muss, bevor sie genutzt werden kann.
-- <br>Optional kann die Mine einstürzen, wenn sie ausgebeutet wurde.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- <li><a href="modules.QSB_2_Objects.QSB_2_Objects.html">(2) Interaktive Objekte</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field InteractiveMineDepleted  Eine ehemals interaktive Mine wurde ausgebeutet (Parameter: ScriptName)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erstelle eine verschüttete Eisenmine.
--
-- Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
-- 20 Holz.
--
-- Die Parameter der interaktiven Mine werden durch ihre Beschreibung
-- festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
-- Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.
--
-- Mögliche Angaben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- <td><b>Optional</b></td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>string</td>
-- <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
-- <td>nein</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string</td>
-- <td>Angezeigter Titel der Beschreibung für die Mine</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string</td>
-- <td>Angezeigte Text der Beschreibung für die Mine</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Costs</td>
-- <td>table</td>
-- <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ResourceAmount</td>
-- <td>number</td>
-- <td>Menge an Rohstoffen nach der Aktivierung</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>RefillAmount</td>
-- <td>number</td>
-- <td>Menge an Rohstoffen, die ein Geologe auffüllt (0 == nicht nachfüllbar)</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ConstructionCondition</td>
-- <td>function</td>
-- <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ConstructionAction</td>
-- <td>function</td>
-- <td>Eine zusätzliche Aktion nach der Aktivierung.</td>
-- <td>ja</td>
-- </tr>
-- </table>
--
-- @param[type=table] _Data Datentabelle der Mine
-- @within Anwenderfunktionen
-- @see API.CreateIOStoneMine
--
-- @usage
-- -- Beispiel #1: Eine einfache Mine
-- API.CreateIOIronMine{
--     Position = "mine"
-- };
--
-- @usage
-- -- Beispiel #2: Mine mit geänderten Kosten
-- API.CreateIOIronMine{
--     Position = "mine",
--     Costs    = {Goods.G_Wood, 15}
-- };
--
-- @usage
-- -- Beispiel #3: Mine mit Aktivierungsbedingung
-- API.CreateIOIronMine{
--     Position              = "mine",
--     Costs                 = {Goods.G_Wood, 15},
--     ConstructionCondition = function(_Data)
--         return HeroHasShovel == true;
--     end
-- };
--
function API.CreateIOIronMine(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Position) then
        error("API.CreateIOIronMine: Position (" ..tostring(_Data.Position).. ") does not exist!");
        return;
    end

    local Costs = {Goods.G_Gold, 500, Goods.G_Wood, 20};
    if _Data.Costs then
        if _Data.Costs[1] then
            if GetNameOfKeyInTable(Goods, _Data.Costs[1]) == nil then
                error("API.CreateIOIronMine: First cost type (" ..tostring(_Data.Costs[1]).. ") is wrong!");
                return;
            end
            if _Data.Costs[2] and (type(_Data.Costs[2]) ~= "number" or _Data.Costs[2] < 1) then
                error("API.CreateIOIronMine: First cost amount must be above 0!");
                return;
            end
        end
        if _Data.Costs[3] then
            if GetNameOfKeyInTable(Goods, _Data.Costs[3]) == nil then
                error("API.CreateIOIronMine: Second cost type (" ..tostring(_Data.Costs[3]).. ") is wrong!");
                return;
            end
            if _Data.Costs[4] and (type(_Data.Costs[4]) ~= "number" or _Data.Costs[4] < 1) then
                error("API.CreateIOIronMine: Second cost amount must be above 0!");
                return;
            end
        end
        Costs = _Data.Costs;
    end

    ModuleInteractiveMines.Global:CreateIOMine(
        _Data.Position,
        Entities.R_IronMine,
        _Data.Title,
        _Data.Text,
        Costs,
        _Data.ResourceAmount,
        _Data.RefillAmount,
        _Data.ConstructionCondition,
        _Data.ConditionInfo,
        _Data.ConstructionAction
    );
end

---
-- Erstelle eine verschüttete Steinmine.
--
-- Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
-- 20 Holz.
--
-- Die Parameter der interaktiven Mine werden durch ihre Beschreibung
-- festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
-- Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.
--
-- Mögliche Angaben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- <td><b>Optional</b></td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>string</td>
-- <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
-- <td>nein</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string</td>
-- <td>Angezeigter Titel der Beschreibung für die Mine</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string</td>
-- <td>Angezeigte Text der Beschreibung für die Mine</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Costs</td>
-- <td>table</td>
-- <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <tr>
-- <td>ResourceAmount</td>
-- <td>number</td>
-- <td>Menge an Rohstoffen nach der Aktivierung</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>RefillAmount</td>
-- <td>number</td>
-- <td>Menge an Rohstoffen, die ein Geologe auffüllt (0 == nicht nachfüllbar)</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ConstructionCondition</td>
-- <td>function</td>
-- <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ConstructionAction</td>
-- <td>function</td>
-- <td>Eine zusätzliche Aktion nach der Aktivierung.</td>
-- <td>ja</td>
-- </tr>
-- </table>
--
-- @param[type=table] _Data Datentabelle der Mine
-- @within Anwenderfunktionen
-- @see API.CreateIOIronMine
--
-- @usage
-- -- Beispiel #1: Eine einfache Mine
-- API.CreateIOStoneMine{
--     Position = "mine"
-- };
--
-- @usage
-- -- Beispiel #2: Mine mit geänderten Kosten
-- API.CreateIOStoneMine{
--     Position = "mine",
--     Costs    = {Goods.G_Wood, 15}
-- };
--
-- @usage
-- -- Beispiel #3: Mine mit Aktivierungsbedingung
-- API.CreateIOStoneMine{
--     Position              = "mine",
--     Costs                 = {Goods.G_Wood, 15},
--     ConstructionCondition = function(_Data)
--         return HeroHasPickaxe == true;
--     end
-- };
--
function API.CreateIOStoneMine(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Position) then
        error("API.CreateIOStoneMine: Position (" ..tostring(_Data.Position).. ") does not exist!");
        return;
    end

    local Costs = {Goods.G_Gold, 500, Goods.G_Wood, 20};
    if _Data.Costs then
        if _Data.Costs[1] then
            if GetNameOfKeyInTable(Goods, _Data.Costs[1]) == nil then
                error("API.CreateIOStoneMine: First cost type (" ..tostring(_Data.Costs[1]).. ") is wrong!");
                return;
            end
            if _Data.Costs[2] and (type(_Data.Costs[2]) ~= "number" or _Data.Costs[2] < 1) then
                error("API.CreateIOStoneMine: First cost amount must be above 0!");
                return;
            end
        end
        if _Data.Costs[3] then
            if GetNameOfKeyInTable(Goods, _Data.Costs[3]) == nil then
                error("API.CreateIOStoneMine: Second cost type (" ..tostring(_Data.Costs[3]).. ") is wrong!");
                return;
            end
            if _Data.Costs[4] and (type(_Data.Costs[4]) ~= "number" or _Data.Costs[4] < 1) then
                error("API.CreateIOStoneMine: Second cost amount must be above 0!");
                return;
            end
        end
        Costs = _Data.Costs;
    end

    ModuleInteractiveMines.Global:CreateIOMine(
        _Data.Position,
        Entities.R_StoneMine,
        _Data.Title,
        _Data.Text,
        Costs,
        _Data.ResourceAmount,
        _Data.RefillAmount,
        _Data.ConstructionCondition,
        _Data.ConditionInfo,
        _Data.ConstructionAction
    );
end

-- -------------------------------------------------------------------------- --

ModuleInteractiveMines = {
    Properties = {
        Name = "ModuleInteractiveMines",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {
        Mines = {},
        Lambda = {
            MineCondition = {},
            MineConstructed = {},
            InteractiveMineDepleted = {},
        }
    },
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Text = {
            Title = {
                de = "Rohstoffquelle erschließen",
                en = "Construct mine",
                fr = "Exploiter la source de ressources",
            },
            Text = {
                de = "An diesem Ort könnt Ihr eine Rohstoffquelle erschließen!",
                en = "You're able to create a pit at this location!",
                fr = "À cet endroit, vous pouvez exploiter une source de ressources!",
            },
        },
    },
};

-- Global ------------------------------------------------------------------- --

function ModuleInteractiveMines.Global:OnGameStart()
    QSB.ScriptEvents.InteractiveMineDepleted = API.RegisterScriptEvent("Event_InteractiveMineDepleted");

    API.StartHiResJob(function()
        ModuleInteractiveMines.Global:ControlIOMines();
    end);
end

function ModuleInteractiveMines.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.ObjectReset then
        if IO[arg[1]] and IO[arg[1]].IsInteractiveMine then
            self:ResetIOMine(arg[1], IO[arg[1]].Type);
        end
    elseif _ID == QSB.ScriptEvents.ObjectDelete then
        if IO[arg[1]].IsInteractiveMine and IO[arg[1]].Type then
            ReplaceEntity(arg[1], IO[arg[1]].Type);
        end
    end
end

function ModuleInteractiveMines.Global:CreateIOMine(
    _Position, _Type, _Title, _Text, _Costs, _ResourceAmount,
    _RefillAmount, _Condition, _ConditionInfo, _Action
)
    local BlockerID = self:ResetIOMine(_Position, _Type);
    local Icon = {14, 10};
    if g_GameExtraNo >= 1 then
        if _Type == Entities.R_IronMine then
            Icon = {14, 10};
        end
        if _Type == Entities.R_StoneMine then
            Icon = {14, 10};
        end
    end

    API.SetupObject {
        Name                 = _Position,
        IsInteractiveMine    = true,
        Title                = _Title or ModuleInteractiveMines.Shared.Text.Title,
        Text                 = _Text or ModuleInteractiveMines.Shared.Text.Text,
        Texture              = Icon,
        Type                 = _Type,
        ResourceAmount       = _ResourceAmount or 250,
        RefillAmount         = _RefillAmount or 75,
        Costs                = _Costs,
        InvisibleBlocker     = BlockerID,
        Distance             = 1200,
        ConditionInfo        = _ConditionInfo,
        AdditionalCondition  = _Condition,
        AdditionalAction     = _Action,
        Condition            = function(_Data)
            if _Data.AdditionalCondition then
                return _Data:AdditionalCondition(_Data);
            end
            return true;
        end,
        Action               = function(_Data, _KnightID, _PlayerID)
            local ID = ReplaceEntity(_Data.Name, _Data.Type);
            API.SetResourceAmount(ID, _Data.ResourceAmount, _Data.RefillAmount);
            DestroyEntity(_Data.InvisibleBlocker);
            if _Data.AdditionalAction then
                _Data.AdditionalAction(_Data, _KnightID, _PlayerID);
            end
        end
    };
end

function ModuleInteractiveMines.Global:ResetIOMine(_ScriptName, _Type)
    if IO[_ScriptName] then
        DestroyEntity(IO[_ScriptName].InvisibleBlocker);
    end
    local EntityID = ReplaceEntity(_ScriptName, Entities.XD_ScriptEntity);
    local Model = Models.Doodads_D_SE_ResourceIron_Wrecked;
    if _Type == Entities.R_StoneMine then
        Model = Models.R_SE_ResorceStone_10;
    end
    Logic.SetVisible(EntityID, true);
    Logic.SetModel(EntityID, Model);
    local x, y, z = Logic.EntityGetPos(EntityID);
    local BlockerID = Logic.CreateEntity(Entities.D_ME_Rock_Set01_B_07, x, y, 0, 0);
    Logic.SetVisible(BlockerID, false);
    if IO[_ScriptName] then
        IO[_ScriptName].InvisibleBlocker = BlockerID;
    end
    return BlockerID;
end

function ModuleInteractiveMines.Global:ControlIOMines()
    for k, v in pairs(IO) do
        local EntityID = GetID(k);
        if v.IsInteractiveMine and Logic.GetResourceDoodadGoodType(EntityID) ~= 0 then
            if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
                if v.RefillAmount == 0 then
                    local Model = Models.Doodads_D_SE_ResourceIron_Wrecked;
                    if v.Type == Entities.R_StoneMine then
                        Model = Models.R_ResorceStone_Scaffold_Destroyed;
                    end
                    API.InteractiveObjectDeactivate(EntityID);
                    Logic.SetModel(EntityID, Model);
                end

                API.SendScriptEvent(QSB.ScriptEvents.InteractiveMineDepleted, k);
                Logic.ExecuteInLuaLocalState(string.format(
                    [[API.SendScriptEvent(QSB.ScriptEvents.InteractiveMineDepleted, "%s")]],
                    k
                ));
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleInteractiveMines.Local:OnGameStart()
    QSB.ScriptEvents.InteractiveMineDepleted = API.RegisterScriptEvent("Event_InteractiveMineDepleted");
end

function ModuleInteractiveMines.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleInteractiveMines);

