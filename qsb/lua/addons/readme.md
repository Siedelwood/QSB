# Struktur des Addons

## Dateien

- In der api.lua sollten alle Funktionen sein die du dem Mapper zur verfügung stellen möchtest.
- In source.lua sollte alles drin sein, was das Addon braucht um zu funtkionieren, aber dem Mapper nicht bekannt sein muss.
- In behavior.lua würdest du die Quests die du anbieten möchtest einbauen.

## Doku der Öffentlichen Schnittstelle

Die Funktionen die der Mapper benutzen können soll, sollten mit einer ldoc Dokumentation versehen sein, sodass beim Bauen der Dokumentation diese automatisch hinzugefügt werden.

## Addontabelle

Damit ein Addon auch geladen wird und in einer Map Funktionen anbieten kann müssen ein paar Voraussetzungen erfüllt sein.

## Behaviors hinzufügen

So können Quests hinzugefügt werden.