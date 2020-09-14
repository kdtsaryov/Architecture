format          PE console 4.0                                          ; Консольное приложение.
entry           start                                                   ; Точка входа
include         'C:\Users\79169\Desktop\FASM\INCLUDE\win32a.inc'                                  ; Делаем стандартное включение описателей.
 
;--- секция кода ---
 
section         '.text' code readable executable
 
  start:
        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        mov     [stdout], eax
        invoke  GetStdHandle, STD_INPUT_HANDLE
        mov     [stdin], eax
        invoke  WriteConsole,[stdout],cMsg,13,NULL,NULL
        invoke  ReadConsole,[stdin],lpBuffer,1,lpCharsRead,NULL
  exit:
        invoke  ExitProcess, 0
 
;--- секция данных ---
 
section         '.data' data readable writeable
 
cMsg            db      'Hello, world!'                                 ; Текстовая строка.
lpBuffer        db      10 dup (0)
lpCharsRead     dd      ?                                               ; Количество фактически считанных символов
stdin           dd      ?
stdout          dd      ?
 
;--- секция (таблица) импорта ---
 
section         '.idata' import data readable writeable
 
library         kernel32,'KERNEL32.DLL'
 
import          kernel32,\ 
                GetStdHandle,'GetStdHandle',\ 
                WriteConsole,'WriteConsoleA',\
                ReadConsole,'ReadConsoleA',\
                ExitProcess,'ExitProcess'
