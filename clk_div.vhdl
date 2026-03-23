library IEEE;
use  IEEE.STD_LOGIC_1164.all;

ENTITY clk_div IS

	PORT
	(
		clock_25Mhz				: IN	STD_LOGIC;
		GReset                  : IN	STD_LOGIC;
		clock_1Hz				: OUT	STD_LOGIC);
	
END clk_div;

ARCHITECTURE a OF clk_div IS

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


    signal clk_1mhz: std_logic;
    signal clk_100khz: std_logic;
    signal clk_10khz: std_logic;
    signal clk_1khz: std_logic;
    signal clk_100hz: std_logic;
    signal clk_10hz: std_logic;

BEGIN

    s1mhz_clk_div_inst: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 25
    )
     port map(
        i_clk => clock_25Mhz,
        resetBar => GReset,
        enable => '1',
        o_clk => clk_1mhz
    );

    s100khz_clk_div_inst: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 10
    )
     port map(
        i_clk => clk_1mhz,
        resetBar => GReset,
        enable => '1',
        o_clk => clk_100khz
    );

    s10khz_clk_div_inst: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 10
    )
     port map(
        i_clk => clk_100khz,
        resetBar => GReset,
        enable => '1',
        o_clk => clk_10khz
    );

    s1khz_clk_div_inst: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 10
    )
     port map(
        i_clk => clk_10khz,
        resetBar => GReset,
        enable => '1',
        o_clk => clk_1khz
    );

    s100hz_clk_div_inst: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 10
    )
     port map(
        i_clk => clk_1khz,
        resetBar => GReset,
        enable => '1',
        o_clk => clk_100hz
    );

    s10hz_clk_div_inst: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 10
    )
     port map(
        i_clk => clk_100hz,
        resetBar => GReset,
        enable => '1',
        o_clk => clk_10hz
    );

    s1hz_clk_div_inst: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 10
    )
     port map(
        i_clk => clk_10hz,
        resetBar => GReset,
        enable => '1',
        o_clk => clock_1Hz
    );
END a;

