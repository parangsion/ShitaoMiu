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
  C_GRIDCOLIDX_SMING      = 3; //--------- 반복시 여기부터...
  C_GRIDCOLIDX_SID        = 4;
  C_GRIDCOLIDX_FILENAME   = 5;
  C_GRIDCOLIDX_BTNINSERT  = 6;
  C_GRIDCOLIDX_BTNDELETE  = 7;



type
  //----------------------------------------------------------------------------
  // 1 sming(노래 1 곡)
  RSONG = record
    sSongName   : String;
    sSID        : String;
    aFileList   : TCommStringArray;   // 1 노래의 짤 목록   Key: sort key, Value:File name
  end;
  RSONGARRAY = RCommArray<RSONG>;

  //----------------------------------------------------------------------------
  // 1 게시물
  RPOST = record
    sDateTime     : String;
    sGallName     : String;
    sTitle        : String;
    aSongList     : RSONGARRAY;    // 1 게시물에 써지는 노래 리스트. 보통 1곡이 대부분이지만, 가끔 2~3곡이 동시에 게시되는 경우가 있음
  end;
  //----------------------------------------------------------------------------
  RPOSTARRAY = RCommArray<RPOST>;


  //----------------------------------------------------------------------------
  // 1 게시물
  RITERATOR = record
    idxPost   : Integer;
    idxSong   : Integer;    // 초기 playlist 을 loading하면 Song 까지는 setting ehls다.
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
  Result := (-1 < idxPost) and (-1 < idxSong) {and (-1 < idxFile)};  // 파일이 없어도 빈 Row 하나는 가지고 있음
end;



//==============================================================================
end.
//==============================================================================
