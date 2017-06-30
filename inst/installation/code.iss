[UninstallDelete]
Type: filesandordirs; Name: "{app}\library";
Type: filesandordirs; Name: "{app}\utils";
Type: filesandordirs; Name: "{app}\log";

[Code]
const
  RRegKey = 'Software\R-Core\R\{#RVersion}';
  ChromeRegKey = 'Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe';
  IERegKey = 'Software\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE';
  FFRegKey = 'Software\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe';
var
  RegPathsFile: string;

// Is R installed?
function RDetected(): boolean;
var
    success: boolean;
begin
  success := RegKeyExists(HKLM, RRegKey) or RegKeyExists(HKCU, RRegKey);
  begin
    Result := success;
  end;
end;

// If R is not detected, it is needed
function RNeeded(): Boolean;
begin
  Result := (RDetected = false);
end;

// Registry path update function (adds an extra backslash for json)
function AddBackSlash(Value: string): string;
begin
  Result := Value;
  StringChangeEx(Result, '\', '\\', True);
end;

// Pandoc is stored in the System PATH
function PandocDetected(): Boolean;
var
  PandocDir, Path: String;
begin
  Log('Checking for Pandoc in %PATH%');
  if RegQueryStringValue(HKEY_CURRENT_USER, 'Environment', 'Path', Path) then
  begin // Successfully read the value
    Log('HKCU\Environment\PATH = ' + Path);
    PandocDir := ExpandConstant('{localappdata}\Pandoc\pandoc.exe');
    Log('Looking for Pandoc in %PATH%: ' + PandocDir + ' in ' + Path);
    if Pos(LowerCase(PandocDir), Lowercase(Path)) = 0 then
		begin
			Log('Did not find Pandoc in %PATH%');
			Result := False;
		end
    else
		begin
			Log('Found Pandoc in %PATH%');
			Result := True;
		end
  end
  else // The key probably doesn't exist
  begin
    Log('Could not access HKCU\Environment\PATH.');
    Result := False;
  end;
end;

// Save installation paths
procedure CurStepChanged(CurStep: TSetupStep);
var
  RPath, ChromePath, IEPath, FFPath, PandocPath: string;
begin
if CurStep = ssPostInstall then begin
    RPath := '';
    ChromePath := '';
    IEPath := '';
    FFPath := '';
		PandocPath := ExpandConstant('{localappdata}\Pandoc\pandoc.exe');
    RegPathsFile := ExpandConstant('{app}\utils\regpaths.json');
    // Create registry paths file
    SaveStringToFile(RegPathsFile, '{' + #13#10, True);

    // R RegPath
    if RegQueryStringValue(HKLM, RRegKey, 'InstallPath', RPath) or RegQueryStringValue(HKCU, RRegKey, 'InstallPath', RPath) then
      SaveStringToFile(RegPathsFile, '"r": "' + AddBackSlash(RPath) + '",' + #13#10, True)
    else
      SaveStringToFile(RegPathsFile, '"r": "none",' + #13#10, True);

    // Chrome RegPath
    if RegQueryStringValue(HKLM, ChromeRegKey, 'Path', ChromePath) then
      SaveStringToFile(RegPathsFile, '"chrome": "' + AddBackSlash(ChromePath) + '",' + #13#10, True)
    else
      SaveStringToFile(RegPathsFile, '"chrome": "none",' + #13#10, True);

    // Internet Explorer RegPath
    if RegQueryStringValue(HKLM, IERegKey, '', IEPath) then
      SaveStringToFile(RegPathsFile, '"ie": "' + AddBackSlash(IEPath) + '",' + #13#10, True)
    else
      SaveStringToFile(RegPathsFile, '"ie": "none",' + #13#10, True);

    // Firefox RegPath
    if RegQueryStringValue(HKLM, FFRegKey, 'Path', FFPath) then
      SaveStringToFile(RegPathsFile, '"ff": "' + AddBackSlash(FFPath) + '",' + #13#10, True)
    else
      SaveStringToFile(RegPathsFile, '"ff": "none",' + #13#10, True);

		// Pandoc RegPath
		// ** Last Line in json file (no trailing comma) **
		if PandocDetected() then
			SaveStringToFile(RegPathsFile, '"pandoc": "' + AddBackSlash(PandocPath) + '"' + #13#10, True)
		else
			SaveStringToFile(RegPathsFile, '"pandoc": "none"' + #13#10, True);

    SaveStringToFile(RegPathsFile, '}', True);
  end;
end;

