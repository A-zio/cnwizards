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
  CnCodeFormatter;

type
  TCnCodeFormatProvider = class(TInterfacedObject, ICnPascalFormatterIntf)
  private
    FResult: PAnsiChar;
    procedure AdjustResultLength(Len: DWORD);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetPascalFormatRule(DirectiveMode: DWORD; KeywordStyle: DWORD; TabSpace:
      DWORD; SpaceBeforeOperator: DWORD; SpaceAfterOperator: DWORD; SpaceBeforeAsm:
      DWORD; SpaceTabAsm: DWORD; LineWrapWidth: DWORD; UsesSingleLine: LongBool);

    function FormatOnePascalUnit(Input: PAnsiChar; Len: DWORD): PAnsiChar;

    function FormatPascalBlock(StartType: DWORD; StartIndent: DWORD;
      Input: PAnsiChar; Len: DWORD): PAnsiChar;
  end;

var
  FCodeFormatProvider: TCnCodeFormatProvider = nil;

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
  Stream: TStream;
  CodeFor: TCnPascalCodeFormatter;
begin
  AdjustResultLength(0);
  if (Input = nil) or (Len = 0) then
  begin
    Result := nil;
    Exit;
  end;

  Stream := TMemoryStream.Create;
  Stream.Write(Input^, Len);
  CodeFor := TCnPascalCodeFormatter.Create(Stream);

  try
    try
      CodeFor.FormatCode;
    finally
      CodeFor.SaveToStream(Stream);
    end;

    if Stream.Size > 0 then
    begin
      AdjustResultLength(Stream.Size + 1);
      Stream.Position := 0;
      Stream.Read(FResult^, Stream.Size);
    end;
  finally
    Stream.Free;
    CodeFor.Free;
  end;
  Result := FResult;
end;

procedure TCnCodeFormatProvider.SetPascalFormatRule(DirectiveMode, KeywordStyle,
  TabSpace, SpaceBeforeOperator, SpaceAfterOperator, SpaceBeforeAsm,
  SpaceTabAsm, LineWrapWidth: DWORD; UsesSingleLine: LongBool);
begin

end;

initialization

finalization
  FreeAndNil(FCodeFormatProvider);

end.
