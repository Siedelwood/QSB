# Module <code>qsb_2_buildingcost</code>
Setzt neue Baukosten eines Gebäudes über das BCS.




### Reward_EditBuildingUpgradeCosts (_upgradeCategory, _Controlled)
source/qsb_2_buildingcost.lua.html#77

Setzt neue Ausbaukosten eines Gebäudes über das BCS.





### BCS
source/qsb_2_buildingcost.lua.html#159

Upgradelevel für die Gebäudekosten





### BCS.SetUpgradeCosts (_Building, _Level, _Good1, _Amount1, _Good2, _Amount2)
source/qsb_2_buildingcost.lua.html#185

Überschreibt die Ausbaukosten eines Gebäudes für eingegebenes Level




### Verwandte Themen:
<ul>


<a href="qsb_2_buildingcost.html#BCS.EditUpgradeCosts">BCS.EditUpgradeCosts</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Neue Ausbaukosten definieren
</span>BCS.SetUpgradeCosts(Entities.B_Cathedral, <span class="number">1</span>, Goods.G_Wood, <span class="number">100</span>, Goods.G_Stone, <span class="number">100</span>)
<span class="comment">-- Auf Originalkosten zurücksetzen
</span>BCS.SetUpgradeCosts(Entities.B_Cathedral, <span class="number">1</span>, <span class="number">0</span>)</pre>


</ul>


### BCS.SetConstructionCosts (_Building, _Amount1, _Good2, _Amount2, _AddToBaseCost)
source/qsb_2_buildingcost.lua.html#230

Überschreibt die Baukosten eines Gebäudes
 Hier muss beachtet werden, dass der erste Kostenparameter zusätzliche Kosten für den ersten Rohstoff darstellen und nicht den neuen Kostenwert




### Verwandte Themen:
<ul>


<a href="qsb_2_buildingcost.html#BCS.SetUpgradeCosts">BCS.SetUpgradeCosts</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Neue Ausbaukosten definieren (erste Rohstoffmenge wird auf Originalkosten draufgerechnet)
</span>BCS.SetUpgradeCosts(UpgradeCategories.BroomMaker, <span class="number">50</span>, Goods.G_Gold, <span class="number">100</span>, <span class="keyword">true</span>)
<span class="comment">-- Auf Originalkosten zurücksetzen
</span>BCS.SetUpgradeCosts(UpgradeCategories.BroomMaker, <span class="keyword">nil</span>)</pre>


</ul>


### BCS.SetHakimUpgradeDiscount (_Discount)
source/qsb_2_buildingcost.lua.html#259

Gibt an welchen Rabatt Hakim auf das Ausbauen von Gebäuden erhält




### Verwandte Themen:
<ul>


<a href="qsb_2_buildingcost.html#BCS.SetUpgradeDiscountFunction">BCS.SetUpgradeDiscountFunction</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Hakim bekommt 20 Prozent Rabatt auf den Ausbau von Gebäuden
</span>BCS.SetHakimUpgradeDiscount(<span class="number">0.2</span>)</pre>


</ul>


### BCS.SetUpgradeDiscountFunction (_Function, _CanBeZero)
source/qsb_2_buildingcost.lua.html#290

Übergibt eine Rabattfunktion für den Ausbau von Gebäuden.
 Diese gelten nur für angepasste Ausbaukosten und können nicht mehr zurückgenommen werden.





### Verwandte Themen:
<ul>


<a href="qsb_2_buildingcost.html#BCS.SetHakimUpgradeDiscount">BCS.SetHakimUpgradeDiscount</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Der Spieler bekommt 20 Prozent Rabatt auf den Ausbau von Gebäuden.
</span><span class="comment">-- Die Kosten des zweiten Rohstoffs wird werden immer mindestens 1 sein.
</span>BCS.SetUpgradeDiscountFunction(<span class="keyword">function</span>()
    <span class="keyword">return</span> <span class="number">0.2</span>
<span class="keyword">end</span>, <span class="keyword">false</span>)</pre>


</ul>


### BCS.SetConstructionOriginalGoodDiscountFunction (_Function, _CanBeZero)
source/qsb_2_buildingcost.lua.html#313

Übergibt eine Rabattfunktion für die Zusatzkosten auf den Originalrohstoff beim den Bau von Gebäuden.
 Diese gelten nur für angepasste Baukosten und können nicht mehr zurückgenommen werden.





### Verwandte Themen:
<ul>


<a href="qsb_2_buildingcost.html#BCS.SetConstructionAddedGoodDiscountFunction">BCS.SetConstructionAddedGoodDiscountFunction</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Der Spieler bekommt 20 Prozent Rabatt auf die Zusatzkosten auf den Originalrohstoff für den Bau von Gebäuden.
</span><span class="comment">-- Die Zusatzkosten können auf Null herabgerundet werden.
</span>BCS.SetConstructionOriginalGoodDiscountFunction(<span class="keyword">function</span>()
    <span class="keyword">return</span> <span class="number">0.2</span>
<span class="keyword">end</span>, <span class="keyword">true</span>)</pre>


</ul>


### BCS.SetConstructionAddedGoodDiscountFunction (_Function, _CanBeZero)
source/qsb_2_buildingcost.lua.html#336

Übergibt eine Rabattfunktion für die Kosten des zweiten Rohstoffs für den Bauen von Gebäuden.
 Diese gelten nur für angepasste Baukosten und können nicht mehr zurückgenommen werden.





### Verwandte Themen:
<ul>


<a href="qsb_2_buildingcost.html#BCS.SetConstructionOriginalGoodDiscountFunction">BCS.SetConstructionOriginalGoodDiscountFunction</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Der Spieler bekommt 20 Prozent Rabatt auf die Kosten des zweiten Rohstoffs beim Bau von Gebäuden.
</span><span class="comment">-- Die Kosten des zweiten Rohstoffs wird werden immer mindestens 1 sein.
</span>BCS.SetConstructionAddedGoodDiscountFunction(<span class="keyword">function</span>()
    <span class="keyword">return</span> <span class="number">0.2</span>
<span class="keyword">end</span>, <span class="keyword">false</span>)</pre>


</ul>


### BCS.EditBuildingCosts (_UpgradeCategory, _Amount1, _Good2, _Amount2, _AddToBaseCost)
source/qsb_2_buildingcost.lua.html#360

Überschreibt die Baukosten eines Gebäudes




### Verwandte Themen:
<ul>


<a href="qsb_2_buildingcost.html#BCS.SetUpgradeCosts">BCS.SetUpgradeCosts</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Neue Ausbaukosten definieren
</span>BCS.SetUpgradeCosts(UpgradeCategories.BroomMaker, <span class="number">100</span>, Goods.G_Gold, <span class="number">100</span>)
<span class="comment">-- Auf Originalkosten zurücksetzen
</span>BCS.SetUpgradeCosts(UpgradeCategories.BroomMaker, <span class="keyword">nil</span>)</pre>


</ul>


### BCS.EditUpgradeCosts (_UpgradeCategory, _Level, _Good1, _Amount1, _Good2, _Amount2)
source/qsb_2_buildingcost.lua.html#414

Überschreibt die Ausbaukosten eines Gebäudes für eingegebenes Level




### Verwandte Themen:
<ul>


<a href="qsb_2_buildingcost.html#BCS.SetUpgradeCosts">BCS.SetUpgradeCosts</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Neue Ausbaukosten definieren
</span>BCS.SetUpgradeCosts(UpgradeCategories.Cathedral, <span class="number">1</span>, Goods.G_Wood, <span class="number">100</span>, Goods.G_Stone, <span class="number">100</span>)
<span class="comment">-- Auf Originalkosten zurücksetzen
</span>BCS.SetUpgradeCosts(UpgradeCategories.Cathedral, <span class="number">1</span>, <span class="number">0</span>)</pre>


</ul>


### BCS.EditRoadCosts (_Factor1, _Good2, _Factor2)
source/qsb_2_buildingcost.lua.html#447

Überschreibt die Baukosten der Straßen





### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Neue Baukosten definieren
</span>BCS.EditRoadCosts(<span class="number">5</span>, Goods.G_Gold, <span class="number">5</span>)
<span class="comment">-- Auf Originalkosten zurücksetzen
</span>BCS.EditRoadCosts(<span class="keyword">nil</span>)</pre>


</ul>


### BCS.EditWallCosts (_Factor1, _Good2, _Factor2)
source/qsb_2_buildingcost.lua.html#483

Überschreibt die Baukosten der Mauern





### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Neue Baukosten definieren
</span>BCS.EditWallCosts(<span class="number">5</span>, Goods.G_Gold, <span class="number">5</span>)
<span class="comment">-- Auf Originalkosten zurücksetzen
</span>BCS.EditWallCosts(<span class="keyword">nil</span>)</pre>


</ul>


### BCS.EditPalisadeCosts (_Factor1, _Good2, _Factor2)
source/qsb_2_buildingcost.lua.html#519

Überschreibt die Baukosten der Palisaden





### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Neue Baukosten definieren
</span>BCS.EditPalisadeCosts(<span class="number">5</span>, Goods.G_Gold, <span class="number">5</span>)
<span class="comment">-- Auf Originalkosten zurücksetzen
</span>BCS.EditPalisadeCosts(<span class="keyword">nil</span>)</pre>


</ul>


### BCS.EditTrailCosts (_Good1, _Factor1, _Good2, _Factor2)
source/qsb_2_buildingcost.lua.html#556

Überschreibt die Baukosten der Wege





### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Neue Baukosten definieren
</span>BCS.EditTrailCosts(Goods.G_Wood ,<span class="number">5</span>, Goods.G_Gold, <span class="number">5</span>)
<span class="comment">-- Auf Originalkosten zurücksetzen
</span>BCS.EditTrailCosts(<span class="keyword">nil</span>)</pre>


</ul>


### BCS.SetKnockDownFactor (_Factor1, _Factor2)
source/qsb_2_buildingcost.lua.html#589

Setzt den Rückerstattungssatz beim Abriß von Gebäuden





### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Es wird die Hälfte Zurückerstattet
</span>BCS.SetKnockDownFactor(<span class="number">0.5</span>, <span class="number">0.5</span>)</pre>


</ul>


### BCS.EditFestivalCosts (_Factor1, _Good2, _Factor2)
source/qsb_2_buildingcost.lua.html#621

Überschreibt die Kosten für Feste





### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Neue Kosten definieren
</span>BCS.EditFestivalCosts(<span class="number">5</span>, Goods.G_Stone, <span class="number">5</span>)
<span class="comment">-- Auf Originalkosten zurücksetzen
</span>BCS.EditFestivalCosts(<span class="keyword">nil</span>)</pre>


</ul>


### BCS.SetRefundCityGoods (_Flag)
source/qsb_2_buildingcost.lua.html#654

Sollen Stadtgüter zurückerstattet werden?





### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Stadtgüter werden zurückerstattet
</span>BCS.SetRefundCityGoods(<span class="keyword">true</span>)</pre>


</ul>


### BCS.SetCountGoodsOnMarketplace (_Flag)
source/qsb_2_buildingcost.lua.html#677

Sollen Güter auf dem Marktplatz betrachtet werden?





### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Güter auf dem Marktplatz werden betrachtet
</span>BCS.SetCountGoodsOnMarketplace(<span class="keyword">true</span>)</pre>


</ul>


