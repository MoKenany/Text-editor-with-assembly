.model small

.data 
    intro db "Text Editor", 0dh, 0ah, "--------------------------------",0dh, 0ah,'$'
    funcs db "[F1]: Save the text to output.txt", 0dh,0ah, "[F2]: load from text from input.txt", 0dh,0ah, "[Esc]: Close the program",0dh,0ah,'--------------------------------',0dh,0ah,0dh,0ah,0dh,0ah,'$'
    buffer db 60000 dup('$')
    LineStack db 100 DUP(?)    
    StackTop db 0
    CurrentLineLen db 0
.code
         
    main proc far
        .startup
            call start ; the first message in the editor 
            InputLoop: ; A loop that listens to the keyboard
                MOV AH, 00h            
                INT 16h ;read a char
                
                CMP AL, 0Dh; is this char the Enter Key ?            
                JE EnterTrue; handle the new line
                
                CMP AL, 1Bh ; is this char the ESC key ?
                JE EscTrue
                
                CMP Al, 08h ; is this char the BackSpacy key ??
                JE BackSpaceTrue
                
                
                JMP Norm; if it's not all the above it is a a normal key
                
                EscTrue:
                .exit
                
                EnterTrue:
                    ; We should save the current line length to handle this when removing the backspace
                    MOV BL, StackTop
                    MOV BH, 0                      ; Or XOR BH, BH  
                    MOV AL, CurrentLineLen  
                    MOV LineStack[BX], AL          ;We saved Curr Len
                    
                    INC StackTop
                    mov CurrentLineLen, 0
                    
                    
                    MOV BYTE PTR [SI], 0Dh
                    INC SI
                    MOV BYTE PTR [SI], 0Ah
                    INC SI
                    ADD CX, 2 ; storing the newline in the buffer
                    
                
                    MOV AH, 02h
                    MOV DL, 0Dh
                    INT 21h
                    
                    MOV Ah, 02h
                    MOV DL, 0Ah
                    INT 21h
                    
                    JMP InputLoop
                    
                Norm:
                    MOV [SI], AL
                    INC SI
                    INC CX
                    INC CurrentLineLen 
                    
                
                    MOV AH, 02h
                    MOV DL, AL
                    INT 21h
                
                
                loop InputLoop
                
                BackSpaceTrue: 
                    CMP CX, 0
                    JE InputLoop           ; Nothing to delete
                                            
                    DEC SI
                    DEC CX
                    Mov Al, [SI]
                    CMP al, 0ah            ; Was the last char new line ??
                    JE DeleteEnter         
                    
                    
                    MOV AH, 02h
                    
                    MOV DL, 08h            ; Move cursor back
                    INT 21h
                    MOV DL, ' '            ; Space
                    INT 21h
                    MOV DL, 08h            ; Move cursor back again
                    INT 21h
                    Jmp InputLoop
                    
                DeleteEnter:
                    DEC SI                 ; Skip CR too
                    DEC CX                 ; decrease it one more time
                                    
                    DEC StackTop
                    MOV BL, StackTop
                    XOR BH, BH  ; offset
                    LEA DI, LineStack ; the stack
                    ADD DI, BX                  
                    MOV AL, [DI]                ; Pop byte from stack
                    MOV CurrentLineLen, AL
                    
                    
                    MOV AH, 03h
                    MOV BH, 0
                    INT 10h
                    
                    
                    DEC DH
                    MOV DL, CurrentLineLen      ; Column position
                    
                    MOV AH, 02h
                    MOV BH, 0
                    INT 10h
                    
                    JMP InputLoop
        
    main endp
    
    ;the intro to the program
    start proc near
        mov ah,09h
        LEA dx, intro
        int 21h
        
        LEA dx, funcs
        int 21h
        
        ret
    start endp
    ;--------------------
    ;loop that will read every pressed key from the user
    EnterPressed proc near
        MOV BYTE PTR [SI], 0Dh
        INC SI
        MOV BYTE PTR [SI], 0Ah
        INC SI
        ADD CX, 2 ; storing the newline in the buffer
    
    
        MOV AH, 02h
        MOV DL, 0Dh
        INT 21h
        
        MOV Ah, 02h
        MOV DL, 0Ah
        INT 21h
        
        JMP InputLoop
        
        Ret
    EnterPressed endp
    ;--------------------
end main