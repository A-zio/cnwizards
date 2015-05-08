{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2015 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnCodeGenerators;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ���ʽ��������������� CnCodeGenerators
* ��Ԫ���ߣ�CnPack������
* ��    ע���õ�Ԫʵ���˴����ʽ������Ĳ���������
* ����ƽ̨��Win2003 + Delphi 5.0
* ���ݲ��ԣ�not test yet
* �� �� ����not test hell
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2007-10-13 V1.0
*               ���뻻�еĲ������ô����������ơ�
*           2003-12-16 V0.1
*               �������򵥵Ĵ�������д���Լ����������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, CnCodeFormatRules;

type
  TCnAfterWriteEvent = procedure (Sender: TObject; IsWriteln: Boolean;
    PrefixSpaces: Integer) of object;

  TCnCodeGenerator = class
  private
    FCode: TStrings;
    FLock: Word;
    FColumnPos: Integer;            // ��ǰ��ֵ��ע������ʵ�������һ��һ�£���Ϊ FCode �е��ַ������ܴ��س�����
    FActualColumn: Integer;         // ��ǰʵ����ֵ������ FCode ���һ�����һ�� #13#10 �������
    FCodeWrapMode: TCodeWrapMode;
    FPrevStr: string;
    FPrevRow: Integer;
    FPrevColumn: Integer;
    FPrevIsCRLFEnd: Boolean;
    FLastNoAutoWrapLine: Integer;
    FLastExceedPosition: Integer; // ���г��� WrapWidth �ĵ㣬����β����ʱ�������»���ʹ��
    FAutoWrapLines: TList; // ��¼�Զ����е��кţ�������Ѱ���һ�η��Զ����е�������
    FOnAfterWrite: TCnAfterWriteEvent;
    FAutoWrapButNoIndent: Boolean;
    function GetCurIndentSpace: Integer;
    function GetLockedCount: Word;
    function GetPrevColumn: Integer;
    function GetPrevRow: Integer;
    function GetCurrColumn: Integer;
    function GetCurrRow: Integer;
    function GetLastIndentSpace: Integer;
    // �Զ���������ʱ���ҳ���һ�����Զ����е�������
    procedure CalcLastNoAutoIndentLine;
    function GetLastIndentSpaceWithOutLineHeadCRLF: Integer;
  protected
    procedure DoAfterWrite(IsWriteln: Boolean; PrefixSpaces: Integer = 0); virtual;
    // �� IsWriteln Ϊ True ʱ��PrefixSpaces ��ʾ����д��س������д�Ŀո���������Ϊ 0
  public
    constructor Create;
    destructor Destroy; override;

    procedure Reset;
    procedure Write(const Text: string; BeforeSpaceCount:Word = 0;
      AfterSpaceCount: Word = 0);
    procedure InternalWriteln;
    procedure Writeln;
    function SourcePos: Word;
    {* ���һ�й��������������δʹ��}
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(FileName: string);
    procedure SaveToStrings(AStrings: TStrings);

    function CopyPartOut(StartRow, StartColumn, EndRow, EndColumn: Integer): string;
    {* �������ָ����ֹλ�ø������ݳ�����ֱ��ʹ�� Row/Column �������
       �߼��ϣ����Ʒ�Χ�ڵ����ݲ����� EndColumn ��ָ���ַ�}

    procedure BackSpaceLastSpaces;
    {* �����һ�е���β�ո�ɾ��һ����������Ϊ�Ѿ�����˴��ո�����ݣ�������βע�ͺ��Ƶ�����}

    procedure LockOutput;
    procedure UnLockOutput;

    procedure ClearOutputLock;
    {* ֱ�ӽ������������}

    property LockedCount: Word read GetLockedCount;
    {* �������}
    property ColumnPos: Integer read FColumnPos;
    {* ��ǰ���ĺ���λ�ã����ڻ��С�ֵΪ��ǰ�г��ȣ���ǰ�иջ���������ʱΪ 0��
       �������Ϊָ��ǰ�Ѿ�������ݵĽ��ں��λ�á�����Ϊ StartCol ʱ�ü�һ��
       ����Ϊ EndCol ʱ����Ϊ��ǰ���ַ����±��һ��ʼ�ĵ� FColumnPos ���ַ���
       ������ CopyPartout �����һ���ַ�����������һ}
    property CurIndentSpace: Integer read GetCurIndentSpace;
    {* ��ǰ����ǰ��Ŀո���}
    property LastIndentSpace: Integer read GetLastIndentSpace;
    {* ��һ�����Զ����е��е���ǰ��Ŀո���}
    property LastIndentSpaceWithOutLineHeadCRLF: Integer read GetLastIndentSpaceWithOutLineHeadCRLF;
    {* ��һ�����Զ����е��е���ǰ��Ŀո�������������β�ǻس������}
    property CodeWrapMode: TCodeWrapMode read FCodeWrapMode write FCodeWrapMode;
    {* ���뻻�е�����}

    property PrevRow: Integer read GetPrevRow;
    {* һ�� Write �ɹ���д֮ǰ�Ĺ���кţ�0 ��ʼ��
      ������ʵ�������������Ϊ Write ��������д�س����з�}
    property PrevColumn: Integer read GetPrevColumn;
    {* һ�� Write �ɹ���д֮ǰ�Ĺ���кţ�0 ��ʼ}
    property CurrRow: Integer read GetCurrRow;
    {* һ�� Write �ɹ���д֮��Ĺ���кţ�0 ��ʼ��
      ������ʵ�������������Ϊ Write ��������д�س����з�}
    property CurrColumn: Integer read GetCurrColumn;
    {* һ�� Write �ɹ���д֮��Ĺ���кţ�0 ��ʼ}

    property AutoWrapButNoIndent: Boolean read FAutoWrapButNoIndent write FAutoWrapButNoIndent;
    {* ����ʱ�Զ�����ʱ�Ƿ��������������ƣ��� uses ���� True}
    property OnAfterWrite: TCnAfterWriteEvent read FOnAfterWrite write FOnAfterWrite;
    {* д����һ�γɹ��󱻵���}
  end;

implementation

{ TCnCodeGenerator }

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  CRLF = #13#10;
  NOTLineHeadChars: set of Char = ['.', ',', ':', ')', ']', ';'];
  NOTLineTailChars: set of Char = ['.', '(', '['];

procedure TCnCodeGenerator.BackSpaceLastSpaces;
var
  S: string;
  Len: Integer;
begin
  if FCode.Count > 0 then
  begin
    S := FCode[FCode.Count - 1];
    Len := Length(S);
    if (Len > 0) and (S[Len] = ' ') then
      FCode[FCode.Count - 1] := TrimRight(S);
  end;
end;

procedure TCnCodeGenerator.CalcLastNoAutoIndentLine;
var
  I: Integer;
  MaxAuto, MaxLine: Integer;
begin
  if FAutoWrapLines.Count = 0 then // ���û�Զ����е��У������һ��
  begin
    FLastNoAutoWrapLine := FCode.Count - 1;
    Exit;
  end;

  MaxAuto := Integer(FAutoWrapLines[FAutoWrapLines.Count - 1]);
  MaxLine := FCode.Count - 1;

  if MaxLine > MaxAuto then // ������һ���Ƿ��Զ����е��У�������
  begin
    FLastNoAutoWrapLine := MaxLine;
    Exit;
  end
  else if MaxLine = MaxAuto then
  begin
  for I := FAutoWrapLines.Count - 1 downto 0 do
  begin
    // �ҵ����� FAutoWrapLines ��ͷ����һ��
    if MaxAuto > Integer(FAutoWrapLines[I]) then
    begin
      FLastNoAutoWrapLine := MaxAuto;
      Exit;
    end;
    Dec(MaxAuto);
  end;
  end
  else
    FLastNoAutoWrapLine := -1; // Should not here
end;

procedure TCnCodeGenerator.ClearOutputLock;
begin
  FLock := 0;
end;

function TCnCodeGenerator.CopyPartOut(StartRow, StartColumn, EndRow,
  EndColumn: Integer): string;
var
  I: Integer;
begin
  Result := '';
  if EndRow > FCode.Count - 1 then
    EndRow := FCode.Count - 1;
    
  if EndRow < StartRow then Exit;
  if (EndRow = StartRow) and (EndColumn < StartColumn) then Exit;

  Inc(StartColumn); // �Ƿ��һ�� FColumnPos ��ע��
  // Inc(EndColumn);

  if EndRow = StartRow then
    Result := Copy(FCode[StartRow], StartColumn, EndColumn - StartColumn + 1) // ��һ����Ϊ StartColumn ����һ
  else
  begin
    for I := StartRow to EndRow do
    begin
      if I = StartRow then
        Result := Result + Copy(FCode[StartRow], StartColumn, MaxInt) + CRLF
      else if I = EndRow then
        Result := Result + Copy(FCode[EndRow], 1, EndColumn)
      else
        Result := Result + FCode[I] + CRLF;
    end;
  end;
end;

constructor TCnCodeGenerator.Create;
begin
  FCode := TStringList.Create;
  FLock := 0;
  FCodeWrapMode := cwmNone;
  FAutoWrapLines := TList.Create;
end;

destructor TCnCodeGenerator.Destroy;
begin
  FAutoWrapLines.Free;
  FCode.Free;
  inherited;
end;

procedure TCnCodeGenerator.DoAfterWrite(IsWriteln: Boolean; PrefixSpaces: Integer);
begin
  if Assigned(FOnAfterWrite) then
    FOnAfterWrite(Self, IsWriteln, PrefixSpaces);
end;

function TCnCodeGenerator.GetCurIndentSpace: Integer;
var
  I, Len: Integer;
begin
  Result := 0;
  if FCode.Count > 0 then
  begin
    Len := Length(FCode[FCode.Count - 1]);
    if Len > 0 then
    begin
      for I := 1 to Len do
        if FCode[FCode.Count - 1][I] in [' ', #09] then
          Inc(Result)
        else
          Exit;
    end;
  end;
end;

function TCnCodeGenerator.GetCurrColumn: Integer;
begin
  Result := FColumnPos;
end;

function TCnCodeGenerator.GetCurrRow: Integer;
begin
  Result := FCode.Count - 1;
end;

function TCnCodeGenerator.GetLastIndentSpace: Integer;
var
  I, Len: Integer;
  S: string;
begin
  Result := 0;
  CalcLastNoAutoIndentLine;
  if (FCode.Count > 0) and (FLastNoAutoWrapLine >= 0) and
    (FLastNoAutoWrapLine < FCode.Count) then
  begin
    S := FCode[FLastNoAutoWrapLine];
    if Pos(CRLF, S) > 0 then
      S := Copy(S, LastDelimiter(#10, S) + 1, MaxInt);

    Len := Length(S);    // ���ܼ������һ�У���������һ�е����һ�����з��ź�Ŀո񳤶�������
    if Len > 0 then
    begin
      for I := 1 to Len do
        if S[I] in [' ', #09] then
          Inc(Result)
        else
          Exit;
    end;
  end;
end;

function TCnCodeGenerator.GetLastIndentSpaceWithOutLineHeadCRLF: Integer;
var
  I, Len: Integer;
  S: string;
begin
  Result := 0;
  S := FCode[FCode.Count - 1];
  if (S = '') and (FCode.Count > 1) then
    S := FCode[FCode.Count - 2];

  Len := Length(S);  // ȥ������β���ĵ����س�����
  if Len > 2 then
    if (S[Len - 1] = #13) and (S[Len] = #10) then
      Delete(S, Len - 1, 2);

  if Pos(CRLF, S) > 0 then
    S := Copy(S, LastDelimiter(#10, S) + 1, MaxInt);

  Len := Length(S);    // �����һ�е����һ�����з��ź�Ŀո񳤶�������
  if Len > 0 then
  begin
    for I := 1 to Len do
      if S[I] in [' ', #09] then
        Inc(Result)
      else
        Exit;
  end;

end;

function TCnCodeGenerator.GetLockedCount: Word;
begin
  Result := FLock;
end;

function TCnCodeGenerator.GetPrevColumn: Integer;
begin
  Result := FPrevColumn;
end;

function TCnCodeGenerator.GetPrevRow: Integer;
begin
  Result := FPrevRow;
end;

procedure TCnCodeGenerator.InternalWriteln;
begin
  if FLock <> 0 then Exit;

  FCode[FCode.Count - 1] := TrimRight(FCode[FCode.Count - 1]);
  FCode.Add('');

  FColumnPos := 0;
  FActualColumn := 0;
  FLastExceedPosition := 0;
end;

procedure TCnCodeGenerator.LockOutput;
begin
  Inc(FLock);
end;

procedure TCnCodeGenerator.Reset;
begin
  FCode.Clear;
  FAutoWrapLines.Clear;
end;

procedure TCnCodeGenerator.SaveToFile(FileName: String);
begin
  FCode.SaveToFile(FileName);
end;

procedure TCnCodeGenerator.SaveToStream(Stream: TStream);
begin
  FCode.SaveToStream(Stream {$IFDEF UNICODE}, TEncoding.Unicode {$ENDIF});
end;

procedure TCnCodeGenerator.SaveToStrings(AStrings: TStrings);
begin
  AStrings.Assign(FCode);
end;

function TCnCodeGenerator.SourcePos: Word;
begin
  Result := Length(FCode[FCode.Count - 1]);
end;

procedure TCnCodeGenerator.UnLockOutput;
begin
  Dec(FLock);
end;

procedure TCnCodeGenerator.Write(const Text: string; BeforeSpaceCount,
  AfterSpaceCount: Word);
var
  Str, WrapStr, Tmp: string;
  ThisCanBeHead, PrevCanBeTail, IsCRLFEnd: Boolean;
  Len, ALen, Blanks: Integer;

  function ExceedLineWrap(Width: Integer): Boolean;
  begin
    Result := ((FActualColumn <= Width) and
      (FActualColumn + Len > Width)) or
      (FActualColumn > Width);
  end;

  // ���һ���ַ������һ�еĳ���
  function ActualColumn(const S: string): Integer;
  var
    LPos: Integer;
  begin
    if Pos(CRLF, S) > 0 then
    begin
      LPos := LastDelimiter(#10, S);
      Result := Length(S) - LPos;
    end
    else
      Result := Length(S);
  end;

  // ���һ���ַ������һ�еĳ���
  function AnsiActualColumn(const S: AnsiString): Integer;
  var
    LPos: Integer;
  begin
    if Pos(CRLF, S) > 0 then
    begin
      LPos := LastDelimiter(#10, S);
      Result := Length(S) - LPos;
    end
    else
      Result := Length(S);
  end;

  // ĳЩ�����ַ���������ͷ
  function StrCanBeHead(const S: string): Boolean;
  begin
    Result := True;
    if (Length(S) = 1) and (S[1] in NOTLineHeadChars) then
      Result := False;
  end;

  // ĳЩ�����ַ���������β
  function StrCanBeTail(const S: string): Boolean;
  begin
    Result := True;
    if (Length(S) = 1) and (S[1] in NOTLineTailChars) then
      Result := False;
  end;

  // �Ƿ��ַ�����������һ���س����в�������ֻ�����ո�� Tab
  function IsTextCRLFSpace(const S: string; out TrailBlanks: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    TrailBlanks := 0;
    I := Pos(CRLF, S);
    if I <= 0 then // �޻س����У����� False
      Exit;

    for I := 1 to Length(S) do
      if not (S[I] in [' ', #09, #13, #10]) then
        Exit;

    Result := True;
    I := LastDelimiter(#10, S);
    TrailBlanks := Length(S) - I;
  end;

begin
  if FLock <> 0 then Exit;
  
  if FCode.Count = 0 then
    FCode.Add('');

  ThisCanBeHead := StrCanBeHead(Text);
  PrevCanBeTail := StrCanBeTail(FPrevStr);

  IsCRLFEnd := False;
  ALen := Length(Text);
  if ALen > 2 then
    IsCRLFEnd := (Text[ALen - 1] = #13) and (Text[ALen] = #10);

  Str := Format('%s%s%s', [StringOfChar(' ', BeforeSpaceCount), Text,
    StringOfChar(' ', AfterSpaceCount)]);

{$IFDEF UNICODE}
  Len := AnsiActualColumn(AnsiString(TrimRight(Str))); // Unicode ģʽ�£�ת�� Ansi ���Ȳŷ���һ�����
{$ELSE}
  Len := ActualColumn(TrimRight(Str)); // Ansi ģʽ�£�����ֱ�ӷ���һ�����
{$ENDIF}

  FPrevRow := FCode.Count - 1;
  if FCodeWrapMode = cwmNone then
  begin
    // ���Զ�����ʱ�����账��
  end
  else if (FCodeWrapMode = cwmSimple) or ( (FCodeWrapMode = cwmAdvanced) and
    (CnPascalCodeForRule.WrapWidth >= CnPascalCodeForRule.WrapNewLineWidth) ) then
  begin
    // �򵥻��У����ӻ��е���ֵ���ò��ԣ��ͼ��ж��Ƿ񳬳����
    if (FPrevStr <> '.') and ExceedLineWrap(CnPascalCodeForRule.WrapWidth)
      and ThisCanBeHead and PrevCanBeTail then // Dot in unitname should not new line.
    begin
      // ���ϴ�������ַ�������β���ұ���������ַ�������ͷ���Ż���
      if FAutoWrapButNoIndent then
      begin
        Str := StringOfChar(' ', CurIndentSpace) + TrimLeft(Str);
        // ����ԭ�е���������Ҫֱ��������һ�񣬱��� uses �����ֲ���Ҫ��������
      end
      else
      begin
        Str := StringOfChar(' ', LastIndentSpace + CnPascalCodeForRule.TabSpaceCount)
          + TrimLeft(Str); // �Զ����к����ԭ�еĿո�Ͳ���Ҫ��
        // �ҳ���һ�η��Զ������������������Ǽ򵥵���һ������ֵ�������������
      end;
      InternalWriteln;
      FAutoWrapLines.Add(Pointer(FCode.Count - 1)); // �Զ����е��к�Ҫ��¼
    end;
  end
  else if FCodeWrapMode = cwmAdvanced then
  begin
    // �߼����������к󣬻��ݵ���С�д���ʼ����
    if ExceedLineWrap(CnPascalCodeForRule.WrapWidth)
      and ThisCanBeHead and PrevCanBeTail and (FLastExceedPosition = 0) then
    begin
      // ��һ�γ�С��ʱ�����ҡ��ϴ�������ַ�������β���ұ���������ַ�������ͷ��ʱ���ճ��������¼���ǰС�д����ݵ�λ��
      // ����ַ���������β����˴�������
      FLastExceedPosition := FColumnPos;
    end
    else if (FPrevStr <> '.') and (FLastExceedPosition > 0) and // �пɻ���֮���Ż�
      ExceedLineWrap(CnPascalCodeForRule.WrapNewLineWidth) then
    begin
      WrapStr := Copy(FCode[FCode.Count - 1], FLastExceedPosition + 1, MaxInt);
      Tmp := FCode[FCode.Count - 1];
      Delete(Tmp, FLastExceedPosition + 1, MaxInt);
      FCode[FCode.Count - 1] := Tmp;

      if FAutoWrapButNoIndent then
      begin
        Str := StringOfChar(' ', CurIndentSpace) + TrimLeft(WrapStr) + Str;
        // ����ԭ�е���������Ҫֱ��������һ�񣬱��� uses �����ֲ���Ҫ��������
      end
      else
      begin
        Str := StringOfChar(' ', LastIndentSpace + CnPascalCodeForRule.TabSpaceCount)
          + TrimLeft(WrapStr) + Str; // �Զ����к����ԭ�еĿո�Ͳ���Ҫ��
        // �ҳ���һ�η��Զ������������������Ǽ򵥵���һ������ֵ�������������
      end;
      InternalWriteln;
      FAutoWrapLines.Add(Pointer(FCode.Count - 1)); // �Զ����е��к�Ҫ��¼
    end;

{
    // δ�����ճ����������һ������������ǻس���β������//��βע�ͣ���
    // ���������Ҫ���ϱ�Ҫ�Ŀո������������軻��
    if FPrevIsCRLFEnd then
    begin
      Str := StringOfChar(' ', LastIndentSpaceWithOutLineHeadCRLF) + TrimLeft(Str);
      // ͬ���ҳ���һ�η��Զ���������������������β�ո񣩡�
      // �����Ǽ򵥵���һ������ֵ�������������
      // FAutoWrapLines.Add(Pointer(FCode.Count - 1));  // �ټ�¼һ��
    end;
}
  end;

  FCode[FCode.Count - 1] :=
    Format('%s%s', [FCode[FCode.Count - 1], Str]);

  FPrevColumn := FColumnPos;
  FPrevIsCRLFEnd := IsCRLFEnd;

//{$IFDEF UNICODE}
//  // Unicode ģʽ�£�ת�� Ansi ���Ȳŷ���һ�����
//  FColumnPos := Length(AnsiString(FCode[FCode.Count - 1]));
//{$ELSE}
// Ansi ģʽ�£�����ֱ�ӷ���һ�����

  FPrevStr := Text;

  // �������д��������лس����У����ϴθû��е�λ������
  if Pos(CRLF, Str) > 0 then
    FLastExceedPosition := 0;

  Str := FCode[FCode.Count - 1];
  FColumnPos := Length(Str);
  FActualColumn := ActualColumn(Str);

  IsCRLFEnd := IsTextCRLFSpace(Text, Blanks);
  DoAfterWrite(IsCRLFEnd, Blanks);

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('String Wrote from %d %d to %d %d: %s', [FPrevRow, FPrevColumn,
//    GetCurrRow, GetCurrColumn, Str]);
//  CnDebugger.LogMsg(CopyPartOut(FPrevRow, FPrevColumn, GetCurrRow, GetCurrColumn));
{$ENDIF}
end;

procedure TCnCodeGenerator.Writeln;
begin
  if FLock <> 0 then Exit;

  // Write(S, BeforeSpaceCount, AfterSpaceCount);
  // delete trailing blanks
  FCode[FCode.Count - 1] := TrimRight(FCode[FCode.Count - 1]);
  FPrevRow := FCode.Count - 1;

  FCode.Add('');

  FPrevColumn := FColumnPos;
  FColumnPos := 0;
  FLastExceedPosition := 0;
  
  DoAfterWrite(True);
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('NewLine Wrote from %d %d to %d %d', [FPrevRow, FPrevColumn,
//    GetCurrRow, GetCurrColumn]);
{$ENDIF}
end;

end.
