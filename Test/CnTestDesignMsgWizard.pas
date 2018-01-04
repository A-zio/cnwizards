{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2018 CnPack ������                       }
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

unit CnTestDesignMsgWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestDesignMsgWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע�����������������Ϣ������
* ����ƽ̨��Windows 7 + Delphi 6/7
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2017.01.03 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizMethodHook,
  CnWizCompilerConst;

type

//==============================================================================
// CnTestDesignMsgWizard �˵�ר��
//==============================================================================

{ TCnTestDesignMsgWizard }

  TCnTestDesignMsgWizard = class(TCnMenuWizard)
  private
    FHook: TCnMethodHook;
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
  CnDebug;

type
  TControlHack = class(TControl);

procedure MyControlWndProc(Self: TControlHack; var Message: TMessage);
var
  Form: TCustomForm;
  KeyState: TKeyboardState;  
  WheelMsg: TCMMouseWheel;
begin
  if (csDesigning in Self.ComponentState) then
  begin
    Form := GetParentForm(Self);
    if (Form <> nil) and (Form.Designer <> nil) and
      Form.Designer.IsDesignMsg(Self, Message) then
      begin
        CnDebugger.LogInterface(Form.Designer);
        
        CnDebugger.LogPointer(PPointer(PPointer(Form.Designer)^)^);               // QueryInterface
        CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 4)^);  // _AddRef
        CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 8)^);  // _Release
        CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 12)^); // Modified
        CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 16)^); // Notification
        CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 20)^); // GetCustomForm
        CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 24)^); // SetCustomForm
        CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 28)^); // GetIsControl
        CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 32)^); // SetIsControl
        CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 36)^); // IsDesignMsg
        CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 40)^); // PaintGrid

        CnDebugger.LogFmt('IsDesignMsg, Ignored: %8.8x.', [Message.Msg]);
        Exit;
      end;
  end;
  if (Message.Msg >= WM_KEYFIRST) and (Message.Msg <= WM_KEYLAST) then
  begin
    Form := GetParentForm(Self);
    if (Form <> nil) and Form.WantChildKey(Self, Message) then Exit;
  end
  else if (Message.Msg >= WM_MOUSEFIRST) and (Message.Msg <= WM_MOUSELAST) then
  begin
    if not (csDoubleClicks in Self.ControlStyle) then
      case Message.Msg of
        WM_LBUTTONDBLCLK, WM_RBUTTONDBLCLK, WM_MBUTTONDBLCLK:
          Dec(Message.Msg, WM_LBUTTONDBLCLK - WM_LBUTTONDOWN);
      end;
    case Message.Msg of
      WM_MOUSEMOVE: Application.HintMouseMessage(Self, Message);
      WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
        begin
          if Self.DragMode = dmAutomatic then
          begin
            Self.BeginAutoDrag;
            Exit;
          end;
          Self.ControlState := Self.ControlState + [csLButtonDown];
        end;
      WM_LBUTTONUP:
        Self.ControlState := Self.ControlState - [csLButtonDown];
    else
      with Mouse do
        if WheelPresent and (RegWheelMessage <> 0) and
          (Message.Msg = RegWheelMessage) then
        begin
          GetKeyboardState(KeyState);
          with WheelMsg do
          begin
            Msg := Message.Msg;
            ShiftState := KeyboardStateToShiftState(KeyState);
            WheelDelta := Message.WParam;
            Pos := TSmallPoint(Message.LParam);
          end;
          Self.MouseWheelHandler(TMessage(WheelMsg));
          Exit;
        end;
    end;
  end
  else if Message.Msg = CM_VISIBLECHANGED then
    with Message do
      Self.SendDockNotification(Msg, WParam, LParam);
  Self.Dispatch(Message);
end;

//==============================================================================
// CnTestDesignMsgWizard �˵�ר��
//==============================================================================

{ TCnTestDesignMsgWizard }

procedure TCnTestDesignMsgWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

constructor TCnTestDesignMsgWizard.Create;
begin
  inherited;
  FHook := TCnMethodHook.Create(GetBplMethodAddress(@TControlHack.WndProc),
    @MyControlWndProc, False, False);
end;

destructor TCnTestDesignMsgWizard.Destroy;
begin
  FHook.Free;
  inherited;
end;

procedure TCnTestDesignMsgWizard.Execute;
begin
  if not (Compiler in [cnDelphi6, cnDelphi7]) then
  begin
    ShowMessage('NO. Only Delphi6/7 Support.');
    Exit;
  end;

  if not FHook.Hooked then
  begin
    FHook.HookMethod;
    ShowMessage('Design Message Hooked.');
  end
  else
  begin
    FHook.UnhookMethod;
    ShowMessage('Design Message Unhooked.');
  end;
end;

function TCnTestDesignMsgWizard.GetCaption: string;
begin
  Result := 'Hook Design Message';
end;

function TCnTestDesignMsgWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestDesignMsgWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestDesignMsgWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestDesignMsgWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestDesignMsgWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Design Message Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Design Message';
end;

procedure TCnTestDesignMsgWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestDesignMsgWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestDesignMsgWizard); // ע��˲���ר��

end.
