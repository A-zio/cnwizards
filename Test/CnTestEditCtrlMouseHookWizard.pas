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

unit CnTestEditCtrlMouseHookWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Ա༭���ؼ�����궯���ҽӵ�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���ҽ� MouseDown/Up/Move ������֧�ַַ�
* ����ƽ̨��PWinXP + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.07.11 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnEventHook, CnCommon, CnWizClasses, CnWizUtils,
  CnWizConsts, CnEditControlWrapper;

type

//==============================================================================
// ���Թҽ� EditControl ����¼��Ĳ˵�ר��
//==============================================================================

{ TCnTestEditCtrlMouseHookWizard }

  TCnTestEditCtrlMouseHookWizard = class(TCnMenuWizard)
  private
    FInScrollBar: Boolean;
    FScrollBarWidthGot: Boolean;
    FScrollBarLeft: Integer;
    FScrollbarRight: Integer;
    procedure HookMouseUp(Editor: TEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HookMouseDown(Editor: TEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HookMouseMove(Editor: TEditorObject; Shift: TShiftState;
      X, Y: Integer);
    procedure SetInScrollBar(const Value: Boolean);
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

    property InScrollBar: Boolean read FInScrollBar write SetInScrollBar;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// ���Թҽ� EditControl ����¼��Ĳ˵�ר��
//==============================================================================

{ TCnTestEditCtrlMouseHookWizard }

procedure TCnTestEditCtrlMouseHookWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditCtrlMouseHookWizard.Create;
begin
  inherited;

end;

destructor TCnTestEditCtrlMouseHookWizard.Destroy;
begin
  EditControlWrapper.RemoveEditorMouseDownNotifier(HookMouseDown);
  EditControlWrapper.RemoveEditorMouseUpNotifier(HookMouseUp);
  EditControlWrapper.RemoveEditorMouseMoveNotifier(HookMouseMove);
  inherited;
end;

procedure TCnTestEditCtrlMouseHookWizard.Execute;
begin
  EditControlWrapper.AddEditorMouseDownNotifier(HookMouseDown);
  EditControlWrapper.AddEditorMouseUpNotifier(HookMouseUp);
  EditControlWrapper.AddEditorMouseMoveNotifier(HookMouseMove);
  InfoDlg('Mouse Event Hooked.');
end;

function TCnTestEditCtrlMouseHookWizard.GetCaption: string;
begin
  Result := 'Test EditControl Mouse Hook';
end;

function TCnTestEditCtrlMouseHookWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditCtrlMouseHookWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditCtrlMouseHookWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditCtrlMouseHookWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditCtrlMouseHookWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test EditControl Mouse Hook Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for EditControl Mouse Hook';
end;

procedure TCnTestEditCtrlMouseHookWizard.HookMouseDown(Editor: TEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CnDebugger.TraceFmt('MouseDown at X %d, Y %d. Button %d.', [X, Y, Ord(Button)]);
end;

procedure TCnTestEditCtrlMouseHookWizard.HookMouseMove(Editor: TEditorObject;
  Shift: TShiftState; X, Y: Integer);
var
  SBI: TScrollBarInfo;
begin
  CnDebugger.TraceFmt('MouseMove at X %d, Y %d.', [X, Y]);
  if not FScrollBarWidthGot then
  begin
    FillChar(SBI, 0, SizeOf(TScrollBarInfo));
    SBI.cbSize := SizeOf(TScrollBarInfo);
    if not GetScrollBarInfo(TWinControl(Editor.EditControl).Handle, OBJID_VSCROLL, SBI) then
    begin
      CnDebugger.TraceMsg('Can NOT Get ScrollBar Info from EditControl. ' + GetLastErrorMsg(True));
      Exit;
    end;

    CnDebugger.TraceRect(SBI.rcScrollBar, 'Current EditControl ScrollBar Rect in Screen.');
    FScrollBarLeft := SBI.rcScrollBar.Left;
    FScrollbarRight := SBI.rcScrollBar.Right;

    FScrollBarWidthGot := True;
  end;
end;

procedure TCnTestEditCtrlMouseHookWizard.HookMouseUp(Editor: TEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CnDebugger.TraceFmt('MouseUp at X %d, Y %d. Button %d.', [X, Y, Ord(Button)]);
end;

procedure TCnTestEditCtrlMouseHookWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditCtrlMouseHookWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditCtrlMouseHookWizard.SetInScrollBar(
  const Value: Boolean);
begin
  if FInScrollBar <> Value then
  begin
    FInScrollBar := Value;
    CnDebugger.TraceBoolean(FInScrollBar, 'InScrollBar  Changed to');
  end;
end;

initialization
  RegisterCnWizard(TCnTestEditCtrlMouseHookWizard); // ע��˲���ר��

end.
