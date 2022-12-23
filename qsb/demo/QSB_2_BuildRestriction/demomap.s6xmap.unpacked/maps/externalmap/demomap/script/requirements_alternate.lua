-- Paradigma: Der Krieger
-- Der Spieler muss Truppen besitzen und Territorien erobern.
function SetBaronPromotionParadigmMilitary()
    KnightTitleRequirements[KnightTitles.Baron] = {}
    KnightTitleRequirements[KnightTitles.Baron].Settlers = 20
    KnightTitleRequirements[KnightTitles.Baron].Headquarters = 1
    KnightTitleRequirements[KnightTitles.Baron].Category = {
        {EntityCategories.Soldier, 12},
        {EntityCategories.Outpost, 2},
    }
end

-- Paradigma: Der Tycoon
-- Der Spieler muss seinen Siedlern Waren aufschwatzen.
function SetBaronPromotionParadigmEconomy()
    KnightTitleRequirements[KnightTitles.Baron] = {}
    KnightTitleRequirements[KnightTitles.Baron].Settlers = 30
    KnightTitleRequirements[KnightTitles.Baron].Consume = {
        {Goods.G_Bread, 15},
        {Goods.G_Sausage, 15},
        {Goods.G_Cheese, 15},
    }
    KnightTitleRequirements[KnightTitles.Baron].Products = {
        {GoodCategories.GC_Hygiene, 6},
    }
end

-- Paradigma: Der Gläubige
-- Der Spieler muss die Kirche ausbauen und fleißig beten.
function SetBaronPromotionParadigmFaith()
    KnightTitleRequirements[KnightTitles.Baron] = {}
    KnightTitleRequirements[KnightTitles.Baron].Settlers = 30
    KnightTitleRequirements[KnightTitles.Baron].Cathedrals = 2
    KnightTitleRequirements[KnightTitles.Baron].Custom = {
        {BaronPromotionParadigmFaith_CheckSermons,
         {4, 14},
         "Predigten abhalten",
         "Beweißt Eure Erfurcht vor Gott und betet was das Zeug hält!"}
    }
end

-- Prüfen, ob genug gebetet wurde.
-- Die Variable wird von einem Event aktualisiert.
BaronPromotionParadigmFaith_CheckSermons = function(_PlayerID, _NextTitle, _Index)
    if _PlayerID == 1 then
        return gvMission.SermonCount >= 3, gvMission.SermonCount, 3;
    end
    return true;
end

