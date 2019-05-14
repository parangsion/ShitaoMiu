program PlayListEditor;

uses
  Vcl.Forms,
  ufPlayListEditorMain in 'ufPlayListEditorMain.pas' {fPlayListEditorMain},
  uDefines in 'uDefines.pas',
  uCommStrings in '..\..\DelphiCommon\CommLibs\uCommStrings.pas',
  uCommStringsCodeEx in '..\..\DelphiCommon\CommLibs\uCommStringsCodeEx.pas',
  GifImage in '..\..\DelphiCommon\CommLibs\gifimaged2010b\GifImage.pas',
  uCommDefines in '..\..\DelphiCommon\CommLibs\uCommDefines.pas',
  uCommDefinesImpl in '..\..\DelphiCommon\CommLibs\uCommDefinesImpl.pas',
  uCommSystem in '..\..\DelphiCommon\CommLibs\uCommSystem.pas',
  DCPbase64 in '..\..\DelphiCommon\CommLibs\Cryptography\DCPbase64.pas',
  DCPblockciphers in '..\..\DelphiCommon\CommLibs\Cryptography\DCPblockciphers.pas',
  DCPblowfish in '..\..\DelphiCommon\CommLibs\Cryptography\DCPblowfish.pas',
  DCPconst in '..\..\DelphiCommon\CommLibs\Cryptography\DCPconst.pas',
  DCPcrypt2 in '..\..\DelphiCommon\CommLibs\Cryptography\DCPcrypt2.pas',
  uCommDateTime in '..\..\DelphiCommon\CommLibs\uCommDateTime.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfPlayListEditorMain, fPlayListEditorMain);
  Application.Run;
end.
