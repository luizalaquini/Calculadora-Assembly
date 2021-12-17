segment code

..start:
    ; iniciar os registros de segmento DS e SS e o ponteiro de pilha SP
    mov ax,data
    mov ds,ax
    mov ax,stack
    mov ss,ax
    mov sp,stacktop

    ;Ler os números (dois números de 4 dígitos com sinal)
    mov dx, mensagemPrimeiroNum
    mov ah, 9
    int 21h
    mov bx,num1
    call lenumero
    mov dx, mensagemSegundoNum
    mov ah, 9
    int 21h
    mov bx,num2
    call lenumero

    ;Realizar operações (soma(+ 2B), subtração(- 2D), multiplicação(* 2A) e divisão(/ 2F))
    mov dx, mensagemOperacao
    mov ah, 9
    int 21h

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

        ;Duas possibilidades de não overflow. DX = 0000 ou DX = FFFF

        cmp dx, 0x0000
        je semOverflow
        cmp dx, 0xFFFF
        je semOverflow
        jmp overflow ; Caso tenha overflow

        semOverflow:
        mov word [result], ax
        mov word [result+2], dx
        jmp imprimir
        
    divi:
        mov dx, 0x0000
        mov ax, word [num1]
        cmp ax,0
        jge positivo
        mov dx, 0xFFFF
        positivo:
        mov bx, word [num2]
        cmp bx, 0
        je erroDivisaoZero
        idiv bx

        mov word [result], ax
        jmp imprimir


    ; Imprimir resultado em decimal
    imprimir:
    MOV 	DI,finalImpressao
    MOV     DX,word [result]
    CALL 	bin2ascii	

    MOV     DX, mensagemResultado
    MOV     AH, 9
    INT     21h	

    MOV 	DX,finalImpressao
    MOV 	AH,9h
    INT 	21h   

    ; Terminar o programa e voltar para o sistema operacional
    mov ah,4ch
    int 21h 



    ; FUNÇÕES AUXILIARES
    overflow:
        ;Imprimir a mensagem de overflow
        MOV DX, mensagemOverflow
        MOV AH, 9
        INT 21h

        ;finaliza o programa
        mov ah,4ch
        int 21h
    
    erroDivisaoZero:
        ;Imprimir a mensagem de erro
        MOV DX, mensagemDivisaoZero
        MOV AH, 9
        INT 21h

        ;finaliza o programa
        mov ah,4ch
        int 21h
    
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

        ;Verificar se o número é negativo
        cmp     DX,0
        jge     numNaoNegativo

        ;Se for negativo, coloca '-' em [DI]
        MOV     byte [DI],0x2D
        imul    DX,-1

        numNaoNegativo: 

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
            MOV 	byte [DI+1],DL
            jmp finishBin2Ascii
        Des:
            MOV 	AX,DX ;0001
            MOV		BL,10
            div		BL
            ADD		AH,0x30
            ADD		AL,0x30
            MOV 	byte [DI+1],AL
            MOV 	byte [DI+2],AH
            jmp finishBin2Ascii
        Cen:		
            MOV 	AX,DX
            MOV		BL,100
            DIV		BL
            ADD		AL,0x30
            MOV 	byte [DI+1],AL
            MOV 	AL,AH
            AND		AX,0x00FF
            MOV		BL,10
            DIV		BL
            ADD		AH,0x30
            ADD		AL,0x30
            MOV 	byte [DI+2],AL		
            MOV 	byte [DI+3],AH
            jmp finishBin2Ascii
        Mil:		
            MOV 	AX,DX
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
            jmp finishBin2Ascii
        Dezmil:
            MOV 	AX,DX
            MOV     DX,0
            MOV		BX,10000
            DIV		BX
            ADD		AL,0x30
            MOV 	byte [DI+1],AL
            MOV		AX,DX		
            MOV     DX,0
            MOV		BX,1000
            DIV		BX
            ADD		AL,0x30
            MOV 	byte [DI+2],AL
            MOV 	AX,DX
            MOV		BL,100
            DIV		BL
            ADD		AL,0x30
            MOV 	byte [DI+3],AL		
            MOV 	AL,AH
            AND     AX,0x00FF
            MOV		BL,10
            DIV		BL
            ADD		AH,0x30
            ADD		AL,0x30
            MOV 	byte [DI+4],AL		
            MOV 	byte [DI+5],AH
            jmp finishBin2Ascii

    finishBin2Ascii:
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
    result: resb 4 
    finalImpressao: resb 5 
                    db 13,10,'$'
    mensagemOverflow: db 13,10,'Overflow! A operacao ultrapassou o limite de 4 bytes',13,10,'$'
    mensagemPrimeiroNum: db 13,10,'Insira Primeiro Numero: ',13,10,'$'
    mensagemSegundoNum: db 13,10,'Insira Segundo Numero: ',13,10,'$'
    mensagemOperacao: db 13,10,'Insira sinal da operacao: ',13,10,'$'
    mensagemResultado: db 13,10,'Resultado: ','$'
    mensagemDivisaoZero: db 13,10,'Erro: Divisao por 0', 13,10,'$'

segment stack stack
    resb 256
stacktop: