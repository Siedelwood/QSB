# Module <code>qsb_x_addon_1_singlebuttons</code>
Dieses Addon erlaubt es Gebäuden einen Button für Single Reserve und Single Knockdown zu geben
 <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.qsb_2_buildingui.qsb_2_buildingui.html">(2) Gebäudeschalter</a></li>
 </ul>

### API.SetDowngradeCosts (_Amount)
source/qsb_x_addon_1_singlebuttons.lua.html#127

Setze die Kosten für den Rückbau von Gebäuden




### Verwandte Themen:
<ul>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Downgrade Kosten auf 50 Gold setzen
</span>API.SetDowngradeCosts(<span class="number">50</span>)
<span class="comment">-- Downgrade Kosten zurücksetzen
</span>API.SetDowngradeCosts(<span class="number">0</span>)</pre>


</ul>


### API.UseDowngrade (_Flag)
source/qsb_x_addon_1_singlebuttons.lua.html#97

Aktiviere oder deaktiviere Rückbau bei Stadt- und Rohstoffgebäuden.  Die
 Rückbaufunktion erlaubt es dem Spieler bei Stadt- und Rohstoffgebäude
 der Stufe 2 und 3 jeweils eine Stufe zu zerstören. Der überflüssige
 Arbeiter wird entlassen.





### Verwandte Themen:
<ul>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Downgrade nutzen
</span>API.UseDowngrade(<span class="keyword">true</span>)
<span class="comment">-- Downgrade deaktivieren
</span>API.UseDowngrade(<span class="keyword">false</span>)</pre>


</ul>


### API.UseSingleReserve (_Flag)
source/qsb_x_addon_1_singlebuttons.lua.html#64

Aktiviert oder deaktiviert die Single Reserve Buttons.  Single Reserve ermöglicht
 das Anhalten des Verbrauchs eines Gebäudetyps.





### Verwandte Themen:
<ul>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Single Reserve nutzen
</span>API.UseSingleReserve(<span class="keyword">true</span>)
<span class="comment">-- Single Reserve deaktivieren
</span>API.UseSingleReserve(<span class="keyword">false</span>)</pre>


</ul>


### API.UseSingleStop (_Flag)
source/qsb_x_addon_1_singlebuttons.lua.html#33

Aktiviert oder deaktiviert die Single Stop Buttons.  Single Stop ermöglicht
 das Anhalten eines einzelnen Betriebes, anstelle des Anhaltens aller
 Betriebe des gleichen Typs.





### Verwandte Themen:
<ul>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Single Stop nutzen
</span>API.UseSingleStop(<span class="keyword">true</span>)
<span class="comment">-- Single Stop deaktivieren
</span>API.UseSingleStop(<span class="keyword">false</span>)</pre>


</ul>


