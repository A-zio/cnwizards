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

unit CnCompDirectiveTree;
{* |<PRE>
================================================================================
* ������ƣ�CnPack ר�Ұ�
* ��Ԫ���ƣ�ʵ�ִ������ IFDEF �����ĵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע���õ�ԪΪʹ�� TCnTree �� TCnLeaf ����������д���� IFDEF ����ʵ�ֵ�Ԫ��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.03.13 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

(*
  ����˼�룺�����뱻 IFDEF/ELSEIF/ENDIF �ֿ��������ֳ���״�ṹ��
  ����루δ�����س����У���
  begin 1111 {$IFDEF DEBUG} 22222 {$ELSEIF NDEBUG} 33333 {ELSE} 4444 {ENDIF} end;

  Root:
    SliceNode 0    -- ǰ׺���ޡ����ݣ�begin 1111
      SliceNode 1  -- ǰ׺��{$IFDEF DEBUG}�����ݣ�22222
      SliceNode 2  -- ǰ׺��{$ELSEIF NDEBUG}�����ݣ�33333
      SliceNode 3  -- ǰ׺��{$ELSE}�����ݣ�4444��
    SliceNode 5    -- ǰ׺��{$ENDIF}�����ݣ�end;

  ���Ƕ�ף�
  begin 111
  {$IFDEF DEBUG}
    2222
    {IFDEF NDEBUG}
       3333
    {$ENDIF}
    4444
  {$ELSE}
    5555
  {$ENDIF}
  end;

  ��
  Root:
    SliceNode 0    -- ǰ׺���ޡ����ݣ�begin 1111
      SliceNode 1  -- ǰ׺��{$IFDEF DEBUG}�����ݣ�22222
        SliceNode 2-- ǰ׺��{$IFDEF NDEBUG}�����ݣ�3333
      SliceNode 3  -- ǰ׺��{$ENDIF}�����ݣ�4444
      SliceNode 4  -- ǰ׺��{$ELSE}�����ݣ�5555
    SliceNode 5    -- ǰ׺��{$ENDIF}�����ݣ�END;
  
  �����Ǽ�IFDEF�ͽ�һ�㲢��IFDEF�ͺ����������ȥ��
  ��ENDIF��һ���ENDIF�ͺ����������ȥ��
  ��ELSE/ELIF��ͬ�����ɸ��µġ�
*)

uses
  SysUtils, Classes, Windows,
  CnTree, CnScaners, CnCodeFormatRules, CnTokens;

type
  TCnSliceNode = class(TCnLeaf)
  {* IFDEF �������ӽڵ�ʵ���࣬�� Child Ҳ�� TCnSliceNode}
  private
    FCompDirectiveStream: TMemoryStream;
    FNormalCodeStream: TMemoryStream;
    function GetItems(Index: Integer): TCnSliceNode;
  protected

  public
    constructor Create(ATree: TCnTree); override;
    destructor Destroy; override;

    function IsSingleSlice: Boolean;
    function ToString: string;

    property CompDirectiveStream: TMemoryStream read FCompDirectiveStream write FCompDirectiveStream;
    property NormalCodeStream: TMemoryStream read FNormalCodeStream write FNormalCodeStream;
    
    property Items[Index: Integer]: TCnSliceNode read GetItems; default;
    {* ֱ��Ҷ�ڵ����� }
  end;

  TCnCompDirectiveTree = class(TCnTree)
  private
    FScaner: TAbstractScaner;
    function GetItems(AbsoluteIndex: Integer): TCnSliceNode;
  public
    constructor Create(AStream: TStream);
    destructor Destroy; override;

    procedure ParseTree;

    property Items[AbsoluteIndex: Integer]: TCnSliceNode read GetItems; 
  end;

implementation

const
  ACnPasCompDirectiveTokenStr: array[0..5] of AnsiString =
    ('{$IF ', '{$IFDEF ', '{$IFNDEF ', '{$ELSE', '{$ENDIF', '{$IFEND');

  ACnPasCompDirectiveTypes: array[0..5] of TPascalCompDirectiveType =
    (cdtIf, cdtIfDef, cdtIfNDef, cdtElse, cdtEndIf, cdtIfEnd);

{ TCnSliceNode }

constructor TCnSliceNode.Create(ATree: TCnTree);
begin
  inherited;

end;

destructor TCnSliceNode.Destroy;
begin
  FreeAndNil(FCompDirectiveStream);
  FreeAndNil(FNormalCodeStream);
  inherited;
end;

function TCnSliceNode.GetItems(Index: Integer): TCnSliceNode;
begin
  Result := TCnSliceNode(inherited GetItems(Index));
end;

function TCnSliceNode.IsSingleSlice: Boolean;
begin
  Result := not GetHasChildren;
end;

function TCnSliceNode.ToString: string;
var
  Len: Integer;
begin
  Result := '';
  if (FCompDirectiveStream = nil) and (FNormalCodeStream = nil) then
    Exit;

  Len := 0;
  if FCompDirectiveStream <> nil then
    Len := FCompDirectiveStream.Size;
  if FNormalCodeStream <> nil then
    Inc(Len, FNormalCodeStream.Size);

  SetLength(Result, Len);
  if FCompDirectiveStream <> nil then
    CopyMemory(@(Result[1]), FCompDirectiveStream.Memory,
      FCompDirectiveStream.Size);

  if FNormalCodeStream <> nil then
  begin
    Len := 0;
    if FCompDirectiveStream <> nil then
      Len := FCompDirectiveStream.Size;
    CopyMemory(@(Result[1 + Len]),
      FNormalCodeStream.Memory, FNormalCodeStream.Size);
  end;
end;

{ TCnCompDirectiveTree }

constructor TCnCompDirectiveTree.Create(AStream: TStream);
begin
  inherited Create(TCnSliceNode);
  FScaner := TScaner.Create(AStream, nil, cdmNone);
end;

destructor TCnCompDirectiveTree.Destroy;
begin
  FScaner.Free;
  inherited;
end;

function TCnCompDirectiveTree.GetItems(
  AbsoluteIndex: Integer): TCnSliceNode;
begin
  Result := TCnSliceNode(inherited GetItems(AbsoluteIndex));
end;

procedure TCnCompDirectiveTree.ParseTree;
var
  CurNode: TCnSliceNode;
  TokenStr: string;
  CompDirectType: TPascalCompDirectiveType;

  function CalcPascalCompDirectiveType: TPascalCompDirectiveType;
  var
    I: Integer;
  begin
    for I := Low(ACnPasCompDirectiveTokenStr) to High(ACnPasCompDirectiveTokenStr) do
    begin
      if Pos(ACnPasCompDirectiveTokenStr[I], TokenStr) = 1 then
      begin
        Result := ACnPasCompDirectiveTypes[I];
        Exit;
      end;
    end;
    Result := cdtUnknown;
  end;

  procedure PutNormalCodeToNode;
  var
    Blank: string;
  begin
    if CurNode.NormalCodeStream = nil then
      CurNode.NormalCodeStream := TMemoryStream.Create;

    if FScaner.BlankStringLength > 0 then
    begin
      Blank := FScaner.BlankString;
      CurNode.NormalCodeStream.Write((PChar(Blank))^, FScaner.BlankStringLength);
    end;
    CurNode.NormalCodeStream.Write(FScaner.TokenPtr^, FScaner.TokenStringLength);
  end;

  procedure PutCompDirectiveToNode;
  var
    Blank: string;
  begin
    if CurNode.CompDirectiveStream = nil then
      CurNode.CompDirectiveStream := TMemoryStream.Create;

    if FScaner.BlankStringLength > 0 then
    begin
      Blank := FScaner.BlankString;
      CurNode.CompDirectiveStream.Write((PChar(Blank))^, FScaner.BlankStringLength);
    end;
    CurNode.CompDirectiveStream.Write(FScaner.TokenPtr^, FScaner.TokenStringLength);
  end;

begin
  Clear;
  CurNode := nil;
  if FScaner.Token <> tokEOF then
    CurNode := TCnSliceNode(AddChildFirst(Root));

  while FScaner.Token <> tokEOF do
  begin
    if FScaner.Token = tokCompDirective then
    begin
      TokenStr := UpperCase(FScaner.TokenString);
      CompDirectType := CalcPascalCompDirectiveType;

      case CompDirectType of
        cdtIf, cdtIfDef, cdtIfNDef:
          begin
            // ��һ�㲢�ѱ�����ָ������ȥ
            CurNode := TCnSliceNode(AddChild(CurNode));
            PutCompDirectiveToNode;
          end;
        cdtElse:
          begin
            // ͬ�����ɸ��µĲ��ѱ�����ָ������ȥ
            CurNode := TCnSliceNode(AddChild(CurNode.Parent));
            PutCompDirectiveToNode;
          end;
        cdtIfEnd, cdtEndIf:
          begin
            // ��һ�㲢�ѱ�����ָ������ȥ
            if CurNode.Parent <> nil then
            begin
              CurNode := TCnSliceNode(Add(CurNode.Parent));
              PutCompDirectiveToNode;
            end;
          end;
      else
        // As other token
        PutNormalCodeToNode;
      end;
    end
    else
      PutNormalCodeToNode;

    FScaner.NextToken;
  end;
end;

end.
