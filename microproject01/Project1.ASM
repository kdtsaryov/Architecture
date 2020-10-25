format PE console
entry start

include 'win32a.inc'
;--------------------------------------------------------------------------
;       Tsaryov Kirill group 193
;
;       First substring with length 4 with condition
;       "each symbol is less than previous"
;--------------------------------------------------------------------------
; Data section
section '.data' data readable writable
        msg      db     'Input a string: ', 10, 0
        strScan  db     '%s', 0
        string1  rb     256    ; Input string
        string2  rb     256    ; Shifted string
        string3  rb     256    ; Output substring
        len      dd     0
        nfStr    db     'Substring not found', 10, 0
        fStr     db     'Substring found: ', 10, 0

;--------------------------------------------------------------------------
; Main program
section '.code' code readable executable
start:
    invoke printf, msg
    ; Scanning a string
    invoke scanf, strScan, string1

    ; Finding length of the string
    stdcall strlen
    ; If length < 5, then there is no substring
    cmp    [len], 5
    jl     NotFound

    ; Copying string1 to string2 with left shift by 1
    cld
    sub    [len], 1
    mov    ecx, [len]
    mov    esi, string1
    ; Skip 1st symbol
    movsb
    mov    edi, string2
Loop1:
    movsb
    loop   Loop1

    ; Comparing strings 1 and 2 by symbols
    mov    ecx, [len]
    ; Current number of symbols in substring
    xor    eax, eax
    ; Current position of comparison
    xor    ebx, ebx
    mov    esi, string2
    mov    edi, string1
    cld
Loop2:
    inc    ebx
    ; Comparing symbols
    cmpsb
    ; If condition is true
    jl     Tr
    ; Else
    jmp    Fls
Tr:
    ; Increase current number of symbols in substring
    inc    eax
    jmp    EndL
Fls:
    ; Undo current number of symbols in substring
    xor    eax, eax
    jmp    EndL
EndL:
    cmp    eax, 4
    je     Found
    loop   Loop2
    jmp    NotFound

Found:
    invoke printf, fStr

    cmp    ebx, 4
    jne    Not4

    ; If  the last position of comparison is 4
    ; Save the substring
    cld
    mov    esi, string2
    mov    edi, string3
    mov    ecx, ebx
Loop0:
    movsb
    loop   Loop0
    jmp    EndF

; Else
Not4:
    ; Skip symbols before substring
    cld
    mov    esi, string2
    sub    ebx, 4
    mov    ecx, ebx
Loop3:
    movsb
    loop   Loop3
    ; Save the substring
    mov    edi, string3
    mov    ecx, 4
Loop4:
    movsb
    loop   Loop4
    jmp    EndF

EndF:
    invoke printf, string3
    jmp    Fin

NotFound:
    invoke printf, nfStr
    jmp    Fin

Fin:
    invoke getch
    invoke ExitProcess, 0

;--------------------------------------------------------------------------
; Strlen procedure (include zero symbol)
strlen:
    mov     edi, string1
    mov     ecx, -1      ; ecx must be < 0
    xor     al, al       ; tail symbol is zero
    cld                  ; direction from begin to end
    repne   scasb        ; while(string[i] != al) {i++; ecx--;}
    neg     ecx
    sub     ecx, 2       ; ecx = length(string)
    mov     [len], ecx
    ret

;--------------------------------------------------------------------------
; Including External Api
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll'

include 'api\kernel32.inc'

    import kernel,\
           ExitProcess, 'ExitProcess'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'