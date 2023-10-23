; ****************************************************************************
; MiSTer2MEGA65 (M2M) QNICE ROM
;
; Modified version of io_library.asm:
; Jumps to QMON$SOFTSTART on CTRL+E instead of QMON$COLDSTART
;
; This solution is not (Q)NICE - so with QNICE V1.7 we should find a more
; elegant solution that works without QNICE Monitor code hacking.
;
; done by sy2002 in 2021 and licensed under GPL v3
; ****************************************************************************

;
;;=======================================================================================
;; The collection of input/output related functions starts here
;;=======================================================================================
;
; Define io system specific constants and memory areas etc. It is expected that the
; basic definitions from sysdef.asm have been included somewhere before!
;
;***************************************************************************************
;* IO$DUMP_MEMORY prints a hexadecimal memory dump of a specified memory region.
;*
;* R8:  Contains the start address
;* R9:  Contains the end address (inclusive)
;*
;* The contents of R8 and R9 are preserved during the run of this function.
;***************************************************************************************
;
IO$DUMP_MEMORY          INCRB                           ; Get a new register page
                        MOVE R8, R0                     ; R0 will be the loop counter
                        MOVE R8, R1                     ; This will be needed to restore R8 later
                        MOVE R9, R3
                        ADD 0x0001, R3                  ; That is necessary since we want the last 
                                                        ; address printed, too
                        MOVE 0xFFFF, R4                 ; Set R4 - this is the column counter - to -1
_IO$DUMP_MEMORY_LOOP    CMP  R3, R0                     ; Have we reached the end of the memory area?
                        RBRA _IO$DUMP_MEMORY_EXIT, !N   ; Yes - that is it, so exit this routine
                        ADD 0x0001, R4                  ; Next column
                        AND 0x0007, R4                  ; We compute mod 8
                        RBRA _IO$DUMP_MEMORY_CONTENT, !Z; if the result is not equal 0 we do not 
                                                        ; need an address printed
                        RSUB IO$PUT_CRLF, 1             ; Print a CR/LF pair
                        MOVE R0, R8                     ; Print address
                        RSUB IO$PUT_W_HEX, 1
                        MOVE IO$COLON_DELIMITER, R8     ; Print a colon followed by a space
                        RSUB IO$PUTS, 1
_IO$DUMP_MEMORY_CONTENT MOVE @R0++, R8                  ; Print the memory contents of this location
                        RSUB IO$PUT_W_HEX, 1
                        MOVE ' ', R8                    ; Print a space
                        RSUB IO$PUTCHAR, 1
                        RBRA _IO$DUMP_MEMORY_LOOP, 1    ; Continue the print loop
_IO$DUMP_MEMORY_EXIT    RSUB IO$PUT_CRLF, 1             ; Print a last CR/LF pair
                        MOVE R1, R8                     ; Restore R8,
                        DECRB                           ; switch back to the correct register page
			            RET
;
;***************************************************************************************
;* IO$GET_W_HEX reads four hex nibbles from stdin and returns the corresponding
;* value in R8
;*
;* Illegal characters (not 1-9A-F or a-f) will generate a bell signal. The only
;* exception to this behaviour is the character 'x' which will erase any input
;* up to this point. This has the positive effect that a hexadecimal value can
;* be entered as 0x.... or just as ....
;***************************************************************************************
;
IO$GET_W_HEX        INCRB                                   ; Get a new register page
                    MOVE    R9, R2                          ; Save R9 and R10
                    MOVE    R10, R3
_IO$GET_W_HEX_REDO  XOR     R0, R0                          ; Clear R0
                    MOVE    4, R1                           ; We need four characters
                    MOVE    IO$HEX_NIBBLES, R9              ; Pointer to list of valid chars
_IO$GET_W_HEX_INPUT RSUB    IO$GETCHAR, 1                   ; Read a character into R8
                    RSUB    CHR$TO_UPPER, 1                 ; Convert to upper case
                    CMP     'X', R8                         ; Was it an 'X'?
                    RBRA    _IO$GET_W_HEX_REDO, Z           ; Yes - redo from start :-)
                    RSUB    STR$STRCHR, 1                   ; Is it a valid character?
                    MOVE    R10, R10                        ; Result equal zero?
                    RBRA    _IO$GET_W_HEX_VALID, !Z         ; No
                    MOVE    CHR$BELL, R8                    ; Yes - generate a beep :-)
                    RSUB    IO$PUTCHAR, 1
                    RBRA    _IO$GET_W_HEX_INPUT, 1          ; Retry
_IO$GET_W_HEX_VALID RSUB    IO$PUTCHAR, 1                   ; Echo character
                    SUB     IO$HEX_NIBBLES, R10             ; Get number of character
                    SHL     4, R0
                    ADD     R10, R0
                    SUB     0x0001, R1
                    RBRA    _IO$GET_W_HEX_INPUT, !Z         ; Read next character
                    MOVE    R0, R8
                    MOVE    R2, R9                          ; Restore R9 and R10
                    MOVE    R3, R10
                    DECRB                                   ; Restore previous register page
                    RET
;
;***************************************************************************************
;* IO$PUT_W_HEX prints a machine word in hexadecimal notation. 
;*
;* R8: Contains the machine word to be printed in hex notation.
;*
;* The contents of R8 are being preserved during the run of this function.
;***************************************************************************************
;
IO$PUT_W_HEX    INCRB                   ; Get a new register page
                MOVE 0x0004, R0         ; Save constant for nibble shifting
                MOVE R0, R4             ; Set loop counter to four
                MOVE R8, R5             ; Copy contents of R8 for later restore
                MOVE IO$HEX_NIBBLES, R1 ; Create a pointer to the list of nibbles
                                        ; Push four ASCII characters to the stack
_IO$PWH_SCAN    MOVE R1, R2             ; and create a scratch copy of this pointer
                MOVE R8, R3             ; Create a local copy of the machine word
                AND 0x000f, R3          ; Only the four LSBs are of interest
                ADD R3, R2              ; Adjust pointer to the desired nibble
                MOVE @R2, @--SP         ; and save the ASCII character to the stack
                SHR 4, R8               ; Shift R8 four places right
                SUB 0x0001, R4          ; Decrement loop counter
                RBRA _IO$PWH_SCAN, !Z   ; and continue with the next nibble
                                        ; Now read these characters back and print them
                MOVE R0, R4             ; Initialize loop counter
_IO$PWH_PRINT   MOVE @SP++, R8          ; Fetch a character from the stack
                RSUB IO$PUTCHAR, 1      ; and print it
                SUB 0x0001, R4          ; Decrement loop counter
                RBRA _IO$PWH_PRINT, !Z  ; and continue with the next character
                                        ; That is all...
                MOVE R5, R8             ; Restore contents of R8
                DECRB                   ; Restore correct register page
		        RET
;
;***************************************************************************************
;* IO$GETCHAR reads a character either from the first UART in the system or from an
;* attached USB keyboard. This depends on the setting of bit 0 of the switch register.
;* If SW[0] == 0, then the character is read from the UART, otherwise it is read from
;* the keyboard data register.
;*
;* R8 will contain the character read in its lower eight bits.
;***************************************************************************************
;
IO$GETCHAR          INCRB
                    MOVE    IO$SWITCH_REG, R0
_IO$GETCHAR_ENTRY   MOVE    @R0, R1                 ; Read the switch register
                    AND     0x0001, R1              ; Lowest bit set?
                    RBRA    _IO$GETCHAR_UART, Z     ; No, read from UART
                    RSUB    KBD$GETCHAR, 1          ; Yes, read from USB-keyboard
                    MOVE    IO$KBD_STATE, R3        ; Preserve modifier keys 
                    MOVE    @R3, R2                  
                    RBRA    _IO$GETCHAR_SPECIAL, 1  ; One char successfully read
_IO$GETCHAR_UART    RSUB    UART$GETCHAR, 1         ; Read from UART
                    MOVE    0, R2                   ; Make sure: no USB phantom modifiers
_IO$GETCHAR_SPECIAL CMP     KBD$CTRL_E, R8          ; CTRL-E?
                    RBRA    QMON$SOFTSTART, Z       ; Return to monitor immediately!
                    CMP     KBD$CTRL_F, R8          ; CTRL-F?
                    RBRA    _IO$GETCHAR_SU1, Z      ; Yes: scroll up 1 line
                    CMP     KBD$CUR_DOWN, R8        ; No: Cursor Down key?
                    RBRA    _IO$GETCHAR_NO_FCD, !Z  ; No
_IO$GETCHAR_SU1     MOVE    1, R8                   ; VGA$SCROLL_UP_1 in manual mode
                    RSUB    VGA$SCROLL_UP_1, 1      ; Perform scroll up
                    RBRA    _IO$GETCHAR_ENTRY, 1    ; Wait for next character
_IO$GETCHAR_NO_FCD  CMP     KBD$CTRL_B, R8          ; CTRL-B?
                    RBRA    _IO$GETCHAR_SD1, Z      ; Yes: scroll down 1 line
                    CMP     KBD$CUR_UP, R8          ; No: Cursor Up key?
                    RBRA    _IO$GETCHAR_NO_BCU, !Z  ; No                    
_IO$GETCHAR_SD1     RSUB    VGA$SCROLL_DOWN_1, 1    ; Perform scroll down
                    RBRA    _IO$GETCHAR_ENTRY, 1    ; Wait for next character
_IO$GETCHAR_NO_BCU  AND     KBD$CTRL, R2            ; CTRL pressed?
                    RBRA    _IO$GETCHAR_NO_CTRL, Z  ; No
                    CMP     KBD$PG_DOWN, R8         ; Yes: CTRL+Page Down?
                    RBRA    _IO$GETCHAR_NO_CPGD, !Z ; No
                    MOVE    10, R8                  ; Yes: scroll up 10 lines
                    RSUB    VGA$SCROLL_UP,1
                    RBRA    _IO$GETCHAR_ENTRY, 1    ; Wait for next character
_IO$GETCHAR_NO_CPGD CMP     KBD$PG_UP, R8           ; CTRL+Page Up?
                    RBRA    _IO$GETCHAR_NO_CTRL, !Z ; No
                    MOVE    10, R8                  ; Yes: scroll down 10 lines
                    RSUB    VGA$SCROLL_DOWN, 1
                    RBRA    _IO$GETCHAR_ENTRY, 1    ; Wait for next character
_IO$GETCHAR_NO_CTRL CMP     KBD$PG_DOWN, R8         ; Page Down?
                    RBRA    _IO$GETCHAR_NO_PGD, !Z  ; No
                    MOVE    40, R8                  ; Yes: scroll up one screen
                    RSUB    VGA$SCROLL_UP, 1
                    RBRA    _IO$GETCHAR_ENTRY, 1    ; Wait for next character
_IO$GETCHAR_NO_PGD  CMP     KBD$PG_UP, R8           ; Page Up?
                    RBRA    _IO$GETCHAR_NO_PGU, !Z  ; No
                    MOVE    40, R8                  ; Yes: scroll down one screen
                    RSUB    VGA$SCROLL_DOWN, 1              
                    RBRA    _IO$GETCHAR_ENTRY, 1    ; Wait for next character
_IO$GETCHAR_NO_PGU  CMP     KBD$HOME, R8            ; Home?
                    RBRA    _IO$GETCHAR_NO_HM, !Z   ; No
                    MOVE    0, R8                   ; Yes: scroll to the very top
                    RSUB    VGA$SCROLL_HOME_END, 1
                    RBRA    _IO$GETCHAR_ENTRY, 1    ; Wait for next character
_IO$GETCHAR_NO_HM   CMP     KBD$END, R8             ; End?
                    RBRA    _IO$GETCHAR_FIN, !Z     ; No: Normal Key
                    MOVE    1, R8                   ; Yes: scroll to the very bottom
                    RSUB    VGA$SCROLL_HOME_END, 1
                    RBRA    _IO$GETCHAR_ENTRY, 1    ; Wait for next character

_IO$GETCHAR_FIN     DECRB
                    RET
;
;***************************************************************************************
;* IO$GETS reads a zero terminated string from STDIN and echos typing on STDOUT
;*
;* ALWAYS PREFER IO$GETS_S OVER THIS FUNCTION!
;*
;* It accepts CR, LF and CR/LF as input terminator, so it directly works with various
;* terminal settings on UART and also with keyboards on PS/2 ("USB"). Furtheron, it
;* accepts BACKSPACE for editing the string.
;*
;* R8 has to point to a preallocated memory area to store the input line
;***************************************************************************************
;
IO$GETS         MOVE    R9, @--SP           ; save original R9
                MOVE    R10, @--SP          ; save original R10
                XOR     R9, R9              ; R9 = 0: unlimited chars
                XOR     R10, R10            ; R10 = 0: no LF at end of str.
                RSUB    IO$GETS_CORE, 1     ; get the unlimited string
                MOVE    @SP++, R10          ; restore original R10
                MOVE    @SP++, R9           ; restore original R9
                RET
;
;***************************************************************************************
;* IO$GETS_S reads a zero terminated string from STDIN into a buffer with a
;*           specified maximum size and echos typing on STDOUT
;*
;* It accepts CR, LF and CR/LF as input terminator, so it directly works with various
;* terminal settings on UART and also with keyboards on PS/2 ("USB"). Furtheron, it
;* accepts BACKSPACE for editing the string.
;*
;* A maximum amount of (R9 - 1) characters will be read, because the function will
;* add the zero terminator to the string, which then results in R9 words.
;*
;* R8 has to point to a preallocated memory area to store the input line
;* R9 specifies the size of the buffer, so (R9 - 1) characters can be read;
;*    if R9 == 0, then an unlimited amount of characters is being read
;***************************************************************************************
;
IO$GETS_S       MOVE    R10, @--SP          ; save original R10
                XOR     R10, R10            ; R10 = 0: no LF at end of str.
                RSUB    IO$GETS_CORE, 1     ; get string
                MOVE    @SP++, R10          ; restore original R10
                RET
;
;***************************************************************************************
;* IO$GETS_SLF reads a zero terminated string from STDIN into a buffer with a specified
;*             maximum size and echos typing on STDOUT. A line feed character is added
;*             to the string in case the function is ended not "prematurely" by
;*             reaching the buffer size, but by pressing CR or LF or CR/LF.
;*
;* It accepts CR, LF and CR/LF as input terminator, so it directly works with various
;* terminal settings on UART and also with keyboards on PS/2 ("USB"). Furtheron, it
;* accepts BACKSPACE for editing the string.
;*
;* A maximum amount of (R9 - 1) characters will be read, because the function will
;* add the zero terminator to the string, which then results in R9 words.
;*
;* R8 has to point to a preallocated memory area to store the input line
;* R9 specifies the size of the buffer, so (R9 - 1) characters can be read;
;*    if R9 == 0, then an unlimited amount of characters is being read
;***************************************************************************************
;
IO$GETS_SLF     MOVE    R10, @--SP          ; save original R10
                MOVE    1, R10              ; R10 = 1: add LF, if the function
                                            ; ends regularly, i.e. by a key
                                            ; stroke (LF, CR or CR/LF)
                RSUB    IO$GETS_CORE, 1     ; get string
                MOVE    @SP++, R10          ; restore original R10
                RET
;
;***************************************************************************************
;* IO$GETS_CORE implements the various gets variants.
;*
;* Refer to the comments for IO$GETS, IO$GET_S and IO$GET_SLF
;*
;* R8  has to point to a preallocated memory area to store the input line
;* R9  specifies the size of the buffer, so (R9 - 1) characters can be read;
;*     if R9 == 0, then an unlimited amount of characters is being read
;* R10 specifies the LF behaviour: R10 = 0 means never add LF, R10 = 1 means: add a
;*     LF when the input is ended by a key stroke (LF, CR or CR/LF) in contrast to
;*     automatically ending due to a full buffer
;***************************************************************************************
;
IO$GETS_CORE    INCRB
                MOVE    R10, @--SP          ; save original R10
                MOVE    R11, @--SP          ; save original R11
                MOVE    R12, @--SP          ; save original R12

                MOVE    R10, R12            ; R12 = add LF flag
                XOR     R11, R11            ; R11 = character counter = 0
                MOVE    R9, R10             ; R10 = max characters
                SUB     1, R10              ; R10 = R9 - 1 characters

                MOVE    R8, R0              ; save original R8
                MOVE    R8, R1              ; R1 = working pointer

_IO$GETS_LOOP   CMP     R9, 0               ; unlimited characters?
                RBRA    _IO$GETS_GETC, Z    ; yes
                CMP     R11, R10            ; buffer size - 1 reached?
                RBRA    _IO$GETS_ZT, Z      ; yes: add zero terminator
                ADD     1, R11              ; no: next character

_IO$GETS_GETC   RSUB    IO$GETCHAR, 1       ; get char from STDIN
                CMP     R8, 0x000D          ; accept CR as line end
                RBRA    _IO$GETS_CR, Z
                CMP     R8, 0x000A          ; accept LF as line end
                RBRA    _IO$GETS_LF, Z
                CMP     R8, 0x0008          ; use BACKSPACE for editing
                RBRA    _IO$GETS_BS, Z
                CMP     R8, 0x007F          ; treat DEL key as BS, e.g. for ..
                RBRA    _IO$GETS_DEL, Z     ; .. MAC compatibility in EMU
_IO$GETS_ADDBUF MOVE    R8, @R1++           ; store char to buffer
_IO$GETS_ECHO   RSUB    IO$PUTCHAR, 1       ; echo char on STDOUT
                RBRA    _IO$GETS_LOOP, 1    ; next character

_IO$GETS_LF     CMP     R12, 0              ; evaluate LF flag
                RBRA    _IO$GETS_ZT, Z      ; 0 = do not add LF flag
                MOVE    0x000A, @R1++       ; add LF

_IO$GETS_ZT     MOVE    0, @R1              ; add zero terminator
                MOVE    R0, R8              ; restore original R8

                MOVE    @SP++, R12          ; restore original R12
                MOVE    @SP++, R11          ; restore original R11
                MOVE    @SP++, R10          ; restore original R10
                DECRB
                RET

                ; For also accepting CR/LF, we need to do a non-blocking
                ; check on STDIN, if there is another character waiting.
                ; IO$GETCHAR is a blocking call, so we cannot use it here.
                ; STDIN = UART, if bit #0 of IO$SWITCH_REG = 0, otherwise
                ; STDIN = PS/2 ("USB") keyboard
                ;
                ; At a terminal speed of 115200 baud = 14.400 chars/sec
                ; (for being save, let us assume only 5.000 chars/sec)
                ; and a CPU frequency of 50 MHz we need to wait about
                ; 10.000 CPU cycles until we check, if the terminal program
                ; did send one other character. The loop at GETS_CR_WAIT
                ; costs about 7 cycles per iteration, so we loop (rounded up)
                ; 2.000 times.
                ; As a simplification, we assume the same waiting time
                ; for a PS/2 ("USB") keyboard

_IO$GETS_CR     MOVE    2000, R3            ; CPU speed vs. transmit speed
_IO$GETS_CRWAIT SUB     1, R3
                RBRA    _IO$GETS_CRWAIT, !Z

                MOVE    IO$SWITCH_REG, R2   ; read the switch register
                MOVE    @R2, R2
                AND     0x0001, R2          ; lowest bit set?
                RBRA    _IO$GETS_CRUART, Z  ; no: read from UART

                MOVE    IO$KBD_STATE, R2    ; read the keyboard status reg.
                MOVE    @R2, R2
                AND     0x0001, R2          ; char waiting/lowest bit set?
                RBRA    _IO$GETS_LF, Z      ; no: then add zero term. and ret.

                MOVE    IO$KBD_DATA, R2     ; yes: read waiting character
                MOVE    @R2, R2
                RBRA    _IO$GETS_CR_LF, 1   ; check for LF


_IO$GETS_CRUART MOVE    IO$UART_SRA, R2     ; read UART status register
                MOVE    @R2, R2
                AND     0x0001, R2          ; is there a character waiting?
                RBRA    _IO$GETS_LF, Z      ; no: then add zero term. and ret.

                MOVE    IO$UART_RHRA, R2    ; yes: read waiting character
                MOVE    @R2, R2

_IO$GETS_CR_LF  CMP     R2, 0x000A          ; is it a LF (so we have CR/LF)?
                RBRA    _IO$GETS_LF, Z      ; yes: then add zero trm. and ret.

                ; it is CR/SOMETHING, so add both: CR and "something" to
                ; the string and go on waiting for input, but only of the
                ; buffer is large enough. Otherwise only add CR.
                MOVE    0x000D, @R1++       ; add CR
                CMP     R9, 0               ; unlimited characters?
                RBRA    _IO$GETS_CRSS, Z    ; yes: go on and add SOMETHING
                CMP     R11, R10            ; buffer size - 1 reached?
                RBRA    _IO$GETS_ZT, Z      ; yes: add zero terminator and end
                ADD     1, R11              ; increase amount of stored chars                
_IO$GETS_CRSS   MOVE    R2, R8              ; no: prepare to add SOMETHING
                RBRA    _IO$GETS_ADDBUF, 1  ; add it to buffer and go on

                ; handle BACKSPACE for editing and accept DEL as alias for BS
                ;
                ; For STDOUT = UART it is kind of trivial, because you "just"
                ; need to rely on the fact, that the terminal settings are
                ; correct and then the terminal program takes care of the
                ; nitty gritty details like moving the cursor and scrolling.
                ;
                ; For STDOUT = VGA, this needs to be done manually by this
                ; routine.

_IO$GETS_DEL    MOVE    0x0008, R8          ; treat DEL as BS
_IO$GETS_BS     SUB     1, R11              ; do not count DEL/BS character
                CMP     R0, R1              ; beginning of string?
                RBRA    _IO$GETS_LOOP, Z    ; yes: ignore BACKSPACE key

                SUB     1, R1               ; delete last char in memory
                SUB     1, R11              ; do not count last char in mem.                

                MOVE    IO$SWITCH_REG, R2   ; read the switch register
                MOVE    @R2, R2
                AND     0x0002, R2          ; bit #1 set?
                RBRA    _IO$GETS_ECHO, Z    ; no: STDOUT = UART: just echo

                MOVE    VGA$CR_X, R2        ; R2: HW X-register
                MOVE    VGA$CR_Y, R3        ; R3: HW Y-register
                MOVE    VGA$CHAR, R4        ; R4: HW put/get character reg.
                MOVE    _VGA$X, R5          ; R5: SW X-register
                MOVE    _VGA$Y, R6          ; R6: SW Y-register

                CMP     @R2, 0              ; cursor already at leftmost pos.?
                RBRA    _IO$GETS_BSLUP, Z   ; yes: scroll one line up

                SUB     1, @R2              ; cursor one position to the left
                SUB     1, @R5
_IO$GETS_BSX    MOVE    0x0020, @R4         ; delete char on the screen
                RBRA    _IO$GETS_LOOP, 1    ; next char/key

_IO$GETS_BSLUP  CMP     @R3, VGA$MAX_Y      ; cursor already bottom line?
                RBRA    _IO$GETS_BSSUP, Z   ; yes: scroll screen up

                SUB     1, @R3              ; cursor one line up
                SUB     1, @R6
_IO$GETS_BSXLU  MOVE    VGA$MAX_X, @R2      ; cursor to the rightpost pos.
                MOVE    VGA$MAX_X, @R5
                RBRA    _IO$GETS_BSX, 1     ; delete char on screen and go on

_IO$GETS_BSSUP  MOVE    VGA$OFFS_DISPLAY, R7        ; if RW > DISP then do not
                MOVE    VGA$OFFS_RW, R8             ; scroll up the screen
                CMP     @R8, @R7                    ; see VGA$SCROLL_UP_1 for
                RBRA    _IO$GETS_BSUPSP, N          ; an explanation

                SUB     VGA$CHARS_PER_LINE, @R7     ; do the visual scrolling
_IO$GETS_BSUPSP SUB     VGA$CHARS_PER_LINE, @R8     ; scroll the RW window

                CMP     @R7, @R8                    ; if after the scrolling
                RBRA    _IO$GETS_NOCRS, !Z          ; RW = DISP then show
                MOVE    VGA$STATE, R8               ; the cursor
                OR      VGA$EN_HW_CURSOR, @R8

_IO$GETS_NOCRS  MOVE    VGA$MAX_Y, @R3              ; cursor to bottom
                MOVE    VGA$MAX_Y, @R6
                RBRA    _IO$GETS_BSXLU, 1           ; cursor to rightmost pos.
;
;***************************************************************************************
;* IO$PUTS prints a null terminated string.
;*
;* R8: Pointer to the string to be printed. Of each word only the lower eight bits
;*     will be printed. The terminating word has to be zero.
;*
;* The contents of R8 are being preserved during the run of this function.
;***************************************************************************************
;
IO$PUTS         INCRB                   ; Get a new register page
                MOVE R8, R1             ; Save contents of R8
                MOVE R8, R0             ; Local copy of the string pointer
_IO$PUTS_LOOP   MOVE @R0++, R8          ; Get a character from the string
                AND 0x00FF, R8          ; Only the lower eight bits are relevant
                RBRA _IO$PUTS_END, Z    ; Return when the string end has been reached
                RSUB IO$PUTCHAR, 1      ; Print this character
                RBRA _IO$PUTS_LOOP, 1   ; Continue with the next character
_IO$PUTS_END    MOVE R1, R8             ; Restore contents of R8
                DECRB                   ; Restore correct register page
        		RET
;
;***************************************************************************************
;* IO$PUT_CRLF prints actually a LF/CR (the reason for this is that curses on the
;*             MAC, where the emulation currently runs, has problems with CR/LF, but
;*             not with LF/CR)
;***************************************************************************************
;
IO$PUT_CRLF     INCRB                   ; Get a new register page
                MOVE R8, R0             ; Save contents of R8
                MOVE 0x0A, R8
                RSUB IO$PUTCHAR, 1
                MOVE 0x0D, R8
                RSUB IO$PUTCHAR, 1
                MOVE R0, R8             ; Restore contents of R8
                DECRB                   ; Return to previous register page
	        	RET
;
;***************************************************************************************
;* IO$PUTCHAR prints a single character.
;*
;* R8: Contains the character to be printed
;
;* The contents of R8 are being preserved during the run of this function.
;***************************************************************************************
;
IO$PUTCHAR          INCRB
                    MOVE    R8, R2              ; Avoid printing a zero character in...
                    AND     KBD$SPECIAL, R2     ; ...case somebody directly syscalls...
                    RBRA    _IO$PUTCHAR_END, !Z ; ...here with a special key in R8
                    MOVE    IO$SWITCH_REG, R0
                    MOVE    @R0, R1             ; Read the switch register
                    AND     0x0002, R1          ; Bit 1 set?
                    RBRA    _IO$PUTCHAR_UART, Z ; No, write to UART
                    RSUB    VGA$PUTCHAR, 1      ; Yes, write to VGA-controller
                    RBRA    _IO$PUTCHAR_END, 1  ; Finish
_IO$PUTCHAR_UART    RSUB    UART$PUTCHAR, 1
_IO$PUTCHAR_END     DECRB
                    RET
;
;***************************************************************************************
;* IO$TIL
;*
;* Show a four nibble hex value on the TIL-display
;*
;* R8: Contains the value to be displayed
;***************************************************************************************
;
IO$TIL          INCRB
                MOVE    IO$TIL_DISPLAY, R0
                MOVE    R8, @R0
                DECRB
                RET
;
;***************************************************************************************
; Constants, etc.
;***************************************************************************************
;
IO$HEX_NIBBLES      .ASCII_W "0123456789ABCDEF"
IO$COLON_DELIMITER  .ASCII_W ": "
