[UninstallDelete]
Type: filesandordirs; Name: "{app}\library";
Type: filesandordirs; Name: "{app}\utils";
Type: filesandordirs; Name: "{app}\log";

[Code]
const
  ChromeRegKey = 'Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe';
  IERegKey = 'Software\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE';
  FFRegKey = 'Software\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe';
var
  RVersions: TStringList;
  RRegKey: string;
  RegPathsFile: string;
  SecondLicensePage: TOutputMsgMemoWizardPage;
  License2AcceptedRadio: TRadioButton;
  License2NotAcceptedRadio: TRadioButton;

// Is R installed?
function RDetected(): boolean;
var
    v: Integer;
    success: boolean;
begin
    for v := 0 to (RVersions.Count - 1) do
      begin
        if RegKeyExists(HKLM, 'Software\R-Core\R\' + RVersions[v]) or RegKeyExists(HKCU, 'Software\R-Core\R\' + RVersions[v]) then
          success := true
        if success then
          begin
            RRegKey := 'Software\R-Core\R\' + RVersions[v];
            break;
          end;
      end;
  begin
    Result := success;
  end;
end;

// If R is not detected, it is needed
function RNeeded(): Boolean;
begin
  Result := not RDetected;
end;


// Is Chrome installed?
function ChromeDetected(): boolean;
var
    success: boolean;
begin
  success := RegKeyExists(HKLM, ChromeRegKey);
  begin
    Result := success;
  end;
end;

// If Chrome is not detected, it is needed
function ChromeNeeded(): Boolean;
begin
  Result := not ChromeDetected;
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
    PandocDir := ExpandConstant('{localappdata}\Pandoc\');
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

// If Pandoc is not detected, it is needed
function PandocNeeded(): Boolean;
begin
  Result := not PandocDetected;
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
    PandocPath := ExpandConstant('{localappdata}\Pandoc\');
    RegPathsFile := ExpandConstant('{app}\utils\regpaths.json');

    if Length(RRegKey) = 0 then
      RDetected;

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

// Add RInno's license to the installer
procedure CheckLicense2Accepted(Sender: TObject);
begin
  { Update Next button when user (un)accepts the license }
  WizardForm.NextButton.Enabled := License2AcceptedRadio.Checked;
end;

function CloneLicenseRadioButton(Source: TRadioButton): TRadioButton;
begin
  Result := TRadioButton.Create(WizardForm);
  Result.Parent := SecondLicensePage.Surface;
  Result.Caption := Source.Caption;
  Result.Left := Source.Left;
  Result.Top := Source.Top;
  Result.Width := Source.Width;
  Result.Height := Source.Height;
  Result.OnClick := @CheckLicense2Accepted;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  { Update Next button when user gets to second license page }
  if CurPageID = SecondLicensePage.ID then
  begin
    CheckLicense2Accepted(nil);
  end;
end;

procedure InitializeWizard();
var
  LicenseFileName: string;
  LicenseFilePath: string;
begin
  { Create second license page, with the same labels as the original license page }
  SecondLicensePage :=
    CreateOutputMsgMemoPage(
      wpLicense, SetupMessage(msgWizardLicense), SetupMessage(msgLicenseLabel),
      SetupMessage(msgLicenseLabel3), '');

  { Shrink license box to make space for radio buttons }
  SecondLicensePage.RichEditViewer.Height := WizardForm.LicenseMemo.Height;

  { Load license }
  { Loading ex-post, as Lines.LoadFromFile supports UTF-8, }
  { contrary to LoadStringFromFile. }
  LicenseFileName := 'LICENSE';
  ExtractTemporaryFile(LicenseFileName);
  LicenseFilePath := ExpandConstant('{tmp}\' + LicenseFileName);
  SecondLicensePage.RichEditViewer.Lines.LoadFromFile(LicenseFilePath);
  DeleteFile(LicenseFilePath);

  { Clone accept/do not accept radio buttons for the second license }
  License2AcceptedRadio := CloneLicenseRadioButton(WizardForm.LicenseAcceptedRadio);
  License2NotAcceptedRadio := CloneLicenseRadioButton(WizardForm.LicenseNotAcceptedRadio);

  { Initially not accepted }
  License2NotAcceptedRadio.Checked := True;

