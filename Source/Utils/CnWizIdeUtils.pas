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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is partly derived from GExperts 1.2                             }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnWizIdeUtils;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE ��ع�����Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
*           LiuXiao����Х��liuxiao@cnpack.org
* ��    ע���õ�Ԫ����������ֲ�� GExperts 1.12 Src
*           ��ԭʼ������ GExperts License �ı���
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2016.04.04 by liuxiao
*               ���� 2010 ���ϰ汾���·��ؼ����֧��
*           2012.09.19 by shenloqi
*               ��ֲ��Delphi XE3
*           2005.05.06 V1.3
*               hubdog ���� ��ȡ�汾��Ϣ�ĺ���
*           2004.03.19 V1.2
*               LiuXiao ���� CnPaletteWrapper����װ�ؼ����ĸ�������
*           2003.03.06 V1.1
*               GetLibraryPath ��չ��·��������Χ��֧�ֹ�������·��
*           2002.12.05 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Controls, SysUtils, Graphics, Forms, Tabs,
  Menus, Buttons, ComCtrls, StdCtrls, ExtCtrls, TypInfo, ToolsAPI, 
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, ComponentDesigner,
  {$ELSE}
  DsgnIntf, LibIntf,
  {$ENDIF}
  CnPasCodeParser, CnWidePasParser,
  CnWizUtils, CnWizEditFiler, CnCommon, CnWizOptions, CnWizCompilerConst;

//==============================================================================
// IDE �еĳ�������
//==============================================================================

const
  // IDE Action ����
  SEditSelectAllCommand = 'EditSelectAllCommand';

  // Editor �����Ҽ��˵�����
  SMenuClosePageName = 'ecClosePage';
  SMenuClosePageIIName = 'ecClosePageII';
  SMenuEditPasteItemName = 'EditPasteItem';
  SMenuOpenFileAtCursorName = 'ecOpenFileAtCursor';

  // Editor �����������
  EditorFormClassName = 'TEditWindow';
  EditControlName = 'Editor';
  EditControlClassName = 'TEditControl';
  DesignControlClassName = 'TEditorFormDesigner';
  WelcomePageClassName = 'TWelcomePageFrame';
  DisassemblyViewClassName = 'TDisassemblyView';
{$IFDEF BDS}
  {$IFDEF BDS4_UP} // BDS 2006 RAD Studio 2007 �ı�ǩҳ����
  XTabControlClassName = 'TIDEGradientTabSet';
  {$ELSE} // BDS 2005 �ı�ǩҳ����
  XTabControlClassName = 'TCodeEditorTabControl';
  {$ENDIF}
{$ELSE} // Delphi BCB �ı�ǩҳ����
  XTabControlClassName = 'TXTabControl';
{$ENDIF BDS}
  XTabControlName = 'TabControl';

  TabControlPanelName = 'TabControlPanel';
  CodePanelName = 'CodePanel';
  TabPanelName = 'TabPanel';

  // ����鿴��
  PropertyInspectorClassName = 'TPropertyInspector';
  PropertyInspectorName = 'PropertyInspector';

  // �༭�����öԻ���
{$IFDEF BDS}
  SEditorOptionDlgClassName = 'TDefaultEnvironmentDialog';
  SEditorOptionDlgName = 'DefaultEnvironmentDialog';
{$ELSE} {$IFDEF BCB}
  SEditorOptionDlgClassName = 'TCppEditorPropertyDialog';
  SEditorOptionDlgName = 'CppEditorPropertyDialog';
{$ELSE}
  SEditorOptionDlgClassName = 'TPasEditorPropertyDialog';
  SEditorOptionDlgName = 'PasEditorPropertyDialog';
{$ENDIF} {$ENDIF}

  // �ؼ������������������
  SCnPaletteTabControlClassName = 'TComponentPaletteTabControl';
  SCnPalettePropSelectedIndex = 'SelectedIndex';
  SCnPalettePropSelectedToolName = 'SelectedToolName';
  SCnPalettePropSelector = 'Selector';
  SCnPalettePropPalToolCount = 'PalToolCount';

  // D2010 �����ϰ汾���¿ؼ��壬һ�� TComponentToolbarFrame ����� TGradientTabSet
  SCnNewPaletteFrameClassName = 'TComponentToolbarFrame';
  SCnNewPaletteFrameName = 'ComponentToolbarFrame';
  SCnNewPaletteTabClassName = 'TGradientTabSet';
  SCnNewPaletteTabName = 'TabControl';
  SCnNewPaletteTabItemsPropName = 'Items';
  SCnNewPaletteTabIndexPropName = 'TabIndex';
  SCnNewPalettePanelContainerName = 'PanelButtons';
  SCnNewPaletteButtonClassName = 'TPalItemSpeedButton';
  
  // ��Ϣ����
  SCnMessageViewFormClassName = 'TMessageViewForm';
  SCnMessageViewTabSetName = 'MessageGroups';
  SCnMvEditSourceItemName = 'mvEditSourceItem';

{$IFDEF BDS}
  SCnTreeMessageViewClassName = 'TBetterHintWindowVirtualDrawTree';
{$ELSE}
  SCnTreeMessageViewClassName = 'TTreeMessageView';
{$ENDIF}

  // ���õ�Ԫ���ܵ� Action ����
{$IFDEF DELPHI}
  SCnUseUnitActionName = 'FileUseUnitCommand';
{$ELSE}
  SCnUseUnitActionName = 'FileIncludeUnitHdrCommand';
{$ENDIF}

  SCnColor16Table: array[0..15] of TColor =
  ( clBlack, clMaroon, clGreen, clOlive,
    clNavy, clPurple, clTeal, clLtGray, clDkGray, clRed, clLime,
    clYellow, clBlue, clFuchsia, clAqua, clWhite);

type
{$IFDEF BDS}
  TXTabControl = TTabSet;
{$ELSE}
  TXTabControl = TTabControl;
{$ENDIF BDS}

{$IFDEF BDS}
  TXTreeView = TCustomControl;
{$ELSE}
  TXTreeView = TTreeView;
{$ENDIF BDS}

//==============================================================================
// IDE ����༭�����ܺ���
//==============================================================================

function IdeGetEditorSelectedLines(Lines: TStringList): Boolean;
{* ȡ�õ�ǰ����༭��ѡ���еĴ��룬ʹ������ģʽ�����ѡ���Ϊ�գ��򷵻ص�ǰ�д��롣}

function IdeGetEditorSelectedText(Lines: TStringList): Boolean;
{* ȡ�õ�ǰ����༭��ѡ���Ĵ��롣}

function IdeGetEditorSourceLines(Lines: TStringList): Boolean;
{* ȡ�õ�ǰ����༭��ȫ��Դ���롣}

function IdeSetEditorSelectedLines(Lines: TStringList): Boolean;
{* �滻��ǰ����༭��ѡ���еĴ��룬ʹ������ģʽ�����ѡ���Ϊ�գ����滻��ǰ�д��롣}

function IdeSetEditorSelectedText(Lines: TStringList): Boolean;
{* �滻��ǰ����༭��ѡ���Ĵ��롣}

function IdeSetEditorSourceLines(Lines: TStringList): Boolean;
{* �滻��ǰ����༭��ȫ��Դ���롣}

function IdeInsertTextIntoEditor(const Text: string): Boolean;
{* �����ı�����ǰ�༭����֧�ֶ����ı���}

function IdeEditorGetEditPos(var Col, Line: Integer): Boolean;
{* ���ص�ǰ���λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ�� }

function IdeEditorGotoEditPos(Col, Line: Integer; Middle: Boolean): Boolean;
{* �ƶ���굽ָ��λ�ã�Middle ��ʾ�Ƿ��ƶ���ͼ�����ġ�}

function IdeGetBlockIndent: Integer;
{* ��õ�ǰ�༭����������� }

function IdeGetSourceByFileName(const FileName: string): AnsiString;
{* �����ļ���ȡ�����ݡ�����ļ��� IDE �д򿪣����ر༭���е����ݣ����򷵻��ļ����ݡ�}

function IdeSetSourceByFileName(const FileName: string; Source: TStrings;
  OpenInIde: Boolean): Boolean;
{* �����ļ���д�����ݡ�����ļ��� IDE �д򿪣�д�����ݵ��༭���У��������
   OpenInIde Ϊ����ļ�д�뵽�༭����OpenInIde Ϊ��ֱ��д���ļ���}

function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
{* �жϱ�ʶ���Ƿ��ڹ���£�Ƶ�����ã���˴˴� View ��ָ�����������ü����Ӷ��Ż��ٶȣ����汾����ʹ�� }

function IsCurrentTokenW(AView: Pointer; AControl: TControl; Token: TCnWidePasToken): Boolean;
{* �жϱ�ʶ���Ƿ��ڹ���£�ͬ�ϣ���ʹ�� WideToken���ɹ� Unicode/Utf8 �����µ���}

//==============================================================================
// IDE ����༭�����ܺ���
//==============================================================================

function IdeGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
{* ȡ�ô���༭�����������FormEditor Ϊ nil ��ʾȡ��ǰ���� }

function IdeGetDesignedForm(Designer: IDesigner = nil): TCustomForm;
{* ȡ�õ�ǰ��ƵĴ��� }

function IdeGetFormSelection(Selections: TList; Designer: IDesigner = nil;
  ExcludeForm: Boolean = True): Boolean;
{* ȡ�õ�ǰ��ƴ�������ѡ������ }

function IdeGetIsEmbeddedDesigner: Boolean;
{* ȡ�õ�ǰ�Ƿ���Ƕ��ʽ��ƴ���ģʽ}

var
  IdeIsEmbeddedDesigner: Boolean = False;
  {* ��ǵ�ǰ�Ƿ���Ƕ��ʽ��ƴ���ģʽ��initiliazation ʱ����ʼ���������ֹ��޸���ֵ��
     ʹ�ô�ȫ�ֱ������Ա���Ƶ������ IdeGetIsEmbeddedDesigner ����}

//==============================================================================
// �޸��� GExperts Src 1.12 �� IDE ��غ���
//==============================================================================

function GetIdeMainForm: TCustomForm;
{* ���� IDE ������ (TAppBuilder) }

function GetIdeEdition: string;
{* ���� IDE �汾}

function GetComponentPaletteTabControl: TTabControl;
{* ������������󣬿���Ϊ�գ�ֻ֧�� 2010 ���°汾}

function GetNewComponentPaletteTabControl: TWinControl;
{* ���� 2010 �����ϵ�����������󣬿���Ϊ��}

function GetObjectInspectorForm: TCustomForm;
{* ���ض����������壬����Ϊ��}

function GetComponentPalettePopupMenu: TPopupMenu;
{* �����������Ҽ��˵�������Ϊ��}

function GetComponentPaletteControlBar: TControlBar;
{* �������������ڵ�ControlBar������Ϊ��}

function GetMainMenuItemHeight: Integer;
{* �������˵���߶� }

function IsIdeEditorForm(AForm: TCustomForm): Boolean;
{* �ж�ָ�������Ƿ�༭������}

function IsIdeDesignForm(AForm: TCustomForm): Boolean;
{* �ж�ָ�������Ƿ�������ڴ���}

procedure BringIdeEditorFormToFront;
{* ��Դ��༭����Ϊ��Ծ}

function IDEIsCurrentWindow: Boolean;
{* �ж� IDE �Ƿ��ǵ�ǰ�Ļ���� }

//==============================================================================
// ������ IDE ��غ���
//==============================================================================

function GetInstallDir: string;
{* ȡ��������װĿ¼}

{$IFDEF BDS}
function GetBDSUserDataDir: string;
{* ȡ�� BDS (Delphi8�Ժ�汾) ���û�����Ŀ¼ }
{$ENDIF}

procedure GetProjectLibPath(Paths: TStrings);
{* ȡ��ǰ���������� Path ����}

function GetFileNameFromModuleName(AName: string; AProject: IOTAProject = nil): string;
{* ����ģ������������ļ���}

function CnOtaGetVersionInfoKeys(Project: IOTAProject = nil): TStrings;
{* ��ȡ��ǰ��Ŀ�еİ汾��Ϣ��ֵ}

procedure GetLibraryPath(Paths: TStrings; IncludeProjectPath: Boolean = True);
{* ȡ���������е� LibraryPath ����}

function GetComponentUnitName(const ComponentName: string): string;
{* ȡ����������ڵĵ�Ԫ��}

procedure GetInstalledComponents(Packages, Components: TStrings);
{* ȡ�Ѱ�װ�İ����������������Ϊ nil�����ԣ�}

function GetIDERegistryFont(const RegItem: string; AFont: TFont): Boolean;
{* ��ĳ��ע���������ĳ�����岢��ֵ�� AFont
   RegItem ������ '', 'Assembler', 'Comment', 'Preprocessor',
    'Identifier', 'Reserved word', 'Number', 'Whitespace', 'String', 'Symbol'
    ��ע�����ͷ�Ѿ������˵ļ�ֵ}

type
  TEnumEditControlProc = procedure (EditWindow: TCustomForm; EditControl:
    TControl; Context: Pointer) of object;

function IsEditControl(AControl: TComponent): Boolean;
{* �ж�ָ���ؼ��Ƿ����༭���ؼ� }

function IsXTabControl(AControl: TComponent): Boolean;
{* �ж�ָ���ؼ��Ƿ�༭�����ڵ� TabControl �ؼ� }

function GetEditControlFromEditorForm(AForm: TCustomForm): TControl;
{* ���ر༭�����ڵı༭���ؼ� }

function GetCurrentEditControl: TControl;
{* ���ص�ǰ�Ĵ���༭���ؼ� }

function GetTabControlFromEditorForm(AForm: TCustomForm): TXTabControl;
{* ���ر༭�����ڵ� TabControl �ؼ� }

function GetStatusBarFromEditor(EditControl: TControl): TStatusBar;
{* �ӱ༭���ؼ�����������ı༭�����ڵ�״̬��}

function EnumEditControl(Proc: TEnumEditControlProc; Context: Pointer;
  EditorMustExists: Boolean = True): Integer;
{* ö�� IDE �еĴ���༭�����ں� EditControl �ؼ������ûص��������������� }

type
  TCnSrcEditorPage = (epCode, epDesign, epCPU, epWelcome, epOthers);

function GetCurrentTopEditorPage(AControl: TWinControl): TCnSrcEditorPage;
{* ȡ��ǰ�༭���ڶ���ҳ�����ͣ�����༭�����ؼ� }

procedure BeginBatchOpenClose;
{* ��ʼ�����򿪻�ر��ļ� }

procedure EndBatchOpenClose;
{* ���������򿪻�ر��ļ� }

function ConvertIDETreeNodeToTreeNode(Node: TObject): TTreeNode;
{* �� IDE �ڲ�ʹ�õ� TTreeControl�� Items ����ֵ�� TreeNode ǿ��ת���ɹ��õ� TreeNode}

function ConvertIDETreeNodesToTreeNodes(Nodes: TObject): TTreeNodes;
{* �� IDE �ڲ�ʹ�õ� TTreeControl�� Items ����ֵ�� TreeNodes ǿ��ת���ɹ��õ� TreeNodes}

//==============================================================================
// ��չ�ؼ�
//==============================================================================

type
  TCnToolBarComboBox = class(TComboBox)
  private
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
  end;

//==============================================================================
// �������װ��
//==============================================================================

type

{ TCnPaletteWrapper }

  TCnPaletteWrapper = class(TObject)
  {* ��װ�˿ؼ���������Ե��࣬�󲿷�ֻ֧�ֵͰ汾�ؼ���
     �߰汾�ؼ������������� Panel ��ɣ����� Panel ���� TGradientTab �� ToolbarSearch
     ���� Panel ���ɹ�����ť�Լ���� TPalItemSpeedButton �Ŀؼ�ͼ�갴ť
   }
  private
    FPalTab: TWinControl;  // �Ͱ汾ָ��� TabControl �������߰汾ָ�ϰ벿�ֵ� TGradientTabSet
    FPalette: TWinControl; // �Ͱ汾ָ��� TabControl �ڵ�����������߰汾ָ�°벿�ֵ��������
    FPageScroller: TWinControl;
    FUpdateCount: Integer;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    function ParseNameFromHint(const Hint: string): string;
{$ENDIF}
    function GetSelectedIndex: Integer;
    function GetSelectedToolName: string;
    function GetSelector: TSpeedButton;
    function GetPalToolCount: Integer;
    function GetActiveTab: string;
    function GetTabCount: Integer;
    function GetIsMultiLine: Boolean;
    procedure SetSelectedIndex(const Value: Integer);
    function GetTabIndex: Integer;
    procedure SetTabIndex(const Value: Integer);
    function GetVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
    function GetEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
    function GetTabs(Index: Integer): string;
  public
    constructor Create;

    procedure BeginUpdate;
    {* ��ʼ���£���ֹˢ��ҳ�� }
    procedure EndUpdate;
    {* ֹͣ���£��ָ�ˢ��ҳ�� }
    function SelectComponent(const AComponent: string; const ATab: string): Boolean;
    {* ��������ѡ�пؼ����е�ĳ�ؼ��������Ƿ�ɹ� }
    function FindTab(const ATab: string): Integer;
    {* ����ĳҳ������� }
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    {* ���µĿؼ��ڱ�ҳ����ţ�0 ��ͷ��֧�ָ߰汾���¿ؼ��� }
    property SelectedToolName: string read GetSelectedToolName;
    {* ���µĿؼ���������δ������Ϊ�գ�֧�ָ߰汾���¿ؼ��� }
    property Selector: TSpeedButton read GetSelector;
    {* ��������л��������� SpeedButton���Ͱ汾��������ڣ��߰汾�� Tab ͷ�� }
    property PalToolCount: Integer read GetPalToolCount;
    {* ��ǰҳ�ؼ����� }
    property ActiveTab: string read GetActiveTab;
    {* ��ǰҳ���⣬֧�ָ߰汾���¿ؼ��� }
    property TabIndex: Integer read GetTabIndex write SetTabIndex;
    {* ��ǰҳ������֧�ָ߰汾���¿ؼ��� }
    property Tabs[Index: Integer]: string read GetTabs;
    {* ���������õ�ҳ���ƣ�֧�ָ߰汾���¿ؼ��� }
    property TabCount: Integer read GetTabCount;
    {* �ؼ�����ҳ����֧�ָ߰汾���¿ؼ��� }
    property IsMultiLine: Boolean read GetIsMultiLine;
    {* �ؼ����Ƿ���У�֧�ָ߰汾���¿ؼ��嵫�߰汾�¿ؼ��岻֧�ֶ��� }
    property Visible: Boolean read GetVisible write SetVisible;
    {* �ؼ����Ƿ�ɼ���֧�ָ߰汾���¿ؼ��� }
    property Enabled: Boolean read GetEnabled write SetEnabled;
    {* �ؼ����Ƿ�ʹ�ܣ�֧�ָ߰汾���¿ؼ��� }
  end;

{TCnMessageViewWrapper}

  TCnMessageViewWrapper = class(TObject)
  {* ��װ����Ϣ��ʾ���ڵĸ������Ե��� }
  private
    FMessageViewForm: TCustomForm;
    FTreeView: TXTreeView;
    FTabSet: TTabSet;
    FEditMenuItem: TMenuItem;
{$IFNDEF BDS}
    function GetMessageCount: Integer;
    function GetSelectedIndex: Integer;
    procedure SetSelectedIndex(const Value: Integer);
    function GetCurrentMessage: string;
{$ENDIF}
    function GetTabCaption: string;
    function GetTabCount: Integer;
    function GetTabIndex: Integer;
    procedure SetTabIndex(const Value: Integer);
    function GetTabSetVisible: Boolean;
  public
    constructor Create;

    procedure UpdateAllItems;

    procedure EditMessageSource;
    {* ˫����Ϣ����}

    property MessageViewForm: TCustomForm read FMessageViewForm;
    {* ��Ϣ����}
    property TreeView: TXTreeView read FTreeView;
    {* ��Ϣ�����ʵ����BDS �·� TreeView�����ֻ�ܷ��� CustomControl }
{$IFNDEF BDS}
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    {* ��Ϣ��ѡ�е����}
    property MessageCount: Integer read GetMessageCount;
    {* ���е���Ϣ��}
    property CurrentMessage: string read GetCurrentMessage;
    {* ��ǰѡ�е���Ϣ�����ƺ����Ƿ��ؿ�}
{$ENDIF}
    property TabSet: TTabSet read FTabSet;
    {* ���ط�ҳ�����ʵ��}
    property TabSetVisible: Boolean read GetTabSetVisible;
    {* ���ط�ҳ����Ƿ�ɼ���D5 ��Ĭ�ϲ��ɼ�}
    property TabIndex: Integer read GetTabIndex write SetTabIndex;
    {* ����/���õ�ǰҳ���}
    property TabCount: Integer read GetTabCount;
    {* ������ҳ��}
    property TabCaption: string read GetTabCaption;
    {* ���ص�ǰҳ���ַ���}
    property EditMenuItem: TMenuItem read FEditMenuItem;
    {* '�༭'�˵���}
  end;

function CnPaletteWrapper: TCnPaletteWrapper;

function CnMessageViewWrapper: TCnMessageViewWrapper;

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  Registry;

{$IFDEF BDS4_UP}
const
  SBeginBatchOpenCloseName = '@Editorform@BeginBatchOpenClose$qqrv';
  SEndBatchOpenCloseName = '@Editorform@EndBatchOpenClose$qqrv';

var
  BeginBatchOpenCloseProc: TProcedure = nil;
  EndBatchOpenCloseProc: TProcedure = nil;
{$ENDIF}

type
  TCustomControlHack = class(TCustomControl);

//==============================================================================
// IDE���ܺ���
//==============================================================================

type
  TGetCodeMode = (smLine, smSelText, smSource);

function DoGetEditorSrcInfo(Mode: TGetCodeMode; View: IOTAEditView;
  var StartPos, EndPos, NewRow, NewCol, BlockStartLine, BlockEndLine: Integer): Boolean;
var
  Block: IOTAEditBlock;
  Row, Col: Integer;
  Stream: TMemoryStream;
begin
  Result := False;
  if View <> nil then
  begin
    Block := View.Block;
    StartPos := 0;
    EndPos := 0;
    BlockStartLine := 0;
    BlockEndLine := 0;
    NewRow := 0;
    NewCol := 0;
    if Mode = smLine then
    begin
      if (Block <> nil) and Block.IsValid then
      begin             // ѡ���ı���������
        BlockStartLine := Block.StartingRow;
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockStartLine), View);
        BlockEndLine := Block.EndingRow;
        // ��겻������ʱ��������һ������
        if Block.EndingColumn > 1 then
        begin
          if BlockEndLine < View.Buffer.GetLinesInBuffer then
          begin
            Inc(BlockEndLine);
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockEndLine), View);
          end
          else
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(255, BlockEndLine), View);
        end
        else
          EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockEndLine), View);
      end
      else
      begin    // δѡ���ʾת�����С�
        if CnOtaGetCurSourcePos(Col, Row) then
        begin
          StartPos := CnOtaEditPosToLinePos(OTAEditPos(1, Row), View);
          if Row < View.Buffer.GetLinesInBuffer then
          begin
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, Row + 1), View);
            NewRow := Row + 1;
            NewCol := Col;
          end
          else
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(255, Row), View);
        end
        else
        begin
          Exit;
        end;
      end;
    end
    else if Mode = smSelText then
    begin
      if (Block <> nil) and (Block.IsValid) then
      begin                           // ������ѡ����ı�
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(Block.StartingColumn,
          Block.StartingRow), View);
        EndPos := CnOtaEditPosToLinePos(OTAEditPos(Block.EndingColumn,
          Block.EndingRow), View);
      end;
    end
    else
    begin
      StartPos := 0;
      Stream := TMemoryStream.Create;
      try
        CnOtaSaveCurrentEditorToStream(Stream, False);
        EndPos := Stream.Size; // �ñ��취�õ��༭�ĳ���
      finally
        Stream.Free;
      end;
    end;
    
    Result := True;
  end;
end;

function DoGetEditorLines(Mode: TGetCodeMode; Lines: TStringList): Boolean;
const
  SCnOtaBatchSize = $7FFF;
var
  View: IOTAEditView;
  Text: AnsiString;
  Res: string;
  Buf: PAnsiChar;
  BlockStartLine, BlockEndLine: Integer;
  StartPos, EndPos, Len, ReadStart, ASize: Integer;
  Reader: IOTAEditReader;
  NewRow, NewCol: Integer;
begin
  Result := False;
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    if not DoGetEditorSrcInfo(Mode, View, StartPos, EndPos, NewRow, NewCol,
      BlockStartLine, BlockEndLine) then
      Exit;
      
    Len := EndPos - StartPos;
    Assert(Len >= 0);
    SetLength(Text, Len);
    Buf := Pointer(Text);
    ReadStart := StartPos;

    Reader := View.Buffer.CreateReader;
    try
      while Len > SCnOtaBatchSize do // ��ζ�ȡ
      begin
        ASize := Reader.GetText(ReadStart, Buf, SCnOtaBatchSize);
        Inc(Buf, ASize);
        Inc(ReadStart, ASize);
        Dec(Len, ASize);
      end;
      if Len > 0 then // �����ʣ���
        Reader.GetText(ReadStart, Buf, Len);
    finally
      Reader := nil;
    end;                  

    {$IFDEF UNICODE}
    Res := ConvertEditorTextToTextW(Text); // Unicode �²����� Ansi ת���Ա��ⶪ�ַ�
    {$ELSE}
    Res := ConvertEditorTextToText(Text);
    {$ENDIF}

    Lines.Text := Res;
    Result := Text <> '';
  end;
end;

function DoSetEditorLines(Mode: TGetCodeMode; Lines: TStringList): Boolean;
const
  SCnOtaBatchSize = $7FFF;
var
  View: IOTAEditView;
  Text: AnsiString;
  BlockStartLine, BlockEndLine: Integer;
  StartPos, EndPos: Integer;
  Writer: IOTAEditWriter;
  NewRow, NewCol: Integer;
begin
  Result := False;
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    if not DoGetEditorSrcInfo(Mode, View, StartPos, EndPos, NewRow, NewCol,
      BlockStartLine, BlockEndLine) then
      Exit;

  {$IFDEF UNICODE_STRING}
    Text := AnsiString(StringReplace(Lines.Text, #0, ' ', [rfReplaceAll]));
  {$ELSE}
    Text := StringReplace(Lines.Text, #0, ' ', [rfReplaceAll]);
  {$ENDIF}
    Writer := View.Buffer.CreateUndoableWriter;
    try
      Writer.CopyTo(StartPos);
      Writer.Insert(PAnsiChar(ConvertTextToEditorText(Text)));
      Writer.DeleteTo(EndPos);
    finally
      Writer := nil;
    end;                

    if (NewRow > 0) and (NewCol > 0) then
    begin
      View.CursorPos := OTAEditPos(NewCol, NewRow);
    end
    else if (BlockStartLine > 0) and (BlockEndLine > 0) then
    begin
      CnOtaSelectBlock(View.Buffer, OTACharPos(0, BlockStartLine),
        OTACharPos(0, BlockEndLine));
    end;

    Result := True;
  end;
end;

function IdeGetEditorSelectedLines(Lines: TStringList): Boolean;
begin
  Result := DoGetEditorLines(smLine, Lines);
end;

function IdeGetEditorSelectedText(Lines: TStringList): Boolean;
begin
  Result := DoGetEditorLines(smSelText, Lines);
end;

function IdeGetEditorSourceLines(Lines: TStringList): Boolean;
begin
  Result := DoGetEditorLines(smSource, Lines);
end;

function IdeSetEditorSelectedLines(Lines: TStringList): Boolean;
begin
  Result := DoSetEditorLines(smLine, Lines);
end;

function IdeSetEditorSelectedText(Lines: TStringList): Boolean;
begin
  Result := DoSetEditorLines(smSelText, Lines);
end;

function IdeSetEditorSourceLines(Lines: TStringList): Boolean;
begin
  Result := DoSetEditorLines(smSource, Lines);
end;

function IdeInsertTextIntoEditor(const Text: string): Boolean;
begin
  if CnOtaGetTopMostEditView <> nil then
  begin
    CnOtaInsertTextIntoEditor(Text);
    Result := True;
  end
  else
    Result := False;  
end;
  
function IdeEditorGetEditPos(var Col, Line: Integer): Boolean;
var
  EditPos: TOTAEditPos;
begin
  if CnOtaGetTopMostEditView <> nil then
  begin
    EditPos := CnOtaGetEditPos(CnOtaGetTopMostEditView);
    Col := EditPos.Col;
    Line := EditPos.Line;
    Result := True;
  end
  else
    Result := False;
end;

function IdeEditorGotoEditPos(Col, Line: Integer; Middle: Boolean): Boolean;
begin
  if CnOtaGetTopMostEditView <> nil then
  begin
    CnOtaGotoEditPos(OTAEditPos(Col, Line), CnOtaGetTopMostEditView, Middle);
    Result := True;
  end
  else
    Result := False;
end;

function IdeGetBlockIndent: Integer;
begin
  Result := CnOtaGetBlockIndent;
end;  

function IdeGetSourceByFileName(const FileName: string): AnsiString;
var
  Strm: TMemoryStream;
begin
  Strm := TMemoryStream.Create;
  try
    EditFilerSaveFileToStream(FileName, Strm, True);
    Result := PAnsiChar(Strm.Memory);
  finally
    Strm.Free;
  end;
end;

function IdeSetSourceByFileName(const FileName: string; Source: TStrings;
  OpenInIde: Boolean): Boolean;
var
  Strm: TMemoryStream;
begin
  Result := False;
  if OpenInIde and not CnOtaOpenFile(FileName) then
    Exit;
    
  if CnOtaIsFileOpen(FileName) then
  begin
    Strm := TMemoryStream.Create;
    try
      Source.SaveToStream(Strm);
      Strm.Position := 0;
      with TCnEditFiler.Create(FileName) do
      try
        ReadFromStream(Strm);
      finally
        Free;
      end;
    finally
      Strm.Free;
    end;
  end
  else
    Source.SaveToFile(FileName);
  Result := True;
end;  

// �жϱ�ʶ���Ƿ��ڹ���£����汾����ʹ��
function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
var
{$IFDEF BDS}
  Text: AnsiString;
{$ENDIF}
  LineNo, Col: Integer;
  View: IOTAEditView;
begin
  if not Assigned(AView) then
  begin
    Result := False;
    Exit;
  end;
  View := IOTAEditView(AView);
  LineNo := View.CursorPos.Line;
  Col := View.CursorPos.Col;

  if Token.EditLine <> LineNo then // �кŲ���ʱֱ���˳�
  begin
    Result := False;
    Exit;
  end;

  // ����Ȳ���Ҫ���������ݽ��бȽϣ����� Col ��ֱ�۵� Ansi ���˫�ֽ��ַ�ռ 2 ��
{$IFDEF BDS}
  Text := AnsiString(GetStrProp(AControl, 'LineText')); // D2009 ���� Unicode Ҳ��ת���� Ansi
  if Text <> '' then
  begin
    // TODO: �� TextWidth ��ù��λ�þ�ȷ��Ӧ��Դ���ַ�λ�ã���ʵ�ֽ��ѡ�
    // ������ռ�ݵ��ַ�λ�õ�˫�ֽ��ַ�ʱ�������㷨����ƫ�

    {$IFNDEF UNICODE}
    // D2005~2007 ��õ��� Utf8 �ַ�������Ҫת��Ϊ Ansi ���ܽ���ֱ���бȽ�
    Col := Length(CnUtf8ToAnsi(Copy(Text, 1, Col)));
    {$ENDIF}
  end;
{$ENDIF}
  Result := (Col >= Token.EditCol) and (Col <= Token.EditCol + Length(Token.Token));
end;

{* �жϱ�ʶ���Ƿ��ڹ���£�ʹ�� WideToken���ɹ� Unicode/Utf8 �����µ���}
function IsCurrentTokenW(AView: Pointer; AControl: TControl; Token: TCnWidePasToken): Boolean;
var
  LineNo, Col: Integer;
  View: IOTAEditView;
begin
  if not Assigned(AView) then
  begin
    Result := False;
    Exit;
  end;
  View := IOTAEditView(AView);
  LineNo := View.CursorPos.Line;
  Col := View.CursorPos.Col;

  if Token.EditLine <> LineNo then // �кŲ���ʱֱ���˳�
  begin
    Result := False;
    Exit;
  end;

  // ����Ȳ���Ҫ�Ƚ��У��������� CursorPos �� ANSI �Ĺ��λ�ã����Եð� Utf16 ת�� Ansi ���Ƚ�
  Result := (Col >= Token.EditCol) and (Col <= Token.EditCol + Length(AnsiString(Token.Token)));
end;

//==============================================================================
// IDE ����༭�����ܺ���
//==============================================================================

// ȡ�ô���༭�����������FormEditor Ϊ nil ��ʾȡ��ǰ����
function IdeGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
begin
  Result := CnOtaGetFormDesigner(FormEditor);
end;  

// ȡ�õ�ǰ��ƵĴ���
function IdeGetDesignedForm(Designer: IDesigner = nil): TCustomForm;
begin
  Result := nil;
  try
    if Designer = nil then
      Designer := IdeGetFormDesigner;
    if Designer = nil then Exit;
    
  {$IFDEF COMPILER6_UP}
    if Designer.Root is TCustomForm then
      Result := TCustomForm(Designer.Root);
  {$ELSE}
    Result := Designer.Form;
  {$ENDIF}
  except
    ;
  end;
end;

// ȡ�õ�ǰ��ƴ�������ѡ������
function IdeGetFormSelection(Selections: TList; Designer: IDesigner = nil;
  ExcludeForm: Boolean = True): Boolean;
var
  i: Integer;
  AObj: TPersistent;
  AList: IDesignerSelections;
begin
  Result := False;
  try
    if Designer = nil then
      Designer := IdeGetFormDesigner;
    if Designer = nil then Exit;

    if Selections <> nil then
    begin
      Selections.Clear;
      AList := CreateSelectionList;
      Designer.GetSelections(AList);
      for i := 0 to AList.Count - 1 do
      begin
      {$IFDEF COMPILER6_UP}
        AObj := TPersistent(AList[i]);
      {$ELSE}
        AObj := TryExtractPersistent(AList[i]);
      {$ENDIF}
        if AObj <> nil then // perhaps is nil when disabling packages in the IDE
          Selections.Add(AObj);
      end;

      if ExcludeForm and (Selections.Count = 1) and (Selections[0] =
        IdeGetDesignedForm(Designer)) then
        Selections.Clear;
    end;
    Result := True;
  except
    ;
  end;
end;

// ȡ�õ�ǰ�Ƿ���Ƕ��ʽ��ƴ���ģʽ
function IdeGetIsEmbeddedDesigner: Boolean;
{$IFDEF BDS}
var
  S: string;
{$ENDIF}
begin
{$IFDEF BDS}
  S := CnOtaGetEnvironmentOptions.Values['EmbeddedDesigner'];
  Result := S = 'True';
{$ELSE}
  Result := False;
{$ENDIF}
end;

//==============================================================================
// �޸��� GExperts Src 1.12 �� IDE ��غ���
//==============================================================================

// ���� IDE ������ (TAppBuilder)
function GetIdeMainForm: TCustomForm;
begin
  Assert(Assigned(Application));
  Result := Application.FindComponent('AppBuilder') as TCustomForm;
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsg('Unable to find AppBuilder!');
{$ENDIF}
end;

// ȡ IDE �汾
function GetIdeEdition: string;
begin
  Result := '';

  with TRegistry.Create do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKeyReadOnly(WizOptions.CompilerRegPath) then
    begin
      Result := ReadString('Version');
      CloseKey;
    end;
  finally
    Free;
  end;
end;

// ������������󣬿���Ϊ��
function GetComponentPaletteTabControl: TTabControl;
var
  MainForm: TCustomForm;
begin
  Result := nil;

  MainForm := GetIdeMainForm;
  if MainForm <> nil then
    Result := MainForm.FindComponent('TabControl') as TTabControl;

{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsg('Unable to Find ComponentPalette TabControl!');
{$ENDIF}
end;

// ���� 2010 �����ϵ���������󣬿���Ϊ��
function GetNewComponentPaletteTabControl: TWinControl;
var
  MainForm: TCustomForm;
begin
  Result := nil;

  MainForm := GetIdeMainForm;
  if MainForm <> nil then
    Result := MainForm.FindComponent(SCnNewPaletteFrameName) as TWinControl;
  if Result <> nil then
    Result := Result.FindComponent(SCnNewPaletteTabName) as TWinControl;

{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsg('Unable to Find New ComponentPalette TabControl!');
{$ENDIF}
end;

// ���ض����������壬����Ϊ��
function GetObjectInspectorForm: TCustomForm;
begin
  Result := GetIdeMainForm;
  if Result <> nil then
    Result := TCustomForm(Result.FindComponent('PropertyInspector'));
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsg('Unable to find object inspector!');
{$ENDIF}
end;

// �����������Ҽ��˵�������Ϊ��
function GetComponentPalettePopupMenu: TPopupMenu;
var
  MainForm: TCustomForm;
begin
  Result := nil;
  MainForm := GetIdeMainForm;
  if MainForm <> nil then
    Result := TPopupMenu(MainForm.FindComponent('PaletteMenu'));
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsg('Unable to find PaletteMenu!');
{$ENDIF}
end;

// �������������ڵ�ControlBar������Ϊ��
function GetComponentPaletteControlBar: TControlBar;
var
  MainForm: TCustomForm;
  i: Integer;
begin
  Result := nil;

  MainForm := GetIdeMainForm;
  if MainForm <> nil then
    for i := 0 to MainForm.ComponentCount - 1 do
      if MainForm.Components[i] is TControlBar then
      begin
        Result := MainForm.Components[i] as TControlBar;
        Break;
      end;
      
{$IFDEF DEBUG}
  if Result = nil then
    CnDebugger.LogMsg('Unable to find ControlBar!');
{$ENDIF}
end;

// �������˵���߶�
function GetMainMenuItemHeight: Integer;
{$IFDEF COMPILER7_UP}
var
  MainForm: TCustomForm;
  Component: TComponent;
{$ENDIF}
begin
{$IFDEF COMPILER7_UP}
  Result := 23;
  MainForm := GetIdeMainForm;
  Component := nil;
  if MainForm <> nil then
    Component := MainForm.FindComponent('MenuBar');
  if (Component is TControl) then
    Result := TControl(Component).ClientHeight; // This is approximate?
{$ELSE}
  Result := GetSystemMetrics(SM_CYMENU);
{$ENDIF}
end;

// �ж�ָ�������Ƿ�������ڴ���
function IsIdeDesignForm(AForm: TCustomForm): Boolean;
begin
  Result := (AForm <> nil) and (csDesigning in AForm.ComponentState);
end;

// �ж�ָ�������Ƿ�༭������
function IsIdeEditorForm(AForm: TCustomForm): Boolean;
begin
  Result := (AForm <> nil) and
            (Pos('EditWindow_', AForm.Name) = 1) and
            (AForm.ClassName = EditorFormClassName) and
            (not (csDesigning in AForm.ComponentState));
end;

// ��Դ��༭����Ϊ��Ծ
procedure BringIdeEditorFormToFront;
var
  i: Integer;
begin
  for i := 0 to Screen.CustomFormCount - 1 do
    if IsIdeEditorForm(Screen.CustomForms[i]) then
    begin
      Screen.CustomForms[i].BringToFront;
      Exit;
    end;
end;

// �ж� IDE �Ƿ��ǵ�ǰ�Ļ����
function IDEIsCurrentWindow: Boolean;
begin
  Result := GetCurrentThreadId = GetWindowThreadProcessId(GetForegroundWindow, nil);
end;

//==============================================================================
// ������ IDE ��غ���
//==============================================================================

// ȡ��������װĿ¼
function GetInstallDir: string;
begin
  Result := _CnExtractFileDir(_CnExtractFileDir(Application.ExeName));
end;

{$IFDEF BDS}
// ȡ�� BDS (Delphi8/9) ���û�����Ŀ¼
function GetBDSUserDataDir: string;
const
  CSIDL_LOCAL_APPDATA = $001c;
begin
  Result := MakePath(GetSpecialFolderLocation(CSIDL_LOCAL_APPDATA));
{$IFDEF DELPHI8}
  Result := Result + 'Borland\BDS\2.0';
{$ELSE}
{$IFDEF DELPHI9}
  Result := Result + 'Borland\BDS\3.0';
{$ELSE}
{$IFDEF DELPHI10}
  Result := Result + 'Borland\BDS\4.0';
{$ELSE}
{$IFDEF DELPHI11}
  Result := Result + 'CodeGear\RAD Studio\5.0';
{$ELSE}
{$IFDEF DELPHI12}
  Result := Result + 'CodeGear\RAD Studio\6.0';
{$ELSE}
{$IFDEF DELPHI14}
  Result := Result + 'CodeGear\RAD Studio\7.0';
{$ELSE}
{$IFDEF DELPHI15}
  Result := Result + 'Embarcadero\BDS\8.0';
{$ELSE}
{$IFDEF DELPHI16}
  Result := Result + 'Embarcadero\BDS\9.0';
{$ELSE}
{$IFDEF DELPHI17}
  Result := Result + 'Embarcadero\BDS\10.0';
{$ELSE}
{$IFDEF DELPHIXE4}
  Result := Result + 'Embarcadero\BDS\11.0';
{$ELSE}
{$IFDEF DELPHIXE5}
  Result := Result + 'Embarcadero\BDS\12.0';
{$ELSE}
{$IFDEF DELPHIXE6}
  Result := Result + 'Embarcadero\BDS\14.0';
{$ELSE}
{$IFDEF DELPHIXE7}
  Result := Result + 'Embarcadero\BDS\15.0';
{$ELSE}
{$IFDEF DELPHIXE8}
  Result := Result + 'Embarcadero\BDS\16.0';
{$ELSE}
{$IFDEF DELPHI10_SEATTLE}
  Result := Result + 'Embarcadero\BDS\17.0';
{$ELSE}
  Error: Unknown Compiler
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
end;
{$ENDIF}

function CnOtaGetVersionInfoKeys(Project: IOTAProject = nil): TStrings;
var
  Options: IOTAProjectOptions;
  PKeys: Integer;
begin
  Result := nil;
  Options := CnOtaGetActiveProjectOptions(Project);
  if not Assigned(Options) then Exit;
  PKeys := Options.GetOptionValue('Keys');
{$IFDEF DEBUG}
  CnDebugger.LogInteger(PKeys, 'CnOtaGetVersionInfoKeys');
{$ENDIF}
  Result := Pointer(PKeys);
end;

// ȡ���������е� LibraryPath ���ݣ�ע�� XE2 ���ϰ汾��GetEnvironmentOptions ��ͷ
// �õ���ֵ�����ǵ�ǰ���̵� Platform ��Ӧ��ֵ������ֻ�ܸĳɸ��ݹ���ƽ̨��ע��������
procedure GetLibraryPath(Paths: TStrings; IncludeProjectPath: Boolean);
var
  Svcs: IOTAServices;
  Options: IOTAEnvironmentOptions;
  Text: string;
  List: TStrings;
{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
  CurPlatform: string;
  Project: IOTAProject;
{$ENDIF}

  procedure AddList(AList: TStrings);
  var
    S: string;
    i: Integer;
  begin
    for i := 0 to List.Count - 1 do
    begin
      S := Trim(MakePath(List[i]));
      if (S <> '') and (Paths.IndexOf(S) < 0) then
        Paths.Add(S);
    end;
  end;
begin
  Svcs := BorlandIDEServices as IOTAServices;
  if not Assigned(Svcs) then Exit;
  Options := Svcs.GetEnvironmentOptions;
  if not Assigned(Options) then Exit;

{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
  CurPlatform := '';
  Project := CnOtaGetCurrentProject;
  if Project <> nil then
  begin
    CurPlatform := Project.CurrentPlatform;
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Project.CurrentPlatform  is ' + CurPlatform);
  {$ENDIF}
  end;
{$ENDIF}

  List := TStringList.Create;
  try
{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
    if CurPlatform = '' then
      Text := ReplaceToActualPath(Options.GetOptionValue('LibraryPath'))
    else
      Text := ReplaceToActualPath(RegReadStringDef(HKEY_CURRENT_USER,
        WizOptions.CompilerRegPath + '\Library\' + CurPlatform, 'Search Path', ''));
{$ELSE}
    Text := ReplaceToActualPath(Options.GetOptionValue('LibraryPath'));
{$ENDIF}

  {$IFDEF DEBUG}
    CnDebugger.LogMsg('LibraryPath' + #13#10 + Text);
  {$ENDIF}
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);

{$IFDEF OTA_ENVOPTIONS_PLATFORM_BUG}
    if CurPlatform = '' then
      Text := ReplaceToActualPath(Options.GetOptionValue('BrowsingPath'))
    else
      Text := ReplaceToActualPath(RegReadStringDef(HKEY_CURRENT_USER,
        WizOptions.CompilerRegPath + '\Library\' + CurPlatform, 'Browsing Path', ''));
{$ELSE}
    Text := ReplaceToActualPath(Options.GetOptionValue('BrowsingPath'));
{$ENDIF}

  {$IFDEF DEBUG}
    CnDebugger.LogMsg('BrowsingPath' + #13#10 + Text);
  {$ENDIF}
    List.Text := StringReplace(Text, ';', #13#10, [rfReplaceAll]);
    AddList(List);

    if IncludeProjectPath then
    begin
      GetProjectLibPath(List);
      AddList(List);
    end;
  finally
    List.Free;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogStrings(Paths, 'Paths');
{$ENDIF}
end;

procedure AddProjectPath(Project: IOTAProject; Paths: TStrings; IDStr: string);
var
  APath: string;
  APaths: TStrings;
  i: Integer;
begin
  if not Assigned(Project.ProjectOptions) then
    Exit;

  APath := Project.ProjectOptions.GetOptionValue(IdStr);

{$IFDEF DEBUG}
  CnDebugger.LogFmt('AddProjectPath: %s '#13#10 + APath, [IdStr]);
{$ENDIF}

  if APath <> '' then
  begin
    APath := ReplaceToActualPath(APath, Project);
      
    // ����·���е����·��
    APaths := TStringList.Create;
    try
      APaths.Text := StringReplace(APath, ';', #13#10, [rfReplaceAll]);
      for i := 0 to APaths.Count - 1 do
      begin
        if Trim(APaths[i]) <> '' then   // ��ЧĿ¼
        begin
          APath := MakePath(Trim(APaths[i]));
          if (Length(APath) > 2) and (APath[2] = ':') then // ȫ·��Ŀ¼
          begin
            if Paths.IndexOf(APath) < 0 then
              Paths.Add(APath);
          end
          else                          // ���·��
          begin
            APath := LinkPath(_CnExtractFilePath(Project.FileName), APath);
            if Paths.IndexOf(APath) < 0 then
              Paths.Add(APath);
          end;
        end;          
      end;
    finally
      APaths.Free;
    end;                
  end;
end;

// ȡ��ǰ���������� Path ����
procedure GetProjectLibPath(Paths: TStrings);
var
  ProjectGroup: IOTAProjectGroup;
  Project: IOTAProject;
  Path: string;
  i, j: Integer;
  APaths: TStrings;
begin
  Paths.Clear;

{$IFDEF DEBUG}
  CnDebugger.LogEnter('GetProjectLibPath');
{$ENDIF}

  // ����ǰ�������е�·������
  ProjectGroup := CnOtaGetProjectGroup;
  if Assigned(ProjectGroup) then
  begin
    APaths := TStringList.Create;
    try
      for i := 0 to ProjectGroup.GetProjectCount - 1 do
      begin
        Project := ProjectGroup.Projects[i];
        if Assigned(Project) then
        begin
          // ���ӹ�������·��
          AddProjectPath(Project, Paths, 'SrcDir');
          AddProjectPath(Project, Paths, 'UnitDir');
          AddProjectPath(Project, Paths, 'LibPath');
          AddProjectPath(Project, Paths, 'IncludePath');

          // ���ӹ������ļ���·��
          for j := 0 to Project.GetModuleCount - 1 do
          begin
            Path := _CnExtractFileDir(Project.GetModule(j).FileName);
            if Paths.IndexOf(Path) < 0 then
              Paths.Add(Path);
          end;
        end;
      end;
    finally
      APaths.Free;
    end;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogStrings(Paths, 'Paths');
  CnDebugger.LogLeave('GetProjectLibPath');
{$ENDIF}
end;

// ����ģ������������ļ���
function GetFileNameFromModuleName(AName: string; AProject: IOTAProject = nil): string;
var
  Paths: TStringList;
  i: Integer;
  Ext, ProjectPath: string;
begin
  if AProject = nil then
    AProject := CnOtaGetCurrentProject;

  Ext := LowerCase(_CnExtractFileExt(AName));
  if (Ext = '') or (Ext <> '.pas') then
    AName := AName + '.pas';

  Result := '';
  // �ڹ���ģ���в���
  if AProject <> nil then
  begin
    for i := 0 to AProject.GetModuleCount - 1 do
      if SameFileName(_CnExtractFileName(AProject.GetModule(i).FileName), AName) then
      begin
        Result := AProject.GetModule(i).FileName;
        Exit;
      end;

    ProjectPath := MakePath(_CnExtractFilePath(AProject.FileName));
    if FileExists(ProjectPath + AName) then
    begin
      Result := ProjectPath + AName;
      Exit;
    end;
  end;

  Paths := TStringList.Create;
  try
    if Assigned(AProject) then
    begin
      // �ڹ�������·�������
      AddProjectPath(AProject, Paths, 'SrcDir');
    end;

    // ��ϵͳ����·�������
    GetLibraryPath(Paths, False);
    for i := 0 to Paths.Count - 1 do
      if FileExists(MakePath(Paths[i]) + AName) then
      begin
        Result := MakePath(Paths[i]) + AName;
        Exit;
      end;
  finally
    Paths.Free;
  end;
end;

// ȡ����������ڵĵ�Ԫ��
function GetComponentUnitName(const ComponentName: string): string;
var
  ClassRef: TClass;
  TypeData: PTypeData;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('GetComponentUnitName: ' + ComponentName);
{$ENDIF}

  Result := '';
  ClassRef := GetClass(ComponentName);

  if Assigned(ClassRef) then
  begin
    TypeData := GetTypeData(PTypeInfo(ClassRef.ClassInfo));
    Result := string(TypeData^.UnitName);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('UnitName: ' + Result);
  {$ENDIF}
  end;
end;

// ȡ�Ѱ�װ�İ������
procedure GetInstalledComponents(Packages, Components: TStrings);
var
  PackSvcs: IOTAPackageServices;
  i, j: Integer;
begin
  QuerySvcs(BorlandIDEServices, IOTAPackageServices, PackSvcs);
  if Assigned(Packages) then
    Packages.Clear;
  if Assigned(Components) then
    Components.Clear;
    
  for i := 0 to PackSvcs.PackageCount - 1 do
  begin
    if Assigned(Packages) then
      Packages.Add(PackSvcs.PackageNames[i]);
    if Assigned(Components) then
      for j := 0 to PackSvcs.ComponentCount[i] - 1 do
        Components.Add(PackSvcs.ComponentNames[i, j]);
  end;
end;

function GetIDERegistryFont(const RegItem: string; AFont: TFont): Boolean;
const
  SCnIDERegName = {$IFDEF BDS} 'BDS' {$ELSE} {$IFDEF DELPHI} 'Delphi' {$ELSE} 'C++Builder' {$ENDIF}{$ENDIF};

  SCnIDEFontName = 'Editor Font';
  SCnIDEFontSize = 'Font Size';

  SCnIDEBold = 'Bold';
  {$IFDEF COMPILER7_UP}
  SCnIDEForeColor = 'Foreground Color New';
  {$ELSE}
  SCnIDEForeColor = 'Foreground Color';
  {$ENDIF}
  SCnIDEItalic = 'Italic';
  SCnIDEUnderline = 'Underline';
var
  S: string;
  Reg: TRegistry;
  Size: Integer;
{$IFDEF COMPILER7_UP}
  AColorStr: string;
{$ENDIF}
  AColor: Integer;

  function ReadBoolReg(Reg: TRegistry; const RegName: string): Boolean;
  var
    S: string;
  begin
    Result := False;
    if Reg <> nil then
    begin
      try
        S := Reg.ReadString(RegName);
        if (UpperCase(S) = 'TRUE') or (S = '1') then
          Result := True;
      except
        ;
      end;
    end;
  end;
begin
  // ��ĳ��ע���������ĳ�����岢��ֵ�� AFont
  Result := False; 

  if AFont <> nil then
  begin
    Reg := nil;
    try
      Reg := TRegistry.Create;
      Reg.RootKey := HKEY_CURRENT_USER;
      try
        if RegItem = '' then // �ǻ�������
        begin
          if Reg.OpenKeyReadOnly(WizOptions.CompilerRegPath + '\Editor\Options') then
          begin
            if Reg.ValueExists(SCnIDEFontName) then
            begin
              S := Reg.ReadString(SCnIDEFontName);
              if S <> '' then AFont.Name := S;
            end;
            if Reg.ValueExists(SCnIDEFontSize) then
            begin
              Size := Reg.ReadInteger(SCnIDEFontSize);
              if Size > 0 then AFont.Size := Size;
            end;
            Reg.CloseKey;
          end;
          Result := True; // ����������Ĭ������
        end
        else  // �Ǹ�������
        begin
          AFont.Style := [];
          if Reg.OpenKeyReadOnly(Format(WizOptions.CompilerRegPath
            + '\Editor\Highlight\%s', [RegItem])) then
          begin
            if Reg.ValueExists(SCnIDEBold) and ReadBoolReg(Reg, SCnIDEBold) then
            begin
              Result := True;
              AFont.Style := AFont.Style + [fsBold];
            end;
            if Reg.ValueExists(SCnIDEItalic) and ReadBoolReg(Reg, SCnIDEItalic) then
            begin
              Result := True;
              AFont.Style := AFont.Style + [fsItalic];
            end;
            if Reg.ValueExists(SCnIDEUnderline) and ReadBoolReg(Reg, SCnIDEUnderline) then
            begin
              Result := True;
              AFont.Style := AFont.Style + [fsUnderline];
            end;
            if Reg.ValueExists(SCnIDEForeColor) then
            begin
              Result := True;
  {$IFDEF COMPILER7_UP}
              AColorStr := Reg.ReadString(SCnIDEForeColor);
              if IdentToColor(AColorStr, AColor) then
                AFont.Color := AColor
              else
                AFont.Color := StrToIntDef(AColorStr, 0);
  {$ELSE}
              // D5/6 ����ɫ�� 16 ɫ������
              AColor := Reg.ReadInteger(SCnIDEForeColor);
              if AColor in [0..15] then
                AFont.Color := SCnColor16Table[AColor];
  {$ENDIF}
            end;
          end;
        end;
      except
        Result := False;
      end;
    finally
      Reg.Free;
    end;
  end;
end;

// �ж�ָ���ؼ��Ƿ����༭���ؼ�
function IsEditControl(AControl: TComponent): Boolean;
begin
  Result := (AControl <> nil) and AControl.ClassNameIs(EditControlClassName)
    and SameText(AControl.Name, EditControlName);
end;

// �ж�ָ���ؼ��Ƿ�༭�����ڵ� TabControl �ؼ�
function IsXTabControl(AControl: TComponent): Boolean;
begin
  Result := (AControl <> nil) and AControl.ClassNameIs(XTabControlClassName)
    and SameText(AControl.Name, XTabControlName);
end;

// ���ر༭�����ڵı༭���ؼ�
function GetEditControlFromEditorForm(AForm: TCustomForm): TControl;
begin
  Result := TControl(FindComponentByClassName(AForm, EditControlClassName,
    EditControlName));
end;

// �ӱ༭���ؼ�����������ı༭�����ڵ�״̬��
function GetStatusBarFromEditor(EditControl: TControl): TStatusBar;
var
  AComp: TComponent;
begin
  Result := nil;
  if EditControl <> nil then
  begin
    AComp := FindComponentByClass(TWinControl(EditControl.Owner), TStatusBar, 'StatusBar');
    if AComp is TStatusBar then
      Result := AComp as TStatusBar;
  end;
end;

// ���ص�ǰ�Ĵ���༭���ؼ�
function GetCurrentEditControl: TControl;
var
  View: IOTAEditView;
begin
  Result := nil;
  View := CnOtaGetTopMostEditView;
  if (View <> nil) and (View.GetEditWindow <> nil) then
    Result := GetEditControlFromEditorForm(View.GetEditWindow.Form);
end;

// ���ر༭�����ڵ� TabControl �ؼ�
function GetTabControlFromEditorForm(AForm: TCustomForm): TXTabControl;
begin
  Result := TXTabControl(FindComponentByClassName(AForm, XTabControlClassName,
    XTabControlName));
end;

// ö�� IDE �еĴ���༭�����ں� EditControl �ؼ������ûص���������������
function EnumEditControl(Proc: TEnumEditControlProc; Context: Pointer;
  EditorMustExists: Boolean): Integer;
var
  i: Integer;
  EditWindow: TCustomForm;
  EditControl: TControl;
begin
  Result := 0;
  for i := 0 to Screen.CustomFormCount - 1 do
    if IsIdeEditorForm(Screen.CustomForms[i]) then
    begin
      EditWindow := Screen.CustomForms[i];
      EditControl := GetEditControlFromEditorForm(EditWindow);
      if Assigned(EditControl) or not EditorMustExists then
      begin
        Inc(Result);
        if Assigned(Proc) then
          Proc(EditWindow, EditControl, Context);
      end;
    end;
end;

// ȡ��ǰ�༭���ڶ���ҳ�����ͣ�����༭�����ؼ�
function GetCurrentTopEditorPage(AControl: TWinControl): TCnSrcEditorPage;
var
  I: Integer;
  Ctrl: TControl;
begin
  // ��ͷ������һ�� Align �� Client �Ķ������Ǳ༭������ʾ
  Result := epOthers;
  for I := AControl.ControlCount - 1 downto 0 do
  begin
    Ctrl := AControl.Controls[I];
    if Ctrl.Visible and (Ctrl.Align = alClient) then
    begin
      if Ctrl.ClassNameIs(EditControlClassName) then
        Result := epCode
      else if Ctrl.ClassNameIs(DisassemblyViewClassName) then
        Result := epCPU
      else if Ctrl.ClassNameIs(DesignControlClassName) then
        Result := epDesign
      else if Ctrl.ClassNameIs(WelcomePageClassName) then
        Result := epWelcome;
      Break;
    end;
  end;
end;

var
  CorIdeModule: HMODULE;

procedure InitIdeAPIs;
begin
  CorIdeModule := LoadLibrary(CorIdeLibName);
  Assert(CorIdeModule <> 0, 'Failed to load CorIdeModule');

{$IFDEF BDS4_UP}
  BeginBatchOpenCloseProc := GetProcAddress(CorIdeModule, SBeginBatchOpenCloseName);
  Assert(Assigned(BeginBatchOpenCloseProc), 'Failed to load BeginBatchOpenCloseProc from CorIdeModule');

  EndBatchOpenCloseProc := GetProcAddress(CorIdeModule, SEndBatchOpenCloseName);
  Assert(Assigned(EndBatchOpenCloseProc), 'Failed to load EndBatchOpenCloseProc from CorIdeModule');
{$ENDIF}
end;

procedure FinalIdeAPIs;
begin
  if CorIdeModule <> 0 then
    FreeLibrary(CorIdeModule);
end;  

// ��ʼ�����򿪻�ر��ļ�
procedure BeginBatchOpenClose;
begin
{$IFDEF BDS4_UP}
  if Assigned(BeginBatchOpenCloseProc) then
    BeginBatchOpenCloseProc;
{$ENDIF}
end;

// ���������򿪻�ر��ļ�
procedure EndBatchOpenClose;
begin
{$IFDEF BDS4_UP}
  if Assigned(EndBatchOpenCloseProc) then
    EndBatchOpenCloseProc;
{$ENDIF}
end;

// �� IDE �ڲ�ʹ�õ� TTreeControl�� Items ����ֵ�� TreeNode ǿ��ת���ɹ��õ� TreeNode
function ConvertIDETreeNodeToTreeNode(Node: TObject): TTreeNode;
begin
{$IFDEF DEBUG}
  if not (Node is TTreeNode) then
    CnDebugger.LogFmt('Node ClassName %s. Value %8.8x. NOT our TreeNode. Manual Cast it.',
      [Node.ClassName, Integer(Node)]);
{$ENDIF}
  Result := TTreeNode(Node);
end;

// �� IDE �ڲ�ʹ�õ� TTreeControl�� Items ����ֵ�� TreeNodes ǿ��ת���ɹ��õ� TreeNodes
function ConvertIDETreeNodesToTreeNodes(Nodes: TObject): TTreeNodes;
begin
{$IFDEF DEBUG}
  if not (Nodes is TTreeNodes) then
    CnDebugger.LogFmt('Nodes ClassName %s. Value %8.8x. NOT our TreeNodes. Manual Cast it.',
      [Nodes.ClassName, Integer(Nodes)]);
{$ENDIF}
  Result := TTreeNodes(Nodes);
end;

//==============================================================================
// ��չ�ؼ�
//==============================================================================

{ TCnToolBarComboBox }

procedure TCnToolBarComboBox.CNKeyDown(var Message: TWMKeyDown);
var
  AShortCut: TShortCut;
  ShiftState: TShiftState;
begin
  ShiftState := KeyDataToShiftState(Message.KeyData);
  AShortCut := ShortCut(Message.CharCode, ShiftState);
  Message.Result := 1;
  if not HandleEditShortCut(Self, AShortCut) then
    inherited;
end;

//==============================================================================
// �������װ��
//==============================================================================

{ TCnPaletteWrapper }

var
  FCnPaletteWrapper: TCnPaletteWrapper = nil;
  FCnMessageViewWrapper: TCnMessageViewWrapper = nil;

function CnPaletteWrapper: TCnPaletteWrapper;
begin
  if FCnPaletteWrapper = nil then
    FCnPaletteWrapper := TCnPaletteWrapper.Create;
  Result := FCnPaletteWrapper;
end;

procedure TCnPaletteWrapper.BeginUpdate;
begin
  if FUpdateCount = 0 then
  begin
    SendMessage(FPalTab.Handle, WM_SETREDRAW, 0, 0);
    SendMessage(FPalette.Handle, WM_SETREDRAW, 0, 0);
  end;
  Inc(FUpdateCount);
end;

constructor TCnPaletteWrapper.Create;
var
  I, J: Integer;
begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  FPalTab := GetNewComponentPaletteTabControl;
  if FPalTab <> nil then
    FPalette := FPalTab.Owner.FindComponent(SCnNewPalettePanelContainerName) as TWinControl;
{$ELSE}
  FPalTab := GetComponentPaletteTabControl;

  for I := 0 to FPalTab.ControlCount - 1 do
  begin
    if FPalTab.Controls[I].ClassNameIs('TPageScroller') then
    begin
      FPageScroller := FPalTab.Controls[I] as TWinControl;
      for J := 0 to FPageScroller.ControlCount - 1 do
        if FPageScroller.Controls[J].ClassNameIs('TPalette') then
        begin
          FPalette := FPageScroller.Controls[J] as TWinControl;
          Exit;
        end;
    end;
  end;
{$ENDIF}
end;

procedure TCnPaletteWrapper.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
  begin
    SendMessage(FPalTab.Handle, WM_SETREDRAW, 1, 0);
    SendMessage(FPalette.Handle, WM_SETREDRAW, 1, 0);
    FPalTab.Invalidate;
    FPalette.Invalidate;
  end;
end;

function TCnPaletteWrapper.FindTab(const ATab: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to TabCount - 1 do
    if Tabs[I] = ATab then
    begin
      Result := I;
      Exit;
    end;
end;

function TCnPaletteWrapper.GetActiveTab: string;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  TabList: TStrings;
{$ENDIF}
begin
  Result := '';
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    TabList := GetObjectProp(FPalTab, SCnNewPaletteTabItemsPropName) as TStrings;
    if TabList <> nil then
      Result := TabList[GetOrdProp(FPalTab, SCnNewPaletteTabIndexPropName)];
{$ELSE}
    Result := (FPalTab as TTabControl).Tabs.Strings[(FPalTab as TTabControl).TabIndex];
{$ENDIF}
  end;
end;

function TCnPaletteWrapper.GetEnabled: Boolean;
begin
  if FPalTab <> nil then
    Result := FPalTab.Enabled
  else
    Result := False;
end;

function TCnPaletteWrapper.GetIsMultiLine: Boolean;
begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE} // �¿ؼ��岻֧�ֶ���
  Result := False;
{$ELSE}
  Result := (FPalTab as TTabControl).MultiLine;
{$ENDIF}
end;

function TCnPaletteWrapper.GetPalToolCount: Integer;
var
  I: Integer;
begin
  Result := -1;
  try
    if FPalette <> nil then
      Result := GetPropValue(FPalette, SCnPalettePropPalToolCount)
  except
    Result := 0;
    if FPageScroller <> nil then
      for I := 0 to FPageScroller.ControlCount - 1 do
        if Self.FPageScroller.Controls[I] is TSpeedButton then
          Inc(Result);
  end;
end;

function TCnPaletteWrapper.GetSelectedIndex: Integer;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  I, Idx: Integer;
{$ENDIF}
begin
  Result := -1;
  try
    if FPalette <> nil then
    begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
      Idx := -1;
      for I := 0 to FPalette.ControlCount - 1 do
      begin
        if (FPalette.Controls[I] is TSpeedButton) and
          FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
        begin
          Inc(Idx);
          if (FPalette.Controls[I] as TSpeedButton).Down then
          begin
            Result := Idx;
            Exit;
          end;
        end;
      end;
{$ELSE}
      Result := GetPropValue(FPalette, SCnPalettePropSelectedIndex);
{$ENDIF}
    end;
  except
    ;
  end;
end;

function TCnPaletteWrapper.GetSelectedToolName: string;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  I: Integer;
{$ENDIF}
begin
  Result := '';
  try
    if FPalette <> nil then
    begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
      for I := 0 to FPalette.ControlCount - 1 do
      begin
        if (FPalette.Controls[I] is TSpeedButton) and
          FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
        begin
          if (FPalette.Controls[I] as TSpeedButton).Down then
          begin
            Result := ParseNameFromHint((FPalette.Controls[I] as TSpeedButton).Hint);
            Exit;
          end;
        end;
      end;
{$ELSE}
      Result := GetPropValue(FPalette, SCnPalettePropSelectedToolName);
{$ENDIF}
    end;
  except
    ;
  end;
end;

function TCnPaletteWrapper.GetSelector: TSpeedButton;
begin
  Result := nil;
  try
    if FPalette <> nil then
      Result := TSpeedButton(GetObjectProp(FPalette, SCnPalettePropSelector))
  except
    ;
  end;
end;

function TCnPaletteWrapper.GetTabCount: Integer;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  TabList: TStrings;
{$ENDIF}
begin
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    TabList := GetObjectProp(FPalTab, SCnNewPaletteTabItemsPropName) as TStrings;
    if TabList <> nil then
      Result := TabList.Count
    else
      Result := 0;
{$ELSE}
    Result := (FPalTab as TTabControl).Tabs.Count;
{$ENDIF}
  end
  else
    Result := 0;
end;

function TCnPaletteWrapper.GetTabIndex: Integer;
begin
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    Result := GetOrdProp(FPalTab, SCnNewPaletteTabIndexPropName);
{$ELSE}
    Result := (FPalTab as TTabControl).TabIndex;
{$ENDIF}
  end
  else
    Result := -1;
end;

function TCnPaletteWrapper.GetTabs(Index: Integer): string;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
var
  TabList: TStrings;
{$ENDIF}
begin
  if FPalette <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    TabList := GetObjectProp(FPalTab, SCnNewPaletteTabItemsPropName) as TStrings;
    if TabList <> nil then
      Result := TabList[Index]
    else
      Result := '';
{$ELSE}
    Result := (FPalTab as TTabControl).Tabs[Index];
{$ENDIF}
  end
  else
    Result := '';
end;

function TCnPaletteWrapper.GetVisible: Boolean;
begin
  if FPalTab <> nil then
    Result := FPalTab.Visible
  else
    Result := False;
end;

{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}

function TCnPaletteWrapper.ParseNameFromHint(const Hint: string): string;
const
  NamePrefix = 'Name: ';
  CRLF = #13#10;
var
  CRLFPos: Integer;
begin
  // �ѿؼ��������ĳ��� SpeedButton ��ť�� Hint ��ͷ�����ֽ�������
  {
    Hint ���磺
    Name: ComponentName
    Unit: UnitName
    Package: PackageName
  }
  Result := Hint;
  if Pos(NamePrefix, Result) = 1 then
    Delete(Result, 1, Length(NamePrefix));
  CRLFPos := Pos(CRLF, Result);
  if CRLFPos > 0 then
    Result := Copy(Result, 1, CRLFPos - 1);
end;

{$ENDIF}

function TCnPaletteWrapper.SelectComponent(const AComponent,
  ATab: string): Boolean;
var
  I, J, Idx: Integer;
begin
  Result := True;
  Idx := FindTab(ATab);
  if Idx >= 0 then
    TabIndex := Idx;

  // �����ʾ��ѡ��
  if AComponent = '' then
  begin
    SelectedIndex := -1;
    Exit;
  end
  else
  for I := 0 to PalToolCount - 1 do
  begin
    SelectedIndex := I;
    if SelectedToolName = AComponent then
      Exit;
  end;

  // �� Tab ���޴����ʱ��ȫ������
  for I := 0 to TabCount - 1 do
  begin
    TabIndex := I;
    for J := 0 to PalToolCount - 1 do
    begin
      SelectedIndex := J;
      if SelectedToolName = AComponent then
        Exit;
    end;
  end;
  
  SelectedIndex := -1;
  Result := False;
end;

procedure TCnPaletteWrapper.SetEnabled(const Value: Boolean);
begin
  if FPalTab <> nil then
    FPalTab.Enabled := Value;
end;

procedure TCnPaletteWrapper.SetSelectedIndex(const Value: Integer);
var
  PropInfo: PPropInfo;
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
  I, Idx: Integer;
{$ENDIF}
begin
  if FPalette <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    Idx := -1;
    for I := 0 to FPalette.ControlCount - 1 do
    begin
      if (FPalette.Controls[I] is TSpeedButton) and
        FPalette.Controls[I].ClassNameIs(SCnNewPaletteButtonClassName) then
      begin
        Inc(Idx);
        if Idx = Value then
        begin
          (FPalette.Controls[I] as TSpeedButton).Down := True;
          Exit;
        end
        else if (Value = -1) and (FPalette.Controls[I] as TSpeedButton).Down then
          (FPalette.Controls[I] as TSpeedButton).Down := False;
      end;
    end;
{$ELSE}
    PropInfo := GetPropInfo(FPalette.ClassInfo, SCnPalettePropSelectedIndex);
    SetOrdProp(FPalette, PropInfo, Value);
{$ENDIF}
  end;
end;

procedure TCnPaletteWrapper.SetTabIndex(const Value: Integer);
begin
  if FPalTab <> nil then
  begin
{$IFDEF IDE_HAS_NEW_COMPONENT_PALETTE}
    SetOrdProp(FPalTab, SCnNewPaletteTabIndexPropName, Value);
{$ELSE}
    (FPalTab as TTabControl).TabIndex := Value;     
{$ENDIF}
    if Assigned((FPalTab as TTabControl).OnChange) then
      (FPalTab as TTabControl).OnChange(FPalTab);
  end;
end;

procedure TCnPaletteWrapper.SetVisible(const Value: Boolean);
begin
  if FPalTab <> nil then
    FPalTab.Visible := Value;
end;

{ TCnMessageViewWrapper }

function CnMessageViewWrapper: TCnMessageViewWrapper;
begin
  if FCnMessageViewWrapper = nil then
    FCnMessageViewWrapper := TCnMessageViewWrapper.Create
  else
    FCnMessageViewWrapper.UpdateAllItems;

  Result := FCnMessageViewWrapper;
end;

constructor TCnMessageViewWrapper.Create;
begin
  UpdateAllItems;
end;

procedure TCnMessageViewWrapper.EditMessageSource;
begin
  if (FEditMenuItem <> nil) and Assigned(FEditMenuItem.OnClick) then
  begin
    FMessageViewForm.SetFocus;
    FEditMenuItem.OnClick(FEditMenuItem);
  end;
end;

{$IFNDEF BDS}

function TCnMessageViewWrapper.GetCurrentMessage: string;
begin
  Result := '';
  if FTreeView <> nil then
    if FTreeView.Selected <> nil then
      Result := FTreeView.Selected.Text;
end;

function TCnMessageViewWrapper.GetMessageCount: Integer;
begin
  Result := -1;
  if FTreeView <> nil then
    Result := FTreeView.Items.Count;
end;

function TCnMessageViewWrapper.GetSelectedIndex: Integer;
begin
  Result := -1;
  if (FTreeView <> nil) and (FTreeView.Selected <> nil) then
    Result := FTreeView.Selected.AbsoluteIndex;
end;

procedure TCnMessageViewWrapper.SetSelectedIndex(const Value: Integer);
begin
  if FTreeView <> nil then
    if (Value >= 0) and (Value < FTreeView.Items.Count) then
      FTreeView.Selected := FTreeView.Items[Value];
end;

{$ENDIF}

function TCnMessageViewWrapper.GetTabCaption: string;
begin
  Result := '';
  if FTabSet <> nil then
    Result := FTabSet.Tabs[FTabSet.TabIndex];
end;

function TCnMessageViewWrapper.GetTabCount: Integer;
begin
  Result := -1;
  if FTabSet <> nil then
    Result := FTabSet.Tabs.Count;
end;

function TCnMessageViewWrapper.GetTabIndex: Integer;
begin
  Result := -1;
  if FTabSet <> nil then
    Result := FTabSet.TabIndex;
end;

function TCnMessageViewWrapper.GetTabSetVisible: Boolean;
begin
  Result := False;
  if FTabSet <> nil then
    Result := FTabSet.Visible;;
end;

procedure TCnMessageViewWrapper.SetTabIndex(const Value: Integer);
begin
  if FTabSet <> nil then
    FTabSet.TabIndex := Value;
end;

procedure TCnMessageViewWrapper.UpdateAllItems;
var
  I, J: Integer;
begin
  try
    FMessageViewForm := nil;
    FEditMenuItem := nil;
    FTreeView := nil;
    FTabSet := nil;
    
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      if Screen.CustomForms[I].ClassNameIs('TMessageViewForm') then
      begin
        FMessageViewForm := Screen.CustomForms[I];
        FEditMenuItem := TMenuItem(FMessageViewForm.FindComponent(SCnMvEditSourceItemName));

        for J := 0 to FMessageViewForm.ControlCount - 1 do
        begin
          if FMessageViewForm.Controls[J].ClassNameIs(SCnTreeMessageViewClassName) then
          begin
           FTreeView := TXTreeView(FMessageViewForm.Controls[J]);
          end
          else if FMessageViewForm.Controls[J].Name = SCnMessageViewTabSetName then
          begin
            FTabSet := TTabSet(FMessageViewForm.Controls[J]);
          end;
        end;
      end;
    end;
  except
    ;
  end;
end;

initialization
  // ʹ�ô�ȫ�ֱ������Ա���Ƶ������ IdeGetIsEmbeddedDesigner ����
  IdeIsEmbeddedDesigner := IdeGetIsEmbeddedDesigner;
  
  InitIdeAPIs;

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnWizIdeUtils finalization.');
{$ENDIF}

  if FCnPaletteWrapper <> nil then
    FreeAndNil(FCnPaletteWrapper);

  if FCnMessageViewWrapper <> nil then
    FreeAndNil(FCnMessageViewWrapper);

  FinalIdeAPIs;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnWizIdeUtils finalization.');
{$ENDIF}
end.

