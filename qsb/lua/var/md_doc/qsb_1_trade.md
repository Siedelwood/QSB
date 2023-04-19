# Module <code>qsb_1_trade</code>
Es kann in den Ablauf von Kauf und Verkauf eingegriffen werden.
 <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_1_trade.lua.html#19

Events, auf die reagiert werden kann.





### QSB.TraderTypes
source/qsb_1_trade.lua.html#29

Typen der Händler





### API.ModifyTradeOffer (_PlayerID, _GoodOrEntityType, _NewAmount)
source/qsb_1_trade.lua.html#859

Ändert die aktuelle Menge des Angebots im Händelrgebäude.

 Es kann ein beliebiger positiver Wert gesetzt werden. Es gibt keine
 Beschränkungen.

 <b>Hinweis</b>: Wird eine höherer Wert gesetzt, als das ursprüngliche
 Maximum, regenerieren sich die Angebote nicht, bis die zusätzlichen
 Angebote verkauft wurden.






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Angebote voll auffüllen
</span>API.ModifyTradeOffer(<span class="number">7</span>, Goods.G_Cheese, -<span class="number">1</span>);</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Angebote auffüllen
</span>API.ModifyTradeOffer(<span class="number">7</span>, Goods.G_Dye, <span class="number">2</span>);</pre></li>


</ul>


### API.PurchaseSetBasePriceForPlayer (_PlayerID, _Function)
source/qsb_1_trade.lua.html#121

Setzt die Funktion zur Bestimmung des Basispreis.  Die Änderung betrifft nur
 den angegebenen Spieler.
 Die Funktion muss den Basispreis der Ware zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
 übergeben werden.






### Beispiel:
<ul>


<pre class="example">API.PurchaseSetBasePriceForPlayer(<span class="number">2</span>, MyCalculationFunction);</pre>


</ul>


### API.PurchaseSetConditionForPlayer (_PlayerID, _Function)
source/qsb_1_trade.lua.html#250

Setzt eine Funktion zur Festlegung spezieller Ankaufsbedingungen.  Diese
 Bedingungen betreffen nur den angegebenen Spieler.
 Die Funktion muss true zurückgeben, wenn gekauft werden darf.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
 übergeben werden.






### Beispiel:
<ul>


<pre class="example">API.PurchaseSetConditionForPlayer(<span class="number">2</span>, MyCalculationFunction);</pre>


</ul>


### API.PurchaseSetDefaultBasePrice (_Function)
source/qsb_1_trade.lua.html#153

Setzt die Funktion zur Bestimmung des Basispreis.
 Die Funktion muss den Basispreis der Ware zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">API.PurchaseSetDefaultBasePrice(MyCalculationFunction);</pre>


</ul>


### API.PurchaseSetDefaultCondition (_Function)
source/qsb_1_trade.lua.html#283

Setzt eine Funktion zur Festlegung spezieller Verkaufsbedingungen.
 Die Funktion muss true zurückgeben, wenn verkauft werden darf.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">API.PurchaseSetDefaultCondition(MyCalculationFunction);</pre>


</ul>


### API.PurchaseSetDefaultInflation (_Function)
source/qsb_1_trade.lua.html#219

Setzt die Funktion zur Berechnung der Preisinflation.
 Die Funktion muss den von der Inflation beeinflussten Preis zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_Amount</td><td>number</td><td>Anzahl bereits gekaufter Angebote</td></tr>
 <tr><td>_Price</td><td>number</td><td></td>Einkaufspreis</tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">API.PurchaseSetDefaultInflation(MyCalculationFunction);</pre>


</ul>


### API.PurchaseSetDefaultTraderAbility (_Function)
source/qsb_1_trade.lua.html#91

Setzt die allgemeine Funktion zur Kalkulation des Einkaufspreisfaktors des
 Helden.  Die Funktion muss den angepassten Preis zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_BasePrice</td><td>number</td><td></td>Basispreis</tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">API.PurchaseSetDefaultTraderAbility(MyCalculationFunction);</pre>


</ul>


### API.PurchaseSetInflationForPlayer (_PlayerID, _Function)
source/qsb_1_trade.lua.html#185

Setzt die Funktion zur Berechnung der Preisinflation.  Die Änderung betrifft
 nur den angegebenen Spieler.
 Die Funktion muss den von der Inflation beeinflussten Preis zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_Amount</td><td>number</td><td>Anzahl bereits gekaufter Angebote</td></tr>
 <tr><td>_Price</td><td>number</td><td></td>Einkaufspreis</tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
 übergeben werden.






### Beispiel:
<ul>


<pre class="example">API.PurchaseSetInflationForPlayer(<span class="number">2</span>, MyCalculationFunction);</pre>


</ul>


### API.PurchaseSetTraderAbilityForPlayer (_PlayerID, _Function)
source/qsb_1_trade.lua.html#58

Setzt die Funktion zur Kalkulation des Einkaufspreisfaktors des Helden.  Die
 Änderung betrifft nur den angegebenen Spieler.
 Die Funktion muss den angepassten Preis zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_BasePrice</td><td>number</td><td></td>Basispreis</tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
 übergeben werden.






### Beispiel:
<ul>


<pre class="example">API.PurchaseSetTraderAbilityForPlayer(<span class="number">2</span>, MyCalculationFunction);</pre>


</ul>


### API.RemoveTradeOffer (_PlayerID, _GoodOrEntityType)
source/qsb_1_trade.lua.html#829

Entfernt das Angebot vom Lagerhaus des Spielers, wenn es vorhanden
 ist.  Es wird immer nur das erste Angebot des Typs entfernt.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Keinen Käse mehr verkaufen
</span>API.RemoveTradeOffer(<span class="number">7</span>, Goods.G_Cheese);</pre>


</ul>


### API.SaleSetBasePriceForPlayer (_PlayerID, _Function)
source/qsb_1_trade.lua.html#377

Setzt die Funktion zur Bestimmung des Basispreis.  Die Änderung betrifft nur
 den angegebenen Spieler.
 Die Funktion muss den Basispreis der Ware zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
 übergeben werden.






### Beispiel:
<ul>


<pre class="example">API.SaleSetBasePriceForPlayer(<span class="number">2</span>, MyCalculationFunction);</pre>


</ul>


### API.SaleSetConditionForPlayer (_PlayerID, _Function)
source/qsb_1_trade.lua.html#506

Setzt eine Funktion zur Festlegung spezieller Verkaufsbedingungen.  Diese
 Bedingungen betreffen nur den angegebenen Spieler.
 Die Funktion muss true zurückgeben, wenn verkauft werden darf.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
 übergeben werden.






### Beispiel:
<ul>


<pre class="example">API.SaleSetConditionForPlayer(<span class="number">2</span>, MyCalculationFunction);</pre>


</ul>


### API.SaleSetDefaultBasePrice (_Function)
source/qsb_1_trade.lua.html#409

Setzt die Funktion zur Bestimmung des Basispreis.
 Die Funktion muss den Basispreis der Ware zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">API.SaleSetDefaultBasePrice(MyCalculationFunction);</pre>


</ul>


### API.SaleSetDefaultCondition (_Function)
source/qsb_1_trade.lua.html#539

Setzt eine Funktion zur Festlegung spezieller Verkaufsbedingungen.
 Die Funktion muss true zurückgeben, wenn verkauft werden darf.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_Amount</td><td>number</td><td>Verkaufte Menge</td></tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">API.SaleSetDefaultCondition(MyCalculationFunction);</pre>


</ul>


### API.SaleSetDefaultDeflation (_Function)
source/qsb_1_trade.lua.html#475

Setzt die Funktion zur Berechnung des minimalen Verkaufserlös.
 Die Funktion muss den von der Deflation beeinflussten Erlös zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_SaleCount</td><td>number</td><td>Amount of sold waggons</td></tr>
 <tr><td>_Price</td><td>number</td><td>Verkaufspreis</td></tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">API.SaleSetDefaultDeflation(MyCalculationFunction);</pre>


</ul>


### API.SaleSetDefaultTraderAbility (_Function)
source/qsb_1_trade.lua.html#347

Setzt die allgemeine Funktion zur Kalkulation des Verkreisfaktors des Helden.
 Die Funktion muss den angepassten Preis zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td></td>Typ des Händlers</tr>
 <tr><td>_Good</td><td>number</td><td></td>Typ des Angebot</tr>
 <tr><td>_BasePrice</td><td>number</td><td></td>Basispreis</tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">API.SaleSetDefaultTraderAbility(MyCalculationFunction);</pre>


</ul>


### API.SaleSetDeflationForPlayer (_PlayerID, _Function)
source/qsb_1_trade.lua.html#441

Setzt die Funktion zur Berechnung des minimalen Verkaufserlös.  Die Änderung
 betrifft nur den angegebenen Spieler.
 Die Funktion muss den von der Deflation beeinflussten Erlös zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td>Typ des Händler</td></tr>
 <tr><td>_Good</td><td>number</td><td>Typ des Angebot</td></tr>
 <tr><td>_SaleCount</td><td>number</td><td>Amount of sold waggons</td></tr>
 <tr><td>_Price</td><td>number</td><td>Verkaufspreis</td></tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Verkäufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Käufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
 übergeben werden.






### Beispiel:
<ul>


<pre class="example">API.SaleSetDeflationForPlayer(<span class="number">2</span>, MyCalculationFunction);</pre>


</ul>


### API.SaleSetTraderAbilityForPlayer (_PlayerID, _Function)
source/qsb_1_trade.lua.html#314

Setzt die Funktion zur Kalkulation des Verkreisfaktors des Helden.  Die
 Änderung betrifft nur den angegebenen Spieler.
 Die Funktion muss den angepassten Preis zurückgeben.

 Parameter der Funktion:
 <table border="1">
 <tr><th><b>Parameter</b></th><th><b>Typ</b></th><th><b>Beschreibung</b></th></tr>
 <tr><td>_Type</td><td>number</td><td></td>Typ des Händlers</tr>
 <tr><td>_Good</td><td>number</td><td></td>Typ des Angebot</tr>
 <tr><td>_BasePrice</td><td>number</td><td></td>Basispreis</tr>
 <tr><td>_PlayerID1</td><td>number</td><td>ID des Käufers</td></tr>
 <tr><td>_PlayerID2</td><td>number</td><td>ID des Verkäufers</td></tr>
 </table>

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 <b>Hinweis</b>: Um den Standard wiederherzustellen, muss nil als Funktion
 übergeben werden.






### Beispiel:
<ul>


<pre class="example">API.SaleSetTraderAbilityForPlayer(<span class="number">2</span>, MyCalculationFunction);</pre>


</ul>


