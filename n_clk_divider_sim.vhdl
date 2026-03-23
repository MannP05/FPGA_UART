LIBRARY ieee;
use ieee.std_logic_1164.ALL;

entity n_clk_divider_sim is
end entity n_clk_divider_sim;

architecture sim of n_clk_divider_sim is

    component n_clk_divider is
    GENERIC (
    DIVIDER_FACTOR: INTEGER := 2
            );
    port (
        i_clk : in STD_LOGIC;
        resetBar : in STD_LOGIC;
        enable : in STD_LOGIC;
        o_clk : out STD_LOGIC
    );
    end component;

    signal sig_clk: STD_LOGIC;
    signal div_clk4: STD_LOGIC;
    signal div_clk6: STD_LOGIC;
    signal en4: STD_LOGIC;
    signal en6: STD_LOGIC;
    signal resetBar: STD_LOGIC;

    
begin

   divider_4: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 4
    )
     port map(
        i_clk => sig_clk,
        resetBar => resetBar,
        enable => en4,
        o_clk => div_clk4
    );

   divider_6: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 6
    )
     port map(
        i_clk => sig_clk,
        resetBar => resetBar,
        enable => en6,
        o_clk => div_clk6
    );

    stimulus: process
    begin

        resetBar <= '0';
        sig_clk <= '0';
        en4 <= '0';
        en6 <= '0';

        WAIT FOR 50 ps;
        en4 <= '1';
        en6 <= '1';
        resetBar <= '1';
        WAIT FOR 50 ps;
        assert div_clk4 = '0';
        assert div_clk6 = '0';

        test: for i in 0 to 11 loop
            sig_clk <= '1';
            wait for 50 ps;

            if (i mod 4) = 3 THEN
                assert div_clk4 = '1';
            ELSE assert div_clk4 = '0';
            end if;

            if (i mod 6) = 5 THEN
                assert div_clk6 = '1';
            ELSE assert div_clk6 = '0';
            end if;

            sig_clk <= '0';
            wait for 50 ps;
        end loop;

        wait;
    end process;

end architecture sim;
