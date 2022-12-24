--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Die neuen Behavior für den Editor.
--
-- @set sort=true
--

-- -------------------------------------------------------------------------- --

---
-- Ein Entity muss sich zu einem Ziel bewegen und eine Distanz unterschreiten.
--
-- Optional kann das Ziel mit einem Marker markiert werden.
--
-- @param[type=string]  _ScriptName Skriptname des Entity
-- @param[type=string]  _Target     Skriptname des Ziels
-- @param[type=number]  _Distance   Entfernung
-- @param[type=boolean] _UseMarker  Ziel markieren
--
-- @within Goal
--
function Goal_MoveToPosition(...)
    return B_Goal_MoveToPosition:new(...);
end

B_Goal_MoveToPosition = {
    Name = "Goal_MoveToPosition",
    Description = {
        en = "Goal: A entity have to moved as close as the distance to another entity. The target can be marked with a static marker.",
        de = "Ziel: Ein Entity muss sich einer anderen bis auf eine bestimmte Distanz nähern. Die Lupe wird angezeigt, das Ziel kann markiert werden.",
        fr = "Objectif: une entité doit s'approcher d'une autre à une distance donnée. La loupe est affichée, la cible peut être marquée.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",   de = "Entity",         fr = "Entité" },
        { ParameterType.ScriptName, en = "Target",   de = "Ziel",           fr = "Cible" },
        { ParameterType.Number,     en = "Distance", de = "Entfernung",     fr = "Distance" },
        { ParameterType.Custom,     en = "Marker",   de = "Ziel markieren", fr = "Marquer la cible" },
    },
}

function B_Goal_MoveToPosition:GetGoalTable()
    return {Objective.Distance, self.Entity, self.Target, self.Distance, self.Marker}
end

function B_Goal_MoveToPosition:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Entity = _Parameter
    elseif (_Index == 1) then
        self.Target = _Parameter
    elseif (_Index == 2) then
        self.Distance = _Parameter * 1
    elseif (_Index == 3) then
        self.Marker = API.ToBoolean(_Parameter)
    end
end

function B_Goal_MoveToPosition:GetCustomData( _Index )
    local Data = {};
    if _Index == 3 then
        Data = {"true", "false"}
    end
    return Data
end

Swift:RegisterBehavior(B_Goal_MoveToPosition);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss einen bestimmten Quest abschließen.
--
-- @param[type=string] _QuestName Name des Quest
--
-- @within Goal
--
function Goal_WinQuest(...)
    return B_Goal_WinQuest:new(...);
end

B_Goal_WinQuest = {
    Name = "Goal_WinQuest",
    Description = {
        en = "Goal: The player has to win a given quest.",
        de = "Ziel: Der Spieler muss eine angegebene Quest erfolgreich abschliessen.",
        fr = "Objectif: Le joueur doit réussir une quête indiquée.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name",  de = "Questname", fr = "Nom de la quête" },
    },
}

function B_Goal_WinQuest:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function B_Goal_WinQuest:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Quest = _Parameter;
    end
end

function B_Goal_WinQuest:CustomFunction(_Quest)
    local quest = Quests[GetQuestID(self.Quest)];
    if quest then
        if quest.Result == QuestResult.Failure then
            return false;
        end
        if quest.Result == QuestResult.Success then
            return true;
        end
    end
    return nil;
end

function B_Goal_WinQuest:Debug(_Quest)
    if Quests[GetQuestID(self.Quest)] == nil then
        error(_Quest.Identifier.. ": " ..self.Name .. ": Quest '"..self.Quest.."' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Goal_WinQuest);

-- -------------------------------------------------------------------------- --

---
-- Es muss eine Menge an Munition in der Kriegsmaschine erreicht werden.
--
-- <u>Relationen</u>
-- <ul>
-- <li>>= - Anzahl als Mindestmenge</li>
-- <li>< - Weniger als Anzahl</li>
-- </ul>
--
-- @param[type=string] _ScriptName  Name des Kriegsgerät
-- @param[type=string] _Relation    Mengenrelation
-- @param[type=number] _Amount      Menge an Munition
--
-- @within Goal
--
function Goal_AmmunitionAmount(...)
    return B_Goal_AmmunitionAmount:new(...);
end

B_Goal_AmmunitionAmount = {
    Name = "Goal_AmmunitionAmount",
    Description = {
        en = "Goal: Reach a smaller or bigger value than the given amount of ammunition in a war machine.",
        de = "Ziel: Über- oder unterschreite die angegebene Anzahl Munition in einem Kriegsgerät.",
        fr = "Objectif : Dépasser ou ne pas dépasser le nombre de munitions indiqué dans un engin de guerre.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Script name", de = "Skriptname",  fr = "Nom de l'entité" },
        { ParameterType.Custom,     en = "Relation",    de = "Relation",    fr = "Relation" },
        { ParameterType.Number,     en = "Amount",      de = "Menge",       fr = "Quantité" },
    },
}

function B_Goal_AmmunitionAmount:GetGoalTable()
    return { Objective.Custom2, {self, self.CustomFunction} }
end

function B_Goal_AmmunitionAmount:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Scriptname = _Parameter
    elseif (_Index == 1) then
        self.bRelSmallerThan = tostring(_Parameter) == "true" or _Parameter == "<"
    elseif (_Index == 2) then
        self.Amount = _Parameter * 1
    end
end

function B_Goal_AmmunitionAmount:CustomFunction()
    local EntityID = GetID(self.Scriptname);
    if not IsExisting(EntityID) then
        return false;
    end
    local HaveAmount = Logic.GetAmmunitionAmount(EntityID);
    if ( self.bRelSmallerThan and HaveAmount < self.Amount ) or ( not self.bRelSmallerThan and HaveAmount >= self.Amount ) then
        return true;
    end
    return nil;
end

function B_Goal_AmmunitionAmount:Debug(_Quest)
    if self.Amount < 0 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": Amount is negative");
        return true
    end
end

function B_Goal_AmmunitionAmount:GetCustomData( _Index )
    if _Index == 1 then
        return {"<", ">="};
    end
end

Swift:RegisterBehavior(B_Goal_AmmunitionAmount);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss mindestens den angegebenen Ruf erreichen. Der Ruf muss
-- in Prozent angegeben werden (ohne %-Zeichen).
--
-- @param[type=number] _Reputation Benötigter Ruf
--
-- @within Goal
--
function Goal_CityReputation(...)
    return B_Goal_CityReputation:new(...);
end

B_Goal_CityReputation = {
    Name = "Goal_CityReputation",
    Description = {
        en = "Goal: The reputation of the quest receivers city must at least reach the desired hight.",
        de = "Ziel: Der Ruf der Stadt des Empfängers muss mindestens so hoch sein, wie angegeben.",
        fr = "Objectif: la réputation de la ville du receveur doit être au moins aussi élevée que celle indiquée.",
    },
    Parameter = {
        { ParameterType.Number, en = "City reputation", de = "Ruf der Stadt", fr = "Réputation de la ville" },
    },
    Text = {
        de = "RUF DER STADT{cr}{cr}Hebe den Ruf der Stadt durch weise Herrschaft an!{cr}Benötigter Ruf: %d",
        en = "CITY REPUTATION{cr}{cr}Raise your reputation by fair rulership!{cr}Needed reputation: %d",
        fr = "RÉPUTATION DE LA VILLE{cr}{cr} Augmente la réputation de la ville en la gouvernant sagement!{cr}Réputation requise : %d",
    }
}

function B_Goal_CityReputation:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function B_Goal_CityReputation:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Reputation = _Parameter * 1;
    end
end

function B_Goal_CityReputation:CustomFunction(_Quest)
    self:SetCaption(_Quest);
    local CityReputation = Logic.GetCityReputation(_Quest.ReceivingPlayer) * 100;
    if CityReputation >= self.Reputation then
        return true;
    end
end

function B_Goal_CityReputation:SetCaption(_Quest)
    if not _Quest.QuestDescription or _Quest.QuestDescription == "" then
        local Text = string.format(API.Localize(self.Text), self.Reputation);
        Swift.Quest:ChangeCustomQuestCaptionText(Text .."%", _Quest);
    end
end

function B_Goal_CityReputation:GetIcon()
    return {5, 14};
end

function B_Goal_CityReputation:Debug(_Quest)
    if type(self.Reputation) ~= "number" or self.Reputation < 0 or self.Reputation > 100 then
        error(_Quest.Identifier.. ": " ..self.Name.. ": Reputation must be between 0 and 100!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Goal_CityReputation);

-- -------------------------------------------------------------------------- --

---
-- Eine Menge an Entities des angegebenen Spawnpoint muss zerstört werden.
--
-- <b>Hinweis</b>: Eignet sich vor allem für Raubtiere!
--
-- Wenn die angegebene Anzahl zu Beginn des Quest nicht mit der Anzahl an
-- bereits gespawnten Entities übereinstimmt, wird dies automatisch korrigiert.
-- (Neue Entities gespawnt bzw. überschüssige gelöscht)
--
-- Wenn _Prefixed gesetzt ist, wird anstatt des Namen Entities mit einer
-- fortlaufenden Nummer gesucht, welche mit dem Namen beginnen. Bei der
-- ersten Nummer, zu der kein Entity existiert, wird abgebrochen.
--
-- @param[type=string] _SpawnPoint Skriptname des Spawnpoint
-- @param[type=number] _Amount     Menge zu zerstörender Entities
-- @param[type=number] _Prefixed   Skriptname ist Präfix
--
-- @within Goal
--
function Goal_DestroySpawnedEntities(...)
    return B_Goal_DestroySpawnedEntities:new(...);
end

B_Goal_DestroySpawnedEntities = {
    Name = "Goal_DestroySpawnedEntities",
    Description = {
        en = "Goal: Destroy all entities spawned at the spawnpoint.",
        de = "Ziel: Zerstöre alle Entitäten, die bei dem Spawnpoint erzeugt wurde.",
        fr = "Objectif: Détruire toutes les entités créées au point d'apparition.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Spawnpoint",       de = "Spawnpoint",         fr = "Point d'émergence" },
        { ParameterType.Number,     en = "Amount",           de = "Menge",              fr = "Quantité" },
        { ParameterType.Custom,     en = "Name is prefixed", de = "Name ist Präfix",    fr = "Le nom est un préfixe" },
    },
};

function B_Goal_DestroySpawnedEntities:GetGoalTable()
    -- Zur Erzeugungszeit Spawnpoint konvertieren
    -- Hinweis: Entities müssen zu diesem Zeitpunkt existieren und müssen
    -- Spawnpoints sein!
    if self.Prefixed then
        local Parameter = table.remove(self.SpawnPoint);
        local i = 1;
        while (IsExisting(Parameter .. i)) do
            table.insert(self.SpawnPoint, Parameter .. i);
            i = i +1;
        end
        -- Hard Error!
        assert(#self.SpawnPoint > 0, "No spawnpoints found!");
    end
    -- Behavior zurückgeben
    return {Objective.DestroyEntities, 3, self.SpawnPoint, self.Amount};
end

function B_Goal_DestroySpawnedEntities:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.SpawnPoint = {_Parameter};
    elseif (_Index == 1) then
        self.Amount = _Parameter * 1;
    elseif (_Index == 2) then
        _Parameter = _Parameter or "false";
        self.Prefixed = API.ToBoolean(_Parameter);
    end
end

function B_Goal_DestroySpawnedEntities:GetMsgKey()
    local ID = GetID(self.SpawnPoint[1]);
    if ID ~= 0 then
        local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(ID));
        if Logic.IsEntityTypeInCategory( ID, EntityCategories.AttackableBuilding ) == 1 then
            return "Quest_Destroy_Leader";
        elseif TypeName:find("Bear") or TypeName:find("Lion") or TypeName:find("Tiger") or TypeName:find("Wolf") then
            return "Quest_DestroyEntities_Predators";
        elseif TypeName:find("Military") or TypeName:find("Cart") then
            return "Quest_DestroyEntities_Unit";
        end
    end
    return "Quest_DestroyEntities";
end

function B_Goal_DestroySpawnedEntities:GetCustomData(_Index)
    if _Index == 2 then
        return {"false", "true"};
    end
end

Swift:RegisterBehavior(B_Goal_DestroySpawnedEntities);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss eine bestimmte Menge Gold mit Dieben stehlen.
--
-- Dabei ist es egal von welchem Spieler. Diebe können Gold nur aus
-- Stadtgebäude stehlen und nur von feindlichen Spielern.
--
-- <b>Hinweis</b>: Es können nur Stadtgebäude mit einem Dieb um Gold
-- erleichtert werden!
--
-- @param[type=number]  _Amount         Menge an Gold
-- @param[type=number]  _TargetPlayerID Zielspieler (-1 für alle)
-- @param[type=boolean] _CheatEarnings  Einnahmen generieren
-- @param[type=boolean] _ShowProgress   Fortschritt ausgeben
--
-- @within Goal
--
function Goal_StealGold(...)
    return B_Goal_StealGold:new(...)
end

B_Goal_StealGold = {
    Name = "Goal_StealGold",
    Description = {
        en = "Goal: Steal an explicit amount of gold from a players or any players city buildings.",
        de = "Ziel: Diebe sollen eine bestimmte Menge Gold aus feindlichen Stadtgebäuden stehlen.",
        fr = "Objectif: les voleurs doivent dérober une certaine quantité d'or dans les bâtiments urbains ennemis.",
    },
    Parameter = {
        { ParameterType.Number,   en = "Amount on Gold", de = "Zu stehlende Menge",             fr = "Quantité à voler" },
        { ParameterType.Custom,   en = "Target player",  de = "Spieler von dem gestohlen wird", fr = "Joueur à qui l'on vole" },
        { ParameterType.Custom,   en = "Cheat earnings", de = "Einnahmen generieren",           fr = "Générer des revenus" },
        { ParameterType.Custom,   en = "Print progress", de = "Fortschritt ausgeben",           fr = "Afficher les progrès" },
    },
}

function B_Goal_StealGold:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function B_Goal_StealGold:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Amount = _Parameter * 1;
    elseif (_Index == 1) then
        local PlayerID = tonumber(_Parameter) or -1;
        self.Target = PlayerID * 1;
    elseif (_Index == 2) then
        _Parameter = _Parameter or "false"
        self.CheatEarnings = API.ToBoolean(_Parameter);
    elseif (_Index == 3) then
        _Parameter = _Parameter or "true"
        self.Printout = API.ToBoolean(_Parameter);
    end
    self.StohlenGold = 0;
end

function B_Goal_StealGold:GetCustomData(_Index)
    if _Index == 1 then
        return { "-", 1, 2, 3, 4, 5, 6, 7, 8 };
    elseif _Index == 2 then
        return { "true", "false" };
    end
end

function B_Goal_StealGold:SetDescriptionOverwrite(_Quest)
    local TargetPlayerName = API.Localize({
        de = " anderen Spielern ",
        en = " different parties ",
        fr = " d'autres joueurs ",
    });

    if self.Target ~= -1 then
        TargetPlayerName = API.GetPlayerName(self.Target);
        if TargetPlayerName == nil or TargetPlayerName == "" then
            TargetPlayerName = " PLAYER_NAME_MISSING ";
        end
    end

    -- Cheat earnings
    if self.CheatEarnings then
        local PlayerIDs = {self.Target};
        if self.Target == -1 then
            PlayerIDs = {1, 2, 3, 4, 5, 6, 7, 8};
        end
        for i= 1, #PlayerIDs, 1 do
            if i ~= _Quest.ReceivingPlayer and Logic.GetStoreHouse(i) ~= 0 then
                local CityBuildings = {Logic.GetPlayerEntitiesInCategory(i, EntityCategories.CityBuilding)};
                for j= 1, #CityBuildings, 1 do
                    local CurrentEarnings = Logic.GetBuildingProductEarnings(CityBuildings[j]);
                    if CurrentEarnings < 45 and Logic.GetTime() % 5 == 0 then
                        Logic.SetBuildingEarnings(CityBuildings[j], CurrentEarnings +1);
                    end
                end
            end
        end
    end

    local amount = self.Amount - self.StohlenGold;
    amount = (amount > 0 and amount) or 0;
    local text = {
        de = "Gold von %s stehlen {cr}{cr}Aus Stadtgebäuden zu stehlende Goldmenge: %d",
        en = "Steal gold from %s {cr}{cr}Amount on gold to steal from city buildings: %d",
        fr = "Voler l'or de %s {cr}{cr}Quantité d'or à voler dans les bâtiments de la ville : %d",
    };
    return "{center}" ..string.format(API.Localize(text), TargetPlayerName, amount);
end

function B_Goal_StealGold:CustomFunction(_Quest)
    Swift.Quest:ChangeCustomQuestCaptionText(self:SetDescriptionOverwrite(_Quest), _Quest);
    if self.StohlenGold >= self.Amount then
        return true;
    end
    return nil;
end

function B_Goal_StealGold:GetIcon()
    return {5,13};
end

function B_Goal_StealGold:Debug(_Quest)
    if tonumber(self.Amount) == nil and self.Amount < 0 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": amount can not be negative!");
        return true;
    end
    return false;
end

function B_Goal_StealGold:Reset(_Quest)
    self.StohlenGold = 0;
end

Swift:RegisterBehavior(B_Goal_StealGold)

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss ein bestimmtes Stadtgebäude bestehlen.
--
-- Eine Kirche wird immer Sabotiert. Ein Lagerhaus verhält sich ähnlich zu
-- einer Burg.
--
-- <b>Hinweis</b>: Ein Dieb kann nur von einem Spezialgebäude oder einem
-- Stadtgebäude stehlen!
--
-- @param[type=string] _ScriptName Skriptname des Gebäudes
-- @param[type=boolean] _CheatEarnings  Einnahmen generieren
--
-- @within Goal
--
function Goal_StealFromBuilding(...)
    return B_Goal_StealFromBuilding:new(...)
end

B_Goal_StealFromBuilding = {
    Name = "Goal_StealFromBuilding",
    Description = {
        en = "Goal: The player has to steal from a building. Not a castle and not a village storehouse!",
        de = "Ziel: Der Spieler muss ein bestimmtes Gebäude bestehlen. Dies darf keine Burg und kein Dorflagerhaus sein!",
        fr = "Objectif: Le joueur doit voler un bâtiment spécifique. Il ne peut s'agir ni d'un château ni d'un entrepôt de village !",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Building",        de = "Gebäude",              fr = "Bâtiment" },
        { ParameterType.Custom,     en = "Cheat earnings",  de = "Einnahmen generieren", fr = "Générer des revenus" },
    },
}

function B_Goal_StealFromBuilding:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function B_Goal_StealFromBuilding:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Building = _Parameter
    elseif (_Index == 1) then
        _Parameter = _Parameter or "false"
        self.CheatEarnings = API.ToBoolean(_Parameter);
    end
    self.RobberList = {};
end

function B_Goal_StealFromBuilding:GetCustomData(_Index)
    if _Index == 1 then
        return { "true", "false" };
    end
end

function B_Goal_StealFromBuilding:SetDescriptionOverwrite(_Quest)
    local isCathedral = Logic.IsEntityInCategory(GetID(self.Building), EntityCategories.Cathedrals) == 1;
    local isWarehouse = Logic.GetEntityType(GetID(self.Building)) == Entities.B_StoreHouse;
    local isCistern = Logic.GetEntityType(GetID(self.Building)) == Entities.B_Cistern;
    local text;

    if isCathedral then
        text = {
            de = "Sabotage {cr}{cr} Sendet einen Dieb und sabotiert die markierte Kirche.",
            en = "Sabotage {cr}{cr} Send a thief to sabotage the marked chapel.",
            fr = "Sabotage {cr}{cr} Envoyez un voleur pour saboter la chapelle marquée.",
        };
    elseif isWarehouse then
        text = {
            de = "Lagerhaus bestehlen {cr}{cr} Sendet einen Dieb in das markierte Lagerhaus.",
            en = "Steal from storehouse {cr}{cr} Steal from the marked storehouse.",
            fr = "Voler un entrepôt {cr}{cr} Envoie un voleur dans l'entrepôt marqué.",
        };
    elseif isCistern then
        text = {
            de = "Sabotage {cr}{cr} Sendet einen Dieb und sabotiert den markierten Brunnen.",
            en = "Sabotage {cr}{cr} Send a thief and break the marked well of the enemy.",
            fr = "Sabotage {cr}{cr} Envoie un voleur et sabote le puits marqué.",
        };
    else
        text = {
            de = "Gebäude bestehlen {cr}{cr} Sendet einen Dieb und bestehlt das markierte Gebäude.",
            en = "Steal from building {cr}{cr} Send a thief to steal from the marked building.",
            fr = "Voler un bâtiment {cr}{cr} Envoie un voleur et vole le bâtiment marqué.",
        };
    end
    return "{center}" .. API.Localize(text);
end

function B_Goal_StealFromBuilding:CustomFunction(_Quest)
    if not IsExisting(self.Building) then
        if self.Marker then
            Logic.DestroyEffect(self.Marker);
        end
        return false;
    end

    if not self.Marker then
        local pos = GetPosition(self.Building);
        self.Marker = Logic.CreateEffect(EGL_Effects.E_Questmarker, pos.X, pos.Y, 0);
    end

    -- Cheat earnings
    if self.CheatEarnings then
        local BuildingID = GetID(self.Building);        
        local CurrentEarnings = Logic.GetBuildingProductEarnings(BuildingID);
        if  Logic.IsEntityInCategory(BuildingID, EntityCategories.CityBuilding) == 1
        and CurrentEarnings < 45 and Logic.GetTime() % 5 == 0 then
            Logic.SetBuildingEarnings(BuildingID, CurrentEarnings +1);
        end
    end

    if self.SuccessfullyStohlen then
        Logic.DestroyEffect(self.Marker);
        return true;
    end
    return nil;
end

function B_Goal_StealFromBuilding:GetIcon()
    return {5,13};
end

function B_Goal_StealFromBuilding:Debug(_Quest)
    local eTypeName = Logic.GetEntityTypeName(Logic.GetEntityType(GetID(self.Building)));
    local IsHeadquarter = Logic.IsEntityInCategory(GetID(self.Building), EntityCategories.Headquarters) == 1;
    if Logic.IsBuilding(GetID(self.Building)) == 0 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": target is not a building");
        return true;
    elseif not IsExisting(self.Building) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": target is destroyed :(");
        return true;
    elseif string.find(eTypeName, "B_NPC_BanditsHQ") or string.find(eTypeName, "B_NPC_Cloister") or string.find(eTypeName, "B_NPC_StoreHouse") then
        error(_Quest.Identifier.. ": " ..self.Name .. ": village storehouses are not allowed!");
        return true;
    elseif IsHeadquarter then
        error(_Quest.Identifier.. ": " ..self.Name .. ": use Goal_StealInformation for headquarters!");
        return true;
    end
    return false;
end

function B_Goal_StealFromBuilding:Reset(_Quest)
    self.SuccessfullyStohlen = false;
    self.RobberList = {};
    self.Marker = nil;
end

function B_Goal_StealFromBuilding:Interrupt(_Quest)
    Logic.DestroyEffect(self.Marker);
end

Swift:RegisterBehavior(B_Goal_StealFromBuilding)

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss ein Gebäude mit einem Dieb ausspoinieren.
--
-- Der Quest ist erfolgreich, sobald der Dieb in das Gebäude eindringt. Es
-- muss sich um ein Gebäude handeln, das bestohlen werden kann (Burg, Lager,
-- Kirche, Stadtgebäude mit Einnahmen)!
--
-- Optional kann der Dieb nach Abschluss gelöscht werden. Diese Option macht
-- es einfacher ihn durch z.B. einen Abfahrenden U_ThiefCart zu "ersetzen".
--
-- <b>Hinweis</b>: Ein Dieb kann nur in Spezialgebäude oder Stadtgebäude
-- eindringen!
--
-- @param[type=string]  _ScriptName  Skriptname des Gebäudes
-- @param[type=boolean] _CheatEarnings  Einnahmen generieren
-- @param[type=boolean] _DeleteThief Dieb nach Abschluss löschen
--
-- @within Goal
--
function Goal_SpyOnBuilding(...)
    return B_Goal_SpyOnBuilding:new(...)
end

B_Goal_SpyOnBuilding = {
    Name = "Goal_SpyOnBuilding",
    IconOverwrite = {5,13},
    Description = {
        en = "Goal: Infiltrate a building with a thief. A thief must be able to steal from the target building.",
        de = "Ziel: Infiltriere ein Gebäude mit einem Dieb. Nur mit Gebaueden möglich, die bestohlen werden koennen.",
        fr = "Objectif: Infiltrer un bâtiment avec un voleur. Seulement possible avec des bâtiments qui peuvent être volés.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Target Building", de = "Zielgebäude",           fr = "Bâtiment cible" },
        { ParameterType.Custom,     en = "Cheat earnings",  de = "Einnahmen generieren",  fr = "Générer des revenus" },
        { ParameterType.Custom,     en = "Destroy Thief",   de = "Dieb löschen",          fr = "Supprimer le voleur" },
    },
}

function B_Goal_SpyOnBuilding:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function B_Goal_SpyOnBuilding:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Building = _Parameter
    elseif (_Index == 1) then
        _Parameter = _Parameter or "false"
        self.CheatEarnings = API.ToBoolean(_Parameter);
    elseif (_Index == 2) then
        _Parameter = _Parameter or "true"
        self.Delete = API.ToBoolean(_Parameter)
    end
end

function B_Goal_SpyOnBuilding:GetCustomData(_Index)
    if _Index == 1 then
        return { "true", "false" };
    end
end

function B_Goal_SpyOnBuilding:SetDescriptionOverwrite(_Quest)
    if not _Quest.QuestDescription then
        local text = {
            de = "Gebäude infriltrieren {cr}{cr}Spioniere das markierte Gebäude mit einem Dieb aus!",
            en = "Infiltrate building {cr}{cr}Spy on the highlighted buildings with a thief!",
            fr = "Infiltrer un bâtiment {cr}{cr}Espionner le bâtiment marqué avec un voleur!",
        };
        return API.Localize(text);
    else
        return _Quest.QuestDescription;
    end
end

function B_Goal_SpyOnBuilding:CustomFunction(_Quest)
    if not IsExisting(self.Building) then
        if self.Marker then
            Logic.DestroyEffect(self.Marker);
        end
        return false;
    end

    if not self.Marker then
        local pos = GetPosition(self.Building);
        self.Marker = Logic.CreateEffect(EGL_Effects.E_Questmarker, pos.X, pos.Y, 0);
    end

    -- Cheat earnings
    if self.CheatEarnings then
        local BuildingID = GetID(self.Building);
        if  Logic.IsEntityInCategory(BuildingID, EntityCategories.CityBuilding) == 1
        and Logic.GetBuildingEarnings(BuildingID) < 5 then
            Logic.SetBuildingEarnings(BuildingID, 5);
        end
    end

    if self.Infiltrated then
        Logic.DestroyEffect(self.Marker);
        return true;
    end
    return nil;
end

function B_Goal_SpyOnBuilding:GetIcon()
    return self.IconOverwrite;
end

function B_Goal_SpyOnBuilding:Debug(_Quest)
    if Logic.IsBuilding(GetID(self.Building)) == 0 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": target is not a building");
        return true;
    elseif not IsExisting(self.Building) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": target is destroyed :(");
        return true;
    end
    return false;
end

function B_Goal_SpyOnBuilding:Reset(_Quest)
    self.Infiltrated = false;
    self.Marker = nil;
end

function B_Goal_SpyOnBuilding:Interrupt(_Quest)
    Logic.DestroyEffect(self.Marker);
end

Swift:RegisterBehavior(B_Goal_SpyOnBuilding);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss eine Anzahl an Gegenständen finden, die bei den angegebenen
-- Positionen platziert werden.
--
-- @param[type=string] _Positions Präfix aller durchnummerierten Enttities
-- @param[type=string] _Model     Model für alle Gegenstände
-- @param[type=number] _Distance  Aktivierungsdistanz (0 = Default = 300)
--
-- @within Goal
--
function Goal_FetchItems(...)
    return B_Goal_FetchItems:new(...);
end

B_Goal_FetchItems = {
    Name = "Goal_FetchItems",
    Description = {
        en = "Goal: ",
        de = "Ziel: ",
        fr = "Objectif: ",
    },
    Parameter = {
        { ParameterType.Default, en = "Search points",          de = "Suchpunkte",              fr = "Points de recherche" },
        { ParameterType.Custom,  en = "Shared model",           de = "Gemeinsames Modell",      fr = "Modèle commun" },
        { ParameterType.Number,  en = "Distance (0 = Default)", de = "Enternung (0 = Default)", fr = "Distance (0 = Default)" },
    },

    Text = {
        {
            de = "%d/%d Gegenstände gefunden",
            en = "%d/%d Items gefunden",
            fr = "%d/%d objets trouvés",
        },
        {
            de = "GEGENSTÄNDE FINDEN {br}{br}Findet die verloren gegangenen Gegenstände.",
            en = "FIND VALUABLES {br}{br}Find the missing items and return them.",
            fr = "TROUVER LES OBJETS {br}{br}Trouve les objets perdus.",
        },
    },

    Tools = {
        Models.Doodads_D_X_Sacks,
        Models.Tools_T_BowNet01,
        Models.Tools_T_Hammer02,
        Models.Tools_T_Cushion01,
        Models.Tools_T_Knife02,
        Models.Tools_T_Scythe01,
        Models.Tools_T_SiegeChest01,
    },

    Distance = 300,
    Finished = false,
    Positions = {},
    Marker = {},
}

function B_Goal_FetchItems:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function B_Goal_FetchItems:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.SearchPositions = _Parameter;
    elseif (_Index == 1) then
        self.Model = _Parameter;
    elseif (_Index == 2) then
        if _Parameter == nil then
            _Parameter = self.Distance;
        end
        self.Distance = _Parameter * 1;
        if self.Distance == 0 then
            self.Distance = 300;
        end
    end
end

function B_Goal_FetchItems:CustomFunction(_Quest)
    Swift.Quest:ChangeCustomQuestCaptionText("{center}" ..API.Localize(self.Text[2]), _Quest);
    if not self.Finished then
        self:GetPositions(_Quest);
        self:CreateMarker(_Quest);
        self:CheckPositions(_Quest);
        if #self.Marker > 0 then
            return;
        end
        self.Finished = true;
    end
    return true;
end

function B_Goal_FetchItems:GetPositions(_Quest)
    if #self.Positions == 0 then
        -- Position is a table (script only feature)
        if type(self.SearchPositions) == "table" then
            self.Positions = self.SearchPositions;
        -- Search positions by prefix
        else
            local Index = 1;
            while (IsExisting(self.SearchPositions .. Index)) do
                table.insert(self.Positions, GetPosition(self.SearchPositions .. Index));
                Index = Index +1;
            end
        end
    end
end

function B_Goal_FetchItems:CreateMarker(_Quest)
    if #self.Marker == 0 then
        for i= 1, #self.Positions, 1 do
            local ID = Logic.CreateEntityOnUnblockedLand(Entities.XD_ScriptEntity, self.Positions[i].X, self.Positions[i].Y, 0, 0);
            if self.Model ~= nil and self.Model ~= "-" then
                Logic.SetModel(ID, Models[self.Model]);
            else
                Logic.SetModel(ID, self.Tools[math.random(1, #self.Tools)]);
            end
            Logic.SetVisible(ID, true);
            table.insert(self.Marker, ID);
        end
    end
end

function B_Goal_FetchItems:CheckPositions(_Quest)
    local Heroes = {};
    Logic.GetKnights(_Quest.ReceivingPlayer, Heroes);
    for i= #self.Marker, 1, -1 do
        for j= 1, #Heroes, 1 do
            if IsNear(self.Marker[i], Heroes[j], self.Distance) then
                DestroyEntity(table.remove(self.Marker, i));
                local Max = #self.Positions;
                local Now = Max - #self.Marker;
                API.Note(string.format(API.Localize(self.Text[1]), Now, Max));
                break;
            end
        end
    end
end

function B_Goal_FetchItems:Reset(_Quest)
    self:Interrupt(_Quest);
end

function B_Goal_FetchItems:Interrupt(_Quest)
    self.Finished = false;
    self.Positions = {};
    for i= 1, #self.Marker, 1 do
        DestroyEntity(self.Marker[i]);
    end
    self.Marker = {};
end

function B_Goal_FetchItems:GetCustomData(_Index)
    if _Index == 1 then
        local Data = ModuleBehaviorCollection.Global:GetPossibleModels();
        table.insert(Data, 1, "-");
        return Data;
    end
end

function B_Goal_FetchItems:Debug(_Quest)
    return false;
end

Swift:RegisterBehavior(B_Goal_FetchItems);

-- -------------------------------------------------------------------------- --

---
-- Ein beliebiger Spieler muss Soldaten eines anderen Spielers zerstören.
--
-- Dieses Behavior kann auch in versteckten Quests bentutzt werden, wenn die
-- Menge an zerstörten Soldaten durch einen Feind des Spielers gefragt ist oder
-- wenn ein Verbündeter oder Feind nach X Verlusten aufgeben soll.
--
-- @param _PlayerA Angreifende Partei
-- @param _PlayerB Zielpartei
-- @param _Amount Menga an Soldaten
--
-- @within Goal
--
function Goal_DestroySoldiers(...)
    return B_Goal_DestroySoldiers:new(...);
end

B_Goal_DestroySoldiers = {
    Name = "Goal_DestroySoldiers",
    Description = {
        en = "Goal: Destroy a given amount of enemy soldiers",
        de = "Ziel: Zerstöre eine Anzahl gegnerischer Soldaten",
        fr = "Objectif: Détruire un certain nombre de soldats ennemis",
    },
    Parameter = {
        {ParameterType.PlayerID, en = "Attacking Player",   de = "Angreifer",   fr = "Attaquant", },
        {ParameterType.PlayerID, en = "Defending Player",   de = "Verteidiger", fr = "Défenseur", },
        {ParameterType.Number,   en = "Amount",             de = "Anzahl",      fr = "Quantité", },
    },

    Text = {
        de = "{center}SOLDATEN ZERSTÖREN {cr}{cr}von der Partei: %s{cr}{cr}Anzahl: %d",
        en = "{center}DESTROY SOLDIERS {cr}{cr}from faction: %s{cr}{cr}Amount: %d",
        fr = "{center}DESTRUIRE DES SOLDATS {cr}{cr}de la faction: %s{cr}{cr}Nombre : %d",
    }
}

function B_Goal_DestroySoldiers:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction} }
end

function B_Goal_DestroySoldiers:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.AttackingPlayer = _Parameter * 1
    elseif (_Index == 1) then
        self.AttackedPlayer = _Parameter * 1
    elseif (_Index == 2) then
        self.KillsNeeded = _Parameter * 1
    end
end

function B_Goal_DestroySoldiers:CustomFunction(_Quest)
    if not _Quest.QuestDescription or _Quest.QuestDescription == "" then
        local PlayerName = GetPlayerName(self.AttackedPlayer) or ("Player " ..self.AttackedPlayer);
        Swift.Quest:ChangeCustomQuestCaptionText(
            string.format(
                Swift.Text:Localize(self.Text),
                PlayerName, self.KillsNeeded
            ),
            _Quest
        );
    end
    if self.KillsNeeded <= ModuleBehaviorCollection.Global:GetEnemySoldierKillsOfPlayer(self.AttackingPlayer, self.AttackedPlayer) then
        return true;
    end
end

function B_Goal_DestroySoldiers:Debug(_Quest)
    if Logic.GetStoreHouse(self.AttackingPlayer) == 0 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": Player " .. self.AttackinPlayer .. " is dead :-(")
        return true
    elseif Logic.GetStoreHouse(self.AttackedPlayer) == 0 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": Player " .. self.AttackedPlayer .. " is dead :-(")
        return true
    elseif self.KillsNeeded < 0 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": Amount negative")
        return true
    end
end

function B_Goal_DestroySoldiers:GetIcon()
    return {7,12}
end

Swift:RegisterBehavior(B_Goal_DestroySoldiers);

-- -------------------------------------------------------------------------- --
-- Reprisals                                                                  --
-- -------------------------------------------------------------------------- --

---
-- Ändert die Position eines Siedlers oder eines Gebäudes.
--
-- Optional kann das Entity in einem bestimmten Abstand zum Ziel platziert
-- werden und das Ziel anschauen. Die Entfernung darf nicht kleiner sein als 50!
--
-- @param[type=string]  _ScriptName Skriptname des Entity
-- @param[type=string]  _Target     Skriptname des Ziels
-- @param[type=boolean] _LookAt     Gegenüberstellen
-- @param[type=number]  _Distance   Relative Entfernung (nur mit _LookAt)
--
-- @within Reprisal
--
function Reprisal_SetPosition(...)
    return B_Reprisal_SetPosition:new(...);
end

B_Reprisal_SetPosition = {
    Name = "Reprisal_SetPosition",
    Description = {
        en = "Reprisal: Places an entity relative to the position of another. The entity can look the target.",
        de = "Vergeltung: Setzt eine Entity relativ zur Position einer anderen. Die Entity kann zum Ziel ausgerichtet werden.",
        fr = "Rétribution: place une Entity vis-à-vis de l'emplacement d'une autre. L'entité peut être orientée vers la cible.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",          de = "Entity",          fr = "Entité", },
        { ParameterType.ScriptName, en = "Target position", de = "Zielposition",    fr = "Position cible", },
        { ParameterType.Custom,     en = "Face to face",    de = "Ziel ansehen",    fr = "Voir la cible", },
        { ParameterType.Number,     en = "Distance",        de = "Zielentfernung",  fr = "Distance de la cible", },
    },
}

function B_Reprisal_SetPosition:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function B_Reprisal_SetPosition:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Target = _Parameter;
    elseif (_Index == 2) then
        self.FaceToFace = API.ToBoolean(_Parameter)
    elseif (_Index == 3) then
        self.Distance = (_Parameter ~= nil and tonumber(_Parameter)) or 100;
    end
end

function B_Reprisal_SetPosition:CustomFunction(_Quest)
    if not IsExisting(self.Entity) or not IsExisting(self.Target) then
        return;
    end

    local entity = GetID(self.Entity);
    local target = GetID(self.Target);
    local x,y,z = Logic.EntityGetPos(target);
    if Logic.IsBuilding(target) == 1 then
        x,y = Logic.GetBuildingApproachPosition(target);
    end
    local ori = Logic.GetEntityOrientation(target)+90;

    if self.FaceToFace then
        x = x + self.Distance * math.cos( math.rad(ori) );
        y = y + self.Distance * math.sin( math.rad(ori) );
        Logic.DEBUG_SetSettlerPosition(entity, x, y);
        LookAt(self.Entity, self.Target);
    else
        if Logic.IsBuilding(target) == 1 then
            x,y = Logic.GetBuildingApproachPosition(target);
        end
        Logic.DEBUG_SetSettlerPosition(entity, x, y);
    end
end

function B_Reprisal_SetPosition:GetCustomData(_Index)
    if _Index == 2 then
        return { "true", "false" }
    end
end

function B_Reprisal_SetPosition:Debug(_Quest)
    if self.FaceToFace then
        if tonumber(self.Distance) == nil or self.Distance < 50 then
            error(_Quest.Identifier.. ": " ..self.Name.. ": Distance is nil or to short!");
            return true;
        end
    end
    if not IsExisting(self.Entity) or not IsExisting(self.Target) then
        error(_Quest.Identifier.. ": " ..self.Name.. ": Mover entity or target entity does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_SetPosition);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Eigentümer des Entity oder des Battalions.
--
-- @param[type=string] _ScriptName Skriptname des Entity
-- @param[type=number] _NewOwner   PlayerID des Eigentümers
--
-- @within Reprisal
--
function Reprisal_ChangePlayer(...)
    return B_Reprisal_ChangePlayer:new(...)
end

B_Reprisal_ChangePlayer = {
    Name = "Reprisal_ChangePlayer",
    Description = {
        en = "Reprisal: Changes the owner of the entity or a battalion.",
        de = "Vergeltung: Aendert den Besitzer einer Entity oder eines Battalions.",
        fr = "Rétribution : Change le propriétaire d'une entité ou d'un bataillon.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",     de = "Entity",   fr = "Entité", },
        { ParameterType.Custom,     en = "Player",     de = "Spieler",  fr = "Joueur", },
    },
}

function B_Reprisal_ChangePlayer:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function B_Reprisal_ChangePlayer:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Player = tostring(_Parameter);
    end
end

function B_Reprisal_ChangePlayer:CustomFunction(_Quest)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    if Logic.IsLeader(eID) == 1 then
        Logic.ChangeSettlerPlayerID(eID, self.Player);
    else
        Logic.ChangeEntityPlayerID(eID, self.Player);
    end
end

function B_Reprisal_ChangePlayer:GetCustomData(_Index)
    if _Index == 1 then
        return {"0", "1", "2", "3", "4", "5", "6", "7", "8"}
    end
end

function B_Reprisal_ChangePlayer:Debug(_Quest)
    if not IsExisting(self.Entity) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_ChangePlayer);

-- -------------------------------------------------------------------------- --

---
-- Ändert die Sichtbarkeit eines Entity.
--
-- @param[type=string]  _ScriptName Skriptname des Entity
-- @param[type=boolean] _Visible    Sichtbarkeit an/aus
--
-- @within Reprisal
--
function Reprisal_SetVisible(...)
    return B_Reprisal_SetVisible:new(...)
end

B_Reprisal_SetVisible = {
    Name = "Reprisal_SetVisible",
    Description = {
        en = "Reprisal: Changes the visibility of an entity. If the entity is a spawner the spawned entities will be affected.",
        de = "Vergeltung: Setzt die Sichtbarkeit einer Entity. Handelt es sich um einen Spawner werden auch die gespawnten Entities beeinflusst.",
        fr = "Rétribution: fixe la visibilité d'une Entité. S'il s'agit d'un spawn, les Entities spawnées sont également affectées.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",      de = "Entity",   fr = "Entité", },
        { ParameterType.Custom,     en = "Visible",     de = "Sichtbar", fr = "Visible", },
    },
}

function B_Reprisal_SetVisible:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function B_Reprisal_SetVisible:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Visible = API.ToBoolean(_Parameter)
    end
end

function B_Reprisal_SetVisible:CustomFunction(_Quest)
    if not IsExisting(self.Entity) then
        return;
    end

    local eID = GetID(self.Entity);
    local pID = Logic.EntityGetPlayer(eID);
    local eType = Logic.GetEntityType(eID);
    local tName = Logic.GetEntityTypeName(eType);

    if string.find(tName, "^S_") or string.find(tName, "^B_NPC_Bandits")
    or string.find(tName, "^B_NPC_Barracks") then
        local spawned = {Logic.GetSpawnedEntities(eID)};
        for i=1, #spawned do
            if Logic.IsLeader(spawned[i]) == 1 then
                local soldiers = {Logic.GetSoldiersAttachedToLeader(spawned[i])};
                for j=2, #soldiers do
                    Logic.SetVisible(soldiers[j], self.Visible);
                end
            else
                Logic.SetVisible(spawned[i], self.Visible);
            end
        end
    else
        if Logic.IsLeader(eID) == 1 then
            local soldiers = {Logic.GetSoldiersAttachedToLeader(eID)};
            for j=2, #soldiers do
                Logic.SetVisible(soldiers[j], self.Visible);
            end
        else
            Logic.SetVisible(eID, self.Visible);
        end
    end
end

function B_Reprisal_SetVisible:GetCustomData(_Index)
    if _Index == 1 then
        return { "true", "false" }
    end
end

function B_Reprisal_SetVisible:Debug(_Quest)
    if not IsExisting(self.Entity) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_SetVisible);

-- -------------------------------------------------------------------------- --

---
-- Macht das Entity verwundbar oder unverwundbar.
--
-- Bei einem Battalion wirkt sich das Behavior auf alle Soldaten und den
-- (unsichtbaren) Leader aus. Wird das Behavior auf ein Spawner Entity 
-- angewendet, werden die gespawnten Entities genommen.
--
-- @param[type=string]  _ScriptName Skriptname des Entity
-- @param[type=boolean] _Vulnerable Verwundbarkeit an/aus
--
-- @within Reprisal
--
function Reprisal_SetVulnerability(...)
    return B_Reprisal_SetVulnerability:new(...);
end

B_Reprisal_SetVulnerability = {
    Name = "Reprisal_SetVulnerability",
    Description = {
        en = "Reprisal: Changes the vulnerability of the entity. If the entity is a spawner the spawned entities will be affected.",
        de = "Vergeltung: Macht eine Entity verwundbar oder unverwundbar. Handelt es sich um einen Spawner, sind die gespawnten Entities betroffen.",
        fr = "Rétribution: rend une Entité vulnérable ou invulnérable. S'il s'agit d'un spawn, les Entities spawnées sont affectées.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",             de = "Entity",     fr = "Entité", },
        { ParameterType.Custom,     en = "Vulnerability",      de = "Verwundbar", fr = "Vulnérabilité", },
    },
}

function B_Reprisal_SetVulnerability:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function B_Reprisal_SetVulnerability:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Vulnerability = API.ToBoolean(_Parameter)
    end
end

function B_Reprisal_SetVulnerability:CustomFunction(_Quest)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    local eType = Logic.GetEntityType(eID);
    local tName = Logic.GetEntityTypeName(eType);
    local EntitiesToCheck = {eID};
    if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
    or string.find(tName, "B_NPC_Barracks") then
        EntitiesToCheck = {Logic.GetSpawnedEntities(eID)};
    end
    local MethodToUse = "MakeInvulnerable";
    if self.Vulnerability then
        MethodToUse = "MakeVulnerable";
    end
    for i= 1, #EntitiesToCheck, 1 do
        if Logic.IsLeader(EntitiesToCheck[i]) == 1 then
            local Soldiers = {Logic.GetSoldiersAttachedToLeader(EntitiesToCheck[i])};
            for j=2, #Soldiers, 1 do
                _G[MethodToUse](Soldiers[j]);
            end
        end
        _G[MethodToUse](EntitiesToCheck[i]);
    end
end

function B_Reprisal_SetVulnerability:GetCustomData(_Index)
    if _Index == 1 then
        return { "true", "false" }
    end
end

function B_Reprisal_SetVulnerability:Debug(_Quest)
    if not IsExisting(self.Entity) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_SetVulnerability);

-- -------------------------------------------------------------------------- --

---
-- Ändert das Model eines Entity.
--
-- In Verbindung mit Reward_SetVisible oder Reprisal_SetVisible können
-- Script Entites ein neues Model erhalten und sichtbar gemacht werden.
-- Das hat den Vorteil, das Script Entities nicht überbaut werden können.
--
-- @param[type=string] _ScriptName Skriptname des Entity
-- @param[type=string] _Model      Neues Model
--
-- @within Reprisal
--
function Reprisal_SetModel(...)
    return B_Reprisal_SetModel:new(...);
end

B_Reprisal_SetModel = {
    Name = "Reprisal_SetModel",
    Description = {
        en = "Reprisal: Changes the model of the entity. Be careful, some models crash the game.",
        de = "Vergeltung: Ändert das Model einer Entity. Achtung: Einige Modelle führen zum Absturz.",
        fr = "Rétribution: modifie le modèle d'une entité. Attention: certains modèles entraînent un crash.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",    de = "Entity", fr = "Entité", },
        { ParameterType.Custom,     en = "Model",     de = "Model",  fr = "Modèle", },
    },
}

function B_Reprisal_SetModel:GetReprisalTable()
    return { Reprisal.Custom, { self, self.CustomFunction } }
end

function B_Reprisal_SetModel:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Model = _Parameter;
    end
end

function B_Reprisal_SetModel:CustomFunction(_Quest)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    Logic.SetModel(eID, Models[self.Model]);
end

-- Hinweis: Kann nicht durch Aufruf der Methode von B_Goal_FetchItems
-- vereinfacht werden, weil man im Editor keine Methoden aufrufen kann!
function B_Reprisal_SetModel:GetCustomData(_Index)
    if _Index == 1 then
        return ModuleBehaviorCollection.Global:GetPossibleModels();
    end
end

function B_Reprisal_SetModel:Debug(_Quest)
    if not IsExisting(self.Entity) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    if not Models[self.Model] then
        error(_Quest.Identifier.. ": " ..self.Name .. ": model '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_SetModel);

-- -------------------------------------------------------------------------- --
-- Rewards                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Ändert die Position eines Siedlers oder eines Gebäudes.
--
-- Optional kann das Entity in einem bestimmten Abstand zum Ziel platziert
-- werden und das Ziel anschauen. Die Entfernung darf nicht kleiner sein
-- als 50!
--
-- @param[type=string] _ScriptName Skriptname des Entity
-- @param[type=string] _Target     Skriptname des Ziels
-- @param[type=number] _LookAt     Gegenüberstellen
-- @param[type=number] _Distance   Relative Entfernung (nur mit _LookAt)
--
-- @within Reward
--
function Reward_SetPosition(...)
    return B_Reward_SetPosition:new(...);
end

B_Reward_SetPosition = Swift.LuaBase:CopyTable(B_Reprisal_SetPosition);
B_Reward_SetPosition.Name = "Reward_SetPosition";
B_Reward_SetPosition.Description.en = "Reward: Places an entity relative to the position of another. The entity can look the target.";
B_Reward_SetPosition.Description.de = "Lohn: Setzt eine Entity relativ zur Position einer anderen. Die Entity kann zum Ziel ausgerichtet werden.";
B_Reward_SetPosition.Description.fr = "Récompense: Définit une Entity vis-à-vis de la position d'une autre. L'entité peut être orientée vers la cible.";
B_Reward_SetPosition.GetReprisalTable = nil;

B_Reward_SetPosition.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Swift:RegisterBehavior(B_Reward_SetPosition);

-- -------------------------------------------------------------------------- --

---
-- Ändert den Eigentümer des Entity oder des Battalions.
--
-- @param[type=string] _ScriptName Skriptname des Entity
-- @param[type=number] _NewOwner   PlayerID des Eigentümers
--
-- @within Reward
--
function Reward_ChangePlayer(...)
    return B_Reward_ChangePlayer:new(...);
end

B_Reward_ChangePlayer = Swift.LuaBase:CopyTable(B_Reprisal_ChangePlayer);
B_Reward_ChangePlayer.Name = "Reward_ChangePlayer";
B_Reward_ChangePlayer.Description.en = "Reward: Changes the owner of the entity or a battalion.";
B_Reward_ChangePlayer.Description.de = "Lohn: Ändert den Besitzer einer Entity oder eines Battalions.";
B_Reward_ChangePlayer.Description.fr = "Récompense: Change le propriétaire d'une entité ou d'un bataillon.";
B_Reward_ChangePlayer.GetReprisalTable = nil;

B_Reward_ChangePlayer.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Swift:RegisterBehavior(B_Reward_ChangePlayer);

-- -------------------------------------------------------------------------- --

---
-- Bewegt einen Siedler relativ zu einem Zielpunkt.
--
-- Der Siedler wird sich zum Ziel ausrichten und in der angegeben Distanz
-- und dem angegebenen Winkel Position beziehen.
--
-- <p><b>Hinweis:</b> Funktioniert ähnlich wie MoveEntityToPositionToAnotherOne.
-- </p>
--
-- @param[type=string] _ScriptName  Skriptname des Entity
-- @param[type=string] _Destination Skriptname des Ziels
-- @param[type=number] _Distance    Entfernung
-- @param[type=number] _Angle       Winkel
--
-- @within Reward
--
function Reward_MoveToPosition(...)
    return B_Reward_MoveToPosition:new(...);
end

B_Reward_MoveToPosition = {
    Name = "Reward_MoveToPosition",
    Description = {
        en = "Reward: Moves an entity relative to another entity. If angle is zero the entities will be standing directly face to face.",
        de = "Lohn: Bewegt eine Entity relativ zur Position einer anderen. Wenn Winkel 0 ist, stehen sich die Entities direkt gegenüber.",
        fr = "Récompense: Déplace une entité par rapport à la position d'une autre. Si l'angle est égal à 0, les entités sont directement opposées.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Settler",     de = "Siedler",     fr = "Settler" },
        { ParameterType.ScriptName, en = "Destination", de = "Ziel",        fr = "Destination" },
        { ParameterType.Number,     en = "Distance",    de = "Entfernung",  fr = "Distance" },
        { ParameterType.Number,     en = "Angle",       de = "Winkel",      fr = "Angle" },
    },
}

function B_Reward_MoveToPosition:GetRewardTable()
    return { Reward.Custom, {self, self.CustomFunction} }
end

function B_Reward_MoveToPosition:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Target = _Parameter;
    elseif (_Index == 2) then
        self.Distance = _Parameter * 1;
    elseif (_Index == 3) then
        self.Angle = _Parameter * 1;
    end
end

function B_Reward_MoveToPosition:CustomFunction(_Quest)
    if not IsExisting(self.Entity) or not IsExisting(self.Target) then
        return;
    end
    self.Angle = self.Angle or 0;

    local entity = GetID(self.Entity);
    local target = GetID(self.Target);
    local orientation = Logic.GetEntityOrientation(target);
    local x,y,z = Logic.EntityGetPos(target);
    if Logic.IsBuilding(target) == 1 then
        x, y = Logic.GetBuildingApproachPosition(target);
        orientation = orientation -90;
    end
    x = x + self.Distance * math.cos( math.rad(orientation+self.Angle) );
    y = y + self.Distance * math.sin( math.rad(orientation+self.Angle) );
    Logic.MoveSettler(entity, x, y);
    self.EntityMovingJob = API.StartJob( function(_entityID, _targetID)
        if Logic.IsEntityMoving(_entityID) == false then
            LookAt(_entityID, _targetID);
            return true;
        end
    end, entity, target);
end

function B_Reward_MoveToPosition:Reset(_Quest)
    if self.EntityMovingJob then
        API.EndJob(self.EntityMovingJob);
    end
end

function B_Reward_MoveToPosition:Debug(_Quest)
    if tonumber(self.Distance) == nil or self.Distance < 50 then
        error(_Quest.Identifier.. ": " ..self.Name.. ": Distance is nil or to short!");
        return true;
    elseif not IsExisting(self.Entity) or not IsExisting(self.Target) then
        error(_Quest.Identifier.. ": " ..self.Name.. ": Mover entity or target entity does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reward_MoveToPosition);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler gewinnt das Spiel mit einem animierten Siegesfest.
--
-- Wenn nach dem Sieg weiter gespielt wird, wird das Fest gelöscht.
--
-- <h5>Multiplayer</h5>
-- Nicht für Multiplayer geeignet.
--
-- @within Reward
--
function Reward_VictoryWithParty()
    return B_Reward_VictoryWithParty:new();
end

B_Reward_VictoryWithParty = {
    Name = "Reward_VictoryWithParty",
    Description = {
        en = "Reward: (Singleplayer) The player wins the game with an animated festival on the market. Continue playing deleates the festival.",
        de = "Lohn: (Einzelspieler) Der Spieler gewinnt das Spiel mit einer animierten Siegesfeier. Bei weiterspielen wird das Fest gelöscht.",
        fr = "Récompense: (Joueur unique) Le joueur gagne la partie avec une fête de la victoire animée. Si le joueur continue à jouer, la fête est effacée.",
    },
    Parameter = {}
};

function B_Reward_VictoryWithParty:GetRewardTable()
    return {Reward.Custom, {self, self.CustomFunction}};
end

function B_Reward_VictoryWithParty:AddParameter(_Index, _Parameter)
end

function B_Reward_VictoryWithParty:CustomFunction(_Quest)
    if Framework.IsNetworkGame() then
        error(_Quest.Identifier.. ": " ..self.Name.. ": Can not be used in multiplayer!");
        return;
    end
    Victory(g_VictoryAndDefeatType.VictoryMissionComplete);
    local pID = _Quest.ReceivingPlayer;

    local market = Logic.GetMarketplace(pID);
    if IsExisting(market) then
        local pos = GetPosition(market)
        Logic.CreateEffect(EGL_Effects.FXFireworks01,pos.X,pos.Y,0);
        Logic.CreateEffect(EGL_Effects.FXFireworks02,pos.X,pos.Y,0);

        local Generated = self:GenerateParty(pID);
        ModuleBehaviorCollection.Global.VictoryWithPartyEntities[pID] = Generated;

        Logic.ExecuteInLuaLocalState(string.format(
            [[
            if IsExisting(%d) then
                CameraAnimation.AllowAbort = false
                CameraAnimation.QueueAnimation(CameraAnimation.SetCameraToEntity, %d)
                CameraAnimation.QueueAnimation(CameraAnimation.StartCameraRotation, 5)
                CameraAnimation.QueueAnimation(CameraAnimation.Stay ,9999)
            end

            GUI_Window.ContinuePlayingClicked_Orig_Reward_VictoryWithParty = GUI_Window.ContinuePlayingClicked
            GUI_Window.ContinuePlayingClicked = function()
                GUI_Window.ContinuePlayingClicked_Orig_Reward_VictoryWithParty()
                
                local PlayerID = GUI.GetPlayerID()
                GUI.SendScriptCommand("B_Reward_VictoryWithParty:ClearParty(" ..PlayerID.. ")")

                CameraAnimation.AllowAbort = true
                CameraAnimation.Abort()
            end
            ]],
            market,
            market
        ));
    end
end

function B_Reward_VictoryWithParty:ClearParty(_PlayerID)
    if ModuleBehaviorCollection.Global.VictoryWithPartyEntities[_PlayerID] then
        for k, v in pairs(ModuleBehaviorCollection.Global.VictoryWithPartyEntities[_PlayerID]) do
            DestroyEntity(v);
        end
        ModuleBehaviorCollection.Global.VictoryWithPartyEntities[_PlayerID] = nil;
    end
end

function B_Reward_VictoryWithParty:GenerateParty(_PlayerID)
    local GeneratedEntities = {};
    local Marketplace = Logic.GetMarketplace(_PlayerID);
    if Marketplace ~= nil and Marketplace ~= 0 then
        local MarketX, MarketY = Logic.GetEntityPosition(Marketplace);
        local ID = Logic.CreateEntity(Entities.D_X_Garland, MarketX, MarketY, 0, _PlayerID)
        table.insert(GeneratedEntities, ID);
        for j=1, 10 do
            for k=1,10 do
                local SettlersX = MarketX -700+ (j*150);
                local SettlersY = MarketY -700+ (k*150);
                
                local rand = Logic.GetRandom(100);
                
                if rand > 70 then
                    local SettlerType = API.GetRandomSettlerType();
                    local Orientation = Logic.GetRandom(360);
                    local WorkerID = Logic.CreateEntityOnUnblockedLand(SettlerType, SettlersX, SettlersY, Orientation, _PlayerID);
                    Logic.SetTaskList(WorkerID, TaskLists.TL_WORKER_FESTIVAL_APPLAUD_SPEECH);
                    table.insert(GeneratedEntities, WorkerID);
                end
            end
        end
    end
    return GeneratedEntities;
end

function B_Reward_VictoryWithParty:Debug(_Quest)
    return false;
end

Swift:RegisterBehavior(B_Reward_VictoryWithParty);

-- -------------------------------------------------------------------------- --

---
-- Ändert die Sichtbarkeit eines Entity.
--
-- @param[type=string]  _ScriptName Skriptname des Entity
-- @param[type=boolean] _Visible    Sichtbarkeit an/aus
--
-- @within Reprisal
--
function Reward_SetVisible(...)
    return B_Reward_SetVisible:new(...)
end

B_Reward_SetVisible = Swift.LuaBase:CopyTable(B_Reprisal_SetVisible);
B_Reward_SetVisible.Name = "Reward_SetVisible";
B_Reward_SetVisible.Description.en = "Reward: Changes the visibility of an entity. If the entity is a spawner the spawned entities will be affected.";
B_Reward_SetVisible.Description.de = "Lohn: Setzt die Sichtbarkeit einer Entity. Handelt es sich um einen Spawner werden auch die gespawnten Entities beeinflusst.";
B_Reward_SetVisible.Description.fr = "Récompense: Définit la visibilité d'une Entity. S'il s'agit d'un spawn, les entités spawnées sont également influencées.";
B_Reward_SetVisible.GetReprisalTable = nil;

B_Reward_SetVisible.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Swift:RegisterBehavior(B_Reward_SetVisible);

-- -------------------------------------------------------------------------- --

---
-- Macht das Entity verwundbar oder unverwundbar.
--
-- Bei einem Battalion wirkt sich das Behavior auf alle Soldaten und den
-- (unsichtbaren) Leader aus. Wird das Behavior auf ein Spawner Entity 
-- angewendet, werden die gespawnten Entities genommen.
--
-- @param[type=string]  _ScriptName Skriptname des Entity
-- @param[type=boolean] _Vulnerable Verwundbarkeit an/aus
--
-- @within Reward
--
function Reward_SetVulnerability(...)
    return B_Reward_SetVulnerability:new(...);
end

B_Reward_SetVulnerability = Swift.LuaBase:CopyTable(B_Reprisal_SetVulnerability);
B_Reward_SetVulnerability.Name = "Reward_SetVulnerability";
B_Reward_SetVulnerability.Description.en = "Reward: Changes the vulnerability of the entity. If the entity is a spawner the spawned entities will be affected.";
B_Reward_SetVulnerability.Description.de = "Lohn: Macht eine Entity verwundbar oder unverwundbar. Handelt es sich um einen Spawner, sind die gespawnten Entities betroffen.";
B_Reward_SetVulnerability.Description.fr = "Récompense: Rend une Entité vulnérable ou invulnérable. S'il s'agit d'un spawn, les entités spawnées sont affectées.";
B_Reward_SetVulnerability.GetReprisalTable = nil;

B_Reward_SetVulnerability.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Swift:RegisterBehavior(B_Reward_SetVulnerability);

-- -------------------------------------------------------------------------- --

---
-- Ändert das Model eines Entity.
--
-- In Verbindung mit Reward_SetVisible oder Reprisal_SetVisible können
-- Script Entites ein neues Model erhalten und sichtbar gemacht werden.
-- Das hat den Vorteil, das Script Entities nicht überbaut werden können.
--
-- @param[type=string] _ScriptName Skriptname des Entity
-- @param[type=string] _Model      Neues Model
--
-- @within Reward
--
function Reward_SetModel(...)
    return B_Reward_SetModel:new(...);
end

B_Reward_SetModel = Swift.LuaBase:CopyTable(B_Reprisal_SetModel);
B_Reward_SetModel.Name = "Reward_SetModel";
B_Reward_SetModel.Description.en = "Reward: Changes the model of the entity. Be careful, some models crash the game.";
B_Reward_SetModel.Description.de = "Lohn: Ändert das Model einer Entity. Achtung: Einige Modelle führen zum Absturz.";
B_Reward_SetModel.Description.fr = "Récompense: Modifie le modèle d'une entité. Attention : certains modèles entraînent un plantage.";
B_Reward_SetModel.GetReprisalTable = nil;

B_Reward_SetModel.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } }
end

Swift:RegisterBehavior(B_Reward_SetModel);

-- -------------------------------------------------------------------------- --

---
-- Gibt oder entzieht einem KI-Spieler die Kontrolle über ein Entity.
--
-- @param[type=string]  _ScriptName Skriptname des Entity
-- @param[type=boolean] _Controlled Durch KI kontrollieren an/aus
--
-- @within Reward
--
function Reward_AI_SetEntityControlled(...)
    return B_Reward_AI_SetEntityControlled:new(...);
end

B_Reward_AI_SetEntityControlled = {
    Name = "Reward_AI_SetEntityControlled",
    Description = {
        en = "Reward: Bind or Unbind an entity or a battalion to/from an AI player. The AI player must be activated!",
        de = "Lohn: Die KI kontrolliert die Entity oder der KI die Kontrolle entziehen. Die KI muss aktiv sein!",
        fr = "Récompense: L'IA contrôle l'entité ou retirer le contrôle à l'IA. L'IA doit être active !",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "Entity",            de = "Entity",                 fr = "Entité", },
        { ParameterType.Custom,     en = "AI control entity", de = "KI kontrolliert Entity", fr = "L'IA contrôle l'entité", },
    },
}

function B_Reward_AI_SetEntityControlled:GetRewardTable()
    return { Reward.Custom, { self, self.CustomFunction } }
end

function B_Reward_AI_SetEntityControlled:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Entity = _Parameter;
    elseif (_Index == 1) then
        self.Hidden = API.ToBoolean(_Parameter)
    end
end

function B_Reward_AI_SetEntityControlled:CustomFunction(_Quest)
    if not IsExisting(self.Entity) then
        return;
    end
    local eID = GetID(self.Entity);
    local pID = Logic.EntityGetPlayer(eID);
    local eType = Logic.GetEntityType(eID);
    local tName = Logic.GetEntityTypeName(eType);
    if string.find(tName, "S_") or string.find(tName, "B_NPC_Bandits")
    or string.find(tName, "B_NPC_Barracks") then
        local spawned = {Logic.GetSpawnedEntities(eID)};
        for i=1, #spawned do
            if Logic.IsLeader(spawned[i]) == 1 then
                AICore.HideEntityFromAI(pID, spawned[i], not self.Hidden);
            end
        end
    else
        AICore.HideEntityFromAI(pID, eID, not self.Hidden);
    end
end

function B_Reward_AI_SetEntityControlled:GetCustomData(_Index)
    if _Index == 1 then
        return { "false", "true" }
    end
end

function B_Reward_AI_SetEntityControlled:Debug(_Quest)
    if not IsExisting(self.Entity) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entity '"..  self.Entity .. "' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reward_AI_SetEntityControlled);

-- -------------------------------------------------------------------------- --
-- Trigger                                                                    --
-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald mindestens X von Y Quests fehlgeschlagen sind.
--
-- @param[type=number] _MinAmount Mindestens zu verlieren (max. 5)
-- @param[type=number] _QuestAmount Anzahl geprüfter Quests (max. 5 und >= _MinAmount)
-- @param[type=string] _Quest1      Name des 1. Quest
-- @param[type=string] _Quest2      Name des 2. Quest
-- @param[type=string] _Quest3      Name des 3. Quest
-- @param[type=string] _Quest4      Name des 4. Quest
-- @param[type=string] _Quest5      Name des 5. Quest
--
-- @within Trigger
--
function Trigger_OnAtLeastXOfYQuestsFailed(...)
    return B_Trigger_OnAtLeastXOfYQuestsFailed:new(...);
end

B_Trigger_OnAtLeastXOfYQuestsFailed = {
    Name = "Trigger_OnAtLeastXOfYQuestsFailed",
    Description = {
        en = "Trigger: if at least X of Y given quests has been finished successfully.",
        de = "Auslöser: wenn X von Y angegebener Quests fehlgeschlagen sind.",
        fr = "Déclencheur: lorsque X des Y quêtes indiquées ont échoué.",
    },
    Parameter = {
        { ParameterType.Custom,    en = "Least Amount", de = "Mindest Anzahl",  fr = "Nombre minimum" },
        { ParameterType.Custom,    en = "Quest Amount", de = "Quest Anzahl",    fr = "Nombre de quêtes" },
        { ParameterType.QuestName, en = "Quest name 1", de = "Questname 1",     fr = "Nom de la quête 1" },
        { ParameterType.QuestName, en = "Quest name 2", de = "Questname 2",     fr = "Nom de la quête 2" },
        { ParameterType.QuestName, en = "Quest name 3", de = "Questname 3",     fr = "Nom de la quête 3" },
        { ParameterType.QuestName, en = "Quest name 4", de = "Questname 4",     fr = "Nom de la quête 4" },
        { ParameterType.QuestName, en = "Quest name 5", de = "Questname 5",     fr = "Nom de la quête 5" },
    },
}

function B_Trigger_OnAtLeastXOfYQuestsFailed:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function B_Trigger_OnAtLeastXOfYQuestsFailed:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.LeastAmount = tonumber(_Parameter)
    elseif (_Index == 1) then
        self.QuestAmount = tonumber(_Parameter)
    elseif (_Index == 2) then
        self.QuestName1 = _Parameter
    elseif (_Index == 3) then
        self.QuestName2 = _Parameter
    elseif (_Index == 4) then
        self.QuestName3 = _Parameter
    elseif (_Index == 5) then
        self.QuestName4 = _Parameter
    elseif (_Index == 6) then
        self.QuestName5 = _Parameter
    end
end

function B_Trigger_OnAtLeastXOfYQuestsFailed:CustomFunction()
    local least = 0
    for i = 1, self.QuestAmount do
		local QuestID = GetQuestID(self["QuestName"..i]);
        if IsValidQuest(QuestID) then
			if (Quests[QuestID].Result == QuestResult.Failure) then
				least = least + 1
				if least >= self.LeastAmount then
					return true
				end
			end
        end
    end
    return false
end

function B_Trigger_OnAtLeastXOfYQuestsFailed:Debug(_Quest)
    local leastAmount = self.LeastAmount
    local questAmount = self.QuestAmount
    if leastAmount <= 0 or leastAmount >5 then
        error(_Quest.Identifier .. ":" .. self.Name .. ": LeastAmount is wrong")
        return true
    elseif questAmount <= 0 or questAmount > 5 then
        error(_Quest.Identifier.. ": " ..self.Name .. ": QuestAmount is wrong")
        return true
    elseif leastAmount > questAmount then
        error(_Quest.Identifier.. ": " ..self.Name .. ": LeastAmount is greater than QuestAmount")
        return true
    end
    for i = 1, questAmount do
        if not IsValidQuest(self["QuestName"..i]) then
            error(_Quest.Identifier.. ": " ..self.Name .. ": Quest ".. self["QuestName"..i] .. " not found")
            return true
        end
    end
    return false
end

function B_Trigger_OnAtLeastXOfYQuestsFailed:GetCustomData(_Index)
    if (_Index == 0) or (_Index == 1) then
        return {"1", "2", "3", "4", "5"}
    end
end

Swift:RegisterBehavior(B_Trigger_OnAtLeastXOfYQuestsFailed)

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, sobald die Munition in der Kriegsmaschine erschöpft ist.
--
-- @param[type=string] _ScriptName Skriptname des Entity
--
-- @within Trigger
--
function Trigger_AmmunitionDepleted(...)
    return B_Trigger_AmmunitionDepleted:new(...);
end

B_Trigger_AmmunitionDepleted = {
    Name = "Trigger_AmmunitionDepleted",
    Description = {
        en = "Trigger: if the ammunition of the entity is depleted.",
        de = "Auslöser: wenn die Munition der Entity aufgebraucht ist.",
        fr = "Déclencheur: lorsque les munitions de l'entité sont épuisées.",
    },
    Parameter = {
        { ParameterType.Scriptname, en = "Script name", de = "Skriptname", fr = "Nom de l'entité" },
    },
}

function B_Trigger_AmmunitionDepleted:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function B_Trigger_AmmunitionDepleted:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Scriptname = _Parameter
    end
end

function B_Trigger_AmmunitionDepleted:CustomFunction()
    if not IsExisting(self.Scriptname) then
        return false;
    end

    local EntityID = GetID(self.Scriptname);
    if Logic.GetAmmunitionAmount(EntityID) > 0 then
        return false;
    end

    return true;
end

function B_Trigger_AmmunitionDepleted:Debug(_Quest)
    if not IsExisting(self.Scriptname) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": '"..self.Scriptname.."' is destroyed!");
        return true
    end
    return false
end

Swift:RegisterBehavior(B_Trigger_AmmunitionDepleted)

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, wenn exakt einer von beiden Quests erfolgreich ist.
--
-- @param[type=string] _QuestName1 Name des ersten Quest
-- @param[type=string] _QuestName2 Name des zweiten Quest
--
-- @within Trigger
--
function Trigger_OnExactOneQuestIsWon(...)
    return B_Trigger_OnExactOneQuestIsWon:new(...);
end

B_Trigger_OnExactOneQuestIsWon = {
    Name = "Trigger_OnExactOneQuestIsWon",
    Description = {
        en = "Trigger: if one of two given quests has been finished successfully, but NOT both.",
        de = "Auslöser: wenn eine von zwei angegebenen Quests (aber NICHT beide) erfolgreich abgeschlossen wurde.",
        fr = "Déclencheur: lorsque l'une des deux quêtes indiquées (mais PAS les deux) a été accomplie avec succès.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name 1", de = "Questname 1", fr = "Nom de la quête 1", },
        { ParameterType.QuestName, en = "Quest Name 2", de = "Questname 2", fr = "Nom de la quête 2", },
    },
}

function B_Trigger_OnExactOneQuestIsWon:GetTriggerTable()
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function B_Trigger_OnExactOneQuestIsWon:AddParameter(_Index, _Parameter)
    self.QuestTable = {};

    if (_Index == 0) then
        self.Quest1 = _Parameter;
    elseif (_Index == 1) then
        self.Quest2 = _Parameter;
    end
end

function B_Trigger_OnExactOneQuestIsWon:CustomFunction(_Quest)
    local Quest1 = Quests[GetQuestID(self.Quest1)];
    local Quest2 = Quests[GetQuestID(self.Quest2)];
    if Quest2 and Quest1 then
        local Quest1Succeed = (Quest1.State == QuestState.Over and Quest1.Result == QuestResult.Success);
        local Quest2Succeed = (Quest2.State == QuestState.Over and Quest2.Result == QuestResult.Success);
        if (Quest1Succeed and not Quest2Succeed) or (not Quest1Succeed and Quest2Succeed) then
            return true;
        end
    end
    return false;
end

function B_Trigger_OnExactOneQuestIsWon:Debug(_Quest)
    if self.Quest1 == self.Quest2 then
        error(_Quest.Identifier.. ": " ..self.Name..": Both quests are identical!");
        return true;
    elseif not IsValidQuest(self.Quest1) then
        error(_Quest.Identifier.. ": " ..self.Name..": Quest '"..self.Quest1.."' does not exist!");
        return true;
    elseif not IsValidQuest(self.Quest2) then
        error(_Quest.Identifier.. ": " ..self.Name..": Quest '"..self.Quest2.."' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Trigger_OnExactOneQuestIsWon);

-- -------------------------------------------------------------------------- --

---
-- Startet den Quest, wenn exakt einer von beiden Quests fehlgeschlagen ist.
--
-- @param[type=string] _QuestName1 Name des ersten Quest
-- @param[type=string] _QuestName2 Name des zweiten Quest
--
-- @within Trigger
--
function Trigger_OnExactOneQuestIsLost(...)
    return B_Trigger_OnExactOneQuestIsLost:new(...);
end

B_Trigger_OnExactOneQuestIsLost = {
    Name = "Trigger_OnExactOneQuestIsLost",
    Description = {
        en = "Trigger: If one of two given quests has been lost, but NOT both.",
        de = "Auslöser: Wenn einer von zwei angegebenen Quests (aber NICHT beide) fehlschlägt.",
        fr = "Déclencheur: Si l'une des deux quêtes indiquées (mais PAS les deux) échoue.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest Name 1", de = "Questname 1", fr = "Nom de la quête 1", },
        { ParameterType.QuestName, en = "Quest Name 2", de = "Questname 2", fr = "Nom de la quête 2", },
    },
}

function B_Trigger_OnExactOneQuestIsLost:GetTriggerTable()
    return {Triggers.Custom2, {self, self.CustomFunction}};
end

function B_Trigger_OnExactOneQuestIsLost:AddParameter(_Index, _Parameter)
    self.QuestTable = {};

    if (_Index == 0) then
        self.Quest1 = _Parameter;
    elseif (_Index == 1) then
        self.Quest2 = _Parameter;
    end
end

function B_Trigger_OnExactOneQuestIsLost:CustomFunction(_Quest)
    local Quest1 = Quests[GetQuestID(self.Quest1)];
    local Quest2 = Quests[GetQuestID(self.Quest2)];
    if Quest2 and Quest1 then
        local Quest1Succeed = (Quest1.State == QuestState.Over and Quest1.Result == QuestResult.Failure);
        local Quest2Succeed = (Quest2.State == QuestState.Over and Quest2.Result == QuestResult.Failure);
        if (Quest1Succeed and not Quest2Succeed) or (not Quest1Succeed and Quest2Succeed) then
            return true;
        end
    end
    return false;
end

function B_Trigger_OnExactOneQuestIsLost:Debug(_Quest)
    if self.Quest1 == self.Quest2 then
        error(_Quest.Identifier.. ": " ..self.Name..": Both quests are identical!");
        return true;
    elseif not IsValidQuest(self.Quest1) then
        error(_Quest.Identifier.. ": " ..self.Name..": Quest '"..self.Quest1.."' does not exist!");
        return true;
    elseif not IsValidQuest(self.Quest2) then
        error(_Quest.Identifier.. ": " ..self.Name..": Quest '"..self.Quest2.."' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Trigger_OnExactOneQuestIsLost);

