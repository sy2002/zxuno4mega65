ZXUNOADDR      equ 0fc3bh

;Macros
MACRO PrintNibble
               cp 10
               jr nc,@EsLetra
               add a,'0'
               call PutChar
               jr @Sigue
@EsLetra        sub 10
               add a,'A'
               call PutChar
@Sigue
ENDM

               ;org 32768
               org 0

;PROC
Main
               di
               xor a
               out (254),a
               ld hl,Pantalla
               ld de,16384
               ld bc,6912
               ldir

BucPrincipal
               ;1 2 3 4 5
               ld bc,0f7feh
               ld a,16
               ld (Fila),a
               ld a,1
               ld (Columna),a
               ld hl,Sem1
               call Display

               ;Q W E R T
               ld bc,0fbfeh
               ld a,17
               ld (Fila),a
               ld a,1
               ld (Columna),a
               ld hl,Sem2
               call Display

               ;A S D F G
               ld bc,0fdfeh
               ld a,18
               ld (Fila),a
               ld a,1
               ld (Columna),a
               ld hl,Sem3
               call Display

               ;CS Z X C V
               ld bc,0fefeh
               ld a,19
               ld (Fila),a
               ld a,1
               ld (Columna),a
               ld hl,Sem4
               call Display

               ;6 7 8 9 0
               ld bc,0effeh
               ld a,16
               ld (Fila),a
               ld a,17
               ld (Columna),a
               ld hl,Sem5
               call Display

               ;Y U I O P
               ld bc,0dffeh
               ld a,17
               ld (Fila),a
               ld a,17
               ld (Columna),a
               ld hl,Sem6
               call Display

               ;H J K L ENTER
               ld bc,0bffeh
               ld a,18
               ld (Fila),a
               ld a,17
               ld (Columna),a
               ld hl,Sem7
               call Display

               ;B N M SS SPACE
               ld bc,07ffeh
               ld a,19
               ld (Fila),a
               ld a,17
               ld (Columna),a
               ld hl,Sem8
               call Display

               ld hl,Men1
               call _Print
               ld bc,00feh
               in a,(c)
               call PrtR8Bin

               ld hl,Men2
               call _Print
               ld bc,ZXUNOADDR
               ld a,5
               out (c),a
               inc b
               in a,(c)
               bit 0,a
               jr z,NoHayTeclaPS2
               push af
               ld bc,ZXUNOADDR
               ld a,4
               out (c),a
               inc b
               in a,(c)
               call Prt8Hex
               pop af
               push af
               ; | BSY | x | x | x | ERR | RLS | EXT | PEN |
               ld hl,Blanco
               bit 1,a
               jr z,NoExtendida
               ld hl,Extendida
NoExtendida    call _Print
               pop af
               ld hl,Blanco
               bit 2,a
               jr z,NoSoltada
               ld hl,Soltada
NoSoltada      call _Print

NoHayTeclaPS2  ld bc,0effeh
               in a,(c)
               ld b,5
               ld hl,PosJoy
BucPtrJoy      rrca
               push af
               ld c,128
               jr c,NoPressJoy
               ld c,129
NoPressJoy     ld a,(hl)
               ld (Fila),a
               inc hl
               ld a,(hl)
               ld (Columna),a
               inc hl
               ld a,%01000111
               ld (Attr),a
               ld a,c
               call PutChar
               pop af
               djnz BucPtrJoy

               jp BucPrincipal
;ENDP

;PROC
Display
               ld a,255
               in a,(254)
               in a,(c)
               ld d,a
               push hl
               ld h,b
               ld l,c
               ld a,%01000110
               ld (Attr),a
               ld a,'#'
               call PutChar
               call PrtR16Hex
               ld a,':'
               call PutChar
               ld a,%01000111
               ld (Attr),a
               ld a,d
               call PrtR8Bin

               ld a,d
               ld b,5
               pop hl

BucActTec      ld e,(hl)
               inc hl
               ld d,(hl)
               inc hl

               ld c,%01000111  ;Tecla soltada
               rrca
               jr c,TeclaSoltada
               ld c,%01111000  ;Tecla pulsada

TeclaSoltada   push af
               ld a,c
               ld (de),a
               inc de
               ld (de),a
               push hl
               ld hl,31
               add hl,de
               ex de,hl
               pop hl
               ld (de),a
               inc de
               ld (de),a
               pop af
               djnz BucActTec
               ret

;ENDP


;Rutinas de soporte

;PROC
_Print
buc_print      ld a,(hl)
               or a
               ret z
               cp 22
               jr nz,no_at
               inc hl
               ld a,(hl)
               ld (Fila),a
               inc hl
               ld a,(hl)
               ld (Columna),a
               inc hl
               jr buc_print

no_at          cp 13
               jr nz,no_cr
               xor a
               ld (Columna),a
               ld a,(Fila)
               inc a
               ld (Fila),a
               inc hl
               jr buc_print

no_cr          cp 4
               jr nz,no_attr
               inc hl
               ld a,(hl)
               ld (Attr),a
               inc hl
               jr buc_print

no_attr        cp 32
               jr nc,imprimible
               ld a,32
imprimible     call PutChar
               inc hl
               jp buc_print
;ENDP

;PROC
PutChar
               push bc
               push de
               push hl
               ld hl,(Columna)
               push hl
               push af
               ld de,16384
               add hl,de
               ld a,h
               and 7
               rrca
               rrca
               rrca
               or l
               ld l,a
               ld a,248
               and h
               ld h,a
               pop af

               push hl
               ld de,15360
               cp 128
               jr c,NoJuegoAlt
               ld de,JuegoChars
               sub 128
NoJuegoAlt     ld l,a
               ld h,0
               add hl,hl
               add hl,hl
               add hl,hl
               add hl,de
               pop de

               ld b,8
print_car      ld a,(hl)
               ;sra a
               ;or (hl)
               ld (de),a
               inc hl
               inc d
               djnz print_car
               pop hl

               push hl
               ld de,22528
               ld b,h
               ld h,0
               add hl,de
               xor a
               or b
               jr z,fin_ca_attr
               ld de,32
calc_dirat     add hl,de
               djnz calc_dirat
fin_ca_attr    ld a,(Attr)
               ld (hl),a
               pop hl

               inc l
               bit 5,l
               jr z,no_inc_fila
               res 5,l
               inc h
no_inc_fila    ld (Columna),hl
               pop hl
               pop de
               pop bc
               ret
;ENDP

Prt8Hex
               push af
               and 0f0h
               rra
               rra
               rra
               rra
               PrintNibble
               pop af
               and 0fh
               PrintNibble
               ret
;ENDP


;PROC
PrtR16Hex
               ld a,h
               call Prt8Hex
               ld a,l
               call Prt8Hex
               ret
;ENDP

;PROC
PrtR8Bin
               ld b,8
BucPBin        rlca
               push af
               jr nc,EsCero
               ld a,'1'
               call PutChar
               jr SigueBin
EsCero         ld a,'0'
               call PutChar
SigueBin       pop af
               djnz BucPBin
               ret
;ENDP

;Variables
Columna        db 0
Fila           db 0
Attr           db 0

Men1           db 22,21,6,4,%01000110,"Puerto #FE: ",4,%01000111,0
Men2           db 22,22,6,4,%01000110,"Scancode: ",4,%01000111,0
Soltada        db " RLS",0
Extendida      db " EXT",0
Blanco         db "    ",0

Sem1           dw 22626,22628,22630,22632,22634
Sem2           dw 22691,22693,22695,22697,22699
Sem3           dw 22754,22756,22758,22760,22762
Sem4           dw 22819,22821,22823,22825,22827
Sem5           dw 22644,22642,22640,22638,22636
Sem6           dw 22709,22707,22705,22703,22701
Sem7           dw 22772,22770,22768,22766,22764
Sem8           dw 22837,22835,22833,22831,22829

PosJoy         db 4,29,3,26,5,26,4,27,4,25

JuegoChars     db %11111111
               db %11000011
               db %10011001
               db %10111101
               db %10111101
               db %10011001
               db %11000011
               db %11111111

               db %11111111
               db %11000011
               db %10000001
               db %10000001
               db %10000001
               db %10000001
               db %11000011
               db %11111111

Pantalla
incbin "testkeys.scr"

; end 32768

; make sure that the binary is 32K as we want to use it as a ROM for the
; "naked" machine and we want the bootloader to be able to handle it

            ORG $7FFF
 L3FFF:     defb 0
