Version 1.1 - November 15, 2023
===============================

Improved HDMI compatibility by fixing an edge case where nothing but vertical
colored lines were shown on screen.
(Fixed GitHub issue https://github.com/sy2002/zxuno4mega65/issues/17)

Version 1.0 - October 24, 2023
==============================

This version introduces HDMI support (audio and video) to the core and it
allows you to use both SD card slots, while the slot on the back side of the
MEGA65 takes precedence over the bottom slot in case two cards are inserted.

Other than that, it is feature-wise identical to Version 0.8, but it no longer
supports the older R2 MEGA65 prototypes (if you have an R2, you can still use
Version 0.8).

This core is compatible with the R3 (DevKits) and R3A versions of the
MEGA65. If you received your MEGA65 before November 2023, you very likely
have an R3 or R3A model, making this core suitable for your device.

Version 0.8 - January 2, 2021
=============================

Version 0.8 is stable and feature rich. Thanks to ESXDOS and SD card support,
loading software is easy. You can play a ton of classic ZX Spectrum games with
it, including AY-3-8910 sound. Also most demos and application programs are
working. And you can program in 48k BASIC.

* This core supports the MEGA65 **R2** and **R3/R3A**.
* It uses **VGA** for video output and the **3.5mm audio jack** 
  for audio output. No HDMI.
* Insert the SD card that you will prepare below into the **internal** SD card
  slot of the MEGA65 (the one in the bottom tray):
  This is currently the only SD card slot, that this core supports.

### Getting Started

The ZX-Uno is not for the faint at heart, so make sure that you go to the
[ZX-Uno for MEGA65 Wiki](https://github.com/sy2002/zxuno4mega65/wiki/Getting-Started)
and work through all steps of the tutorial.
 
### Here is a list, what works:

* The ZX-Uno core runs flawlessly (CPU, ULA incl. ULAplus, RAM, ROM, ...)
* 48k BASIC
* VGA output
* Audio via the 3.5mm analog audio jack
* Keyboard using a convenient mapping
* Joysticks
* Ability to emulate a joystick via cursor keys. By default, a Sinclair
  joystick is emulated.
* SD-Cards via ESXDOS, but only via the **internal** SD card slot

### Not working yet:

* HDMI
* Mouse
* External SD-Card slot of MEGA65
* Attaching a real tape player via EAR
* MIDI
* UART
* PZX Player
* PENTAGON 512k Support
* Expansion port
