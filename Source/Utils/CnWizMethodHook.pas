{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2014 CnPack ������                       }
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

unit CnWizMethodHook;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����󷽷��ҽӵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ�����ҽ� IDE �ڲ���ķ���
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2014.08.28
*               ����DDetoursʵ�ֵ���
*           2003.10.27
*               ʵ�����Ա༭�������ҽӺ��ļ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes{$IFDEF USE_DDETOURS_HOOK}, DDetours{$ENDIF};

type
{$IFNDEF USE_DDETOURS_HOOK}
  PLongJump = ^TLongJump;
  TLongJump = packed record
    JmpOp: Byte;        // Jmp �����תָ�Ϊ $E9
    Addr: Pointer;      // ��ת������Ե�ַ
  end;
{$ENDIF}

  TCnMethodHook = class
  {* ��̬�� dynamic �����ҽ��࣬���ڹҽ����о�̬����������Ϊ dynamic �Ķ�̬������
     ����ͨ���޸�ԭ�������ǰ 5�ֽڣ���Ϊ��תָ����ʵ�ַ����ҽӲ�������ʹ��ʱ
     �뱣֤ԭ������ִ���������� 5�ֽڣ�������ܻ�������غ����}
  private
    FHooked: Boolean;
    FOldMethod: Pointer;
    FNewMethod: Pointer;
{$IFDEF USE_DDETOURS_HOOK}
    FTrampoline: Pointer;
{$ELSE}
    FSaveData: TLongJump;
{$ENDIF}
  public
    constructor Create(const AOldMethod, ANewMethod: Pointer);
    {* ������������Ϊԭ������ַ���·�����ַ��ע�������ר�Ұ���ʹ�ã�ԭ������ַ
       ���� GetBplMethodAddress ת������ʵ��ַ�����������ú���Զ��ҽӴ���ķ�����
     |<PRE>
       �������Ҫ�ҽ� TTest.Abc(const A: Integer) ���������Զ����·���Ϊ��
       procedure MyAbc(ASelf: TTest; const A: Integer);
       �˴� MyAbc Ϊ��ͨ���̣���Ϊ������������һ������Ϊ Self���ʴ˴�����һ��
       ASelf: TTest ������֮��ԣ�ʵ�ִ����п��԰�����������ʵ�������ʡ�
     |</PRE>}
    destructor Destroy; override;
    {* ����������ȡ���ҽ�}
    
    procedure HookMethod; virtual;
    {* ���¹ҽӣ������Ҫִ��ԭ���̣���ʹ���� UnhookMethod������ִ����ɺ����¹ҽ�}
    procedure UnhookMethod; virtual;
    {* ȡ���ҽӣ������Ҫִ��ԭ���̣�����ʹ�� UnhookMethod���ٵ���ԭ���̣���������}
{$IFDEF USE_DDETOURS_HOOK}
    property Trampoline: Pointer read FTrampoline;
{$ENDIF}
  end;

function GetBplMethodAddress(Method: Pointer): Pointer;
{* ������ BPL ��ʵ�ʵķ�����ַ����ר�Ұ����� @TPersistent.Assign ���ص���ʵ��
   һ�� Jmp ��ת��ַ���ú������Է����� BPL �з�������ʵ��ַ��}

implementation

resourcestring
  SMemoryWriteError = 'Error writing method memory (%s).';

const
  csJmpCode = $E9;              // �����תָ�������

// ������ BPL ��ʵ�ʵķ�����ַ
function GetBplMethodAddress(Method: Pointer): Pointer;
{$IFNDEF USE_DDETOURS_HOOK}
type
  PJmpCode = ^TJmpCode;
  TJmpCode = packed record
    Code: Word;                 // �����תָ����Ϊ $25FF
    Addr: ^Pointer;             // ��תָ���ַ��ָ�򱣴�Ŀ���ַ��ָ��
  end;
const
  csJmp32Code = $25FF;
{$ENDIF}
begin
{$IFDEF USE_DDETOURS_HOOK}
  Result := Method;
{$ELSE}
  if PJmpCode(Method)^.Code = csJmp32Code then
    Result := PJmpCode(Method)^.Addr^
  else
    Result := Method;
{$ENDIF}
end;

//==============================================================================
// ��̬�� dynamic �����ҽ���
//==============================================================================

{ TCnMethodHook }

constructor TCnMethodHook.Create(const AOldMethod, ANewMethod: Pointer);
begin
  inherited Create;
  FHooked := False;
  FOldMethod := AOldMethod;
  FNewMethod := ANewMethod;
{$IFDEF USE_DDETOURS_HOOK}
  FTrampoline := nil;
{$ENDIF}
  HookMethod;
end;

destructor TCnMethodHook.Destroy;
begin
  UnHookMethod;
  inherited;
end;

procedure TCnMethodHook.HookMethod;
{$IFNDEF USE_DDETOURS_HOOK}
var
  DummyProtection: DWORD;
  OldProtection: DWORD;
{$ENDIF}
begin
{$IFDEF USE_DDETOURS_HOOK}
  FTrampoline := DDetours.InterceptCreate(FOldMethod, FNewMethod);
  if not Assigned(FTrampoline) then
    raise Exception.Create('Failed to install method hook');
{$ELSE}
  if FHooked then Exit;
  
  // ���ô���ҳд����Ȩ��
  if not VirtualProtect(FOldMethod, SizeOf(TLongJump), PAGE_EXECUTE_READWRITE, @OldProtection) then
    raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

  try
    // ����ԭ���Ĵ���
    FSaveData := PLongJump(FOldMethod)^;

    // ����תָ���滻ԭ������ǰ 5 �ֽڴ���
    PLongJump(FOldMethod)^.JmpOp := csJmpCode;
    PLongJump(FOldMethod)^.Addr := Pointer(Integer(FNewMethod) -
      Integer(FOldMethod) - SizeOf(TLongJump)); // ʹ�� 32 λ��Ե�ַ

    // ����ദ������ָ�����ͬ��
    FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TLongJump));
  finally
    // �ָ�����ҳ����Ȩ��
    if not VirtualProtect(FOldMethod, SizeOf(TLongJump), OldProtection, @DummyProtection) then
      raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
  end;
{$ENDIF}
  FHooked := True;
end;

procedure TCnMethodHook.UnhookMethod;
{$IFNDEF USE_DDETOURS_HOOK}
var
  DummyProtection: DWORD;
  OldProtection: DWORD;
{$ENDIF}
begin
{$IFDEF USE_DDETOURS_HOOK}
  DDetours.InterceptRemove(FTrampoline);
  FTrampoline := nil;
{$ELSE}
  if not FHooked then Exit;
  
  // ���ô���ҳд����Ȩ��
  if not VirtualProtect(FOldMethod, SizeOf(TLongJump), PAGE_READWRITE, @OldProtection) then
    raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

  try
    // �ָ�ԭ���Ĵ���
    PLongJump(FOldMethod)^ := FSaveData;
  finally
    // �ָ�����ҳ����Ȩ��
    if not VirtualProtect(FOldMethod, SizeOf(TLongJump), OldProtection, @DummyProtection) then
      raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
  end;

  // ����ദ������ָ�����ͬ��
  FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TLongJump));
{$ENDIF}

  FHooked := False;
end;

end.
