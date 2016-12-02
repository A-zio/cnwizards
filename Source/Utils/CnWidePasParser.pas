{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2016 CnPack ������                       }
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

unit CnWidePasParser;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�Pas Դ����������� Unicode �汾
* ��Ԫ���ߣ��ܾ��� zjy@cnpack.org
* ��    ע����д�� CnPasCodeParser��ȥ����һ���������ĺ���
* ����ƽ̨��Win7 + Delphi 2009
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id: CnPasCodeParser.pas 1385 2013-12-31 15:39:02Z liuxiaoshanzhashu@gmail.com $
* �޸ļ�¼��2015.04.25 V1.1
*               ���� WideString ʵ��
*           2015.04.10
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, mPasLex, CnPasWideLex, mwBCBTokenList,
  Contnrs, CnFastList, CnPasCodeParser, CnQueue;

type
{$IFDEF UNICODE}
  CnWideString = string;
{$ELSE}
  CnWideString = WideString;
{$ENDIF}

  TCnWidePasToken = class(TPersistent)
  {* ����һ Token �Ľṹ������Ϣ}
  private
    FEditAnsiCol: Integer;
    FTag: Integer;
    function GetToken: PWideChar;
  protected
    FCppTokenKind: TCTokenKind;
    FCompDirectiveType: TCnCompDirectiveType;
    FCharIndex: Integer;
    FAnsiIndex: Integer;
    FEditCol: Integer;
    FEditLine: Integer;
    FItemIndex: Integer;
    FItemLayer: Integer;
    FLineNumber: Integer;
    FMethodLayer: Integer;
    FToken: array[0..CN_TOKEN_MAX_SIZE] of WideChar;
    FTokenID: TTokenKind;
    FTokenPos: Integer;
    FIsMethodStart: Boolean;
    FIsMethodClose: Boolean;
    FIsBlockStart: Boolean;
    FIsBlockClose: Boolean;
    FUseAsC: Boolean;
  public
    procedure Clear;

    property UseAsC: Boolean read FUseAsC;
    {* �Ƿ��� C ��ʽ�Ľ�����Ĭ�ϲ���}
    property LineNumber: Integer read FLineNumber; // Start 0
    {* �����кţ����㿪ʼ���� ParseSource ������� }
    property CharIndex: Integer read FCharIndex;   // Start 0
    {* �ӱ��п�ʼ�����ַ�λ�ã����㿪ʼ���� ParseSource �ھ���չ�� Tab ������� }
    property AnsiIndex: Integer read FAnsiIndex;   // Start 0
    {* �ӱ��п�ʼ���� Ansi �ַ�λ�ã����㿪ʼ���������}

    property EditCol: Integer read FEditCol write FEditCol;
    {* �����У���һ��ʼ�������ת��������һ���Ӧ EditPos}
    property EditLine: Integer read FEditLine write FEditLine;
    {* �����У���һ��ʼ�������ת��������һ���Ӧ EditPos}
    property EditAnsiCol: Integer read FEditAnsiCol write FEditAnsiCol;
    {* ���� Ansi �У���һ��ʼ�������ת�����������ڻ��Ƶĳ���}

    property ItemIndex: Integer read FItemIndex;
    {* ������ Parser �е���� }
    property ItemLayer: Integer read FItemLayer;
    {* ���ڸ����Ĳ�Σ��������̡������Լ�����飬��ֱ���������Ƹ�����Σ������κο���ʱ������㣩Ϊ 0 }
    property MethodLayer: Integer read FMethodLayer;
    {* ���ں�����Ƕ�ײ�Σ������ĺ�����Ϊ 1�������������� }
    property Token: PWideChar read GetToken;
    {* �� Token ���ַ������� }
    property TokenID: TTokenKind read FTokenID;
    {* Token ���﷨���� }
    property CppTokenKind: TCTokenKind read FCppTokenKind;
    {* ��Ϊ C �� Token ʹ��ʱ�� CToken ����}
    property TokenPos: Integer read FTokenPos;
    {* Token �������ļ��е�����λ�� }
    property IsBlockStart: Boolean read FIsBlockStart;
    {* �Ƿ���һ���ƥ���������Ŀ�ʼ }
    property IsBlockClose: Boolean read FIsBlockClose;
    {* �Ƿ���һ���ƥ���������Ľ��� }
    property IsMethodStart: Boolean read FIsMethodStart;
    {* �Ƿ��Ǻ������̵Ŀ�ʼ������ function �� begin/asm ����� }
    property IsMethodClose: Boolean read FIsMethodClose;
    {* �Ƿ��Ǻ������̵Ľ��� }
    property CompDirectivtType: TCnCompDirectiveType read FCompDirectiveType write FCompDirectiveType;
    {* ���������� Pascal ����ָ��ʱ�������������ϸ���ͣ��������������ⲿ�������}
    property Tag: Integer read FTag write FTag;
    {* Tag ��ǣ���������ⳡ��ʹ��}
  end;

//==============================================================================
// Pascal Unicode �ļ��ṹ����������
//==============================================================================

  { TCnPasStructureParser }

  TCnWidePasStructParser = class(TObject)
  {* ���� TCnPasWideLex �����﷨�����õ����� Token ��λ����Ϣ}
  private
    FSupportUnicodeIdent: Boolean;
    FBlockCloseToken: TCnWidePasToken;
    FBlockStartToken: TCnWidePasToken;
    FChildMethodCloseToken: TCnWidePasToken;
    FChildMethodStartToken: TCnWidePasToken;
    FCurrentChildMethod: CnWideString;
    FCurrentMethod: CnWideString;
    FKeyOnly: Boolean;
    FList: TCnList;
    FMethodCloseToken: TCnWidePasToken;
    FMethodStartToken: TCnWidePasToken;
    FSource: CnWideString;
    FInnerBlockCloseToken: TCnWidePasToken;
    FInnerBlockStartToken: TCnWidePasToken;
    FUseTabKey: Boolean;
    FTabWidth: Integer;
    FMethodStack, FBlockStack, FMidBlockStack, FProcStack: TCnObjectStack;
    function GetCount: Integer;
    function GetToken(Index: Integer): TCnWidePasToken;
  public
    constructor Create(SupportUnicodeIdent: Boolean = True);
    destructor Destroy; override;
    procedure Clear;
    procedure ParseSource(ASource: PWideChar; AIsDpr, AKeyOnly: Boolean);
    function FindCurrentDeclaration(LineNumber, WideCharIndex: Integer): CnWideString;
    {* ����ָ�����λ�����ڵ�������LineNumber 1 ��ʼ��WideCharIndex 0 ��ʼ�������� CharPos��
       ��Ҫ���� WideChar ƫ�ơ�D2005~2007 �£�CursorPos.Col �� ConverPos ��õ�����
       Utf8 �� CharPos ƫ�ƣ�2009 ������ ConverPos �õ����ҵ� Ansi ƫ�ƣ�������ֱ���á�
       ǰ����Ҫת�� WideChar ƫ�ƣ�����ֻ�ܰ� CursorPos.Col - 1 ���� Ansi �� CharIndex��
       ��ת�� WideChar ��ƫ��}
    procedure FindCurrentBlock(LineNumber, WideCharIndex: Integer);
    {* ����ָ�����λ�����ڵĿ飬LineNumber 1 ��ʼ��WideCharIndex 0 ��ʼ�������� CharPos��
       ��Ҫ���� WideChar ƫ�ơ�D2005~2007 �£�CursorPos.Col �� ConverPos ��õ�����
       Utf8 �� CharPos ƫ�ƣ�2009 ������ ConverPos �õ����ҵ� Ansi ƫ�ƣ�������ֱ���á�
       ǰ����Ҫת�� WideChar ƫ�ƣ�����ֻ�ܰ� CursorPos.Col - 1 ���� Ansi �� CharIndex��
       ��ת�� WideChar ��ƫ��}
    function IndexOfToken(Token: TCnWidePasToken): Integer;
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TCnWidePasToken read GetToken;
    property MethodStartToken: TCnWidePasToken read FMethodStartToken;
    {* ��ǰ�����Ĺ��̻���}
    property MethodCloseToken: TCnWidePasToken read FMethodCloseToken;
    {* ��ǰ�����Ĺ��̻���}
    property ChildMethodStartToken: TCnWidePasToken read FChildMethodStartToken;
    {* ��ǰ���ڲ�Ĺ��̻�����������Ƕ�׹��̻�����������}
    property ChildMethodCloseToken: TCnWidePasToken read FChildMethodCloseToken;
    {* ��ǰ���ڲ�Ĺ��̻�����������Ƕ�׹��̻�����������}
    property BlockStartToken: TCnWidePasToken read FBlockStartToken;
    {* ��ǰ������}
    property BlockCloseToken: TCnWidePasToken read FBlockCloseToken;
    {* ��ǰ������}
    property InnerBlockStartToken: TCnWidePasToken read FInnerBlockStartToken;
    {* ��ǰ���ڲ��}
    property InnerBlockCloseToken: TCnWidePasToken read FInnerBlockCloseToken;
    {* ��ǰ���ڲ��}
    property CurrentMethod: CnWideString read FCurrentMethod;
    {* ��ǰ�����Ĺ��̻�����}
    property CurrentChildMethod: CnWideString read FCurrentChildMethod;
    {* ��ǰ���ڲ�Ĺ��̻�������������Ƕ�׹��̻�����������}
    property Source: CnWideString read FSource;
    property KeyOnly: Boolean read FKeyOnly;
    {* �Ƿ�ֻ������ؼ���}

    property UseTabKey: Boolean read FUseTabKey write FUseTabKey;
    {* �Ƿ��Ű洦�� Tab ���Ŀ�ȣ��粻������ Tab ��������Ϊ 1 ����}
    property TabWidth: Integer read FTabWidth write FTabWidth;
    {* Tab ���Ŀ��}
  end;

procedure ParseUnitUsesW(const Source: CnWideString; UsesList: TStrings;
  SupportUnicodeIdent: Boolean = False);
{* ����Դ���������õĵ�Ԫ}

implementation

type
  TProcObj = class
  private
    FLayer: Integer;
    FToken: TCnWidePasToken;
    FMatched: Boolean;
  public
    property Token: TCnWidePasToken read FToken write FToken;
    property Layer: Integer read FLayer write FLayer;
    property Matched: Boolean read FMatched write FMatched;
  end;

var
  TokenPool: TCnList;

function WideTrim(const S: CnWideString): CnWideString;
{$IFNDEF UNICODE}
var
  I, L: Integer;
{$ENDIF}
begin
{$IFDEF UNICODE}
  Result := Trim(S);
{$ELSE}
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  if I > L then Result := '' else
  begin
    while S[L] <= ' ' do Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
{$ENDIF}
end;

// �óط�ʽ������ PasTokens ���������
function CreatePasToken: TCnWidePasToken;
begin
  if TokenPool.Count > 0 then
  begin
    Result := TCnWidePasToken(TokenPool.Last);
    TokenPool.Delete(TokenPool.Count - 1);
  end
  else
    Result := TCnWidePasToken.Create;
end;

procedure FreePasToken(Token: TCnWidePasToken);
begin
  if Token <> nil then
  begin
    Token.Clear;
    TokenPool.Add(Token);
  end;
end;

procedure ClearTokenPool;
var
  I: Integer;
begin
  for I := 0 to TokenPool.Count - 1 do
    TObject(TokenPool[I]).Free;
end;

// NextNoJunk����ֻ����ע�ͣ���û��������ָ���������Ӵ˺����ɹ�����ָ��
procedure LexNextNoJunkWithoutCompDirect(Lex: TCnPasWideLex);
begin
  repeat
    Lex.Next;
  until not (Lex.TokenID in [tkSlashesComment, tkAnsiComment, tkBorComment, tkCRLF,
    tkCRLFCo, tkSpace, tkCompDirect]);
end;

//==============================================================================
// �ṹ����������
//==============================================================================

{ TCnPasStructureParser }

constructor TCnWidePasStructParser.Create(SupportUnicodeIdent: Boolean);
begin
  inherited Create;
  FList := TCnList.Create;
  FTabWidth := 2;
  FSupportUnicodeIdent := SupportUnicodeIdent;

  FMethodStack := TCnObjectStack.Create;
  FBlockStack := TCnObjectStack.Create;
  FMidBlockStack := TCnObjectStack.Create;
  FProcStack := TCnObjectStack.Create;
end;

destructor TCnWidePasStructParser.Destroy;
begin
  Clear;
  FMethodStack.Free;
  FBlockStack.Free;
  FMidBlockStack.Free;
  FProcStack.Free;
  FList.Free;
  inherited;
end;

procedure TCnWidePasStructParser.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FreePasToken(TCnWidePasToken(FList[I]));
  FList.Clear;

  FMethodStartToken := nil;
  FMethodCloseToken := nil;
  FChildMethodStartToken := nil;
  FChildMethodCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';
  FSource := '';
end;

function TCnWidePasStructParser.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnWidePasStructParser.GetToken(Index: Integer): TCnWidePasToken;
begin
  Result := TCnWidePasToken(FList[Index]);
end;

procedure TCnWidePasStructParser.ParseSource(ASource: PWideChar; AIsDpr, AKeyOnly:
  Boolean);
var
  Lex: TCnPasWideLex;
  ProcNestCount: Integer;
  Token, CurrMethod, CurrBlock, CurrMidBlock: TCnWidePasToken;
  Bookmark: TCnPasWideBookmark;
  IsClassOpen, IsClassDef, IsImpl, IsHelper: Boolean;
  IsRecordHelper, IsSealed, IsAbstract, IsRecord, IsForFunc: Boolean;
  DeclareWithEndLevel: Integer;
  PrevTokenID: TTokenKind;
  PrevTokenStr: CnWideString;
  AProcObj: TProcObj;

  procedure CalcCharIndexes(out ACharIndex: Integer; out AnAnsiIndex: Integer);
  var
    I, AnsiLen, WideLen: Integer;
  begin
    if FUseTabKey and (FTabWidth >= 2) then
    begin
      // ������ǰ�����ݽ��� Tab ��չ��
      I := Lex.LineStartOffset;
      AnsiLen := 0;
      WideLen := 0;
      while I < Lex.TokenPos do
      begin
        if (ASource[I] = #09) then
        begin
          AnsiLen := ((AnsiLen div FTabWidth) + 1) * FTabWidth;
          WideLen := ((WideLen div FTabWidth) + 1) * FTabWidth;
          // TODO: Wide �ַ����� Tab չ�������Ƿ���������
        end
        else
        begin
          Inc(WideLen);
          if Ord(ASource[I]) > $900 then
            Inc(AnsiLen, SizeOf(WideChar))
          else
            Inc(AnsiLen, SizeOf(AnsiChar));
        end;
        Inc(I);
      end;
      ACharIndex := WideLen;
      AnAnsiIndex := AnsiLen;
    end
    else
    begin
      ACharIndex := Lex.TokenPos - Lex.LineStartOffset;
      AnAnsiIndex := Lex.ColumnNumber - 1;
    end;
  end;

  procedure NewToken;
  var
    Len: Integer;
  begin
    Token := CreatePasToken;
    Token.FTokenPos := Lex.TokenPos;

    Len := Lex.TokenLength;
    if Len > CN_TOKEN_MAX_SIZE then
      Len := CN_TOKEN_MAX_SIZE;
    FillChar(Token.FToken[0], SizeOf(Token.FToken), 0);
    CopyMemory(@Token.FToken[0], Lex.TokenAddr, Len * SizeOf(WideChar));

    Token.FLineNumber := Lex.LineNumber - 1;              // 1 ��ʼ��� 0 ��ʼ
    CalcCharIndexes(Token.FCharIndex, Token.FAnsiIndex);
    // ��ֱ��ʹ�� Column ֱ���к����ԣ����Ǿ��� Tab չ������Ҳ������ 1 ��ʼ��� 0 ��ʼ

    Token.FTokenID := Lex.TokenID;
    Token.FItemIndex := FList.Count;
    if CurrBlock <> nil then
      Token.FItemLayer := CurrBlock.FItemLayer;
    if CurrMethod <> nil then
      Token.FMethodLayer := CurrMethod.FMethodLayer;
    FList.Add(Token);
  end;

  procedure DiscardToken(Forced: Boolean = False);
  begin
    if (AKeyOnly or Forced) and (FList.Count > 0) then
    begin
      FreePasToken(FList[FList.Count - 1]);
      FList.Delete(FList.Count - 1);
    end;
  end;

begin
  Clear;
  Lex := nil;
  PrevTokenID := tkProgram;

  try
    FSource := ASource;
    FKeyOnly := AKeyOnly;

    FMethodStack.Clear;
    FBlockStack.Clear;
    FMidBlockStack.Clear;
    FProcStack.Clear;  // �洢 procedure/function ʵ�ֵĹؼ����Լ���Ƕ�ײ��
    ProcNestCount := 0;

    Lex := TCnPasWideLex.Create(FSupportUnicodeIdent);
    Lex.Origin := PWideChar(ASource);

    DeclareWithEndLevel := 0; // Ƕ�׵���Ҫend�Ķ������
    Token := nil;
    CurrMethod := nil;
    CurrBlock := nil;
    CurrMidBlock := nil;
    IsImpl := AIsDpr;
    IsHelper := False;
    IsRecordHelper := False;

    while Lex.TokenID <> tkNull do
    begin
      if {IsImpl and } (Lex.TokenID in [tkCompDirect, // Allow CompDirect
        tkProcedure, tkFunction, tkConstructor, tkDestructor,
        tkInitialization, tkFinalization,
        tkBegin, tkAsm,
        tkCase, tkTry, tkRepeat, tkIf, tkFor, tkWith, tkOn, tkWhile,
        tkRecord, tkObject, tkOf, tkEqual,
        tkClass, tkInterface, tkDispInterface,
        tkExcept, tkFinally, tkElse,
        tkEnd, tkUntil, tkThen, tkDo]) then
      begin
        NewToken;
        case Lex.TokenID of
          tkProcedure, tkFunction, tkConstructor, tkDestructor:
            begin
              // ������ procedure/function ���Ͷ��壬ǰ���� = ��
              // Ҳ������ procedure/function ����������ǰ���� : ��
              // Ҳ��������������������ǰ���� to
              // Ҳ��������������ʵ�֣�ǰ���� := ��ֵ�� ( , �������������ܲ���ȫ
              if IsImpl and ((not (Lex.TokenID in [tkProcedure, tkFunction]))
                or (not (PrevTokenID in [tkEqual, tkColon, tkTo, tkAssign, tkRoundOpen, tkComma])))
                and (DeclareWithEndLevel <= 0) then
              begin
                // DeclareWithEndLevel <= 0 ��ʾֻ���� class/record ����������ڲ�����
//                while BlockStack.Count > 0 do
//                  BlockStack.Pop;
//                CurrBlock := nil;
                if CurrBlock = nil then
                  Token.FItemLayer := 0
                else
                  Token.FItemLayer := CurrBlock.ItemLayer;
                Token.FIsMethodStart := True;

                if CurrMethod <> nil then
                begin
                  Token.FMethodLayer := CurrMethod.FMethodLayer + 1;
                  FMethodStack.Push(CurrMethod);
                end
                else
                  Token.FMethodLayer := 0;
                CurrMethod := Token;

                // ���� procedure/function ʵ��ʱ�������ջ����¼���Σ����� Layer �ɼ�¼��
                AProcObj := TProcObj.Create;
                AProcObj.Token := Token;
                FProcStack.Push(AProcObj);
                Inc(ProcNestCount);
              end;
            end;
          tkInitialization, tkFinalization:
            begin
              while FBlockStack.Count > 0 do
                FBlockStack.Pop;
              CurrBlock := nil;
              while FMethodStack.Count > 0 do
                FMethodStack.Pop;
              CurrMethod := nil;
            end;
          tkBegin, tkAsm:
            begin
              Token.FIsBlockStart := True;
              if CurrMethod <> nil then
                Token.FIsMethodStart := True;
              if CurrBlock <> nil then
              begin
                Token.FItemLayer := CurrBlock.FItemLayer + 1;
                FBlockStack.Push(CurrBlock);
              end
              else
                Token.FItemLayer := 0;
              CurrBlock := Token;

              // ���� begin/asm �� procedure/function ͬ��ʱ�Ľ���
              if FProcStack.Count > 0 then
              begin
                AProcObj := TProcObj(FProcStack.Peek);
                if not AProcObj.Matched then
                begin
                  // ���������� procedure/function��begin/asm ��һ���Է��ϳ�ʶ
                  if FProcStack.Count = 1 then
                    Inc(Token.FItemLayer, 1)
                  else
                    Inc(Token.FItemLayer, ProcNestCount - 1);
                  // ���������begin Ҫ�� procedure/function ��δƥ���Ƕ�ײ��� - 1��
                  // Ҳ����ǰ procedure/function ��ֱ��Ƕ�ײ���

                  AProcObj.Layer := Token.ItemLayer;    // Layer ��¼ begin/asm �Ĳ��
                  AProcObj.Matched := True;
                  Dec(ProcNestCount);
                end;
              end;
            end;
          tkCase:
            begin
              if (CurrBlock = nil) or (CurrBlock.TokenID <> tkRecord) then
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  FBlockStack.Push(CurrBlock);
                end
                else
                  Token.FItemLayer := 0;
                CurrBlock := Token;
              end
              else
                DiscardToken(True);
            end;
          tkTry, tkRepeat, tkIf, tkFor, tkWith, tkOn, tkWhile,
          tkRecord, tkObject:
            begin
              IsRecord := Lex.TokenID = tkRecord;
              IsForFunc := (PrevTokenID in [tkPoint]) or
                ((PrevTokenID = tkSymbol) and (PrevTokenStr = '&'));
              if IsRecord then
              begin
                // ���� record helper for �����Σ�����implementation������end�ᱻ
                // record�ڲ���function/procedure���ɵ������޽��������
                IsRecordHelper := False;
                Lex.SaveToBookMark(Bookmark);

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID in [tkSymbol, tkIdentifier] then
                begin
                  if LowerCase(Lex.Token) = 'helper' then
                    IsRecordHelper := True;
                end;

                Lex.LoadFromBookMark(Bookmark);
              end;

              // ������ of object ��������������ǰ���� @@ �͵�label������
              // ������ IsRecord ������Ϊ Lex.RunPos �ָ���TokenID ���ܻ��
              if ((Lex.TokenID <> tkObject) or (PrevTokenID <> tkOf))
                and not (PrevTokenID in [tkAt, tkDoubleAddressOp])
                and not IsForFunc        // ������ TParalle.For �Լ� .&For ���ֺ���
                and not ((Lex.TokenID = tkFor) and (IsHelper or IsRecordHelper)) then
                // ������ helper �е� for
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  FBlockStack.Push(CurrBlock);
                  if (CurrBlock.TokenID = tkTry) and (Token.TokenID = tkTry)
                    and (CurrMidBlock <> nil) then
                  begin
                    FMidBlockStack.Push(CurrMidBlock);
                    CurrMidBlock := nil;
                  end;
                end
                else
                  Token.FItemLayer := 0;
                CurrBlock := Token;

                if IsRecord then
                begin
                  // ������¼ record����Ϊ record �����ں������ begin end ֮���� end
                  // IsInDeclareWithEnd := True;
                  Inc(DeclareWithEndLevel);
                end;
              end;

              if Lex.TokenID = tkFor then
              begin
                if IsHelper then
                  IsHelper := False;
                if IsRecordHelper then
                  IsRecordHelper := False;
              end;
            end;
          tkClass, tkInterface, tkDispInterface:
            begin
              IsHelper := False;
              IsSealed := False;
              IsAbstract := False;
              IsClassDef := ((Lex.TokenID = tkClass) and Lex.IsClass)
                or ((Lex.TokenID = tkInterface) and Lex.IsInterface) or
                (Lex.TokenID = tkDispInterface);

              // ������ classdef ���� class helper for TObject ������
              if not IsClassDef and (Lex.TokenID = tkClass) and not Lex.IsClass then
              begin
                Lex.SaveToBookMark(Bookmark);

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID in [tkSymbol, tkIdentifier, tkSealed, tkAbstract] then
                begin
                  if LowerCase(Lex.Token) = 'helper' then
                  begin
                    IsClassDef := True;
                    IsHelper := True;
                  end
                  else if Lex.TokenID = tkSealed then
                  begin
                    IsClassDef := True;
                    IsSealed := True;
                  end
                  else if Lex.TokenID = tkAbstract then
                  begin
                    IsClassDef := True;
                    IsAbstract := True;
                  end;
                end;

                Lex.LoadFromBookMark(Bookmark);
              end;

              IsClassOpen := False;
              if IsClassDef then
              begin
                IsClassOpen := True;
                Lex.SaveToBookMark(Bookmark);

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID = tkSemiColon then // �Ǹ� class; ����Ҫ end;
                  IsClassOpen := False
                else if IsHelper or IsSealed or IsAbstract then
                  LexNextNoJunkWithoutCompDirect(Lex);

                if Lex.TokenID = tkRoundOpen then // �����ţ����ǲ���();
                begin
                  while not (Lex.TokenID in [tkNull, tkRoundClose]) do
                    LexNextNoJunkWithoutCompDirect(Lex);
                  if Lex.TokenID = tkRoundClose then
                    LexNextNoJunkWithoutCompDirect(Lex);
                end;

                if Lex.TokenID = tkSemiColon then
                  IsClassOpen := False
                else if Lex.TokenID = tkFor then
                  IsClassOpen := True;

                Lex.LoadFromBookMark(Bookmark);
              end;

              if IsClassOpen then // �к������ݣ���Ҫһ�� end
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  FBlockStack.Push(CurrBlock);
                end
                else
                  Token.FItemLayer := 0;
                CurrBlock := Token;
                // �ֲ���������Ҫ end ����β
                // IsInDeclareWithEnd := True;
                Inc(DeclareWithEndLevel);
              end
              else // Ӳ�޲������ unit �� interface �Լ� class procedure �ȱ�����
                DiscardToken(Token.TokenID in [tkClass, tkInterface, tkDispInterface]);
            end;
          tkExcept, tkFinally:
            begin
              if (CurrBlock = nil) or (CurrBlock.TokenID <> tkTry) then
                DiscardToken
              else if CurrMidBlock = nil then
              begin
                CurrMidBlock := Token;
              end
              else
                DiscardToken;
            end;
          tkElse:
            begin
              if (CurrBlock = nil) or (PrevTokenID in [tkAt, tkDoubleAddressOp]) then
                DiscardToken
              else if (CurrBlock.TokenID = tkTry) and (CurrMidBlock <> nil) and
                (CurrMidBlock.TokenID = tkExcept) and
                (PrevTokenID in [tkSemiColon, tkExcept]) then
                Token.FItemLayer := CurrBlock.FItemLayer    // try except else end ��һ���
              else if not (CurrBlock.TokenID = tkCase) then // case of �е� else ǰ����Բ��Ƿֺ�
                Token.FItemLayer := Token.FItemLayer + 1;
            end;
          tkEnd, tkUntil, tkThen, tkDo:
            begin
              if (CurrBlock <> nil) and not (PrevTokenID in [tkPoint, tkAt, tkDoubleAddressOp]) then
              begin
                if ((Lex.TokenID = tkUntil) and (CurrBlock.TokenID <> tkRepeat))
                  or ((Lex.TokenID = tkThen) and (CurrBlock.TokenID <> tkIf))
                  or ((Lex.TokenID = tkDo) and not (CurrBlock.TokenID in
                  [tkOn, tkWhile, tkWith, tkFor])) then
                begin
                  DiscardToken;
                end
                else
                begin
                  // ���ⲿ�ֹؼ����������������Σ���ֻ��һ��С patch������������
                  Token.FItemLayer := CurrBlock.FItemLayer;
                  Token.FIsBlockClose := True;
                  if (CurrBlock.TokenID = tkTry) and (CurrMidBlock <> nil) then
                  begin
                    if FMidBlockStack.Count > 0 then
                      CurrMidBlock := TCnWidePasToken(FMidBlockStack.Pop)
                    else
                      CurrMidBlock := nil;
                  end;
                  if FBlockStack.Count > 0 then
                  begin
                    CurrBlock := TCnWidePasToken(FBlockStack.Pop);
                  end
                  else
                  begin
                    CurrBlock := nil;
                    if (CurrMethod <> nil) and (Lex.TokenID = tkEnd) and (DeclareWithEndLevel <= 0) then
                    begin
                      Token.FIsMethodClose := True;
                      if FMethodStack.Count > 0 then
                        CurrMethod := TCnWidePasToken(FMethodStack.Pop)
                      else
                        CurrMethod := nil;
                    end;
                  end;
                end;
              end
              else // Ӳ�޲������ unit �� End Ҳ����
                DiscardToken(Token.TokenID = tkEnd);

              if (DeclareWithEndLevel > 0) and (Lex.TokenID = tkEnd) then // �����˾ֲ�����
                Dec(DeclareWithEndLevel);

              // ��� end �� procedure/function ����Ԫ��ͬ��
              if (Lex.TokenID = tkEnd) and (FProcStack.Count > 0) then
              begin
                AProcObj := TProcObj(FProcStack.Peek);
                if AProcObj.Matched and (AProcObj.Layer = Token.ItemLayer) then
                begin
                  AProcObj := TProcObj(FProcStack.Pop);
                  AProcObj.Free;
                end;
              end;
            end;
        end;
      end
      else
      begin
        if not IsImpl and (Lex.TokenID = tkImplementation) then
          IsImpl := True;

        if (CurrMethod <> nil) and // forward, external ��ʵ�ֲ��֣�ǰ������Ƿֺ�
          (Lex.TokenID in [tkForward, tkExternal]) and (PrevTokenID = tkSemicolon) then
        begin
          CurrMethod.FIsMethodStart := False;
          if AKeyOnly and (CurrMethod.FItemIndex = FList.Count - 1) then
          begin
            FreePasToken(FList[FList.Count - 1]);
            FList.Delete(FList.Count - 1);
          end;
          if FMethodStack.Count > 0 then
            CurrMethod := TCnWidePasToken(FMethodStack.Pop)
          else
            CurrMethod := nil;

          if FProcStack.Count > 0 then
          begin
            AProcObj := TProcObj(FProcStack.Pop);
            AProcObj.Free;
            if ProcNestCount > 0 then
              Dec(ProcNestCount);
          end;
        end;

        // ��Ҫʱ����ͨ��ʶ���ӣ�& ��ı�ʶ��Ҳ��
        if not AKeyOnly and ((PrevTokenID <> tkAmpersand) or (Lex.TokenID = tkIdentifier)) then
          NewToken;
      end;

      PrevTokenID := Lex.TokenID;
      PrevTokenStr := Lex.Token;
      //LexNextNoJunkWithoutCompDirect(Lex);
      Lex.NextNoJunk;
    end;
  finally
    Lex.Free;
    FMethodStack.Clear;
    FBlockStack.Clear;
    FMidBlockStack.Clear;
    while FProcStack.Count > 0 do
    begin
      AProcObj := TProcObj(FProcStack.Pop);
      AProcObj.Free;
    end;
    FProcStack.Clear;
  end;
end;

procedure TCnWidePasStructParser.FindCurrentBlock(LineNumber, WideCharIndex:
  Integer);
var
  Token: TCnWidePasToken;
  CurrIndex: Integer;

  procedure _BackwardFindDeclarePos;
  var
    Level: Integer;
    I, NestedProcs: Integer;
    StartInner: Boolean;
  begin
    Level := 0;
    StartInner := True;
    NestedProcs := 1;
    for I := CurrIndex - 1 downto 0 do
    begin
      Token := Tokens[I];
      if Token.IsBlockStart then
      begin
        if StartInner and (Level = 0) then
        begin
          FInnerBlockStartToken := Token;
          StartInner := False;
        end;

        if Level = 0 then
          FBlockStartToken := Token
        else
          Dec(Level);
      end
      else if Token.IsBlockClose then
      begin
        Inc(Level);
      end;

      if Token.IsMethodStart then
      begin
        if Token.TokenID in [tkProcedure, tkFunction, tkConstructor, tkDestructor] then
        begin
          // ���� procedure �����Ӧ�� begin �������� MethodStart�������Ҫ��������
          Dec(NestedProcs);
          if (NestedProcs = 0) and (FChildMethodStartToken = nil) then
            FChildMethodStartToken := Token;
          if Token.MethodLayer = 1 then
          begin
            FMethodStartToken := Token;
            Exit;
          end;
        end
        else if Token.TokenID in [tkBegin, tkAsm] then
        begin
          // �ڿ�Ƕ�������������̵ĵ�������ʱ������������
        end;
      end
      else if Token.IsMethodClose then
        Inc(NestedProcs);

      if Token.TokenID in [tkImplementation] then
      begin
        Exit;
      end;
    end;
  end;

  procedure _ForwardFindDeclarePos;
  var
    Level: Integer;
    I, NestedProcs: Integer;
    EndInner: Boolean;
  begin
    Level := 0;
    EndInner := True;
    NestedProcs := 1;
    for I := CurrIndex to Count - 1 do
    begin
      Token := Tokens[I];
      if Token.IsBlockClose then
      begin
        if EndInner and (Level = 0) then
        begin
          FInnerBlockCloseToken := Token;
          EndInner := False;
        end;

        if Level = 0 then
          FBlockCloseToken := Token
        else
          Dec(Level);
      end
      else if Token.IsBlockStart then
      begin
        Inc(Level);
      end;

      if Token.IsMethodClose then
      begin
        Dec(NestedProcs);
        if Token.MethodLayer = 1 then // ����������� Layer Ϊ 1 �ģ���Ȼ�������
        begin
          FMethodCloseToken := Token;
          Exit;
        end
        else if (NestedProcs = 0) and (FChildMethodCloseToken = nil) then
          FChildMethodCloseToken := Token;
          // �����ͬ��εģ����� ChildMethodClose
      end
      else if Token.IsMethodStart and (Token.TokenID in [tkProcedure, tkFunction,
        tkConstructor, tkDestructor]) then
      begin
        Inc(NestedProcs);
      end;

      if Token.TokenID in [tkInitialization, tkFinalization] then
      begin
        Exit;
      end;
    end;
  end;

  procedure _FindInnerBlockPos;
  var
    I, Level: Integer;
  begin
    // �˺����� _ForwardFindDeclarePos �� _BackwardFindDeclarePos �����
    if (FInnerBlockStartToken <> nil) and (FInnerBlockCloseToken <> nil) then
    begin
      // ���һ�����˳�
      if FInnerBlockStartToken.ItemLayer = FInnerBlockCloseToken.ItemLayer then
        Exit;
      // ���·��ٽ��� Block ���ܲ�β�һ������Ҫ�Ҹ�һ����εģ��������Ϊ׼

      if FInnerBlockStartToken.ItemLayer > FInnerBlockCloseToken.ItemLayer then
        Level := FInnerBlockCloseToken.ItemLayer
      else
        Level := FInnerBlockStartToken.ItemLayer;

      for I := CurrIndex - 1 downto 0 do
      begin
        Token := Tokens[I];
        if Token.IsBlockStart and (Token.ItemLayer = Level) then
          FInnerBlockStartToken := Token;
      end;
      for i := CurrIndex to Count - 1 do
      begin
        Token := Tokens[i];
        if Token.IsBlockClose and (Token.ItemLayer = Level) then
          FInnerBlockCloseToken := Token;
      end;
    end;
  end;

  function _GetMethodName(StartToken, CloseToken: TCnWidePasToken): CnWideString;
  var
    I: Integer;
  begin
    Result := '';
    if Assigned(StartToken) and Assigned(CloseToken) then
      for I := StartToken.ItemIndex + 1 to CloseToken.ItemIndex do
      begin
        Token := Tokens[I];
        if (Token.Token^ = '(') or (Token.Token^ = ':') or (Token.Token^ = ';') then
          Break;
        Result := Result + WideTrim(Token.Token);
      end;
  end;

begin
  FMethodStartToken := nil;
  FMethodCloseToken := nil;
  FChildMethodStartToken := nil;
  FChildMethodCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FInnerBlockCloseToken := nil;
  FInnerBlockStartToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';

  CurrIndex := 0;
  while CurrIndex < Count do
  begin
    // ǰ�ߴ� 0 ��ʼ�����ߴ� 1 ��ʼ�������Ҫ�� 1
    if (Tokens[CurrIndex].LineNumber > LineNumber - 1) then
      Break;

    // ���ݲ�ͬ����ʼ Token���ж�����Ҳ������ͬ
    if Tokens[CurrIndex].LineNumber = LineNumber - 1 then
    begin
      if (Tokens[CurrIndex].TokenID in [tkBegin, tkAsm, tkTry, tkRepeat, tkIf,
        tkFor, tkWith, tkOn, tkWhile, tkCase, tkRecord, tkObject, tkClass,
        tkInterface, tkDispInterface]) and
        (Tokens[CurrIndex].CharIndex > WideCharIndex ) then // ��ʼ�������ж�
        Break
      else if (Tokens[CurrIndex].TokenID in [tkEnd, tkUntil, tkThen, tkDo]) and
        (Tokens[CurrIndex].CharIndex + Length(Tokens[CurrIndex].Token) > WideCharIndex ) then
        Break;  //�����������ж�
    end;

    Inc(CurrIndex);
  end;

  if (CurrIndex > 0) and (CurrIndex < Count) then
  begin
    _BackwardFindDeclarePos;
    _ForwardFindDeclarePos;

    _FindInnerBlockPos;
    if not FKeyOnly then
    begin
      FCurrentMethod := _GetMethodName(FMethodStartToken, FMethodCloseToken);
      FCurrentChildMethod := _GetMethodName(FChildMethodStartToken, FChildMethodCloseToken);
    end;
  end;
end;

function TCnWidePasStructParser.IndexOfToken(Token: TCnWidePasToken): Integer;
begin
  Result := FList.IndexOf(Token);
end;

function TCnWidePasStructParser.FindCurrentDeclaration(LineNumber,
  WideCharIndex: Integer): CnWideString;
var
  Idx: Integer;
begin
  Result := '';
  FindCurrentBlock(LineNumber, WideCharIndex);

  if InnerBlockStartToken <> nil then
  begin
    if InnerBlockStartToken.TokenID in [tkClass, tkInterface, tkRecord,
      tkDispInterface] then
    begin
      // ��ǰ�ҵȺ���ǰ�ı�ʶ��
      Idx := IndexOfToken(InnerBlockStartToken);
      if Idx > 3 then
      begin
        if (InnerBlockStartToken.TokenID = tkRecord)
          and (Tokens[Idx - 1].TokenID = tkPacked) then
          Dec(Idx);
        if Tokens[Idx - 1].TokenID = tkEqual then
          Dec(Idx);
        if Tokens[Idx - 1].TokenID = tkIdentifier then
          Result := Tokens[Idx - 1].Token;
      end;
    end;
  end;
end;

// ����Դ���������õĵ�Ԫ
procedure ParseUnitUsesW(const Source: CnWideString; UsesList: TStrings;
  SupportUnicodeIdent: Boolean);
var
  Lex: TCnPasWideLex;
  Flag: Integer;
  S: CnWideString;
begin
  UsesList.Clear;
  Lex := TCnPasWideLex.Create(SupportUnicodeIdent);

  Flag := 0;
  S := '';
  try
    Lex.Origin := PWideChar(Source);
    while Lex.TokenID <> tkNull do
    begin
      if Lex.TokenID = tkUses then
      begin
        while not (Lex.TokenID in [tkNull, tkSemiColon]) do
        begin
          Lex.Next;
          if Lex.TokenID = tkIdentifier then
          begin
            S := S + CnWideString(Lex.Token);
          end
          else if Lex.TokenID = tkPoint then
          begin
            S := S + '.';
          end
          else if Trim(S) <> '' then
          begin
            UsesList.AddObject(S, TObject(Flag));
            S := '';
          end;
        end;
      end
      else if Lex.TokenID = tkImplementation then
      begin
        Flag := 1;
        // �� Flag ����ʾ interface ���� implementation
      end;
      Lex.Next;
    end;
  finally
    Lex.Free;
  end;
end;

{ TCnWidePasToken }

procedure TCnWidePasToken.Clear;
begin
  FCppTokenKind := TCTokenKind(0);
  FCharIndex := 0;
  FAnsiIndex := 0;
  FEditCol := 0;
  FEditLine := 0;
  FItemIndex := 0;
  FItemLayer := 0;
  FLineNumber := 0;
  FMethodLayer := 0;
  FillChar(FToken[0], SizeOf(FToken), 0);
  FTokenID := TTokenKind(0);
  FTokenPos := 0;
  FIsMethodStart := False;
  FIsMethodClose := False;
  FIsBlockStart := False;
  FIsBlockClose := False;
end;

function TCnWidePasToken.GetToken: PWideChar;
begin
  Result := @FToken[0];
end;

initialization
  TokenPool := TCnList.Create;

finalization
  ClearTokenPool;
  FreeAndNil(TokenPool);

end.
