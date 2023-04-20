# Module <code>qsb_1_entity</code>
Ermöglicht, Entities suchen und auf bestimmte Ereignisse reagieren.
 <h5>Entity Suche</h5>
 Es kann entweder mit vordefinierten Funktionen oder mit eigenen Filtern
 nach allen Entities gesucht werden.</p>

<p> <h5>Diebstahleffekte</h5>
 Die Effekte von Diebstählen können deaktiviert und mittels Event neu
 geschrieben werden.</p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_1_entity.lua.html#41

Events, auf die reagiert werden kann.





### API.CommenceEntitySearch (_Filter)
source/qsb_1_entity.lua.html#252

Führt eine benutzerdefinierte Suche nach Entities aus.

 <b>Achtung</b>: Die Reihenfolge der Abfragen im Filter hat direkten
 Einfluss auf die Dauer der Suche. Während Abfragen auf den Besitzer oder
 den Typ schnell gehen, dauern Gebietssuchen lange! Es ist daher klug, zuerst
 Kriterien auszuschließen, die schnell bestimmt werden können!






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Es werden alle Kühe und Schafe von Spieler 1 gefunden, die nicht auf den
</span><span class="comment">-- Territorien 7 und 15 sind.
</span><span class="keyword">local</span> Result = API.CommenceEntitySearch(
    <span class="keyword">function</span>(_ID)
        <span class="comment">-- Nur Entities von Spieler 1 akzeptieren
</span>        <span class="keyword">if</span> Logic.EntityGetPlayer(_ID) == <span class="number">1</span> <span class="keyword">then</span>
            <span class="comment">-- Nur Entities akzeptieren, die Kühe oder Schafe sind.
</span>            <span class="keyword">if</span> Logic.IsEntityInCategory(_ID, EntityCategories.CattlePasture) == <span class="number">1</span>
            <span class="keyword">or</span> Logic.IsEntityInCategory(_ID, EntityCategories.SheepPasture) == <span class="number">1</span> <span class="keyword">then</span>
                <span class="comment">-- Nur Entities akzeptieren, die nicht auf den Territorien 7 und 15 sind.
</span>                <span class="keyword">local</span> Territory = GetTerritoryUnderEntity(_ID);
                <span class="keyword">return</span> Territory ~= <span class="number">7</span> <span class="keyword">and</span> Territory ~= <span class="number">15</span>;
            <span class="keyword">end</span>
        <span class="keyword">end</span>
        <span class="keyword">return</span> <span class="keyword">false</span>;
    <span class="keyword">end</span>
);</pre>


</ul>


### API.SearchEntities (_PlayerID, _WithoutDefeatResistant)
source/qsb_1_entity.lua.html#61

Findet <u>alle</u> Entities.




### Verwandte Themen:
<ul>


<a href="qsb_1_entity.html#API.CommenceEntitySearch">API.CommenceEntitySearch</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- ALLE Entities
</span><span class="keyword">local</span> Result = API.SearchEntities();
<span class="comment">-- Alle Entities von Spieler 5.
</span><span class="keyword">local</span> Result = API.SearchEntities(<span class="number">5</span>);</pre>


</ul>


### API.SearchEntitiesByScriptname (_Pattern)
source/qsb_1_entity.lua.html#210

Findet alle Entities deren Skriptname das Suchwort enthält.




### Verwandte Themen:
<ul>


<a href="qsb_1_entity.html#API.CommenceEntitySearch">API.CommenceEntitySearch</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Findet alle Entities, deren Name mit "TreasureChest" beginnt.
</span><span class="keyword">local</span> Result = API.SearchEntitiesByScriptname(<span class="string">"^TreasureChest"</span>);</pre>


</ul>


### API.SearchEntitiesOfCategoryInArea (_Area, _Position, _Category, _PlayerID)
source/qsb_1_entity.lua.html#116

Findet alle Entities der Kategorie in einem Gebiet.




### Verwandte Themen:
<ul>


<a href="qsb_1_entity.html#API.CommenceEntitySearch">API.CommenceEntitySearch</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Result = API.SearchEntitiesInArea(<span class="number">5000</span>, <span class="string">"City"</span>, EntityCategories.CityBuilding, <span class="number">2</span>);</pre>


</ul>


### API.SearchEntitiesOfCategoryInTerritory (_Territory, _Category, _PlayerID)
source/qsb_1_entity.lua.html#174

Findet alle Entities der Kategorie in einem Territorium.




### Verwandte Themen:
<ul>


<a href="qsb_1_entity.html#API.CommenceEntitySearch">API.CommenceEntitySearch</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Result = API.SearchEntitiesInTerritory(<span class="number">7</span>, EntityCategories.CityBuilding, <span class="number">6</span>);</pre>


</ul>


### API.SearchEntitiesOfTypeInArea (_Area, _Position, _Type, _PlayerID)
source/qsb_1_entity.lua.html#98

Findet alle Entities des Typs in einem Gebiet.




### Verwandte Themen:
<ul>


<a href="qsb_1_entity.html#API.CommenceEntitySearch">API.CommenceEntitySearch</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Result = API.SearchEntitiesInArea(<span class="number">5000</span>, <span class="string">"Busches"</span>, Entities.R_HerbBush);</pre>


</ul>


### API.SearchEntitiesOfTypeInTerritory (_Territory, _Type, _PlayerID)
source/qsb_1_entity.lua.html#157

Findet alle Entities des Typs in einem Territorium.




### Verwandte Themen:
<ul>


<a href="qsb_1_entity.html#API.CommenceEntitySearch">API.CommenceEntitySearch</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Result = API.SearchEntitiesInTerritory(<span class="number">7</span>, Entities.R_HerbBush);</pre>


</ul>


### API.ThiefDisableCathedralEffect (_Flag)
source/qsb_1_entity.lua.html#314

Deaktiviert die Standardaktion wenn ein Dieb in eine Kirche eindringt.

 <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
 stattdessen Informationen.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Deaktivieren
</span>API.ThiefDisableCathedralEffect(<span class="keyword">true</span>);
<span class="comment">-- Aktivieren
</span>API.ThiefDisableCathedralEffect(<span class="keyword">false</span>);</pre>


</ul>


### API.ThiefDisableCisternEffect (_Flag)
source/qsb_1_entity.lua.html#332

Deaktiviert die Standardaktion wenn ein Dieb einen Brunnen sabotiert.

 <b>Hinweis</b>: Brunnen können nur im Addon gebaut und sabotiert werden.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Deaktivieren
</span>API.ThiefDisableCisternEffect(<span class="keyword">true</span>);
<span class="comment">-- Aktivieren
</span>API.ThiefDisableCisternEffect(<span class="keyword">false</span>);</pre>


</ul>


### API.ThiefDisableStorehouseEffect (_Flag)
source/qsb_1_entity.lua.html#295

Deaktiviert die Standardaktion wenn ein Dieb in ein Lagerhaus eindringt.

 <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
 stattdessen Informationen.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Deaktivieren
</span>API.ThiefDisableStorehouseEffect(<span class="keyword">true</span>);
<span class="comment">-- Aktivieren
</span>API.ThiefDisableStorehouseEffect(<span class="keyword">false</span>);</pre>


</ul>


