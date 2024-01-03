program UDExtract;

{$APPTYPE CONSOLE}

// Application to convert a Unicode database file into a resource script compilable
// to a resource file. For usage see procedure PrintUsage.

uses
  Generics.Collections,
  Generics.Defaults,
  System.IOUtils,
  System.Classes,
  System.SysUtils,
  PascalType.Unicode in '..\..\..\PascalType.Unicode.pas',
  PascalType.Unicode.Builder.CharacterSet in 'PascalType.Unicode.Builder.CharacterSet.pas',
  PascalType.Unicode.Builder.ResourceWriter in 'PascalType.Unicode.Builder.ResourceWriter.pas',
  PascalType.Unicode.Builder.Common in 'PascalType.Unicode.Builder.Common.pas',
  PascalType.Unicode.Builder.PropertyValueAliases in 'PascalType.Unicode.Builder.PropertyValueAliases.pas',
  PascalType.Unicode.Builder.Logger in 'PascalType.Unicode.Builder.Logger.pas',
  PascalType.Unicode.Builder.CaseMapping in 'PascalType.Unicode.Builder.CaseMapping.pas',
  PascalType.Unicode.Builder.ArabicShaping in 'PascalType.Unicode.Builder.ArabicShaping.pas',
  PascalType.Unicode.Builder.Decomposition in 'PascalType.Unicode.Builder.Decomposition.pas',
  PascalType.Unicode.Builder.Numbers in 'PascalType.Unicode.Builder.Numbers.pas',
  PascalType.Unicode.Builder.Categories in 'PascalType.Unicode.Builder.Categories.pas',
  PascalType.Unicode.Builder.Scripts in 'PascalType.Unicode.Builder.Scripts.pas',
  PascalType.Unicode.Builder.PropList in 'PascalType.Unicode.Builder.PropList.pas',
  PascalType.Unicode.Builder.DerivedNormalizationProps in 'PascalType.Unicode.Builder.DerivedNormalizationProps.pas',
  PascalType.Unicode.Builder.UnicodeData in 'PascalType.Unicode.Builder.UnicodeData.pas';

var
  SourceFolder: string;
  TargetFileName: string = sDefaultResourceFilename;
  ZLibCompress: Boolean;

  Categories: TUnicodeCategories;
  CCCs: TCharacterSetList;
  ArabicShaping: TUnicodeArabicShaping;
  Scripts: TUnicodeScripts;
  Decompositions: TUnicodeDecompositions;
  Compositions: TUnicodeCompositions;
  Numbers: TUnicodeNumbers;
  CaseMapping: TUnicodeCaseMapping;


//----------------------------------------------------------------------------------------------------------------------

procedure CreateResourceScript;
// creates the target file using the collected data
begin
  var ResourceWriter := TResourceWriter.Create(TargetFileName, ZLibCompress);
  try

    // 1) Resource script header
    ResourceWriter.WriteHeader;


    // 2) Category data
    ResourceWriter.BeginResource(sUnicodeResourceCategories);
    Categories.WriteAsResource(ResourceWriter);
    ResourceWriter.EndResource;


    // 3) Case mapping data
    if (CaseMapping <> nil) then
    begin
      ResourceWriter.BeginResource(sUnicodeResourceCase);
      CaseMapping.WriteAsResource(ResourceWriter);
      ResourceWriter.EndResource;
    end;


    // 4) Decomposition data
    ResourceWriter.BeginResource(sUnicodeResourceDecomposition);
    Decompositions.WriteAsResource(ResourceWriter);
    ResourceWriter.EndResource;


    // 5) Canonical combining class data
    ResourceWriter.BeginResource(sUnicodeResourceCombining);
    CCCs.WriteAsResource(ResourceWriter);
    ResourceWriter.EndResource;


    // 5a) ArabicShapingClasses
    if (ArabicShaping <> nil) then
    begin
      ResourceWriter.BeginResource(sUnicodeResourceArabShaping);
      ArabicShaping.WriteAsResource(ResourceWriter);
      ResourceWriter.EndResource;
    end;


    // 5b) Scripts
    ResourceWriter.BeginResource(sUnicodeResourceScripts);
    Scripts.WriteAsResource(ResourceWriter);
    ResourceWriter.EndResource;

    // 6) Number data, this is actually two arrays, one which contains the numbers
    //    and the second containing the mapping between a code and a number
    ResourceWriter.BeginResource(sUnicodeResourceNumbers);
    Numbers.WriteAsResource(ResourceWriter);
    ResourceWriter.EndResource;


    // 7 ) Composition data
    // Create composition data from decomposition data and exclusion list before generating the output
    Compositions.ConstructFromDecompositions(Decompositions);
    ResourceWriter.BeginResource(sUnicodeResourceComposition);
    Compositions.WriteAsResource(ResourceWriter);
    ResourceWriter.EndResource;

  finally
    ResourceWriter.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure PrintUsage;
begin
  Logger.Writeln('Usage: UDExtract [options]');
  Logger.Writeln;
  Logger.Writeln('  Reads data from the Unicode Character Database (UCD) text files');
  Logger.Writeln('  and generate a Windows resource script from the data in it.');
  Logger.Writeln;
  Logger.Writeln('  Options might have the following values (not case sensitive):');
  Logger.Writeln('    /?'#9#9#9'shows this screen');
  Logger.Writeln('    /source:<value>'#9'specify UCD source folder');
  Logger.Writeln('    /target:<value>'#9'specify destination resource file (default is unicode.rc)');
  Logger.Writeln('    /v or /verbose'#9'show warnings, errors etc., prompt at completion');
  Logger.WriteLn('    /z or /zip'#9#9'compress resource streams using zlib');
  Logger.Writeln('    /pause'#9#9'prompt after completion');
  Logger.Writeln('    /all'#9#9'include all of the following resources');
  Logger.Writeln('    /alias'#9#9'read property value aliases text file');
  Logger.Writeln('    /arabic'#9#9'include arabic shaping resource');
  Logger.Writeln('    /case'#9#9'include lower/upper case resource');
  Logger.Writeln('    /casing'#9#9'include special case folding resource');
  Logger.WriteLn('    /derived'#9#9'include derived normalization resource');
  Logger.WriteLn('    /proplist'#9#9'include character properties resources');
  Logger.Writeln('    /scripts'#9#9'include scripts resource');
  Logger.Writeln;
  Logger.Writeln('Press <enter> to continue...');
  Logger.Readln;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ParseOptions;
var
  Value: string;
begin
  if FindCmdLineSwitch('h') or FindCmdLineSwitch('help') or FindCmdLineSwitch('?') then
  begin
    PrintUsage;
    Halt(0)
  end;

  Logger.Verbose := FindCmdLineSwitch('verbose') or FindCmdLineSwitch('v');
  ZLibCompress := FindCmdLineSwitch('zip') or FindCmdLineSwitch('z');

  if FindCmdLineSwitch('source', Value, True, [clstValueAppended]) then
    SourceFolder := Value;

  if FindCmdLineSwitch('target', Value, True, [clstValueAppended]) then
    TargetFileName := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

begin

  Logger.Writeln('Unicode database conversion tool');
  Logger.Writeln('(c) 2000, written by Dipl. Ing. Mike Lischke [public@lischke-online.de]');
  Logger.Writeln('(c) 2023, rewritten by Anders Melander [anders@melander.dk]');
  Logger.Writeln;

  ParseOptions;

  Decompositions := nil;
  Compositions := nil;
  CaseMapping := nil;
  ArabicShaping := nil;
  var PropertyValueAliases: TPropertyValueAliases := nil;
  try
    try
      Decompositions := TUnicodeDecompositions.Create;
      Compositions := TUnicodeCompositions.Create;
      Numbers := TUnicodeNumbers.Create;
      CaseMapping := TUnicodeCaseMapping.Create;

      begin
        var FileName := TPath.Combine(SourceFolder, sUnicodeDataFileName);
        UnicodeData.Parse(FileName,
          Categories,
          CCCs,
          Decompositions,
          Numbers,
          CaseMapping);
      end;

      var ParamAll := FindCmdLineSwitch('all');

      if ParamAll or FindCmdLineSwitch('alias') then
      begin
        PropertyValueAliases := TPropertyValueAliases.Create;

        var FileName := TPath.Combine(SourceFolder, AliasFileName);
        PropertyValueAliases.Parse(FileName);
      end;

      if ParamAll or FindCmdLineSwitch('arabic') then
      begin
        ArabicShaping := TUnicodeArabicShaping.Create;

        var FileName := TPath.Combine(SourceFolder, ArabicShapingFileName);;
        ArabicShaping.Parse(FileName);
      end;

      if ParamAll or FindCmdLineSwitch('scripts') then
      begin
        var FileName := TPath.Combine(SourceFolder, sScriptsFileName);
        Scripts.Parse(FileName);
      end;

      // TODO : We might need to create CaseMapping always since it's used by the main data file
      if ParamAll or FindCmdLineSwitch('casing') then
      begin
        var FileName := TPath.Combine(SourceFolder, SpecialCasingFileName);
        CaseMapping.ParseSpecialCasing(FileName);
      end;

      if ParamAll or FindCmdLineSwitch('case') then
      begin
        var FileName := TPath.Combine(SourceFolder, CaseFoldingFileName);
        CaseMapping.ParseCaseFolding(FileName);
      end;

      if ParamAll or FindCmdLineSwitch('derived') then
      begin
        var FileName := TPath.Combine(SourceFolder, sDerivedNormalizationPropsFileName);
        UnicodeDerivedNormalizationProps.Parse(FileName, Compositions);
      end;

      if ParamAll or FindCmdLineSwitch('proplist') then
      begin
        var FileName := TPath.Combine(SourceFolder, sPropListFileName);
        UnicodePropList.Parse(FileName, Categories);
      end;

      // finally write the collected data
      if Logger.Verbose then
      begin
        Logger.Writeln;
        Logger.Writeln;
        Logger.Writeln('Writing resource script ' + TargetFileName + '  ');
      end;

      CreateResourceScript;

    except
      on E: Exception do
        Logger.FatalError('Exception: %s', [E.Message]);
    end;

  finally
    Numbers.Free;
    Decompositions.Free;
    Compositions.Free;
    PropertyValueAliases.Free;
    CaseMapping.Free;
    ArabicShaping.Free;

    if Logger.Verbose and FindCmdLineSwitch('pause') then
    begin
      Logger.Writeln;
      Logger.Writeln('Program finished. Press <enter> to continue...');
      Logger.ReadLn;
    end;
  end;
end.

