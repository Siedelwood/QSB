Dieses Verzeichnis ist für die Module der QSB.

# Module

Alle Module wurden von der Siedelwood Community erzeugt und sind unter der MIT-Lizenz frei nutzbar.

## Aufbau

Verzeichnisse:

* `qsb/lua/modules/*` Hier liegen die Skripte. In der Regel besteht ein Modul aus einer `source.lua`, einer `api.lua` und ggf. einer `behavior.lua`.
Weitere Skripte sind möglich. Die Quelldatei ist zum ausprogrammieren der Features gedacht. Die API-Datei für die Benutzerschnittstelle.
* `demo_maps/*` Hier liegen die Demo-Maps. Eine Demo-Map muss als S6XMAP vorliegen und sollte ebenso als entpackter Ordner vorhanden sein. Das Format des Ordners richtet sich nach der Version des verwendeten BBA-Tool.

## Buildprozess

### Source build

Sofern ein Modul in dem Ordner für die Module liegt, wird es automatish mit den anderen Modulen zur QSB gebaut.

### Dokumentation

Damit zu einem Modul die ldoc Dokumentation automatisch erzeugt werden kann, muss dieses in qsb/lua/tools/docbuilder.lua mit aufgelistet werden:

```lua
QsbDoc_FileList = {
    ...
    {"modules/name_of_module.lua", "Anzeigename"},
};
```

# Addons

Addons werden von einzelnen Mitgliedern der Siedelwood Community zur Verfügung gestellt. Dadurch werden diese automatisch unter der MIT-Lizenz frei nutzbar.

## Aufbau

Verzeichnisse:

* `qsb/lua/addons/*` Hier liegen die Skripte. In der Regel besteht ein Modul aus einer `source.lua`, einer `api.lua` und ggf. einer `behavior.lua`.
Weitere Skripte sind möglich. Die Quelldatei ist zum ausprogrammieren der Features gedacht. Die API-Datei für die Benutzerschnittstelle.
* `demo_maps/*` Hier liegen die Demo-Maps. Eine Demo-Map muss als S6XMAP vorliegen und sollte ebenso als entpackter Ordner vorhanden sein. Das Format des Ordners richtet sich nach der Version des verwendeten BBA-Tool.

## Buildprozess

### Source build

Noch werden Addons nicht automatisch generiert.

### Dokumentation

Damit zu einem Addon die ldoc Dokumentation automatisch erzeugt werden kann, muss dieses in qsb/lua/tools/docbuilder.lua mit aufgelistet werden:

```lua
QsbDoc_FileList = {
    ...
    {"addons/name_of_addon.lua", "Anzeigename"},
};
```