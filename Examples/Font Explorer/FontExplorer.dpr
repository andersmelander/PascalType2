program FontExplorer;

{$I PT_Compiler.inc}
{$R 'Default.res' '..\..\Resource\Default.rc'}

uses
  Forms,
  FE_FontHeader in 'FE_FontHeader.pas' {FrameFontHeader: TFrame},
  FontExplorerMain in 'FontExplorerMain.pas' {FormTTF};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormTTF, FormTTF);
  Application.Run;
end.
