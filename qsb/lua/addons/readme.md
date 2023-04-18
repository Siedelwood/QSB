# Struktur des Addons

Jedes Addon erhält einen eigenen Ordner im Addons-Ordner der so benannt ist wie die Addon-Datei dann heißen soll.
Entsprechend der Konvention der Module empfiehlt sich folgendes Muster:

QSB_X_Addon_X_Template

Das zweite X ist hier eine Zahl die um eins höher sein sollte als bei Modulen die für dieses Addon benötigt werden damit alles funktioniert.
Alle folgenden Punkte können in dem genannten Ordner eingesehen werden wie diese zusammen zu einem Addon aufgebaut werden.

## Dateien

In dem Ordner des Addons kann eine beliebige Anzahl an lua Dateien liegen.
Beim bauen der QSB werden diese alle aneinander gehängt und bilden dann die Addon Datei.
Ist eine bestimmte Reihenfolge für die korrekte Funktion wichtig sollte dies bei der Namensgebung beachtet werden.
Beim Bau des Addons werden die Dateien alphanumerisch sortiert aneinander gehängt.
Entsprechend der Konvention der Module empfehlen sich manche oder alle der folgenden Dateien:

- In der api.lua sollten alle Funktionen sein die du dem Mapper zur verfügung stellen möchtest.
- In source.lua sollte alles drin sein, was das Addon braucht um zu funtkionieren, aber dem Mapper nicht bekannt sein muss.
- In behavior.lua würdest du die Quests die du anbieten möchtest einbauen.

Beispiele für alle drei Dateien befinden sich in dem oben genannten Ordner.
Die folgenden Erklärungen enthalten jeweils Teile des darin enthaltenen Codings.

## Doku der Öffentlichen Schnittstelle

Die Funktionen die der Mapper benutzen können soll (welche im Normalfall in der api.lua liegen), sollten mit einer ldoc Dokumentation versehen sein, sodass beim Bauen der Dokumentation diese automatisch hinzugefügt werden.
Wie diese für eine Funktion aussehen sollte siehst du anhand des folgenden Beispiels:

``` lua
---
-- Dies ist die Doku zu einer DemoFunktion
--
-- Die DemoFunktion kann eine Ausführliche Beschreibung enthalten. Was alles möglich ist sollte in der Dokumentation von ldoc nachgeschlagen werden.
--
-- Bei der Angabe von Parametern kann jeweils angegeben werden welchen Type diese haben sollten, diese Information kann aber auch weggelassen werden.
--
-- @param[type=number] _Parameter1 Ein Paramter
-- @param[type=string] _Parameter2 (Optional) ein anderer Parameter
-- @return[type=table] Liste mit Ergebnissen
-- @within Anwenderfunktionen
--
-- @usage
-- API.DemoFunktion(1, "_Parameter2")
--
function API.DemoFunktion(_Parameter1, _Parameter2)
    ...
end
```

## Addontabelle

Dieser Abschnitt betrifft den Inhalt des Addons, welcher sich in der source.lua befinden würde.
Damit ein Addon auch geladen wird und in einer Map Funktionen anbieten kann müssen ein paar Voraussetzungen erfüllt sein.
Zum einen sollte für das addon eine Tabelle definiert werden, welche  ihren Namen preisgibt und eine lokale und globale unter Tabelle enthält.

``` lua
Addon_Template = {
    Properties = {
        Name = "Addon_Template",
    },

    Global = {},

    Local = {},
}
```

In den globalen und lokalen Tabellen werden jeweils die Teile des Codings eingefügt welche im globalen oder lokalen Script liegen sollen.
Für beide gibt es die verpflichtende Funktion OnGameStart, welche zum Start des Spieles aufgerufen wird und die genutzt werden kann um alle Daten für das Addon zu initialen.
Optionale Funktionen sind zB OnEvent.

``` lua
function Addon_Template.Global:OnGameStart()
    -- do initialization stuff
end
```

Am Ende der Datei befindet sich folgender Aufruf, der dafür sorgt, dass die QSB dieses Addon lädt.

``` lua
Swift:RegisterModule(Addon_Template)
```

## Behaviors hinzufügen

Ein Behavior (üblicherweise sollte dieser in der behavior.lua abgelegt werden), also für eine Quest entweder ein Trigger, Reward, Reprisal oder Goal, ist eine Tabelle welche bestimmte Daten und Funktionen enthält.

``` lua
B_Reprisal_Useless = {
    Name = "Reprisal_Useless",
    Description = {
        ...
    },
    Parameter = {
        { ParameterType.PlayerID, en = "PlayerID", de = "SpielerID", fr = "PlayerID", },
        ...
    },
}
```
Mehr Details zu den Funktionen die ein Behavior braucht und wie diese zu verwenden sind kann der Beispieldatei entnommen werden.

Am Ende der Definition eines Behaviors muss dieses der QSB übergeben werden, sodass es für Quests zur Verfügung steht und im Questassistenten des Editors benutzt werden kann.

``` lua
Swift:RegisterBehavior(B_Reprisal_Useless)
```
