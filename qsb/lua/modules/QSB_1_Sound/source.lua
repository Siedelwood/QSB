-- -------------------------------------------------------------------------- --

ModuleSound = {
    Properties = {
        Name = "ModuleSound",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {},
    Local = {
        SoundBackup = {},
    },
}

-- Global Script ---------------------------------------------------------------

function ModuleSound.Global:OnGameStart()
end

function ModuleSound.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- Local Script ----------------------------------------------------------------

function ModuleSound.Local:OnGameStart()
end

function ModuleSound.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

function ModuleSound.Local:AdjustSound(_Global, _Music, _Voice, _Atmo, _UI)
    self:SaveSound();
    if _Global then
        Sound.SetGlobalVolume(_Global);
    end
    if _Music then
        Sound.SetMusicVolume(_Music);
    end
    if _Voice then
        Sound.SetSpeechVolume(_Voice);
    end
    if _Atmo then
        Sound.SetFXSoundpointVolume(_Atmo);
        Sound.SetFXAtmoVolume(_Atmo);
    end
    if _UI then
        Sound.Set2DFXVolume(_UI);
        Sound.SetFXVolume(_UI);
    end
end

function ModuleSound.Local:SaveSound()
    if not self.SoundBackup.Saved then
        self.SoundBackup.Saved = true;
        self.SoundBackup.FXSP = Sound.GetFXSoundpointVolume();
        self.SoundBackup.FXAtmo = Sound.GetFXAtmoVolume();
        self.SoundBackup.FXVol = Sound.GetFXVolume();
        self.SoundBackup.Sound = Sound.GetGlobalVolume();
        self.SoundBackup.Music = Sound.GetMusicVolume();
        self.SoundBackup.Voice = Sound.GetSpeechVolume();
        self.SoundBackup.UI = Sound.Get2DFXVolume();
    end
end

function ModuleSound.Local:RestoreSound()
    if self.SoundBackup.Saved then
        Sound.SetFXSoundpointVolume(self.SoundBackup.FXSP);
        Sound.SetFXAtmoVolume(self.SoundBackup.FXAtmo);
        Sound.SetFXVolume(self.SoundBackup.FXVol);
        Sound.SetGlobalVolume(self.SoundBackup.Sound);
        Sound.SetMusicVolume(self.SoundBackup.Music);
        Sound.SetSpeechVolume(self.SoundBackup.Voice);
        Sound.Set2DFXVolume(self.SoundBackup.UI);
        self.SoundBackup = {};
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleSound);

