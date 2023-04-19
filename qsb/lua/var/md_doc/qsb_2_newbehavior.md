# Module <code>qsb_2_newbehavior</code>
Die neuen Behavior für den Editor.




### Goal_AmmunitionAmount (_ScriptName, _Relation, _Amount)
source/qsb_2_newbehavior.lua.html#143

Es muss eine Menge an Munition in der Kriegsmaschine erreicht werden.

 <u>Relationen</u>
 <ul>
 <li>>= - Anzahl als Mindestmenge</li>
 <li>< - Weniger als Anzahl</li>
 </ul>






### Goal_CityReputation (_Reputation)
source/qsb_2_newbehavior.lua.html#212

Der Spieler muss mindestens den angegebenen Ruf erreichen.  Der Ruf muss
 in Prozent angegeben werden (ohne %-Zeichen).






### Goal_DestroySoldiers (_PlayerA, _PlayerB, _Amount)
source/qsb_2_newbehavior.lua.html#960

Ein beliebiger Spieler muss Soldaten eines anderen Spielers zerstören.

 Dieses Behavior kann auch in versteckten Quests bentutzt werden, wenn die
 Menge an zerstörten Soldaten durch einen Feind des Spielers gefragt ist oder
 wenn ein Verbündeter oder Feind nach X Verlusten aufgeben soll.






### Goal_DestroySpawnedEntities (_SpawnPoint, _Amount, _Prefixed)
source/qsb_2_newbehavior.lua.html#293

Eine Menge an Entities des angegebenen Spawnpoint muss zerstört werden.

 <b>Hinweis</b>: Eignet sich vor allem für Raubtiere!

 Wenn die angegebene Anzahl zu Beginn des Quest nicht mit der Anzahl an
 bereits gespawnten Entities übereinstimmt, wird dies automatisch korrigiert.
 (Neue Entities gespawnt bzw. überschüssige gelöscht)

 Wenn _Prefixed gesetzt ist, wird anstatt des Namen Entities mit einer
 fortlaufenden Nummer gesucht, welche mit dem Namen beginnen. Bei der
 ersten Nummer, zu der kein Entity existiert, wird abgebrochen.






### Goal_FetchItems (_Positions, _Model, _Distance)
source/qsb_2_newbehavior.lua.html#791

Der Spieler muss eine Anzahl an Gegenständen finden, die bei den angegebenen
 Positionen platziert werden.





### Goal_MoveToPosition (_ScriptName, _Target, _Distance, _UseMarker)
source/qsb_2_newbehavior.lua.html#23

Ein Entity muss sich zu einem Ziel bewegen und eine Distanz unterschreiten.

 Optional kann das Ziel mit einem Marker markiert werden.






### Goal_SpyOnBuilding (_ScriptName, _CheatEarnings, _DeleteThief)
source/qsb_2_newbehavior.lua.html#670

Der Spieler muss ein Gebäude mit einem Dieb ausspoinieren.

 Der Quest ist erfolgreich, sobald der Dieb in das Gebäude eindringt. Es
 muss sich um ein Gebäude handeln, das bestohlen werden kann (Burg, Lager,
 Kirche, Stadtgebäude mit Einnahmen)!

 Optional kann der Dieb nach Abschluss gelöscht werden. Diese Option macht
 es einfacher ihn durch z.B. einen Abfahrenden U_ThiefCart zu "ersetzen".

 <b>Hinweis</b>: Ein Dieb kann nur in Spezialgebäude oder Stadtgebäude
 eindringen!






### Goal_StealFromBuilding (_ScriptName, _CheatEarnings)
source/qsb_2_newbehavior.lua.html#513

Der Spieler muss ein bestimmtes Stadtgebäude bestehlen.

 Eine Kirche wird immer Sabotiert. Ein Lagerhaus verhält sich ähnlich zu
 einer Burg.

 <b>Hinweis</b>: Ein Dieb kann nur von einem Spezialgebäude oder einem
 Stadtgebäude stehlen!






### Goal_StealGold (_Amount, _TargetPlayerID, _CheatEarnings, _ShowProgress)
source/qsb_2_newbehavior.lua.html#381

Der Spieler muss eine bestimmte Menge Gold mit Dieben stehlen.

 Dabei ist es egal von welchem Spieler. Diebe können Gold nur aus
 Stadtgebäude stehlen und nur von feindlichen Spielern.

 <b>Hinweis</b>: Es können nur Stadtgebäude mit einem Dieb um Gold
 erleichtert werden!






### Goal_WinQuest (_QuestName)
source/qsb_2_newbehavior.lua.html#77

Der Spieler muss einen bestimmten Quest abschließen.





### Reprisal_ChangePlayer (_ScriptName, _NewOwner)
source/qsb_2_newbehavior.lua.html#1143

Ändert den Eigentümer des Entity oder des Battalions.





### Reprisal_SetModel (_ScriptName, _Model)
source/qsb_2_newbehavior.lua.html#1390

Ändert das Model eines Entity.

 In Verbindung mit Reward_SetVisible oder Reprisal_SetVisible können
 Script Entites ein neues Model erhalten und sichtbar gemacht werden.
 Das hat den Vorteil, das Script Entities nicht überbaut werden können.






### Reprisal_SetPosition (_ScriptName, _Target, _LookAt, _Distance)
source/qsb_2_newbehavior.lua.html#1050

Ändert die Position eines Siedlers oder eines Gebäudes.

 Optional kann das Entity in einem bestimmten Abstand zum Ziel platziert
 werden und das Ziel anschauen. Die Entfernung darf nicht kleiner sein als 50!






### Reprisal_SetVisible (_ScriptName, _Visible)
source/qsb_2_newbehavior.lua.html#1210

Ändert die Sichtbarkeit eines Entity.





### Reprisal_SetVulnerability (_ScriptName, _Vulnerable)
source/qsb_2_newbehavior.lua.html#1304

Macht das Entity verwundbar oder unverwundbar.

 Bei einem Battalion wirkt sich das Behavior auf alle Soldaten und den
 (unsichtbaren) Leader aus. Wird das Behavior auf ein Spawner Entity
 angewendet, werden die gespawnten Entities genommen.






### Reward_SetVisible (_ScriptName, _Visible)
source/qsb_2_newbehavior.lua.html#1736

Ändert die Sichtbarkeit eines Entity.





### Reward_AI_SetEntityControlled (_ScriptName, _Controlled)
source/qsb_2_newbehavior.lua.html#1825

Gibt oder entzieht einem KI-Spieler die Kontrolle über ein Entity.





### Reward_ChangePlayer (_ScriptName, _NewOwner)
source/qsb_2_newbehavior.lua.html#1494

Ändert den Eigentümer des Entity oder des Battalions.





### Reward_MoveToPosition (_ScriptName, _Destination, _Distance, _Angle)
source/qsb_2_newbehavior.lua.html#1529

Bewegt einen Siedler relativ zu einem Zielpunkt.

 Der Siedler wird sich zum Ziel ausrichten und in der angegeben Distanz
 und dem angegebenen Winkel Position beziehen.

 <p><b>Hinweis:</b> Funktioniert ähnlich wie MoveEntityToPositionToAnotherOne.
 </p>






### Reward_SetModel (_ScriptName, _Model)
source/qsb_2_newbehavior.lua.html#1798

Ändert das Model eines Entity.

 In Verbindung mit Reward_SetVisible oder Reprisal_SetVisible können
 Script Entites ein neues Model erhalten und sichtbar gemacht werden.
 Das hat den Vorteil, das Script Entities nicht überbaut werden können.






### Reward_SetPosition (_ScriptName, _Target, _LookAt, _Distance)
source/qsb_2_newbehavior.lua.html#1467

Ändert die Position eines Siedlers oder eines Gebäudes.

 Optional kann das Entity in einem bestimmten Abstand zum Ziel platziert
 werden und das Ziel anschauen. Die Entfernung darf nicht kleiner sein
 als 50!






### Reward_SetVulnerability (_ScriptName, _Vulnerable)
source/qsb_2_newbehavior.lua.html#1767

Macht das Entity verwundbar oder unverwundbar.

 Bei einem Battalion wirkt sich das Behavior auf alle Soldaten und den
 (unsichtbaren) Leader aus. Wird das Behavior auf ein Spawner Entity
 angewendet, werden die gespawnten Entities genommen.






### Reward_VictoryWithParty ()
source/qsb_2_newbehavior.lua.html#1620

Der Spieler gewinnt das Spiel mit einem animierten Siegesfest.

 Wenn nach dem Sieg weiter gespielt wird, wird das Fest gelöscht.

 <h5>Multiplayer</h5>
 Nicht für Multiplayer geeignet.






### Reward_ToggleCommunityFeatures (...)
source/qsb_2_newbehavior.lua.html#1901

Aktiviert/Deaktiviert optionale Communityfeatures wie Rückbau, Viehzucht, etc.







### Trigger_AmmunitionDepleted (_ScriptName)
source/qsb_2_newbehavior.lua.html#2089

Startet den Quest, sobald die Munition in der Kriegsmaschine erschöpft ist.





### Trigger_OnAtLeastXOfYQuestsFailed (_MinAmount, _QuestAmount, _Quest1, _Quest2, _Quest3, _Quest4, _Quest5)
source/qsb_2_newbehavior.lua.html#1990

Startet den Quest, sobald mindestens X von Y Quests fehlgeschlagen sind.





### Trigger_OnExactOneQuestIsLost (_QuestName1, _QuestName2)
source/qsb_2_newbehavior.lua.html#2218

Startet den Quest, wenn exakt einer von beiden Quests fehlgeschlagen ist.





### Trigger_OnExactOneQuestIsWon (_QuestName1, _QuestName2)
source/qsb_2_newbehavior.lua.html#2148

Startet den Quest, wenn exakt einer von beiden Quests erfolgreich ist.





