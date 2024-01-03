unit PascalType.Unicode.Builder.Logger;

interface

type
  Logger = record
  public
    class var Verbose: boolean;

  public
    class procedure FatalError(const AFormat: string; const Args: array of const; AExitCode: Cardinal = 1); overload; static;
    class procedure FatalError(const S: string; AExitCode: Cardinal = 1); overload; static;

    class procedure Warning(const AFormat: string; const Args: array of const); overload; static;
    class procedure Warning(const S: string); overload; static;

    class procedure WriteLn(const AFormat: string; const Args: array of const); overload; static;
    class procedure WriteLn(const S: string); overload; static;
    class procedure WriteLn; overload; static;

    class procedure Write(const AFormat: string; const Args: array of const); overload; static;
    class procedure Write(const S: string); overload; static;

    class procedure ReadLn; overload; static;
  end;

//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  System.SysUtils;

class procedure Logger.FatalError(const S: string; AExitCode: Cardinal);
begin
  if Verbose then
  begin
    Writeln;
    Writeln('[Fatal error] ' + S);
  end;
  ExitCode := AExitCode;
  Abort;
end;

class procedure Logger.FatalError(const AFormat: string; const Args: array of const; AExitCode: Cardinal);
begin
  FatalError(Format(AFormat, Args), AExitCode);
end;

class procedure Logger.ReadLn;
begin
  System.ReadLn;
end;

class procedure Logger.Warning(const S: string);
begin
  if Verbose then
  begin
    Writeln;
    Writeln('[Warning] ' + S);
  end;
end;

class procedure Logger.Warning(const AFormat: string; const Args: array of const);
begin
  Warning(Format(AFormat, Args));
end;

class procedure Logger.Write(const S: string);
begin
  System.Write(S);
end;

class procedure Logger.Write(const AFormat: string; const Args: array of const);
begin
  Write(Format(AFormat, Args));
end;

class procedure Logger.WriteLn(const AFormat: string; const Args: array of const);
begin
  WriteLn(Format(AFormat, Args));
end;

class procedure Logger.WriteLn(const S: string);
begin
  System.WriteLn(S);
end;

class procedure Logger.WriteLn;
begin
  System.WriteLn;
end;

end.
