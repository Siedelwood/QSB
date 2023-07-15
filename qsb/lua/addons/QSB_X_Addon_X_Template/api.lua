
---
-- Dies ist die gesamtbeschreibung des Addons
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- </ul>
--
-- @within Modulbeschreibung
-- @set sort=true
--

API = API or {}

---
-- Hier würden Events aufgelistet werden welche von diesem Addon angeboten werden.
--
-- @field MyAddonEvent Ein Event das zu unbekannter Zeit ausgelöst wird. (Parameter: PlayerID, WassermelonenID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {}

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
    -- Hier sollte geprüft werden ob die übergebenen Parameter den Erwartungen entsprechen
    assert(_Parameter1 and type(_Parameter1) == "number", "API.DemoFunktion: der erste Parameter fehlt oder hat den falschen Typ")

    if not GUI then
        return Addon_Template.Global:DemoFunktion(_Parameter1, _Parameter2)
    else
        return Addon_Template.Local:DemoFunktion(_Parameter1, _Parameter2)
    end
end