library ieee;
use ieee.std_logic_1164.ALL;

entity hex_bcd_decoder_sim is
end entity hex_bcd_decoder_sim;

architecture sim of hex_bcd_decoder_sim is
    component hex_bcd_decoder is
    port (
        hex_val : IN std_logic_vector(3 downto 0);
        dec_msb : OUT std_logic_vector(3 downto 0);
        dec_lsb : OUT std_logic_vector(3 downto 0)
    );
end component;

signal V : std_logic_vector(3 downto 0) := (others => '0');
signal BCD1 : std_logic_vector(3 downto 0) := (others => '0');
signal BCD2 : std_logic_vector(3 downto 0) := (others => '0');
begin


    decoder : hex_bcd_decoder
    port map(
        hex_val => V,
        dec_msb => BCD2,
        dec_lsb => BCD1 
    );

    stimulus: process
    begin

        V <= "0000";
        wait for 200 ps; 
        assert BCD2 = "0000";
        assert BCD1 = "0000";

        V <= "0001";
        wait for 200 ps; 
        assert BCD2 = "0000";
        assert BCD1 = "0001";

        V <= "0010";
        wait for 200 ps; 
        assert BCD2 = "0000";
        assert BCD1 = "0010";

        V <= "0011";
        wait for 200 ps; 
        assert BCD2 = "0000";
        assert BCD1 = "0011";

        V <= "0100";
        wait for 200 ps; 
        assert BCD2 = "0000";
        assert BCD1 = "0100";

        V <= "0101";
        wait for 200 ps; 
        assert BCD2 = "0000";
        assert BCD1 = "0101";

        V <= "0110";
        wait for 200 ps; 
        assert BCD2 = "0000";
        assert BCD1 = "0110";

        V <= "0111";
        wait for 200 ps; 
        assert BCD2 = "0000";
        assert BCD1 = "0111";

        V <= "1000";
        wait for 200 ps; 
        assert BCD2 = "0000";
        assert BCD1 = "1000";

        V <= "1001";
        wait for 200 ps; 
        assert BCD2 = "0000";
        assert BCD1 = "1001";

        V <= "1010";
        wait for 200 ps; 
        assert BCD2 = "0001";
        assert BCD1 = "0000";

        V <= "1011";
        wait for 200 ps; 
        assert BCD2 = "0001";
        assert BCD1 = "0001";

        V <= "1100";
        wait for 200 ps; 
        assert BCD2 = "0001";
        assert BCD1 = "0010";

        V <= "1101";
        wait for 200 ps; 
        assert BCD2 = "0001";
        assert BCD1 = "0011";

        V <= "1110";
        wait for 200 ps; 
        assert BCD2 = "0001";
        assert BCD1 = "0100";

        V <= "1111";
        wait for 200 ps; 
        assert BCD2 = "0001";
        assert BCD1 = "0101";

        wait;

    end process;

end architecture sim;

