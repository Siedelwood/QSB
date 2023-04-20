# Module <code>qsb_2_buildingui</code>
Ermöglicht es zusätzliche Buttons im Gebäudemenü platzieren.
 <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(0) Anzeigesteuerung</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_2_buildingui.lua.html#25

Events, auf die reagiert werden kann.





### API.AddBuildingButton (_Action, _Tooltip, _Update)
source/qsb_2_buildingui.lua.html#115

Fügt einen allgemeinen Gebäudeschalter hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion.






### Beispiel:
<ul>


<pre class="example">SpecialButtonID = API.AddBuildingButton(
    <span class="comment">-- Aktion
</span>    <span class="keyword">function</span>(_WidgetID, _BuildingID)
        GUI.AddNote(<span class="string">"Hier passiert etwas!"</span>);
    <span class="keyword">end</span>,
    <span class="comment">-- Tooltip
</span>    <span class="keyword">function</span>(_WidgetID, _BuildingID)
        <span class="comment">-- Es MUSS ein Kostentooltip verwendet werden.
</span>        API.SetTooltipCosts(<span class="string">"Beschreibung"</span>, <span class="string">"Das ist die Beschreibung!"</span>);
    <span class="keyword">end</span>,
    <span class="comment">-- Update
</span>    <span class="keyword">function</span>(_WidgetID, _BuildingID)
        <span class="comment">-- Ausblenden, wenn noch in Bau
</span>        <span class="keyword">if</span> Logic.IsConstructionComplete(_BuildingID) == <span class="number">0</span> <span class="keyword">then</span>
            XGUIEng.ShowWidget(_WidgetID, <span class="number">0</span>);
            <span class="keyword">return</span>;
        <span class="keyword">end</span>
        <span class="comment">-- Deaktivieren, wenn ausgebaut wird.
</span>        <span class="keyword">if</span> Logic.IsBuildingBeingUpgraded(_BuildingID) <span class="keyword">then</span>
            XGUIEng.DisableButton(_WidgetID, <span class="number">1</span>);
        <span class="keyword">end</span>
        SetIcon(_WidgetID, {<span class="number">1</span>, <span class="number">1</span>});
    <span class="keyword">end</span>
);</pre>


</ul>


### API.AddBuildingButtonAtPosition (_X, _Y, _Action, _Tooltip, _Update)
source/qsb_2_buildingui.lua.html#72

Fügt einen allgemeinen Gebäudeschalter an der Position hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion.

 Die Position wird lokal zur linken oberen Ecke des Fensters angegeben.






### Beispiel:
<ul>


<pre class="example">SpecialButtonID = API.AddBuildingButton(
    <span class="comment">-- Position (X, Y)
</span>    <span class="number">230</span>, <span class="number">180</span>,
    <span class="comment">-- Aktion
</span>    <span class="keyword">function</span>(_WidgetID, _BuildingID)
        GUI.AddNote(<span class="string">"Hier passiert etwas!"</span>);
    <span class="keyword">end</span>,
    <span class="comment">-- Tooltip
</span>    <span class="keyword">function</span>(_WidgetID, _BuildingID)
        <span class="comment">-- Es MUSS ein Kostentooltip verwendet werden.
</span>        API.SetTooltipCosts(<span class="string">"Beschreibung"</span>, <span class="string">"Das ist die Beschreibung!"</span>);
    <span class="keyword">end</span>,
    <span class="comment">-- Update
</span>    <span class="keyword">function</span>(_WidgetID, _BuildingID)
        <span class="comment">-- Ausblenden, wenn noch in Bau
</span>        <span class="keyword">if</span> Logic.IsConstructionComplete(_BuildingID) == <span class="number">0</span> <span class="keyword">then</span>
            XGUIEng.ShowWidget(_WidgetID, <span class="number">0</span>);
            <span class="keyword">return</span>;
        <span class="keyword">end</span>
        <span class="comment">-- Deaktivieren, wenn ausgebaut wird.
</span>        <span class="keyword">if</span> Logic.IsBuildingBeingUpgraded(_BuildingID) <span class="keyword">then</span>
            XGUIEng.DisableButton(_WidgetID, <span class="number">1</span>);
        <span class="keyword">end</span>
        SetIcon(_WidgetID, {<span class="number">1</span>, <span class="number">1</span>});
    <span class="keyword">end</span>
);</pre>


</ul>


### API.AddBuildingButtonByEntity (_ScriptName, _Action, _Tooltip, _Update)
source/qsb_2_buildingui.lua.html#199

Fügt einen Gebäudeschalter für das Entity hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion. Wenn ein Entity einen Button zugewiesen bekommt, werden
 alle allgemeinen Buttons und alle Buttons für Typen für das Entity ignoriert.





### Verwandte Themen:
<ul>


<a href="qsb_2_buildingui.html#API.AddBuildingButton">API.AddBuildingButton</a>


</ul>



### API.AddBuildingButtonByEntityAtPosition (_ScriptName, _X, _Y, _Action, _Tooltip, _Update)
source/qsb_2_buildingui.lua.html#179

Fügt einen Gebäudeschalter für das Entity hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion. Wenn ein Entity einen Button zugewiesen bekommt, werden
 alle allgemeinen Buttons und alle Buttons für Typen für das Entity ignoriert.





### Verwandte Themen:
<ul>


<a href="qsb_2_buildingui.html#API.AddBuildingButton">API.AddBuildingButton</a>


</ul>



### API.AddBuildingButtonByType (_Type, _Action, _Tooltip, _Update)
source/qsb_2_buildingui.lua.html#157

Fügt einen Gebäudeschalter für den Entity-Typ hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion. Wenn ein Typ einen Button zugewiesen bekommt, werden alle
 allgemeinen Buttons für den Typ ignoriert.





### Verwandte Themen:
<ul>


<a href="qsb_2_buildingui.html#API.AddBuildingButton">API.AddBuildingButton</a>


</ul>



### API.AddBuildingButtonByTypeAtPosition (_Type, _X, _Y, _Action, _Tooltip, _Update)
source/qsb_2_buildingui.lua.html#137

Fügt einen Gebäudeschalter für den Entity-Typ hinzu.

 Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
 hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
 Update-Funktion. Wenn ein Typ einen Button zugewiesen bekommt, werden alle
 allgemeinen Buttons für den Typ ignoriert.





### Verwandte Themen:
<ul>


<a href="qsb_2_buildingui.html#API.AddBuildingButton">API.AddBuildingButton</a>


</ul>



### API.DropBuildingButton (_ID)
source/qsb_2_buildingui.lua.html#211

Entfernt einen allgemeinen Gebäudeschalter.





### Beispiel:
<ul>


<pre class="example">API.DropBuildingButton(SpecialButtonID);</pre>


</ul>


### API.DropBuildingButtonFromEntity (_ScriptName, _ID)
source/qsb_2_buildingui.lua.html#237

Entfernt einen Gebäudeschalter vom benannten Gebäude.





### Beispiel:
<ul>


<pre class="example">API.DropBuildingButtonFromEntity(<span class="string">"Bakery"</span>, SpecialButtonID);</pre>


</ul>


### API.DropBuildingButtonFromType (_Type, _ID)
source/qsb_2_buildingui.lua.html#224

Entfernt einen Gebäudeschalter vom Gebäudetypen.





### Beispiel:
<ul>


<pre class="example">API.DropBuildingButtonFromType(Entities.B_Bakery, SpecialButtonID);</pre>


</ul>


