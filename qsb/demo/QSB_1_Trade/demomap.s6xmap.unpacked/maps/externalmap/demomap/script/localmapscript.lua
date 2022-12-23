function StartScript()
    InitTradeConditions();
end

function InitTradeConditions()
    -- Basispreise verändern
    API.PurchaseSetBasePriceForPlayer(
        3,
        function(_Type, _Good, _PlayerID1, _PlayerID2)
            local BasePrice = MerchantSystem.BasePrices[_Good];
            -- Nur für Spieler 1 wird der Basispreis halbiert
            if _PlayerID1 == 1 then
                BasePrice = BasePrice * 0.5;
            end
           return (BasePrice == nil and 3) or BasePrice;
        end
    );
    API.PurchaseSetBasePriceForPlayer(
        4,
        function(_Type, _Good, _PlayerID1, _PlayerID2)
            local BasePrice = MerchantSystem.BasePrices[_Good];
            -- Nur für Spieler 1 wird der Basispreis verdoppelt
            if _PlayerID1 == 1 then
                BasePrice = BasePrice * 2;
            end
           return (BasePrice == nil and 3) or BasePrice;
        end
    );

    -- Inflation verändern
    API.PurchaseSetInflationForPlayer(
        5,
        function(_Type, _Good, _OfferCount, _Price, _PlayerID1, _PlayerID2)
            -- Nur für Spieler 1 ist die Inflation nicht auf ein
            -- Maximum von 8 beschränkt.
            if _PlayerID1 ~= 1 and _OfferCount > 8 then
                OfferCount = 8;
            end
            -- Die Berechnung bleibt unverändert.
            local Result = _Price + (math.ceil(_Price / 4) * _OfferCount);
            return (Result < _Price and _Price) or Result;
        end
    );

    -- Increased Discount
    API.PurchaseSetTraderAbilityForPlayer(
        2,
        function(_Type, _Good, _BasePrice, _PlayerID1, _PlayerID2)
            local Modifier = 1.0;
            -- Nur für Elias wird ein Bonus gewährt
            local KnightType =  Logic.GetEntityType(Logic.GetKnightID(_PlayerID1));
            if KnightType == Entities.U_KnightTrading then
                Modifier = 1.4;
           end
           return math.ceil(_BasePrice / Modifier);
        end
    );
end

