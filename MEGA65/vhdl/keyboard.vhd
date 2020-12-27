--------------------------------------------------------------------------------------
-- ZX-Uno port for MEGA65
--
-- Keyboard driver which includes the mapping of the MEGA 65 keys to ZX Uno keys
--
-- Terminology: CS = Spectrum's CAPS SHIFT            (MEGA65's right shift key)
--              SS = Spectrum's SYMBOL SHIFT          (MEGA65 key)
--              MS = MEGA65's Convenience Shift Key   (MEGA65's left shift key)
--             ALT = MEGA65's Convenience Alt Key     (MEGA65' Alt key)
--
-- The keyboard mapping includes a "Convenience Shift Key", which is meant to
-- simplify entering special characters. The MEGA65's left shift key is the
-- convenience shift key and the right shift key is the Spectrum's CAPS SHIFT (CS).
-- Example: When pressing the Convenience Shift + 2, then the keyboard driver
-- will generate SS + P to generate " (double quotes), because this is what you
-- would expect when looking at the MEGA65 keyboard. In situations, where there
-- is no special shift character available on the MEGA65's keyboard, the MS
-- key behaves just like this CS key.
--
-- ALT is used to generate sequences of keys on the Spectrum to conveniently produce
-- special characters. Example: ALT + , produces ~ by first switching to spectrum's
-- "E" mode via CS + SS and then pressing SS + A. 
--
-- If you want the native Spectrrum behavior, then you use the MEGA65's right
-- shift key, which is always mapped to be the CAPS SHIFT.
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- MEGA65 port done by sy2002 in 2020 and licensed under GPL v3
-- Keyboard mapping as defined by Andrew Owen in December 2020
--------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keyboard is
port (
   clk         : in std_logic;         -- assumes a 28 MHz clock 
       
   -- interface to the MEGA65 keyboard controller       
   kio8        : out std_logic;        -- clock to keyboard
   kio9        : out std_logic;        -- data output to keyboard
   kio10       : in std_logic;         -- data input from keyboard
      
   -- interface to ZXUNO's internal logic
   row_select  : in std_logic_vector(7 downto 0);  -- query Spectrum's matrix
   col_data    : out std_logic_vector(4 downto 0); -- return value of query
   user_nmi    : out std_logic;                    -- NMI key (ESC) pressed
   joystick    : out std_logic_vector(4 downto 0)  -- CAPS LOCK on: use cursor keys as joystick   
);
end keyboard;

architecture beh of keyboard is

constant CLOCK_SPEED       : integer := 28000000;
constant SEQ_SPEED         : integer := (CLOCK_SPEED / 1000) * 50; -- 50ms delay between sequence actions at 28 MHz
constant SEQ_MAXLEN        : integer := 18;


signal matrix_col          : std_logic_vector(7 downto 0);
signal matrix_col_idx      : integer range 0 to 9 := 0;
signal key_num             : integer range 0 to 79;
signal key_status_n        : std_logic;

-- Special key signalling: key_* is high, if special key is pressed during the current scan cycle
-- The "matrix_to_keynum" component is using registers to store the status during the scan cycle
signal bucky_key           : std_logic_vector(6 downto 0);
signal key_shift_left      : std_logic;
signal key_shift_right     : std_logic;
signal key_ctrl            : std_logic;
signal key_mega            : std_logic;
signal key_alt             : std_logic;

-- Special keys that are not mapped to and not used in context of the Spectrum's matrix
signal key_esc             : std_logic;
signal m65_capslock_n      : std_logic;

-- CAPS LOCK on: use the cursor keys as joystick
signal cursor_as_joystick  : boolean;

-- [ (MS + :) and ] (MS + ;) need a special treatment, because they are the only keys, that are
-- utilizing the sequencer without the need of the ALT key to be pressed.
signal key_seq             : boolean;

-- Spectrum's keyboard matrix: low active matrix with 8 rows and 5 columns
-- Refer to "doc/assets/spectrum_keyboard_ports.png" to learn how it works
type matrix_reg_t is array(0 to 7) of std_logic_vector(4 downto 0);
signal matrix : matrix_reg_t := (others => "11111");  -- low active, i.e. "11111" means "no key pressed"

-- Remember, if a certain matrix key has been set automatically as a key combo so that the raw keyscan will not delete it later.
-- Example: Consider "Inst/Del", which is mapped to "Inv. Video" aka CS+4: As "Inst/Del" is key_num zero, it would activate
-- CS and "4" at the 0th iteration. Now "4" is at the 11th iteration and would reset "4" back to "not pressed". This is why
-- we need to remember, that we did autoset this key combo by "and-ing" the autoset status to what we receive from
-- the MEGA keyboard. "And-ing" due to the negativ-active logic.

signal autoset_m : std_logic_vector(79 downto 0) := (others => '1');
signal autoset_u : matrix_reg_t := (others => "11111");
signal msca_m    : std_logic_vector(79 downto 0) := (others => '1');
signal msca_u    : matrix_reg_t := (others => "11111");

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
-- 4. The ALT key is used to trigger sequences of keys on the Spectrum to retrieve special characters.
--    If such a sequence is supported, then "seq_mode" needs to be true and "seq_prg" needs to contain the
--    number of the sequence (program) to execute.
type mapping_record_t is record
   first_active   : boolean;
   first_row      : integer range 0 to 7;
   first_col      : integer range 0 to 5;
   second_active  : boolean;
   second_row     : integer range 0 to 7;
   second_col     : integer range 0 to 5;
   msca           : boolean;                 -- MEGA65's Convencience Shift Key active
   ca1_row        : integer range 0 to 7;
   ca1_col        : integer range 0 to 5;
   ca2_row        : integer range 0 to 7;
   ca2_col        : integer range 0 to 5;
   seq_mode       : boolean;
   seq_prg        : integer range 0 to SEQ_MAXLEN;
end record;

type mapping_t is array(0 to 79) of mapping_record_t;

constant mapping : mapping_t := (                                      -- MEGA 65          => ZX Uno
   0  => (true,   0, 0, true,   3, 3, false, 0, 0, 0, 0, false, 0),    -- Inst/Del         => Inv. Video: CS + 4
   1  => (true,   6, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- Return           => Enter
   2  => (true,   0, 0, true,   4, 2, false, 0, 0, 0, 0, false, 0),    -- Cursor Right     => Cursor Right: CS + 8
   3  => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),      
   4  => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),      
   5  => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),      
   6  => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),      
   7  => (true,   0, 0, true,   4, 4, false, 0, 0, 0, 0, false, 0),    -- Cursor Down       => Cursor Down: CS + 6    
   8  => (true,   3, 2, false,  0, 0, true,  7, 1, 3, 2, true, 11),    -- 3 | # (MS + 3)    => 3 | # (SS + 3)
                                                                       --   | Red (ALT + 3) => Red: SEQ 11 (CS + SS, 2)      
   9  => (true,   2, 1, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- W                 => W    
   10 => (true,   1, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- A                 => A     
   11 => (true,   3, 3, false,  0, 0, true,  7, 1, 3, 3, true, 12),    -- 4 | $ (MS + 4)    => 4 | $ (SS + 4)
                                                                       --   | Cyn (ALT + 4) => Cyan: SEQ 12 (CS + SS, 5)    
   12 => (true,   0, 1, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- Z                 => Z      
   13 => (true,   1, 1, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- S                 => S      
   14 => (true,   2, 2, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- E                 => E      
   15 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),      
   16 => (true,   3, 4, false,  0, 0, true,  7, 1, 3, 4, true, 13),    -- 5 | % (MS + 5)    => 5 | % (SS + 5)
                                                                       --   | Pur (ALT + 5) => Magenta: SEQ 13 (CS + SS, 3)   
   17 => (true,   2, 3, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- R                 => R      
   18 => (true,   1, 2, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- D                 => D      
   19 => (true,   4, 4, false,  0, 0, true,  7, 1, 4, 4, true, 14),    -- 6 | & (MS + 6)    => 6 | & (SS + 6)
                                                                       --   | Grn (ALT + 6) => Green: SEQ 14 (CS + SS, 4)
   20 => (true,   0, 3, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- C                 => C      
   21 => (true,   1, 3, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- F                 => F      
   22 => (true,   2, 4, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- T                 => T      
   23 => (true,   0, 2, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- X                 => X      
   24 => (true,   4, 3, false,  0, 0, true,  7, 1, 4, 3, true, 15),    -- 7 | ' (MS + 7)    => 7 | ' (SS + 7)
                                                                       --   | Blu (ALT +7 ) => Blue: SEQ 15 (CS + SS, 1)       
   25 => (true,   5, 4, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- Y                 => Y      
   26 => (true,   1, 4, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- G                 => G      
   27 => (true,   4, 2, false,  0, 0, true , 7, 1, 4, 2, true, 16),    -- 8 | ( (MS + 8)    => 8 | ( (SS + 8)
                                                                       --   | Yel (ALT + 8) => Yellow: SEQ 16 (CS + SS, 6)      
   28 => (true,   7, 4, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- B                 => B
   29 => (true,   6, 4, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- H                 => H      
   30 => (true,   5, 3, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- U                 => U      
   31 => (true,   0, 4, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- V                 => V      
   32 => (true,   4, 1, false,  0, 0, true,  7, 1, 4, 1, true, 17),    -- 9 | ) (MS + 9)    => 9 | ) (SS + 9)
                                                                       --   | Rvs On (ALT + 9) => Inv. Video: SEQ 17 (CS + 4) 
   33 => (true,   5, 2, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- I                 => I      
   34 => (true,   6, 3, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- J                 => J      
   35 => (true,   4, 0, false,  0, 0, false, 0, 0, 0, 0, true, 18),    -- 0 |               => 0
                                                                       --   | Rvs Off (ALT + 0) => True Video: SEQ 18 (CS + 3)
   36 => (true,   7, 2, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- M                 => M
   37 => (true,   6, 2, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- K                 => K      
   38 => (true,   5, 1, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- O                 => O  
   39 => (true,   7, 3, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- N                 => N      
   40 => (true,   7, 1, true,   6, 2, false, 0, 0, 0, 0, false, 0),    -- +                 => +: SS + K       
   41 => (true,   5, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- P                 => P     
   42 => (true,   6, 1, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- L                 => L      
   43 => (true,   7, 1, true,   6, 3, false, 0, 0, 0, 0, false, 0),    -- -                 => -: SS + J
   44 => (true,   7, 1, true,   7, 2, true,  7, 1, 2, 4, true,  2),    -- . | > (MS + .)    => .: SS + M | > (SS + T)
                                                                       --   | | (ALT + .)   => |: SEQ 2 (CS + SS, SS + S)       
   45 => (true,   7, 1, true,   0, 1, false, 0, 0, 0, 0, true,  4),    -- :                 => :: SS + Z
                                                                       --   | { (ALT + :)   => {: SEQ 4 (CS + SS, SS + F)      
   46 => (true,   7, 1, true ,  3, 1, false, 0, 0, 0, 0, false, 0),    -- @                 => @: SS + 2      
   47 => (true,   7, 1, true,   7, 3, true,  7, 1, 2, 3, true,  1),    -- , | < (MS + ,)    => ,: SS + N | < (SS + R)  
                                                                       --   | ~ (ALT + ,)   => ~: SEQ 1 (CS + SS, SS + A)
   48 => (true,   7, 1, true,   0, 2, false, 0, 0, 0, 0, false, 0),    -- British Pound     => British Pound: SS + X      
   49 => (true,   7, 1, true,   7, 4, false, 0, 0, 0, 0, false, 0),    -- *                 => *: SS + B      
   50 => (true,   7, 1, true,   5, 1, false, 0, 0, 0, 0, true,  5),    -- ;                 => ;: SS + O
                                                                       --   | } (ALT + ;)   => }: SEQ 5 (CS + SS, SS + G)      
   51 => (true,   0, 0, true,   3, 2, false, 0, 0, 0, 0, false, 0),    -- Clr/Home          => True Video: CS + 3     
   52 => (true,   0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- Right Shift       => Caps Shift (CS)    
   53 => (true,   7, 1, true,   6, 1, false, 0, 0, 0, 0, true,  0),    -- = | _ (ALT + =)   => =: SS + L | _: SEQ 0 (SS + 0)      
   54 => (true,   7, 1, true,   6, 4, false, 0, 0, 0, 0, true,  8),    -- Arrow-up          => Arrow up: SS + H
                                                                       -- (pi) (ALT + Arrow-up) => (c) (copyright): SEQ 8 (CS + SS, SS + P)
   55 => (true,   7, 1, true,   0, 4, true,  7, 1, 0, 3, true,  3),    -- / | ? (MS + /)    => /: SS + V | ? (SS + C)
                                                                       --   | \ (ALT + /)   => \: SEQ 3 (CS + SS, SS + D)       
   56 => (true,   3, 0, false,  0, 0, true , 7, 1, 3, 0, true,  9),    -- 1 | ! (MS + 1)    => 1 | ! (SS + 1)
                                                                       --   | Blk (Alt + 1) => Black: SEQ 9 (CS + SS, 0)
   57 => (true,   0, 0, true ,  4, 0, false, 0, 0, 0, 0, false, 0),    -- Arrow-left        => Delete: CS + 0          
   58 => (true,   0, 0, true,   7, 1, false, 0, 0, 0, 0, false, 0),    -- Ctrl              => Extend Mode: CS + SS       
   59 => (true,   3, 1, false,  0, 0, true , 7, 1, 5, 0, true, 10),    -- 2 | " (MS + 2)    => 2 | " (SS + P)
                                                                       --   | Wht (Alt + 2) => White: SEQ 10 (CS + SS, 7)      
   60 => (true,   7, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- Space             => Space      
   61 => (true,   7, 1, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- Mega65            => Symbol Shift (SS)   
   62 => (true,   2, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),    -- Q                 => Q    
   63 => (true,   0, 0, true,   4, 1, false, 0, 0, 0, 0, false, 0),    -- Run/Stop          => Graphics: CS + 9      
   64 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),      
   65 => (true,   0, 0, true ,  3, 0, false, 0, 0, 0, 0, false, 0),    -- Tab               => Edit: CS + 1      
   66 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),
   67 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),
   68 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),
   69 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),
   70 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),
   71 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),
   72 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),
   73 => (true,   0, 0, true,   4, 3, false, 0, 0, 0, 0, false, 0),    -- Cursor Up         => Cursor Up: CS + 7
   74 => (true,   0, 0, true,   3, 4, false, 0, 0, 0, 0, false, 0),    -- Cursor Left       => Cursor Left: CS + 5
   75 => (true,   0, 0, true,   7, 0, false, 0, 0, 0, 0, false, 0),    -- Restore           => Break: CS + Space
   76 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),
   77 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),
   78 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0),
   79 => (false,  0, 0, false,  0, 0, false, 0, 0, 0, 0, false, 0)
);

type sequence_record_t is record
   size           : integer range 2 to 4;
   s1_1_row       : integer range 0 to 7;
   s1_1_col       : integer range 0 to 4;
   s1_2_row       : integer range 0 to 7;
   s1_2_col       : integer range 0 to 4;
   s2_1_row       : integer range 0 to 7;
   s2_1_col       : integer range 0 to 4;
   s2_2_row       : integer range 0 to 7;
   s2_2_col       : integer range 0 to 4;   
end record;

type sequence_t is array(0 to SEQ_MAXLEN) of sequence_record_t;

constant seq : sequence_t := (
   0  => (2, 7, 1, 4, 0, 0, 0, 0, 0),   -- SEQ 0:    _ => SS + 0 
   1  => (4, 0, 0, 7, 1, 7, 1, 1, 0),   -- SEQ 1:    ~ => CS + SS, SS + A
   2  => (4, 0, 0, 7, 1, 7, 1, 1, 1),   -- SEQ 2:    | => CS + SS, SS + S    
   3  => (4, 0, 0, 7, 1, 7, 1, 1, 2),   -- SEQ 3:    \ => CS + SS, SS + D
   4  => (4, 0, 0, 7, 1, 7, 1, 1, 3),   -- SEQ 4:    { => CS + SS, SS + F
   5  => (4, 0, 0, 7, 1, 7, 1, 1, 4),   -- SEQ 5:    } => CS + SS, SS + G
   6  => (4, 0, 0, 7, 1, 7, 1, 5, 4),   -- SEQ 6:    [ => CS + SS, SS + Y
   7  => (4, 0, 0, 7, 1, 7, 1, 5, 3),   -- SEQ 7:    ] => CS + SS, SS + U
   8  => (4, 0, 0, 7, 1, 7, 1, 5, 0),   -- SEQ 8:  (c) => CS + SS, SS + P
   9  => (3, 0, 0, 7, 1, 4, 0, 0, 0),   -- SEQ 9:  Blk => CS + SS, 0    
   10 => (3, 0, 0, 7, 1, 4, 3, 0, 0),   -- SEQ 10: Wht => CS + SS, 7
   11 => (3, 0, 0, 7, 1, 3, 1, 0, 0),   -- SEQ 11: Red => CS + SS, 2
   12 => (3, 0, 0, 7, 1, 3, 4, 0, 0),   -- SEQ 12: Cyn => CS + SS, 5
   13 => (3, 0, 0, 7, 1, 3, 2, 0, 0),   -- SEQ 13: Pur => CS + SS, 3    (Purple => Magenta)
   14 => (3, 0, 0, 7, 1, 3, 3, 0, 0),   -- SEQ 14: Grn => CS + SS, 4
   15 => (3, 0, 0, 7, 1, 3, 0, 0, 0),   -- SEQ 15: Blu => CS + SS, 1
   16 => (3, 0, 0, 7, 1, 4, 4, 0, 0),   -- SEQ 16: Yel => CS + SS, 6
   17 => (2, 0, 0, 3, 3, 0, 0, 0, 0),   -- SEQ 17: Rvs On => CS + 4     (Reverse On => Inv. Video)
   18 => (2, 0, 0, 3, 2, 0, 0, 0, 0)    -- SEQ 18: Rvs Off => CS + 3    (Reverse Off => True Video)
 );

type sequencer_t is (seq_none, seq_start, seq_1, seq_clear, seq_2, seq_end);
signal sequencer        : sequencer_t := seq_none;
signal seq_next         : sequencer_t := seq_none;
signal seq_active       : integer range 0 to SEQ_MAXLEN;
signal seq_active_next  : integer range 0 to SEQ_MAXLEN;
signal seq_delay        : integer range 0 to SEQ_SPEED;
signal seq_delay_start  : boolean;

begin

   -- ESC is the NMI key (e.g. for being used in ESXDOS)
   user_nmi          <= key_esc;

   -- high if the special key is pressed during the current scan cycle
   key_shift_left    <= bucky_key(0);
   key_shift_right   <= bucky_key(1);
   key_ctrl          <= bucky_key(2);
   key_mega          <= bucky_key(3);
   key_alt           <= bucky_key(4);
   
   -- special handling for "[" and "]" on the MEGA65 keyboard (see comments above)
   key_seq           <= key_alt = '1' or (key_status_n = '0' and key_shift_left = '1' and (key_num = 45 or key_num = 50));

   m65driver : entity work.mega65kbd_to_matrix
   port map
   (
       ioclock          => clk,
      
       flopmotor        => '0',
       flopled          => '0',
       powerled         => '1',    
       
       kio8             => kio8,
       kio9             => kio9,
       kio10            => kio10,
      
       matrix_col       => matrix_col,
       matrix_col_idx   => matrix_col_idx,
       
       capslock_out     => m65_capslock_n     
   );
   
   m65matrix_to_keynum : entity work.matrix_to_keynum
   generic map
   (
      scan_frequency    => 1000,
      clock_frequency   => CLOCK_SPEED      
   )
   port map
   (
      clk               => clk,
      reset_in          => '0',

      matrix_col => matrix_col,
      matrix_col_idx => matrix_col_idx,
      
      m65_key_num => key_num,
      m65_key_status_n => key_status_n,
      
      suppress_key_glitches => '1',
      suppress_key_retrigger => '0',
      
      bucky_key => bucky_key      
   );
   
   matrix_col_idx_handler : process(clk)
   begin
      if rising_edge(clk) then
         if matrix_col_idx < 9 then
           matrix_col_idx <= matrix_col_idx + 1;
         else
           matrix_col_idx <= 0;
         end if;      
      end if;
   end process;      
   
   -- fill the matrix registers that will be read by the ZX Uno
   -- support two ZX Uno matrix entries per pressed MEGA key for the end user's convenience
   write_matrix : process(clk)
      variable m : mapping_record_t;
      variable s : sequence_record_t;
      variable shifted_color_keys : boolean;
      variable cursor_as_joystick : boolean;
      constant joy_up     : integer := 73; -- cursor up
      constant joy_down   : integer := 7;  -- cursor down
      constant joy_left   : integer := 74; -- cursor left
      constant joy_right  : integer := 2;  -- cursor right
      constant joy_fire   : integer := 60; -- space
   begin
      if rising_edge(clk) then
         --------------------------------------------------------------------------------------
         -- Handle keys that are not part of the Spectrum's matrix
         --------------------------------------------------------------------------------------     
         if key_num = 71 then
            key_esc <= not key_status_n;
         end if;
         
         -- if CAPS LOCK is on, then handle cursor keys and space as joystick
         if m65_capslock_n = '0' and (key_num = joy_up   or key_num = joy_down  or 
                                      key_num = joy_left or key_num = joy_right or key_num = joy_fire) then
            cursor_as_joystick := true;
            case key_num is
               when joy_right => joystick(0) <= not key_status_n;
               when joy_left  => joystick(1) <= not key_status_n;
               when joy_down  => joystick(2) <= not key_status_n;
               when joy_up    => joystick(3) <= not key_status_n;
               when joy_fire  => joystick(4) <= not key_status_n;
               when others    => null;
            end case;
         else
            cursor_as_joystick := false;
         end if;
         if m65_capslock_n = '1' then
            joystick <= "00000";
         end if;         
                        
         --------------------------------------------------------------------------------------
         -- None-sequenced mode: Read actual keypresses from the keyboard
         --------------------------------------------------------------------------------------
         if sequencer = seq_none and not key_seq and not cursor_as_joystick then
            m := mapping(key_num);         
            -- key is currently pressed and ALT is not pressed, because ALT starts the sequencer
            if key_status_n = '0' then         
               -- standard operation: no MEGA65's Convencience Shift Key (MS) pressed or no special treatment available          
               if (key_shift_left = '0') or (not m.msca) then
                  if m.first_active then
                     matrix(m.first_row)(m.first_col)       <= '0';
                  end if;
                  if m.second_active then
                     autoset_m(key_num)                     <= '0';  -- remember standard autoset
                     autoset_u(m.first_row)(m.first_col)    <= '0';
                     autoset_u(m.second_row)(m.second_col)  <= '0';
                     matrix(m.second_row)(m.second_col)     <= '0';  -- set Spectrum's matrix          
                  end if;

               -- convenience mode via MEGA65's Convencience Shift Key (MS)           
               else
                  msca_m(key_num)                           <= '0';  -- remember MS autoset
                  msca_u(m.ca1_row)(m.ca1_col)              <= '0';
                  msca_u(m.ca2_row)(m.ca2_col)              <= '0';               
                  matrix(m.ca1_row)(m.ca1_col)              <= '0';
                  matrix(m.ca2_row)(m.ca2_col)              <= '0';  -- set Spectrum's matrix
                  
                  -- prevent glitch that when you release MS while the combo (e.g. MS + 2) is pressed
                  -- and then press MS again, that you have then one extra active key
                  if m.first_active and not (m.first_row = m.ca1_row and m.first_col = m.ca1_col) and
                                        not (m.first_row = m.ca2_row and m.first_col = m.ca2_col) then
                     matrix(m.first_row)(m.first_col)       <= '1' and autoset_u(m.first_row)(m.first_col);
                  end if;
                  if m.second_active and not (m.second_row = m.ca1_row and m.second_col = m.ca1_col) and
                                         not (m.second_row = m.ca2_row and m.second_col = m.ca2_col) then
                     matrix(m.second_row)(m.second_col)     <= '1' and autoset_u(m.second_row)(m.second_col);
                  end if;               
               end if;
            
            -- key is currently released: we prevent releasing an autoset key (standard or msca) by and-ing
            -- the Spectrum's matrix value with our remembered autoset matrices
            else
               if m.first_active then
                  matrix(m.first_row)(m.first_col)          <= '1' and autoset_u(m.first_row)(m.first_col)
                                                                   and msca_u(m.first_row)(m.first_col);
               end if;
               if m.second_active and autoset_m(key_num) = '0' then
                  autoset_m(key_num)                        <= '1';
                  autoset_u(m.first_row)(m.first_col)       <= '1';
                  autoset_u(m.second_row)(m.second_col)     <= '1';
                  matrix(m.second_row)(m.second_col)        <= '1' and msca_u(m.second_row)(m.second_col);
               end if;
               if m.msca and msca_m(key_num) = '0' then
                  msca_m(key_num)                           <= '1';
                  msca_u(m.ca1_row)(m.ca1_col)              <= '1';
                  msca_u(m.ca2_row)(m.ca2_col)              <= '1';
                  matrix(m.ca1_row)(m.ca1_col)              <= '1' and autoset_u(m.ca1_row)(m.ca1_col);
                  matrix(m.ca2_row)(m.ca2_col)              <= '1' and autoset_u(m.ca2_row)(m.ca2_col);
               end if;
            end if;               
            
            -- If the MEGA65's MEGA key (SS) or right shift (CS) is being pressed, then
            -- this has precedence over all decisions we made above
            if key_shift_right = '1' then matrix(0)(0) <= '0'; end if;
            if key_mega        = '1' then matrix(7)(1) <= '0'; end if;
            
            -- Releasing the MS key means that all remembered convenience combos are gone
            if key_shift_left  = '0' then
               msca_m <= (others => '1');
               msca_u <= (others => "11111");
               
            -- Pressing the MS key while no special convenience combo is active means: MS behaves like CS
            elsif msca_m = "11111111111111111111111111111111111111111111111111111111111111111111111111111111" then
               matrix(0)(0) <= '0';
            end if;
         
         --------------------------------------------------------------------------------------
         -- Sequenced mode: Play back pre-recorded key combos
         --------------------------------------------------------------------------------------         
         elsif not cursor_as_joystick then
            s := seq(seq_active);
            
            -- special case: The MEGA65's color keys produce the background color when not shifted
            -- and the frontend color when shifted: By changing the length of the sequence from 3 to 4,
            -- the final (0, 0) will lead the the shift key being pressed on the Spectrum
            shifted_color_keys := seq_active >= 9 and seq_active <= 18 and (key_shift_left = '1' or key_shift_right = '1');
            
            case sequencer is
               when seq_start | seq_clear | seq_end =>
                  matrix      <= (others => "11111");
                  autoset_u   <= (others => "11111");
                  msca_u      <= (others => "11111");
                  autoset_m   <= (others => '1');
                  msca_m      <= (others => '1');
                  
               when seq_1 =>
                  matrix(s.s1_1_row)(s.s1_1_col) <= '0';
                  matrix(s.s1_2_row)(s.s1_2_col) <= '0';
                  
               when seq_2 =>
                  matrix(s.s2_1_row)(s.s2_1_col) <= '0';
                  if s.size = 4 or shifted_color_keys then
                     matrix(s.s2_2_row)(s.s2_2_col) <= '0';
                  end if;
                  
               when others =>
                  null;                  
            end case;
         end if;
      end if;
   end process;
   
   -- return matrix to Spectrum
   -- (refer to "doc/assets/spectrum_keyboard_ports.png" for the "row_select" encoding)
   read_matrix : process(row_select)
   begin
      case row_select is
         when "11111110" => col_data <= matrix(0);
         when "11111101" => col_data <= matrix(1);
         when "11111011" => col_data <= matrix(2);
         when "11110111" => col_data <= matrix(3);
         when "11101111" => col_data <= matrix(4);
         when "11011111" => col_data <= matrix(5);
         when "10111111" => col_data <= matrix(6);
         when "01111111" => col_data <= matrix(7);
         when others => col_data <= "11111";
      end case;
   end process;
   
   sequencer_fsm : process(clk)
   begin
      if rising_edge(clk) then
         sequencer   <= seq_next;
         seq_active  <= seq_active_next;
         
         if seq_delay_start then
            seq_delay <= SEQ_SPEED;
         elsif seq_delay /= 0 then
            seq_delay <= seq_delay - 1;
         end if;         
      end if;
   end process;
   
   sequencer_control : process(sequencer, seq_active, key_seq, key_alt, key_num, key_status_n, seq_delay)
   begin
      seq_next          <= seq_none;
      seq_active_next   <= seq_active;      
      seq_delay_start   <= false;
      
      if sequencer = seq_none then           
         if key_seq and key_status_n = '0' and mapping(key_num).seq_mode then
            seq_next        <= seq_start;
            seq_delay_start <= true;
            -- standard case: the sequence was initiated using ALT + <key>
            if key_alt = '1' then
               seq_active_next <= mapping(key_num).seq_prg;            
            -- special treatment for [ and ] necessary (see comments above), because the sequence
            -- is initiated by MS instead of ALT, so we hardcode the sequence numbers here
            else            
               if key_num = 45 then
                  seq_active_next <= 6; -- SEQ 6: [
               elsif key_num = 50 then
                  seq_active_next <= 7; -- SEQ 7: ]
               end if; 
            end if;                    
         end if;         
      else
         if seq_delay /= 0 then
            seq_next <= sequencer;
         else
            seq_delay_start <= true;
            case sequencer is
               when seq_start => seq_next <= seq_1;
               when seq_1     => seq_next <= seq_clear;
               when seq_clear =>
                  if seq(seq_active).size > 2 then
                     seq_next <= seq_2;
                  else
                     seq_next <= seq_none;
                  end if;
               when seq_2     => seq_next <= seq_end;
               when seq_end   => seq_next <= seq_none;
               when others    => seq_next <= seq_none;
            end case;
         end if; 
      end if;
   end process;       
end beh;
