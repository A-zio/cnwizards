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

unit CnCodeFormatterWizard;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ������ʽ��ר�ҵ�Ԫ
* ��Ԫ���ߣ���Х(LiuXiao) liuxiao@cnpack.org
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5
* ���ݲ��ԣ����ޣ�PWin9X/2000/XP/7 Delphi 5/6/7 + C++Builder 5/6��
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.03.11 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODEFORMATTERWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, StdCtrls, ComCtrls, Menus, CnSpin,
  CnConsts, CnCommon, CnWizConsts, CnWizClasses, CnWizMultiLang, CnWizOptions,
  CnWizUtils, CnFormatterIntf, CnCodeFormatRules;

type
  TCnCodeFormatterWizard = class(TCnSubMenuWizard)
  private
    FIdOptions: Integer;
    FIdFormatCurrent: Integer;

    FLibHandle: THandle;
    FGetProvider: TCnGetFormatterProvider;

    // Pascal Format Settings
    FUsesUnitSingleLine: Boolean;
    FUseIgnoreArea: Boolean;
    FSpaceAfterOperator: Byte;
    FSpaceBeforeOperator: Byte;
    FSpaceBeforeASM: Byte;
    FTabSpaceCount: Byte;
    FSpaceTabASMKeyword: Byte;
    FWrapWidth: Integer;
    FBeginStyle: TBeginStyle;
    FKeywordStyle: TKeywordStyle;
    FWrapMode: TCodeWrapMode;
    FWrapNewLineWidth: Integer;

    function PutPascalFormatRules: Boolean;
    function GetErrorStr(Err: Integer): string;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure AcquireSubActions; override;

    property KeywordStyle: TKeywordStyle read FKeywordStyle write FKeywordStyle;
    property BeginStyle: TBeginStyle read FBeginStyle write FBeginStyle;
    property WrapMode: TCodeWrapMode read FWrapMode write FWrapMode;
    property TabSpaceCount: Byte read FTabSpaceCount write FTabSpaceCount;
    property SpaceBeforeOperator: Byte read FSpaceBeforeOperator write FSpaceBeforeOperator;
    property SpaceAfterOperator: Byte read FSpaceAfterOperator write FSpaceAfterOperator;
    property SpaceBeforeASM: Byte read FSpaceBeforeASM write FSpaceBeforeASM;
    property SpaceTabASMKeyword: Byte read FSpaceTabASMKeyword write FSpaceTabASMKeyword;
    property WrapWidth: Integer read FWrapWidth write FWrapWidth;
    property WrapNewLineWidth: Integer read FWrapNewLineWidth write FWrapNewLineWidth;
    property UsesUnitSingleLine: Boolean read FUsesUnitSingleLine write FUsesUnitSingleLine;
    property UseIgnoreArea: Boolean read FUseIgnoreArea write FUseIgnoreArea;
  end;

  TCnCodeFormatterForm = class(TCnTranslateForm)
    pgcFormatter: TPageControl;
    tsPascal: TTabSheet;
    grpCommon: TGroupBox;
    lblKeyword: TLabel;
    cbbKeywordStyle: TComboBox;
    lblBegin: TLabel;
    cbbBeginStyle: TComboBox;
    lblTab: TLabel;
    seTab: TCnSpinEdit;
    seWrapLine: TCnSpinEdit;
    lblSpaceBefore: TLabel;
    seSpaceBefore: TCnSpinEdit;
    lblSpaceAfter: TLabel;
    seSpaceAfter: TCnSpinEdit;
    chkUsesSinglieLine: TCheckBox;
    grpAsm: TGroupBox;
    chkIgnoreArea: TCheckBox;
    seASMHeadIndent: TCnSpinEdit;
    lblAsmHeadIndent: TLabel;
    lblASMTab: TLabel;
    seAsmTab: TCnSpinEdit;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    chkAutoWrap: TCheckBox;
    btnShortCut: TButton;
    lblNewLine: TLabel;
    seNewLine: TCnSpinEdit;
    procedure chkAutoWrapClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnShortCutClick(Sender: TObject);
  private
    FWizard: TCnCodeFormatterWizard;
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

{$ENDIF CNWIZARDS_CNCODEFORMATTERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODEFORMATTERWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
{$IFDEF UNICODE}
  DLLName: string = 'CnFormatLibW.dll'; // D2009 ~ ���� �� Unicode ��
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  DLLName: string = 'CnFormatLibW.dll'; // D2005 ~ 2007 Ҳ�� Unicode �浫�� UTF8
  {$ELSE}
  DLLName: string = 'CnFormatLib.dll';  // D5~7 ���� Ansi ��
  {$ENDIF}
{$ENDIF}

  csUsesUnitSingleLine = 'UsesUnitSingleLine';
  csUseIgnoreArea = 'UseIgnoreArea';
  csSpaceAfterOperator = 'SpaceAfterOperator';
  csSpaceBeforeOperator = 'SpaceBeforeOperator';
  csSpaceBeforeASM = 'SpaceBeforeASM';
  csTabSpaceCount = 'TabSpaceCount';
  csSpaceTabASMKeyword = 'SpaceTabASMKeyword';
  csWrapWidth = 'WrapWidth';
  csWrapNewLineWidth = 'WrapNewLineWidth';
  csWrapMode = 'WrapMode';
  csBeginStyle = 'BeginStyle';
  csKeywordStyle = 'KeywordStyle';

{ TCnCodeFormatterWizard }

procedure TCnCodeFormatterWizard.AcquireSubActions;
begin
  FIdFormatCurrent := RegisterASubAction(SCnCodeFormatterWizardFormatCurrent,
    SCnCodeFormatterWizardFormatCurrentCaption, TextToShortCut('Ctrl+W'),
    SCnCodeFormatterWizardFormatCurrentHint);
  // Other Menus

  AddSepMenu;
  FIdOptions := RegisterASubAction(SCnCodeFormatterWizardConfig,
    SCnCodeFormatterWizardConfigCaption, 0, SCnCodeFormatterWizardConfigHint);
end;

procedure TCnCodeFormatterWizard.Config;
begin
  with TCnCodeFormatterForm.Create(nil) do
  begin
    FWizard := Self;

    cbbKeywordStyle.ItemIndex := Ord(FKeywordStyle);
    cbbBeginStyle.ItemIndex := Ord(FBeginStyle);
    seTab.Value := FTabSpaceCount;
    chkAutoWrap.Checked := (FWrapMode <> cwmNone);
    seWrapLine.Value := FWrapWidth;
    seNewLine.Value := FWrapNewLineWidth;
    seSpaceBefore.Value := FSpaceBeforeOperator;
    seSpaceAfter.Value := FSpaceAfterOperator;
    chkUsesSinglieLine.Checked := FUsesUnitSingleLine;

    seASMHeadIndent.Value := FSpaceBeforeASM;
    seAsmTab.Value := FSpaceTabASMKeyword;
    chkIgnoreArea.Checked := FUseIgnoreArea;

    if ShowModal = mrOK then
    begin
      FKeywordStyle := TKeywordStyle(cbbKeywordStyle.ItemIndex);
      FBeginStyle := TBeginStyle(cbbBeginStyle.ItemIndex);
      FTabSpaceCount := seTab.Value;
      FWrapWidth := seWrapLine.Value;
      FWrapNewLineWidth := seNewLine.Value;
      if chkAutoWrap.Checked then
        FWrapMode := cwmAdvanced
      else
        FWrapMode := cwmNone;

      FSpaceBeforeOperator := seSpaceBefore.Value;
      FSpaceAfterOperator := seSpaceAfter.Value;
      FUsesUnitSingleLine := chkUsesSinglieLine.Checked;

      FSpaceBeforeASM := seASMHeadIndent.Value;
      FSpaceTabASMKeyword := seAsmTab.Value;
      FUseIgnoreArea := chkIgnoreArea.Checked;
    end;
    
    Free;
  end;
end;

constructor TCnCodeFormatterWizard.Create;
begin
  inherited;
  FLibHandle := LoadLibrary(PChar(MakePath(WizOptions.DllPath) + DLLName));
  if FLibHandle <> 0 then
    FGetProvider := TCnGetFormatterProvider(GetProcAddress(FLibHandle, 'GetCodeFormatterProvider'));
end;

destructor TCnCodeFormatterWizard.Destroy;
begin
  FreeLibrary(FLibHandle);
  inherited;
end;

procedure TCnCodeFormatterWizard.Execute;
begin

end;

function TCnCodeFormatterWizard.GetCaption: string;
begin
  Result := SCnCodeFormatterWizardMenuCaption;
end;

function TCnCodeFormatterWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnCodeFormatterWizard.GetErrorStr(Err: Integer): string;
begin
  case Err of
    CN_ERRCODE_PASCAL_IDENT_EXP:
      Result := SCnCodeFormatterErrPascalIdentExp;
    CN_ERRCODE_PASCAL_STRING_EXP:
      Result := SCnCodeFormatterErrPascalStringExp;
    CN_ERRCODE_PASCAL_NUMBER_EXP:
      Result := SCnCodeFormatterErrPascalNumberExp;
    CN_ERRCODE_PASCAL_CHAR_EXP:
      Result := SCnCodeFormatterErrPascalCharExp;
    CN_ERRCODE_PASCAL_SYMBOL_EXP:
      Result := SCnCodeFormatterErrPascalSymbolExp;
    CN_ERRCODE_PASCAL_PARSE_ERR:
      Result := SCnCodeFormatterErrPascalParseErr;
    CN_ERRCODE_PASCAL_INVALID_BIN:
      Result := SCnCodeFormatterErrPascalInvalidBin;
    CN_ERRCODE_PASCAL_INVALID_STRING:
      Result := SCnCodeFormatterErrPascalInvalidString;
    CN_ERRCODE_PASCAL_INVALID_BOOKMARK:
      Result := SCnCodeFormatterErrPascalInvalidBookmark;
    CN_ERRCODE_PASCAL_LINE_TOOLONG:
      Result := SCnCodeFormatterErrPascalLineTooLong;
    CN_ERRCODE_PASCAL_ENDCOMMENT_EXP:
      Result := SCnCodeFormatterErrPascalEndCommentExp;
    CN_ERRCODE_PASCAL_NOT_SUPPORT:
      Result := SCnCodeFormatterErrPascalNotSupport;
    CN_ERRCODE_PASCAL_ERROR_DIRECTIVE:
      Result := SCnCodeFormatterErrPascalErrorDirective;
    CN_ERRCODE_PASCAL_NO_METHODHEADING:
      Result := SCnCodeFormatterErrPascalNoMethodHeading;
    CN_ERRCODE_PASCAL_NO_STRUCTTYPE:
      Result := SCnCodeFormatterErrPascalNoStructType;
    CN_ERRCODE_PASCAL_NO_TYPEDCONSTANT:
      Result := SCnCodeFormatterErrPascalNoTypedConstant;
    CN_ERRCODE_PASCAL_NO_EQUALCOLON:
      Result := SCnCodeFormatterErrPascalNoEqualColon;
    CN_ERRCODE_PASCAL_NO_DECLSECTION:
      Result := SCnCodeFormatterErrPascalNoDeclSection;
    CN_ERRCODE_PASCAL_NO_PROCFUNC:
      Result := SCnCodeFormatterErrPascalNoProcFunc;
    CN_ERRCODE_PASCAL_UNKNOWN_GOAL:
      Result := SCnCodeFormatterErrPascalUnknownGoal;
    CN_ERRCODE_PASCAL_ERROR_INTERFACE:
      Result := SCnCodeFormatterErrPascalErrorInterface;
    CN_ERRCODE_PASCAL_INVALID_STATEMENT:
      Result := SCnCodeFormatterErrPascalInvalidStatement;
  else
    Result := SCnCodeFormatterErrUnknown;
  end;
end;

function TCnCodeFormatterWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnCodeFormatterWizard.GetHint: string;
begin
  Result := SCnCodeFormatterWizardMenuHint;
end;

function TCnCodeFormatterWizard.GetState: TWizardState;
begin
  if Active then
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnCodeFormatterWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := SCnCodeFormatterWizardName;
  Author := SCnPack_GuYueChunQiu + ';' + SCnPack_LiuXiao;
  Email := SCnPack_GuYueChunQiuEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnCodeFormatterWizardComment;
end;

procedure TCnCodeFormatterWizard.LoadSettings(Ini: TCustomIniFile);
begin
  FUsesUnitSingleLine := Ini.ReadBool('', csUsesUnitSingleLine, CnPascalCodeForVCLRule.UsesUnitSingleLine);
  FUseIgnoreArea := Ini.ReadBool('', csUseIgnoreArea, CnPascalCodeForVCLRule.UseIgnoreArea);
  FSpaceAfterOperator := Ini.ReadInteger('', csSpaceAfterOperator, CnPascalCodeForVCLRule.SpaceAfterOperator);
  FSpaceBeforeOperator := Ini.ReadInteger('', csSpaceBeforeOperator, CnPascalCodeForVCLRule.SpaceBeforeOperator);
  FSpaceBeforeASM := Ini.ReadInteger('', csSpaceBeforeASM, CnPascalCodeForVCLRule.SpaceBeforeASM);
  FTabSpaceCount := Ini.ReadInteger('', csTabSpaceCount, CnPascalCodeForVCLRule.TabSpaceCount);
  FSpaceTabASMKeyword := Ini.ReadInteger('', csSpaceTabASMKeyword, CnPascalCodeForVCLRule.SpaceTabASMKeyword);
  FWrapWidth := Ini.ReadInteger('', csWrapWidth, CnPascalCodeForVCLRule.WrapWidth);
  FWrapNewLineWidth := Ini.ReadInteger('', csWrapNewLineWidth, CnPascalCodeForVCLRule.WrapNewLineWidth);
  FWrapMode := TCodeWrapMode(Ini.ReadInteger('', csWrapMode, Ord(CnPascalCodeForVCLRule.CodeWrapMode)));
  FBeginStyle := TBeginStyle(Ini.ReadInteger('', csBeginStyle, Ord(CnPascalCodeForVCLRule.BeginStyle)));
  FKeywordStyle := TKeywordStyle(Ini.ReadInteger('', csKeywordStyle, Ord(CnPascalCodeForVCLRule.KeywordStyle)));
end;

function TCnCodeFormatterWizard.PutPascalFormatRules: Boolean;
var
  Intf: ICnPascalFormatterIntf;
  ADirectiveMode: DWORD;
  AKeywordStyle: DWORD;
  ABeginStyle: DWORD;
  ATabSpace: DWORD;
  ASpaceBeforeOperator: DWORD;
  ASpaceAfterOperator: DWORD;
  ASpaceBeforeAsm: DWORD;
  ASpaceTabAsm: DWORD;
  ALineWrapWidth: DWORD;
  ANewLineWrapWidth: DWORD;
  AWrapMode: DWORD;
  AUsesSingleLine: LongBool;
  AUseIgnoreArea: LongBool;
begin
  Result := False;
  if FGetProvider = nil then
    Exit;
  Intf := FGetProvider();

  if Intf = nil then    
    Exit;

  ADirectiveMode := CN_RULE_DIRECTIVE_MODE_DEFAULT;
  AKeywordStyle := CN_RULE_KEYWORD_STYLE_DEFAULT;
  AWrapMode := CN_RULE_CODE_WRAP_MODE_DEFAULT;

  case FKeywordStyle of
    ksLowerCaseKeyword:
      AKeywordStyle := CN_RULE_KEYWORD_STYLE_LOWER;
    ksUpperCaseKeyword:
      AKeywordStyle := CN_RULE_KEYWORD_STYLE_UPPER;
    ksPascalKeyword:
      AKeywordStyle := CN_RULE_KEYWORD_STYLE_UPPERFIRST;
    ksNoChange:
      AKeywordStyle := CN_RULE_KEYWORD_STYLE_NOCHANGE;
  end;

  ABeginStyle := CN_RULE_BEGIN_STYLE_DEFAULT;
  case FBeginStyle of
    bsNextLine: ABeginStyle := CN_RULE_BEGIN_STYLE_NEXTLINE;
    bsSameLine: ABeginStyle := CN_RULE_BEGIN_STYLE_SAMELINE;
  end;

  ATabSpace := FTabSpaceCount;
  ASpaceBeforeOperator := FSpaceBeforeOperator;
  ASpaceAfterOperator := FSpaceAfterOperator;
  ASpaceBeforeAsm := FSpaceBeforeASM;
  ASpaceTabAsm := FSpaceTabASMKeyword;
  ALineWrapWidth := FWrapWidth;
  ANewLineWrapWidth := FWrapNewLineWidth;

  case FWrapMode of
    cwmNone: AWrapMode := CN_RULE_CODE_WRAP_MODE_NONE;
    cwmSimple: AWrapMode := CN_RULE_CODE_WRAP_MODE_SIMPLE;
    cwmAdvanced: AWrapMode := CN_RULE_CODE_WRAP_MODE_ADVANCED;
  end;

  AUsesSingleLine := LongBool(FUsesUnitSingleLine);
  AUseIgnoreArea := LongBool(FUseIgnoreArea);

  Intf.SetPascalFormatRule(ADirectiveMode, AKeywordStyle, ABeginStyle, AWrapMode,
    ATabSpace, ASpaceBeforeOperator, ASpaceAfterOperator, ASpaceBeforeAsm,
    ASpaceTabAsm, ALineWrapWidth, ANewLineWrapWidth, AUsesSingleLine, AUseIgnoreArea);
  Result := True;
end;

procedure TCnCodeFormatterWizard.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool('', csUsesUnitSingleLine, FUsesUnitSingleLine);
  Ini.WriteBool('', csUseIgnoreArea, FUseIgnoreArea);
  Ini.WriteInteger('', csSpaceAfterOperator, FSpaceAfterOperator);
  Ini.WriteInteger('', csSpaceBeforeOperator, FSpaceBeforeOperator);
  Ini.WriteInteger('', csSpaceBeforeASM, FSpaceBeforeASM);
  Ini.WriteInteger('', csTabSpaceCount, FTabSpaceCount);
  Ini.WriteInteger('', csSpaceTabASMKeyword, FSpaceTabASMKeyword);
  Ini.WriteInteger('', csWrapWidth, FWrapWidth);
  Ini.WriteInteger('', csWrapNewLineWidth, FWrapNewLineWidth);
  Ini.WriteInteger('', csWrapMode, Ord(FWrapMode));
  Ini.WriteInteger('', csBeginStyle, Ord(FBeginStyle));
  Ini.WriteInteger('', csKeywordStyle, Ord(FKeywordStyle));
end;

procedure TCnCodeFormatterWizard.SubActionExecute(Index: Integer);
var
  Formatter: ICnPascalFormatterIntf;
  View: IOTAEditView;
  Src: string;
  Res: PChar;
  ErrCode, SourceLine, SourceCol, SourcePos: Integer;
  CurrentToken: PAnsiChar;
  Block: IOTAEditBlock;
  StartPos, EndPos, StartPosIn, EndPosIn: Integer;
  StartRec, EndRec: TOTACharPos;
  ErrLine: string;

  // ���������з��صĳ�����ת���� IDE ���ڲ�ʹ�õ��й���λ��BDS ������ Utf8
  function ConvertToEditorCol(const Line: string; Col: Integer): Integer;
  var
    S: WideString;
  begin
    Result := Col;
{$IFDEF IDE_STRING_ANSI_UTF8}
    // Col ���ص��� Unicode ���У�Line �� Ansi �ģ���Ҫת�� Utf8 ����
    S := WideString(Line);
    S := Copy(S, 1, Col);
    Result := Length(UTF8Encode(S));
{$ELSE}
  {$IFDEF UNICODE}
    // Col ���ص��� Unicode ���У�Line �� Unicode �ģ���Ҫת�� Utf8 ����
    S := Copy(Line, 1, Col);
    Result := Length(UTF8Encode(S));
  {$ENDIF}
{$ENDIF}
  end;

  // ���������з��صĳ�����ת���� IDE ����ʾ���й���ʾ������ Ansi
  function ConvertToVisibleCol(const Line: string; Col: Integer): Integer;
  var
    S: WideString;
  begin
    Result := Col;
{$IFDEF IDE_STRING_ANSI_UTF8}
    // Col ���ص��� Unicode ���У�Line �� Ansi �ģ���Ҫת�� Ansi ����
    S := WideString(Line);
    S := Copy(S, 1, Col);
    Result := Length(AnsiString(S));
{$ELSE}
  {$IFDEF UNICODE}
    // Col ���ص��� Unicode ���У�Line �� Unicode �ģ���Ҫת�� Ansi ����
    S := Copy(Line, 1, Col);
    Result := Length(AnsiString(S));
  {$ENDIF}
{$ENDIF}
  end;

begin
  if Index = FIdOptions then
    Config
  else if Index = FIdFormatCurrent then
  begin
    PutPascalFormatRules;

    Formatter := FGetProvider();
    if Formatter = nil then
      Exit;
    View := CnOtaGetTopMostEditView;
    if not Assigned(View) then
      Exit;

    if (View.Block = nil) or not View.Block.IsValid then // ��ѡ����
    begin
      try
        Screen.Cursor := crHourGlass;
{$IFDEF UNICODE}
        // Src/Res Utf16
        Src := CnOtaGetCurrentEditorSourceW;
        Res := Formatter.FormatOnePascalUnitW(PChar(Src), Length(Src));

        // Remove FF FE BOM if exists
        if (Res <> nil) and (StrLen(Res) > 1) and (Res[0] = #$FEFF) then
          Inc(Res);
        // CnDebugger.LogMemDump(PChar(Res), Length(Res) * SizeOf(Char));
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
        // Src/Res Utf8
        Src := CnOtaGetCurrentEditorSource(False);
        Res := Formatter.FormatOnePascalUnitUtf8(PAnsiChar(Src), Length(Src));

        // Remove EF BB BF BOM if exist
        if (Res <> nil) and (StrLen(Res) > 3) and
          (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
          Inc(Res, 3);
        // CnDebugger.LogMemDump(PAnsiChar(Res), Length(Res));
  {$ELSE}
        // Src/Res Ansi
        Src := CnOtaGetCurrentEditorSource(True);
        Res := Formatter.FormatOnePascalUnit(PAnsiChar(Src), Length(Src));
  {$ENDIF}
{$ENDIF}
        if Res <> nil then
        begin
{$IFDEF UNICODE}
          // Utf16 �ڲ�ת Utf8 д��
          CnOtaSetCurrentEditorSourceW(string(Res));
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
          // Utf8 ֱ��д��
          CnOtaSetCurrentEditorSourceUtf8(string(Res));
  {$ELSE}
          // Ansi ת Utf8 д��
          CnOtaSetCurrentEditorSource(string(Res));
  {$ENDIF}
{$ENDIF}
        end
        else
        begin
          ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
            SourcePos, CurrentToken);
          Screen.Cursor := crDefault;

          ErrLine := CnOtaGetLineText(SourceLine, View.Buffer);
          CnOtaGotoEditPos(OTAEditPos(ConvertToEditorCol(ErrLine, SourceCol), SourceLine));
          ErrorDlg(Format(SCnCodeFormatterErrPascalFmt, [SourceLine, ConvertToVisibleCol(ErrLine, SourceCol),
            GetErrorStr(ErrCode), CurrentToken]));
        end;
      finally
        Formatter := nil;
        Screen.Cursor := crDefault;
      end;
    end
    else // ��ѡ����
    begin
      try
        Screen.Cursor := crHourGlass;
{$IFDEF UNICODE}
        // Src/Res Utf16
        Src := CnOtaGetCurrentEditorSourceW;
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
        // Src/Res Utf8
        Src := CnOtaGetCurrentEditorSource(False);
  {$ELSE}
        // Src/Res Ansi
        Src := CnOtaGetCurrentEditorSource(True);
  {$ENDIF}
{$ENDIF}

        View := CnOtaGetTopMostEditView;
        if View <> nil then
        begin
          Block := View.Block;
          if (Block <> nil) and Block.IsValid then
          begin
            // ѡ�����ֹλ�����쵽��ģʽ
            if not CnOtaGetBlockOffsetForLineMode(StartRec, EndRec, View) then
              Exit;
            StartPos := CnOtaEditPosToLinePos(OTAEditPos(StartRec.CharIndex, StartRec.Line), View);
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(EndRec.CharIndex, EndRec.Line), View);

            // ��ʱ StartPos �� EndPos ����˵�ǰѡ������Ҫ������ı�
{$IFDEF UNICODE}
            // Src/Res Utf16���� LinearPos �� Utf8 ��ƫ��������Ҫת��
            StartPosIn := Length(UTF8Decode(Copy(Utf8Encode(Src), 1, StartPos + 1))) - 1;
            EndPosIn := Length(UTF8Decode(Copy(Utf8Encode(Src), 1, EndPos + 1))) - 1;
            Res := Formatter.FormatPascalBlockW(PChar(Src), Length(Src), StartPosIn, EndPosIn);

            // Remove FF FE BOM if exists
            if (Res <> nil) and (StrLen(Res) > 1) and (Res[0] = #$FEFF) then
              Inc(Res);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
            // Src/Res Utf8
            StartPosIn := StartPos;
            EndPosIn := EndPos;
            Res := Formatter.FormatPascalBlockUtf8(PAnsiChar(Src), Length(Src), StartPosIn, EndPosIn);

            // Remove EF BB BF BOM if exist
            if (Res <> nil) and (StrLen(Res) > 3) and
              (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
              Inc(Res, 3);
  {$ELSE}
            // Src/Res Ansi
            StartPosIn := StartPos;
            EndPosIn := EndPos;
            // IDE �ڵ����� Pos �� 0 ��ʼ�ģ�ʹ�� Src �� Copy ʱ���±��� 1 ��ʼ�������Ҫ�� 1
            Res := Formatter.FormatPascalBlock(PAnsiChar(Src), Length(Src), StartPosIn, EndPosIn);
  {$ENDIF}
{$ENDIF}

            if Res <> nil then
            begin
              {$IFDEF IDE_STRING_ANSI_UTF8}
              CnOtaReplaceCurrentSelectionUtf8(Res, True, True, True);
              {$ELSE}
              // Ansi/Unicode ������
              CnOtaReplaceCurrentSelection(Res, True, True, True);
              {$ENDIF}
            end
            else
            begin
              ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
                SourcePos, CurrentToken);
              Screen.Cursor := crDefault;

              ErrLine := CnOtaGetLineText(SourceLine, View.Buffer);
              CnOtaGotoEditPos(OTAEditPos(ConvertToEditorCol(ErrLine, SourceCol), SourceLine));
              ErrorDlg(Format(SCnCodeFormatterErrPascalFmt, [SourceLine, ConvertToVisibleCol(ErrLine, SourceCol),
                GetErrorStr(ErrCode), CurrentToken]));
            end;
          end;
        end;
      finally
        Screen.Cursor := crDefault;
        Formatter := nil;
      end;
    end;
  end;
end;

procedure TCnCodeFormatterWizard.SubActionUpdate(Index: Integer);
var
  S: string;
begin
  if Index = FIdFormatCurrent then
  begin
    S := CnOtaGetCurrentSourceFile;
    SubActions[Index].Enabled := IsDprOrPas(S) or IsInc(S) or IsDpk(S);
  end
  else
    SubActions[Index].Enabled := True;
end;

procedure TCnCodeFormatterForm.chkAutoWrapClick(Sender: TObject);
begin
  seWrapLine.Enabled := chkAutoWrap.Checked;
  seNewLine.Enabled := chkAutoWrap.Checked;
end;

procedure TCnCodeFormatterForm.FormShow(Sender: TObject);
begin
  chkAutoWrapClick(chkAutoWrap);
end;

function TCnCodeFormatterForm.GetHelpTopic: string;
begin
  Result := 'CnCodeFormatterWizard';
end;

procedure TCnCodeFormatterForm.btnShortCutClick(Sender: TObject);
begin
  if FWizard.ShowShortCutDialog(GetHelpTopic) then
    FWizard.DoSaveSettings;
end;

initialization
{$IFNDEF BCB5}  // Ŀǰֻ֧�� Delphi��
{$IFNDEF BCB6}
  RegisterCnWizard(TCnCodeFormatterWizard);
{$ENDIF}
{$ENDIF}

{$ENDIF CNWIZARDS_CNCODEFORMATTERWIZARD}
end.
