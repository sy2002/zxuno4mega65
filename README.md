![PRE-ALPHA](https://img.shields.io/badge/-WARNING%3A%20PRE--ALPHA-red)

ZX-Uno @ MEGA65: ZX Spectrum & Chloe 280SE Core
===============================================

The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)

Original website: https://zxuno.speccy.org/index_e.shtml

MEGA65 port done by sy2002 in 2020 and licensed under GPL v3

Special thanks to Paul, Deft, Miguel, Andrew

README.md work-in progress

### Keyboard mapping

There is a [keyboard mapping page in the Wiki](https://github.com/sy2002/zxuno4mega65/wiki/Keyboard).

### What works already on a MEGA65 R2

* The basic ZX-Uno core runs (CPU, ULA incl. ULAplus, RAM, ROM, ...)
* VGA output
* (Work-in-Progress) Keyboard using a convenient mapping (+TODO doc)

### Not working yet

* MEGA65 R3
* HDMI
* ESXDOS / DivMMC / SD-Cards
* Audio
* Joystick
* Mouse

### Scratchpad

#### Keyboard TODOs

* Support PS/2 codes for at least the function keys for Chloe
* Handle the MEGA65's SHIFT-LOCK key differently. Currently, it just
  locks the "convenicence" shift key (left shift), which does not make
  a lot of sense.

#### Acknowledgement TODOs

* Z80 Core
* ZX-Uno
* Keyboard Mapping GFX
* Spectrum's Matrix GFX from http://www.breakintoprogram.co.uk/computers/zx-spectrum/keyboard
* M65 driver stubs
