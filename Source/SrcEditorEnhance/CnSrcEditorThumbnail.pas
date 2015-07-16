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

unit CnSrcEditorThumbnail;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭����չԤ������ͼʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiuao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWinXP + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.07.16
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, ToolsAPI,
  IniFiles, Forms, ExtCtrls, Menus, StdCtrls, CnCommon,
  CnWizUtils, CnWizIdeUtils, CnWizNotifier, CnEditControlWrapper, CnWizClasses;

const
  WM_NCMOUSELEAVE       = $02A2;

type
  TCnSrcEditorThumbnail = class;

  TCnSrcThumbnailForm = class(TCustomMemo)
  private
    FMouseIn: Boolean;
    FThumbnail: TCnSrcEditorThumbnail;
    FPopup: TPopupMenu;
    FTopLine: Integer;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;

    procedure MouseLeave(var Msg: TMessage); message WM_MOUSELEAVE;

    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure MouseDblClick(var Msg: TWMMouse); message WM_LBUTTONDBLCLK;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetPos(X, Y: Integer);
    procedure SetTopLine(const Value: Integer; UseRelative: Boolean);

    property Thumbnail: TCnSrcEditorThumbnail read FThumbnail write FThumbnail;
    property TopLine: Integer read FTopLine; // ��ʾ�Ķ����кţ�0 ��ʼ
  end;

//==============================================================================
// ����༭����չ����ͼ����
//==============================================================================

{ TCnSrcEditorThumbnail }

  TCnSrcEditorThumbnail = class(TObject)
  private
    FActive: Boolean;
    FThumbForm: TCnSrcThumbnailForm;
    // FThumbMemo: TMemo;
    FInScroll: Boolean;
    FEditControl: TWinControl;
    FPoint: TPoint; // ��������洢�����λ������ʾ���壬x��y �� FEditControl �ڵ�����
    FShowTimer: TTimer;
    FHideTimer: TTimer;
    FShowThumbnail: Boolean;
    procedure EditControlMouseMove(Editor: TEditorObject; Shift: TShiftState;
      X, Y: Integer; IsNC: Boolean);
    procedure EditControlMouseLeave(Editor: TEditorObject; IsNC: Boolean);

    procedure OnShowTimer(Sender: TObject);
    procedure OnHideTimer(Sender: TObject);

    procedure CheckCreateForm;
    procedure UpdateThumbnailForm(IsShow: Boolean; UseRelative: Boolean);
    procedure SetShowThumbnail(const Value: Boolean);
    // �������ݡ���������ͼ���ڵ�λ�ù����㡢��ʾ����ͼ����

    procedure CheckNotifiers;
  protected
    procedure SetActive(Value: Boolean);
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    procedure ResetSettings(Ini: TCustomIniFile);
    procedure LanguageChanged(Sender: TObject);

    property Active: Boolean read FActive write SetActive;
    property ShowThumbnail: Boolean read FShowThumbnail write SetShowThumbnail;
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
{$IFDEF DEBUG}
  CnDebug;
{$ENDIF}

const
  SHOW_INTERVAL = 1000;

  CS_DROPSHADOW = $20000;

  csThumbnail = 'Thumbnail';                   
  csShowThumbnail = 'ShowThumbnail';

//==============================================================================
// ����༭����չ����ͼ
//==============================================================================

{ TCnSrcEditorThumbnail }

procedure TCnSrcEditorThumbnail.ApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
begin
  if (Msg.message = WM_MOUSEWHEEL) and FThumbForm.Visible then
  begin
    SendMessage(FThumbForm.Handle, WM_MOUSEWHEEL, Msg.wParam, Msg.lParam);
    Handled := True;
  end
  else if FThumbForm.Visible and (Msg.hwnd = FThumbForm.Handle) and
   (Msg.message > WM_MOUSEFIRST) and (Msg.message < WM_MOUSELAST) then
  begin
    // ���γ� MOUSEMOVE �� MOUSEWHEEL ֮���һ�������Ϣ
    // ��˫�����Ǵ���Ϊ��ת
    if Msg.message = WM_LBUTTONDBLCLK then
      SendMessage(FThumbForm.Handle, WM_LBUTTONDBLCLK, Msg.wParam, Msg.lParam);
    Handled := True;
  end;
end;

procedure TCnSrcEditorThumbnail.CheckCreateForm;
var
  AFont: TFont;
  Canvas: TControlCanvas;
begin
  if FThumbForm = nil then
  begin
    FThumbForm := TCnSrcThumbnailForm.Create(nil);
    FThumbForm.Thumbnail := Self;
    FThumbForm.DoubleBuffered := True;
    FThumbForm.ReadOnly := True;
    FThumbForm.Parent := Application.MainForm;
    FThumbForm.Visible := False;
    FThumbForm.BorderStyle := bsSingle;
    FThumbForm.Color := clInfoBk;
    FThumbForm.Width := 500;
    FThumbForm.Height := 200;
    // FThumbForm.ScrollBars := ssVertical;

    AFont := TFont.Create;
    AFont.Name := 'Courier New';  {Do NOT Localize}
    AFont.Size := 10;

    GetIDERegistryFont('', AFont);
    FThumbForm.Font := AFont;
    Canvas := TControlCanvas.Create;
    Canvas.Control := FThumbForm;
    Canvas.Font := AFont;
    FThumbForm.Width := Canvas.TextWidth(Spc(82));
    Canvas.Free;
  end;
end;

procedure TCnSrcEditorThumbnail.CheckNotifiers;
begin
{$IFDEF DEBUG}
  CnDebugger.TraceCurrentStack;
  CnDebugger.TraceBoolean(Active);
  CnDebugger.TraceBoolean(ShowThumbnail);
{$ENDIF}
  if Active and ShowThumbnail then
  begin
    EditControlWrapper.AddEditorMouseMoveNotifier(EditControlMouseMove);
    EditControlWrapper.AddEditorMouseLeaveNotifier(EditControlMouseLeave);
  end
  else
  begin
    EditControlWrapper.RemoveEditorMouseMoveNotifier(EditControlMouseMove);
    EditControlWrapper.REmoveEditorMouseLeaveNotifier(EditControlMouseLeave);
  end;
end;

constructor TCnSrcEditorThumbnail.Create;
begin
  inherited;
  // FShowThumbnail := True;

  FShowTimer := TTimer.Create(nil);
  FShowTimer.Enabled := False;
  FShowTimer.Interval := SHOW_INTERVAL;
  FShowTimer.OnTimer := OnShowTimer;

  FHideTimer := TTimer.Create(nil);
  FHideTimer.Enabled := False;
  FHideTimer.Interval := SHOW_INTERVAL;
  FHideTimer.OnTimer := OnHideTimer;

  CheckCreateForm;
  CheckNotifiers;
  CnWizNotifierServices.AddApplicationMessageNotifier(ApplicationMessage);
end;

destructor TCnSrcEditorThumbnail.Destroy;
begin
  CnWizNotifierServices.RemoveApplicationMessageNotifier(ApplicationMessage);
  EditControlWrapper.RemoveEditorMouseMoveNotifier(EditControlMouseMove);
  EditControlWrapper.REmoveEditorMouseLeaveNotifier(EditControlMouseLeave);

  FHideTimer.Free;
  FShowTimer.Free;

  FThumbForm.Free;
  inherited;
end;

procedure TCnSrcEditorThumbnail.EditControlMouseLeave(
  Editor: TEditorObject; IsNC: Boolean);
begin
  if not Active or not FShowThumbnail or (Editor.EditControl <> CnOtaGetCurrentEditControl) then
    Exit;
{$IFDEF DEBUG}
  CnDebugger.TraceFmt('MouseLeave. Is from NC: %d', [Integer(IsNc)]);
{$ENDIF}

  FInScroll := False;
  FShowTimer.Enabled := False; // �뿪�˵Ļ���׼����ʾ�ľ�ͣ��
  FHideTimer.Enabled := True;  // ׼������
end;

procedure TCnSrcEditorThumbnail.EditControlMouseMove(Editor: TEditorObject;
  Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  InRightScroll: Boolean;
begin
{$IFDEF DEBUG}
  CnDebugger.TraceFmt('MouseMove at X %d, Y %d. Is in NC: %d', [X, Y, Integer(IsNc)]);
{$ENDIF}
  if not Active or not FShowThumbnail or (Editor.EditControl <> CnOtaGetCurrentEditControl) then
    Exit;

  // �жϵ�ǰ�Ƿ�����Ҫ��ʾ����ͼ��������߼�Ϊ��X ���� ClientWidth ���� IsNC
  InRightScroll := (IsNC and (X >= Editor.EditControl.ClientWidth));
  FEditControl := TWinControl(Editor.EditControl);

  CheckCreateForm;
  if not FInScroll and InRightScroll then // ��һ�ν����˹�������
  begin
    // ֻ�е�һ�ν����˹�����������Ҫ�󲶻� MouseLeave
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('First enter scroll.');
{$ENDIF}
    FPoint.x := X;
    FPoint.y := Y;
    if not FThumbForm.Visible then
    begin
      // ��һ�ν�����������ʾ Thumbnail Form �Ķ�ʱ��
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('First enter scroll. enable timer');
{$ENDIF}
      FShowTimer.Enabled := True;
    end
    else
    begin
      // ��������ʾ�� Thumbnail ��λ�ò���������λ��
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('First enter scroll. Update position');
{$ENDIF}
      UpdateThumbnailForm(False, False);
    end;
  end
  else if InRightScroll then
  begin
    FPoint.x := X;
    FPoint.y := Y;
    // ���ڲ��������Ѿ���ʾ Thumbnail �ˣ���������������
    if FThumbForm.Visible then
    begin
      FHideTimer.Enabled := False;
      UpdateThumbnailForm(False, True);
    end;
  end;

  FInScroll := InRightScroll;
end;

procedure TCnSrcEditorThumbnail.LanguageChanged(Sender: TObject);
begin

end;

procedure TCnSrcEditorThumbnail.LoadSettings(Ini: TCustomIniFile);
begin
  ShowThumbnail := Ini.ReadBool(csThumbnail, csShowThumbnail, FShowThumbnail);
end;

procedure TCnSrcEditorThumbnail.OnHideTimer(Sender: TObject);
begin
  FHideTimer.Enabled := False;
  if FThumbForm <> nil then
    FThumbForm.Hide;
end;

procedure TCnSrcEditorThumbnail.OnShowTimer(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('OnShowTimer');
{$ENDIF}
  FShowTimer.Enabled := False;
  UpdateThumbnailForm(True, False);
end;

procedure TCnSrcEditorThumbnail.ResetSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnSrcEditorThumbnail.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csThumbnail, csShowThumbnail, FShowThumbnail);
end;

procedure TCnSrcEditorThumbnail.SetActive(Value: Boolean);
begin
  if Value <> FActive then
  begin
    FActive := Value;
    CheckNotifiers;

    if not FActive then
      if FThumbForm <> nil then
        FThumbForm.Hide;
  end;
end;

procedure TCnSrcEditorThumbnail.SetShowThumbnail(const Value: Boolean);
begin
  if FShowThumbnail <> Value then
  begin
    FShowThumbnail := Value;
    CheckNotifiers;

    if FThumbForm <> nil then
      FreeAndNil(FThumbForm);
  end;
end;

procedure TCnSrcEditorThumbnail.UpdateThumbnailForm(IsShow: Boolean; UseRelative: Boolean);
var
  P: TPoint;
  ThisLine: Integer;
begin
  CheckCreateForm;

  // �������ݡ���������ͼ���ڵ�λ�ù����㡢��ʾ����ͼ����
  if IsShow or (FThumbForm.Lines.Text = '') then
    FThumbForm.Lines.Text := CnOtaGetCurrentEditorSource;

  // FPoint ��Ҫ����ʱ�� FEditControl �ڵ����λ�� ���Դ�Ϊ׼���ô���λ��
  P := FPoint;
  P.x := FEditControl.Width;
  P := FEditControl.ClientToScreen(P);

  P.x := P.x - FThumbForm.Width - 20;
  P.y := P.y - FThumbForm.Height div 2;

  // ���ⳬ����Ļ
  if P.x < 0 then
    P.x := 0;
  if P.y < 0 then
    P.y := 0;

  if P.x + FThumbForm.Width > Screen.Width then
    P.x := Screen.Width - FThumbForm.Width;
  if P.y + FThumbForm.Height > Screen.Height then
    P.y := Screen.Height - FThumbForm.Height;

  FThumbForm.SetPos(P.x, P.y) ;

  // ����λ�ù�����
  ThisLine := FThumbForm.Lines.Count * FPoint.y div FEditControl.ClientHeight;
  FThumbForm.SetTopLine(ThisLine, UseRelative);

  if IsShow then
    FThumbForm.Visible := True;
end;

{ TCnSrcThumbnailForm }

constructor TCnSrcThumbnailForm.Create(AOwner: TComponent);
begin
  inherited;
  FPopup := TPopupMenu.Create(Self);
  PopupMenu := FPopup;  // ȡ���������Դ����Ҽ��˵�
end;

procedure TCnSrcThumbnailForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CHILDWINDOW {or WS_SIZEBOX} or WS_MAXIMIZEBOX
    or WS_BORDER;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;
  if CheckWinXP then
    Params.WindowClass.style := CS_DBLCLKS or CS_DROPSHADOW
  else
    Params.WindowClass.style := CS_DBLCLKS;
end;

procedure TCnSrcThumbnailForm.CreateWnd;
begin
  inherited;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);

  SendMessage(Handle, EM_SETMARGINS, EC_LEFTMARGIN, 5);
  SendMessage(Handle, EM_SETMARGINS, EC_RIGHTMARGIN, 5);
end;

destructor TCnSrcThumbnailForm.Destroy;
begin
  inherited;

end;

procedure TCnSrcThumbnailForm.MouseDblClick(var Msg: TWMMouse);
var
  View: IOTAEditView;
  P: TOTAEditPos;
begin
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('FThumbmail Mouse Dblclick');
{$ENDIF}

  // ȥ TopLine ����ʶ�ĵط�
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    P.Col := 1;
    P.Line := TopLine + 1; // 0 ��ʼ��� 1 ��ʼ
    CnOtaGotoEditPos(P, View, True);
  end;

  Hide;
end;

procedure TCnSrcThumbnailForm.MouseLeave(var Msg: TMessage);
begin
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('FThumbmail Mouse Hover');
{$ENDIF}

  FMouseIn := False;
  FThumbnail.FHideTimer.Enabled := True;
end;

procedure TCnSrcThumbnailForm.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Tme: TTrackMouseEvent;
begin
  inherited;
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('FThumbmail Mouse Move');
{$ENDIF}
  if not FMouseIn then
  begin
    Tme.cbSize := SizeOf(TTrackMouseEvent);
    Tme.dwFlags := TME_LEAVE;
    Tme.hwndTrack := Handle;
    TrackMouseEvent(Tme);
  end;

  FMouseIn := True;
  FThumbnail.FHideTimer.Enabled := False;
end;

procedure TCnSrcThumbnailForm.MouseWheel(var Msg: TWMMouseWheel);
var
  NewLine: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('FThumbmail Mouse Wheel ' + IntToStr(Msg.WheelDelta));
{$ENDIF}
  if Msg.WheelDelta > 0 then
    NewLine := TopLine - Mouse.WheelScrollLines
  else
    NewLine := TopLine + Mouse.WheelScrollLines;

  if NewLine < 0 then
    NewLine := 0;
  if NewLine > Lines.Count then
    NewLine := Lines.Count;

  SetTopLine(NewLine, True);
end;

procedure TCnSrcThumbnailForm.SetPos(X, Y: Integer);
begin
  SetWindowPos(Handle, HWND_TOPMOST, X, Y, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE);
end;

procedure TCnSrcThumbnailForm.SetTopLine(const Value: Integer; UseRelative: Boolean);
begin
  if FTopLine <> Value then
  begin
    if UseRelative then
      SendMessage(Handle, EM_LINESCROLL, 0, Value - FTopLine)
    else
    begin
      SendMessage(Handle, EM_LINESCROLL, 0, -Lines.Count);
      SendMessage(Handle, EM_LINESCROLL, 0, Value);
    end;
    FTopLine := Value;
  end;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.


