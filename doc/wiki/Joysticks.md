## Quickstart

1. Plug in a real joystick to MEGA65's joystick port #1 or #2. As long as you are playing with only one joystick, it does not matter which port you choose.

2. Alternatively, switch on <kbd>CAPS LOCK</kbd> on your MEGA65 to turn the cursor keys <kbd>&#8592;</kbd> <kbd>&#8594;</kbd> <kbd>&#8593;</kbd> <kbd>&#8595;</kbd> into an emulated joystick. Use the <kbd>Space</kbd> bar as a fire button.

3. In the game that you want to play, select the **Sinclair** joystick option, which is sometimes also called **Interface 2**.

4. Play

## Details

When you power on the machine, all three joystick ports, i.e. the two real joystick ports #1 and #2 as well as the emulated joystick port are configured to act as *Sinclair P1 ("right" joystick port)*. If you are playing alone (only one joystick needed), then you just need to configure your game's joystick setting to use *Sinclair* - or sometimes it is also called *Interface 2* - and everything will "just work" because most games are supporting *Sinclair* and are configured to use the "right" joystick port for player 1.

There were several competing [Joystick Standards](http://www.retroisle.com/general/spectrum_joysticks.php) for the ZX Spectrum. We are supporting:

* Kempston
* Sinclair P1 ("right" joystick port): Default after power-on
* Sinclair P2 ("left" joystick port)
* Cursor (aka AGF aka Protek)
* Fuller

## Testing your joystick

### Configured as Sinclair P1 (default mode)

1. Insert the SD Card that you prepared in the [[Getting Started]] guide
2. Reset the machine
3. Enter the following two comands (the `LOAD` command is entered by pressing <kbd>J</kbd>):
   ```
   .tapein /zx/tests/testkeys.tap
   LOAD ""
   ```
4. You should see the joystick movements and the pressed fire button on the top right of the screen:

[[/assets/testkeys.png|ZX Spectrum 48k Rubber Keyboard]]

### Configured as Kempston

Enter the following BASIC program and run it. You will see the direction of the pushed joystick and the fire button represented as numbers. You might want to open the [[Keyboard Mapping]] in parallel while you type:

```
10 LET kj = IN 31
20 PRINT AT 5, 5, kj, "  "
30 GO TO 10
RUN
```

Press <kbd>Restore</kbd> to end the program.

## Changing the joystick configuration

If you want to use two joysticks at once, then you need to change the joystick configuration. The configuration is remembered after a reset (e.g. by using the MEGA65 reset button). But the configuration needs to be redone after a power cycle. Here is how you do it:

1. Calculate the number `X` by adding the number `A` and the number `B` (see table below).
2. Reset your MEGA65
3. Type in the following two commands. You produce `OUT` by pressing and releasing <kbd>Ctrl</kbd> (you should see the cursor changing into `E`) and then <kbd>Shift</kbd> + <kbd>O</kbd>. Do not enter `X` literally, but enter the number you calculated, instead.
   ```
   OUT 64571, 6
   OUT 64827, X
   ```

Choose from this table: Which configuration do you want for joystick port #1? This is `A`. Which one for joystick port #2 and for the emulated joystick? This is `B`. The sum of `A` and `B` equals `X`, which you need to use in the above-mentined `OUT` command.

| Joystick Model        | A: Port #1 | B: Port #2 & Emulation
|:----------------------|:-----------|-----------------------
| switched-off          | 0          | 0
| Kempston              | 16         | 1
| Sinclair P1           | 32         | 2
| Sinclair P2           | 48         | 3
| Cursor / AGF / Protek | 64         | 4
| Fuller                | 80         | 5

Example: If you want the joystik in port #1 to act as Kempston and the joystick in port #2 (including the emulated "cursor-key-joystick") to act as Sinclair P1, then `X = A + B = 16 + 2 = 18`.