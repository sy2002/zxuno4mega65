Keyboard
========

-- Keyboard driver which includes the mapping of the MEGA 65 keys to ZX Uno keys
--
-- Terminology: CS = Spectrum's CAPS SHIFT    (MEGA65's right shift key)
--              SS = Spectrum's SYMBOL SHIFT  (MEGA65 key)
--              Convencience Shift Key        (MEGA65's left shift key)
--
-- The keyboard mapping includes a "Convenience Shift Key", which is meant to
-- simplify entering special characters. The MEGA65's left shift key is the
-- convenience shift key and the right shift key is the Spectrum's CAPS SHIFT.
-- Example: When pressing the Convenience Shift + 2, then the keyboard driver
-- will generate SS + P to generate " (double quotes), because this is what you
-- would expect when looking at the MEGA65 keyboard.
--
-- If you want the native Spectrrum behavior, then you use the MEGA65's right
-- shift key, which is always mapped to be the CAPS SHIFT.
