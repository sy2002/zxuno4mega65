----------------------------------------------------------------------------------
-- ZX-Uno port for MEGA65
--
-- Keyboard driver
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- Nexys and MEGA65 port done by sy2002 in 2020 and licensed under GPL v3
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
   new_key  : out std_logic;
   scancode : out std_logic_vector(7 downto 0);
   released : out std_logic;
   extended : out std_logic      
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

begin

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
   begin
      if rising_edge(clk) then
         new_key <= '0';
         released <= '1';
         
         if ascii_key_valid = '1' then
            new_key <= '1';
            scancode <= x"16";
            released <= '0';
            extended <= '0'; 
         end if;
      end if;
   end process;
      
end beh;
