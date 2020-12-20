----------------------------------------------------------------------------------
-- ZX-Uno port for MEGA65
--
-- Keyboard driver
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- MEGA65 port done by sy2002 in 2020 and licensed under GPL v3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keyboard is
port (
   clk      : in std_logic;
       
   -- interface to the MEGA65 keyboard controller       
   kio8     : out std_logic;        -- clock to keyboard
   kio9     : out std_logic;        -- data output to keyboard
   kio10    : in std_logic;         -- data input from keyboard
      
   -- interface to ZXUNO's internal logic ("emulate PS/2")
   new_key        : buffer std_logic;
   scancode       : out std_logic_vector(7 downto 0);
   released       : out std_logic;
   extended       : out std_logic;   
   shift_pressed  : out std_logic;
   ctrl_pressed   : out std_logic;
   alt_pressed    : out std_logic;
   mega_pressed   : out std_logic
);
end keyboard;

architecture beh of keyboard is

-- connectivity for the MEGA65 hardware keyboard controller
signal matrix_col          : std_logic_vector(7 downto 0);
signal matrix_col_idx      : integer range 0 to 9 := 0;
signal key_delete          : std_logic;
signal key_return          : std_logic;
signal key_fast            : std_logic;
signal key_restore_n       : std_logic;
signal key_capslock_n      : std_logic;
signal key_left            : std_logic;
signal key_up              : std_logic;

-- connectivity for MEGA65 keyboard matrix to ASCII converter
signal ascii_key           : unsigned(7 downto 0);
signal ff_ascii_key        : std_logic_vector(7 downto 0) := x"00";
signal bucky_key           : std_logic_vector(6 downto 0);
signal ascii_key_valid     : std_logic;

signal delay               : integer range 0 to 1400000 := 0;

begin

   -- signal special keys to ZXUNO's logic
   ctrl_pressed   <= bucky_key(2);
   alt_pressed    <= bucky_key(4);
   shift_pressed  <= bucky_key(0) or bucky_key(1);
   mega_pressed   <= bucky_key(3);

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
      
       delete_out       => key_delete,
       return_out       => key_return,
       fastkey_out      => key_fast,
       
       -- RESTORE and capslock are active low
       restore          => key_restore_n,
       capslock_out     => key_capslock_n,
      
       -- LEFT and UP cursor keys are active HIGH
       leftkey          => key_left,
       upkey            => key_up
   );
   
   m65matrix_to_ascii : entity work.matrix_to_ascii
   generic map
   (
      scan_frequency    => 1000,
      clock_frequency   => 28000000      
   )
   port map
   (
      clk               => clk,
      reset_in          => '0',

      matrix_col => matrix_col,
      matrix_col_idx => matrix_col_idx,

      suppress_key_glitches => '1',
      suppress_key_retrigger => '0',
      
      key_up => key_up,
      key_left => key_left,
      key_caps => key_capslock_n,
      
      ascii_key => ascii_key,
      bucky_key => bucky_key,
      ascii_key_valid => ascii_key_valid        
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
   
   ascii_to_ps2 : process(clk)
      variable sc: std_logic_vector(7 downto 0);
   begin     
      case ascii_key is
      
         -- numbers 0 .. 9
         when x"30"  => sc := x"45";   -- 0
         when x"31"  => sc := x"16";   -- 1
         when x"32"  => sc := x"1E";   -- 2
         when x"33"  => sc := x"26";   -- 3
         when x"34"  => sc := x"25";   -- 4
         when x"35"  => sc := x"2E";   -- 5
         when x"36"  => sc := x"36";   -- 6
         when x"37"  => sc := x"3D";   -- 7
         when x"38"  => sc := x"3E";   -- 8
         when x"39"  => sc := x"46";   -- 9
         
         -- characters a .. z
         when x"61"  => sc := x"1C";   -- A
         when x"62"  => sc := x"32";   -- B
         when x"63"  => sc := x"21";   -- C
         when x"64"  => sc := x"23";   -- D
         when x"65"  => sc := x"24";   -- E
         when x"66"  => sc := x"2B";   -- F
         when x"67"  => sc := x"34";   -- G
         when x"68"  => sc := x"33";   -- H
         when x"69"  => sc := x"43";   -- I
         when x"6A"  => sc := x"3B";   -- J
         when x"6B"  => sc := x"42";   -- K
         when x"6C"  => sc := x"4B";   -- L
         when x"6D"  => sc := x"3A";   -- M
         when x"6E"  => sc := x"31";   -- N
         when x"6F"  => sc := x"44";   -- O
         when x"70"  => sc := x"4D";   -- P
         when x"71"  => sc := x"15";   -- Q
         when x"72"  => sc := x"2D";   -- R
         when x"73"  => sc := x"1B";   -- S
         when x"74"  => sc := x"2C";   -- T
         when x"75"  => sc := x"3C";   -- U
         when x"76"  => sc := x"2A";   -- V
         when x"77"  => sc := x"1D";   -- W
         when x"78"  => sc := x"22";   -- X
         when x"79"  => sc := x"35";   -- Y (U.S. keyboard layout)
         when x"7A"  => sc := x"1A";   -- Z (ditto)
         
         -- special keys
         when x"14"  => sc := x"66";   -- Backspace
         when x"20"  => sc := x"29";   -- Space
         when x"0D"  => sc := x"5A";   -- Enter                  
         when others => sc := x"00";
      end case;
   
      if rising_edge(clk) then
         new_key <= '0';
         extended <= '0';          
         released <= '1';
         
         if delay = 700000 then
            delay <= 0;
            new_key <= '1';
         elsif delay > 0 then
            delay <= delay + 1;
            released <= '0';
         end if;
                              
         if ascii_key_valid = '1' then
            new_key <= '1';            
            scancode <= sc;
            delay <= 1;
            released <= '0';
         end if;
                  
      end if;
   end process;
      
end beh;
