# Module <code>qsb_2_buildrestriction</code>
Ermöglicht Abriss und Bau für den Spieler einzuschränken.
 <p><b>Hinweis</b>: Jegliche Enschränkungen funktionieren nur für menschlische
 Spieler. Die KI wird sie alle ignorieren!</p></p>

<p> <p>Eine Baubeschränkung oder ein Abrissschutz geben eine ID zurück, über die
 seibiger dann gelöscht werden kann.</p></p>

<p> Es gibt zudem eine Hierarchie, nach der die einzelnen Checks durchgeführt
 werden. Dabei wird nach Art des betroffenen Bereiches und nach Art des
 betroffenen Subjektes unterschieden.</p>

<p> Nach Art des Bereiches:
 <ol>
 <li>Custom-Funktionen</li>
 <li>Durch Umkreise definierte Bereiche</li>
 <li>Durch Territorien definierte Bereiche</li>
 </ol></p>

<p> Nach Art des Gebäudes:
 <ol>
 <li>Custom-Funktionen</li>
 <li>Skriptnamen</li>
 <li>Entity Types</li>
 <li>Entity Categories</li>
 </ol></p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
 </ul>

### API.DeleteRestriction (_ID)
source/qsb_2_buildrestriction.lua.html#341

Löscht eine Baueinschränkung mit der angegebenen ID.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">API.DeleteRestriction(MyRestrictionID);</pre>


</ul>


### API.RestrictBuildingCategoryInArea (_PlayerID, _Category, _Position, _Area)
source/qsb_2_buildrestriction.lua.html#177

Verhindert den Bau von Gebäuden der Kategorie innerhalb des Gebietes.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyRestrictionID = API.RestrictBuildingCategoryInArea(<span class="number">1</span>, EntityCategories.OuterRimBuilding, <span class="string">"NoOuterRim"</span>, <span class="number">3000</span>);</pre>


</ul>


### API.RestrictBuildingCategoryInTerritory (_PlayerID, _Category, _Territory)
source/qsb_2_buildrestriction.lua.html#148

Verhindert den Bau von Gebäuden der Kategorie in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyRestrictionID = API.RestrictBuildingCategoryInTerritory(<span class="number">1</span>, EntityCategories.CityBuilding, <span class="number">1</span>);</pre>


</ul>


### API.RestrictBuildingCustomFunction (_PlayerID, _Function, _Message)
source/qsb_2_buildrestriction.lua.html#68

Verhindert den Bau Gebäuden anhand der übergebenen Funktion.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 Die angegebene Funktion muss eine Funktion im lokalen Skript sein. Es ist
 möglich Funktionen innerhalb Tables anzugeben. Die self-Referenz wird
 allerdings nicht unterstützt.

 Eine Funktion muss true zurückgeben, wenn der Bau geblockt werden soll.
 Die gleiche Funktion kann für alle Spieler benutzt werden, wenn als PlayerID
 -1 angegeben wird. Für welchen Spieler sie ausgeführt wird, wird stets als
 Parameter übergeben.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> MyCustomRestriction = <span class="keyword">function</span>(_PlayerID, _Type, _X, _Y)
   <span class="keyword">if</span> AnythingIWant <span class="keyword">then</span>
       <span class="keyword">return</span> <span class="keyword">true</span>;
   <span class="keyword">end</span>
<span class="keyword">end</span>
MyRestrictionID = API.RestrictBuildingCustomFunction(<span class="number">1</span>, MyCustomRestriction);</pre>


</ul>


### API.RestrictBuildingTypeInArea (_PlayerID, _Type, _Position, _Area)
source/qsb_2_buildrestriction.lua.html#122

Verhindert den Bau von Gebäuden des Typs innerhalb des Gebietes.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyRestrictionID = API.RestrictBuildingTypeInArea(<span class="number">1</span>, Entities.B_Bakery, <span class="string">"GiveMeMeatInstead"</span>, <span class="number">3000</span>);</pre>


</ul>


### API.RestrictBuildingTypeInTerritory (_PlayerID, _Type, _Territory)
source/qsb_2_buildrestriction.lua.html#93

Verhindert den Bau von Gebäuden des Typs in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyRestrictionID = API.RestrictBuildingTypeInTerritory(<span class="number">1</span>, Entities.B_Bakery, <span class="number">1</span>);</pre>


</ul>


### API.RestrictRoadCustomFunction (_PlayerID, _Function, _Message)
source/qsb_2_buildrestriction.lua.html#217

Verhindert den Bau von Pfaden oder Straßen anhand der übergebenen Funktion.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 Die angegebene Funktion muss eine Funktion im lokalen Skript sein. Es ist
 möglich Funktionen innerhalb Tables anzugeben. Die self-Referenz wird
 allerdings nicht unterstützt.

 Eine Funktion muss true zurückgeben, wenn der Bau geblockt werden soll.
 Die gleiche Funktion kann für alle Spieler benutzt werden, wenn als PlayerID
 -1 angegeben wird. Für welchen Spieler sie ausgeführt wird, wird stets als
 Parameter übergeben.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> MyCustomRestriction = <span class="keyword">function</span>(_PlayerID, _IsTrail, _X, _Y)
   <span class="keyword">if</span> AnythingIWant <span class="keyword">then</span>
       <span class="keyword">return</span> <span class="keyword">true</span>;
   <span class="keyword">end</span>
<span class="keyword">end</span>
MyRestrictionID = API.RestrictRoadCustomFunction(<span class="number">1</span>, MyCustomRestriction);</pre>


</ul>


### API.RestrictStreetInArea (_PlayerID, _Position, _Area)
source/qsb_2_buildrestriction.lua.html#319

Verhindert den Bau von Straßen innerhalb des Gebiets.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyRestrictionID = API.RestrictStreetInArea(<span class="number">1</span>, <span class="string">"NoMansLand"</span>, <span class="number">3000</span>);</pre>


</ul>


### API.RestrictStreetInTerritory (_PlayerID, _Territory)
source/qsb_2_buildrestriction.lua.html#292

Verhindert den Bau von Straßen in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyRestrictionID = API.RestrictStreetInTerritory(<span class="number">1</span>, <span class="number">1</span>);</pre>


</ul>


### API.RestrictTrailInArea (_PlayerID, _Position, _Area)
source/qsb_2_buildrestriction.lua.html#268

Verhindert den Bau von Pfaden innerhalb des Gebiets.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyRestrictionID = API.RestrictTrailInArea(<span class="number">1</span>, <span class="string">"NoMansLand"</span>, <span class="number">3000</span>);</pre>


</ul>


### API.RestrictTrailInTerritory (_PlayerID, _Territory)
source/qsb_2_buildrestriction.lua.html#241

Verhindert den Bau von Pfaden in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyRestrictionID = API.RestrictTrailInTerritory(<span class="number">1</span>, <span class="number">1</span>);</pre>


</ul>


### API.DeleteProtection (_ID)
source/qsb_2_buildrestriction.lua.html#531

Löscht einen Abrissschutz mit der angegebenen ID.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">API.DeleteProtection(MyProtectionID);</pre>


</ul>


### API.ProtectBuildingCategoryInArea (_PlayerID, _Category, _Position, _Area)
source/qsb_2_buildrestriction.lua.html#485

Verhindert den Abriss aller Gebäude in der Kategorie innerhalb des Gebiets.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyProtectionID = API.ProtectBuildingCategoryInArea(<span class="number">1</span>, EntityCategories.CityBuilding, <span class="string">"AreaCenter"</span>, <span class="number">3000</span>);</pre>


</ul>


### API.ProtectBuildingCategoryInTerritory (_PlayerID, _Category, _Territory)
source/qsb_2_buildrestriction.lua.html#456

Verhindert den Abriss aller Gebäude in der Kategorie in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyProtectionID = API.ProtectBuildingCategoryInTerritory(<span class="number">1</span>, EntityCategories.CityBuilding, <span class="number">1</span>);</pre>


</ul>


### API.ProtectBuildingCustomFunction (_PlayerID, _Function, _Message)
source/qsb_2_buildrestriction.lua.html#376

Verhindert den Abriss von Gebäuden anhand der übergebenen Funktion.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!

 Die angegebene Funktion muss eine Funktion im lokalen Skript sein. Es ist
 möglich Funktionen innerhalb Tables anzugeben. Die self-Referenz wird
 allerdings nicht unterstützt.

 Eine Funktion muss true zurückgeben, wenn der Abriss geblockt werden soll.
 Die gleiche Funktion kann für alle Spieler benutzt werden, wenn als PlayerID
 -1 angegeben wird. Für welchen Spieler sie ausgeführt wird, wird stets als
 Parameter übergeben.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> MyCustomProtection = <span class="keyword">function</span>(_PlayerID, _BuildingID, _X, _Y)
   <span class="keyword">if</span> AnythingIWant <span class="keyword">then</span>
       <span class="keyword">return</span> <span class="keyword">true</span>;
   <span class="keyword">end</span>
<span class="keyword">end</span>
MyProtectionID = API.ProtectBuildingCustomFunction(<span class="number">1</span>, MyCustomProtection);</pre>


</ul>


### API.ProtectBuildingTypeInArea (_PlayerID, _Type, _Position, _Area)
source/qsb_2_buildrestriction.lua.html#430

Verhindert den Abriss aller Gebäude des Typs innerhalb des Gebiets.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyProtectionID = API.ProtectBuildingTypeInArea(<span class="number">1</span>, Entities.B_Bakery, <span class="string">"AreaCenter"</span>, <span class="number">3000</span>);</pre>


</ul>


### API.ProtectBuildingTypeInTerritory (_PlayerID, _Type, _Territory)
source/qsb_2_buildrestriction.lua.html#401

Verhindert den Abriss aller Gebäude des Typs in dem Territorium.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyProtectionID = API.ProtectBuildingTypeInTerritory(<span class="number">1</span>, Entities.B_Bakery, <span class="number">1</span>);</pre>


</ul>


### API.ProtectNamedBuilding (_PlayerID, _ScriptName)
source/qsb_2_buildrestriction.lua.html#510

Verhindert den Abriss eines benannten Gebäudes.

 <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!






### Beispiel:
<ul>


<pre class="example">MyProtectionID = API.ProtectNamedBuilding(<span class="number">1</span>, <span class="string">"Denkmalschutz"</span>);</pre>


</ul>


