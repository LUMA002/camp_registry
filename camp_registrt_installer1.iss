[Setup]
AppName=Camp Registry
AppVersion=1.0.0
DefaultDirName={autopf}\Camp Registry
DefaultGroupName=Camp Registry
UninstallDisplayIcon={app}\camp_registry.exe
OutputDir=installer
OutputBaseFilename=camp_registry_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\Camp Registry"; Filename: "{app}\camp_registry.exe"
Name: "{commondesktop}\Camp Registry"; Filename: "{app}\camp_registry.exe"

[Run]
Filename: "{app}\camp_registry.exe"; Description: "Запустити додаток"; Flags: nowait postinstall skipifsilent