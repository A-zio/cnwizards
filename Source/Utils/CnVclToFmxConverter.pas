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

unit CnVclToFmxConverter;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizards VCL/FMX ����ת������Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע���õ�Ԫ�� Delphi 10.3.1 �� VCL �� FMX Ϊ����ȷ����һЩӳ���ϵ
* ����ƽ̨��PWin7 + Delphi 10.3.1
* ���ݲ��ԣ�XE2 �����ϣ���֧�ָ��Ͱ汾
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2019.04.10 V1.0
*               ������Ԫ��ʵ�ֻ�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Winapi.Windows,
  FMX.Types, FMX.Edit, FMX.ListBox, FMX.ListView, FMX.StdCtrls, FMX.ExtCtrls,
  FMX.TabControl, FMX.Memo, FMX.Dialogs, CnFmxUtils, CnVclToFmxMap;

type
  TCnPositionConverter = class(TCnPropertyConverter)
  {* �� Left/Top ת���� Position ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnSizeConverter = class(TCnPropertyConverter)
  {* �� Width/Height ת���� Size ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnCaptionConverter = class(TCnPropertyConverter)
  {* �� Caption ת���� Text ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnFontConverter = class(TCnPropertyConverter)
  {* �� Font ת���� TextSettings ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnTouchConverter = class(TCnPropertyConverter)
  {* ת�� Touch ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnGeneralConverter = class(TCnPropertyConverter)
  {* ת��һЩ��ͨ���Ե�ת����}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

implementation

function SearchPropertyValueAndRemoveFromStrings(List: TStrings; const PropertyName: string): string;
var
  I, P: Integer;
  S: string;
begin
  Result := '';
  S := PropertyName + ' = ';
  for I := List.Count - 1 downto 0 do
  begin
    P := Pos(S, List[I]);
    if P = 1 then
    begin
      Result := Copy(List[I], Length(S) + 1, MaxInt);
      List.Delete(I);
      Exit;
    end;
  end;
end;

{ TCnPositionConverter }

class procedure TCnPositionConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Top');
    OutProperties.Add('Left');
  end;
end;

class procedure TCnPositionConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  X, Y: Integer;
  V: string;
  Cls: TClass;
begin
  ActivateClassGroup(TFmxObject);
  Cls := GetClass(CnGetFmxClassFromVclClass(TheClassName));

  if (Cls = nil) or not CnFmxClassIsInheritedFromControl(Cls) then
  begin
    // ���� FMX.TControl �����ֱ࣬��ʹ��ԭʼ Left/Top������ Position.X/Y
    OutProperties.Add(Format('%s = %s', [PropertyName, PropertyValue]));
  end
  else
  begin
    if PropertyName = 'Top' then
    begin
      Y := StrToIntDef(PropertyValue, 0);
      V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Left');
      X := StrToIntDef(V, 0);
    end
    else if PropertyName = 'Left' then
    begin
      X := StrToIntDef(PropertyValue, 0);
      V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Top');
      Y := StrToIntDef(V, 0);
    end
    else
      Exit;

    OutProperties.Add('Position.X = ' + GetFloatStringFromInteger(X));
    OutProperties.Add('Position.Y = ' + GetFloatStringFromInteger(Y));
  end;
end;

{ TCnTextConverter }

class procedure TCnCaptionConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
    OutProperties.Add('Caption');
end;

class procedure TCnCaptionConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
begin
  // FMX TPanel û�� Text ����
  if (PropertyName = 'Caption') and (TheClassName <> 'TPanel') then
    OutProperties.Add('Text = ' + PropertyValue);
end;

{ TCnSizeConverter }

class procedure TCnSizeConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Width');
    OutProperties.Add('Height');
  end;
end;

class procedure TCnSizeConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  W, H: Integer;
  V: string;
begin
  if PropertyName = 'Width' then
  begin
    W := StrToIntDef(PropertyValue, 0);
    V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Height');
    H := StrToIntDef(V, 0);
  end
  else if PropertyName = 'Height' then
  begin
    H := StrToIntDef(PropertyValue, 0);
    V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Width');
    W := StrToIntDef(V, 0);
  end
  else
    Exit;

  OutProperties.Add('Size.Width = ' + GetFloatStringFromInteger(W));
  OutProperties.Add('Size.Height = ' + GetFloatStringFromInteger(H));
end;

{ TCnFontConverter }

class procedure TCnFontConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Font.Charset'); // û��
    OutProperties.Add('Font.Color');   // TextSettings.FontColor
    OutProperties.Add('Font.Height');  // TextSettings.Font.Size���Ӹ��������㷨���о�
    OutProperties.Add('Font.Name');    // TextSettings.Font.Family
    OutProperties.Add('Font.Style');   // TextSettings.Font.StyleExt������������ת��������о�
    OutProperties.Add('WordWrap');     // TextSettings.WordWrap
  end;
end;

class procedure TCnFontConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  V, ScreenLogPixels: Integer;
  DC: HDC;
  NewStr: string;
begin
  if PropertyName = 'Font.Charset' then
    // ɶ���������������Ҳ�����Ӧ��
  else if PropertyName = 'Font.Color' then
  begin
    NewStr := CnConvertEnumValue(PropertyValue);
    if Length(NewStr) > 0 then
    begin
      if NewStr[1] in ['A'..'Z'] then // TextSettings �� FontColor ֵ����ɫ����ǰ��Ҫ�� cla
        NewStr := 'cla' + NewStr;
      OutProperties.Add('TextSettings.FontColor = ' + NewStr);
    end;
  end
  else if PropertyName = 'Font.Name' then
    OutProperties.Add('TextSettings.Font.Family = ' + PropertyValue)
  else if PropertyName = 'Font.Height' then
  begin
    // ���� Height ���� Size ��ֵ
    V := StrToIntDef(PropertyValue, -11);
    DC := GetDC(0);
    ScreenLogPixels := GetDeviceCaps(DC, LOGPIXELSY);
    ReleaseDC(0, DC);
    V := -MulDiv(V, 72, ScreenLogPixels);
    OutProperties.Add('TextSettings.Font.Size = ' + GetFloatStringFromInteger(V));
  end
  else if PropertyName = 'Font.Style' then
  begin
    // TODO: ���� StyleExt �Ķ�����ֵ
    OutProperties.Add('TextSettings.Font.StyleExt = ');
  end
  else if PropertyName = 'WordWrap' then
    OutProperties.Add('TextSettings.WordWrap = ' + PropertyValue);
end;

{ TCnTouchConverter }

class procedure TCnTouchConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
    OutProperties.Add('Touch.');
end;

class procedure TCnTouchConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
begin
  if Pos('Touch.', PropertyName) = 1 then
    OutProperties.Add(Format('%s = %s', [PropertyName, PropertyValue]));
end;

{ TCnGeneralConverter }

class procedure TCnGeneralConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Action');      // �����������
    OutProperties.Add('Anchors');
    OutProperties.Add('Cancel');
    OutProperties.Add('Checked');     // TRadioButton/TCheckBox �� IsChecked
    OutProperties.Add('Cursor');
    OutProperties.Add('DragMode');
    OutProperties.Add('Default');
    OutProperties.Add('Enabled');
    OutProperties.Add('GroupIndex');
    OutProperties.Add('HelpContext');
    OutProperties.Add('Hint');
    OutProperties.Add('ImageIndex');
    OutProperties.Add('Images');
    OutProperties.Add('ItemHeight');
    OutProperties.Add('ItemIndex');
    OutProperties.Add('Items.Strings');
    OutProperties.Add('Lines.Strings');
    OutProperties.Add('ModalResult');
    OutProperties.Add('ParentShowHint');
    OutProperties.Add('PopupMenu');
    OutProperties.Add('ShowHint');
    OutProperties.Add('ShortCut');
    OutProperties.Add('TabStop');
    OutProperties.Add('TabOrder');
    OutProperties.Add('Tag');
    OutProperties.Add('Text');
    OutProperties.Add('Visible');

    OutProperties.Add('ActivePage');   // ������Ҫ����
    OutProperties.Add('PageIndex');
  end;
end;

class procedure TCnGeneralConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  NewPropName: string;
begin
  // FMX �� TComboBox �� Text ���Բ����ڣ�����
  if (TheClassName = 'TComboBox') and (PropertyName = 'Text') then
    Exit;

  if PropertyName = 'ActivePage' then
    NewPropName := 'ActiveTab'
  else if PropertyName = 'PageIndex' then
    NewPropName := 'Index'
  else if (PropertyName = 'Checked') and ((TheClassName = 'TRadioButton') or
    (TheClassName = 'TCheckBox')) then
    NewPropName := 'IsChecked'
  else
    NewPropName := PropertyName;

  OutProperties.Add(Format('%s = %s', [NewPropName, PropertyValue]));
end;

initialization
  RegisterCnPropertyConverter(TCnPositionConverter);
  RegisterCnPropertyConverter(TCnSizeConverter);
  RegisterCnPropertyConverter(TCnCaptionConverter);
  RegisterCnPropertyConverter(TCnFontConverter);
  RegisterCnPropertyConverter(TCnTouchConverter);
  RegisterCnPropertyConverter(TCnGeneralConverter);

end.
