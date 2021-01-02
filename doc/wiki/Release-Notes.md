## Release 0.8

Release 0.8 is stable and feature rich. Thanks to ESXDOS and SD card support, loading software is easy. You can play a ton of classic ZX Spectrum games with it, including AY-3-8910 sound. Also most demos and application programs are working. And you can program in 48k BASIC.

* This core supports the MEGA65 **R2** and **R3**.
* It uses **VGA** for video output and the **3.5mm audio jack** for audio output. No HDMI.
* Insert the SD card that you will prepare below into the **internal** SD card slot of the MEGA65 (the one in the bottom tray):
  This is currently the only SD card slot, that this core supports.

### Here is a list, what works:

* The ZX-Uno core runs flawlessly (CPU, ULA incl. ULAplus, RAM, ROM, ...)
* 48k BASIC
* VGA output
* Audio via the 3.5mm analog audio jack
* Keyboard using a [[convenient mapping|Keyboard-Mapping]]
* [Joysticks](https://github.com/sy2002/zxuno4mega65/wiki/Joysticks)
* Ability to [[emulate a joystick|Keyboard-Mapping#cursor-keys-standard-and-joystick-mode]] via cursor keys.
  By default, a Sinclair joystick is emulated.
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
