format PE console 4.0
 
include 'win32a.inc'
start:  cinvoke printf,  req, 41h   ; ????? ?? ????? 
    cinvoke scanf, tpt, A       ; ???? A
    cinvoke printf,  req, 42h   ; ????? ?? ????? 
    cinvoke scanf, tpt, B       ; ???? B
    mov eax,[A]
    add eax,[B]
    cinvoke printf, tpo, eax
    invoke  sleep, 5000     ; 5 sec. delay
; ?????
gtfo:   invoke  exit, 0
req db  'Enter %c:',0
tpo db  'A + B = '
tpt db  '%d',0
A   dd  ?
B   dd  ?
; import data in the same section
 data import
 
 library msvcrt,'MSVCRT.DLL',\
    kernel32,'KERNEL32.DLL'
 
 import kernel32,\
    sleep,'Sleep'
 
 import msvcrt,\
    puts,'puts',\
    scanf,'scanf',\
        printf,'printf',\ 
    exit,'exit'
end data
