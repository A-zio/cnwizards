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

unit CnTestEditorMenuWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Ա༭���Ҽ��˵���Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��WinXP + Delphi 7
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 7 ����
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id:  CnTestEditorMenuWizard 1146 2012-10-24 06:25:41Z liuxiaoshanzhashu@gmail.com $
* �޸ļ�¼��2015.08.17 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager;

type

//==============================================================================
// ���Ա༭���Ҽ��˵���Ĳ˵�ר��
//==============================================================================

{ TCnTestEditorMenuWizard }

  TCnTestEditorMenuWizard = class(TCnMenuWizard)
  private
    FExecutor: TCnContextMenuExecutor;
    procedure Executor2Execute(Sender: TObject);
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;

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

  TCnTestEditorMenu1 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

  TCnTestEditorMenu2 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

  TCnTestEditorMenu3 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// ���Ա༭���Ҽ��˵���Ĳ˵�ר��
//==============================================================================

{ TCnTestEditorMenuWizard }

procedure TCnTestEditorMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditorMenuWizard.Create;
begin
  inherited;
  RegisterBaseEditorMenuExecutor(TCnTestEditorMenu1.Create(Self));
  RegisterBaseEditorMenuExecutor(TCnTestEditorMenu2.Create(Self));
  RegisterBaseEditorMenuExecutor(TCnTestEditorMenu3.Create(Self));
end;

procedure TCnTestEditorMenuWizard.Execute;
begin
  ShowMessage('3 Menu Items Registered using TCnBaseMenuExecutor.' + #13#10
    + '1 Hidden, 1 Disabled and 1 Enabled. Please Check Editor Context Menu.');
end;

procedure TCnTestEditorMenuWizard.Executor2Execute(Sender: TObject);
begin
  ShowMessage('Executor 2 Run Here.');
end;

function TCnTestEditorMenuWizard.GetCaption: string;
begin
  Result := 'Test Editor Menu';
end;

function TCnTestEditorMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditorMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditorMenuWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditorMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Editor Context Menu';
end;

procedure TCnTestEditorMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

{ TCnTestEditorMenu1 }

function TCnTestEditorMenu1.Execute: Boolean;
begin
  ShowMessage('Should NOT Run Here.');
  Result := True;
end;

function TCnTestEditorMenu1.GetActive: Boolean;
begin
  Result := False;
end;

function TCnTestEditorMenu1.GetCaption: string;
begin
  Result := 'Hidden Caption';
end;

function TCnTestEditorMenu1.GetEnabled: Boolean;
begin
  Result := True;
end;

{ TCnTestEditorMenu2 }

function TCnTestEditorMenu2.Execute: Boolean;
begin
  ShowMessage('Should NOT Run Here.');
  Result := True;
end;

function TCnTestEditorMenu2.GetActive: Boolean;
begin
  Result := True;
end;

function TCnTestEditorMenu2.GetCaption: string;
begin
  Result := 'Disabled Caption'
end;

function TCnTestEditorMenu2.GetEnabled: Boolean;
begin
  Result := False;
end;

{ TCnTestEditorMenu3 }

function TCnTestEditorMenu3.Execute: Boolean;
begin
  ShowMessage('Should Run Here.');
  Result := True;
end;

function TCnTestEditorMenu3.GetActive: Boolean;
begin
  Result := True;
end;

function TCnTestEditorMenu3.GetCaption: string;
begin
  Result := 'Enabled Caption';
end;

function TCnTestEditorMenu3.GetEnabled: Boolean;
begin
  Result := True;
end;

initialization
  RegisterCnWizard(TCnTestEditorMenuWizard); // ע��˲���ר��

end.
