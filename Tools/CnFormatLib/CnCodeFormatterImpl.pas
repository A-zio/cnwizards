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

unit CnCodeFormatterImpl;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ������ʽ������ӿ�
* ��Ԫ���ߣ�CnPack������
* ��    ע���õ�Ԫʵ�ִ����ʽ���Ķ���ӿ�
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ�not test yet
* �� �� ����not test hell
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.02.11 V1.0
*               ������Ԫ��
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  CnFormatterIntf, SysUtils, Classes, Windows;

function GetCodeFormatterProvider: ICnPascalFormatterIntf; stdcall;

exports
  GetCodeFormatterProvider;

implementation

uses
  CnCodeFormatter, CnParseConsts, CnCodeFormatRules {$IFDEF DEBUG} , CnDebug {$ENDIF} ;

type
  TCnCodeFormatProvider = class(TInterfacedObject, ICnPascalFormatterIntf)
  private
    FResult: PAnsiChar;
    procedure AdjustResultLength(Len: DWORD);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetPascalFormatRule(DirectiveMode: DWORD; KeywordStyle: DWORD;
      BeginStyle: DWORD; TabSpace: DWORD; SpaceBeforeOperator: DWORD;
      SpaceAfterOperator: DWORD; SpaceBeforeAsm: DWORD; SpaceTabAsm: DWORD;
      LineWrapWidth: DWORD; UsesSingleLine: LongBool; UseIgnoreArea: LongBool);

    function FormatOnePascalUnit(Input: PAnsiChar; Len: DWORD): PAnsiChar;

    function FormatPascalBlock(StartType: DWORD; StartIndent: DWORD;
      Input: PAnsiChar; Len: DWORD): PAnsiChar;

    function RetrievePascalLastError(out SourceLine: Integer; out SourceCol: Integer;
      out SourcePos: Integer; out CurrentToken: PAnsiChar): Integer;
  end;

var
  FCodeFormatProvider: ICnPascalFormatterIntf = nil;

function GetCodeFormatterProvider: ICnPascalFormatterIntf; stdcall;
begin
  if FCodeFormatProvider = nil then
    FCodeFormatProvider := TCnCodeFormatProvider.Create;
  Result := FCodeFormatProvider;
end;

{ FCodeFormatProvider }

procedure TCnCodeFormatProvider.AdjustResultLength(Len: DWORD);
begin
  if FResult <> nil then
  begin
    StrDispose(FResult);
    FResult := nil;
  end;

  if Len > 0 then
  begin
    FResult := StrAlloc(Len);
    ZeroMemory(FResult, Len);
  end;
end;

constructor TCnCodeFormatProvider.Create;
begin
  inherited;
  
end;

destructor TCnCodeFormatProvider.Destroy;
begin
  AdjustResultLength(0);
  inherited;
end;

function TCnCodeFormatProvider.FormatPascalBlock(StartType, StartIndent: DWORD;
  Input: PAnsiChar; Len: DWORD): PAnsiChar;
begin
  AdjustResultLength(0);
  Result := FResult;
end;

function TCnCodeFormatProvider.FormatOnePascalUnit(Input: PAnsiChar;
  Len: DWORD): PAnsiChar;
var
  InStream, OutStream: TStream;
  CodeFor: TCnPascalCodeFormatter;
begin
  AdjustResultLength(0);
  ClearPascalError;
  if (Input = nil) or (Len = 0) then
  begin
    Result := nil;
    Exit;
  end;

  InStream := TMemoryStream.Create;
  OutStream := TMemoryStream.Create;

  InStream.Write(Input^, Len);
  CodeFor := TCnPascalCodeFormatter.Create(InStream);

  try
    try
      CodeFor.FormatCode;
      CodeFor.SaveToStream(OutStream);
    except
      ; // �����ˣ����� nil �Ľ��
    end;

    if OutStream.Size > 0 then
    begin
      AdjustResultLength(OutStream.Size + 1);
      OutStream.Position := 0;
      OutStream.Read(FResult^, OutStream.Size);
    end;
  finally
    CodeFor.Free;
    InStream.Free;
    OutStream.Free;
  end;
  Result := FResult;
end;

procedure TCnCodeFormatProvider.SetPascalFormatRule(DirectiveMode, KeywordStyle,
  BeginStyle, TabSpace, SpaceBeforeOperator, SpaceAfterOperator, SpaceBeforeAsm,
  SpaceTabAsm, LineWrapWidth: DWORD; UsesSingleLine, UseIgnoreArea: LongBool);
begin
  case DirectiveMode of
    CN_RULE_DIRECTIVE_MODE_ASCOMMENT:
      CnPascalCodeForRule.CompDirectiveMode := cdmAsComment;
    CN_RULE_DIRECTIVE_MODE_ONLYFIRST:
      CnPascalCodeForRule.CompDirectiveMode := cdmOnlyFirst;
  end;

  case KeywordStyle of
    CN_RULE_KEYWORD_STYLE_UPPER:
      CnPascalCodeForRule.KeywordStyle := ksUpperCaseKeyword;
    CN_RULE_KEYWORD_STYLE_LOWER:
      CnPascalCodeForRule.KeywordStyle := ksLowerCaseKeyword;
    CN_RULE_KEYWORD_STYLE_UPPERFIRST:
      CnPascalCodeForRule.KeywordStyle := ksPascalKeyword;
    CN_RULE_KEYWORD_STYLE_NOCHANGE:
      CnPascalCodeForRule.KeywordStyle := ksNoChange;
  end;

  case BeginStyle of
    CN_RULE_BEGIN_STYLE_NEXTLINE:
      CnPascalCodeForRule.BeginStyle := bsNextLine;
    CN_RULE_BEGIN_STYLE_SAMELINE:
      CnPascalCodeForRule.BeginStyle := bsSameLine;
  end;

  CnPascalCodeForRule.TabSpaceCount := TabSpace;
  CnPascalCodeForRule.SpaceBeforeOperator := SpaceBeforeOperator;
  CnPascalCodeForRule.SpaceAfterOperator := SpaceAfterOperator;
  CnPascalCodeForRule.SpaceBeforeASM := SpaceBeforeAsm;
  CnPascalCodeForRule.SpaceTabASMKeyword := SpaceTabAsm;
  CnPascalCodeForRule.WrapWidth := LineWrapWidth;
  CnPascalCodeForRule.UsesUnitSingleLine := UsesSingleLine;
  CnPascalCodeForRule.UseIgnoreArea := UseIgnoreArea;
end;

function TCnCodeFormatProvider.RetrievePascalLastError(out SourceLine, SourceCol,
  SourcePos: Integer; out CurrentToken: PAnsiChar): Integer;
begin
  Result := PascalErrorRec.ErrorCode;
  SourceLine := PascalErrorRec.SourceLine;
  SourceCol := PascalErrorRec.SourceCol;
  SourcePos := PascalErrorRec.SourcePos;
  CurrentToken := PAnsiChar(PascalErrorRec.CurrentToken);
end;

initialization

finalization
  FCodeFormatProvider := nil;

end.
