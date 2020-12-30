![PRE-ALPHA](https://img.shields.io/badge/-WARNING%3A%20PRE--ALPHA-red)

ZX-Uno @ MEGA65: ZX Spectrum Core
=================================

The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)

Original website: https://zxuno.speccy.org/index_e.shtml

MEGA65 port done by sy2002 in 2020 and licensed under GPL v3, see [AUTHORS](AUTHORS) for more details

Special thanks to Paul, Deft, Miguel, Andrew

README.md is just a stub and work-in progress

### Keyboard & Joysticks

There is a [keyboard mapping page in the Wiki](https://github.com/sy2002/zxuno4mega65/wiki/Keyboard-Mapping).

Here is information of [how to use joysticks](https://github.com/sy2002/zxuno4mega65/wiki/Joysticks).

### What works already on a MEGA65 R2

* The basic ZX-Uno core runs (CPU, ULA incl. ULAplus, RAM, ROM, ...)
* 48k BASIC
* VGA output
* Keyboard using a [convenient mapping](https://github.com/sy2002/zxuno4mega65/wiki/Keyboard-Mapping)
* [Joysticks](https://github.com/sy2002/zxuno4mega65/wiki/Joysticks)
* Ability to [emulate a joystick](https://github.com/sy2002/zxuno4mega65/wiki/Keyboard#cursor-keys-standard-and-joystick-mode) via cursor keys.
  By default, a Sinclair joystick is emulated.
* SD-Cards via ESXDOS

### Not working yet

* MEGA65 R3
* HDMI
* Audio
* Mouse

### Scratchpad

#### Documentation TODOs

* Setup: Download EXDOS, hint about SDHC vs. SD, FAT32, ...
* How to start a game: Mention NMI menu, but if this does not work, one might need to switch
  into 48k mode by entering OUT 32765, 48 in basic and then use the EXTDOS dot commands to load:
  explain how. 128k games vs. 48k games. Speed changes.
* EXTDOS basics

#### Keyboard TODOs

* Support PS/2 codes for at least the function keys for Chloe

