{
Copyright (C) 2002-2020  Massimo Melina (www.rejetto.com)

This file is part of HFS ~ HTTP File Server.

    HFS is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    HFS is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with HFS; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
{$INCLUDE defs.inc }

unit utilLib;
{$I NoRTTI.inc}

interface

uses
  types, Windows, graphics, dialogs, registry, classes, dateUtils,
  comCtrls, shlobj, shellapi, activex, comobj, forms, stdctrls, controls, psAPI,
  menus, math, iniFiles, richedit, sysutils, strutils,
//  Vcl.Imaging.gifimg,
  Vcl.Imaging.pngImage,
  OverbyteIcsWSocket, OverbyteIcshttpProt,
  regexpr,
  longinputDlg,
  main, hslib,
  classesLib, fileLib, hfsGlobal;

const
  ILLEGAL_FILE_CHARS = [#0..#31,'/','\',':','?','*','"','<','>','|'];
  DOW2STR: array [1..7] of string=( 'Sun','Mon','Tue','Wed','Thu','Fri','Sat' );
  MONTH2STR: array [1..12] of string = ( 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec' );
  PTR1: Tobject = ptr(1);
var
  GMToffset: integer; // in minutes
  inputQueryLongdlg: TlonginputFrm;
  winVersion: (WV_LOWER, WV_2000, WV_VISTA, WV_SEVEN, WV_HIGHER);
type
  TreCB = procedure(re:TregExpr; var res:string; data:pointer);
  PstringDynArray = ^TstringDynArray;
  TnameExistsFun = function(user:string):boolean;
type
  TaccountRecursionStopCase = (ARSC_REDIR, ARSC_NOLIMITS, ARSC_IN_SET);

procedure doNothing(); inline; // useful for readability
function httpsCanWork():boolean;
function accountExists(user:string; evenGroups:boolean=FALSE):boolean;
function getAccount(user:string; evenGroups:boolean=FALSE):Paccount;
function accountRecursion(account:Paccount; stopCase:TaccountRecursionStopCase; data:pointer=NIL; data2:pointer=NIL):Paccount;
function findEnabledLinkedAccount(account:Paccount; over:TStringDynArray; isSorted:boolean=FALSE):Paccount;
procedure fixFontFor(frm:Tform);
function hostFromURL(s:string):string;
function hostToIP(name: string):string;
function allocatedMemory():int64;
{$IFDEF MSWINDOWS}
function currentStackUsage: NativeUInt;
{$ENDIF MSWINDOWS}
{$IFDEF HFS_GIF_IMAGES}
function stringToGif(s: RawByteString; gif:TgifImage=NIL):TgifImage;
function gif2str(gif:TgifImage): RawByteString;
{$ELSE ~HFS_GIF_IMAGES}
function stringToPNG(s: RawByteString; png: TpngImage=NIL):TpngImage;
function png2str(png:TPngImage): RawByteString;
{$ENDIF HFS_GIF_IMAGES}
function bmp2str(bmp:Tbitmap): RawByteString;
function pic2str(idx:integer): RawByteString;
function str2pic(s: RawByteString):integer;
function getImageIndexForFile(fn:string):integer;
function maybeUnixTime(t:Tdatetime):Tdatetime;
function filetimeToDatetime(ft:TFileTime):Tdatetime;
function localToGMT(d:Tdatetime):Tdatetime;
function onlyExistentAccounts(a:TstringDynArray):TstringDynArray;
procedure onlyForExperts(controls:array of Tcontrol);
function createAccountOnTheFly():Paccount;
function newMenuSeparator(lbl:string=''):Tmenuitem;
function accountIcon(isEnabled, isGroup:boolean):integer; overload;
function accountIcon(a:Paccount):integer; overload;
function evalFormula(s:string):real;
function boolOnce(var b:boolean):boolean;
procedure drawCentered(cnv:Tcanvas; r:Trect; text:string);
function minmax(min, max, v:integer):integer;
function isLocalIP(const ip:string):boolean;
function clearAndReturn(var v:string):string;
function swapMem(var src,dest; count:dword; cond:boolean=TRUE):boolean;
function pid2file(pid: cardinal):string;
function port2pid(const port:string):integer;
function holdingKey(key:integer):boolean;
function blend(from,to_:Tcolor; perc:real):Tcolor;
function isNT():boolean;
function setClip(const s:string):boolean;
function eos(s:Tstream):boolean;
function safeDiv(a,b:real; default:real=0):real; overload;
function safeDiv(a,b:int64; default:int64=0):int64; overload;
function safeMod(a,b:int64; default:int64=0):int64;
function smartsize(size:int64):string;
function httpGetStr(url:string; from:int64=0; size:int64=-1):string;
function httpGet(const url:string; from:int64=0; size:int64=-1): RawByteString;
function httpGetFile(url, filename:string; tryTimes:integer=1; notify:TdocDataEvent=NIL):boolean;
function httpFileSize(url:string):int64;
function getIPs():TStringDynArray;
function getPossibleAddresses():TstringDynArray;
function whatStatusPanel(statusbar:Tstatusbar; x:integer):integer;
function getExternalAddress(var res:string; provider:Pstring=NIL):boolean;
function checkAddressSyntax(address:string; mask:boolean=TRUE):boolean;
function inputQueryLong(const caption, msg:string; var value:string; ofs:integer=0):boolean;
procedure purgeVFSaccounts();
function accountAllowed(action:TfileAction; cd:TconnDataMain; f:Tfile):boolean;
function exec(cmd:string; pars:string=''; showCmd:integer=SW_SHOW):boolean;
function execNew(cmd:string):boolean;
function captureExec(const DosApp: string; out output:string; out exitcode:cardinal; timeout:real=0):boolean;
function openURL(const url: string):boolean;
function getRes(name:pchar; const typ:string='TEXT'): RawByteString;
//function bmpToHico(bitmap:Tbitmap):hicon;
function compare_(i1,i2:double):integer; overload;
function compare_(i1,i2:int64):integer; overload;
function compare_(i1,i2:integer):integer; overload;
function msgDlg(msg:string; code:integer=0; title:string=''):integer;
function if_(v:boolean; const v1:string; const v2:string=''):string; overload; inline;
function if_(v: Boolean; const v1: RawByteString; const v2: RawByteString = ''): RawByteString;overload; inline;
function if_(v:boolean; v1:int64; v2:int64=0):int64; overload; inline;
function if_(v:boolean; v1:integer; v2:integer=0):integer; overload; inline;
function if_(v:boolean; v1:Tobject; v2:Tobject=NIL):Tobject; overload; inline;
function if_(v:boolean; v1:boolean; v2:boolean=FALSE):boolean; overload; inline;
// file
function getEtag(const filename:string):string;
function getDrive(fn:string):string;
function diskSpaceAt(path:string):int64;
function deltree(path:string):boolean;
function newMtime(fn:string; var previous:Tdatetime):boolean;
function dirCrossing(s:string):boolean;
function forceDirectory(path:string):boolean;
function moveToBin(fn:string; force:boolean=FALSE):boolean; overload;
function moveToBin(files:TstringDynArray; force:boolean=FALSE):boolean; overload;
function uri2disk(url:string; parent:Tfile=NIL; resolveLnk:boolean=TRUE):string;
function uri2diskMaybe(path:string; parent:Tfile=NIL; resolveLnk:boolean=TRUE):string;
function freeIfTemp(var f:Tfile):boolean; inline;
function isAbsolutePath(path:string):boolean;
function getTempDir():string;
function createShellLink(linkFN:WideString; destFN:string):boolean;
function readShellLink(linkFN:WideString):string;
function getShellFolder(const id: String): String;
function getTempFilename():string;
function saveTempFile(data:string):string;
function fileOrDirExists(fn:string):boolean;
function sizeOfFile(fn:string):int64; overload;
function sizeOfFile(fh:Thandle):int64; overload;
//function loadFile(fn:string; from:int64=0; size:int64=-1):ansistring;  // Use RDFileUtil instead!
function saveFileU(fn:string; data:string; append:boolean=FALSE):boolean; overload;   // Use RDFileUtil instead!
//function saveFile(var f:file; data:string):boolean; overload;    // Use RDFileUtil instead!
function saveFileA(fn:string; data: RawByteString; append:boolean=FALSE): boolean; overload;   // Use RDFileUtil instead!
function saveFileA(var f:file; data:RawByteString): boolean; overload;
function moveFile(src, dst:string; op:UINT=FO_MOVE):boolean;
function copyFile(src, dst:string):boolean;
function resolveLnk(const fn: String): String;
function validFilename(s:string):boolean;
function validFilepath(fn:string; acceptUnits:boolean=TRUE):boolean;
function match(mask, txt:pchar; fullMatch:boolean=TRUE; charsNotWildcard:TcharsetW=[]):integer;
function filematch(mask, fn:string):boolean;
function appendFileU(fn:string; data:string):boolean;
function appendFileA(fn:string; data:RawByteString):boolean;
function getFilename(var f:file):string;
function filenameToDriveByte(fn:string):byte;
function selectFile(var fn:string; title:string=''; filter:string=''; options:TOpenOptions=[]):boolean;
function selectFiles(caption:string; var files:TStringDynArray):boolean;
function selectFolder(const caption: String; var folder:string):boolean;
function selectFileOrFolder(caption:string; var fileOrFolder:string):boolean;
function isExtension(filename, ext:string):boolean;
function getMtimeUTC(filename:string):Tdatetime;
function getMtime(filename:string):Tdatetime;
// registry
function loadregistry(const key, value: String; root: HKEY=0): string;
function saveregistry(const key, value, data: string; root: HKEY=0): boolean;
function deleteRegistry(const key, value: string; root: HKEY=0): boolean; overload;
function deleteRegistry(key: String; root:HKEY=0): boolean; overload;
// strings array
function split(const separator, s:string; nonQuoted:boolean=FALSE):TStringDynArray;
function splitU(const s, separator: RawByteString; nonQuoted:boolean=FALSE):TStringDynArray;
function join(const separator: String; ss:TstringDynArray):string;
function addUniqueString(const s: String; var ss: TStringDynArray): boolean;
function addString(const s: String; var ss: TStringDynArray): integer;
function replaceString(var ss:TStringDynArray; old, new:string):integer;
function popString(var ss:TstringDynArray):string;
procedure insertString(const s: String; idx: integer; var ss: TStringDynArray);
function removeString(var a:TStringDynArray; idx:integer; l:integer=1):boolean; overload;
function removeString(s:string; var a:TStringDynArray; onlyOnce:boolean=TRUE; ci:boolean=TRUE; keepOrder:boolean=TRUE):boolean; overload;
procedure removeStrings(find:string; var a:TStringDynArray);
procedure toggleString(s:string; var ss:TStringDynArray);
function onlyString(const s: String; ss: TStringDynArray): boolean;
function addArray(var dst:TstringDynArray; src:array of string; where:integer=-1; srcOfs:integer=0; srcLn:integer=-1):integer;
function removeArray(var src:TstringDynArray; toRemove:array of string):integer;
function addUniqueArray(var a:TstringDynArray; b:array of string):integer;
procedure uniqueStrings(var a:TstringDynArray; ci:Boolean=TRUE);
function idxOf(s:string; a:array of string; isSorted:boolean=FALSE):integer;
function stringExists(s:string; a:array of string; isSorted:boolean=FALSE):boolean;
function listToArray(l:Tstrings):TstringDynArray;
function arrayToList(a:TStringDynArray; list:TstringList=NIL):TstringList;
procedure sortArray(var a:TStringDynArray);
function sortArrayF(const a:TStringDynArray):TStringDynArray;
// convert
function boolToPtr(b:boolean):pointer;
function strToCharset(s:string):TcharsetW;
function ipToInt(ip:string):dword;
function rectToStr(r:Trect):string;
function strToRect(s:string):Trect;
function dt_(s: RawByteString):Tdatetime;
function int_(s: RawByteString):integer;
function str_(i:integer): RawByteString; overload;
function str_(fa:TfileAttributes): RawByteString; overload;
function str_(t:Tdatetime): RawByteString; overload;
function str_(b:boolean): RawByteString; overload;
function strToUInt(s:string): UInt;
function elapsedToStr(t:Tdatetime):string;
function dateToHTTP(gmtTime:Tdatetime):string; overload;
function dateToHTTP(const filename:string):string; overload;
function dateToHTTPr(const filename: string): RawByteString; overload;
function dateToHTTPr(gmtTime: Tdatetime): RawByteString; overload;
function toSA(a:array of string):TstringDynArray; // this is just to have a way to typecast
function stringToColorEx(s:string; default:Tcolor=clNone):Tcolor;
// misc string
procedure excludeTrailingString(var s:string; ss:string);
function findEOL(s:string; ofs:integer=1; included:boolean=TRUE):integer;
function getUniqueName(const start:string; exists:TnameExistsFun):string;
function getStr(from,to_: pAnsichar): RawByteString; OverLoad;
function getStr(from,to_: pchar): String; OverLoad;
function TLV(t:integer; const data: RawByteString): RawByteString;
function TLVS(t:integer; const data: String): RawByteString;
function TLV_NOT_EMPTY(t:integer; const data: RawByteString): RawByteString;
function TLVS_NOT_EMPTY(t:integer; const data: String): RawByteString;
function popTLV(var s,data: RawByteString):integer;
function getCRC(const data: RawByteString):integer;
function dotted(i:int64):string;
function xtpl(src:string; table:array of string):string; OverLoad;
function xtpl(src: RawByteString; table:array of RawByteString): RawByteString; OverLoad;
function validUsername(s:string; acceptEmpty:boolean=FALSE):boolean;
function anycharIn(chars, s:string):boolean; overload;
function anycharIn(chars:TcharsetW; s:string):boolean; overload;
function int0(i,digits:integer):string;
function addressmatch(mask, address:string):boolean;
function getTill(const ss, s:string; included:boolean=FALSE):string; overload;
function getTill(i:integer; const s:string):string; overload;
function getTill(const ss, s: RawByteString; included:boolean=FALSE): RawByteString; OverLoad;
function getTill(i:integer; const s: RawByteString): RawByteString; OverLoad;
function singleLine(s:string):boolean;
function poss(chars:TcharSetW; s:string; ofs:integer=1):integer;
//function optUTF8(bool:boolean; s:string):string; overload;
//function optUTF8(tpl:Ttpl; s:string):string; overload;
function optAnsi(bool:boolean; s:string):string;
function utf8Test(const s:string):boolean; OverLoad;
function utf8Test(const s: RawByteString): boolean; OverLoad;
function jsEncode(s, chars:string):string;
function nonEmptyConcat(const pre,s:string; const post:string=''):string;
function first(a,b:integer):integer; overload;
function first(a,b:double):double; overload;
function first(a,b:pointer):pointer; overload;
function first(const a,b:string):string; overload;
function first(a:array of string):string; overload;
function first(a:array of RawByteString): RawByteString; overload;
function stripChars(s:string; cs:TcharsetW; invert:boolean=FALSE):string;
function strAt(const s, ss:string; at:integer):boolean; inline;
function substr(const s: RawByteString; start:integer; upTo:integer=0): RawByteString; inline; OverLoad;
function substr(const s:string; start:integer; upTo:integer=0):string; inline; overload;
function substr(const s:string; const after:string):string; overload;
function reduceSpaces(s:string; const replacement:string=' '; spaces:TcharSetW=[]):string;
function replace(var s:string; const ss:string; start,upTo:integer):integer;
function countSubstr(const ss:string; const s:string):integer;
function trim2(const s:string; chars:TcharsetW):string;
procedure urlToStrings(const s:string; sl:Tstrings); OverLoad;
procedure urlToStrings(const s: RawByteString; sl:Tstrings); OverLoad;
function reCB(const expr, subj:string; cb:TreCB; data:pointer=NIL):string;
function reMatch(const s, exp:string; mods:string='m'; ofs:integer=1; subexp:PstringDynArray=NIL):integer;
function reReplace(subj, exp, repl:string; mods:string='m'):string;
function reGet(const s, exp:string; subexpIdx:integer=1; mods:string='!mi'; ofs:integer=1):string;
function getSectionAt(p:pchar; out name:string):boolean;
function isSectionAt(p:pChar):boolean;
function dequote(const s:string; quoteChars:TcharSetW=['"']):string;
function quoteIfAnyChar(badChars, s:string; const quote:string='"'; const unquote:string='"'):string;
function getKeyFromString(const s:string; key:string; const def:string=''):string;
function setKeyInString(s:string; key:string; val:string=''):string;
function getFirstChar(const s:string):char;
function escapeNL(s:string):string;
function unescapeNL(s:string):string;
function htmlEncode(const s:string):string;
procedure enforceNUL(var s: string); OverLoad;
procedure enforceNUL(var s: RawbyteString); OverLoad;
function bmp2ico32(bitmap: Tbitmap): HICON;
function bmp2ico24(bitmap: Tbitmap): HICON;

function strSHA256(s:string):string;
function strMD5(s:string):string;

function b64utf8(const s:string): RawByteString;
function b64utf8W(const s:string): UnicodeString;
function decodeB64utf8(const s: RawByteString):string; OverLoad;
function decodeB64utf8(const s: String):string; OverLoad;
function decodeB64(const s: String): RawByteString; OverLoad;
function decodeB64(const s: RawByteString): RawByteString; OverLoad;
function b64U(const b: RawByteString): UnicodeString;
function b64R(const b: RawByteString): RawByteString;


implementation

uses
  clipbrd, CommCtrl, //System.Hash,
  AnsiClasses, ansiStrings,
  OverbyteIcsSSLEAY,
  {$IFDEF HAS_FASTMM}
  fastmm4,
  {$ENDIF HAS_FASTMM}
  Base64,
  RDUtils, RDFileUtil, RnQCrypt,
  HFSJclNTFS, hfsJclOthers,
  hfsVars, parserLib, newuserpassDlg, winsock;

var
  ipToInt_cache: ThashedStringList;
  onlyDotsRE: TRegExpr;

// method TregExpr.ReplaceEx does the same thing, but doesn't allow the extra data field (sometimes necessary).
// Moreover, here i use the TfastStringAppend that will give us good performance with many replacements.
function reCB(const expr, subj:string; cb:TreCB; data:pointer=NIL):string;
var
  r: string;
  last: integer;
  re: TRegExpr;
  s: TfastStringAppend;
begin
re:=TRegExpr.create;
s:=TfastStringAppend.create;
try
  re.modifierI:=TRUE;
  re.ModifierS:=FALSE;
  re.expression:=expr;
  re.compile();
  last:=1;
  if re.exec(subj) then
    repeat
    r:=re.match[0];
    cb(re, r, data);
    if re.MatchPos[0] > 1 then
      s.append(substr(subj, last, re.matchPos[0]-1)); // we must IF because 0 is the end of string for substr()
    s.append(r);
    last:=re.matchPos[0]+re.matchLen[0];
    until not re.execNext();
  s.append(substr(subj, last));
  result:=s.get();
finally
  re.free;
  s.free;
  end
end; // reCB

// this is meant to detect junctions, symbolic links, volume mount points
function isJunction(path:string):boolean; inline;
var
  attr: DWORD;
begin
attr:=getFileAttributes(PChar(path));
// don't you dare to convert the <>0 in a boolean typecast! my TurboDelphi (2006) generates the wrong assembly :-(
result:=(attr <> DWORD(-1)) and (attr and FILE_ATTRIBUTE_REPARSE_POINT <> 0)
end;

// the file may not be a junction itself, but we may have a junction at some point in the path
function hasJunction(fn:string):string;
var
  i: integer;
begin
i:=length(fn);
while i > 0 do
  begin
  result:=copy(fn,1,i);
  if isJunction(result) then
    exit;
  while (i > 0) and not (fn[i] in ['\','/']) do dec(i);
  dec(i);
  end;
result:='';
end; // hasJunction

// this is a fixed version of the one contained in JclNTFS.pas
function NtfsGetJunctionPointDestination(const Source: string; var Destination: widestring): Boolean;
var
  Handle: THandle;
  ReparseData: record
    case Boolean of
      False: (Reparse: TReparseDataBuffer;);
      True: (Buffer: array [0..MAXIMUM_REPARSE_DATA_BUFFER_SIZE] of Char;);
    end;
  BytesReturned: DWORD;
begin
  Result := False;
  if not NtfsFileHasReparsePoint(Source) then
    exit;
  handle := CreateFile(PChar(Source), GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OPEN_REPARSE_POINT, 0);
  if handle = INVALID_HANDLE_VALUE then exit;
  try
    BytesReturned := 0;
    if not DeviceIoControl(Handle, FSCTL_GET_REPARSE_POINT, nil, 0, @ReparseData, MAXIMUM_REPARSE_DATA_BUFFER_SIZE, BytesReturned, nil) then
      exit;
    if BytesReturned < DWORD(ReparseData.Reparse.SymbolicLinkReparseBuffer.SubstituteNameLength + SizeOf(WideChar)) then
      exit;
    SetLength(Destination, (ReparseData.Reparse.SymbolicLinkReparseBuffer.SubstituteNameLength div SizeOf(WideChar)));
    Move(ReparseData.Reparse.SymbolicLinkReparseBuffer.PathBuffer[0], Destination[1], ReparseData.Reparse.SymbolicLinkReparseBuffer.SubstituteNameLength);
    Result := True;
   finally
    CloseHandle(Handle)
  end
end; // NtfsGetJunctionPointDestination

function getDrive(fn:string):string;
var
  i: integer;
  ws: widestring;
begin
result:=fn;
  repeat
  fn:=hasJunction(result);
  if fn = '' then break;
  if not NtfsGetJunctionPointDestination(fn, ws) then
    break; // at worst we hope the drive is the same
  result:=WideCharToString(@ws[1]);
  // sometimes we get a unicode result
  i:=length(result);
  if (i > 3) and (result[2] = #0) then
    begin
    break;
    result:=wideCharToString(@result[1]);
    setLength(result, i-1);
    end;
  // remove some trailing null chars
  result:=trim(result);
  // we don't like this form, remove useless chars
  if reMatch(result, '^\\\?\?\\.:', '!') > 0 then
    delete(result, 1,4);
  until false;
result:=extractFileDrive(result);
end; // getDrive

function moveToBin(fn:string; force:boolean=FALSE):boolean; overload;
begin result:=moveToBin(toSA(fn), force) end;

function moveToBin(files:TstringDynArray; force:boolean=FALSE):boolean; overload;
var
  fo: TSHFileOpStruct;
  i: integer;
  fn, test, list: string;
begin
result:=FALSE;
// the list is null-separated. A double-null will mark the end of the list, but delphi adds an extra hidden null in every string.
list:='';
try
  for i:=0 to length(files)-1 do
    begin
    fn:=expandFileName(files[i]); // if we don't specify a full path, the bin won't be used, and the file will be just deleted
    test:=fn;
    if (reMatch(fn, '[*?]', '!')>0) then
      test:=ExtractFilePath(test);
    // this system call doesn't work on linked files. Moreover, it hangs the process for a while, so we try to detect them, to abort.
    if not fileOrDirExists(test) or (hasJunction(test) > '') then continue;
    
    list:=list+fn+#0;
    end;

  if list = '' then exit;

  try
    ZeroMemory(@fo, sizeOf(fo));
    fo.wFunc:=FO_DELETE;
    fo.pFrom:=pchar(list);
    fo.fFlags:=FOF_ALLOWUNDO or FOF_NOCONFIRMATION or FOF_NOERRORUI or FOF_SILENT;
    result:=SHFileOperation(fo) = 0;
  except result:=FALSE end;
finally
  if not result and force then
    begin
    // enter the rude
    result:=TRUE;
    for i:=0 to length(files)-1 do
      result:=result and deltree(files[i]);
    end;
  end;
end; // moveToBin

function moveFile(src, dst:string; op:UINT=FO_MOVE):boolean;
var
  fo: TSHFileOpStruct;
begin
  try
    ZeroMemory(@fo, sizeOf(fo));
    fo.wFunc:=op;
    fo.pFrom:=pchar(src+#0);
    fo.pTo:=pchar(dst+#0);
    fo.fFlags:=FOF_ALLOWUNDO + FOF_NOCONFIRMATION + FOF_NOERRORUI + FOF_SILENT + FOF_NOCONFIRMMKDIR;
    result:=SHFileOperation(fo) = 0;
  except result:=FALSE end;
end; // movefile

function copyFile(src, dst:string):boolean;
begin result:=movefile(src, dst, FO_COPY) end;

var
  reTempCache, reFixedCache: THashedStringList;

function reCache(exp:string; mods:string='m'):TregExpr;
const
  CACHE_MAX = 100;
var
  i: integer;
  cache: THashedStringList;
  temporary: boolean;
  key: string;

begin

// this is a temporary cache: older things get deleted. order: first is older, last is newer.
if reTempCache = NIL then
  reTempCache:=THashedStringList.create();
// this is a permanent cache: things are never deleted (while the process is alive)
if reFixedCache = NIL then
  reFixedCache:=THashedStringList.create();

// is it temporary or not?
i:=pos('!', mods);
temporary:= i=0;
Tobject(cache):=if_(temporary, reTempCache, reFixedCache);
delete(mods, i, 1);

// access the cache
key:=mods+#255+exp;
i:=cache.indexOf(key);
if i >= 0 then
  begin
  result:=cache.objects[i] as TregExpr;
  if temporary then
    cache.move(i, cache.count-1); // just requested, refresh position
  end
else
  begin
  // cache fault, create new object
  result:=TRegExpr.Create;
  cache.addObject(key, result);

  if temporary and (cache.count > CACHE_MAX) then
    // delete older ones
    for i:=1 to CACHE_MAX div 10 do
      try
        cache.objects[0].free;
        cache.delete(0);
      except end;

  result.modifierS:=FALSE;
  result.modifierStr:=mods;
  result.expression:=exp;
  result.compile();
  end;

end;//reCache

function reMatch(const s, exp:string; mods:string='m'; ofs:integer=1; subexp:PstringDynArray=NIL):integer;
var
  i: integer;
  re: TRegExpr;
begin
result:=0;
re:=reCache(exp,mods);
if assigned(subexp) then
  subexp^:=NIL;
// do the job
try
  re.inputString:=s;
  if not re.execPos(ofs) then exit;
  result:=re.matchPos[0];
  if subexp = NIL then exit;
  i:=re.subExprMatchCount;
  setLength(subexp^, i+1); // it does include also the whole match, with index zero
  for i:=0 to i do
    subexp^[i]:=re.match[i]
except end;
end; // reMatch

function reGet(const s, exp:string; subexpIdx:integer=1; mods:string='!mi'; ofs:integer=1):string;
var
  se: TstringDynArray;
begin
if reMatch(s, exp, mods, ofs, @se) > 0 then
  result:=se[subexpIdx]
else
  result:='';
end; // reGet

function reReplace(subj, exp, repl:string; mods:string='m'):string;
var
  re: TRegExpr;
begin
re:=reCache(exp,mods);
result:=re.replace(subj, repl, TRUE);
end; // reReplace

// converts from integer to string[4]
function str_(i:integer): RawByteString; overload;
begin
  setlength(result, 4 div sizeOf(AnsiChar));
  move(i, result[1], 4 div sizeOf(AnsiChar));
end; // str_

// converts from boolean to string[1]
function str_(b:boolean):RawByteString; overload;
begin result:= Ansichar(b) end;

// converts from TfileAttributes to string[4]
function str_(fa:TfileAttributes): RawByteString; overload;
begin result:=str_(integer(fa)) end;

// converts from Tdatetime to string[8]
function str_(t:Tdatetime): RawByteString; overload;
begin
  setlength(result, 8 div sizeOf(AnsiChar));
  move(t, result[1], 8 div sizeOf(AnsiChar));
end; // str_

// converts from string[4] to integer
function int_(s: RawByteString):integer;
var
  s1: String[4];
begin
  s1 := s;
  result:=Pinteger(@s1[1])^
end;

// converts from string[8] to datetime
function dt_(s: RawByteString):Tdatetime;
begin result:=Pdatetime(@s[1])^ end;

function strToUInt(s:string): UInt;
begin
s:=trim(s);
if s='' then result:=0
else result:= SysUtils.StrToUInt(s);
if result < 0 then
  raise Exception.Create('strToUInt: Signed value not accepted');
end; // strToUInt

function split(const separator, s:string; nonQuoted:boolean=FALSE):TStringDynArray;
var
  i, j, n, l: integer;
begin
l:=length(s);
result:=NIL;
if l = 0 then exit;
i:=1;
n:=0;
  repeat
  if length(result) = n then
    setLength(result, n+50);
  if nonQuoted then
    j:=nonQuotedPos(separator, s, i)
  else
    j:=posEx(separator, s, i);
  if j = 0 then
    j:=l+1;
  if i < j then
    result[n]:=substr(s, i, j-1);
  i:=j+length(separator);
  inc(n);
  until j > l;
setLength(result, n);
end; // split

function splitU(const s, separator: RawByteString; nonQuoted:boolean=FALSE):TStringDynArray;
var
  i, j, n, l: integer;
begin
l:=length(s);
result:=NIL;
if l = 0 then exit;
i:=1;
n:=0;
  repeat
  if length(result) = n then
    setLength(result, n+50);
  if nonQuoted then
    j:=nonQuotedPos(separator, s, i)
  else
    j:=posEx(separator, s, i);
  if j = 0 then
    j:=l+1;
  if i < j then
    result[n]:= UnUTF(substr(s, i, j-1));
  i:=j+length(separator);
  inc(n);
  until j > l;
setLength(result, n);
end; // splitU

function join(const separator: String; ss:TstringDynArray):string;
var
  i:integer;
begin
result:='';
if length(ss) = 0 then exit;
result:=ss[0];
for i:=1 to length(ss)-1 do
  result:=result+separator+ss[i];
end; // join

procedure toggleString(s:string; var ss:TStringDynArray);
var
  i: integer;
begin
i:=idxOf(s, ss);
if i < 0 then addString(s, ss)
else removeString(ss, i);
end; // toggleString

procedure uniqueStrings(var a:TstringDynArray; ci:Boolean=TRUE);
var
  i, j: integer;
begin
for i:=length(a)-1 downto 1 do
  for j:=i-1 downto 0 do
    if ci and SameText(a[i], a[j])
    or not ci and (a[i] = a[j]) then
      begin
      removeString(a, i);
      break;
      end;
end; // uniqueStrings

// remove all instances of the specified string
procedure removeStrings(find:string; var a:TStringDynArray);
var
  i, l: integer;
begin
  repeat
  i:=idxOf(find,a);
  if i < 0 then break;
  l:=1;
  while (i+l < length(a)) and (ansiCompareText(a[i+l], find) = 0) do inc(l);
  removeString(a, i, l);
  until false;
end; // removeStrings

function removeArray(var src:TstringDynArray; toRemove:array of string):integer;
var
  i, l, ofs: integer;
  b: boolean;
begin
l:=length(src);
i:=0;
ofs:=0;
while i+ofs < l do
  begin
  b:=stringExists(src[i+ofs], toRemove);
  if b then inc(ofs);
  if i+ofs > l then break;
  if ofs > 0 then src[i]:=src[i+ofs];
  if not b then inc(i);
  end;
setLength(src, l-ofs);
result:=ofs;
end; // removeArray

function popString(var ss:TstringDynArray):string;
begin
result:='';
if ss = NIL then exit;
result:=ss[0];
removeString(ss, 0);
end; // popString

function addString(const s: String; var ss: TStringDynArray): integer;
begin
result:=length(ss);
addArray(ss, [s], result)
end; // addString

function replaceString(var ss:TStringDynArray; old, new:string):integer;
var
  i: integer;
begin
result:=0;
  repeat
  i:=idxOf(old, ss);
  if i < 0 then exit;
  inc(result);
  ss[i]:=new;
  until false;
end; // replaceString

function onlyString(const s: String; ss: TStringDynArray): boolean;
// we are case insensitive, just like other functions in this set
begin result:=(length(ss) = 1) and sameText(ss[0], s) end;

function addUniqueString(const s: String; var ss: TStringDynArray): boolean;
begin
result:=idxof(s, ss) < 0;
if result then addString(s, ss)
end; // addUniqueString

procedure insertstring(const s: String; idx: Integer; var ss: TStringDynArray);
begin addArray(ss, [s], idx) end;

function removestring(var a:TStringDynArray; idx:integer; l:integer=1):boolean;
begin
result:=FALSE;
if (idx<0) or (idx >= length(a)) then exit;
result:=TRUE;
while idx+l < length(a) do
  begin
  a[idx]:=a[idx+l];
  inc(idx);
  end;
setLength(a, idx);
end; // removestring

function removeString(s:string; var a:TStringDynArray; onlyOnce:boolean=TRUE; ci:boolean=TRUE; keepOrder:boolean=TRUE):boolean; overload;
var i, lessen:integer;
begin
result:=FALSE;
if a = NIL then
  exit;
lessen:=0;
try
  for i:=length(a)-1 to 0 do
    if ci and sameText(a[i], s)
    or not ci and (a[i]=s) then
      begin
      result:=TRUE;
      if keepOrder then
        removeString(a, i)
      else
        begin
        inc(lessen);
        a[i]:=a[length(a)-lessen];
        end;
      if onlyOnce then
        exit;
      end;
finally
  if lessen > 0 then
    setLength(a, length(a)-lessen);
  end;
end;

function dotted(i:int64):string;
begin
result:=intToStr(i);
i:=length(result)-2;
while i > 1 do
  begin
  insert(FormatSettings.ThousandSeparator, result, i);
  dec(i,3);
  end;
end; // dotted

function getRes(name:pchar; const typ:string='TEXT'): RawByteString;
var
  h1, h2: Thandle;
  p: pByte;
  l: integer;
  ansi: RawByteString;
begin
  result:='';
  h1:=FindResource(HInstance, name, pchar(typ));
  h2:=LoadResource(HInstance, h1);
  if h2=0 then
    exit;
  l:=SizeOfResource(HInstance, h1);
  p := LockResource(h2);
  setLength(ansi, l);
  move(p^, ansi[1], l);
  UnlockResource(h2);
  FreeResource(h2);
  result := ansi;
end; // getRes

function compare_(i1,i2:int64):integer; overload;
begin
  if i1 < i2 then
    result:=-1
   else
    if i1 > i2 then
      result:=1
     else
      result:=0
end; // compare_

function compare_(i1,i2:integer):integer; overload;
begin
if i1 < i2 then result:=-1 else
if i1 > i2 then result:=1 else
  result:=0
end; // compare_

function compare_(i1,i2:double):integer; overload;
begin
if i1 < i2 then result:=-1 else
if i1 > i2 then result:=1 else
  result:=0
end; // compare_

function rectToStr(r:Trect):string;
begin result:=format('%d,%d,%d,%d',[r.left,r.top,r.right,r.bottom]) end;

function strToRect(s:string):Trect;
begin
result.Left:=strToInt(chop(',',s));
result.Top:=strToInt(chop(',',s));
result.right:=strToInt(chop(',',s));
result.bottom:=strToInt(chop(',',s));
end; // strToRect

function TLV(t:integer; const data: RawByteString): RawByteString;
begin result:=str_(t)+str_(length(data))+data end;

function TLVS(t:integer; const data: String): RawByteString;
begin result:=TLV(t, StrToUTF8(data)) end;


function TLV_NOT_EMPTY(t:integer; const data: RawByteString): RawByteString;
begin if data > '' then result:=TLV(t,data) else result:='' end;

function TLVS_NOT_EMPTY(t:integer; const data: String): RawByteString;
begin if data > '' then result:=TLV(t, StrToUTF8(data)) else result:='' end;

// for heavy jobs you are supposed to use class Ttlv
function popTLV(var s,data: RawByteString):integer;
begin
result:=-1;
if length(s) < 8 then exit;
result:=integer((@s[1])^);
data:=copy(s,9,Pinteger(@s[5])^);
delete(s,1,8+length(data));
end; // popTLV

function getCRC(const data: RawByteString):integer;
var
  i:integer;
  p:Pinteger;
begin
result:=0;
p:=@data[1];
for i:=1 to length(data) div 4 do
  begin
  inc(result, p^);
  inc(p);
  end;
end; // crc

function msgDlg(msg:string; code:integer=0; title:string=''):integer;
var
  parent: Thandle;
begin
result:=0;
if msg='' then exit;
if code = 0 then code:=MB_OK+MB_ICONINFORMATION;
if screen.ActiveCustomForm = NIL then parent:=0
else parent:=screen.ActiveCustomForm.handle;
application.restore();
application.BringToFront();
title:=application.Title+nonEmptyConcat(' -- ', title);
result:=messageBox(parent, pchar(msg), pchar(title), code)
end; // msgDlg

function idxOf(s:string; a:array of string; isSorted:boolean=FALSE):integer;
var
  r, b, e: integer;
begin
if not isSorted then
  begin
  result:=ansiIndexText(s,a);
  exit;
  end;
// a classic one... :-P
b:=0;
e:=length(a)-1;
while b <= e do
  begin
  result:=(b+e) div 2;
  r:=ansiCompareText(s, a[result]);
  if r = 0 then exit;
  if r < 0 then e:=result-1
  else b:=result+1;
  end;
result:=-1;
end;

function stringExists(s:string; a:array of string; isSorted:boolean=FALSE):boolean;
begin result:= idxOf(s,a, isSorted) >= 0 end;

function validUsername(s:string; acceptEmpty:boolean=FALSE):boolean;
begin
result:=(s = '') and acceptEmpty
  or (s > '') and not anycharIn('/\:?*"<>|;&',s) and (length(s) <= 40)
  and not anyMacroMarkerIn(s) // mod by mars
end;

function validFilename(s:string):boolean;
begin
result:=(s>'')
  and not dirCrossing(s)
  and not anycharIn(ILLEGAL_FILE_CHARS,s)
end;

function validFilepath(fn:string; acceptUnits:boolean=TRUE):boolean;
var
  withUnit: boolean;
begin
withUnit:=(length(fn) > 2) and (upcase(fn[1]) in ['A'..'Z']) and (fn[2] = ':');

result:=(fn > '')
  and (posEx(':', fn, if_(withUnit,3,1)) = 0)
  and (poss([#0..#31,'?','*','"','<','>','|'], fn) = 0)
  and (length(fn) <= 255+if_(withUnit, 2));
end;
{
function loadFile(fn:string; from:int64=0; size:int64=-1):ansistring;
var
  f:file;
  bak: byte;
begin
result:='';
IOresult;
if not validFilepath(fn) then exit;
if not isAbsolutePath(fn) then chDir(exePath);
assignFile(f, fn);
bak:=fileMode;
fileMode:=0;
try
  reset(f,1);
  if IOresult <> 0 then exit;
  seek(f, from);
  if size < 0 then
    size:=filesize(f)-from;
  setLength(result, size);
  blockRead(f, result[1], size);
  closeFile(f);
finally
  filemode:=bak;
  end;
end; // loadFile
}
function saveFileA(var f:file; data: RawByteString):boolean; overload;
begin
  blockWrite(f, data[1], length(data));
  result:=IOresult=0;
end;

function forceDirectory(path:string):boolean;
var
  s: string;
begin
result:=TRUE;
path:=excludeTrailingPathDelimiter(path);
if path = '' then exit;
if directoryExists(path) then exit;
s:=extractFilePath(path);
if s = path then exit; // we are at the top, going nowhere
forceDirectory(s);
result:=createDir(path);
end; // forceDirectory


function saveFileU(fn:string; data:string; append:boolean=FALSE):boolean;
var
  f: file;
  path, temp: string;
begin
result:=FALSE;
try
  if not validFilepath(fn) then exit;
  if not isAbsolutePath(fn) then chDir(exePath);
  path:=extractFilePath(fn);
  if (path > '') and not forceDirectory(path) then exit;
  IOresult();
  if append then
    begin
    assignFile(f, fn);
    reset(f,1);
    if IOresult() <> 0 then rewrite(f,1)
    else seek(f,fileSize(f));
    end
  else
    begin
    // in this case, we save to a temp file, and overwrite the previous one (if it exists) only after the saving is complete
    temp:=format('%s~%d.tmp', [fn, random(MAXINT)]);
    if not validFilepath(temp) then // fn may be too long to append something
      temp:=format('hfs~%d.tmp', [fn, random(999)]);
    assignFile(f, temp);
    rewrite(f,1)
    end;

  if IOresult() <> 0 then exit;
  if not saveFileA(f, UTF8Encode(data)) then exit;
  closeFile(f);
  if not append then
    begin
    deleteFile(fn); // this may fail if the file didn't exist already
    renameFile(temp, fn);
    end;
  result:=TRUE;
except end;
end; // saveFile

function saveFileA(fn: string; data: RawByteString; append:boolean=FALSE):boolean; overload;
var
  f: file;
  path, temp: string;
begin
result:=FALSE;
try
  if not validFilepath(fn) then
    exit;
  if not isAbsolutePath(fn) then
    chDir(exePath);
  path := extractFilePath(fn);
  if (path > '') and not forceDirectory(path) then
    exit;
  IOresult();
  if append then
    begin
      assignFile(f, fn);
      reset(f,1);
      if IOresult() <> 0 then
        rewrite(f,1)
       else
        seek(f, fileSize(f));
    end
  else
    begin
    // in this case, we save to a temp file, and overwrite the previous one (if it exists) only after the saving is complete
      temp := format('%s~%d.tmp', [fn, random(MAXINT)]);
      if not validFilepath(temp) then // fn may be too long to append something
        temp := format('hfs~%d.tmp', [fn, random(999)]);
      assignFile(f, temp);
      rewrite(f,1)
    end;

  if IOresult() <> 0 then
    exit;
  if not saveFileA(f, data) then
    exit;
  closeFile(f);
  if not append then
    begin
    deleteFile(fn); // this may fail if the file didn't exist already
    renameFile(temp, fn);
    end;
  result:=TRUE;
except end;
end; // saveFile

function appendFileU(fn:string; data:string):boolean;
begin result:=saveFileU(fn, data, TRUE) end;

function appendFileA(fn:string; data: RawByteString):boolean;
begin
  result := saveFileA(fn, data, TRUE)
end;

function getTempFilename():string;
var
  path: string;
begin
  setLength(path, 1000);
  setLength(path, getTempPath(length(path), @path[1]));
  setLength(result, 1000);
  if Windows.getTempFileName(pchar(path), 'hfs.', 0, @result[1]) = 0 then
    result := ''
   else
    setLength(result, StrLen(PChar(@result[1])));
end; // getTempFilename

function saveTempFile(data:string):string;
begin
  result:=getTempFilename();
  if result > '' then
    saveFile2(result, UTF8ToStr(data));
end; // saveTempFile

function loadregistry(const key, value: String; root: HKEY=0): string;
begin
result:='';
with Tregistry.create do
  try
    try
      if root > 0 then rootKey:=root;
      if openKey(key, FALSE) then
        begin
        result:=readString(value);
        closeKey();
        end;
    finally free end
  except end
  end; // loadregistry

function saveregistry(const key,value,data:string; root:HKEY=0):boolean;
begin
result:=FALSE;
with Tregistry.create do
  try
    if root > 0 then rootKey:=root;
    try
      createKey(key);
      if openKey(key, FALSE) then
        begin
        WriteString(value,data);
        closeKey;
        result:=TRUE;
        end;
    finally free end
  except end;
end; // saveregistry

function deleteRegistry(const key,value:string; root:HKEY=0):boolean; overload;
var
  reg:Tregistry;
begin
reg:=Tregistry.create;
if root > 0 then reg.RootKey:=root;
result:=reg.OpenKey(key,FALSE) and reg.DeleteValue(value);
reg.free
end; // deleteRegistry

function deleteRegistry(key: String; root: HKEY=0): boolean; overload;
var
  reg:Tregistry;
  ss:TstringList;
  i:integer;
  deleteIt:boolean;
begin
reg:=Tregistry.create;
if root > 0 then reg.RootKey:=root;
result:=reg.DeleteKey(key);
// delete also parent keys, if empty
ss:=Tstringlist.create;
while key>'' do
  begin
  i:=LastDelimiter('\',key);
  if i=0 then break;
  setlength(key, i-1);
  if not reg.OpenKeyReadOnly(key) then break;
  reg.GetValueNames(ss);
  deleteIt:=(ss.count=0) and not reg.HasSubKeys;
  reg.CloseKey;
  if deleteit then reg.deleteKey(key)
  else break;
  end;
ss.free;
reg.free
end; // deleteRegistry

function resolveLnk(const fn: String): String;
Var
  sl: IShellLink;
  buffer: array [0..MAX_PATH] of char;
  fd: Twin32finddata;
begin
result:=fn;
  try
    olecheck(coCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IShellLink, sl));
    olecheck((sl as IPersistFile).load(pwidechar(widestring(fn)), STGM_READ));
    olecheck(sl.resolve(0, SLR_ANY_MATCH or SLR_NO_UI));
    olecheck(sl.getPath(Buffer, MAX_PATH, fd, 0));
    result:=buffer;
  except // convertion failed, but keep original filename
  end;
end; // resolveLnk

function anycharIn(chars:TcharsetW; s:string):boolean;
begin result:=poss(chars, s) > 0 end;

function anycharIn(chars, s:string):boolean;
begin result:=anyCharIn(strToCharset(chars), s) end;

function exec(cmd:string; pars:string=''; showCmd:integer=SW_SHOW):boolean;
const
  MAX_PARS = 9;
var
  pars0: string;
  i, o: integer;
  poss: array [1..MAX_PARS] of TintegerDynArray; // positions where we found the Nth parameter, in the %N form, for later substitution
  a: TintegerDynArray;
  parsA: TStringDynArray; // splitted version of pars
begin
result:=FALSE;
cmd:=trim(cmd);
if (cmd = '') or (dequote(cmd) = '') then exit;

i:=nonQuotedPos(' ', cmd);
if (cmd > '') and (cmd[1] <> '"') and (extractFileExt(cmd) > '') and (extractFileExt(substr(cmd, 0, i)) = '') then
  pars0:=''
else
  begin
  // the cmd sometimes contains parameters, because loaded from registry
  pars0:=cmd;
  // split such parameters from the real cmd
  cmd:=chop(i, pars0);
  // if pars0 contains %1, it must be replaced with the first parameter contained 'pars'.
  // Sadly we can't just replace, because 'pars' may contain %DIGIT strings (that must not be replaced). So we collect positions first, then make substitutions.
  for i:=1 to MAX_PARS do
    begin
    a:=NIL;
    o:=0;
      repeat
      o:=posEx('%'+intToStr(i), pars0, o+1);
      if o = 0 then break;
      setLength(a, length(a)+1);
      a[length(a)-1]:=o;
      until false;
    poss[i]:=a;
    end;

  parsA:=split(' ', pars, TRUE);
  // now do all the collected replacements
  for i:=1 to MAX_PARS do
    begin
    for o:=0 to length(poss[i])-1 do
      replace(pars0, parsA[i-1], poss[i][o], 1+poss[i][o]);
    if length(poss[i]) > 0 then
      removeString(parsA, i-1);
    end;
  // ok, now we have the final version of parameters
  pars:=pars0+nonEmptyConcat(' ', join(' ',parsA));
  end;
// go
result:=(cmd > '') and (32 < shellexecute(0, 'open', pchar(cmd), pchar(pars), NIL, showCmd))
end;

// exec but does not wait for the process to end
function execNew(cmd:string):boolean;
begin
result:=32 < ShellExecute(0, nil, 'cmd.exe', pchar('/C '+cmd), nil, SW_SHOW);
end; // execNew

function execNew2(cmd:string):boolean;
var
  si: TStartupInfo;
  pi: TProcessInformation;
begin
  ZeroMemory(@si, sizeOf(si));
  ZeroMemory(@pi, sizeOf(pi));
  si.cb:=sizeOf(si);
  result:=createProcess(NIL,pchar(cmd),NIL,NIL,FALSE,0,NIL,NIL,si,pi)
end; // execNew

function addArray(var dst:TstringDynArray; src:array of string; where:integer=-1; srcOfs:integer=0; srcLn:integer=-1):integer;
var
  i, l:integer;
begin
l:=length(dst);
if where < 0 then // this means: at the end of it
  where:=l;
if srcLn < 0 then
  srcLn:=length(src);
setLength(dst, l+srcLn); // enlarge your array!

i:=max(l, where+srcLn);
while i > l do // we are over newly allocated memory, just copy
  begin
  dec(i);
  dst[i]:=src[i-where+srcOfs];
  end;
while i > where+srcLn do  // we're over the existing data, just shift
  begin
  dec(i);
  dst[i+srcLn]:=dst[i];
  end;
while i > where do // we'are in middle-earth, both shift and copy
  begin
  dec(i);
  dst[i+srcLn]:=dst[i];
  dst[i]:=src[i-where+srcOfs];
  end;
result:=l+srcLn;
end; // addArray

function addUniqueArray(var a:TstringDynArray; b:array of string):integer;
var
  i, l, j, n, lb:integer;
  found: boolean;
  bi: string;
begin
l:=length(a);
n:=l; // real/final length of 'a'
lb:=length(b); // cache this value
setlength(a, l+lb);
for i:=0 to lb-1 do
  begin
  bi:=b[i]; // cache this value
  found:=FALSE;
  for j:=0 to n-1 do
    if sameText(a[j], bi) then
      begin
      found:=TRUE;
      break;
      end;
  if found then continue;
  a[n]:=bi;
  inc(n);
  end;
setLength(a, n);
result:=n-l;
end; // addUniqueArray

function if_(v:boolean; v1:boolean; v2:boolean=FALSE):boolean;
begin if v then result:=v1 else result:=v2 end;

function if_(v:boolean; const v1, v2:string):string;
begin if v then result:=v1 else result:=v2 end;

function if_(v: Boolean; const v1, v2: RawByteString): RawByteString;
begin
  if v then
    result := v1
   else
    result := v2
end;

function if_(v:boolean; v1,v2:int64):int64;
begin if v then result:=v1 else result:=v2 end;

function if_(v:boolean; v1, v2:integer):integer;
begin if v then result:=v1 else result:=v2 end;

function if_(v:boolean; v1, v2:Tobject):Tobject;
begin if v then result:=v1 else result:=v2 end;

function match(mask, txt:pchar; fullMatch:boolean; charsNotWildcard:TcharsetW):integer;
// charsNotWildcard is for chars that are not allowed to be matched by wildcards, like CR/LF
var
  i: integer;
begin
result:=0;
// 1 to 1 match
while not (mask^ in [#0,'*'])
and (txt^ <> #0)
and (
  (ansiUpperCase(mask^) = ansiUpperCase(txt^))
  or (upCase(mask^) = upCase(txt^))
  or (mask^ = '?') and not (txt^ in charsNotWildcard)
) do
  begin
  inc(mask);
  inc(txt);
  inc(result);
  end;
if (mask^ = #0) and (not fullMatch or (txt^ = #0)) then
  exit;
if mask^ <> '*' then
  begin
  result:=0;
  exit;
  end;
while mask^ = '*' do inc(mask);
if mask^ = #0 then // final *, anything matches
  begin
  inc(result, strLen(txt));
  exit;
  end;
  repeat
  if txt^ in charsNotWildcard then break;

  if fullMatch and (strpos(mask,'*') = NIL) then
    begin // we just passed last * so we are trying to match the final part of txt. This block is just an optimization. It happens often because of mime types and masks like *.css 
    i:=length(txt)-length(mask);
    if i < 0 then break; // not enough characters left
    // move forward of the minimum part that's required to be covered by the last *
    inc(txt, i);
    inc(result, i);
    i:=match(mask, txt, fullMatch);
    if i = 0 then break; // no more chances
    end
  else
    i:=match(mask, txt, fullMatch);

  if i > 0 then
    begin
    inc(result, i);
    exit;
    end;
  // we're after a *, next part may match at any point, so try it in every way
  inc(txt);
  inc(result);
  until txt^ = #0;
result:=0;
end; // match

function filematch(mask, fn:string):boolean;
var
  invert: integer;
begin
result:=TRUE;
invert:=0;
while (invert < length(mask)) and (mask[invert+1] = '\') do
  inc(invert);
delete(mask,1,invert);
while mask > '' do
  begin
  result:=match( pchar(chop(';',mask)), pchar(fn) ) > 0;
  if result then break;
  end;
result:=result xor odd(invert);
end; // filematch

function checkAddressSyntax(address:string; mask:boolean=TRUE):boolean;
var
  a1, a2: string;
  sf: TSocketFamily;
begin
if not mask then
  exit(WSocketIsIPEx(address, sf));
result:=FALSE;
if address = '' then exit;
while (address > '') and (address[1] = '\') do
  delete(address,1,1);
while address > '' do
  begin
  a2:=chop(';', address);
  if sameText(a2, 'lan') then
    continue;
  a1:=chop('-', a2);
  if a2 > '' then
    if not checkAddressSyntax(a1, FALSE)
    or not checkAddressSyntax(a2, FALSE) then
      exit;
  if reMatch(a1, '^[?*a-f0-9\.:]+$', '!') = 0 then
    exit;
  end;
result:=TRUE;
end; // checkAddressSyntax

function ipv6hex(ip:TIcsIPv6Address):string;
begin
setLength(result, 4*8);
binToHex(@ip.words[0], pchar(result), sizeOf(ip))
end;

function addressMatch(mask, address:string):boolean;
var
  invert: boolean;
  addr4: dword;
  addr6: string;
  bits: integer;
  a: TStringDynArray;

  function ipv6fix(s:string):string;
  var
    ok: boolean;
    r: TIcsIPv6Address;
  begin
  if length(s) = 39 then
    exit(replaceStr(s,':',''));
  r:=wsocketStrToipv6(s, ok);
  if ok then
    exit(ipv6hex(r));
  exit('');
  end;

  function ipv6range():boolean;
  var
    min, max: string;
  begin
  min:=ipv6fix(a[0]);
  if min = ''then
    exit(FALSE);
  max:=ipv6fix(a[1]);
  if max = '' then
    exit(FALSE);
  result:=(min <= addr6) and (max >= addr6)
  end; // ipv6range

begin
result:=FALSE;
invert:=FALSE;
while (mask > '') and (mask[1] = '\') do
  begin
  delete(mask,1,1);
  invert:=not invert;
  end;
addr6:=ipv6fix(address);
addr4:=0;
if addr6 = '' then
  addr4:=ipToInt(address);
for mask in split(';',mask) do
  begin
  if result then
    break;
  if sameText(mask, 'lan') then
    begin
    result:=isLocalIP(address);
    continue;
    end;

  // range?
  a:=split('-', mask);
  if length(a) = 2 then
    begin
    if addr6 > '' then
      result:=ipv6range()
    else
      result:=(pos(':',a[0]) = 0) and (addr4 >= ipToInt(a[0])) and (addr4 <= ipToInt(a[1]));
    continue;
    end;

  // bitmask? ipv4 only
  a:=split('/', mask);
  if (addr6='') and (length(a) = 2) then
    begin
    try
      bits:=32-strToInt(a[1]);
      result:=addr4 shr bits = ipToInt(a[0]) shr bits;
    except
      end;
    continue;
    end;

  // single
  result:=match( pchar(mask), pchar(address) ) > 0;
  end;
result:=result xor invert;
end; // addressMatch

function freeIfTemp(var f:Tfile):boolean; inline;
begin
try
  result:=assigned(f) and f.isTemp();
  if result then freeAndNIL(f);
except result:=FALSE end;
end; // freeIfTemp

function uri2disk(url:string; parent:Tfile=NIL; resolveLnk:boolean=TRUE):string;
var
  fi: Tfile;
  i: integer;
  append: string;
begin
// don't consider wildcard-part when resolving
  i:=reMatch(url, '[?*]', '!');
  if i = 0 then
    append:=''
   else
    begin
      i:=lastDelimiter('/', url);
      append:=substr(url,i);
      if i>0 then append[1]:='\';
      delete(url, i, MaxInt);
    end;
try
  fi:=mainfrm.findFilebyURL(url, parent);
  if fi <> NIL then
    try
      result:=ifThen(resolveLnk or (fi.lnk=''), fi.resource, fi.lnk) +append;
     finally
      freeIfTemp(fi)
    end
   else
    Result := '';
except result:='' end;
end; // uri2disk

function uri2diskMaybe(path:string; parent:Tfile=NIL; resolveLnk:boolean=TRUE):string;
begin
if ansiContainsStr(path, '/') then result:=uri2disk(path, parent, resolveLnk)
else result:=path;
end; // uri2diskmaybe

function sizeOfFile(fh:Thandle):int64; overload;
var
  h, l: dword;
begin
l:=getFileSize(fh, @h);
if (l = $FFFFFFFF) and (getLastError() <> NO_ERROR) then result:=-1
else result:=l+int64(h) shl 32;
end; // sizeOfFile

function sizeOfFile(fn:string):int64; overload;
var
  h: Thandle;
begin
if ansiStartsText('http://', fn) then
  begin
  result:=httpFilesize(fn);
  exit;
  end;
if ansiContainsStr(fn, '/') then fn:=uri2disk(fn);
h:=fileopen(fn, fmOpenRead+fmShareDenyNone);
result:=sizeOfFile(h);
fileClose(h);
end; // sizeOfFile

function isAbsolutePath(path:string):boolean;
begin result:=(path > '') and (path[1] = '\') or (length(path) > 1) and (path[2] = ':') end;

function min(a,b:integer):integer; inline;
begin if a>b then result:=b else result:=a end;

function fileOrDirExists(fn:string):boolean;
begin
result:=fileExists(fn) or directoryExists(fn);
{** first i used this way, because faster, but it proved to not always work: http://www.rejetto.com/forum/index.php/topic,10825.0.html
var
  sr:TsearchRec;
begin
result:= 0=findFirst(ExcludeTrailingPathDelimiter(fn),faAnyFile,sr);
if result then FindClose(sr);
}
end; // fileOrDirExists

function int0(i,digits:integer):string;
begin
result:=intToStr(i);
result:=stringOfChar('0',digits-length(result))+result;
end; // int0

function elapsedToStr(t:Tdatetime):string;
var
  sec: integer;
begin
sec:=trunc(t*SECONDS);
result:=format('%d:%.2d:%.2d', [sec div 3600, sec div 60 mod 60, sec mod 60] );
end; // elapsedToStr

// ensure f.accounts does not store non-existent users
function cbPurgeVFSaccounts(f:Tfile; callingAfterChildren:boolean; par, par2: IntPtr):TfileCallbackReturn;
var
  usernames, renamings: THashedStringList;
  i: integer;
  act: TfileAction;
  u, n: string;
begin
result:=[];
usernames:=THashedStringList(par);
renamings:=THashedStringList(par2);
for act:=low(act) to high(act) do
  for i:=length(f.accounts[act])-1 downto 0 do
    begin
    u:=f.accounts[act][i];
    n:=renamings.values[u];
    if n > '' then
      begin
      f.accounts[act][i]:=n;
      VFSmodified:=TRUE;
      continue;
      end;
    if (u = '')
    or not (u[1] in ['@','*']) and (usernames.indexOf(u) < 0) then
      begin
      removeString(f.accounts[act], i);
      VFSmodified:=TRUE;
      end;
    end;
end; // cbPurgeVFSaccounts

procedure purgeVFSaccounts();
var
  usernames, renamings: THashedStringList;
  i: integer;
  a: Paccount;
begin
usernames:=THashedStringList.create;
renamings:=THashedStringList.create;
try
  for i:=0 to length(accounts)-1 do
    begin
    a:=@accounts[i];
    usernames.add(a.user);
    if (a.wasUser > '') and (a.user <> a.wasUser) then
      renamings.Values[a.wasUser]:=a.user;
    end;
  rootFile.recursiveApply(cbPurgeVFSaccounts, NativeInt(usernames), NativeInt(renamings));
finally
  usernames.free;
  renamings.free;
  end;
end; // purgeVFSaccounts

function accountAllowed(action:TfileAction; cd:TconnDataMain; f:Tfile):boolean;
var
  a: TStringDynArray;
begin
result:=FALSE;
if f = NIL then exit;
if action = FA_ACCESS then
  begin
  result:= f.accessFor(cd);
  exit;
  end;
if f.isTemp() then
  f:=f.parent;
if (action = FA_UPLOAD) and not f.isRealFolder() then exit;

  repeat
  a:=f.accounts[action];
  if assigned(a)
  and not ((action = FA_UPLOAD) and not f.isRealFolder()) then break;
  f:=f.parent;
  if f = NIL then exit;
  until false;

result:=TRUE;
if stringExists(USER_ANYONE, a, TRUE) then exit;
result:=(cd.usr = '') and stringExists(USER_ANONYMOUS, a, TRUE)
  or assigned(cd.account) and stringExists(USER_ANY_ACCOUNT, a, TRUE)
  or (NIL <> findEnabledLinkedAccount(cd.account, a, TRUE));
end; // accountAllowed


function inputQueryLong(const caption, msg:string; var value:string; ofs:integer=0):boolean;
begin
inputQueryLongdlg.Caption:=caption;
inputQueryLongdlg.msgLbl.Caption:='  '+xtpl(msg, [#13,#13'  '] );
inputQueryLongdlg.inputBox.Text:=value;
inputQueryLongdlg.inputBox.SelStart:=ofs;
// i want focus on the editor, but setFocus works only on visible windows -_-' any better idea?
inputQueryLongdlg.show();                                                   
inputQueryLongdlg.inputBox.SetFocus();
inputQueryLongdlg.hide();
result:=inputQueryLongdlg.ShowModal() = mrOk;
if result then value:=inputQueryLongdlg.inputBox.Text;
end; // inputQueryLong

function dllIsPresent(name:string):boolean;
var h: HMODULE;
begin
h:=LoadLibraryEx(@name, 0, LOAD_LIBRARY_AS_DATAFILE);
result:= h<>0;
FreeLibrary(h);
end;

function httpsCanWork():boolean;
resourcestring
  MSG_NO_DLL = 'An HTTPS action is required but some files are missing. Download them?';
  MSG_DNL_OK = 'Download completed';
  MSG_DNL_FAIL = 'Download failed';

const
  baseUrl = 'http://rejetto.com/hfs/';
var
  files: array of string; // = ['libcrypto-1_1.dll','libssl-1_1.dll'];
  missing: TStringDynArray;
begin
missing:=NIL;
  SetLength(files, 2);
  files[0] := GLIBEAY_110DLL_Name;
  files[1] := GSSLEAY_110DLL_Name;
for var s in files do
  if not FileExists(s) and not dllIsPresent(s) then
    addString(s, missing);
if missing=NIL then
  exit(TRUE);
if msgDlg(MSG_NO_DLL, MB_OKCANCEL+MB_ICONQUESTION) <> MROK then
  exit(FALSE);
for var s in missing do
  if not httpGetFile(baseUrl+s, s, 2, mainfrm.statusBarHttpGetUpdate) then
    begin
    msgDlg(MSG_DNL_FAIL, MB_ICONERROR);
    exit(FALSE);
    end;
mainfrm.setStatusBarText(MSG_DNL_OK);
result:=TRUE;
end; // httpsCanWork

function httpGetStr(url:string; from:int64=0; size:int64=-1):string;
var
  reply: Tstringstream;
begin
if size = 0 then
  exit('');
reply:=TStringStream.Create('');
with ThttpClient.createURL(url) do
  try
    rcvdStream:=reply;
    if (from <> 0) or (size > 0) then
      contentRangeBegin:=intToStr(from);
    if size > 0 then
      contentRangeEnd:=intToStr(from+size-1);
    get();
    result:=reply.dataString;
    if sameText('utf-8', reGet(ContentType, '; *charset=(.+) *($|;)')) then
      Result:=UTF8ToString(result);
  finally
    reply.free;
    Free;
    end
end; // httpGetStr

function httpGet(const url:string; from:int64=0; size:int64=-1): RawByteString;
var
  fs: TMemoryStream;
  httpCli: ThttpClient;
begin
if size = 0 then
  begin
  result:='';
  exit;
  end;

//  Result := LoadFromURLStr(url, from, size);
  fs := nil;
  Result := '';
  httpCli := ThttpClient.createURL(url);
  if Assigned(httpCli) then
with httpCli do
  try
    fs := TMemoryStream.Create;
    rcvdStream:=fs;
    if (from <> 0) or (size > 0) then
      contentRangeBegin:=intToStr(from);
    if size > 0 then
      contentRangeEnd:=intToStr(from+size-1);

      if size >= 0 then
      begin
        httpCli.Head;
        if httpCli.ContentLength < from then
          Exit;
      end;

    get();
        if fs.Size > 0 then
        begin
          SetLength(Result, fs.Size);
          fs.Seek(0, soFromBeginning);
          fs.Read(Result[1], Length(Result));
        end;
  finally
    fs.free;
    Free;
    end


end; // httpGet

function httpFileSize(url:string):int64;
var
  httpCli: ThttpClient;
begin
  Result := -1;
  httpCli := ThttpClient.createURL(url);
  if Assigned(httpCli) then
with httpCli do
  try
    try
      head();
      result:=contentLength
     except result:=-1
      end;
  finally free
    end;
end; // httpFileSize

function httpGetFile(url, filename:string; tryTimes:integer=1; notify:TdocDataEvent=NIL):boolean;
var
  httpCli: ThttpClient;
  supposed: int64;
  reply: Tfilestream;
begin
  supposed := 0;
  httpCli := ThttpClient.createURL(url);
  if Assigned(httpCli) then
with httpCli do
  try
    reply:=TfileStream.Create(filename, fmCreate);
    rcvdStream:=reply;
    onDocData:=notify;
    result:=TRUE;
    try get()
    except result:=FALSE
      end;
    supposed:=ContentLength;
  finally
    reply.free;
    free;
    end;
result:= result and (sizeOfFile(filename)=supposed);
if not result then
  deleteFile(filename);

if not result and (tryTimes > 1) then
  result:=httpGetFile(url, filename, tryTimes-1, notify);
end; // httpGetFile

function getExternalAddress(var res:string; provider:Pstring=NIL):boolean;

  procedure loadIPservices(src:string='');
  var
    l:string;
    sA: RawByteString;
  begin
  if src = '' then
    begin
    if now()-IPservicesTime < 1 then exit; // once a day
    IPservicesTime:=now();
    try sA:=trim(httpGet(IP_SERVICES_URL));
    except exit end;
     src := (UnUTF(sA));
    end;
  IPservices:=NIL;
  while src > '' do
    begin
    l:=chopLine(src);
    if ansiStartsText('http://', l) then addString(l, IPservices);
    end;
  end; // loadIPservices

const {$J+}
  lastProvider: string = ''; // this acts as a static variable
var
  s, mark, addr: string;
  sA: RawByteString;
  i: integer;
begin
result:=FALSE;
if customIPservice > '' then s:=customIPservice
else
  begin
  loadIPservices();
  if IPservices = NIL then
    loadIPservices(UnUTF(getRes('IPservices')));
  if IPservices = NIL then exit;

    repeat
    s:=IPservices[random(length(IPservices))];
    until s <> lastProvider;
  lastProvider:=s;
  end;
addr:=chop('|',s);
if assigned(provider) then provider^:=addr;
mark:=s;
try
  sA:=httpGet(addr);
  s:=UnUTF(sA);
except exit end;
if mark > '' then chop(mark, s);
s:=trim(s);
if s = '' then exit;
// try to determine length
i:=1;
while (i < length(s)) and (i < 15) and (s[i+1] in ['0'..'9','.']) do
  inc(i);
while (i > 0) and (s[i] = '.') do
  dec(i);
setLength(s,i);
result:= checkAddressSyntax(s, false) and not HSlib.isLocalIP(s);
if not result then exit;
if (res <> s) and mainFrm.logOtherEventsChk.checked then
  mainFrm.add2log('New external address: '+s+' via '+hostFromURL(addr));
res:=s;
end; // getExternalAddress

function whatStatusPanel(statusbar:Tstatusbar; x:integer):integer;
var
  x1: integer;
begin
result:=0;
x1:=statusbar.panels[0].width;
while (x > x1) and (result < statusbar.Panels.Count-1) do
  begin
  inc(result);
  inc(x1, statusbar.panels[result].width);
  end;
end; // whatStatusPanel

function getIPs():TStringDynArray;
var
  a6: TStringDynArray;
  I: Integer;
begin
  try
    result := listToArray(localIPlist(sfIPv4));
    a6 := listToArray(localIPlist(sfIPv6));
    if Length(a6) > 0 then
      begin
        for I := Low(a6) to High(a6) do
          a6[i] := '[' + a6[i] + ']';
        Result := Result + a6;
      end;
   except
     result := NIL
  end;
end;

function getPossibleAddresses():TstringDynArray;
begin // next best
result:=toSA([defaultIP, dyndns.host]);
addArray(result, customIPs);
addString(externalIP, result);
addArray(result, getIPs());
removeStrings('', result);
uniqueStrings(result);
end; // getPossibleAddresses

function getFilename(var f:file):string;
begin result:=pchar(@f)+72 end;

function filenameToDriveByte(fn:string):byte;
begin
if (length(fn) < 2) or (fn[2] <> ':') then fn:=exePath; // relative paths are actually based on the same drive of the executable
fn:=getDrive(fn);
if fn = '' then
  result:=0
else
  result:=ord(upcase(fn[1]))-ord('A')+1;
end; // filenameToDriveByte

function smartsize(size:int64):string;
begin
if size < 0 then result:='N/A'
else
  if size < 1 shl 10 then result:=intToStr(size)
  else
    if size < 1 shl 20 then result:=format('%.1f K',[size/(1 shl 10)])
    else
      if size < 1 shl 30 then result:=format('%.1f M',[size/(1 shl 20)])
      else result:=format('%.1f G',[size/(1 shl 30)])
end; // smartsize

function cbSelectFolder(wnd:HWND; uMsg:UINT; lp,lpData:LPARAM):LRESULT; stdcall;
begin
result:=0;
if (uMsg <> BFFM_INITIALIZED) or (lpdata = 0) then exit;
SendMessage(wnd, BFFM_SETSELECTION, 1, LPARAM(pchar(lpdata)));
SendMessage(wnd, BFFM_ENABLEOK, 0, 1);
end; // cbSelectFolder

function selectWrapper(caption:string; var from:string; flags:dword=0):boolean;
const
  BIF_NEWDIALOGSTYLE = $40;
  BIF_UAHINT = $100;
  BIF_SHAREABLE = $8000;
var
  bi: TBrowseInfo;
  res: PItemIDList;
  buff: array [0..MAX_PATH] of char;
  im: iMalloc;
begin
result:=FALSE;
if SHGetMalloc(im) <> 0 then exit;
bi.hwndOwner:=GetActiveWindow();
bi.pidlRoot:=NIL;
bi.pszDisplayName:=@buff;
bi.lpszTitle:=pchar(caption);
bi.ulFlags:=BIF_RETURNONLYFSDIRS+BIF_NEWDIALOGSTYLE+BIF_SHAREABLE+BIF_UAHINT+BIF_EDITBOX+flags;
bi.lpfn:=@cbSelectFolder;
if from > '' then
  bi.lParam:= INT_PTR(@from[1]);
bi.iImage:=0;
res:=SHBrowseForFolder(bi);
if res = NIL then exit;
if not SHGetPathFromIDList(res, buff) then exit;
im.Free(res);
from:=buff;
result:=TRUE;
end; // selectWrapper

function selectFolder(const caption: String; var folder:string):boolean;
begin result:=selectWrapper(caption, folder) end;

// works only on XP
function selectFileOrFolder(caption:string; var fileOrFolder:string):boolean;
begin result:=selectWrapper(caption, fileOrFolder, BIF_BROWSEINCLUDEFILES) end;

function selectFile(var fn:string; title, filter:string; options:TOpenOptions):boolean;
var
  dlg: TopenDialog;
begin
result:=FALSE;
dlg:=TopenDialog.create(screen.activeForm);
if title > '' then dlg.Title:=title;
dlg.Filter:=filter;
if fn > '' then
  begin
  dlg.FileName:=fn;
  if not isAbsolutePath(fn) then dlg.InitialDir:=exePath;
  end;
try
  dlg.Options:=[ofEnableSizing]+options;
  if not dlg.Execute() then exit;
  fn:=dlg.FileName;
  result:=TRUE;
finally dlg.free end;
end; // selectFile

function safeMod(a,b:int64; default:int64=0):int64;
begin if b=0 then result:=default else result:=a mod b end;

function safeDiv(a,b:int64; default:int64=0):int64; inline;
begin if b=0 then result:=default else result:=a div b end;

function safeDiv(a,b:real; default:real=0):real; inline;
begin if b=0 then result:=default else result:=a/b end;

function isExtension(filename, ext:string):boolean;
begin result:= 0=ansiCompareText(ext, extractFileExt(filename)) end;

function getTill(const ss, s:string; included:boolean=FALSE):string;
var
  i: integer;
begin
i:=pos(ss, s);
if i = 0 then result:=s
else result:=copy(s,1,i-1+if_(included,length(ss)));
end; // getTill

function getTill(const ss, s: RawByteString; included:boolean=FALSE): RawByteString;
var
  i: integer;
begin
  i := pos(ss, s);
  if i = 0 then
    result := s
   else
    result := copy(s,1,i-1+if_(included,length(ss)));
end; // getTill


function getTill(i:integer; const s:string):string;
begin
if i < 0 then i:=length(s)+i;
result:=copy(s, 1, i);
end; // getTill

function getTill(i:integer; const s: RawByteString): RawByteString;
begin
  if i < 0 then
    i:=length(s)+i;
  result:=copy(s, 1, i);
end; // getTill

function dateToHTTP(const filename:string):string; overload;
begin result:=dateToHTTP(getMtimeUTC(filename)) end;

function dateToHTTP(gmtTime:Tdatetime):string; overload;
begin
result:=formatDateTime('"'+DOW2STR[dayOfWeek(gmtTime)]+'," dd "'+MONTH2STR[monthOf(gmtTime)]
  +'" yyyy hh":"nn":"ss "GMT"', gmtTime);
end; // dateToHTTP

function dateToHTTPr(const filename: string): RawByteString; overload;
begin result:=dateToHTTPr(getMtimeUTC(filename)) end;

function dateToHTTPr(gmtTime: Tdatetime): RawByteString;
begin
  result := RawByteString(formatDateTime('"'+DOW2STR[dayOfWeek(gmtTime)]+'," dd "'+MONTH2STR[monthOf(gmtTime)]
  +'" yyyy hh":"nn":"ss "GMT"', gmtTime));
end; // dateToHTTP


function getEtag(const filename: string): string;
var
  sr: TsearchRec;
  st: TSystemTime;
begin
  result:='';
  if findFirst(filename, faAnyFile, sr) <> 0 then
    exit;
  FileTimeToSystemTime(sr.FindData.ftLastWriteTime, st);
  result:=intToStr(sr.Size)+':'+floatToStr(SystemTimeToDateTime(st))+':'+expandFileName(filename);
  findClose(sr);
  result := MD5PassHS(result);
end; // getEtag

function getMtimeUTC(filename:string):Tdatetime;
var
  sr: TsearchRec;
  st: TSystemTime;
begin
result:=0;
if findFirst(filename, faAnyFile, sr) <> 0 then exit;
FileTimeToSystemTime(sr.FindData.ftLastWriteTime, st);
result:=SystemTimeToDateTime(st);
findClose(sr);
end; // getMtimeUTC

function getMtime(filename:string):Tdatetime;
begin
if not fileAge(filename, result) then
  result:=0;
end; // getMtime

function ipToInt(ip:string):dword;
var
  i: integer;
begin
  i := ipToInt_cache.Add(ip);
  result := dword(ipToInt_cache.Objects[i]);
  if result <> 0 then
    exit;
  result := WSocket_ntohl(WSocket_inet_addr(PAnsichar(AnsiString(ip))));
  ipToInt_cache.Objects[i] := Tobject(result);
end; // ipToInt

function getShellFolder(const id: String): String;
begin
result:=loadregistry(
  'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', id,
  HKEY_CURRENT_USER);
end; // getShellFolder

function createShellLink(linkFN:WideString; destFN:string):boolean;
var
  ShellObject: IUnknown;
begin
shellObject:=CreateComObject(CLSID_ShellLink);
result:=((shellObject as IShellLink).setPath(PChar(destFN)) = NOERROR)
  and ((shellObject as IPersistFile).Save(PWChar(linkFN), False) = S_OK)
end; // createShellLink

function readShellLink(linkFN:WideString):string;
var
  ShellObject: IUnknown;
  pfd: _WIN32_FIND_DATAW;
begin
  shellObject := CreateComObject(CLSID_ShellLink);
  if (shellObject as IPersistFile).Load(PWChar(linkFN), 0) <> S_OK then
    raise Exception.create('readShellLink: cannot load');
  setLength(result, MAX_PATH);
  if (shellObject as IShellLink).getPath(@result[1], length(result), pfd, 0) <> NOERROR then
    raise Exception.create('readShellLink: cannot getPath');
  setLength(result, strLen(PChar(@result[1])));
end; // readShellLink

function selectFiles(caption:string; var files:TStringDynArray):boolean;
var
  dlg: TopenDialog;
  i: integer;
begin
dlg:=TopenDialog.create(screen.activeForm);
try
  dlg.Options:=dlg.Options+[ofAllowMultiSelect, ofFileMustExist, ofPathMustExist];
  result:=dlg.Execute();
  if result then
    begin
    setLength(files, dlg.Files.count);
    for i:=0 to dlg.files.Count-1 do
      files[i]:=dlg.files[i];
    end;
finally dlg.free end;
end;

function eos(s:Tstream):boolean;
begin result:=s.position >= s.size end;

function singleLine(s:string):boolean;
var
  i, l: integer;
begin
i:=pos(#13,s);
l:=length(s);
result:=(i = 0) or (i = l) or (i = l-1) and (s[l] = #10)
end; // singleLine

function setClip(const s:string):boolean;
begin
result:=TRUE;
try clipboard().AsText:=s
except result:=FALSE end;
end; // setClip

function getStr(from, to_: pAnsichar): RawByteString;
var
  l: integer;
begin
  result:='';
  if (from = NIL) or assigned(to_) and (from > to_) then
    exit;
  if to_ = NIL then
    begin
      to_ := ansistrings.strEnd(from);
      dec(to_);
    end;
  l := to_-from+1;
  setLength(result, l);
  if l > 0 then
    ansistrings.strLcopy(@result[1], from, l);
end; // getStr

function getStr(from, to_:pchar): String;
var
  l: integer;
begin
result:='';
if (from = NIL) or assigned(to_) and (from > to_) then exit;
if to_ = NIL then
  begin
  to_:=strEnd(from);
  dec(to_);
  end;
l:=to_-from+1;
setLength(result, l);
if l > 0 then strLcopy(@result[1], from, l);
end; // getStr

function poss(chars:TcharSetW; s:string; ofs:integer=1):integer;
begin
for result:=ofs to length(s) do
  if s[result] in chars then exit;
result:=0;
end; // poss

function isNT():boolean;
var
  vi: TOSVERSIONINFO;
begin
result:=TRUE;
vi.dwOSVersionInfoSize:=sizeOf(vi);
if not windows.getVersionEx(vi) then exit;
result:= vi.dwPlatformId = VER_PLATFORM_WIN32_NT;
end; // isNT

function getTempDir():string;
begin
setLength(result, 1000);
setLength(result, getTempPath(length(result), @result[1]));
end; // getTempDir
{
function optUTF8(bool:boolean; s: AnsiString): RawByteString;
begin
 if bool then
   result:=ansiToUtf8(s)
  else
   result:=s
end;

function optUTF8(bool:boolean; s:string): RawByteString;
begin
 if bool then
   result:=ansiToUtf8(s)
  else
   result:=s
end;

function optUTF8(tpl:Ttpl; s:string):string; inline;
begin result:=optUTF8(assigned(tpl) and tpl.utf8, s) end;
}
function optAnsi(bool:boolean; s:string):string;
begin if bool then result:=UTF8toAnsi(s) else result:=s end;

function blend(from,to_:Tcolor; perc:real):Tcolor;
var
  i: integer;
begin
result:=0;
from:=ColorToRGB(from);
to_:=ColorToRGB(to_);
for i:=0 to 2 do
  inc(result, min($FF, round(((from shr (i*8)) and $FF)*(1-perc)
    +((to_ shr (i*8)) and $FF)*perc)) shl (i*8));
end; // blend

function listToArray(l:Tstrings):TstringDynArray;
var
  i: integer;
begin
try
  setLength(result, l.Count);
  for i:=0 to l.Count-1 do
    result[i]:=l[i];
except
  result:=NIL
  end
end; // listToArray

function jsEncode(s, chars:string):string;
var
  i: integer;
begin
for i:=1 to length(chars) do
  s:=ansiReplaceStr(s, chars[i], '\x'+intToHex(ord(chars[i]),2));
result:=s;
end; // jsEncode

function holdingKey(key:integer):boolean;
begin result:=getAsyncKeyState(key) and $8000 <> 0 end;

function utf8Test(const s: String):boolean;
begin result := ansiContainsText(s, 'charset=UTF-8') end;

function utf8Test(const s: RawByteString): boolean;
begin result := ansiContainsText(s, RawByteString('charset=UTF-8')) end;

// concat pre+s+post only if s is non empty
function nonEmptyConcat(const pre, s:string; const post:string=''):string;
begin if s = '' then result:='' else result:=pre+s+post end;

// returns the first non empty string
function first(a:array of string):string;
var
  i: integer;
begin
result:='';
for i:=0 to length(a)-1 do
  begin
  result:=a[i];
  if result > '' then exit;
  end;
end; // first

function first(a:array of RawByteString): RawByteString; overload;
var
  i: integer;
begin
result:='';
for i:=0 to length(a)-1 do
  begin
  result:=a[i];
  if result > '' then exit;
  end;
end; // first

function first(const a,b:string):string;
begin if a = '' then result:=b else result:=a end;

function first(a,b:integer):integer;
begin if a = 0 then result:=b else result:=a end;

function first(a,b:double):double;
begin if a = 0 then result:=b else result:=a end;

function first(a,b:pointer):pointer;
begin if a = NIL then result:=b else result:=a end;

// taken from http://www.delphi3000.com/articles/article_3361.asp
function captureExec(const DosApp: string; out output:string; out exitcode:cardinal; timeout:real=0):boolean;
const
  ReadBuffer = 1048576;  // 1 MB Buffer
var
  sa            : TSecurityAttributes;
  ReadPipe,WritePipe  : THandle;
  start               : TStartUpInfo;
  ProcessInfo         : TProcessInformation;
  Buffer              : PAnsiChar;
  buf2                : PWideChar;
  TotalBytesRead,
  BytesRead           : DWORD;
  Apprunning,
  BytesLeftThisMessage,
  TotalBytesAvail : integer;
begin
result:=FALSE;
output:='';
sa.nlength:=SizeOf(sa);
sa.binherithandle:=TRUE;
sa.lpsecuritydescriptor:=NIL;

if not createPipe(ReadPipe, WritePipe, @sa, 0) then exit;
// Redirect In- and Output through STARTUPINFO structure
  Buffer := AllocMem(ReadBuffer + 1);
  ZeroMemory(@start, Sizeof(Start));
  start.cb:= SizeOf(start);
start.hStdOutput:= WritePipe;
start.hStdInput:= ReadPipe;
start.dwFlags:= STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
start.wShowWindow:= SW_HIDE;
TotalBytesRead:=0;
if timeout = 0 then
  timeout:=MaxExtended
else
  timeout:=now()+timeout/SECONDS;
// Create a Console Child Process with redirected input and output
try
  if CreateProcess(nil, PChar(DosApp), @sa, @sa, true, CREATE_NO_WINDOW or NORMAL_PRIORITY_CLASS, nil, nil, start, ProcessInfo) then
    repeat
    result:=TRUE;
    // wait for end of child process
    Apprunning := WaitForSingleObject(ProcessInfo.hProcess,100);
    Application.ProcessMessages();
    // it is important to read from time to time the output information
    // so that the pipe is not blocked by an overflow. New information
    // can be written from the console app to the pipe only if there is
    // enough buffer space.
    if not PeekNamedPipe(ReadPipe, @Buffer[TotalBytesRead], ReadBuffer,
      @BytesRead, @TotalBytesAvail, @BytesLeftThisMessage ) then
      break
    else if BytesRead > 0 then
      ReadFile(ReadPipe, Buffer[TotalBytesRead], BytesRead, BytesRead, nil );
    inc(TotalBytesRead, BytesRead);
    until (Apprunning <> WAIT_TIMEOUT) or (now() >= timeout);

  if IsTextUnicode(Buffer, TotalBytesRead, NIL) then
    begin
    Pchar(@Buffer[TotalBytesRead])^:= #0;
    output:=pchar(Buffer)
    end
  else
    begin
      Buffer[TotalBytesRead]:= #0;
      buf2 := StrAlloc(ReadBuffer + 1);
      OemToChar(PansiChar(Buffer), buf2);
      output := strPas(buf2);
    end;
finally
  GetExitCodeProcess(ProcessInfo.hProcess, exitcode);
  TerminateProcess(ProcessInfo.hProcess, 0);
  FreeMem(Buffer);
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);
  CloseHandle(ReadPipe);
  CloseHandle(WritePipe);
  end;
end; // captureExec

function port2pid(const port:string):integer;
var
  s, l, p: string;
  code: cardinal;
begin
result:=-1;
if not captureExec('netstat -naop tcp', s, code) then
  exit;
  
while s > '' do
  begin
  l:=chopline(s);
  if pos('LISTENING', l) = 0 then continue;
  chop(':', l);
  p:=chop(' ',l);
  if p <> port then continue;
  chop('LISTENING', l);
  result:=strToIntDef(trim(l), -1);
  exit;
  end;
end; // port2pid

function pid2file(pid: cardinal):string;
var
  h: Thandle;
begin
result:='';
// this is likely to fail on Vista if we are querying a service, because we are running with less privs
h:=openProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, pid);
if h = 0 then exit;
try
  setLength(result, MAX_PATH);
  if getModuleFileNameEx(h, 0, pchar(Result), MAX_PATH) > 0 then
    setLength(result, strLen(pchar(result)))
  else
    result:=''
finally closeHandle(h) end;
end; // pid2file

function stripChars(s:string; cs:TcharsetW; invert:boolean=FALSE):string;
var
  i, l, ofs: integer;
  b: boolean;
begin
l:=length(s);
i:=1;
ofs:=0;
while i+ofs <= l do
  begin
  b:=(s[i+ofs] in cs) xor invert;
  if b then inc(ofs);
  if i+ofs > l then break;
  if ofs > 0 then s[i]:=s[i+ofs];
  if not b then inc(i);
  end;
setLength(s, l-ofs);
result:=s;
end; // stripChars

function openURL(const url:string):boolean;
begin
result:=exec(url);
end; // openURL

// tells if a substring is found at specific position
function strAt(const s, ss:string; at:integer):boolean; inline;
begin
if (ss = '') or (length(s) < at+length(ss)-1) then result:=FALSE
else if length(ss) = 1 then result:=s[at] = ss[1]
else if length(ss) = 2 then result:=(s[at] = ss[1]) and (s[at+1] = ss[2])
else result:=copy(s,at,length(ss)) = ss;
end; // strAt

function swapMem(var src,dest; count:dword; cond:boolean=TRUE):boolean; inline;
var
  temp:pointer;
begin
result:=cond;
if not cond then exit;
getmem(temp, count);
move(src, temp^, count);
move(dest, src, count);
move(temp^, dest, count);
freemem(temp, count);
end; // swapMem

function replace(var s:string; const ss:string; start,upTo:integer):integer;
var
  common, oldL, surplus: integer;
begin
  oldL := upTo-start+1;
  common := min(length(ss), oldL);
  MoveChars(ss[1], s[start], common);
  surplus := oldL-length(ss);
  if surplus > 0 then
    delete(s, start+length(ss), surplus)
   else
    insert(copy(ss, common+1, -surplus), s, start+common);
  result := -surplus;
end; // replace

function substr(const s:string; start:integer; upTo:integer=0):string; inline;
var
  l: integer;
begin
l:=length(s);
if start = 0 then inc(start)
else if start < 0 then start:=l+start+1;
if upTo <= 0 then upTo:=l+upTo;
result:=copy(s, start, upTo-start+1)
end; // substr

function substr(const s: RawByteString; start:integer; upTo:integer=0): RawByteString; inline;
var
  l: integer;
begin
  l := length(s);
  if start = 0 then
    inc(start)
   else
    if start < 0 then
      start := l+start+1;
  if upTo <= 0 then
    upTo := l+upTo;
  result := copy(s, start, upTo-start+1)
end; // substr

function substr(const s:string; const after:string):string;
var
  i: integer;
begin
i:=pos(after,s);
if i = 0 then result:=''
else result:=copy(s, i+length(after), MAXINT)
end; // substr

function xtpl(src:string; table:array of string):string;
var
  i:integer;
begin
i:=0;
while i < length(table) do
  begin
  src := SysUtils.StringReplace(src,table[i],table[i+1],[rfReplaceAll,rfIgnoreCase]);
  inc(i, 2);
  end;
result:=src;
end; // xtpl

function xtpl(src: RawByteString; table:array of RawByteString): RawByteString;
var
  i: integer;
begin
i:=0;
while i < length(table) do
  begin
  src:=stringReplace(src,table[i],table[i+1],[rfReplaceAll,rfIgnoreCase]);
  inc(i, 2);
  end;
result:=src;
end; // xtpl

function clearAndReturn(var v:string):string;
begin
result:=v;
v:='';
end;

procedure drawCentered(cnv:Tcanvas; r:Trect; text:string);
begin drawText(cnv.Handle, pchar(text), length(text), r, DT_CENTER+DT_NOPREFIX+DT_VCENTER+DT_END_ELLIPSIS) end;

function minmax(min, max, v:integer):integer; inline;
begin
if v < min then result:=min
else if v > max then result:=max
else result:=v
end;

function isLocalIP(const ip:string):boolean;
begin result:=checkAddressSyntax(ip, FALSE) and HSlib.isLocalIP(ip) end;

function reduceSpaces(s:string; const replacement:string=' '; spaces:TcharSetW=[]):string;
var
  i, c, l: integer;
begin
if spaces = [] then include(spaces, ' ');
i:=0;
l:=length(s);
while i < l do
  begin
  inc(i);
  c:=i;
  while (c <= l) and (s[c] in spaces) do
    inc(c);
  if c = i then continue;
  replace(s, replacement, i, c-1);
  end;
result:=s;
end; // reduceSpaces

function countSubstr(const ss:string; const s:string):integer;
var
  i, l: integer;
  c: char;
begin
result:=0;
l:=length(ss);
if l = 1 then
  begin
  l:=length(s);
  c:=ss[1];
  for i:=1 to l do
    if s[i] = c then
      inc(result);
  exit;
  end;
i:=1;
  repeat
  i:=posEx(ss, s, i);
  if i = 0 then exit;
  inc(result);
  inc(i, l);
  until false;
end; // countSubstr

function trim2(const s:string; chars:TcharsetW):string;
var
  b, e: integer;
begin
b:=1;
while (b <= length(s)) and (s[b] in chars) do inc(b);
e:=length(s);
while (e > 0) and (s[e] in chars) do dec(e);
result:=substr(s, b, e);
end; // trim2

function boolOnce(var b:boolean):boolean;
begin result:=b; b:=FALSE end;

procedure urlToStrings(const s:string; sl:Tstrings);
var
  i, l, p: integer;
  t: string;
begin
i:=1;
l:=length(s);
while i <= l do
  begin
  p:=posEx('&',s,i);
  t:=decodeURL(xtpl(substr(s,i,if_(p=0,0,p-1)), ['+',' ']), FALSE); // TODO should we instead try to decode utf-8? doing so may affect calls to {.force ansi.} in the template 
  sl.add(t);
  if p = 0 then exit;
  i:=p+1;
  end;
end; // urlToStrings

procedure urlToStrings(const s: RawByteString; sl: Tstrings);
var
  i, l, p: integer;
  t: string;
begin
  i:=1;
  l:=length(s);
  while i <= l do
  begin
    p := posEx(RawByteString('&'),s,i);
    t := decodeURL(xtpl(substr(s,i,if_(p=0,0,p-1)), [RawByteString('+'), RawByteString(' ')]));
     // TODO should we instead try to decode utf-8? doing so may affect calls to {.force ansi.} in the template
    sl.add(t);
    if p = 0 then
      exit;
    i := p+1;
  end;
end; // urlToStrings

// extract at p the section name of a text, if any
function getSectionAt(p: pchar; out name:string): boolean;
var
 eos, eol: pchar;
begin
result:=FALSE;
if (p = NIL) or (p^ <> '[') then exit;
eos:=p;
while eos^ <> ']' do
  if eos^ in [#0, #10, #13] then exit
  else inc(eos);
// ensure the line is termineted correctly
eol:=eos;
inc(eol);
while not (eol^ in [#10,#0]) do
  if not (eol^ in [#9,#32,#13]) then exit
  else inc(eol);
inc(p);
dec(eos);
name:=getStr(p, eos);
result:=TRUE;
end; // getSectionAt

function isSectionAt(p:pchar):boolean;
var
  trash: string;
begin
  result:=getSectionAt(p, trash);
end; // isSectionAt

procedure doNothing();
begin end;

// calculates the value of a constant formula
function evalFormula(s:string):real;
// this algo is by far not the quickest, because it manipulates the string, but it's the simpler that came to my mind
const
  PAR_VAL = 100;
var
  i, v,
  mImp, // index of the most important operator
  mImpV: integer; // importance of the most important
  ofsImp: integer; // importance offset, due to parenthesis
  ch: char;
  left, right: real;
  leftS, rightS: string;

  function getOperand(dir:integer):string;
  var
    j: integer;
  begin
  i:=mImp+dir;
    repeat
    j:=i+dir;
    if (j > 0) and (j <= length(s))
    and (charInSet(s[j], ['0'..'9','.','E']) or (j>1) and charInSet(s[j],['+','-']) and (s[j-1]='E')) then
      i:=j
    else
      break;
    until false;
  j:=mImp+dir;
  swapMem(i, j, sizeOf(i), dir > 0);
  j:=j-i+1;
  result:=copy(s, i, j);
  end; // getOperand

begin
  repeat
  // search the most urgent operator
  ofsImp:=0;
  mImp:=0;
  mImpV:=0;
  for i:=1 to length(s) do
    begin
    // calculate operator precedence (if any)
    ch:=s[i];
    v:=0;
    case ch of
      '*','/','%','[',']': v:=5+ofsImp;
      '+','-': v:=3+ofsImp;
      '(': inc(ofsImp, PAR_VAL);
      ')': dec(ofsImp, PAR_VAL);
      end;

    if (i = 1) // a starting operator is not an operator
    or (s[i-1]='E') // exponential syntax
    or (v <= mImpV) // left-to-right precedence
    then continue;
    // we got a better one, record it
    mImpV:=v;
    mImp:=i;
    end;//for

  // found or not?
  if mImp = 0 then
    begin
    result:=strToFloat(s);
    exit;
    end;
  // determine operates
  leftS:=getOperand(-1);
  rightS:=getOperand(+1);
  left:=StrToFloatDef(trim(leftS), 0);
  right:=strToFloat(trim(rightS));
  // calculate
  ch:=s[mImp];
  case ch of
    '+': result:=left+right;
    '-': result:=left-right;
    '*': result:=left*right;
    '/':
      if right <> 0 then result:=left/right
      else raise Exception.create('division by zero');
    '%':
      if right <> 0 then result:=trunc(left) mod trunc(right)
      else raise Exception.create('division by zero');
    '[': result:=round(left) shl round(right);
    ']': result:=round(left) shr round(right);
    else raise Exception.create('operator not supported: '+ch);
    end;
  // replace sub-expression with result
  i:=mImp-length(leftS);
  v:=mImp+length(rightS);
  if (i > 1) and (v < length(s)) and (s[i-1] = '(') and (s[v+1] = ')') then
    begin  // remove also parenthesis
    dec(i);
    inc(v);
    end;
  if v-i+1 = length(s) then exit; // we already got the result
  replace(s, floatToStr(result), i, v);
  until false;
end; // evalFormula

function getUniqueName(const start:string; exists:TnameExistsFun):string;
var
  i: integer;
begin
result:=start;
if not exists(result) then exit;
i:=2;
  repeat
  result:=format('%s (%d)', [start,i]);
  inc(i);
  until not exists(result);
end; // getUniqueName

function accountIcon(isEnabled, isGroup:boolean):integer; overload;
begin result:=if_(isGroup, if_(isEnabled,29,40), if_(isEnabled,27,28)) end;

function accountIcon(a:Paccount):integer; overload;
begin result:=accountIcon(a.enabled, a.group) end;

function newMenuSeparator(lbl:string=''):Tmenuitem;
begin
result:=newItem('-',0,FALSE,TRUE,NIL,0,'');
result.hint:=lbl;
result.onDrawItem:=mainfrm.menuDraw;
result.OnMeasureItem:=mainfrm.menuMeasure;
end; // newMenuSeparator

function arrayToList(a:TStringDynArray; list:TstringList=NIL):TstringList;
var
  i: integer;
begin
if list = NIL then
  list:=ThashedStringList.create;
result:=list;
list.Clear();
for i:=0 to length(a)-1 do
  list.add(a[i]);
end; // arrayToList

function createAccountOnTheFly():Paccount;
var
  acc: Taccount;
  i: integer;
begin
  result:=NIL;
  ZeroMemory(@acc, sizeOf(acc));
  acc.enabled:=TRUE;
  repeat
  if not newuserpassFrm.prompt(acc.user, acc.pwd)
  or (acc.user = '') then exit;

  if getAccount(acc.user) = NIL then break;
  msgDlg('Username already exists', MB_ICONERROR)
  until false;
i:=length(accounts);
setLength(accounts, i+1);
accounts[i]:=acc;
result:=@accounts[i];
end; // createAccountOnTheFly

procedure sortArray(var a:TStringDynArray);
var
  i, j, l: integer;
begin
l:=length(a);
for i:=0 to l-2 do
  for j:=i+1 to l-1 do
    swapMem(a[i], a[j], sizeof(a[i]), ansiCompareText(a[i], a[j]) > 0);
end; // sortArray

function sortArrayF(const a:TStringDynArray):TStringDynArray;
var
  i, j, l: integer;
begin
result:=a;
l:=length(result);
for i:=0 to l-2 do
  for j:=i+1 to l-1 do
    swapMem(result[i], result[j], sizeof(result[i]), ansiCompareText(result[i], result[j]) > 0);
end; // sortArray

procedure onlyForExperts(controls:array of Tcontrol);
var
  i: integer;
begin
for i:=0 to length(controls)-1 do
  controls[i].visible:=not easyMode;
end; // onlyForExperts

function onlyExistentAccounts(a:TstringDynArray):TstringDynArray;
var
  i: integer;
  s: string;
begin
for i:=0 to length(a)-1 do
  begin
  s:=trim(a[i]);
  if (s = '') or (s[1] <> '@') and (getAccount(s) = NIL) then
    removeString(a, i)
  else
    a[i]:=s;
  end;
result:=a;
end; // onlyExistentAccounts

function strToCharset(s:string):TcharsetW;
var
  i: integer;
begin
result:=[];
for i:=1 to length(s) do
  include(result, ansichar(s[i]));
end; // strToCharset

function boolToPtr(b:boolean):pointer;
begin result:=if_(b, PTR1, NIL) end;

// recognize strings containing pieces (separated by backslash) made of only dots
function dirCrossing(s:string):boolean;
begin
result:=FALSE;

if onlyDotsRE = NIL then
  begin
  onlyDotsRE:=TRegExpr.Create;
  onlyDotsRE.modifierM:=TRUE;
  onlyDotsRE.expression:='(^|\\)\.\.+($|\\)';
  onlyDotsRE.compile();
  end;

with onlyDotsRE do
  try result:=exec(s);
  except end;
end; // dirCrossing

// this will tell if the file has changed
function newMtime(fn:string; var previous:Tdatetime):boolean;
var
  d: TDateTime;
begin
d:=getMtime(fn);
result:=fileExists(fn) and (d <> previous);
if result then
  previous:=d;
end; // newMtime

function dequote(const s:string; quoteChars:TcharSetW=['"']):string;
begin
if (s > '') and (s[1] = s[length(s)]) and (s[1] in quoteChars) then
  result:=copy(s, 2, length(s)-2)
else
  result:=s;
end; // dequote

// finds the end of the line
function findEOL(s:string; ofs:integer=1; included:boolean=TRUE):integer;
begin
ofs:=max(1,ofs);
result:=posEx(#13, s, ofs);
if result > 0 then
  begin
  if not included then
    dec(result)
  else
    if (result < length(s)) and (s[result+1] = #10) then
      inc(result);
  exit;
  end;
result:=posEx(#10, s, ofs);
if result > 0 then
  begin
  if not included then
    dec(result);
  exit;
  end;
result:=length(s);
end; // findEOL

function quoteIfAnyChar(badChars, s:string; const quote:string='"'; const unquote:string='"'):string;
begin
if anycharIn(badChars, s) then
  s:=quote+s+unquote;
result:=s;
end; // quoteIfAnyChar

function toSA(a:array of string):TstringDynArray; // this is just to have a way to typecast
begin
result:=NIL;
addArray(result, a);
end; // toSA

// this is feasible for spot and low performance needs
function getKeyFromString(const s:string; key:string; const def:string=''):string;
var
  i: integer;
begin
result:=def;
includeTrailingString(key, '=');
i:=1;
  repeat
  i:= ipos(key, s, i);
  if i = 0 then exit; // not found
  until (i = 1) or (s[i-1] in [#13,#10]); // ensure we are at the very beginning of the line
inc(i, length(key));
result:=substr(s,i, findEOL(s,i,FALSE));
end; // getKeyFromString

// "key=val" in second parameter (with 3rd one empty) is supported
function setKeyInString(s:string; key:string; val:string=''):string;
var
  i: integer;
begin
i:=pos('=', key);
if i = 0 then
  key:=key+'='
else if val = '' then
  begin
  val:=copy(key,i+1,MAXINT);
  setLength(key, i);
  end;
// now key has a trailing '='. Let's find where it is.
i:=0;
  repeat i:= ipos(key, s, i+1);
  until (i <= 1) or (s[i-1] in [#13,#10]); // we accept cases 0,1 as they are. Other cases must comply with being at start of line.
if i = 0 then // missing, then add
  begin
  if s > '' then
    includeTrailingString(s, CRLF);
  result:=s+key+val;
  exit;
  end;
// replace
inc(i, length(key));
replace(s, val, i, findEOL(s,i, FALSE));
result:=s;
end; // setKeyInString

// useful for casing on the first char
function getFirstChar(const s:string):char;
begin
if s = '' then result:=#0
else result:=s[1]
end; // getFirstChar

function localToGMT(d:Tdatetime):Tdatetime;
begin result:=d-GMToffset*60/SECONDS end;

// this is useful when we don't know if the value is expressed as a real Tdatetime or in unix time format
function maybeUnixTime(t:Tdatetime):Tdatetime;
begin
if t > 1000000 then result:=unixToDateTime(round(t))
else result:=t
end;

procedure excludeTrailingString(var s:string; ss:string);
var
  i: integer;
begin
i:=length(s)-length(ss);
if copy(s, i+1, length(ss)) = ss then
  setLength(s, i);
end;

function deltree(path:string):boolean;
var
  sr: TSearchRec;
  fn: string;
begin
result:=FALSE;
if fileExists(path) then
  begin
  result:=deleteFile(path);
  exit;
  end;
if not ansiContainsStr(path, '?') and not ansiContainsStr(path, '*') then
  path:=path+'\*';
if findfirst(path, faAnyFile, sr) <> 0 then exit;
try
  repeat
  if (sr.name = '.') or (sr.name = '..') then continue;
  fn:=path+'\'+sr.name;
  if boolean(sr.attr and faDirectory) then
    delTree(fn)
  else
    deleteFile(fn);
  until findNext(sr) <> 0;
finally
  findClose(sr);
  rmDir(path);
  end;
end; // deltree

{$IFDEF HFS_GIF_IMAGES}
function stringToGif(s: RawByteString; gif: TgifImage=NIL):TgifImage;
var
  ss: TAnsiStringStream;
begin
  ss := TAnsiStringStream.create(s);
try
  if gif = NIL then
    gif:=TGIFImage.Create();
  gif.loadFromStream(ss);
  result:=gif;
finally ss.free end;
end; // stringToGif

function gif2str(gif:TgifImage): RawByteString;
var
  stream: Tbytesstream;
begin
stream:=Tbytesstream.create();
gif.SaveToStream(stream);
setLength(result, stream.size);
move(stream.bytes[0], result[1], stream.size);
stream.free;
end; // gif2str

function bmp2str(bmp:Tbitmap): RawByteString;
var
	gif: TGIFImage;
begin
gif:=TGIFImage.Create();
try
  gif.ColorReduction:=rmQuantize;
  gif.Assign(bmp);
  result:=gif2str(gif);
finally gif.free;
  end;
end; // bmp2str

function pic2str(idx:integer): RawByteString;
var
  ico: Ticon;
  gif: TgifImage;
begin
result:='';
if idx < 0 then exit;
idx:=idx_ico2img(idx);
if length(imagescache) <= idx then
  setlength(imagescache, idx+1);
result:=imagescache[idx];
if result > '' then exit;

ico:=Ticon.Create;
gif:=TGifImage.Create;
try
  mainfrm.images.getIcon(idx, ico);
  gif.Assign(ico);
  result:=gif2str(gif);
  imagescache[idx]:=result;
finally
  gif.Free;
  ico.free;
  end;
end; // pic2str

function str2pic(s: RawByteString):integer;
var
	gif: TGIFImage;
begin
  for result:=0 to mainfrm.images.count-1 do
    if pic2str(result) = s then
      exit;
// in case the pic was not found, it automatically adds it to the pool
  gif := stringToGif(s);
  try
    result := mainfrm.images.addMasked(gif.bitmap, gif.Bitmap.TransparentColor);
    etags.values['icon.'+intToStr(result)] := MD5PassHS(s);
   finally
    gif.free
  end;
end; // str2pic
{$ELSE ~HFS_GIF_IMAGES}
function stringToPNG(s: RawByteString; png: TpngImage=NIL):TpngImage;
var
  ss: TAnsiStringStream;
begin
  ss := TAnsiStringStream.create(s);
try
  if png = NIL then
    png:=TPNGImage.Create();
  png.loadFromStream(ss);
  result:=png;
finally ss.free end;
end; // stringToGif

function png2str(png:TpngImage): RawByteString;
var
  stream: Tbytesstream;
begin
stream:=Tbytesstream.create();
png.SaveToStream(stream);
setLength(result, stream.size);
move(stream.bytes[0], result[1], stream.size);
stream.free;
end; // gif2str

function bmp2str(bmp:Tbitmap): RawByteString;
var
	png: TPNGImage;
begin
png:=TPNGImage.Create();
try
//  png.ColorReduction:=rmQuantize;
  png.Assign(bmp);
  result:=png2str(png);
finally png.free;
  end;
end; // bmp2str

function pic2str(idx:integer): RawByteString;
var
  bmp: TBitmap;
  png: TpngImage;
  ico: TIcon;
begin
result:='';
if idx < 0 then exit;
idx:=idx_ico2img(idx);
if length(imagescache) <= idx then
  setlength(imagescache, idx+1);
result:=imagescache[idx];
if result > '' then exit;

png:=TPNGImage.Create;
bmp := TBitmap.Create;
ico := TIcon.Create;
//bmp.PixelFormat := pf32bit;
//  bmp.PixelFormat := pf24bit;
try
  mainfrm.images.GetIcon(idx, ico);
//  ico2bmp(ico, bmp);
  bmp.SetSize(ico.Width, ico.Height);
  bmp.PixelFormat := pf24bit;
  bmp.Canvas.Brush.Color:= $010100;
  bmp.Canvas.FillRect(bmp.Canvas.ClipRect);
  bmp.Canvas.StretchDraw(Rect(0, 0, bmp.Width, bmp.Height), ico);

  bmp.TransparentColor := $010100;
  bmp.Transparent := True;

  png.Assign(bmp);
  result:=png2str(png);
  imagescache[idx]:=result;
finally
  ico.Free;
  bmp.Free;
  png.Free;
  end;
end; // pic2str

function str2pic(s: RawByteString):integer;
var
	png: TPNGImage;
  bmp: TBitmap;
begin
  for result:=0 to mainfrm.images.count-1 do
    if pic2str(result) = s then
      exit;
// in case the pic was not found, it automatically adds it to the pool
  png := stringToPNG(s);
  bmp := TBitmap.Create;
  try
    bmp.Assign(png);
    result := mainfrm.images.addMasked(bmp, bmp.TransparentColor);
    etags.values['icon.'+intToStr(result)] := MD5PassHS(s);
   finally
    bmp.Free;
    png.free
  end;
end; // str2pic
{$ENDIF HFS_GIF_IMAGES}

function getImageIndexForFile(fn:string):integer;
var
  i, n: integer;
  ico: Ticon;
  shfi: TShFileInfo;
  sR: RawByteString;
begin
  ZeroMemory(@shfi, SizeOf(TShFileInfo));
// documentation reports shGetFileInfo() to be working with relative paths too,
// but it does not actually work without the expandFileName()
shGetFileInfo( pchar(expandFileName(fn)), 0, shfi, SizeOf(shfi), SHGFI_SYSICONINDEX);
if shfi.iIcon = 0 then
  begin
  result:=ICON_FILE;
  exit;
  end;
// as reported by official docs
if shfi.hIcon <> 0 then
  destroyIcon(shfi.hIcon);

// have we already met this sysidx before?
for i:=0 to length(sysidx2index)-1 do
  if sysidx2index[i].sysidx = shfi.iIcon then
  	begin
    result:=sysidx2index[i].idx;
    exit;
    end;
// found not, let's check deeper: byte comparison.
// we first add the ico to the list, so we can use pic2str()
ico:=Ticon.create();
try
  systemimages.getIcon(shfi.iIcon, ico);
  i:=mainfrm.images.addIcon(ico);
  sR:=pic2str(i);
  etags.values['icon.'+intToStr(i)] := MD5PassHS(sR);
finally ico.free end;
// now we can search if the icon was already there, by byte comparison
n:=0;
while n < length(sysidx2index) do
  begin
  if pic2str(sysidx2index[n].idx) = sR then
    begin // found, delete the duplicate
    mainfrm.images.delete(i);
    setlength(imagescache, i);
    i:=sysidx2index[n].idx;
    break;
    end;
  inc(n);
  end;

n:=length(sysidx2index);
setlength(sysidx2index, n+1);
sysidx2index[n].sysidx:=shfi.iIcon;
sysidx2index[n].idx:=i;
result:=i;
end; // getImageIndexForFile


{$IFNDEF HAS_FASTMM}
// this is to be used with the standard memory manager, while we are currently using a different one
function allocatedMemory():int64;
var
  mms: TMemoryManagerState;
  i: integer;
begin
getMemoryManagerState(mms);
result:=0;
for i:=0 to high(mms.SmallBlockTypeStates)-1 do
  with mms.SmallBlockTypeStates[i] do
    //inc(result, ReservedAddressSpace);   i guess this is real consumption from a system PoV, but it's actually preallocated, not fully used
    inc(result, internalBlockSize*allocatedBlockCount);
inc(result, mms.TotalAllocatedLargeBlockSize+mms.TotalAllocatedMediumBlockSize);
end; // allocatedMemory

{$ELSE HAS_FASTMM}

function allocatedMemory():int64;
var
  mm: TMemoryManagerUsageSummary;
begin
  getMemoryManagerUsageSummary(mm);
  result := mm.allocatedBytes;
end; // allocatedMemory
{$ENDIF HAS_FASTMM}

{$IFDEF MSWINDOWS}
function currentStackUsage: NativeUInt;
//NB: Win32 uses FS, Win64 uses GS as base for Thread Information Block.
asm
  {$IFDEF WIN32}
  mov eax, fs:[4]  // TIB: base of the stack
  sub eax, esp     // compute difference in EAX (=Result)
  {$ENDIF}
  {$IFDEF WIN64}
  mov rax, gs:[8]  // TIB: base of the stack
  sub rax, rsp     // compute difference in RAX (=Result)
  {$ENDIF}
{$ENDIF}
end;

function removeStartingStr(ss,s:string):string;
begin
if ansiStartsStr(ss, s) then
  result:=substr(s, 1+length(ss))
else
  result:=s
end; // removeStartingStr

function stringToColorEx(s:string; default:Tcolor=clNone):Tcolor;
begin
try
  if reMatch(s, '#?[0-9a-f]{3,6}','!i') > 0 then
    begin
    s:=removeStartingStr('#', s);
    case length(s) of
      3: s:=s[3]+s[3]+s[2]+s[2]+s[1]+s[1];
      6: s:=s[5]+s[6]+s[3]+s[4]+s[1]+s[2];
      end;
    end;
  result:=stringToColor('$'+s)
except
  try result:=stringToColor('cl'+s);
  except
    if default = clNone then
      result:=stringToColor(s)
    else
      try result:=stringToColor(s)
      except result:=default end;
    end;
  end;
end; // stringToColorEx

function filetimeToDatetime(ft:TFileTime):Tdatetime;
var
  st: TsystemTime;
begin
FileTimeToLocalFileTime(ft, ft);
FileTimeToSystemTime(ft, st);
TryEncodeDateTime(st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond, st.wMilliseconds, result);
end; // filetimeToDatetime

function diskSpaceAt(path:string):int64;
var
  tmp: int64;
  was: string;
begin
while not directoryExists(path) do
  begin
  was:=path;
  path:=extractFileDir(path);
  if path = was then break; // we're on the road to nowhere
  end;
if not getDiskFreeSpaceEx(pchar(path), result, tmp, NIL) then
  result:=-1;
end; // diskSpaceAt

// this is a blocking method for dns resolving. The Wsocket.DnsLookup() method provided by ICS is non-blocking 
function hostToIP(name: string):string;
type
  Tbytes = array [0..3] of byte;
var
  hostEnt: PHostEnt;
  addr: ^Tbytes;
begin
result:='';
hostEnt:=gethostbyname(Pansichar(ansiString(name)));
if (hostEnt = NIL) or (hostEnt^.h_addr_list = NIL) then exit;
addr:=pointer(hostEnt^.h_addr_list^);
if addr = NIL then exit;
result:=format('%d.%d.%d.%d', [addr[0], addr[1], addr[2], addr[3]]);
end; // hostToIP

function hostFromURL(s:string):string;
begin result:=reGet(s, '([a-z]+://)?([^/]+@)?([^/]+)', 3) end;

procedure fixFontFor(frm:Tform);
var
  nonClientMetrics: TNonClientMetrics;
begin
nonClientMetrics.cbSize:=sizeOf(nonClientMetrics);
systemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @nonClientMetrics, 0);
frm.font.handle:=createFontIndirect(nonClientMetrics.lfMessageFont);
if frm.scaled then
  frm.font.height:=nonClientMetrics.lfMessageFont.lfHeight;
end; // fixFontFor

function getAccount(user:string; evenGroups:boolean=FALSE):Paccount;
var
  i: integer;
begin
result:=NIL;
if user = '' then
  exit;
for i:=0 to length(accounts)-1 do
  if sameText(user, accounts[i].user) then
    begin
    if evenGroups or not accounts[i].group then
      result:= @accounts[i];
    exit;
    end;
end; // getAccount

function accountExists(user:string; evenGroups:boolean=FALSE):boolean;
begin result:=getAccount(user, evenGroups) <> NIL end;

// this function follows account linking until it finds and returns the account matching the stopCase
function accountRecursion(account:Paccount; stopCase:TaccountRecursionStopCase; data:pointer=NIL; data2:pointer=NIL):Paccount;

  function shouldStop():boolean;
  begin
  case stopCase of
    ARSC_REDIR: result:=account.redir > '';
    ARSC_NOLIMITS: result:=account.noLimits;
    ARSC_IN_SET: result:=stringExists(account.user, TstringDynArray(data), boolean(data2));
    else result:=FALSE;
    end;
  end;

var
  tocheck: TStringDynArray;
  i: integer;
begin
result:=NIL;
if (account = NIL) or not account.enabled then exit;
if shouldStop() then
  begin
  result:=account;
  exit;
  end;
i:=0;
toCheck:=account.link;
while i < length(toCheck) do
  begin
  account:=getAccount(toCheck[i], TRUE);
  inc(i);
  if (account = NIL) or not account.enabled then continue;
  if shouldStop() then
    begin
    result:=account;
    exit;
    end;
  addUniqueArray(toCheck, account.link);
  end;
end; // accountRecursion

function findEnabledLinkedAccount(account:Paccount; over:TStringDynArray; isSorted:boolean=FALSE):Paccount;
begin result:=accountRecursion(account, ARSC_IN_SET, over, boolToPtr(isSorted)) end;


type
  Tnewline = (NL_UNK, NL_D, NL_A, NL_DA, NL_MIXED);

function newlineType(s:string):Tnewline;
var
  d, a, l: integer;
begin
d:=pos(#13,s);
a:=pos(#10,s);
if d = 0 then
  if a = 0 then
    result:=NL_UNK
  else
    result:=NL_A
else
  if a = 0 then
    result:=NL_D
  else
    if a = 1 then
      result:=NL_MIXED
    else
      begin
      result:=NL_MIXED;
      // search for an unpaired #10
      while (a > 0) and (s[a-1] = #13) do
        a:=posEx(#10, s, a+1);
      if a > 0 then exit;
      // search for an unpaired #13
      l:=length(s);
      while (d < l) and (s[d+1] = #10) do
        d:=posEx(#13, s, d+1);
      if d > 0 then exit;
      // ok, all is paired
      result:=NL_DA;
      end;
end; // newlineType

function escapeNL(s:string):string;
begin
s:=replaceStr(s, '\','\\');
case newlineType(s) of
  NL_D: s:=replaceStr(s, #13,'\n');
  NL_A: s:=replaceStr(s, #10,'\n');
  NL_DA: s:=replaceStr(s, #13#10,'\n');
  NL_MIXED: s:=replaceStr(replaceStr(replaceStr(s, #13#10,'\n'), #13,'\n'), #10,'\n'); // bad case, we do our best
  end;
result:=s;
end; // escapeNL

function unescapeNL(s:string):string;
var
  o, n: integer;
begin
o:=1;
while o <= length(s) do
  begin
  o:=posEx('\n', s, o);
  if o = 0 then break;
  n:=1;
  while (o-n > 0) and (s[o-n] = '\') do inc(n);
  if odd(n) then
    begin
    s[o]:=#13;
    s[o+1]:=#10;
    end;
  inc(o,2);
  end;
result:=xtpl(s, ['\\','\']);
end; // unescapeNL

function htmlEncode(const s:string):string;
var
  i: integer;
  p: string;
  fs: TfastStringAppend;
begin
fs:=TfastStringAppend.create;
try
  for i:=1 to length(s) do
    begin
    case s[i] of
      '&': p:='&amp;';
      '<': p:='&lt;';
      '>': p:='&gt;';
      '"': p:='&quot;';
      '''': p:='&#039;';
      else p:=s[i];
      end;
    fs.append(p);
    end;
  result:=fs.get();
finally fs.free end;
end; // htmlEncode

procedure enforceNUL(var s:string);
begin
  if s>'' then
    setLength(s, strLen(PWideChar(@s[1])))
end; // enforceNUL

procedure enforceNUL(var s:RawByteString);
begin
  if s>'' then
    setLength(s, ansistrings.strLen(PAnsiChar(@s[1])))
end; // enforceNUL

function bmp2ico32(bitmap: Tbitmap): HICON;
var
  il: THandle;
  i: Integer;
begin
  il := ImageList_Create(min(bitmap.Width, bitmap.Height), min(bitmap.Width,bitmap.Height), ILC_COLOR32 or ILC_MASK, 0, 0);
  i := ImageList_Add(il, bitmap.Handle, bitmap.MaskHandle);
  if i >= 0 then
    Result := ImageList_ExtractIcon(0, il, i)
   else
    Result := 0;
  ImageList_Destroy(il);
end;

function bmp2ico24(bitmap: Tbitmap): HICON;
var
  il: THandle;
  i: Integer;
begin
//  il := ImageList_Create(Min(bitmap.Width, iconX), Min(bitmap.Height, iconY), ILC_COLOR32 or ILC_MASK, 0, 0);
  il := ImageList_Create(min(bitmap.Width, bitmap.Height), min(bitmap.Width,bitmap.Height), ILC_COLOR24 or ILC_MASK, 0, 0);
  i := ImageList_Add(il, bitmap.Handle, bitmap.MaskHandle);
  if i >= 0 then
    Result := ImageList_ExtractIcon(0, il, i)
   else
    Result := 0;
  ImageList_Destroy(il);
end;

function strSHA256(s:string):string;
//begin result:=THashSHA2.GetHashString(s) end;
begin result:= SHA256PassLS(UTF8Encode(s)) end;

//function strMD5(s:string):string;
//begin result:=THashMD5.GetHashString(s) end;

function strMD5(s:string):string;
begin Result := LowerCase(MD5PassHS(UTF8Encode(s))); end;


function b64utf8(const s:string): RawByteString;
begin result:=Base64EncodeString(UTF8encode(s)); end;

function b64utf8W(const s:string): UnicodeString;
begin result:=Base64EncodeString(UTF8encode(s)); end;

function b64U(const b: RawByteString): UnicodeString;
begin result:=Base64EncodeString(b); end;

function b64R(const b: RawByteString): RawByteString;
begin result:=Base64EncodeString(b); end;

function decodeB64utf8(const s: RawByteString):string; OverLoad;
begin result:=UnUTF(Base64DecodeString(s)); end;

function decodeB64utf8(const s: String):string; OverLoad;
begin result:=UnUTF(Base64DecodeString(s)); end;

function decodeB64(const s: String): RawByteString; OverLoad;
begin result:=Base64DecodeString(s); end;

function decodeB64(const s: RawByteString): RawByteString; OverLoad;
begin result:=Base64DecodeString(s); end;

var
  TZinfo:TTimeZoneInformation;

INITIALIZATION
//  sysutils.DecimalSeparator:='.'; // standardize
  sysutils.FormatSettings.DecimalSeparator:='.'; // standardize

ipToInt_cache:=THashedStringList.Create;
ipToInt_cache.Sorted:=TRUE;
ipToInt_cache.Duplicates:=dupIgnore;
inputQueryLongdlg:=TlonginputFrm.create(NIL); // mainFrm is NIL at this time

// calculate GMToffset
GetTimeZoneInformation(TZinfo);
case GetTimeZoneInformation(TZInfo) of
  TIME_ZONE_ID_STANDARD: GMToffset:=TZInfo.StandardBias;
  TIME_ZONE_ID_DAYLIGHT: GMToffset:=TZInfo.DaylightBias;
  else GMToffset:=0;
  end;
GMToffset:=-(TZinfo.bias+GMToffset);

// windows version detect
case byte(getversion()) of
  1..4: winVersion:=WV_LOWER;
  5: winVersion:=WV_2000;
  6: case hibyte(getversion()) of
      0: winVersion:=WV_VISTA;
      1: winVersion:=WV_SEVEN;
      else winVersion:=WV_HIGHER;
      end;
  7..15: winVersion:=WV_HIGHER;
  end;

trayMsg:='%ip%'
  +trayNL+'Uptime: %uptime%'
  +trayNL+'Downloads: %downloads%';

//fastmm4.SuppressMessageBoxes:=TRUE;

FINALIZATION
freeAndNIL(ipToInt_cache);
freeAndNIL(inputQueryLongdlg);
freeAndNIL(onlyDotsRE);

end.
