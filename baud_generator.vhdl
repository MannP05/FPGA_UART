LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity baud_generator is
    port (
             sel: in std_logic_vector(2 downto 0);
             clk: in std_logic;
             resetBar: in std_logic;
             baud: out std_logic;
             baud_8x: out std_logic
    );
end entity baud_generator;


architecture rtl of baud_generator is
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

    signal stacked_divider: std_logic_vector(8 downto 0);
    signal i_baud: std_logic;
    signal i_baud8x: std_logic;

begin

    n_clk_divider_inst_41: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 41
    )
     port map(
        i_clk => clk,
        resetBar => resetBar,
        enable => '1',
        o_clk => stacked_divider(8)
    );

    -- don't daisy chain because that delays the clock
    a: for i in 7 downto 1 generate
        n_clk_divider_inst_stacked: n_clk_divider
         generic map(
            DIVIDER_FACTOR => 2*i
        )
         port map(
            i_clk => stacked_divider(8),
            resetBar => resetBar,
            enable => '1',
            o_clk => stacked_divider(i)
        );
    end generate;
    stacked_divider(0) <= stacked_divider(8);

    -- 8x output mux
    i_baud8x <= 
           (    sel(2) AND      sel(1) AND      sel(0) AND stacked_divider(7)) OR
           (    sel(2) AND      sel(1) AND NOT  sel(0) AND stacked_divider(6)) OR
           (    sel(2) AND NOT  sel(1) AND      sel(0) AND stacked_divider(5)) OR
           (    sel(2) AND NOT  sel(1) AND NOT  sel(0) AND stacked_divider(4)) OR
           (NOT sel(2) AND      sel(1) AND      sel(0) AND stacked_divider(3)) OR
           (NOT sel(2) AND      sel(1) AND NOT  sel(0) AND stacked_divider(2)) OR
           (NOT sel(2) AND NOT  sel(1) AND      sel(0) AND stacked_divider(1)) OR
           (NOT sel(2) AND NOT  sel(1) AND NOT  sel(0) AND stacked_divider(0));

    -- baud output
    x8_divider: n_clk_divider
                 generic map(DIVIDER_FACTOR => 8)
                 port map(
                    i_clk => i_baud8x,
                    resetBar => resetBar,
                    enable => '1',
                    o_clk => baud
                );

                baud_8x <= i_baud8x;
    
end architecture rtl;
