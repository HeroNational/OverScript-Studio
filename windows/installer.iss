[Setup]
AppName=OverScript Studio
AppVersion=1.0.0
AppPublisher=OverScript Studio
AppPublisherURL=https://github.com/HeroNational/OverScript-Studio
AppSupportURL=https://github.com/HeroNational/OverScript-Studio/issues
AppUpdatesURL=https://github.com/HeroNational/OverScript-Studio
DefaultDirName={pf}\OverScript Studio
DefaultGroupName=OverScript Studio
OutputDir=.\installer
OutputBaseFilename=OverScriptStudio-Setup
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
WizardStyle=modern
SetupIconFile=..\assets\app_icon.ico
DisableProgramGroupPage=no
AllowNoIcons=no
UninstallDisplayName=OverScript Studio
UninstallDisplayIcon={app}\prompteur.exe
LicenseFile=..\LICENSE
WizardImageFile=..\assets\wizard_image.bmp
WizardSmallImageFile=..\assets\wizard_small_image.bmp

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: ".\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\OverScript Studio"; Filename: "{app}\prompteur.exe"; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,OverScript Studio}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\OverScript Studio"; Filename: "{app}\prompteur.exe"; Tasks: desktopicon; WorkingDir: "{app}"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\OverScript Studio"; Filename: "{app}\prompteur.exe"; Tasks: quicklaunchicon; WorkingDir: "{app}"

[Run]
Filename: "{app}\prompteur.exe"; Description: "{cm:LaunchProgram,OverScript Studio}"; Flags: nowait postinstall skipifsilent

[InstallDelete]
Type: filesandordirs; Name: "{app}\*"

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    MsgBox('Installation de OverScript Studio...', mbInformation, MB_OK);
  end;
  if CurStep = ssPostInstall then
  begin
    MsgBox('OverScript Studio a été installé avec succès!', mbInformation, MB_OK);
  end;
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  { Vous pouvez ajouter des vérifications système ici si nécessaire }
end;
