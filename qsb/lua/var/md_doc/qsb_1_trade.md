### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### QSB.TraderTypes

Typen der Händler

### API.ModifyTradeOffer (_PlayerID, _GoodOrEntityType, _NewAmount)

Ändert die aktuelle Menge des Angebots im Händelrgebäude.

 Es kann ein beliebiger positiver Wert gesetzt werden. Es gibt keine
 Beschränkungen.

 <b>Hinweis</b>: Wird eine höherer Wert gesetzt, als das ursprüngliche
 Maximum, regenerieren sich die Angebote nicht, bis die zusätzlichen
 Angebote verkauft wurden.


### API.PurchaseSetBasePriceForPlayer (_PlayerID, _Function)

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


### API.PurchaseSetConditionForPlayer (_PlayerID, _Function)

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


### API.PurchaseSetDefaultBasePrice (_Function)

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


### API.PurchaseSetDefaultCondition (_Function)

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


### API.PurchaseSetDefaultInflation (_Function)

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


### API.PurchaseSetDefaultTraderAbility (_Function)

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


### API.PurchaseSetInflationForPlayer (_PlayerID, _Function)

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


### API.PurchaseSetTraderAbilityForPlayer (_PlayerID, _Function)

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


### API.RemoveTradeOffer (_PlayerID, _GoodOrEntityType)

Entfernt das Angebot vom Lagerhaus des Spielers, wenn es vorhanden
 ist.  Es wird immer nur das erste Angebot des Typs entfernt.


### API.SaleSetBasePriceForPlayer (_PlayerID, _Function)

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


### API.SaleSetConditionForPlayer (_PlayerID, _Function)

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


### API.SaleSetDefaultBasePrice (_Function)

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


### API.SaleSetDefaultCondition (_Function)

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


### API.SaleSetDefaultDeflation (_Function)

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


### API.SaleSetDefaultTraderAbility (_Function)

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


### API.SaleSetDeflationForPlayer (_PlayerID, _Function)

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


### API.SaleSetTraderAbilityForPlayer (_PlayerID, _Function)

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


