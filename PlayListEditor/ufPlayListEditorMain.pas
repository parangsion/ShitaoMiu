//==============================================================================
unit ufPlayListEditorMain;
//==============================================================================

//==============================================================================
interface
//==============================================================================

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Grids, Vcl.CheckLst, Vcl.Mask, JvExMask,
  JvComponentBase, JvDragDrop, JvExExtCtrls, JvExtComponent, JvToolEdit,
  JvSplit, JvExStdCtrls, JvListBox, JvSpin, CEButton, Vcl.Imaging.pngimage,
  XStringGrid, TFlatSplitterUnit,

  uCommDefines, uCommIniLastData,

  uDefines
;

type
  TfPlayListEditorMain = class(TForm)
    Panel1: TPanel;
    pnlGrid: TPanel;
    Panel2: TPanel;
    EditCellEditor1: TEditCellEditor;
    btnRowInsertFirst: TButton;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Label1: TLabel;
    edSmingbotDir: TJvDirectoryEdit;
    btnLoadPlaylistFile_SmingInit: TButton;
    btnLoadPlaylistFile_SmingCurr: TButton;
    btnSavePlaylistFile_Sming: TButton;
    Label2: TLabel;
    edEditorDir: TEdit;
    btnLoadPlaylistFile_EditorInit: TButton;
    btnLoadPlaylistFile_EditorCurr: TButton;
    btnSavePlaylistFile_Editor: TButton;
    Panel9: TPanel;
    pnlBodyLeft: TPanel;
    Panel4: TPanel;
    btnLoadCaptureFileList: TButton;
    lbFileList: TListBox;
    JvxSplitter1: TJvxSplitter;
    sgList: TXStringGrid;
    btnAutoSetCaptureFileLiist: TButton;
    mLog: TMemo;
    imgDelete: TImage;
    lblVersion: TLabel;
    btnRowInsertAll: TButton;
    imgInsert: TImage;
    Panel3: TPanel;
    Label3: TLabel;
    edMagickDir: TJvDirectoryEdit;
    btnMergeImage: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadPlaylistFile_SmingInitClick(Sender: TObject);
    procedure sgListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure btnRowInsertFirstClick(Sender: TObject);
    procedure btnSavePlaylistFile_SmingClick(Sender: TObject);
    procedure JvListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditCellEditor1AllowEndEditEvent(Sender: TObject; var Key: Word;
      Shift: TShiftState; var EndEdit: Boolean);
    procedure btnLoadCaptureFileListClick(Sender: TObject);
    procedure sgListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure btnAutoSetCaptureFileLiistClick(Sender: TObject);
    procedure sgListSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure btnRowInsertAllClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure sgListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgListMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnMergeImageClick(Sender: TObject);

  private
    // CaptureFile listbox
    procedure GetSeletedFilenameList(var aCaptureFilenameList : TCommStringArray);
    procedure GetAllFilenameList(var aCaptureFilenameList : TCommStringArray);

    // StringGrid
    procedure LoadCaptureFileList(sCaptureDir : String; var aCaptureFilenameList : TCommStringPairArray);
    procedure RemoveUsedCaptureFile(var aCaptureFilenameList : TCommStringPairArray);
    procedure SortFilenameList(var aCaptureFilenameList : TCommStringPairArray);

    function  GetKeyForSort(sOrgFilename : String) : String;
    function  GetKeyForMatch(sOrgFilename : String) : String;

    // StringGrid : Screen <-> Data
    procedure PlayList_ScreenToData(var aPlayList : RPOSTARRAY; incEmptyFilename : Boolean);
    procedure PlayList_DataToScreen(var aPlayList : RPOSTARRAY);
    // PlayList -> Merge image files
    procedure PlayList_MergeImages(var aPlayList : RPOSTARRAY);

      // nRowNo 에 해당하는 Pos 값을 구한다.  nRowNo : 1 base
    procedure PlayList_DataPosOfRowNo(var aPos : RITERATOR; var aPlayList : RPOSTARRAY; nRowNo : Integer);
      // sFilename 과 Key Match 되는 게시물의 Pos 값을 구한다.  nRowNo : 1 base
    procedure PlayList_DataPosOfMatchFilename(var aPos : RITERATOR; var aPlayList : RPOSTARRAY; sFilename : String);
    procedure PlayList_AddDataPos(var aPlayList : RPOSTARRAY; var aPos : RITERATOR; var aNewFilenameList : TCommStringArray);
    procedure PlayList_AddData_EmptyFilenameToAll(var aPlayList : RPOSTARRAY; nNewCount : Integer);
    function  PlayList_ScreenRowCount(var aPlayList : RPOSTARRAY) : Integer;

    // StringGrid basic
    function  InsertUpperRow(VGrid : TStringGrid; idxRow : Integer) : Integer;
    function  InsertLowerRow(VGrid : TStringGrid; idxRow : Integer) : Integer;
    function  AppendRow(VGrid : TStringGrid) : Integer;
    function  DeleteRow(VGrid : TStringGrid; idxRow : Integer) : Integer;

    // 특문 생성
    function  GetSpecialText() : String;

  private
    lastData_   : TCommIniLastData;

    isChanged_  : Boolean;

  public
    { Public declarations }
  end;

var
  fPlayListEditorMain: TfPlayListEditorMain;

//==============================================================================
implementation
//==============================================================================

{$R *.dfm}


uses
  StrUtils,
  uCommDefinesImpl, uCommMath, uCommStrings, uCommSystem, uCommLogger
;

{$include Version.inc}


//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.FormCreate(Sender: TObject);
begin
  pnlGrid.Align := alClient;

  lblVersion.Caption  := 'BUILD ' + C_DEFAULT_VERSION_STRING;
  mLog.Text           := '';

  sgList.RowCount     := 2;
  sgList.Rows[1].Text := '';

  btnSavePlaylistFile_Sming.Enabled   := False;
  btnSavePlaylistFile_Editor.Enabled  := False;

  edSmingbotDir.Text  := '';
  edEditorDir.Text    := '';

  lbFileList.Items.Clear;

  lastData_ := TCommIniLastData.Create;
  with lastData_ do begin
    iniFilename := ExtractFilePath(Application.ExeName) + 'PlayListEditor.ini';
    SetSectionName(Self);

    AddKey(edSmingbotDir,  ExtractFilePath(Application.ExeName));
    AddKey(edMagickDir,   '');
  end;

  isChanged_ := False;

end;

//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.FormDestroy(Sender: TObject);
begin
  if (Assigned(lastData_)) then
    FreeAndNil(lastData_);
end;

//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.FormShow(Sender: TObject);
begin

  edEditorDir.Text    := ExtractFilePath( Application.ExeName );

  //----------------------------------------------------------------------------
  // Last data 로당
  LastData_.Read;

end;

//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  buttonSelected : Integer;
begin
  if isChanged_ then begin
    buttonSelected := messagedlg('자료가 변경되었습니다. 종료하시겠습니까?', mtConfirmation, mbOKCancel, 0);
    CanClose := (buttonSelected = mrOK);
  end;
end;
//------------------------------------------------------------------------------
procedure TfPlayListEditorMain.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  //----------------------------------------------------------------------------
  // Last data write
  LastData_.Write;

end;

//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  case Key of
//    VK_ESCAPE : begin key := 0; sgList.EditorMode := False; end;
//    VK_F2     : begin key := 0; if (btnSearch.Enabled and btnSearch.Visible) then btnSearchClick(Sender); end;
//    VK_F5     : begin key := 0; if (btnPrint.Enabled and btnPrint.Visible) then btnPrintClick(Sender); end;
//    VK_F6     : begin key := 0; if (btnExcel.Enabled and btnExcel.Visible) then btnExcelClick(Sender); end;
//    VK_F7     : begin key := 0; if (btnClient.Enabled and btnClient.Visible) then btnClientClick(Sender); end;
//    VK_F12    : begin key := 0; btnCloseClick(Sender); end;
//  end;
end;





//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.btnLoadPlaylistFile_SmingInitClick(Sender: TObject);
var
  isSming, isInit, isSucc : Boolean;
  idxLine, idxCol, nPos : Integer;
  nGridRow : Integer;
  sIniFullFilename, sSmingBefore, sSIDBefore : String;
  iniBody : TStringList;
  aStringArray : TCommStringArray;
  buttonSelected : Integer;
begin
  isSming := (Sender = btnLoadPlaylistFile_SmingInit) or (Sender = btnLoadPlaylistFile_SmingCurr);
  isInit  := (Sender = btnLoadPlaylistFile_SmingInit) or (Sender = btnLoadPlaylistFile_EditorInit);

  if isSming then
    sIniFullFilename := IncludeTrailingPathDelimiter( edSmingbotDir.Text ) + C_PLAYLISTFILENAME
  else
    sIniFullFilename := IncludeTrailingPathDelimiter( edEditorDir.Text ) + C_PLAYLISTFILENAME;

  if not FileExists(sIniFullFilename) then begin
    ShowMessage('ini 파일 없음 : ' + sIniFullFilename);
    Exit;
  end;

  if isChanged_ then begin
    buttonSelected := messagedlg('자료가 변경되었습니다. 변경내용을 무시하고 계속 처리하시겠습니까?', mtConfirmation, mbOKCancel, 0);
    if buttonSelected <> mrOK then
      Exit;
  end;

  // Load ini
  iniBody := TStringList.Create;
  try
    iniBody.LoadFromFile(sIniFullFilename, TEncoding.Unicode);
    //mLog.Lines.Assign(iniBody);

    sSmingBefore  := '';
    sSIDBefore    := '';
    nGridRow := 0;
    for idxLine := 0 to iniBody.Count - 1 do begin
      ClearStringArray(aStringArray);
      Split(iniBody[idxLine], {Separator}'|', {out}aStringArray, {optTrim=}True, {optSkipEmpty=}False);
      if (5 < Length(aStringArray)) then begin
        if (isInit = True) then begin
          isSucc := (aStringArray[1] <> '') or (aStringArray[2] <> '') or (aStringArray[3] <> '');
          // 시간,갤명,제목이 비어있어도, 스밍과 SID 가 이전과 다르면 초기 ini 에 추가(같은갤에 다른 파일스밍)
          if (isSucc = False) and ( (aStringArray[4] <> sSmingBefore) or (aStringArray[5] <> sSIDBefore) ) then
            isSucc := True;
        end else begin
          isSucc := True;
        end;

        if isSucc then begin
          Inc(nGridRow);
          sgList.RowCount := 1 + nGridRow;
          for idxCol := LOW(aStringArray) to MinEx(HIGH(aStringArray),5) do begin
            if isInit and (idxCol = C_GRIDCOLIDX_FILENAME) then begin
              sgList.Rows[nGridRow][idxCol] := '';
            end else begin
              if (idxCol + 1 <= HIGH(aStringArray)) then
                sgList.Rows[nGridRow][idxCol] := aStringArray[idxCol + 1]  // 0 column 은 비어있음
              else
                sgList.Rows[nGridRow][idxCol] := '';

              // (특문) 변경
              if (idxCol = C_GRIDCOLIDX_TITLE) and (sgList.Rows[nGridRow][idxCol] <> '') then begin
                nPos := Pos('(특문)', sgList.Rows[nGridRow][idxCol]);
                if (0 < nPos) then
                  sgList.Rows[nGridRow][idxCol] := StringReplace(sgList.Rows[nGridRow][idxCol], '(특문)', GetSpecialText(), [rfReplaceAll]);
              end;

            end;
          end;
        end;
        sSmingBefore  := aStringArray[4];
        sSIDBefore    := aStringArray[5];
      end;
    end;

  finally
    if Assigned(iniBody) then
      iniBody.Free;
  end;

  btnSavePlaylistFile_Sming.Enabled   := True;
  btnSavePlaylistFile_Editor.Enabled  := True;

  btnLoadCaptureFileList.Click();

  isChanged_ := False;

end;



//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.btnSavePlaylistFile_SmingClick(Sender: TObject);
var
  isSming : Boolean;
  idxR : Integer;
  sIniFullFilename, sIniBackupFullFilename, sLine : String;
  sCaptureDir, sFilename : String;
  iniBody : TStringList;
begin
  isSming := (Sender = btnSavePlaylistFile_Sming);
  sCaptureDir := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(edSmingbotDir.Text) + 'Capture');

  // 원본 백업
  if isSming then
    sIniFullFilename := IncludeTrailingPathDelimiter( edSmingbotDir.Text ) + C_PLAYLISTFILENAME
  else
    sIniFullFilename := IncludeTrailingPathDelimiter( edEditorDir.Text ) + C_PLAYLISTFILENAME;
  if FileExists(sIniFullFilename) then begin
    sIniBackupFullFilename := IncludeTrailingPathDelimiter( edEditorDir.Text ) + 'playlist\' + C_PLAYLISTFILENAME + '.'+ FormatDatetime('YYYYMMDDHHNNSS', Now);
    CreateFullPath(sIniBackupFullFilename, {lastIsFilename=}True);
    //if not RenameFile(sIniFullFilename, sIniBackupFullFilename) then begin
    if not MoveFile(PChar(sIniFullFilename), PChar(sIniBackupFullFilename)) then begin
      ShowMessage('ini 파일 백업 실패 : ' + sIniFullFilename + ' -> ' + sIniBackupFullFilename);
      Exit;
    end;
  end;

  // 저장
  iniBody := TStringList.Create;
  try
    for idxR := 1 to sgList.RowCount - 1 do begin
      sFilename := Trim(sgList.Cells[C_GRIDCOLIDX_FILENAME, idxR]);

      if (sFilename <> '') and (not FileExists(sCaptureDir + sFilename)) then begin
        ShowMessage('Capture 파일 없음 : ' + sFilename);
        Exit;
      end;

      sLine := '|' + Trim(sgList.Cells[C_GRIDCOLIDX_TIME, idxR])
             + '|' + Trim(sgList.Cells[C_GRIDCOLIDX_GALLNAME, idxR])
             + '|' + Trim(sgList.Cells[C_GRIDCOLIDX_TITLE, idxR])
             + '|' + Trim(sgList.Cells[C_GRIDCOLIDX_SMING, idxR])
             + '|' + Trim(sgList.Cells[C_GRIDCOLIDX_SID, idxR])
             + '|' + sFilename
            ;
      iniBody.Add(sLine);
    end;

    try
      iniBody.SaveToFile(sIniFullFilename, TEncoding.Unicode);
    except
      on E:Exception do begin
        ShowMessage('ini 파일 저장 실패 : ' + sIniFullFilename + '. Error:' + E.Message);
        Exit;
      end;
    end;

    IsChanged_ := False;

  finally
    if Assigned(iniBody) then
      iniBody.Free;
  end;

  ShowMessage('ini 파일 저장 성공');

end;



//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.btnLoadCaptureFileListClick(Sender: TObject);
var
  idx : Integer;
  aCaptureFilenameList : TCommStringPairArray;
begin
  LoadCaptureFileList(IncludeTrailingPathDelimiter( edSmingbotDir.Text ) + 'Capture', aCaptureFilenameList);
  RemoveUsedCaptureFile(aCaptureFilenameList);
  SortFilenameList(aCaptureFilenameList);

  lbFileList.Items.Clear;
  for idx := LOW(aCaptureFilenameList) to HIGH(aCaptureFilenameList) do
    lbFileList.Items.Add(aCaptureFilenameList[idx].Value);
end;

//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.btnAutoSetCaptureFileLiistClick(Sender: TObject);
var
  idx, nAddCount : Integer;
  aCaptureFilenameList, aNewFilenameList : TCommStringArray;
  aPlayList : RPOSTARRAY;
  aPos : RITERATOR;
begin
  GetAllFilenameList(aCaptureFilenameList);

  if (0 < Length(aCaptureFilenameList)) then begin
    PlayList_ScreenToData(aPlayList, {incEmptyFilename=}False);
    SetLength(aNewFilenameList, 1);

    nAddCount := 0;
    for idx := LOW(aCaptureFilenameList) to HIGH(aCaptureFilenameList) do begin
      PlayList_DataPosOfMatchFilename({out}aPos, aPlayList, {nRowNo=}aCaptureFilenameList[idx]);
      if aPos.IsValid() then begin
        aNewFilenameList[0] := aCaptureFilenameList[idx];
        PlayList_AddDataPos(aPlayList, aPos, aNewFilenameList);
        Inc(nAddCount);
      end;
    end;

    if (0 < nAddCount) then begin
      PlayList_DataToScreen(aPlayList);
      btnLoadCaptureFileList.Click();
    end;

    isChanged_ := True;

    //mLog.Lines.Add('Drop:' + IntToStr(idxC) + ',' + IntToStr(idxR) + ':' + StringArrayToString(aSelectedFilenameList));
    //mLog.Lines.Add(' -- ' + IntToStr(aPos.idxPost) + ',' + IntToStr(aPos.idxSong) + ',' + IntToStr(aPos.idxFile));
  end;
end;




//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.btnMergeImageClick(Sender: TObject);
var
  aPlayList : RPOSTARRAY;
begin
  PlayList_ScreenToData(aPlayList, {incEmptyFilename=}True);
  PlayList_MergeImages(aPlayList);
  PlayList_DataToScreen(aPlayList);
  isChanged_ := True;
end;


//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.btnRowInsertFirstClick(Sender: TObject);
var
  idxAffectedRow : Integer;
begin
  // 첫 줄 추가
  idxAffectedRow := InsertUpperRow(sgList, 1);
  if (0 < idxAffectedRow) then begin
    sgList.Row := idxAffectedRow;
    isChanged_ := True;
  end;
end;
//------------------------------------------------------------------------------
procedure TfPlayListEditorMain.btnRowInsertAllClick(Sender: TObject);
var
  aPlayList : RPOSTARRAY;
begin
  PlayList_ScreenToData(aPlayList, {incEmptyFilename=}True);
  PlayList_AddData_EmptyFilenameToAll(aPlayList, 1);
  PlayList_DataToScreen(aPlayList);
  isChanged_ := True;
end;




//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.JvListBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not (ssShift in Shift) and  not (ssAlt in Shift) and  not (ssCtrl in Shift) then begin
    (Sender as TListBox).BeginDrag({Immediate=}True);
  end;
end;




//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.EditCellEditor1AllowEndEditEvent(Sender: TObject;
  var Key: Word; Shift: TShiftState; var EndEdit: Boolean);
begin
  EndEdit := (key = VK_ESCAPE);
end;



//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.sgListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  idxC, idxR : Integer;
begin
  sgList.MouseToCell(X, Y, idxC, idxR);

  Accept := (idxC in [C_GRIDCOLIDX_SMING, C_GRIDCOLIDX_SID, C_GRIDCOLIDX_FILENAME]) and
            (0 < idxR);
end;
//------------------------------------------------------------------------------
procedure TfPlayListEditorMain.sgListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  idxC, idxR : Integer;
  aSelectedFilenameList : TCommStringArray;
  aPlayList : RPOSTARRAY;

  aPos : RITERATOR;
begin

  GetSeletedFilenameList(aSelectedFilenameList);

  if (0 < Length(aSelectedFilenameList)) then begin
    sgList.MouseToCell(X, Y, idxC, idxR);

    PlayList_ScreenToData(aPlayList, {incEmptyFilename=}False);

    PlayList_DataPosOfRowNo({out}aPos, aPlayList, {nRowNo=}idxR);
    if aPos.IsValid() then begin
      PlayList_AddDataPos(aPlayList, aPos, aSelectedFilenameList);
      PlayList_DataToScreen(aPlayList);
      btnLoadCaptureFileList.Click();
    end;

    isChanged_ := True;

    mLog.Lines.Add('Drop:' + IntToStr(idxC) + ',' + IntToStr(idxR) + ':' + StringArrayToString(aSelectedFilenameList));
    mLog.Lines.Add(' -- ' + IntToStr(aPos.idxPost) + ',' + IntToStr(aPos.idxSong) + ',' + IntToStr(aPos.idxFile));
  end;

end;

//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.sgListSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  isChanged_ := True;
  btnLoadCaptureFileList.Click();
end;





//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.sgListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  //aRect : TRect;
  aCanvas: TCanvas;
begin
  with TStringGrid(Sender).Canvas do begin
    // Insert row 버튼을 그립니다...
    if (ACol = C_GRIDCOLIDX_BTNINSERT) and (0 < ARow) then begin
      //DrawFrameControl(Handle, Rect, DFC_BUTTON, DFCS_BUTTON3STATE)
      // Draw ImageX.Picture.Bitmap in all Rows in Col 1
      aCanvas := (Sender as TStringGrid).Canvas;  // To avoid with statement
      // Clear current cell rect
      aCanvas.FillRect(Rect);
      // Draw the image in the cell
      aCanvas.Draw(Rect.Left, Rect.Top, imgInsert.Picture.Bitmap);

    // Delete row 버튼을 그립니다...
    end else if (ACol = C_GRIDCOLIDX_BTNDELETE) and (0 < ARow) then begin
      //DrawFrameControl(Handle, Rect, DFC_BUTTON, DFCS_BUTTON3STATE)
      // Draw ImageX.Picture.Bitmap in all Rows in Col 1
      aCanvas := (Sender as TStringGrid).Canvas;  // To avoid with statement
      // Clear current cell rect
      aCanvas.FillRect(Rect);
      // Draw the image in the cell
      aCanvas.Draw(Rect.Left, Rect.Top, imgDelete.Picture.Bitmap);
    end;
  end;
end;

//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.sgListMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  idxC, idxR : Integer;
  buttonSelected : Integer;
  idxAffectedRow : Integer;
begin
  sgList.MouseToCell(X, Y, idxC, idxR);

  //----------------------------------------------------------------------------
  if (idxC = C_GRIDCOLIDX_BTNINSERT) and (0 < idxR) then begin
    idxAffectedRow := InsertLowerRow(sgList, sgList.Row);
    if (0 < idxAffectedRow) then begin
      if (1 < idxAffectedRow) then begin
        sgList.Cells[C_GRIDCOLIDX_SMING, idxAffectedRow] := sgList.Cells[C_GRIDCOLIDX_SMING, idxAffectedRow - 1];
        sgList.Cells[C_GRIDCOLIDX_SID,   idxAffectedRow] := sgList.Cells[C_GRIDCOLIDX_SID,   idxAffectedRow - 1];
      end;
      sgList.Row := idxAffectedRow;
      isChanged_ := True;
    end;

    mLog.Lines.Add('Insert:' + IntToStr(idxC) + ',' + IntToStr(idxR));

  //----------------------------------------------------------------------------
  end else if (idxC = C_GRIDCOLIDX_BTNDELETE) and (0 < idxR) then begin
    if (sgList.Cells[C_GRIDCOLIDX_TIME, sgList.Row] <> '') or (sgList.Cells[C_GRIDCOLIDX_GALLNAME, sgList.Row] <> '') or (sgList.Cells[C_GRIDCOLIDX_TITLE, sgList.Row] <> '') then begin
      buttonSelected := messagedlg('게시글을 삭제합니까?', mtConfirmation, mbOKCancel, 0);
      if buttonSelected <> mrOK then
        Exit;
    end;

    idxAffectedRow := DeleteRow(sgList, sgList.Row);
    if (0 < idxAffectedRow) then begin
      sgList.Row := MinEx(idxAffectedRow, sgList.RowCount - 1);
      btnLoadCaptureFileList.Click();
      isChanged_ := True;
    end;

    mLog.Lines.Add('Delete:' + IntToStr(idxC) + ',' + IntToStr(idxR));

  //----------------------------------------------------------------------------
  end;
end;








//------------------------------------------------------------------------------
//
procedure TfPlayListEditorMain.GetSeletedFilenameList(var aCaptureFilenameList : TCommStringArray);
var
  idx : Integer;
begin
  ClearStringArray(aCaptureFilenameList);
  for idx := 0 to lbFileList.Items.Count - 1 do begin
    if lbFileList.Selected[idx] then
      AddStringArray(aCaptureFilenameList, lbFileList.Items[idx]);
  end;
end;
//------------------------------------------------------------------------------
procedure TfPlayListEditorMain.GetAllFilenameList(var aCaptureFilenameList : TCommStringArray);
var
  idx : Integer;
begin
  SetLength(aCaptureFilenameList, lbFileList.Items.Count);
  for idx := 0 to lbFileList.Items.Count - 1 do begin
    aCaptureFilenameList[idx] := lbFileList.Items[idx];
  end;
end;


//------------------------------------------------------------------------------
//
procedure  TfPlayListEditorMain.LoadCaptureFileList(sCaptureDir : String; var aCaptureFilenameList : TCommStringPairArray);
var
  EOFound : Boolean;
  Res : TSearchRec;
begin
  ClearStringPairArray(aCaptureFilenameList);

  EOFound := False;
  try
    if FindFirst(IncludeTrailingPathDelimiter(sCaptureDir) + '*.*', faNormal, Res) < 0 then begin
      exit;
    end else begin

      while not EOFound do begin

        AddStringPairArray(aCaptureFilenameList, '', Res.Name);

        EOFound := FindNext(Res) <> 0;
      end; // while
    end; // if

  finally
    FindClose(Res);
  end;
end;

//------------------------------------------------------------------------------
//
procedure  TfPlayListEditorMain.RemoveUsedCaptureFile(var aCaptureFilenameList : TCommStringPairArray);
var
  idx : Integer;

  //----------------------------------------------------------------------------
  function ExistFilename(sFilename : String) : Boolean;
  var n : Integer;
  begin
    Result := False;
    for n := 0 to sgList.RowCount - 1 do begin
      if SameText(sFilename, sgList.Cells[C_GRIDCOLIDX_FILENAME, n]) then begin
        Result := True;
        Break;
      end;
    end;
  end;
  //----------------------------------------------------------------------------

begin
  idx := 0;
  while IsValidIndex(aCaptureFilenameList, idx) do begin

    if ExistFilename(aCaptureFilenameList[idx].Value) then begin
      RemoveStringPairArray(aCaptureFilenameList, idx);
    end else begin
      Inc(idx);
    end;

  end;

end;


//------------------------------------------------------------------------------
//
procedure  TfPlayListEditorMain.SortFilenameList(var aCaptureFilenameList : TCommStringPairArray);
var
  idx : Integer;
begin
  for idx := LOW(aCaptureFilenameList) to HIGH(aCaptureFilenameList) do begin
    aCaptureFilenameList[idx].Key := GetKeyForSort(aCaptureFilenameList[idx].Value);
  end;

  // 1. Sort by Key + Value !!!
  // iOn : 1:by Value, 0,else:by Key
  QuickSortStringPairArray(aCaptureFilenameList, {iOn=}0, LOW(aCaptureFilenameList), HIGH(aCaptureFilenameList));
end;


//------------------------------------------------------------------------------
//
function  TfPlayListEditorMain.GetKeyForSort(sOrgFilename : String) : String;
begin
  // Key : Gen + '_' + Value
  // 18-11-25 19시 45분 43초 잘 지내요 - 정승환.png
  // 18-11-25 shitaomiu.png
  // 18-11-25 shitaomiu1.png
  // shitaomiu.png
  // shitaomiu1.png
  // blabla.png

  Result := Trim(ChangeFileExt(sOrgFilename, ''));

  if IsAllNumber(Copy(Result,1,2)) and
     (Copy(Result,3,1) = '-') and
     IsAllNumber(Copy(Result,4,2)) and
     (Copy(Result,6,1) = '-') and
     IsAllNumber(Copy(Result,7,2)) then
  begin
    Result := Trim(Copy(Result, 9) + '_' + Copy(Result, 1, 8));
  end;

  if IsAllNumber(Copy(Result,1,2)) and
     (Copy(Result,3,2) = '시 ') and
     IsAllNumber(Copy(Result,5,2)) and
     (Copy(Result,7,2) = '분 ') and
     IsAllNumber(Copy(Result,9,2)) and
     (Copy(Result,11,1) = '초') then
  begin
    Result := Trim(Copy(Result, 12) + '_' + Copy(Result, 1, 11));
  end;
end;

//------------------------------------------------------------------------------
//
function  TfPlayListEditorMain.GetKeyForMatch(sOrgFilename : String) : String;
begin
  // 18-11-25 19시 45분 43초 잘 지내요 - 정승환.png
  // 18-11-25 shitaomiu.png
  // 18-11-25 shitaomiu1.png
  // shitaomiu.png
  // shitaomiu1.png
  // blabla.png

  Result := Trim(ChangeFileExt(sOrgFilename, ''));

  if IsAllNumber(Copy(Result,1,2)) and
     (Copy(Result,3,1) = '-') and
     IsAllNumber(Copy(Result,4,2)) and
     (Copy(Result,6,1) = '-') and
     IsAllNumber(Copy(Result,7,2)) then
  begin
    Result := Trim(Copy(Result, 9));
  end;

  if IsAllNumber(Copy(Result,1,2)) and
     (Copy(Result,3,2) = '시 ') and
     IsAllNumber(Copy(Result,5,2)) and
     (Copy(Result,7,2) = '분 ') and
     IsAllNumber(Copy(Result,9,2)) and
     (Copy(Result,11,1) = '초') then
  begin
    Result := Trim(Copy(Result, 12));
  end;

  Result := RemoveWhiteSpace(Result);

end;




//------------------------------------------------------------------------------
//
procedure  TfPlayListEditorMain.PlayList_ScreenToData(var aPlayList : RPOSTARRAY; incEmptyFilename : Boolean);
var
  idxR : Integer;
  sSongBefore, sSIDBefore : String;
  aIter : RITERATOR;
  isSucc : Boolean;
begin
  aIter.Clear();
  aPlayList.Clear();

  sSongBefore := '';
  sSIDBefore  := '';

  for idxR := 1 to sgList.RowCount - 1 do begin
    if (sgList.Cells[C_GRIDCOLIDX_TIME, idxR] <> '') or
       (sgList.Cells[C_GRIDCOLIDX_GALLNAME, idxR] <> '') or
       (sgList.Cells[C_GRIDCOLIDX_TITLE, idxR] <> '') or
       (sgList.Cells[C_GRIDCOLIDX_SMING, idxR] <> '') or
       (sgList.Cells[C_GRIDCOLIDX_SID, idxR] <> '') or
       (sgList.Cells[C_GRIDCOLIDX_FILENAME, idxR] <> '') then
    begin
      // New Post
      if (aIter.idxPost < 0) or
         (sgList.Cells[C_GRIDCOLIDX_TIME, idxR] <> '') or
         (sgList.Cells[C_GRIDCOLIDX_GALLNAME, idxR] <> '') or
         (sgList.Cells[C_GRIDCOLIDX_TITLE, idxR] <> '') then
      begin
        aPlayList.SetLength( aPlayList.GetLength() + 1 );
        aIter.idxPost := HIGH(aPlayList.list);
        aIter.idxSong := -1;
        aIter.idxFile := -1;

        aPlayList.list[aIter.idxPost].sDateTime := sgList.Cells[C_GRIDCOLIDX_TIME, idxR];
        aPlayList.list[aIter.idxPost].sGallName := sgList.Cells[C_GRIDCOLIDX_GALLNAME, idxR];
        aPlayList.list[aIter.idxPost].sTitle    := sgList.Cells[C_GRIDCOLIDX_TITLE, idxR];
      end;

      // New Song
      if (aIter.idxSong < 0) or
         ((sgList.Cells[C_GRIDCOLIDX_SMING, idxR] <> '') and (sgList.Cells[C_GRIDCOLIDX_SMING, idxR] <> sSongBefore)) or
         ((sgList.Cells[C_GRIDCOLIDX_SID,   idxR] <> '') and (sgList.Cells[C_GRIDCOLIDX_SID,   idxR] <> sSIDBefore )) then
      begin
        aPlayList.list[aIter.idxPost].aSongList.SetLength( aPlayList.list[aIter.idxPost].aSongList.GetLength() + 1 );
        //aIter.idxPost := ;
        aIter.idxSong := HIGH(aPlayList.list[aIter.idxPost].aSongList.list);
        aIter.idxFile := -1;

        aPlayList.list[aIter.idxPost].aSongList.list[aIter.idxSong].sSongName := sgList.Cells[C_GRIDCOLIDX_SMING, idxR];
        aPlayList.list[aIter.idxPost].aSongList.list[aIter.idxSong].sSID      := sgList.Cells[C_GRIDCOLIDX_SID, idxR];
      end;
      sSongBefore := sgList.Cells[C_GRIDCOLIDX_SMING, idxR];
      sSIDBefore  := sgList.Cells[C_GRIDCOLIDX_SID, idxR];

      // New File : 빈칸 이어도 줄이 있으면 빈 Row 생성
      if incEmptyFilename then
        isSucc := True
      else
        isSucc := (sgList.Cells[C_GRIDCOLIDX_FILENAME, idxR] <> '');
      if isSucc then begin
        SetLength(aPlayList.list[aIter.idxPost].aSongList.list[aIter.idxSong].aFileList, Length(aPlayList.list[aIter.idxPost].aSongList.list[aIter.idxSong].aFileList) + 1 );
        //aIter.idxPost := ;
        //aIter.idxSong := ;
        aIter.idxFile := HIGH(aPlayList.list[aIter.idxPost].aSongList.list[aIter.idxSong].aFileList);

        aPlayList.list[aIter.idxPost].aSongList.list[aIter.idxSong].aFileList[aIter.idxFile] := sgList.Cells[C_GRIDCOLIDX_FILENAME, idxR];
      end;

    end;
  end;

end;

//------------------------------------------------------------------------------
//
procedure  TfPlayListEditorMain.PlayList_DataToScreen(var aPlayList : RPOSTARRAY);
var
  nRowNo, idxPost, idxSong, idxFile, nFileCount : Integer;

  //----------------------------------------------------------------------------
  procedure SetRowData(sFilename : String);
  begin
    if (idxSong = 0) and (idxFile = 0) then begin
      sgList.Cells[C_GRIDCOLIDX_TIME,    nRowNo] := aPlayList.list[idxPost].sDateTime;
      sgList.Cells[C_GRIDCOLIDX_GALLNAME,nRowNo] := aPlayList.list[idxPost].sGallName;
      sgList.Cells[C_GRIDCOLIDX_TITLE,   nRowNo] := aPlayList.list[idxPost].sTitle;
    end else begin
      sgList.Cells[C_GRIDCOLIDX_TIME,    nRowNo] := '';
      sgList.Cells[C_GRIDCOLIDX_GALLNAME,nRowNo] := '';
      sgList.Cells[C_GRIDCOLIDX_TITLE,   nRowNo] := '';
    end;
    sgList.Cells[C_GRIDCOLIDX_SMING,   nRowNo] := aPlayList.list[idxPost].aSongList.list[idxSong].sSongName;
    sgList.Cells[C_GRIDCOLIDX_SID,     nRowNo] := aPlayList.list[idxPost].aSongList.list[idxSong].sSID;
    sgList.Cells[C_GRIDCOLIDX_FILENAME,nRowNo] := sFilename;
  end;
  //----------------------------------------------------------------------------
begin
  //sgList.Rows.Clear();

  sgList.RowCount := 1 + PlayList_ScreenRowCount(aPlayList);

  nRowNo := 0;
  for idxPost := LOW(aPlayList.list) to HIGH(aPlayList.list) do begin
    for idxSong := LOW(aPlayList.list[idxPost].aSongList.list) to HIGH(aPlayList.list[idxPost].aSongList.list) do begin

      nFileCount := Length(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList);
      if (nFileCount < 1) then begin
        idxFile := 0;
        Inc(nRowNo);
        SetRowData({sFilename=}'');
      end else begin
        for idxFile := LOW(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList) to HIGH(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList) do begin
          Inc(nRowNo);
          SetRowData({sFilename=}aPlayList.list[idxPost].aSongList.list[idxSong].aFileList[idxFile]);
        end;
      end;

    end; // for idxSong
  end; // for idxPost
end;


//------------------------------------------------------------------------------
// PlayList -> Merge image files
procedure TfPlayListEditorMain.PlayList_MergeImages(var aPlayList : RPOSTARRAY);
var
  idxPost, idxSong, idxFile, nFileCount : Integer;
  sCaptureFolder, sBackupFolder, sOutFullFilename, sOutFilename, sFileList, sCmdLine : String;
begin
  sCaptureFolder := IncludeTrailingPathDelimiter(edSmingbotDir.Text) + 'Capture\';
  sBackupFolder  := sCaptureFolder + 'MergeBackup\';
    CreateFullPath(sBackupFolder, {lastIsFilename=}False);

  for idxPost := LOW(aPlayList.list) to HIGH(aPlayList.list) do begin
    for idxSong := LOW(aPlayList.list[idxPost].aSongList.list) to HIGH(aPlayList.list[idxPost].aSongList.list) do begin

      nFileCount := Length(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList);
      if (1 < nFileCount) then begin

        // Merge zzzz
        sFileList := '';
        for idxFile := LOW(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList) to HIGH(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList) do begin
          sFileList := sFileList + '"' + sCaptureFolder + aPlayList.list[idxPost].aSongList.list[idxSong].aFileList[idxFile] + '" ';
        end;

        sOutFilename := FormatDateTime('YY-MM-DD',Now) + ' ' + aPlayList.list[idxPost].sGallName + '_' + IntToStr(idxSong + 1) + '.png';
        sOutFullFilename := sCaptureFolder + sOutFilename;
        if FileExists(sOutFullFilename) then
          DeleteFile(sOutFullFilename);

        sCmdLine := IncludeTrailingPathDelimiter(edMagickDir.Text) + 'magick.exe ' + sFileList + '-append "' + sOutFullFilename + '"';
        //LOG.msg(sCmdLine);

        if ExecuteCommand(sCmdLine, {Hidden=}False, {doWait=}True) then begin
          if FileExists(sOutFullFilename) then begin
            for idxFile := LOW(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList) to HIGH(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList) do begin
              MoveFile(  PChar(sCaptureFolder + aPlayList.list[idxPost].aSongList.list[idxSong].aFileList[idxFile]),
                         PChar(sBackupFolder + aPlayList.list[idxPost].aSongList.list[idxSong].aFileList[idxFile])   );
            end;

            SetLength(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList, 1);
            aPlayList.list[idxPost].aSongList.list[idxSong].aFileList[0] := sOutFilename;
          end;
        end else begin
          LOG.msg(
            LOG.log(logError, 'Commanf error : [%s]', [sCmdLine])
          );
        end;
      end;

    end; // for idxSong
  end; // for idxPost
end;

//------------------------------------------------------------------------------
// nRowNo 에 해당하는 Pos 값을 구한다. nRowNo : 1 base
procedure  TfPlayListEditorMain.PlayList_DataPosOfRowNo(var aPos : RITERATOR; var aPlayList : RPOSTARRAY; nRowNo : Integer);
var
  found : Boolean;
  idxPost, idxSong, nRowCounter, nFileCount : Integer;
begin
  aPos.Clear();

  found := False;

  nRowCounter := 0;
  for idxPost := LOW(aPlayList.list) to HIGH(aPlayList.list) do begin
    for idxSong := LOW(aPlayList.list[idxPost].aSongList.list) to HIGH(aPlayList.list[idxPost].aSongList.list) do begin

      nFileCount := MaxEx(1, Length(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList));

      Inc(nRowCounter, nFileCount);
      if (nRowNo <= nRowCounter) then begin
        found := True;
        aPos.idxPost := idxPost;
        aPos.idxSong := idxSong;
        aPos.idxFile := nFileCount - (nRowCounter - nRowNo) - 1;
        Break;
      end;

    end; // for idxSong
    if found then Break;
  end; // for idxPost

end;

//------------------------------------------------------------------------------
// sFilename 과 Key Match 되는 게시물의 Pos 값을 구한다.  nRowNo : 1 base
procedure TfPlayListEditorMain.PlayList_DataPosOfMatchFilename(var aPos : RITERATOR; var aPlayList : RPOSTARRAY; sFilename : String);
var
  found : Boolean;
  idxPost, idxSong : Integer;
  sSmingKey, sFilenameKey : String;

  //----------------------------------------------------------------------------
  function IsSmingSID(sSID : String) : Boolean;
  begin
    Result := (0 < Length(sSID)) and IsAllNumber(sSID);
  end;
  //----------------------------------------------------------------------------

begin
  aPos.Clear();
  if (sFilename = '') then
    Exit;

  found := False;

  sFilenameKey := GetKeyForMatch(sFilename);

  for idxPost := LOW(aPlayList.list) to HIGH(aPlayList.list) do begin
    for idxSong := LOW(aPlayList.list[idxPost].aSongList.list) to HIGH(aPlayList.list[idxPost].aSongList.list) do begin

      // 1. SMING Key 비교
      if (not found) then begin
        sSmingKey := CleanFileName(RemoveWhiteSpace(aPlayList.list[idxPost].aSongList.list[idxSong].sSongName));
        found := (0 < Pos(sSmingKey, sFilenameKey)) or (0 < Pos(sFilenameKey, sSmingKey));
      end;

      // 2. 갤명 비교 : 갤명 C_MIN_GALLNAME_LEN 자 이상이어야 하고, SID 값이 숫자(스밍)이면 안된다.
      if (not found) then begin
        found := //(not IsSmingSID(aPlayList.list[idxPost].aSongList.list[idxSong].sSID)) and
                 (C_MIN_GALLNAME_LEN <= Length(aPlayList.list[idxPost].sGallName)) and
                 (0 < Pos(aPlayList.list[idxPost].sGallName, sFilenameKey));
      end;

      if found then begin
        aPos.idxPost := idxPost;
        aPos.idxSong := idxSong;
        aPos.idxFile := -1;
        Break;
      end;

    end; // for idxSong
    if found then Break;
  end; // for idxPost

end;


//------------------------------------------------------------------------------
//
procedure  TfPlayListEditorMain.PlayList_AddDataPos(var aPlayList : RPOSTARRAY; var aPos : RITERATOR; var aNewFilenameList : TCommStringArray);
var
  idx : Integer;
begin
  if not aPos.IsValid() then
    Exit;

  for idx := LOW(aNewFilenameList) to HIGH(aNewFilenameList) do begin
    AddUniqueStringArray(aPlayList.list[aPos.idxPost].aSongList.list[aPos.idxSong].aFileList, aNewFilenameList[idx]);
  end;
  QuickSortStringArray(aPlayList.list[aPos.idxPost].aSongList.list[aPos.idxSong].aFileList,
                {iLo=}LOW(aPlayList.list[aPos.idxPost].aSongList.list[aPos.idxSong].aFileList),
                {iHi=}HIGH(aPlayList.list[aPos.idxPost].aSongList.list[aPos.idxSong].aFileList));

end;

//------------------------------------------------------------------------------
//
procedure  TfPlayListEditorMain.PlayList_AddData_EmptyFilenameToAll(var aPlayList : RPOSTARRAY; nNewCount : Integer);
var
  idxPost, idxSong, idx : Integer;
begin
  for idxPost := LOW(aPlayList.list) to HIGH(aPlayList.list) do begin
    for idxSong := LOW(aPlayList.list[idxPost].aSongList.list) to HIGH(aPlayList.list[idxPost].aSongList.list) do begin
      SetLength( aPlayList.list[idxPost].aSongList.list[idxSong].aFileList,
                 Length(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList) + nNewCount );
      for idx := Length(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList) - nNewCount to HIGH(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList) do
        aPlayList.list[idxPost].aSongList.list[idxSong].aFileList[idx] := '';
    end; // for idxSong
  end; // for idxPost
end;

//------------------------------------------------------------------------------
//
function   TfPlayListEditorMain.PlayList_ScreenRowCount(var aPlayList : RPOSTARRAY) : Integer;
var
  idxPost, idxSong : Integer;
begin
  Result := 0;

  for idxPost := LOW(aPlayList.list) to HIGH(aPlayList.list) do begin
    for idxSong := LOW(aPlayList.list[idxPost].aSongList.list) to HIGH(aPlayList.list[idxPost].aSongList.list) do begin
      Inc(Result, MaxEx(1, Length(aPlayList.list[idxPost].aSongList.list[idxSong].aFileList)));
    end; // for idxSong
  end; // for idxPost
end;




//------------------------------------------------------------------------------
//
function  TfPlayListEditorMain.InsertUpperRow(VGrid : TStringGrid; idxRow : Integer) : Integer;
var
  idxR : Integer;
begin
  Result := -1;

  VGrid.RowCount := VGrid.RowCount + 1;
  for idxR := VGrid.RowCount - 1 downto idxRow do
    VGrid.Rows[idxR] := VGrid.Rows[idxR - 1];
  VGrid.Rows[idxRow].Text := '';
  Result := idxRow;
end;

//------------------------------------------------------------------------------
function  TfPlayListEditorMain.InsertLowerRow(VGrid : TStringGrid; idxRow : Integer) : Integer;
var
  idxR : Integer;
begin
  Result := -1;

  VGrid.RowCount := VGrid.RowCount + 1;
  for idxR := VGrid.RowCount - 1 downto idxRow + 1 do
    VGrid.Rows[idxR] := VGrid.Rows[idxR - 1];
  VGrid.Rows[idxRow + 1].Text := '';
  Result := idxRow + 1;
end;

//------------------------------------------------------------------------------
//
function  TfPlayListEditorMain.AppendRow(VGrid : TStringGrid) : Integer;
var
  idxC : Integer;
begin
  Result := -1;

  VGrid.RowCount := VGrid.RowCount + 1;
  for idxC := 0 to VGrid.ColCount - 1 do
    VGrid.Cells[idxC, VGrid.RowCount - 1] := '';
  Result := VGrid.RowCount - 1;
end;


//------------------------------------------------------------------------------
//
function  TfPlayListEditorMain.DeleteRow(VGrid : TStringGrid; idxRow : Integer) : Integer;
var
  idxR, idxC : Integer;
begin
  Result := -1;

  if (VGrid.RowCount = 2) then begin
    Result := 1;
    VGrid.Rows[1].Text := '';
  end else begin
    for idxR := idxRow to VGrid.RowCount - 2 do
      for idxC := 0 to VGrid.ColCount - 1 do begin
        VGrid.Cells[idxC, idxR] := VGrid.Cells[idxC, idxR + 1];
      end;
    VGrid.RowCount := VGrid.RowCount - 1;
    Result := idxRow;
  end;
end;


{
procedure DeleteAllRows(VGrid: TStringGrid);
begin
if VGrid.RowCount = 2 then
begin
VGrid.Rows[1].CommaText:= '"","","","",""';
end
else
begin
repeat
DeleteRow(VGrid, VGrid.row);
until VGrid.Row = 1;
VGrid.Rows[1].CommaText:= '"","","","",""';
end;
end;


procedure MoveRowUp(vgrid: TStringGrid; vrow:integer);
var
s: string;
i:integer;
begin
if vrow=1 then exit;
for i:=0 to vgrid.colcount-1 do
begin
s:=vgrid.cells[i,vrow-1];
vgrid.cells[i,vrow-1]:=vgrid.cells[i,vrow];
vgrid.cells[i,vrow]:=s;
end;
vgrid.row:= vrow -1;
vgrid.repaint;
end;

procedure MoveRowDown(vgrid: TStringGrid; vrow:integer);
var
s: string;
i:integer;
begin
if vrow= vgrid.rowcount-1 then exit;
for i:=0 to vgrid.colcount-1 do
begin
s:=vgrid.cells[i,vrow+1];
vgrid.cells[i,vrow+1]:=vgrid.cells[i,vrow];
vgrid.cells[i,vrow]:=s;
end;
vgrid.row:=vrow +1;
vgrid.repaint;
end;
}



//------------------------------------------------------------------------------
//
function  TfPlayListEditorMain.GetSpecialText() : String;
const
  C_SPLIST = '@#$*§※☆★○●◎◇◆□■△▲▽▼◁◀▷▶♤♠♡♥♧♣⊙◈▣◐◑♨☏☎☜☞⌂☺☻'; // 42개
var
  idx1, idx2 : Integer;
begin
  Randomize();
  idx1 := Random(42) + 1;  // 0 .. 41 -> 1 .. 42
  idx2 := Random(42) + 1;  // 0 .. 41 -> 1 .. 42

  Result := C_SPLIST[idx1] + C_SPLIST[idx2];
end;


//==============================================================================
end.
//==============================================================================
