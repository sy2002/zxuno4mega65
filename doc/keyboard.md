Keyboard
========

----------------------------------------------------------------------------------
-- ZX-Uno port for MEGA65
--
-- Keyboard driver which includes the mapping of the MEGA 65 keys to ZX Uno keys
--
-- Terminology: CS = Spectrum's CAPS SHIFT            (MEGA65's right shift key)
--              SS = Spectrum's SYMBOL SHIFT          (MEGA65 key)
--              MS = MEGA65's Convencience Shift Key  (MEGA65's left shift key)
--
-- The keyboard mapping includes a "Convenience Shift Key", which is meant to
-- simplify entering special characters. The MEGA65's left shift key is the
-- convenience shift key and the right shift key is the Spectrum's CAPS SHIFT.
-- Example: When pressing the Convenience Shift + 2, then the keyboard driver
-- will generate SS + P to generate " (double quotes), because this is what you
-- would expect when looking at the MEGA65 keyboard. In situations, where there
-- is no special shift character available on the MEGA65's keyboard, the MS
-- key behaves just like this CS key.
--
-- If you want the native Spectrrum behavior, then you use the MEGA65's right
-- shift key, which is always mapped to be the CAPS SHIFT.
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- MEGA65 port done by sy2002 in 2020 and licensed under GPL v3
-- Keyboard mapping as defined by Andrew Owen in December 2020
----------------------------------------------------------------------------------


-- The mapping works like this: MEGA65's "matrix_to_keynum" component is constantly scanning through all
-- keys of the MEGA65 keyboard: 0..79. For each MEGA65 key, we define the mapping as one of the following options:
-- 1. The MEGA65 key maps to one keypress in the Spectrum matrix. Example: The "A" key maps to row 1 and column 0
--    In this case, "first_active" is true and the other booleans are false. 
-- 2. The MEGA65 key maps to two keypresses in the Spectrum's matrix: Example: "Cursor Up" maps to CS + 7
--    That means in the matrix, row 0 and column 0 as well as row 4 and column 3 needs to be mapped.
--    In this case, "first_active" and "second_active" are true and "convenience_active" is false.
-- 3. The left MEGA65 shift key is the Convenience Shift Key. The idea is to map for example the
--    double quotes (") of the MEGA65 keyboard (MS + 2) to SS + P, so that the Spectrum shows the double quotes, too.
--    In this case, independend of "first_active" and "second_active" which are only meant to be evaluated
--    when MS is not pressed, there is now "convenience_active" = true and the ca* record fields are describing the
--    sequence of Spectrum keys that need to be pressed. 
