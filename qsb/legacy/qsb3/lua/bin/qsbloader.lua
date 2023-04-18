---@diagnostic disable: undefined-global
QSBLoader = {
    m_BasePath = nil,
    m_CoreFiles = {
        "Swift_0_Core/swift.lua",
        "Swift_0_Core/api.lua",
        "Swift_0_Core/debug.lua",
        "Swift_0_Core/behavior.lua",
        "Swift_0_Core/user.lua",
    },
    m_ModuleFiles = {},
}

function QSBLoader:SetPath(_Path)
    self.m_BasePath = _Path;
end

function QSBLoader:Load()
    if self.m_BasePath == nil then
        self:SetPath("maps/externalmap/" ..Framework.GetCurrentMapName().. "/");
    end

    Script.Load(self.m_BasePath.. "loadorder.lua");
    if not QSBLoader_LoadOrder then
        assert(false, "unable to find load order!");
        return;
    end
    self.m_ModuleFiles = QSBLoader_LoadOrder;
    if #self.m_ModuleFiles == 0 then
        assert(false, "no files in load order!");
        return;
    end

    for i= 1, #self.m_CoreFiles do
        Script.Load(self.m_BasePath.. "lib/" ..self.m_CoreFiles[i]);
    end
    for i= 1, #self.m_ModuleFiles, 1 do
        Script.Load(self.m_BasePath.. "lib/" ..self.m_ModuleFiles[i]);
    end
    Script.Load(self.m_BasePath.. "lib/Swift_0_Core/selfload.lua");
end

-- ----- --

function SetPath(_Path)
    QSBLoader:SetPath(_Path);
end

function IncludeLibrary()
    QSBLoader:Load();
end

