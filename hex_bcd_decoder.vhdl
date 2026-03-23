library ieee;
use ieee.std_logic_1164.ALL;

entity hex_bcd_decoder is
    port (
        hex_val : IN std_logic_vector(3 downto 0);
        dec_msb : OUT std_logic_vector(3 downto 0);
        dec_lsb : OUT std_logic_vector(3 downto 0)
    );
end entity hex_bcd_decoder;

architecture rtl of hex_bcd_decoder is
    
begin

    dec_msb(3 downto 1) <= (others => '0');
    dec_msb(0) <= (hex_val(3) AND hex_val(2)) OR (hex_val(3) AND hex_val(1));

    dec_lsb(3) <= hex_val(3) AND NOT hex_val(2) AND NOT hex_val(1);
    dec_lsb(2) <= (NOT hex_val(3) AND hex_val(2)) OR (hex_val(2) AND hex_val(1));
    dec_lsb(1) <= (NOT hex_val(3) AND hex_val(1)) OR (hex_val(3) AND hex_val(2) AND NOT hex_val(1));
    dec_lsb(0) <= hex_val(0);
    
end architecture rtl;

