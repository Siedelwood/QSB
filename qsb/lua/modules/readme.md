Dieses Verzeichnis ist für die Module der QSB.

# Module

## Aufbau

Ein Modul ist verteilt an 3 Stellen anzulegen. Über das Build Script werden 
Module später automatisch zusammen gebaut, wenn alles entsprechend in den 
Verzeichnissen angelegt wurde.

Verzeichnisse:

* `qsb/lua/modules/*` Hier liegen die Skripte. In der Regel besteht ein Modul 
aus einer `source.lua`, einer `api.lua` und ggf. einer `behavior.lua`. Weitere 
Skripte sind möglich. Die Quelldatei ist zum ausprogrammieren der Features 
gedacht. Die API-Datei für die Benutzerschnittstelle.
* `qsb/demo/*` Hier liegen die Demo-Maps. Eine Demo-Map muss als S6XMAP 
vorliegen und ebenso als entpackter Ordner. Das Format des Ordners richtet
sich nach der Version des verwendeten BBA-Tool.
* `qsb/sample/*` Hier liegen die Beispiele. Ein Beispiel ist eine PDF-Datei 
mit verschiedenen Skriptausschnitten und Erklärungen.

## Registierung

Module müssen in den Tools-Skripten registiert werden.

* In qsb/lua/tools/writer.lua:

```lua
QsbWriter_ModuleFiles = {
    ...
    {"NAME_OF_MODULE", {
        "file1.lua",
        "file2.lua",
        ...
    }},
};
```

* In qsb/lua/tools/docbuilder.lua:

```lua
QsbDoc_FileList = {
    ...
    {"modules/NAME_OF_MODULE/name_of_module.lua", "Anzeigename"},
};
```