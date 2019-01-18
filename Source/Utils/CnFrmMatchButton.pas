{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2019 CnPack ������                       }
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

unit CnFrmMatchButton;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭����������Ԫ
* ��Ԫ���ߣ�liuxiao (liuxiao@cnpack.org)
* ��    ע�����������߰�ť�������˵�ѡ��ƥ�䷽ʽ�Ĺ��� Frame
* ����ƽ̨��PWinXP + Delphi 5.01
* ���ݲ��ԣ�PWinXP/7 + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2018.04.30
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, ToolWin, ExtCtrls, CnWizUtils, CnWizShareImages;

type
  TCnMatchButtonFrame = class(TPanel)
  private
    tlb1: TToolBar;
    btnMatchMode: TToolButton;
    pmMatchMode: TPopupMenu;
    FOnModeChange: TNotifyEvent;
    function GetMatchMode: TCnMatchMode;
    procedure SetMatchMode(const Value: TCnMatchMode);
    procedure btnMatchModeClick(Sender: TObject);
    procedure mniMatchClick(Sender: TObject);

  protected
    procedure DoModeChange; virtual;
  public
    mniMatchStart: TMenuItem;
    mniMatchAny: TMenuItem;
    mniMatchFuzzy: TMenuItem;

    constructor Create(AOwner: TComponent); override;
    procedure CreateComponents;
    procedure SyncButtonHint;

    property MatchMode: TCnMatchMode read GetMatchMode write SetMatchMode;
    property OnModeChange: TNotifyEvent read FOnModeChange write FOnModeChange;
  end;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{ TCnMatchButtonFrame }

procedure TCnMatchButtonFrame.CreateComponents;
begin
  //tlb1
  tlb1 := TToolBar.Create(Self);

  //btnMatchMode
  btnMatchMode := TToolButton.Create(Self);

  //tlb1
  tlb1.Name := 'tlb1';
  tlb1.Parent := Self;
  tlb1.Left := 0;
  tlb1.Top := 0;
  tlb1.Width := 40;
  tlb1.Height := 25;
  tlb1.Align := alNone;
  tlb1.EdgeBorders := [];
  tlb1.Flat := True;
  tlb1.Images := dmCnSharedImages.Images;
  tlb1.TabOrder := 0;

  //btnMatchMode
  btnMatchMode.Name := 'btnMatchMode';
  btnMatchMode.Parent := tlb1;
  btnMatchMode.Left := 0;
  btnMatchMode.Top := 0;
  btnMatchMode.DropdownMenu := pmMatchMode;
  btnMatchMode.Grouped := True;
  btnMatchMode.ImageIndex := 28;
  btnMatchMode.Style := tbsDropDown;
  btnMatchMode.OnClick := btnMatchModeClick;

  //pmMatchMode
  pmMatchMode := TPopupMenu.Create(Self);

  //mniMatchStart
  mniMatchStart := TMenuItem.Create(Self);

  //mniMatchAny
  mniMatchAny := TMenuItem.Create(Self);

  //mniMatchFuzzy
  mniMatchFuzzy := TMenuItem.Create(Self);

  //pmMatchMode
  pmMatchMode.Name := 'pmMatchMode';
  pmMatchMode.Images := dmCnSharedImages.Images;

  //mniMatchStart
  mniMatchStart.Name := 'mniMatchStart';
  pmMatchMode.Items.Add(mniMatchStart);
  mniMatchStart.Caption := 'Match From &Start';
  mniMatchStart.Hint := 'Match From Start';
  mniMatchStart.ImageIndex := 27;
  mniMatchStart.OnClick := mniMatchClick;

  //mniMatchAny
  mniMatchAny.Name := 'mniMatchAny';
  pmMatchMode.Items.Add(mniMatchAny);
  mniMatchAny.Caption := 'Match &All Parts';
  mniMatchAny.Checked := True;
  mniMatchAny.Hint := 'Match All Parts';
  mniMatchAny.ImageIndex := 28;
  mniMatchAny.OnClick := mniMatchClick;

  //mniMatchFuzzy
  mniMatchFuzzy.Name := 'mniMatchFuzzy';
  pmMatchMode.Items.Add(mniMatchFuzzy);
  mniMatchFuzzy.Caption := '&Fuzzy Match';
  mniMatchFuzzy.Hint := 'Fuzzy Match';
  mniMatchFuzzy.ImageIndex := 94;
  mniMatchFuzzy.OnClick := mniMatchClick;

  btnMatchMode.DropdownMenu := pmMatchMode;
end;

procedure TCnMatchButtonFrame.DoModeChange;
begin
  if Assigned(FOnModeChange) then
    FOnModeChange(Self);
end;

function TCnMatchButtonFrame.GetMatchMode: TCnMatchMode;
begin
  if mniMatchStart.Checked then
    Result := mmStart
  else if mniMatchAny.Checked then
    Result := mmAnywhere
  else
    Result := mmFuzzy;
end;

procedure TCnMatchButtonFrame.SetMatchMode(const Value: TCnMatchMode);
var
  I, Idx: Integer;
begin
  if Value <> MatchMode then
  begin
    Idx := Ord(Value);
    if (Idx < 0) or (Idx >= pmMatchMode.Items.Count) then
      Exit;

    for I := 0 to pmMatchMode.Items.Count - 1 do
      pmMatchMode.Items[I].Checked := False;

    pmMatchMode.Items.Items[Idx].Checked := True;
    btnMatchMode.ImageIndex := pmMatchMode.Items.Items[Idx].ImageIndex;
    SyncButtonHint;

    DoModeChange;
  end;
end;

procedure TCnMatchButtonFrame.mniMatchClick(Sender: TObject);
var
  Idx: Integer;
begin
  if Sender is TMenuItem then
  begin
    Idx := (Sender as TMenuItem).MenuIndex;
    if TCnMatchMode(Idx) in [Low(TCnMatchMode)..High(TCnMatchMode)] then
      MatchMode := TCnMatchMode(Idx);
  end;
end;

procedure TCnMatchButtonFrame.btnMatchModeClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := Ord(MatchMode);
  if Idx = Ord(High(TCnMatchMode)) then
    Idx := 0
  else
    Inc(Idx);

  MatchMode := TCnMatchMode(Idx);
end;

procedure TCnMatchButtonFrame.SyncButtonHint;
var
  Idx: Integer;
begin
  Idx := Ord(MatchMode);
  if (Idx >= 0) and (Idx < pmMatchMode.Items.Count) then
    btnMatchMode.Hint := pmMatchMode.Items.Items[Idx].Hint;
end;

constructor TCnMatchButtonFrame.Create(AOwner: TComponent);
begin
  inherited;
  Height := 25;
  Width := 50;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  BevelWidth := 1;
end;

end.
