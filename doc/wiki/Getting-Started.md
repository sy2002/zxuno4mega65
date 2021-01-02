Make sure you use the right hardware:

* This core supports the MEGA65 **R2** and **R3**.
* It uses **VGA** for video output and the **3.5mm audio jack** for audio output. No HDMI.
* Insert the SD card that you will prepare below into the **internal** SD card slot of the MEGA65 (the one in the bottom tray):
  This is currently the only SD card slot, that this core supports.

Follow these steps to get started:

1. [Prepare](#1-prepare-an-sd-card) an SD card
   
2. [Choose](#2-choose-the-right-core-and-install-it) the right core and [install](#1-choose-the-right-core-and-install-it) the ZX-Uno @ MEGA65 Core on your machine.

3. [Run a bunch of experiments](#3-run-a-bunch-of-experiments)

4. Learn more about the [[Keyboard Mapping]]

5. Learn more about how to use [[Joysticks]]

## 1. Prepare an SD Card

You can use your existing MEGA65 SD card and just add the folders and files mentioned here; you do not need to use a new card.
If you decide to use a new card, then make sure that it is a SDHC card between 4 GB and 32 GB formatted as FAT32.

Only the first two following steps (1) and (2) are mandatory. In the other steps, some helpful tests and games are copied to the
SD card, so that you can check the basic and advanced functionality of the core: Graphics inkl. ULAplus, sound, keyboard, joystick.
Additionally we will deliberately download some 48k games that need a manual switch to 48k mode, so that you can test that, too.

1. ZX-Uno @ MEGA65 needs **ESXDOS** (http://esxdos.org) to access the SD card.<br>
   We are currently supporting version 0.8.8, download it [here](http://www.esxdos.org/files/esxdos088.zip).

2. From the unzipped ESXDOS archive, copy the folders `BIN`, `SYS` and `TMP` to your SD Card.
   You do not need the other files outside these three subfolders.

3. Create a new folder called `zx` and inside this folder create three more folders: `demos`, `games` and `tests`.

4. Download the keyboard and joystick test program [testkeys.tap](https://github.com/sy2002/zxuno4mega65/raw/master/test/keyb_test/testkeys.tap)
   and copy it into the `tests` folder.

5. Copy the following downloads into the `games` folder. You might want to rename them to the 8.3 naming scheme for
   a more convenient file name display in ESXDOS:
  
   a) [Rick Dangerous](http://abrimaal.pro-e.pl/zx/rick-dangerous.tap.zip), ULAPplus version, runs directly from NMI menu<br>
   b) [Commando](http://abrimaal.pro-e.pl/zx/commando.zip), ULAplus version, needs a manual switch to 48k mode<br>
   c) [Boulder Dash](https://www.worldofspectrum.org//pub/sinclair/games/b/BoulderDash.tap.zip), standard version, is very slow, needs a speed-up

6. Copy the following downloads into the `demos` folder. 

   a) [aeon by Triebkraft & 4th Dimension](ftp://ftp.untergrund.net/users/diver4d/tbk4d-08-aeonfinal.zip)<br>
   b) [mescaline synesthesia by deMarche](ftp://ftp.untergrund.net/users/diver4d/tum09/low-end%20demo/zx_demo_mescaline_synesthesia_with_emu.zip)<br>

7. In general, when you copy software to your SD card: Make sure that you use the `.tap` format. Other formats will most probably not work.
   
## 2. Choose the right core and install it

At the time of writing this in January 2020, there are two MEGA65 models out there in the wild: **R2** and **R3** (aka DevKit).
Pick your model in the table below. Download the `.cor` file, if you'd like to install it as described in the
[MEGA65 User's Guide](https://files.mega65.org/news/MEGA65-User-Guide.pdf)
*Chapter 5 Cores and Flashing*. Otherwise, you can also use MEGA65's `M65 Command Line Tool` as descibed in 
*Chapter 12 Data Transfer and Debugging Tools* or Vivado's `Hardware Manager` to directly upload the bitstream (`.bit`) using
an FPGA JTag connection.

| Your MEGA65                 | Model             | Core File&nbsp;&nbsp;`.cor` | Bitstream&nbsp;&nbsp;`.bit`
|:----------------------------|:------------------|:----------------------------|:------------------
| [[/assets/mega65-r2.jpg]]   | Pre&#8209;series&nbsp;R2 | [r2zxu08.cor](https://github.com/sy2002/zxuno4mega65/raw/master/bin/R2/r2zxu08.cor)| [r2zxu08.bit](https://github.com/sy2002/zxuno4mega65/raw/master/bin/R2/r2zxu08.bit)
| [[/assets/mega65-r3.jpg]]   | DevKit&nbsp;R3    | [r3zxu08.cor](https://github.com/sy2002/zxuno4mega65/raw/master/bin/R3/r3zxu08.cor)| [r3zxu08.bit](https://github.com/sy2002/zxuno4mega65/raw/master/bin/R3/r3zxu08.bit)

## 3. Run a bunch of experiments

Boot up the core, either using the <kbd>No Scroll</kbd> mechanism or by using the `M65` command line tool. You should see a light gray screen with the following copyright message displayed in black: `(c) 1982 Sinclair Research Ltd`

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

1. Press <kbd>Esc</kbd> while being in 48k BASIC or while you see the initial copyright screen.

2. The ESCDOS NMI Menu opens. This is a convenient file browser and program starter. You can press <kbd>h</kbd> to see
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

1. Press <kbd>Esc</kbd>

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

1. Press <kbd>Esc</kbd>

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

### Using ESXDOS

You can use the following commands in 48k BASIC. Always write them as shown here, with a trailing `.` (dot):

* `.ls`: Browse the current directly
* `.cd`: Change directory
* `.tapein`: Mount `.tap` file. Run it without parameters to learn more.
* Browse the `/BIN` folder to discover more commands

Here is an [outdated manual](http://www.benophetinternet.nl/hobby/vanmezelf/ESXDOS%20manual.pdf) for ESXDOS.
There does not seem to be anything newer nor seems to be an official manual by ESXDOS' creators.