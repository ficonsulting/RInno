[Code]
// Is R installed?
function RDetected(): boolean;
var
    success: boolean;
begin
  success := RegKeyExists(HKLM, 'Software\R-Core\R\{#RVersion}');
  begin
    Result := success;
  end;
end;

// If R is not detected, it is needed
function RNeeded(): Boolean;
begin
  Result := (RDetected = false);
end;


