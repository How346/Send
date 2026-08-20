#define AppName "HyperDrop"
#define AppVersion "0.1.0"
#define AppPublisher "HyperDrop"
#define AppExeName "hyperdrop.exe"

[Setup]
AppId={{B6C0A7A4-3E2B-4B4B-A9D4-0D4A4C12D9A1}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\HyperDrop
DefaultGroupName=HyperDrop
OutputDir=.
OutputBaseFilename=HyperDrop-Setup
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
WizardStyle=modern

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\HyperDrop"; Filename: "{app}\hyperdrop.exe"
Name: "{autodesktop}\HyperDrop"; Filename: "{app}\hyperdrop.exe"
