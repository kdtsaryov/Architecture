format PE console
entry start

include 'win32a.inc'
;--------------------------------------------------------------------------
;  Царёв Кирилл БПИ193
;  Вариант 4
;  Массив B из элементов B[i] = 1, если A[i]>0;
;                              -1, если A[i]<0;
;                               0, если A[i]=0.
;--------------------------------------------------------------------------
section '.data' data readable writable

        strArrSize   db 'N? ', 0
        strIncorSize db 'Incorrect size of array = %d', 10, 0
        strArrElemI  db 'A[%d]? ', 0
        strScanInt   db '%d', 0
        strArrAElemOut  db 'A[%d] = %d', 10, 0
        strArrBElemOut  db 'B[%d] = %d', 10, 0
        strLine db '-----------', 10, 0

        arr_size      dd 0
        i             dd ?
        tmpA          dd ?
        tmpStackA     dd ?
        tmpB          dd ?
        tmpStackB     dd ?
        arrA          rd 1000
        arrB          rd 1000
        one           dd 1
        mone          dd -1
        zero          dd 0
;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) array input
        call ArrayInput
        push strLine
        call [printf]
; 2) array B creating and output
        call NewArrayOut
        push strLine
        call [printf]
; 3) array A output
        call ArrayOut
finish:
        call [getch]

        push 0
        call [ExitProcess]
;--------------------------------------------------------------------------
ArrayInput:
        push strArrSize
        call [printf]
        add esp, 4

        push arr_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [arr_size]
        cmp eax, 0
        jg  getArray
; fail size
        push [arr_size]
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]
; else continue...
getArray:
        xor ecx, ecx             ; ecx = 0
        mov ebx, arrA            ; ebx = &arrA
getArrLoop:
        mov [tmpA], ebx
        cmp ecx, [arr_size]
        jge endInputArray       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strArrElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmpA]
        add ebx, 4
        jmp getArrLoop
endInputArray:
        ret
;--------------------------------------------------------------------------
ArrayOut:
        mov [tmpStackA], esp
        xor ecx, ecx             ; ecx = 0
        mov ebx, arrA            ; ebx = &arrA
putArrLoop:
        mov [tmpA], ebx
        cmp ecx, [arr_size]
        je endOutputArray        ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strArrAElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmpA]
        add ebx, 4
        jmp putArrLoop
endOutputArray:
        mov esp, [tmpStackA]
        ret
;----------------------------------------------------------------------------
NewArrayOut:
        mov [tmpStackA], esp
        xor ecx, ecx             ; ecx = 0
        mov ebx, arrA            ; ebx = &arrA
putArrLoopn:
        mov [tmpA], ebx
        cmp ecx, [arr_size]
        je endOutputArrayn       ; to end of loop
        mov [i], ecx

        ; comparing to zero
        cmp dword [ebx], 0
        jg Gr
        cmp dword [ebx], 0
        jl Ls

        push [zero]
        push ecx
        push strArrBElemOut
        call [printf]
        jmp fin
     Gr:
        push [one]
        push ecx
        push strArrBElemOut
        call [printf]
        jmp fin
     Ls:
        push [mone]
        push ecx
        push strArrBElemOut
        call [printf]
        jmp fin

     fin:
        mov ecx, [i]
        inc ecx
        mov ebx, [tmpA]
        add ebx, 4
        jmp putArrLoopn
endOutputArrayn:
        mov esp, [tmpStackA]
        ret
;----------------------------------------------------------------------------
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'