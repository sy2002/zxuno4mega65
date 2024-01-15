**The ZX Spectrum is quite a machine! For sure not self-explanatory for beginners and the core does need a specially prepared SD card, so you need to walk through this Getting Started tutorial.**

### Download the core

* Download the latest core from the [MEGA65 File Host](https://files.mega65.org?id=bdaeb7e0-9fc8-4185-99de-104d01229f27).

* If your MEGA65 was manufactured before 2024, then choose `zxuno-v1.2-r3.cor` from the ZIP otherwise choose `zxuno-v1.2-r6.cor`. If you are interested, then learn more about the different [[MEGA65 models]].

* The default video resolution of the core is PAL 576p @ 50 Hz. The core supports analog video
  and audio output (VGA port and 3.5mm analog audio jack) and digital video and audio output
  using HDMI.

### Avoid SD card problems

* Insert the SD card that you will prepare by following the steps below before starting the core!

* You can choose to use the SD card at the bottom tray of the MEGA65 or the SD card at the back
  side of the MEGA65. The SD card at the back of the machine takes precedence over the SD card at
  the bottom.

* Only use FAT32 formatted "brand" SD cards (no "noname" cards) which are between **4 GB and 32 GB in size**.
  Larger or smaller won't work reliably.

### Avoid hardware problems (pre 2024 MEGA65 machines only)

All MEGA65 machines built before 2024 have a bug on their PCB which is called "HDMI back powering".
Your machine might suffer from HDMI back powering (i.e. because a cable
is connected and a HDMI monitor is ON) and this might lead to the core not being able to read the SD card.
Please head over to the [C64 for MEGA65 core's FAQ](https://github.com/MJoergen/C64MEGA65/blob/master/FAQ.md)
and learn more about HDMI back powering and resolve the issue before you proceed with this tutorial.

### Follow these steps to get started:

1. [Prepare](#1-prepare-an-sd-card) an SD card
   
2. [Run a bunch of experiments](#2-run-a-bunch-of-experiments)

3. Learn more about the [[Keyboard Mapping]]

4. Learn more about how to use [[Joysticks]]

Important keys:

* <kbd>Help</kbd> opens the On-Screen-Menu (OSM). You can configure the HDMI resolution and read the online-help.

* <kbd>Esc</kbd> enters the file manager. Do not mix up <kbd>Run/Stop</kbd> with <kbd>Esc</kbd>.
  In the file manager you can browse the SD card and load/run programs. Use the cursor keys to navigate,
  <kbd>Enter</kbd> to open a subfolder or run a program and <kbd>Tab</kbd> to go up one sub-folder-level.

* Backspace is not <kbd>Inst/Del</kbd> on the ZX Spectrum but <kbd>Arrow left</kbd> (which is the key to the left of <kbd>1</kbd>).

* When <kbd>Caps Lock</kbd> is on, then the cursor keys are emulating a Sinclair (aka Interface 2) joystick, while the <kbd>Space</kbd> bar is the fire button.

## 1. Prepare an SD Card

You can use your existing MEGA65 SD card and just add the folders and files mentioned here; you do not need to use a new card.
If you decide to use a new card, then make sure that it is a SDHC card between 4 GB and 32 GB formatted as FAT32. You can use
both SD card slots of the MEGA65; if you insert an SD card into the back slot then this card is chosen over the bottom slot.

Only the first two following steps (1) and (2) are mandatory. In the other steps, some helpful tests and games are copied to the
SD card, so that you can check the basic and advanced functionality of the core: Graphics inkl. ULAplus, sound, keyboard, joystick.
Additionally we will deliberately download some 48k games that need a manual switch to 48k mode, so that you can test that, too.

1. ZX-Uno @ MEGA65 needs **ESXDOS** (http://esxdos.org) to access the SD card.<br>
   We are currently supporting version 0.8.8, download it [here](http://www.esxdos.org/files/esxdos088.zip).
   **Do use version 0.8.8, do not use any older or newer version!**

2. From the unzipped ESXDOS archive, copy the folders `BIN`, `SYS` and `TMP` to your SD Card.
   You do not need the other files outside these three subfolders.

3. Create a new folder called `zx` and inside this folder create three more folders: `demos`, `games` and `tests`.

4. Download the keyboard and joystick test program [testkeys.tap](https://github.com/sy2002/zxuno4mega65/raw/master/CORE/test/keyb_test/testkeys.tap)
   and copy it into the `tests` folder.

5. Unzip the following downloads into the `games` folder. You might want to rename them to the 8.3 naming scheme for
   a more convenient file name display in ESXDOS:
  
   a) [Rick Dangerous](http://abrimaal.pro-e.pl/zx/rick-dangerous.tap.zip), ULAPplus version, runs directly from NMI menu<br>
   b) [Commando](http://abrimaal.pro-e.pl/zx/commando.zip), ULAplus version, needs a manual switch to 48k mode<br>
   c) [Boulder Dash](https://www.worldofspectrum.org//pub/sinclair/games/b/BoulderDash.tap.zip), standard version, is very slow, needs a speed-up

6. Unzip the following downloads into the `demos` folder. 

   a) [aeon by Triebkraft & 4th Dimension](https://ftp.untergrund.net/users/diver4d/tbk4d-08-aeonfinal.zip)<br>
   b) [mescaline synesthesia by deMarche](https://ftp.untergrund.net/users/diver4d/tum09/low-end%20demo/zx_demo_mescaline_synesthesia_with_emu.zip)<br>
   c) [Break Space by Thesuper](https://files.scene.org/get/parties/2016/chaosconstructions16/zx_spectrum_640k_demo/breakspace_by_thesuper.zip)<br>

7. In general, when you copy software to your SD card: Make sure that you use the `.tap` format or the `.trd` format. Other formats will most likely not work. The file browser cannot browse ZIP files, so you will need to unzip ZIP files first and copy the right files (see "The hardware" section below) to the SD card. You also might want to rename files to an 8.3 scheme as the file browser only supports 8.3.
   
## 2. Run a bunch of experiments

Boot up the core, either using the <kbd>No Scroll</kbd> mechanism or by using the `M65` command line tool. After running through the boot sequence of ESXDOS, you will see a light gray screen with the following copyright message displayed in black: `(c) 1982 Sinclair Research Ltd`

### The hardware: ZX Spectrum 48k or 128k, both with ULAplus

* After startup, this core simulates a ZX Spectrum 128k with 48k BASIC and ULAplus
* When choosing which software version to run, then choose "ZX Spectrum 128k" or "ZX Spectrum +2", if available
* Since the Spectrum 128k /+2 has some [different hardware specifications](https://worldofspectrum.org/faq/reference/128kreference.htm#Plus2) than the original 48k machine, some games or demos are not working in 128k /+2 mode. This tutorial will use the game "Commando" as an example of an 48k game that does not work in 128k mode: You will need to switch the core into 48k mode to run it.
* [ULAplus](https://sinclair.wiki.zxnet.co.uk/wiki/ULAplus) is supported, so you can choose "Enhanced colors" / "Enhanced gfx" / "ULAplus" or similar options when running software to enjoy a way better visual experience.
* When a game gives you different joystick options, choose "Sinclair" or "Interface 2": The core simulates this joystick type by default and it does not matter in which MEGA65 joystick port you are plugging your joystick (exceptions, see [[Joysticks]]). When <kbd>Caps Lock</kbd> is on, then the cursor keys and the Space bar are simulating a joystick.

### 48k Basic

Start typing while you see the copyright screen:

<kbd>1</kbd> <kbd>0</kbd> <kbd>Space</kbd> <kbd>p</kbd> <kbd>Shift</kbd>+<kbd>2</kbd> Hello MEGA65!!! <kbd>Shift</kbd>+<kbd>2</kbd> <kbd>Return</kbd><br>
<kbd>2</kbd> <kbd>0</kbd> <kbd>Space</kbd> <kbd>g</kbd> 10 <kbd>Return</kbd>

For your convenience, we are showing the keystrokes here because of the non-trivial Spectrum [[Keyboard Mapping]]. When you are done, you should see something like this:

```
10 PRINT "Hello MEGA65!!!"
20 GO TO 10
```

Now press <kbd>r</kbd> and press <kbd>Enter</kbd>. The screen fills with some nice MEGA65 greetings. End the program with <kbd>Restore</kbd> and then press <kbd>Enter</kbd>.

**Important:** Backspace is not <kbd>Inst/Del</kbd> on the ZX Spectrum but <kbd>Arrow left</kbd> (which is the key to the left of <kbd>1</kbd>).

### Keyboard and joystick

1. Press <kbd>Esc</kbd> while being in 48k BASIC or while you see the initial copyright screen.<br><br>
   **Caution: Do not mix up the <kbd>Run/Stop</kbd> key with the <kbd>Esc</kbd> key!
     <kbd>Esc</kbd> is one key to the right of <kbd>Run/Stop</kbd>.**<br><br>
   (If you cannot wait to learn more about the <kbd>Run/Stop</kbd> key then head to the [[Keyboard Mapping]] section, but instead,
    we would advise continuing with this tutorial first.)

2. The ESXDOS NMI Menu opens. This is a convenient file browser and program starter. You can press <kbd>h</kbd> to see
   a nice help screen, but then you need to reset your MEGA65 afterwards, so we propose not to press <kbd>h</kbd> right now.

3. Navigate to `zx`, press <kbd>Enter</kbd> and then to `tests` (press <kbd>Enter</kbd>) and then to `testkeys.tap` and
   press <kbd>Enter</kbd> to start the keyboard and joystick test program.

4. Play around with the keyboard.

5. If you have a joystick: Plug it in now into port #1 or #2 and move it. You should see a graphical representation
   of your joystick's movements at the top-right corner of the screen.

6. Activate <kbd>Caps Lock</kbd> - this switches the cursor keys into "Virtual Joystick Mode" (joystick emulation). Now
   use the cursor keys and see, how the movements are also represented at the top-right corner of the screen.
   Try also the <kbd>Space</kbd> bar: It will trigger the fire button of the emulated joystick.

7. Deactivate <kbd>Caps Lock</kbd>.

8. **In any game: Choose "Sinclair" or "Interface 2" as joystick type.**

### Rick Dangerous: Playing an ULAplus game with joystick

1. Press <kbd>Esc</kbd>. (Do not mix up <kbd>Run/Stop</kbd> with <kbd>Esc</kbd>.)
2. If you followed this tutorial in sequence, then you should be still in the `/ZX/TESTS` folder.
   Press <kbd>Tab</kbd> to go up one folder and go to the `games` folder. 

3. Start Rick Dangerous.

4. You should see a welcome screen. Press the <kbd>Space</kbd> bar: You should now see
   a screen that lets you choose between "Enhanced Colours" aka **ULAplus mode** and
   "Standard Colours". And you should hear hear music.

5. Choose <kbd>1</kbd> "Enhanced Colours". You should see "ULA PLUS DETECTED".
   Then choose <kbd>4</kbd> "Normal Game"

6. You should hear music and have the choice of different joysticks. Press <kbd>4</kbd> to choose
   "Sinclair". If you have a real joystick, plug it in now (does not matter if you choose port #1 or #2).
   If you don't, then switch on <kbd>Caps Lock</kbd> now.

7. Press fire on your joystick (or <kbd>Space</kbd> on your keyboard) to start the game.

8. Play with your joystick or using the cursor keys while <kbd>Caps Lock</kbd> is on.

### Commando: Playing a 48k game that needs manual intervention

1. Press <kbd>Esc</kbd>. (Do not mix up <kbd>Run/Stop</kbd> with <kbd>Esc</kbd>.)

2. If you followed this tutorial in sequence, then you should be still in the `/ZX/GAMES` folder.

3. Start Commando

4. Press <kbd>Space</kbd> after you have seen the welcome screen. And then answer the first question
   "Enhanced Colours" with <kbd>y</kbd>+<kbd>Enter</kbd> and then answer all the other questions with
   <kbd>n</kbd>+<kbd>Enter</kbd>. When you see "OK", then press <kbd>Enter</kbd> again.

5. See how the game crashes.

Commando is a perfect example of a 48k game, that needs manual intervention. Follow this sequence to play it:

1. Boot to the 48k BASIC, e.g. by cold starting the ZX Spectrum core and then pressing <kbd>Enter</kbd>.

2. You should see a blinking cursor and the letter `K`. (If you want to know what this `K` means,
   then visit [this link](https://worldofspectrum.org/ZXBasicManual/zxmanchap1.html).)

3. Press the <kbd>Ctrl</kbd> key once, but leave it alone afterwards (do not keep it pressed).

4. The `K` should have turned into an `E` by now. The cursor is still blinking.

5. Press <kbd>Shift</kbd>+<kbd>o</kbd>. You should see `OUT` and a blinking cursor and the letter `L`.

6. Enter `32765, 48`. You should now have this on your screen: `OUT 32765, 48`. Press <kbd>Return</kbd>.

7. You should see something like: `0 OK, 0:1`

8. Press the <kbd>.</kbd> (dot) key and enter directly after the dot (without a space) `tapein /zx/games/commando.tap`

9. Press <kbd>j</kbd> and you will see "LOAD". Enter `""` by pressing <kbd>Shift</kbd>+<kbd>2</kbd> twice. Then press <kbd>Enter</kbd>.

10. Press <kbd>Space</kbd> after you see the load screen and answer the questions just like described above.

11. The game will start.

12. Press <kbd>j</kbd> to choose the joystick and then press <kbd>2</kbd> for "Interface II", which is just another name for
    the Spectrum joystick. It has nothing to do in which hardware port you plugged in your joystick, which does not matter.
    Turn on <kbd>Caps Lock</kbd>, if you want to use the joystick emulation via cursor keys.

13. Press <kbd>s</kbd> to start the game.

### Boulder Dash: Speeding-up a game

Please look at the tutorial steps above to learn how to navigate through the ESXDOS menu and how to enter the `OUT` command.

1. Start Boulder Dash via the ESXDOS menu after having pressed <kbd>Esc</kbd>. You will notice that the game is very slow and not a lot of fun to play. This is actually the original speed of the game as it was back in the days.

2. Reset the machine so that you are back to the start screen / copyright screen.

3. Enter the following commands:

```
.tapein /zx/games/boulder1.tap
OUT 64571, 11
OUT 64827, 65
LOAD ""
```

4. The CPU is now running at 7.0 MHz instead of the ZX Spectrum's standard 3.5 MHz. The game is now a lot of more fun to play.

### Watch demos

The ZX Spectrum has some impressive capabilities that you can enjoy best by watching the demos that you downloaded earlier in this tutorial.
"aeon" and "mescaline" are delivered as "tape" files `*.tap` while "Break Space" is delivered as a "disk image" `*.trd`.
Some demos offer different builds for different Spectrum hardware variants. When running "mescaline" for example,
make sure you choose the "ZX 128 plus 2" variant. And when watching "Break Space", make sure to press <kbd>Return</kbd>
while seeing the intro screen to start the actual demo.

### Using ESXDOS

You can use the following commands in 48k BASIC. Always write them as shown here, with a trailing `.` (dot):

* `.ls`: Browse the current directly
* `.cd`: Change directory
* `.tapein`: Mount `.tap` file. Run it without parameters to learn more.
* Browse the `/BIN` folder to discover more commands

Here is an [outdated manual](http://www.benophetinternet.nl/hobby/vanmezelf/ESXDOS%20manual.pdf) for ESXDOS.
There does not seem to be anything newer nor seems to be an official manual by ESXDOS' creators.

### Gaming

1. Learn more about the [[Keyboard Mapping]]

2. Learn more about how to use [[Joysticks]]

3. Learn tips & tricks that make your ZX Spectrum gaming experience pleasant: Proceed to the [[Gaming]] section