[Setup]
AppName = Falcon Punch
AppVersion = 1.0
CreateAppDir = no
WizardImageFile=banner.bmp
WizardSmallImageFile=logo.bmp
DisableWelcomePage = no
OutputDir = ..\builds
OutputBaseFilename = Falcon Punch Setup

[Files]
Source: "..\..\builds\lua\*"; DestDir: "{userdocs}\UVI\Falcon\User Presets\EventProcessors\Script Processor\Falcon Punch"; Flags: ignoreversion recursesubdirs