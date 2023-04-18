### API.AddSaveGameAction (_Function)

Registriert eine Funktion, die nach dem laden ausgeführt wird.

 <b>Alias</b>: AddOnSaveGameLoadedAction


### API.InstanceTable (_Source, _Dest)

Kopiert eine komplette Table und gibt die Kopie zurück.  Tables können
 nicht durch Zuweisungen kopiert werden. Verwende diese Funktion. Wenn ein
 Ziel angegeben wird, ist die zurückgegebene Table eine Vereinigung der 2
 angegebenen Tables.
 Die Funktion arbeitet rekursiv.

 <b>Alias:</b> CopyTableRecursive


### API.TraverseTable (_Data, _Table)

Sucht in einer eindimensionalen Table nach einem Wert.  Das erste Auftreten des Suchwerts wird als Erfolg gewertet. Es können praktisch alle Lua-Werte gesucht werden.

 <b>Alias:</b> Inside


