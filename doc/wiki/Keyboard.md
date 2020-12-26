![ZX Spectrum 48k Rubber Keyboard](https://raw.githubusercontent.com/sy2002/zxuno4mega65/master/doc/assets/keyboard-48k-rubber-2x.png)

The ZX Spectrum's keyboard is a very special beast! It is not uncommon that one key is having five different meanings. When you are in **Spectrum 16k/48k** or **Spectrum+** mode, you might want to have this schematic illustration at hand.

## MEGA65 key mapping

| MEGA65                  | ZX Spectrum     | Comment
|-------------------------|-----------------|------------------------------------------------------------------
| <kbd>MEGA</kbd>         | SYMBOL SHIFT    | Use the *red* elements in the schematic illustration above.
| <kbd>Right Shift</kbd>  | CAPS SHIFT      | In `K` mode, use the *white* elements above the numbers. In `L` mode use upper case characters.
| <kbd>Left Shift</kbd>   | Smart Shift     | Similar to CAPS SHIFT, but on all MEGA65 keys, that have an alternative "shift-character" visible (such as all numbers, <kbd>:</kbd>, <kbd>;</kbd>, ...), this "shift-character" is being generated instead of sending CAPS SHIFT + \<character\> to the Spectrum. Example: <kbd>Left Shift</kbd> + <kbd>2</kbd> generates double quotes ("), which is what you would expect, when you look at the MEGA65 keyboard. If you used <kbd>Right Shift</kbd> + <kbd>2</kbd> instead (i.e. CAPS SHIFT), then you would have gotten the At character (@) instead.
| <kbd>Alt</kbd>          | (Sequences)     | Playback those sequences of key strokes on the Spectrum that are necessary to generate special characters. On the MEGA65 keyboard, these are characters that you would reach via the MEGA key when the MEGA65 would be in native mode. In this ZX Spectrum core, you need to press <kbd>Alt</kbd> instead. Example: Pressing <kbd>Alt</kbd> + <kbd>/</kbd> generates the backslash `\` on the Spectrum by sending the sequence to enter the `E` mode on the spectrum and then sending <kbd>SYMBOL SHIFT</kbd> + <kbd>D</kbd>.

Have a look at the [ZX Basic Manual](https://worldofspectrum.org/ZXBasicManual/zxmanchap1.html) to learn more about the five edit modes `K`, `L`, `C`, `E` and `G`.