
---
-- Ermittelt alle Entities in der Kategorie auf dem Territorium und gibt
-- sie als Liste zurück.
--
-- <b>QSB:</b> API.SearchEntitiesOfCategoryInTerritory(_Territory, _Category, _PlayerID)
-- <p><b>Alias:</b> GetEntitiesOfCategoryInTerritory</p>
--
-- @param[type=number] _PlayerID    PlayerID [0-8] oder -1 für alle
-- @param[type=number] _Category  Kategorie, der die Entities angehören
-- @param[type=number] _Territory Zielterritorium
-- @within QSB_1_Entity
--
-- @usage
-- local Found = API.GetEntitiesOfCategoryInTerritory(1, EntityCategories.Hero, 5)
--
function API.GetEntitiesOfCategoryInTerritory(_PlayerID, _Category, _Territory)
    return API.SearchEntitiesOfCategoryInTerritory (_Territory, _Category, _PlayerID)
end
GetEntitiesOfCategoryInTerritory = API.GetEntitiesOfCategoryInTerritory;