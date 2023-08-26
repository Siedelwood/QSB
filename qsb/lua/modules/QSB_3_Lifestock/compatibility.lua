
---
-- Erlaube oder verbiete dem Spieler Schafe zu züchten.
--
-- Die Zucht wird immer synchron für alle Spieler erlaubt oder verboten.
--
-- <b>QSB:</b> API.ActivateSheepBreeding(_Flag)
--
-- @param[type=boolean] _Flag Schafzucht aktiv/inaktiv
-- @within QSB_3_Lifestock
--
function API.UseBreedSheeps(_Flag)
    API.ActivateSheepBreeding(_Flag)
end

---
-- Erlaube oder verbiete dem Spieler Kühe zu züchten.
--
-- Die Zucht wird immer synchron für alle Spieler erlaubt oder verboten.
--
-- <b>QSB:</b> API.ActivateCattleBreeding(_Flag)
--
-- @param[type=boolean] _Flag Kuhzucht aktiv/inaktiv
-- @within QSB_3_Lifestock
--
function API.UseBreedCattle(_Flag)
    API.ActivateCattleBreeding(_Flag)
end

---
-- Aktiviert oder deaktiviert den "Baby Mode" für Schafe.
--
-- Ist der Modus aktiv, werden neu gekaufte Tiere mit 40% ihrer Große erzeugt
-- und wachseln allmählich heran. Dies ist nur kosmetisch und hat keinen
-- Einfluss auf ihre Funktion.
--
-- <b>QSB:</b> API.ConfigureSheepBreeding(_Data)
--
-- @param[type=boolean] _Flag Baby Mode aktivieren/deaktivieren
-- @within QSB_3_Lifestock
--
function API.SetSheepBabyMode(_Flag)
    if GUI then
        return;
    end
    API.ConfigureSheepBreeding{
        UseCalves = true,
    }
end


---
-- Aktiviert oder deaktiviert den "Baby Mode" für Kühe.
--
-- Ist der Modus aktiv, werden neu gekaufte Tiere mit 40% ihrer Große erzeugt
-- und wachseln allmählich heran. Dies ist nur kosmetisch und hat keinen
-- Einfluss auf ihre Funktion.
--
-- <b>QSB:</b> API.ConfigureCattleBreeding(_Data)
--
-- @param[type=boolean] _Flag Baby Mode aktivieren/deaktivieren
-- @within QSB_3_Lifestock
--
function API.SetCattleBabyMode(_Flag)
    if GUI then
        return;
    end
    API.ConfigureCattleBreeding{
        UseCalves = true,
    }
end