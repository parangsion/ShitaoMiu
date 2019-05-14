//==============================================================================
unit uDefines;
//==============================================================================

//==============================================================================
interface
//==============================================================================

uses
  uCommDefines
;

const
  C_PLAYLISTFILENAME  = 'playlist.ini';

  C_CAPTUREFOLDERNAME = 'Capture';


const
  C_GRIDCOLIDX_TIME       = 0;
  C_GRIDCOLIDX_GALLNAME   = 1;
  C_GRIDCOLIDX_TITLE      = 2;
  C_GRIDCOLIDX_SMING      = 3; //--------- �ݺ��� �������...
  C_GRIDCOLIDX_SID        = 4;
  C_GRIDCOLIDX_FILENAME   = 5;
  C_GRIDCOLIDX_BTNINSERT  = 6;
  C_GRIDCOLIDX_BTNDELETE  = 7;



type
  //----------------------------------------------------------------------------
  // 1 sming(�뷡 1 ��)
  RSONG = record
    sSongName   : String;
    sSID        : String;
    aFileList   : TCommStringArray;   // 1 �뷡�� © ���   Key: sort key, Value:File name
  end;
  RSONGARRAY = RCommArray<RSONG>;

  //----------------------------------------------------------------------------
  // 1 �Խù�
  RPOST = record
    sDateTime     : String;
    sGallName     : String;
    sTitle        : String;
    aSongList     : RSONGARRAY;    // 1 �Խù��� ������ �뷡 ����Ʈ. ���� 1���� ��κ�������, ���� 2~3���� ���ÿ� �ԽõǴ� ��찡 ����
  end;
  //----------------------------------------------------------------------------
  RPOSTARRAY = RCommArray<RPOST>;


  //----------------------------------------------------------------------------
  // 1 �Խù�
  RITERATOR = record
    idxPost   : Integer;
    idxSong   : Integer;    // �ʱ� playlist �� loading�ϸ� Song ������ setting ehls��.
    idxFile   : Integer;
  public
    procedure Clear();
    function  IsValid() : Boolean;
  end;



//==============================================================================
implementation
//==============================================================================


//------------------------------------------------------------------------------
//
procedure RITERATOR.Clear();
begin
  idxPost   := -1;
  idxSong   := -1;
  idxFile   := -1;
end;

//------------------------------------------------------------------------------
//
function  RITERATOR.IsValid() : Boolean;
begin
  Result := (-1 < idxPost) and (-1 < idxSong) {and (-1 < idxFile)};  // ������ ��� �� Row �ϳ��� ������ ����
end;



//==============================================================================
end.
//==============================================================================
