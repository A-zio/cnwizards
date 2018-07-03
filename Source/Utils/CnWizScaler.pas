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

unit CnWizScaler;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����ר�Ұ�����������ڱ�������ʵ�ֵ�Ԫ������Ļ DPI �޹�
* ��Ԫ���ߣ���Х liuxiao@cnpack.org
* ��    ע��
* ����ƽ̨��PWinXP SP3 + Delphi 7
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2018.07.16 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Windows, Controls, Forms;

procedure ScaleForm(AForm: TCustomForm; Factor: Single);

implementation

type
  TControlHack = class(TControl);

procedure ScaleControl(Control: TControl; Factor: Single; UseClient: Boolean = False);
var
  X, Y, W, H: Integer;
begin
  X := Round(Control.Left * Factor);
  Y := Round(Control.Top * Factor);

  if UseClient then
  begin
    if not (csFixedWidth in Control.ControlStyle) then
      W := Round(Control.ClientWidth * Factor)
    else
      W := Control.ClientWidth;

    if not (csFixedHeight in Control.ControlStyle) then
      H := Round(Control.ClientHeight * Factor)
    else
      H := Control.ClientHeight;
  end
  else
  begin
    if not (csFixedWidth in Control.ControlStyle) then
      W := Round(Control.Width * Factor)
    else
      W := Control.Width;

    if not (csFixedHeight in Control.ControlStyle) then
      H := Round(Control.Height * Factor)
    else
      H := Control.Height;
  end;

  // Scale Constraints
  if Control.Constraints.MinWidth > 0 then
    Control.Constraints.MinWidth := Round(Control.Constraints.MinWidth * Factor);
  if Control.Constraints.MaxWidth > 0 then
    Control.Constraints.MaxWidth := Round(Control.Constraints.MaxWidth * Factor);
  if Control.Constraints.MinHeight > 0 then
    Control.Constraints.MinHeight := Round(Control.Constraints.MinHeight * Factor);
  if Control.Constraints.MaxHeight > 0 then
    Control.Constraints.MaxHeight := Round(Control.Constraints.MaxHeight * Factor);

{$IFDEF TCONTROL_HAS_MARGINS}
  // Scale Margins
  if Margins.Left > 0 then
    Margins.Left := Round(Margins.Left * Factor);
  if Margins.Top > 0 then
    Margins.Top := Round(Margins.Top * Factor);
  if Margins.Right > 0 then
    Margins.Right := Round(Margins.Right * Factor);
  if Margins.Bottom > 0 then
    Margins.Bottom := Round(Margins.Bottom * Factor);
{$ENDIF}

  if UseClient then
  begin
    Control.Left := X;
    Control.Top := Y;
    Control.ClientHeight := H;
    Control.ClientWidth := W;
  end
  else
    Control.SetBounds(X, Y, W, H);

  // Scale Font
  if not TControlHack(Control).ParentFont then
    TControlHack(Control).Font.Size := Round(TControlHack(Control).Font.Size * Factor);
end;

procedure ScaleWinControl(WinControl: TWinControl; Factor: Single;
  UseClient: Boolean = False);
var
  I: Integer;
  AControl: TControlHack;
  BackupAnchors: array of TAnchors;
begin
  WinControl.DisableAlign;
  SetLength(BackupAnchors, WinControl.ControlCount);
  try
    for I := 0 to WinControl.ControlCount - 1 do
    begin
      // ����ÿ���ؼ��� Anchors
      AControl := TControlHack(WinControl.Controls[I]);
      BackupAnchors[I] := AControl.Anchors;
      if AControl.Anchors <> [akTop, akLeft] then
      begin
{$IFDEF TCONTROL_HAS_EXPLICIT_BOUNDS}
        AControl.UpdateExplicitBounds;
{$ENDIF}
        AControl.Anchors := [akTop, akLeft];
      end;

      // ���ӿؼ���С
      if WinControl.Controls[I] is TWinControl then
        ScaleWinControl(WinControl.Controls[I] as TWinControl, Factor)
      else
        ScaleControl(WinControl.Controls[I], Factor);
    end;

    // �������С
    ScaleControl(WinControl, Factor, UseClient);

    // �ָ�ÿ���ӿؼ��� Anchors
    for I := 0 to WinControl.ControlCount - 1 do
    begin
      AControl := TControlHack(WinControl.Controls[I]);
      if AControl.Anchors <> BackupAnchors[I] then
      begin
        AControl.Anchors := BackupAnchors[I];
      end;
    end;
  finally
    SetLength(BackupAnchors, 0);
    WinControl.EnableAlign;
  end;
end;

procedure ScaleForm(AForm: TCustomForm; Factor: Single);
begin
  if Abs(Factor - 1.0) < 0.001 then
    Exit;

  ScaleWinControl(AForm, Factor, True);
end;

end.
