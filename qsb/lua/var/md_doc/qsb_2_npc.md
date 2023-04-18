### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.NpcCompose (_Data)

Erstellt einen neuen NPC für den angegebenen Siedler.

 Mögliche Einstellungen für den NPC:
 <table border="1">
 <tr>
 <th><b>Eigenschaft</b></th>
 <th><b>Beschreibung</b></th>
 </tr>
 <tr>
 <td>Name</td>
 <td>(string) Skriptname des NPC. Dieses Attribut wird immer benötigt!</td>
 </tr>
 <tr>
 <td>Type</td>
 <td>(number) Typ des NPC. Zahl zwischen 1 und 4 möglich. Bestimmt, falls
 vorhanden, den Anzeigemodus des NPC Icon.</td>
 </tr>
 <tr>
 <td>Condition</td>
 <td>(function) Bedingung, um die Konversation auszuführen. Muss boolean zurückgeben.</td>
 </tr>
 <tr>
 <td>Callback</td>
 <td>(function) Funktion, die bei erfolgreicher Aktivierung ausgeführt wird.</td>
 </tr>
 <tr>
 <td>Player</td>
 <td>(number|table) Spieler, der/die mit dem NPC sprechen kann/können.</td>
 </tr>
 <tr>
 <td>WrongPlayerAction</td>
 <td>(function) Funktion, die für einen falschen Spieler ausgeführt wird.</td>
 </tr>
 <tr>
 <td>Hero</td>
 <td>(string) Skriptnamen von Helden, die mit dem NPC sprechen können.</td>
 </tr>
 <tr>
 <td>WrongHeroAction</td>
 <td>(function) Funktion, die für einen falschen Helden ausgeführt wird.</td>
 </tr>
 </table>


### API.NpcDispose (_Data)

Entfernt den NPC komplett vom Entity.  Das Entity bleibt dabei erhalten.


### API.NpcUpdate (_Data)

Aktualisiert die Daten des NPC.

 Mögliche Einstellungen für den NPC:
 <table border="1">
 <tr>
 <th><b>Eigenschaft</b></th>
 <th><b>Beschreibung</b></th>
 </tr>
 <tr>
 <td>Name</td>
 <td>(string) Skriptname des NPC. Dieses Attribut wird immer benötigt!</td>
 </tr>
 <tr>
 <td>Type</td>
 <td>(number) Typ des NPC. Zahl zwischen 1 und 4 möglich. Bestimmt, falls
 vorhanden, den Anzeigemodus des NPC Icon.</td>
 </tr>
 <tr>
 <td>Condition</td>
 <td>(function) Bedingung, um die Konversation auszuführen. Muss boolean zurückgeben.</td>
 </tr>
 <tr>
 <td>Callback</td>
 <td>(function) Funktion, die bei erfolgreicher Aktivierung ausgeführt wird.</td>
 </tr>
 <tr>
 <td>Player</td>
 <td>(number) Spieler, die mit dem NPC sprechen können.</td>
 </tr>
 <tr>
 <td>WrongPlayerAction</td>
 <td>(function) Funktion, die für einen falschen Spieler ausgeführt wird.</td>
 </tr>
 <tr>
 <td>Hero</td>
 <td>(string) Skriptnamen von Helden, die mit dem NPC sprechen können.</td>
 </tr>
 <tr>
 <td>WrongHeroAction</td>
 <td>(function) Funktion, die für einen falschen Helden ausgeführt wird.</td>
 </tr>
 <tr>
 <td>Active</td>
 <td>(boolean) Steuert, ob der NPC aktiv ist.</td>
 </tr>
 </table>


### API.NpcIsActive (_Data)

Prüft, ob der NPC gerade aktiv ist.

### API.NpcTalkedTo (_Data, _Hero, _PlayerID)

Prüft, ob ein NPC schon gesprochen hat und optional auch mit wem.

