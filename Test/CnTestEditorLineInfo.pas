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

unit CnTestEditorLineInfo;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Կؼ����װ�Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 7 ����
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id:  CnTestPaletteWizard 1146 2012-10-24 06:25:41Z liuxiaoshanzhashu@gmail.com $
* �޸ļ�¼��2016.04.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TTestEditorLineInfoForm = class(TForm)
    lstInfo: TListBox;
    EditorTimer: TTimer;
    procedure EditorTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//==============================================================================
// ���Ա༭����������Ϣ�Ĳ�����ר��
//==============================================================================

{ TCnTestEditorLineInfoWizard }

  TCnTestEditorLineInfoWizard = class(TCnMenuWizard)
  private
    FTestEdiotrLineForm: TTestEditorLineInfoForm;
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

implementation

uses
  CnWizIdeUtils, CnDebug, CnEditControlWrapper;

{$R *.DFM}

//==============================================================================
// ���Ա༭����������Ϣ�Ĳ�����ר��
//==============================================================================

{ TCnTestEditorLineInfoWizard }

procedure TCnTestEditorLineInfoWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditorLineInfoWizard.Create;
begin
  inherited;
  FTestEdiotrLineForm := TTestEditorLineInfoForm.Create(Application);
end;

procedure TCnTestEditorLineInfoWizard.Execute;
begin
  FTestEdiotrLineForm.Show;
  FTestEdiotrLineForm.EditorTimer.Enabled := True;
end;

function TCnTestEditorLineInfoWizard.GetCaption: string;
begin
  Result := 'Test Editor Line Info';
end;

function TCnTestEditorLineInfoWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditorLineInfoWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditorLineInfoWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditorLineInfoWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorLineInfoWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Line Info Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Editor Line Info';
end;

procedure TCnTestEditorLineInfoWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorLineInfoWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TTestEditorLineInfoForm.EditorTimerTimer(Sender: TObject);
const
  SEP = '================================================';
var
  EditView: IOTAEditView;
  EditPos: TOTAEditPos;
  CharPos: TOTACharPos;
  Text: string;
  LineNo: Integer;
  CharIndex: Integer;
  EditControl: TControl;
  StatusBar: TStatusBar;
  PasParser: TCnGeneralPasStructParser;
  Stream: TMemoryStream;
  Element, LineFlag: Integer;
begin
  lstInfo.Clear;
  lstInfo.Items.Add(SEP);
  // NtaGetCurrentLine(LineText Property)/GetTextAtLine CursorPos ConvertPos

  CnNtaGetCurrLineText(Text, LineNo, CharIndex);

  lstInfo.Items.Add('CnNtaGetCurrLineText using LineText property:');
  lstInfo.Items.Add(Text);
  lstInfo.Items.Add(Format('LineNo %d, CharIndex %d.', [LineNo, CharIndex]));

  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;

  Text := EditControlWrapper.GetTextAtLine(EditControl, LineNo);
  lstInfo.Items.Add(SEP);
  lstInfo.Items.Add(Format('EditControlWrapper.GetTextAtLine %d', [LineNo]));
  lstInfo.Items.Add(Text);

  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);

  lstInfo.Items.Add(SEP);
  lstInfo.Items.Add('CursorPos/EditPos(1/1) CharPos(1/0) Conversion.');
  lstInfo.Items.Add(Format('EditPos %d:%d, CharPos %d:%d.', [EditPos.Line,
    EditPos.Col, CharPos.Line, CharPos.CharIndex]));


  lstInfo.Items.Add(SEP);
  lstInfo.Items.Add('CnOtaGetCurrentCharPosFromCursorPosForParser.');
  if CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos) then
    lstInfo.Items.Add(Format('For Parser CharPos (Ansi/Wide) %d:%d.',
      [CharPos.Line, CharPos.CharIndex]))
  else
    lstInfo.Items.Add('Get Current Position Failed.');

  lstInfo.Items.Add(SEP);
  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
  lstInfo.Items.Add(Format('GetAttributeAtPos EditPos %d:%d. Element %d, Flag %d.', [EditPos.Line,
    EditPos.Col, Element, LineFlag]));

  PasParser := TCnGeneralPasStructParser.Create;
  Stream := TMemoryStream.Create;

  try
    CnGeneralSaveEditorToStream(EditView.Buffer, Stream);
    CnPasParserParseSource(PasParser, Stream, IsDpr(EditView.Buffer.FileName)
      or IsInc(EditView.Buffer.FileName), False);

    CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
    PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

{$IFDEF BDS}
    if PasParser.BlockStartToken <> nil then
      lstInfo.Items.Add(Format('OuterStart: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.BlockStartToken.LineNumber, PasParser.BlockStartToken.CharIndex,
        PasParser.BlockStartToken.AnsiIndex, PasParser.BlockStartToken.ItemLayer,
        PasParser.BlockStartToken.Token]));
    if PasParser.BlockCloseToken <> nil then
      lstInfo.Items.Add(Format('OuterClose: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.BlockCloseToken.LineNumber, PasParser.BlockCloseToken.CharIndex,
         PasParser.BlockCloseToken.AnsiIndex, PasParser.BlockCloseToken.ItemLayer,
         PasParser.BlockCloseToken.Token]));
    if PasParser.InnerBlockStartToken <> nil then
      lstInfo.Items.Add(Format('InnerStart: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.InnerBlockStartToken.LineNumber, PasParser.InnerBlockStartToken.CharIndex,
         PasParser.InnerBlockStartToken.AnsiIndex, PasParser.InnerBlockStartToken.ItemLayer,
         PasParser.InnerBlockStartToken.Token]));
    if PasParser.InnerBlockCloseToken <> nil then
      lstInfo.Items.Add(Format('InnerClose: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.InnerBlockCloseToken.LineNumber, PasParser.InnerBlockCloseToken.CharIndex,
         PasParser.InnerBlockCloseToken.AnsiIndex, PasParser.InnerBlockCloseToken.ItemLayer,
         PasParser.InnerBlockCloseToken.Token]));

{$ELSE}
    if PasParser.BlockStartToken <> nil then
      lstInfo.Items.Add(Format('OuterStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.BlockStartToken.LineNumber, PasParser.BlockStartToken.CharIndex,
        PasParser.BlockStartToken.ItemLayer, PasParser.BlockStartToken.Token]));
    if PasParser.BlockCloseToken <> nil then
      lstInfo.Items.Add(Format('OuterClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.BlockCloseToken.LineNumber, PasParser.BlockCloseToken.CharIndex,
        PasParser.BlockCloseToken.ItemLayer, PasParser.BlockCloseToken.Token]));
    if PasParser.InnerBlockStartToken <> nil then
      lstInfo.Items.Add(Format('InnerStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.InnerBlockStartToken.LineNumber, PasParser.InnerBlockStartToken.CharIndex,
        PasParser.InnerBlockStartToken.ItemLayer, PasParser.InnerBlockStartToken.Token]));
    if PasParser.InnerBlockCloseToken <> nil then
      lstInfo.Items.Add(Format('InnerClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.InnerBlockCloseToken.LineNumber, PasParser.InnerBlockCloseToken.CharIndex,
        PasParser.InnerBlockCloseToken.ItemLayer, PasParser.InnerBlockCloseToken.Token]));
{$ENDIF}
  finally
    PasParser.Free;
    Stream.Free;
  end;

  StatusBar := GetEditWindowStatusBar;
  if (StatusBar <> nil) and (StatusBar.Panels.Count > 0) then
  begin
    lstInfo.Items.Add(SEP);
    lstInfo.Items.Add('Editor Position at StatusBar:');
    lstInfo.Items.Add(StatusBar.Panels[0].Text);
  end;
end;

initialization
  RegisterCnWizard(TCnTestEditorLineInfoWizard); // ע��˲���ר��

end.
