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

unit CnTestFormatterWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Դ����ʽ�����ܵĲ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ CnCppCodeParser �� ParseCppCodePosInfo �Բ鿴�Ƿ����˹��
            ���ڴ���λ�����͡�����ʱ��ǰ���ڴ� C/C++ �ļ����ɲ��ԡ�
* ����ƽ̨��WinXP + BCB 5/6
* ���ݲ��ԣ�PWin9X/2000/XP + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id: CnTestFormatterWizard.pas 1146 2012-10-24 06:25:41Z liuxiaoshanzhashu@gmail.com $
* �޸ļ�¼��2015.02.12 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnFormatterIntf;

type

//==============================================================================
// ���Լ��� DLL �����и�ʽ�������Ĳ˵�ר��
//==============================================================================

{ TCnTestFormatterWizard }

  TCnTestFormatterWizard = class(TCnMenuWizard)
  private
    FHandle: THandle;
    FGetProvider: TCnGetFormatterProvider;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnDebug, CnCommon;

const
  DLLName: string = 'CnFormatLib.dll';

function ModulePath: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, SizeOf(ModName)));
  Result := _CnExtractFilePath(Result);
end;

//==============================================================================
// ���Լ��� DLL �����и�ʽ�������Ĳ˵�ר��
//==============================================================================

{ TCnTestFormatterWizard }

procedure TCnTestFormatterWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestFormatterWizard.Create;
begin
  inherited;

end;

destructor TCnTestFormatterWizard.Destroy;
begin
  if FHandle <> 0 then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
  end;
  inherited;
end;

procedure TCnTestFormatterWizard.Execute;
var
  S: AnsiString;
  Res: PAnsiChar;
  Formatter: ICnPascalFormatterIntf;
begin
  if FHandle = 0 then
    FHandle := LoadLibrary(PChar(ModulePath + DLLName));
   
  if FHandle = 0 then
  begin
    ShowMessage('No DLL Found.');
    Exit;
  end;

  if not Assigned(FGetProvider) then
    FGetProvider := TCnGetFormatterProvider(GetProcAddress(FHandle, 'GetCodeFormatterProvider'));
  if not Assigned(FGetProvider) then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
    ShowMessage('No Provider Found.');
    Exit;
  end;

  Formatter := FGetProvider();
  if Formatter = nil then
  begin
    FGetProvider := nil;
    FreeLibrary(FHandle);
    FHandle := 0;
    ShowMessage('No Formatter Found.');
    Exit;
  end;

  try
    S := AnsiString(CnOtaGetCurrentEditorSource);
    Res := Formatter.FormatOnePascalUnit(PAnsiChar(S), Length(S));

    if Res <> nil then
    begin
      ShowMessage(Res);
      CnOtaSetCurrentEditorSource(string(Res));
    end;
  finally
    Formatter := nil;
  end;
end;

function TCnTestFormatterWizard.GetCaption: string;
begin
  Result := 'Test Formatter';
end;

function TCnTestFormatterWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestFormatterWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestFormatterWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestFormatterWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestFormatterWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Formatter Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Formatterusing DLL.';
end;

procedure TCnTestFormatterWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestFormatterWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestFormatterWizard); // ע��˲���ר��

end.
