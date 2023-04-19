# Module <code>qsb_4_iotreasure</code>
Es können Schatztruhen und Ruinen mit Inhalten bestückt werden.
 Der Schatz einer Kiste oder Ruine wird nach Aktivierung in einem Karren
 abtransportiert.</p>

<p> Die erzeugten Truhen und Ruinen verhalten sich wie Interaktive Objekte.
 Werden ihnen Aktionen und Bedingungen mitgegeben, gelten für diese Funktionen
 die gleichen Regeln wie bei Interaktiven Objekten.</p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
 <li><a href="modules.QSB_2_Objects.QSB_2_Objects.html">(2) Interaktive Objekte</a></li>
 </ul>

### API.CreateRandomChest (_Name, _Good, _Min, _Max, _Condition, _Action)
source/qsb_4_iotreasure.lua.html#53

Erstellt eine Schatztruhe mit einer zufälligen Menge an Waren
 des angegebenen Typs.

 Die Menge der Ware ist dabei zufällig und liegt zwischen dem Minimalwert
 und dem Maximalwert.






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Bepspiel #1: Normale Truhe
</span>API.CreateRandomChest(<span class="string">"well1"</span>, Goods.G_Gems, <span class="number">100</span>, <span class="number">300</span>);</pre></li>


<li><pre class="example"><span class="comment">-- Bepspiel #2: Truhe mit Aktion
</span><span class="comment">-- Wird die Bedingung weggelassen, tritt die Aktion an ihre Stelle
</span>API.CreateRandomChest(<span class="string">"well1"</span>, Goods.G_Gems, <span class="number">100</span>, <span class="number">300</span>, MyActionFunction);</pre></li>


<li><pre class="example"><span class="comment">-- Bepspiel #3: Truhe mit Bedingung
</span><span class="comment">-- Wenn eine Bedingung gebraucht wird, muss eine Aktion angegeben werden.
</span>API.CreateRandomChest(<span class="string">"well1"</span>, Goods.G_Gems, <span class="number">100</span>, <span class="number">300</span>, MyConditionFunction, MyActionFunction);</pre></li>


</ul>


### API.CreateRandomGoldChest (_Name)
source/qsb_4_iotreasure.lua.html#165

Erstellt eine Schatztruhe mit einer zufälligen Menge Gold.





### Beispiel:
<ul>


<pre class="example">API.CreateRandomGoldChest(<span class="string">"chest"</span>)</pre>


</ul>


### API.CreateRandomLuxuryChest (_Name)
source/qsb_4_iotreasure.lua.html#211

Erstellt eine Schatztruhe mit zufälligen Luxusgütern.

 Luxusgüter können seien: Salz, Farben (, Edelsteine, Musikinstrumente
 Weihrauch)






### Beispiel:
<ul>


<pre class="example">API.CreateRandomLuxuryChest(<span class="string">"chest"</span>)</pre>


</ul>


### API.CreateRandomResourceChest (_Name)
source/qsb_4_iotreasure.lua.html#188

Erstellt eine Schatztruhe mit zufälligen Gütern.

 Güter können seien: Eisen, Fisch, Fleisch, Getreide, Holz,
 Honig, Kräuter, Milch, Stein, Wolle.






### Beispiel:
<ul>


<pre class="example">API.CreateRandomResourceChest(<span class="string">"chest"</span>)</pre>


</ul>


### API.CreateRandomTreasure (_Name, _Good, _Min, _Max, _Condition, _Action)
source/qsb_4_iotreasure.lua.html#119

Erstellt ein beliebiges IO mit einer zufälligen Menge an Waren
 des angegebenen Typs.

 Die Menge der Ware ist dabei zufällig und liegt zwischen dem Minimalwert
 und dem Maximalwert.






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Bepspiel #1: Normale Ruine
</span>API.CreateRandomTreasure(<span class="string">"well1"</span>, Goods.G_Gems, <span class="number">100</span>, <span class="number">300</span>);</pre></li>


<li><pre class="example"><span class="comment">-- Bepspiel #2: Ruine mit Aktion
</span><span class="comment">-- Wird die Bedingung weggelassen, tritt die Aktion an ihre Stelle
</span>API.CreateRandomTreasure(<span class="string">"well1"</span>, Goods.G_Gems, <span class="number">100</span>, <span class="number">300</span>, MyActionFunction);</pre></li>


<li><pre class="example"><span class="comment">-- Bepspiel #3: Ruine mit Bedingung
</span><span class="comment">-- Wenn eine Bedingung gebraucht wird, muss eine Action angegeben werden.
</span>API.CreateRandomTreasure(<span class="string">"well1"</span>, Goods.G_Gems, <span class="number">100</span>, <span class="number">300</span>, MyConditionFunction, MyActionFunction);</pre></li>


</ul>


