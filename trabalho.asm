segment code

..start:
    ; iniciar os registros de segmento DS e SS e o ponteiro de pilha SP
    mov ax,data
    mov ds,ax
    mov ax,stack
    mov ss,ax
    mov sp,stacktop

    ;Ler os números (dois números de 4 dígitos com sinal)
    mov bx,num1
    call lenumero
    mov bx,num2
    call lenumero
    ;Realizar operações (soma(+ 2B), subtração(- 2D), multiplicação(* 2A) e divisão(/ 2F))
    ;Lê qual o operador
    mov ah,1
    int 21h
    ; Verifica se o ascii passado é a soma
    cmp al, 0x2B
    je soma
    ; Verifica se o ascii passado é a subtração
    cmp al, 0x2D
    je subt
    ; Verifica se o ascii passado é a Multiplicação
    cmp al, 0x2A
    je mult
    ; Verifica se o ascii passado é a divisão
    cmp al, 0x2F
    je divi

    soma:
        mov ax, word [num1]
        mov bx, word [num2]
        add ax, bx

        mov word [result], ax
        jmp imprimir

    subt:
        mov ax, word [num1]
        mov bx, word [num2]
        imul bx, -1
        add ax, bx

        mov word [result], ax
        jmp imprimir
    
    mult:
        mov ax, word [num1]
        mov bx, word [num2]
        imul bx

        mov word [result], ax
        mov word [result+2], dx
        jmp imprimir
        
    divi:
        mov dx, 0
        mov ax, word [num1]
        mov bx, word [num2]
        idiv bx

        mov word [result], ax
        jmp imprimir


    imprimir: ;Imprimir resultado em decimal
    MOV 	DI,finalImpressao
    MOV     AX,word [result]
    MOV     DX,word [result+2]
    CALL 	bin2ascii		

    MOV 	DX,finalImpressao
    MOV 	AH,9h
    INT 	21h    


    ; Terminar o programa e voltar para o sistema operacional
    mov ah,4ch
    int 21h



    ; FUNÇÕES AUXILIARES
    
    lenumero:
        PUSHF
        PUSH 	AX
        PUSH 	BX
        PUSH	CX
        PUSH 	DX
        
        mov dx, 0
        mov cx, 1
        
        mov ah,1
        int 21h
        ; Verifica se o ascii passado é o sinal
        cmp al, 0x2D
        jne semsinal
        ; al tem o valor ascii do digito passado
        mov cx, -1

        mov ah,1
        int 21h
        ; Verifica se o ascii passado é o enter 0D
        cmp al, 0x0D
        je terminoLenumero
        semsinal:
        ; al tem o valor ascii do digito passado
        add al, -0x30 ; Convertendo de ASCII para decimal
        mov ah, 00
        imul ax, cx
        add dx, ax

        mov ah,1
        int 21h
        ; Verifica se o ascii passado é o enter 0D
        cmp al, 0x0D
        je terminoLenumero
        ; al tem o valor ascii do digito passado
        add al, -0x30 ; Convertendo de ASCII para decimal
        mov ah, 00
        imul ax, cx
        imul dx, 10
        add dx, ax

        mov ah,1
        int 21h
        ; Verifica se o ascii passado é o enter 0D
        cmp al, 0x0D
        je terminoLenumero
        ; al tem o valor ascii do digito passado
        add al, -0x30 ; Convertendo de ASCII para decimal
        mov ah, 00
        imul ax, cx
        imul dx, 10
        add dx, ax

        mov ah,1
        int 21h
        ; Verifica se o ascii passado é o enter 0D
        cmp al, 0x0D
        je terminoLenumero
        ; al tem o valor ascii do digito passado
        add al, -0x30 ; Convertendo de ASCII para decimal
        mov ah, 00
        imul ax, cx
        imul dx, 10
        add dx, ax

        terminoLenumero:  

        mov word [bx], dx
        
        ; Upgrade the context
        POP 	DX
        POP 	CX
        POP		BX
        POP 	AX
        POPF
        RET

    bin2ascii:
        PUSHF
        PUSH 	AX
        PUSH 	BX
        PUSH	CX
        PUSH 	DX          

        ;Verificar se o número é maior do que 0x7FFF
        CMP		DX,0
        JNE		Uni

        ;Verificar se o número é negativo
        
        CMP		DX,10
        JB		Uni
        CMP		DX,100 
        JB		Des
        CMP		DX,1000
        JB		Cen
        CMP		DX,10000
        JB		Mil
        JMP		Dezmil

        Uni:	
            ADD		DX,0x0030
            MOV 	byte [DI],DL
            RET
        Des:
            MOV 	AX,DX ;0001
            MOV		BL,10
            div		BL
            ADD		AH,0x30
            ADD		AL,0x30
            MOV 	byte [DI],AL
            MOV 	byte [DI+1],AH
            RET
        Cen:		
            MOV 	AX,DX
            MOV		BL,100
            DIV		BL
            ADD		AL,0x30
            MOV 	byte [DI],AL
            MOV 	AL,AH
            AND		AX,0x00FF
            MOV		BL,10
            DIV		BL
            ADD		AH,0x30
            ADD		AL,0x30
            MOV 	byte [DI+1],AL		
            MOV 	byte [DI+2],AH
            RET
        Mil:		
            MOV 	AX,DX
            MOV     DX,0
            MOV		BX,1000
            DIV		BX
            ADD		AL,0x30
            MOV 	byte [DI],AL
            MOV 	AX,DX
            MOV		BL,100
            DIV		BL
            ADD		AL,0x30
            MOV 	byte [DI+1],AL		
            MOV 	AL,AH
            AND     AX,0x00FF
            MOV		BL,10
            DIV		BL
            ADD		AH,0x30
            ADD		AL,0x30
            MOV 	byte [DI+2],AL		
            MOV 	byte [DI+3],AH
            RET
        Dezmil:
            MOV 	AX,DX
            MOV     DX,0
            MOV		BX,10000
            DIV		BX
            ADD		AL,0x30
            MOV 	byte [DI],AL
            MOV		AX,DX		
            MOV     DX,0
            MOV		BX,1000
            DIV		BX
            ADD		AL,0x30
            MOV 	byte [DI+1],AL
            MOV 	AX,DX
            MOV		BL,100
            DIV		BL
            ADD		AL,0x30
            MOV 	byte [DI+2],AL		
            MOV 	AL,AH
            AND     AX,0x00FF
            MOV		BL,10
            DIV		BL
            ADD		AH,0x30
            ADD		AL,0x30
            MOV 	byte [DI+3],AL		
            MOV 	byte [DI+4],AH
            RET


        ; Upgrade the context
        POP 	DX
        POP 	CX
        POP		BX
        POP 	AX
        POPF
        RET          
                            
                            

segment data
    num1: resb 4
    num2: resb 4
    result: resb 8 
    finalImpressao: resb 9 
                    db 13,10,'$'

segment stack stack
    resb 256
stacktop: