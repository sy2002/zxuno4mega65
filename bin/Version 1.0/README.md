ZX-Uno for MEGA65 Version 1.0
=============================

ZX-Uno for MEGA65 Version 1.0 is stable and feature-rich. Thanks to ESXDOS and
SD card support, loading software is easy. You can play a ton of classic
ZX Spectrum games with it, including AY-3-8910 sound and thanks to ULAplus
support certain games look even better than back in the good old days. Also,
most demos and application programs are working. Last but not least, you can
program in 48k BASIC.

The core is compatible with the R3 (DevKits) and R3A versions of the MEGA65.
If you received your MEGA65 before November 2023, you very likely have an R3
or R3A model, making this core suitable for your device. It neither supports
the R2 prototype any more (R2 users can still use Version 0.8 of the core),
nor does it support R4/R5 boards (most recent MEGA65 deliveries post
November 2023).

The video output is either analog via the VGA port of the MEGA65 or digital
via the HDMI port. Audio output is supported via the 3.5mm analog audio jack
and via HDMI audio.

### Getting Started

Make sure that you insert a prepared and FAT32 formatted SD card which is
32 GB in size (or smaller) as described here before trying to start the core:

https://github.com/sy2002/zxuno4mega65/wiki/Getting-Started

The ZX-Uno is not for the faint at heart, so make sure that you work
through the tutorial.
 
### Features

* The ZX-Uno core runs flawlessly (CPU, ULA incl. ULAplus, RAM, ROM, ...)
* 48k BASIC
* Analog (PAL 576p @ 50 Hz via the VGA port) and
  digital (HDMI port) video output
* Analog (3.5mm analog audio jack) and digital (HDMI) audio output
* Keyboard with a convenient key mapping
* Joysticks
* Ability to emulate a joystick via cursor keys. By default, a Sinclair
  joystick is emulated.
* SD-Cards via ESXDOS

### List of not, yet working features

* Mouse
* Attaching a real tape player via EAR
* MIDI
* UART
* PZX Player
* PENTAGON 512k Support
* Expansion port

Additionally, see also the GitHub issues list:

https://github.com/sy2002/zxuno4mega65/issues
