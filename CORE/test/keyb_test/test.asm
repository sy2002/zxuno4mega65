; Test program to debug the keyboard problem on zxuno4mega65

ZXUNOADDR       EQU     0xFC3B
ZXUNODATA       EQU     0xFD3B
SCANDBLCTRL     EQU     0x0B

BORDERCOL       EQU     0xFE

                ORG     0x0000
                DI

                ; set speed to 28 MHz
;                LD      BC, ZXUNOADDR
;                LD      A, SCANDBLCTRL  
;                OUT     (C), A
;                INC     B
;                IN      A, (C)
;                OR      0xC0            ; set to 28 MHz                
;                OUT     (C), A

                ; wait for any key to be pressed in row 0xFB of the matrix,
                ; that means Q, W, E, R or T and then activate the color
                ; cycling border
                LD      BC, 0xFBFE
WAITFORKEY      IN      A, (C)
                AND     0x0F
                CP      0x0F            ; 0x0F = no key pressed 
                JR      Z, WAITFORKEY

BORDERCYCLER    XOR     A
                LD      C, A

                ; color cycling on the border
_BORDERCYCLER   LD      A, C
                OUT     (BORDERCOL), A
                INC     A
                AND     7
                LD      C, A

                LD      A, 10
                LD      B, 255
_BC_DELAY       DJNZ    _BC_DELAY
                DEC     A
                JP      Z, _BC_DELAY
                JR      _BORDERCYCLER

                END
