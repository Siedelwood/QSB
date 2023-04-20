# Module <code>qsb_4_iomines</code>
Stellt Minen bereit, die wie Ruinen aktiviert werden können.
 Der Spieler kann eine Stein- oder Eisenmine restaurieren, die zuerst durch
 Begleichen der Kosten aufgebaut werden muss, bevor sie genutzt werden kann.
 <br>Optional kann die Mine einstürzen, wenn sie ausgebeutet wurde.</p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
 <li><a href="modules.QSB_2_Objects.QSB_2_Objects.html">(2) Interaktive Objekte</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_4_iomines.lua.html#28

Events, auf die reagiert werden kann.





### API.CreateIOIronMine (_Data)
source/qsb_4_iomines.lua.html#125

Erstelle eine verschüttete Eisenmine.

 Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
 20 Holz.

 Die Parameter der interaktiven Mine werden durch ihre Beschreibung
 festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
 Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.

 Mögliche Angaben:
 <table border="1">
 <tr>
 <td><b>Feldname</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 <td><b>Optional</b></td>
 </tr>
 <tr>
 <td>Position</td>
 <td>string</td>
 <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
 <td>nein</td>
 </tr>
 <tr>
 <td>Title</td>
 <td>string</td>
 <td>Angezeigter Titel der Beschreibung für die Mine</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Text</td>
 <td>string</td>
 <td>Angezeigte Text der Beschreibung für die Mine</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Costs</td>
 <td>table</td>
 <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ResourceAmount</td>
 <td>number</td>
 <td>Menge an Rohstoffen nach der Aktivierung</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>RefillAmount</td>
 <td>number</td>
 <td>Menge an Rohstoffen, die ein Geologe auffüllt (0 == nicht nachfüllbar)</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ConstructionCondition</td>
 <td>function</td>
 <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ConstructionAction</td>
 <td>function</td>
 <td>Eine zusätzliche Aktion nach der Aktivierung.</td>
 <td>ja</td>
 </tr>
 </table>





### Verwandte Themen:
<ul>


<a href="qsb_4_iomines.html#API.CreateIOStoneMine">API.CreateIOStoneMine</a>


</ul>



### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Eine einfache Mine
</span>API.CreateIOIronMine{
    Position = <span class="string">"mine"</span>
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Mine mit geänderten Kosten
</span>API.CreateIOIronMine{
    Position = <span class="string">"mine"</span>,
    Costs    = {Goods.G_Wood, <span class="number">15</span>}
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #3: Mine mit Aktivierungsbedingung
</span>API.CreateIOIronMine{
    Position              = <span class="string">"mine"</span>,
    Costs                 = {Goods.G_Wood, <span class="number">15</span>},
    ConstructionCondition = <span class="keyword">function</span>(_Data)
        <span class="keyword">return</span> HeroHasShovel == <span class="keyword">true</span>;
    <span class="keyword">end</span>
};</pre></li>


</ul>


### API.CreateIOStoneMine (_Data)
source/qsb_4_iomines.lua.html#269

Erstelle eine verschüttete Steinmine.

 Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
 20 Holz.

 Die Parameter der interaktiven Mine werden durch ihre Beschreibung
 festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
 Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.

 Mögliche Angaben:
 <table border="1">
 <tr>
 <td><b>Feldname</b></td>
 <td><b>Typ</b></td>
 <td><b>Beschreibung</b></td>
 <td><b>Optional</b></td>
 </tr>
 <tr>
 <td>Position</td>
 <td>string</td>
 <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
 <td>nein</td>
 </tr>
 <tr>
 <td>Title</td>
 <td>string</td>
 <td>Angezeigter Titel der Beschreibung für die Mine</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Text</td>
 <td>string</td>
 <td>Angezeigte Text der Beschreibung für die Mine</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>Costs</td>
 <td>table</td>
 <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
 <td>ja</td>
 </tr>
 <tr>
 <tr>
 <td>ResourceAmount</td>
 <td>number</td>
 <td>Menge an Rohstoffen nach der Aktivierung</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>RefillAmount</td>
 <td>number</td>
 <td>Menge an Rohstoffen, die ein Geologe auffüllt (0 == nicht nachfüllbar)</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ConstructionCondition</td>
 <td>function</td>
 <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
 <td>ja</td>
 </tr>
 <tr>
 <td>ConstructionAction</td>
 <td>function</td>
 <td>Eine zusätzliche Aktion nach der Aktivierung.</td>
 <td>ja</td>
 </tr>
 </table>





### Verwandte Themen:
<ul>


<a href="qsb_4_iomines.html#API.CreateIOIronMine">API.CreateIOIronMine</a>


</ul>



### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Eine einfache Mine
</span>API.CreateIOStoneMine{
    Position = <span class="string">"mine"</span>
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Mine mit geänderten Kosten
</span>API.CreateIOStoneMine{
    Position = <span class="string">"mine"</span>,
    Costs    = {Goods.G_Wood, <span class="number">15</span>}
};</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #3: Mine mit Aktivierungsbedingung
</span>API.CreateIOStoneMine{
    Position              = <span class="string">"mine"</span>,
    Costs                 = {Goods.G_Wood, <span class="number">15</span>},
    ConstructionCondition = <span class="keyword">function</span>(_Data)
        <span class="keyword">return</span> HeroHasPickaxe == <span class="keyword">true</span>;
    <span class="keyword">end</span>
};</pre></li>


</ul>


