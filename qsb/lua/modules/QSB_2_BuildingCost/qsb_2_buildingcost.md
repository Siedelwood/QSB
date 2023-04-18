### Reward_EditBuildingConstructionCosts (_upgradeCategory, _Controlled)

Setzt neue Baukosten eines Gebäudes über das BCS.

### BCS

Upgradelevel für die Gebäudekosten

### BCS.SetUpgradeCosts (_Building, _Level, _Good1, _Amount1, _Good2, _Amount2)

Überschreibt die Ausbaukosten eines Gebäudes für eingegebenes Level

### BCS.SetConstructionCosts (_Building, _Amount1, _Good2, _Amount2, _AddToBaseCost)

Überschreibt die Baukosten eines Gebäudes
 Hier muss beachtet werden, dass der erste Kostenparameter zusätzliche Kosten für den ersten Rohstoff darstellen und nicht den neuen Kostenwert

### BCS.SetHakimUpgradeDiscount (_Discount)

Gibt an welchen Rabatt Hakim auf das Ausbauen von Gebäuden erhält

### BCS.SetUpgradeDiscountFunction (_Function, _CanBeZero)

Übergibt eine Rabattfunktion für den Ausbau von Gebäuden.
 Diese gelten nur für angepasste Ausbaukosten und können nicht mehr zurückgenommen werden.


### BCS.SetConstructionOriginalGoodDiscountFunction (_Function, _CanBeZero)

Übergibt eine Rabattfunktion für die Zusatzkosten auf den Originalrohstoff beim den Bau von Gebäuden.
 Diese gelten nur für angepasste Baukosten und können nicht mehr zurückgenommen werden.


### BCS.SetConstructionAddedGoodDiscountFunction (_Function, _CanBeZero)

Übergibt eine Rabattfunktion für die Kosten des zweiten Rohstoffs für den Bauen von Gebäuden.
 Diese gelten nur für angepasste Baukosten und können nicht mehr zurückgenommen werden.


### BCS.EditBuildingCosts (_UpgradeCategory, _Amount1, _Good2, _Amount2, _AddToBaseCost)

Überschreibt die Baukosten eines Gebäudes

### BCS.EditUpgradeCosts (_UpgradeCategory, _Level, _Good1, _Amount1, _Good2, _Amount2)

Überschreibt die Ausbaukosten eines Gebäudes für eingegebenes Level

### BCS.EditRoadCosts (_Factor1, _Good2, _Factor2)

Überschreibt die Baukosten der Straßen

### BCS.EditWallCosts (_Factor1, _Good2, _Factor2)

Überschreibt die Baukosten der Mauern

### BCS.EditPalisadeCosts (_Factor1, _Good2, _Factor2)

Überschreibt die Baukosten der Palisaden

### BCS.EditTrailCosts (_Good1, _Factor1, _Good2, _Factor2)

Überschreibt die Baukosten der Wege

### BCS.SetKnockDownFactor (_Factor1, _Factor2)

Setzt den Rückerstattungssatz beim Abriß von Gebäuden

### BCS.EditFestivalCosts (_Factor1, _Good2, _Factor2)

Überschreibt die Kosten für Feste

### BCS.SetRefundCityGoods (_Flag)

Sollen Stadtgüter zurückerstattet werden?

### BCS.SetCountGoodsOnMarketplace (_Flag)

Sollen Güter auf dem Marktplatz betrachtet werden?

