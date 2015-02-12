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

unit CnFormatterIntf;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ������ʽ������ӿ�
* ��Ԫ���ߣ�CnPack������
* ��    ע���õ�Ԫʵ�ִ����ʽ���Ķ���ӿ�
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ�not test yet
* �� �� ����not test hell
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.02.11 V1.0
*               ������Ԫ��
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Windows;

const
  // ���� IFDEF ELSE ENDIF ʱ�Ĵ���ģʽ
  CN_RULE_DIRECTIVE_MODE_ASCOMMENT  = 1;
  {* ����ע�ʹ���}
  CN_RULE_DIRECTIVE_MODE_ONLYFIRST  = 2;
  {* ֻ�����һ����}
  CN_RULE_DIRECTIVE_MODE_DEFAULT    = CN_RULE_DIRECTIVE_MODE_ASCOMMENT;

  // �ؼ��ִ�Сд����
  CN_RULE_KEYWORD_STYLE_UPPER       = 1;
  {* ȫ��д}
  CN_RULE_KEYWORD_STYLE_LOWER       = 2;
  {* ȫСд}
  CN_RULE_KEYWORD_STYLE_UPPERFIRST  = 3;
  {* ����ĸ��д}
  CN_RULE_KEYWORD_STYLE_DEFAULT     = CN_RULE_KEYWORD_STYLE_LOWER;

  // Ĭ�������ո���
  CN_RULE_TABSPACE_DEFAULT          = 2;

  // ˫Ŀ�����ǰ��Ĭ�Ͽո���
  CN_RULE_SPACE_BEFORE_OPERATOR      = 1;

  // ˫Ŀ��������Ĭ�Ͽո���
  CN_RULE_SPACE_AFTER_OPERATOR       = 1;

  // ���ָ������Ĭ������
  CN_RULE_SPACE_BEFORE_ASM           = 8;

  // ���ָ�� Tab ���
  CN_RULE_SPACE_TAB_ASM              = 8;

  // Ĭ�ϻ��г����˿��
  CN_RULE_LINE_WRAP_WIDTH            = 80;

  // ���ⲿָ������ʼԪ������
  CN_START_UNKNOWN_ALL               = 0;
  CN_START_USES                      = 1;
  CN_START_CONST                     = 2;
  CN_START_TYPE                      = 3;
  CN_START_VAR                       = 4;
  CN_START_PROC                      = 5;
  CN_START_STATEMENT                 = 6;

type
  ICnPascalFormatterIntf = interface
    ['{0CC0F874-227A-4516-9D17-6331EA86CBCA}']
    procedure SetPascalFormatRule(DirectiveMode: DWORD; KeywordStyle: DWORD; TabSpace:
      DWORD; SpaceBeforeOperator: DWORD; SpaceAfterOperator: DWORD; SpaceBeforeAsm:
      DWORD; SpaceTabAsm: DWORD; LineWrapWidth: DWORD; UsesSingleLine: LongBool);
    {* ���ø�ʽ��ѡ��}

    function FormatOnePascalUnit(Input: PAnsiChar; Len: DWORD): PAnsiChar;
    {* ��ʽ��һ���� Pascal �ļ����ݣ������� AnsiString ��ʽ���롣
       ���ؽ���洢�� AnsiString �ַ����ݵ�ָ�룬����������ͷ�}

    function FormatPascalBlock(StartType: DWORD; StartIndent: DWORD;
      Input: PAnsiChar; Len: DWORD): PAnsiChar;
    {* ��ʽ��һ����롣��Ҫָ����ʼ���������Լ���ʼ������
       ������ AnsiString ��ʽ���룬���ؽ���洢�� AnsiString �ַ����ݵ�ָ�룬
       ����������ͷ�}
  end;

  TCnGetFormatterProvider = function: ICnPascalFormatterIntf; stdcall;
  {* DLL �еĺ�������}

implementation

end.
