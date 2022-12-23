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

