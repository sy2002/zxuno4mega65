;	// SOXZ - A bootloader for the Mega65's ZX Spectrum FPGA core.
;	// Copyright (c) 2020 Source Solutions, Inc.

;	// SOXZ is free software: you can redistribute it and/or modify
;	// it under the terms of the GNU General Public License as published by
;	// the Free Software Foundation, either version 3 of the License, or
;	// (at your option) any later version.
;	// 
;	// SOXZ is distributed in the hope that it will be useful,
;	// but WITHOUT ANY WARRANTY; without even the implied warranty o;
;	// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;	// GNU General Public License for more details.
;	// 
;	// You should have received a copy of the GNU General Public License
;	// along with SOXZ. If not, see <http://www.gnu.org/licenses/>.

uno_reg equ $fc3b;						// Uno register select
uno_dat equ $fd3b;						// Uno data
uno_conf equ 0;							// Uno main config
uno_mapper equ 1;						// Uno paging
scandbl_ctrl equ 11;					// Uno scan doubler
paging equ $7ffd;						// 128 paging
xpaging equ $1ffd;						// +3 extended paging
mmcram equ $e3;							// divMMC RAM

	org 0;
	di;									// interrupts off

	xor a;								// step 1. switch to 28 MHz
	out (254), a;						// set a BLACK border

	ld bc, uno_reg;						// register select port
	ld a, scandbl_ctrl;					// scan double register
	out (c), a;							// select register
	inc b;								// LD BC, uno_dat
	in a, (c);							// read current value of scan double register
	or $c0;								// set 28MHz mode without affecting other values
	out (c), a;							// write it back

	ld a, 1;							// step 2. copy SOXZ ROM from BRAM to SRAM
	out (254), a;						// set a BLUE border

;	ld bc, uno_reg;						// register select port
;	ld a, uno_mapper;					// main mapper register
;	out (c), a;							// select register
;	inc b;								// LD BC, uno_dat
;	ld a, 8;							// bank ROM 0 (occurs after RAM 7)
;	out (c), a;							// page in ROM 0 area at $c000
;	ld hl, $4000;						// source (RAM 5 @ $4000)
;	ld de, $c000;						// destination (ROM 0)
;	ld bc, $4000;						// byte count (16K)
;	ldir;								// block copy ROM 0 in place

;	ld bc, uno_reg;						// register select port
;	ld a, 9;							// bank ROM 1 (occurs after ROM 0)
;	out (c), a;							// page in ROM 1 area at $c000
;	ld hl, $c000;						// source (RAM 5 @ $4000)
;	ld de, $c000;						// destination (ROM 1)
;	ld bc, $4000;						// byte count (16K)
;	ldir;								// block copy ROM 1 in place

;	ld bc, uno_reg;						// register select port
;	ld a, 10;							// bank ROM 2 (occurs after ROM 1)
;	out (c), a;							// page in ROM 2 area at $c000
;	ld hl, $4000;						// source (RAM 5 @ $4000)
;	ld de, $c000;						// destination (ROM 2)
;	ld bc, $4000;						// byte count 16K)
;	ldir;								// block copy ROM 2 in place (+3 uses four ROMs so this code makes two copies of the 32K ROM)

	ld bc, uno_reg;						// register select port
	ld a, 11;							// bank ROM 3 (occurs after ROM 2)
	out (c), a;							// page in ROM 3 area at $c000
	ld hl, $c000;						// source (RAM 5 @ $4000)
	ld de, $c000;						// destination (ROM 3)
	ld bc, $4000;						// byte count (16K)
	ldir;								// block copy ROM 3 in place (+3 uses four ROMs so the uncommented code makes four copies of the 16K ROM) - note, this is the ROM that esxDOS will invoke

	ld bc, uno_reg;						// register select port
	ld a, 12;							// bank divMMC ROM (occurs after ROM 3)
	out (c), a;							// page in divMMC ROM area at $c000
	ld hl, esxdosrom;					// a copy of the 8K esxDOS ROM must is located at $0200
	ld de, $c000;						// destination (divMMC ROM)
	ld bc, $2000;						// byte count (8K)
	ldir;

noinitialstartup:
	ld a, 2;							// step 3. prepare phase in RAM
	out (254), a;						// set a RED border

	ld hl, lastphaseinram;				// source (location of code in this ROM)
	ld de, $8000;						// destination (bank RAM 2)
	ld bc, endoflastphase;				// byte count (calculated)
	ldir;								// copy ROM code to RAM for execution

	jp $8000;							// jump to execute following code in RAM 2 @ $8000

lastphaseinram:
	ld a, 3;							// step 4. configuramos máquina
	out (254), a;						// set a MAGENTA border

	ld bc, uno_reg;						// register select port
	ld a, uno_conf;						// main configuration register
	out (c), a;							// select register
	inc b;								// LD BC, uno_dat

	ld a, %00010010;					// D7:0 - unlocked
;										// D6:0 - PAL
;										// D5:0 - video contention enabled
;										// D4:0 - 311 lines
;										// D3:0 - issue 3 keyboard
;										// D2:0 - divMMC NMI enabled
;										// D1:1 - divMMC enabled
;										// D0:0 - run mode

;	// this section should not be required as esxDOS should select ROM 3 by default, or ROM 1 if port #1ffd is inactive

;	out (c), a;							// write register
;	ld bc, paging;						// 128 memory paging register
;	ld a, %00010000;					// set ROM 1 @ $0000 and RAM 0 @ $c000, frame buffer in bank RAM 5, paging enabled
;	out (c), a;							// write register - should really set ROM 0, esxDOS will default to RAM 3 in any case
;	ld bc, xpaging;						// +3 memory paging register
;	ld a, %00000100;					// set ROM 3 @ $0000, normal paging, disk motor off
;	out (c), a;							// write register

	ld a, 4;							// step 5. erase the divMMC RAM to force reboot
	out (254), a;						// set a GREEN border

	ld a, $80;							// 16 pages of 8Kb each + conmem

looperasedivmmc:
	out (mmcram), a;					// write to divMMC control register - presumably pages in divMMC RAM @ $2000
	ld hl, $2000;						// source ($2000)
	ld de, $2001;						// destination ($2001)
	ld bc, $1fff;						// byte count (8K - 1 byte)
	ld (hl), l;							// LD HL, 0 - clear first byte
	ldir;								// clear remaining bytes
	inc a;								// increment low byte for 16 passes
	cp $90;								// al 16 done?
	jr nz, looperasedivmmc;				// loop if not
	xor a;								// LD A, 0
	out (mmcram), a;					// writing 0 to the divMMC control register presumably pages out divMMC RAM

	ld a, 5;							// step 6. we go back to 3.5 MHz and we start normal 128K ROM (with divMMC)
	out (254), a;						// set a CYAN border

	ld bc, uno_reg;						// register select port
	ld a, scandbl_ctrl;					// scan double register
	out (c), a;							// select register
	inc b;								// LD BC, uno_dat
	in a, (c);							// read current value of scan double register
	and $3f;							// set 3.5MHz mode without affecting other values
	out (c), a;							// write it back

	jp 0;								// jump to $0000 without stacking return address

endoflastphase equ $-lastphaseinram;	// used to figure out how much code to copy to RAM

	org 511;							// padding
	db 0;								// ensures boot code is 512 bytes

	org 512;
esxdosrom equ $;						// esxDOS ROM goes here
