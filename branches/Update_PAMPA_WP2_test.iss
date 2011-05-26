; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "PAMPA WP2"
#define MyAppVersion "1.0-4_test"
#define MyAppPublisher "Ifremer"
#define MyAppURL "http://wwz.ifremer.fr/pampa/"
#define MyAppExeName "PAMPA WP2.bat"
#define InstallDir "C:\PAMPA"
#define ExecDir "Exec"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{6F863544-2657-4C1C-8CB5-CD743B198932}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={reg:HKLM\Software\PAMPA WP2,Path|{#InstallDir}}\{#ExecDir}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=.
OutputBaseFilename=setup-update_PAMPA_WP2-{#MyAppVersion}
; SetupIconFile=Y:\tmp\1284538187_bluefish-icon.ico
Compression=lzma
SolidCompression=yes
WizardImageFile=..\Img\pampa2L.bmp
WizardSmallImageFile=..\Img\pampa2.bmp

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
Source: ".\tests\PAMPA WP2.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\tests\img\*"; DestDir: "{app}\img"; Flags: ignoreversion
Source: ".\tests\Doc\*"; DestDir: "{app}\Doc"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: ".\tests\config.r"; DestDir: "{app}"; Flags: uninsneveruninstall onlyifdoesntexist
Source: "tests\barplots_occurrence.R"; DestDir: "{app}"
Source: "tests\barplots_occurrence_unitobs.R"; DestDir: "{app}"
Source: "tests/fonctions_graphiques.R"; DestDir: "{app}"
Source: "tests\boxplots_esp_generiques.R"; DestDir: "{app}"
Source: "tests\boxplots_unitobs_generiques.R"; DestDir: "{app}"
Source: "tests\calcul_simple.r"; DestDir: "{app}"
Source: "tests\command.r"; DestDir: "{app}"
Source: "tests\corresp-cat-benth.csv"; DestDir: "{app}"
Source: "tests\fonctions_base.R"; DestDir: "{app}"
Source: "tests\gestionmessages.r"; DestDir: "{app}"
Source: "tests\Global.r"; DestDir: "{app}"
Source: "tests\import.r"; DestDir: "{app}"
Source: "tests\importdefaut.r"; DestDir: "{app}"
Source: "tests\interface.r"; DestDir: "{app}"
Source: "tests\interface_fonctions.R"; DestDir: "{app}"
Source: "tests\load_packages.R"; DestDir: "{app}"
Source: "tests\mkfilegroupe.r"; DestDir: "{app}"
Source: "tests\modeles_lineaires_esp_generiques.R"; DestDir: "{app}"
Source: "tests\modeles_lineaires_unitobs_generiques.R"; DestDir: "{app}"
Source: "tests\modeles_lineaires_interface.R"; DestDir: "{app}"
Source: "tests\modifinterface.r"; DestDir: "{app}"
Source: "tests\NomsVariables.csv"; DestDir: "{app}"
Source: "tests\PAMPA WP2.bat"; DestDir: "{app}"
Source: "tests\requetes.r"; DestDir: "{app}"
Source: "tests\Rprofile.site"; DestDir: "{app}"
Source: "tests\selection_variables_fonctions.R"; DestDir: "{app}"
Source: "tests\selection_variables_interface.R"; DestDir: "{app}"
Source: "tests\testfichier.r"; DestDir: "{app}"
Source: "tests\view.r"; DestDir: "{app}"
Source: "tests\nombres_SVR.R"; DestDir: "{app}"
Source: "tests\arbres_regression_unitobs_generiques.R"; DestDir: "{app}"
Source: "tests\arbres_regression_esp_generiques.R"; DestDir: "{app}"
Source: "tests\demo_cartes.R"; DestDir: "{app}"


[Icons]
;; IconFilename: "{app}\img\Pampa.ico" pour d�finir l'icone d'un raccourci.
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: {#InstallDir}; IconFilename: "{app}\img\Pampa.ico"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{app}\{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; WorkingDir: {#InstallDir}; IconFilename: "{app}\img\Pampa.ico"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon; WorkingDir: {#InstallDir}; IconFilename: "{app}\img\Pampa.ico"

Name: "{group}\Documentation\Guide Utilisateur"; Filename: "{app}\Doc\Guide_plateforme_WP2_Meth4-042011.pdf";
;; Name: "{group}\Documentation\Nouveaut�s de la plateforme PAMPA WP2"; Filename: "{app}\Doc\Annexe_GuideCalculsIndicateurs-WP2-Meth4-092010.pdf";
Name: "{group}\Cr�er un rapport de bug"; Filename: "{app}\Doc\Rapport_bug_PAMPA-WP2.dot";

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, "&", "&&")}}"; Flags: shellexec postinstall skipifsilent; WorkingDir: {#InstallDir}

[Dirs]
Name: "{#InstallDir}\Data"; Flags: uninsneveruninstall; Tasks: ; Languages:





































