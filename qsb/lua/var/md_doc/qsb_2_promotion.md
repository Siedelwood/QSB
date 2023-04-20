# Module <code>qsb_2_promotion</code>
Ermöglicht das Anpassen der Aufstiegsbedingungen.
 Die Aufstiegsbedingungen werden in der Funktion InitKnightTitleTables
 angegeben und bearbeitet.</p>

<p> <b>Achtung</b>: es können maximal 6 Bedingungen angezeigt werden!</p>

<p> <p>Mögliche Aufstiegsbedingungen:
 <ul>
 <li><b>Entitytyp besitzen</b><br/>
 Der Spieler muss eine bestimmte Anzahl von Entities eines Typs besitzen.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].Entities = {</p>

<pre>
{Entities.B_Bakery, <span class="number">2</span>},
...
</pre>

<p> }
 </code></pre>
 </li></p>

<p> <li><b>Entitykategorie besitzen</b><br/>
 Der Spieler muss eine bestimmte Anzahl von Entities einer Kategorie besitzen.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].Category = {</p>

<pre>
{EntitiyCategories.CattlePasture, <span class="number">10</span>},
...
</pre>

<p> }
 </code></pre>
 </li></p>

<p> <li><b>Gütertyp besitzen</b><br/>
 Der Spieler muss Rohstoffe oder Güter eines Typs besitzen.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].Goods = {</p>

<pre>
{Goods.G_RawFish, <span class="number">35</span>},
...
</pre>

<p> }
 </code></pre>
 </li></p>

<p> <li><b>Produkte erzeugen</b><br/>
 Der Spieler muss Gebrauchsgegenstände für ein Bedürfnis bereitstellen. Hier
 werden nicht die Warentypen sonderen deren Kategorie angegeben.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].Products = {</p>

<pre>
{GoodCategories.GC_Clothes, <span class="number">6</span>},
...
</pre>

<p> }
 </code></pre>
 </li></p>

<p> <li><b>Güter konsumieren</b><br/>
 Die Siedler müssen eine Menge einer bestimmten Waren konsumieren.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].Consume = {</p>

<pre>
{Goods.G_Bread, <span class="number">30</span>},
...
</pre>

<p> }
 </code></pre>
 </li></p>

<p> <li><b>Buffs aktivieren</b><br/>
 Der Spieler muss einen Buff aktivieren.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].Buff = {</p>

<pre>
Buffs.Buff_FoodDiversity,
...
</pre>

<p> }
 </code></pre>
 </li></p>

<p> <li><b>Stadtruf erreichen</b><br/>
 Der Ruf der Stadt muss einen bestimmten Wert erreichen oder überschreiten.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].Reputation = 20
 </code></pre></p>

<p> <li><b>Anzahl an Dekorationen</b><br/>
 Der Spieler muss mindestens die Anzahl der angegebenen Dekoration besitzen.
 <code><pre>
 KnightTitleRequirements[KnightTitles.Mayor].DecoratedBuildings = {</p>

<pre>
{Goods.G_Banner, <span class="number">9</span> },
...
</pre>

<p> }
 </code></pre>
 </li></p>

<p> <li><b>Anzahl voll dekorierter Gebäude</b><br/>
 Anzahl an Gebäuden, an die alle vier Dekorationen angebracht sein müssen.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].FullDecoratedBuildings = 12
 </code></pre>
 </li></p>

<p> <li><b>Spezialgebäude ausbauen</b><br/>
 Ein Spezielgebäude muss ausgebaut werden.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].Headquarters = 1
 KnightTitleRequirements[KnightTitles.Mayor].Storehouse = 1
 KnightTitleRequirements[KnightTitles.Mayor].Cathedrals = 1
 </code></pre>
 </li></p>

<p> <li><b>Anzahl Siedler</b><br/>
 Der Spieler benötigt eine Gesamtzahl an Siedlern.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].Settlers = 40
 </code></pre>
 </li></p>

<p> <li><b>Anzahl reiche Stadtgebäude</b><br/>
 Eine Anzahl an Gebäuden muss durch Einnahmen Reichtum erlangen.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].RichBuildings = 30
 </code></pre>
 </li></p>

<p> <li><b>Benutzerdefiniert</b><br/>
 Eine benutzerdefinierte Funktion, die entweder als Schalter oder als Zähler
 fungieren kann und true oder false zurückgeben muss. Soll ein Zähler
 angezeigt werden, muss nach dem Wahrheitswert der aktuelle und der maximale
 Wert des Zählers folgen.
 <pre><code>
 KnightTitleRequirements[KnightTitles.Mayor].Custom = {</p>

<pre>
{SomeFunction, {<span class="number">1</span>, <span class="number">1</span>}, <span class="string">"Überschrift"</span>, <span class="string">"Beschreibung"</span>}
...
</pre>

<p> }</p>

<p> -- Funktion prüft Schalter
 function SomeFunction(_PlayerID, _NextTitle, _Index)</p>

<pre>
<span class="keyword">return</span> gvMission.MySwitch == <span class="keyword">true</span>;
</pre>

<p> end
 -- Funktion prüft Zähler
 function SomeFunction(_PlayerID, _NextTitle, _Index)</p>

<pre>
<span class="keyword">return</span> gvMission.MyCounter == <span class="number">6</span>, gvMission.MyCounter, <span class="number">6</span>;
</pre>

<p> end
 </code></pre>
 </li>
 </ul></p></p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
 </ul>


### QSB.ScriptEvents
source/qsb_2_promotion.lua.html#159

Events, auf die reagiert werden kann.





### API.CanKnightBePromoted (_PlayerID, _KnightTitle)
source/qsb_2_promotion.lua.html#619

Prüft, ob der Spieler befördert werden kann.





### InitKnightTitleTables ()
source/qsb_2_promotion.lua.html#1955

Diese Funktion muss entweder in der QSB modifiziert oder sowohl im globalen
 als auch im lokalen Skript überschrieben werden.  Ideal ist laden des
 angepassten Skriptes als separate Datei. Bei Modifikationen muss das Schema
 für Aufstiegsbedingungen und Rechtevergabe immer beibehalten werden.

 <b>Hinweis</b>: Diese Funktion wird <b>automatisch</b> vom Code ausgeführt.
 Du rufst sie <b>niemals</b> selbst auf!






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Dies ist ein Beispiel zum herauskopieren. Hier sind die üblichen
</span><span class="comment">-- Bedingungen gesetzt. Wenn du diese Funktion in dein Skript kopierst, muss
</span><span class="comment">-- sie im globalen und lokalen Skript stehen oder dort geladen werden!
</span>InitKnightTitleTables = <span class="keyword">function</span>()
    KnightTitles = {}
    KnightTitles.Knight     = <span class="number">0</span>
    KnightTitles.Mayor      = <span class="number">1</span>
    KnightTitles.Baron      = <span class="number">2</span>
    KnightTitles.Earl       = <span class="number">3</span>
    KnightTitles.Marquees   = <span class="number">4</span>
    KnightTitles.Duke       = <span class="number">5</span>
    KnightTitles.Archduke   = <span class="number">6</span>

    <span class="comment">-- ---------------------------------------------------------------------- --
</span>    <span class="comment">-- Rechte und Pflichten                                                   --
</span>    <span class="comment">-- ---------------------------------------------------------------------- --
</span>
    NeedsAndRightsByKnightTitle = {}

    <span class="comment">-- Ritter ------------------------------------------------------------------
</span>
    NeedsAndRightsByKnightTitle[KnightTitles.Knight] = {
        ActivateNeedForPlayer,
        {
            Needs.Nutrition,                                    <span class="comment">-- Bedürfnis: Nahrung
</span>            Needs.Medicine,                                     <span class="comment">-- Bedürfnis: Medizin
</span>        },
        ActivateRightForPlayer,
        {
            Technologies.R_Gathering,                           <span class="comment">-- Recht: Rohstoffsammler
</span>            Technologies.R_Woodcutter,                          <span class="comment">-- Recht: Holzfäller
</span>            Technologies.R_StoneQuarry,                         <span class="comment">-- Recht: Steinbruch
</span>            Technologies.R_HuntersHut,                          <span class="comment">-- Recht: Jägerhütte
</span>            Technologies.R_FishingHut,                          <span class="comment">-- Recht: Fischerhütte
</span>            Technologies.R_CattleFarm,                          <span class="comment">-- Recht: Kuhfarm
</span>            Technologies.R_GrainFarm,                           <span class="comment">-- Recht: Getreidefarm
</span>            Technologies.R_SheepFarm,                           <span class="comment">-- Recht: Schaffarm
</span>            Technologies.R_IronMine,                            <span class="comment">-- Recht: Eisenmine
</span>            Technologies.R_Beekeeper,                           <span class="comment">-- Recht: Imkerei
</span>            Technologies.R_HerbGatherer,                        <span class="comment">-- Recht: Kräutersammler
</span>            Technologies.R_Nutrition,                           <span class="comment">-- Recht: Nahrung
</span>            Technologies.R_Bakery,                              <span class="comment">-- Recht: Bäckerei
</span>            Technologies.R_Dairy,                               <span class="comment">-- Recht: Käserei
</span>            Technologies.R_Butcher,                             <span class="comment">-- Recht: Metzger
</span>            Technologies.R_SmokeHouse,                          <span class="comment">-- Recht: Räucherhaus
</span>            Technologies.R_Clothes,                             <span class="comment">-- Recht: Kleidung
</span>            Technologies.R_Tanner,                              <span class="comment">-- Recht: Ledergerber
</span>            Technologies.R_Weaver,                              <span class="comment">-- Recht: Weber
</span>            Technologies.R_Construction,                        <span class="comment">-- Recht: Konstruktion
</span>            Technologies.R_Wall,                                <span class="comment">-- Recht: Mauer
</span>            Technologies.R_Pallisade,                           <span class="comment">-- Recht: Palisade
</span>            Technologies.R_Trail,                               <span class="comment">-- Recht: Pfad
</span>            Technologies.R_KnockDown,                           <span class="comment">-- Recht: Abriss
</span>            Technologies.R_Sermon,                              <span class="comment">-- Recht: Predigt
</span>            Technologies.R_SpecialEdition,                      <span class="comment">-- Recht: Special Edition
</span>            Technologies.R_SpecialEdition_Pavilion,             <span class="comment">-- Recht: Pavilion AeK SE
</span>        }
    }

    <span class="comment">-- Landvogt ----------------------------------------------------------------
</span>
    NeedsAndRightsByKnightTitle[KnightTitles.Mayor] = {
        ActivateNeedForPlayer,
        {
            Needs.Clothes,                                      <span class="comment">-- Bedürfnis: KLeidung
</span>        },
        ActivateRightForPlayer, {
            Technologies.R_Hygiene,                             <span class="comment">-- Recht: Hygiene
</span>            Technologies.R_Soapmaker,                           <span class="comment">-- Recht: Seifenmacher
</span>            Technologies.R_BroomMaker,                          <span class="comment">-- Recht: Besenmacher
</span>            Technologies.R_Military,                            <span class="comment">-- Recht: Militär
</span>            Technologies.R_SwordSmith,                          <span class="comment">-- Recht: Schwertschmied
</span>            Technologies.R_Barracks,                            <span class="comment">-- Recht: Schwertkämpferkaserne
</span>            Technologies.R_Thieves,                             <span class="comment">-- Recht: Diebe
</span>            Technologies.R_SpecialEdition_StatueFamily,         <span class="comment">-- Recht: Familienstatue Aek SE
</span>        },
        StartKnightsPromotionCelebration                        <span class="comment">-- Beförderungsfest aktivieren
</span>    }

    <span class="comment">-- Baron -------------------------------------------------------------------
</span>
    NeedsAndRightsByKnightTitle[KnightTitles.Baron] = {
        ActivateNeedForPlayer,
        {
            Needs.Hygiene,                                      <span class="comment">-- Bedürfnis: Hygiene
</span>        },
        ActivateRightForPlayer, {
            Technologies.R_SiegeEngineWorkshop,                 <span class="comment">-- Recht: Belagerungswaffenschmied
</span>            Technologies.R_BatteringRam,                        <span class="comment">-- Recht: Ramme
</span>            Technologies.R_Medicine,                            <span class="comment">-- Recht: Medizin
</span>            Technologies.R_Entertainment,                       <span class="comment">-- Recht: Unterhaltung
</span>            Technologies.R_Tavern,                              <span class="comment">-- Recht: Taverne
</span>            Technologies.R_Festival,                            <span class="comment">-- Recht: Fest
</span>            Technologies.R_Street,                              <span class="comment">-- Recht: Straße
</span>            Technologies.R_SpecialEdition_Column,               <span class="comment">-- Recht: Säule AeK SE
</span>        },
        StartKnightsPromotionCelebration                        <span class="comment">-- Beförderungsfest aktivieren
</span>    }

    <span class="comment">-- Graf --------------------------------------------------------------------
</span>
    NeedsAndRightsByKnightTitle[KnightTitles.Earl] = {
        ActivateNeedForPlayer,
        {
            Needs.Entertainment,                                <span class="comment">-- Bedürfnis: Unterhaltung
</span>            Needs.Prosperity,                                   <span class="comment">-- Bedürfnis: Reichtum
</span>        },
        ActivateRightForPlayer, {
            Technologies.R_BowMaker,                            <span class="comment">-- Recht: Bogenmacher
</span>            Technologies.R_BarracksArchers,                     <span class="comment">-- Recht: Bogenschützenkaserne
</span>            Technologies.R_Baths,                               <span class="comment">-- Recht: Badehaus
</span>            Technologies.R_AmmunitionCart,                      <span class="comment">-- Recht: Munitionswagen
</span>            Technologies.R_Prosperity,                          <span class="comment">-- Recht: Reichtum
</span>            Technologies.R_Taxes,                               <span class="comment">-- Recht: Steuern einstellen
</span>            Technologies.R_Ballista,                            <span class="comment">-- Recht: Mauerkatapult
</span>            Technologies.R_SpecialEdition_StatueSettler,        <span class="comment">-- Recht: Siedlerstatue AeK SE
</span>        },
        StartKnightsPromotionCelebration                        <span class="comment">-- Beförderungsfest aktivieren
</span>    }

    <span class="comment">-- Marquees ----------------------------------------------------------------
</span>
    NeedsAndRightsByKnightTitle[KnightTitles.Marquees] = {
        ActivateNeedForPlayer,
        {
            Needs.Wealth,                                       <span class="comment">-- Bedürfnis: Verschönerung
</span>        },
        ActivateRightForPlayer, {
            Technologies.R_Theater,                             <span class="comment">-- Recht: Theater
</span>            Technologies.R_Wealth,                              <span class="comment">-- Recht: Schmuckgebäude
</span>            Technologies.R_BannerMaker,                         <span class="comment">-- Recht: Bannermacher
</span>            Technologies.R_SiegeTower,                          <span class="comment">-- Recht: Belagerungsturm
</span>            Technologies.R_SpecialEdition_StatueProduction,     <span class="comment">-- Recht: Produktionsstatue AeK SE
</span>        },
        StartKnightsPromotionCelebration                        <span class="comment">-- Beförderungsfest aktivieren
</span>    }

    <span class="comment">-- Herzog ------------------------------------------------------------------
</span>
    NeedsAndRightsByKnightTitle[KnightTitles.Duke] = {
        ActivateNeedForPlayer, <span class="keyword">nil</span>,
        ActivateRightForPlayer, {
            Technologies.R_Catapult,                            <span class="comment">-- Recht: Katapult
</span>            Technologies.R_Carpenter,                           <span class="comment">-- Recht: Tischler
</span>            Technologies.R_CandleMaker,                         <span class="comment">-- Recht: Kerzenmacher
</span>            Technologies.R_Blacksmith,                          <span class="comment">-- Recht: Schmied
</span>            Technologies.R_SpecialEdition_StatueDario,          <span class="comment">-- Recht: Dariostatue AeK SE
</span>        },
        StartKnightsPromotionCelebration                        <span class="comment">-- Beförderungsfest aktivieren
</span>    }

    <span class="comment">-- Erzherzog ---------------------------------------------------------------
</span>
    NeedsAndRightsByKnightTitle[KnightTitles.Archduke] = {
        ActivateNeedForPlayer,<span class="keyword">nil</span>,
        ActivateRightForPlayer, {
            Technologies.R_Victory                              <span class="comment">-- Sieg
</span>        },
        <span class="comment">-- VictroryBecauseOfTitle,                              -- Sieg wegen Titel
</span>        StartKnightsPromotionCelebration                        <span class="comment">-- Beförderungsfest aktivieren
</span>    }



    <span class="comment">-- Reich des Ostens --------------------------------------------------------
</span>
    <span class="keyword">if</span> g_GameExtraNo &gt;= <span class="number">1</span> <span class="keyword">then</span>
        <span class="keyword">local</span> TechnologiesTableIndex = <span class="number">4</span>;
        <span class="global">table</span>.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Cistern);
        <span class="global">table</span>.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Beautification_Brazier);
        <span class="global">table</span>.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Beautification_Shrine);
        <span class="global">table</span>.insert(NeedsAndRightsByKnightTitle[KnightTitles.Baron][TechnologiesTableIndex],Technologies.R_Beautification_Pillar);
        <span class="global">table</span>.insert(NeedsAndRightsByKnightTitle[KnightTitles.Earl][TechnologiesTableIndex],Technologies.R_Beautification_StoneBench);
        <span class="global">table</span>.insert(NeedsAndRightsByKnightTitle[KnightTitles.Earl][TechnologiesTableIndex],Technologies.R_Beautification_Vase);
        <span class="global">table</span>.insert(NeedsAndRightsByKnightTitle[KnightTitles.Marquees][TechnologiesTableIndex],Technologies.R_Beautification_Sundial);
        <span class="global">table</span>.insert(NeedsAndRightsByKnightTitle[KnightTitles.Archduke][TechnologiesTableIndex],Technologies.R_Beautification_TriumphalArch);
        <span class="global">table</span>.insert(NeedsAndRightsByKnightTitle[KnightTitles.Duke][TechnologiesTableIndex],Technologies.R_Beautification_VictoryColumn);
    <span class="keyword">end</span>



    <span class="comment">-- ---------------------------------------------------------------------- --
</span>    <span class="comment">-- Bedingungen                                                            --
</span>    <span class="comment">-- ---------------------------------------------------------------------- --
</span>
    KnightTitleRequirements = {}

    <span class="comment">-- Ritter ------------------------------------------------------------------
</span>
    KnightTitleRequirements[KnightTitles.Mayor] = {}
    KnightTitleRequirements[KnightTitles.Mayor].Headquarters = <span class="number">1</span>
    KnightTitleRequirements[KnightTitles.Mayor].Settlers = <span class="number">10</span>
    KnightTitleRequirements[KnightTitles.Mayor].Products = {
        {GoodCategories.GC_Clothes, <span class="number">6</span>},
    }

    <span class="comment">-- Baron -------------------------------------------------------------------
</span>
    KnightTitleRequirements[KnightTitles.Baron] = {}
    KnightTitleRequirements[KnightTitles.Baron].Settlers = <span class="number">30</span>
    KnightTitleRequirements[KnightTitles.Baron].Headquarters = <span class="number">1</span>
    KnightTitleRequirements[KnightTitles.Baron].Storehouse = <span class="number">1</span>
    KnightTitleRequirements[KnightTitles.Baron].Cathedrals = <span class="number">1</span>
    KnightTitleRequirements[KnightTitles.Baron].Products = {
        {GoodCategories.GC_Hygiene, <span class="number">12</span>},
    }

    <span class="comment">-- Graf --------------------------------------------------------------------
</span>
    KnightTitleRequirements[KnightTitles.Earl] = {}
    KnightTitleRequirements[KnightTitles.Earl].Settlers = <span class="number">50</span>
    KnightTitleRequirements[KnightTitles.Earl].Headquarters = <span class="number">2</span>
    KnightTitleRequirements[KnightTitles.Earl].Goods = {
        {Goods.G_Beer, <span class="number">18</span>},
    }

    <span class="comment">-- Marquess ----------------------------------------------------------------
</span>
    KnightTitleRequirements[KnightTitles.Marquees] = {}
    KnightTitleRequirements[KnightTitles.Marquees].Settlers = <span class="number">70</span>
    KnightTitleRequirements[KnightTitles.Marquees].Headquarters = <span class="number">2</span>
    KnightTitleRequirements[KnightTitles.Marquees].Storehouse = <span class="number">2</span>
    KnightTitleRequirements[KnightTitles.Marquees].Cathedrals = <span class="number">2</span>
    KnightTitleRequirements[KnightTitles.Marquees].RichBuildings = <span class="number">20</span>

    <span class="comment">-- Herzog ------------------------------------------------------------------
</span>
    KnightTitleRequirements[KnightTitles.Duke] = {}
    KnightTitleRequirements[KnightTitles.Duke].Settlers = <span class="number">90</span>
    KnightTitleRequirements[KnightTitles.Duke].Storehouse = <span class="number">2</span>
    KnightTitleRequirements[KnightTitles.Duke].Cathedrals = <span class="number">2</span>
    KnightTitleRequirements[KnightTitles.Duke].Headquarters = <span class="number">3</span>
    KnightTitleRequirements[KnightTitles.Duke].DecoratedBuildings = {
        {Goods.G_Banner, <span class="number">9</span> },
    }

    <span class="comment">-- Erzherzog ---------------------------------------------------------------
</span>
    KnightTitleRequirements[KnightTitles.Archduke] = {}
    KnightTitleRequirements[KnightTitles.Archduke].Settlers = <span class="number">150</span>
    KnightTitleRequirements[KnightTitles.Archduke].Storehouse = <span class="number">3</span>
    KnightTitleRequirements[KnightTitles.Archduke].Cathedrals = <span class="number">3</span>
    KnightTitleRequirements[KnightTitles.Archduke].Headquarters = <span class="number">3</span>
    KnightTitleRequirements[KnightTitles.Archduke].RichBuildings = <span class="number">30</span>
    KnightTitleRequirements[KnightTitles.Archduke].FullDecoratedBuildings = <span class="number">30</span>

    <span class="comment">-- Einstellungen Aktivieren
</span>    CreateTechnologyKnightTitleTable()
<span class="keyword">end</span></pre>


</ul>


