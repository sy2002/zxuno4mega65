[[/assets/keyboard-48k-rubber-2x.png|ZX Spectrum 48k Rubber Keyboard]]

The ZX Spectrum's keyboard is a very special beast! It is not uncommon that one key is having five different meanings. When you are in **Spectrum 16k/48k** or **Spectrum+** mode, you might want to have this schematic illustration at hand.

## MEGA65 Key Mapping

| MEGA65                  | ZX Spectrum         | Comment
|-------------------------|---------------------|------------------------------------------------------------------
| <kbd>MEGA</kbd>         | SYMBOL SHIFT        | Use the *red* elements in the schematic illustration above.
| <kbd>Right Shift</kbd>  | CAPS SHIFT          | In `K` mode, use the *white* elements above the numbers. In `L` mode use upper case characters.
| <kbd>Left Shift</kbd>   | Smart Shift         | Similar to CAPS SHIFT, but on all MEGA65 keys, that have an alternative "shift-character" visible (such as all numbers, <kbd>:</kbd>, <kbd>;</kbd>, ...), this "shift-character" is being generated instead of sending CAPS SHIFT + \<character\> to the Spectrum. Example: <kbd>Left Shift</kbd> + <kbd>2</kbd> generates double quotes ("), which is what you would expect, when you look at the MEGA65 keyboard. If you used <kbd>Right Shift</kbd> + <kbd>2</kbd> instead (i.e. CAPS SHIFT), then you would have gotten the At character (@).
| <kbd>Ctrl</kbd>         | Extend Mode         | Switch to `E` mode. Equivalent to <kbd>SYMBOL SHIFT</kbd> + <kbd>CAPS SHIFT</kbd>.
| <kbd>Alt</kbd>          | (Sequences)         | Playback those sequences of key strokes on the Spectrum that are necessary to generate special characters. On the MEGA65 keyboard, these special characters are printed in light gray color at the side of some keys. Example: Pressing <kbd>Alt</kbd> + <kbd>/</kbd> generates the backslash `\` on the Spectrum by sending the sequence to enter the `E` mode on the Spectrum and then sending <kbd>SYMBOL SHIFT</kbd> + <kbd>D</kbd> to actually generate the backslash.
| <kbd>Tab</kbd>          | Edit                | Switch to BASIC's line edit mode. Equivalent to <kbd>CAPS SHIFT</kbd> + <kbd>1</kbd>.
| <kbd>Left Arrow</kbd>   | Delete              | Backspace, equivalent to <kbd>CAPS SHIFT</kbd> + <kbd>0</kbd>.
| <kbd>Clr/Home</kbd>     | True Video          | BASIC's non inverted colors, equivalent to <kdb>CAPS SHIFT</kbd> + <kbd>3</kbd>.
| <kbd>Inst/Del</kbd>     | Inv. Video          | BASIC's inverted colors, equivalent to <kbd>CAPS SHIFT</kbd> + <kbd>4</kbd>.
| <kbd>Restore</kbd>      | Break               | Break command, for example for interrupting BASIC programs. Equivalent to <kbd>CAPS SHIFT</kbd> + <kbd>Space</kbd>
| <kbd>Run/Stop</kbd>     | Graphics            | Switch to `G` mode and back. Equivalent to <kbd>CAPS SHIFT</kbd> + <kbd>9</kbd>
| <kbd>Esc</kbd>          | (NMI)               | Trigger an NMI. In ESXDOS this enters the NMI Browser.
| <kbd>Caps Lock</kbd>    | (Alternate Mapping) | Emulate joysticks via the MEGA65's cursor keys and space (fire).

### Cursor Keys: Standard and Joystick Mode

* The MEGA65's cursor keys behave like expected: They behave like the Spectrum's cursor keys, because they are mapped to the cursor key sequences of the Spectrum as shown in the image above: Spectrum's <kbd>CAPS SHIFT</kbd> + \<5 to 8\>. 

* When the MEGA65 <kbd>Caps Lock</kbd> mode is active, then the cursor keys are by default emulating a Sinclair joystick by mapping the joystick movements to the following numbers: 6=left, 7=right, 8=down, 9=up, 0=fire. The <kbd>Space</kbd> key is mapped to fire in this mode. You can change the configuration of the [[Joysticks]].

### Convenience Functions

In general, the characters and functions shown on a MEGA65 key are mapped as closely as possible to the Spectrum. For example if you press <kbd>Shift</kbd> + <kbd>:</kbd>, then you will receive a <kbd>[</kbd> just like you would expect it, when you look at the MEGA65 keyboard. In the background, the MEGA65 keyboard is sending the sequence to enter `E` mode and then <kbd>SYMBOL SHIFT</kbd> + <kbd>Y</kbd>.

This convenience functions work everywhere possible, see also the information about the <kbd>Alt</kbd> key above.

It works also for the Spectrum's color modes in BASIC, which you can reach on the MEGA65 keyboard via <kbd>Alt</kbd> + \<number key\> (background) and <kbd>Alt</kbd> + <kbd>Shift</kbd> + \<number key\> (foreground).

Have a look at the [ZX Basic Manual](https://worldofspectrum.org/ZXBasicManual/zxmanchap1.html) to learn more about the five edit modes `K`, `L`, `C`, `E` and `G`.