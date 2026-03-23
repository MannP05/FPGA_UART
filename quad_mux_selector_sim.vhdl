LIBRARY ieee;
use ieee.std_logic_1164.ALL;

-- Testbench to simulate the latch
entity quad_mux_selector_sim is
end entity quad_mux_selector_sim;

ARCHITECTURE sim OF quad_mux_selector_sim IS 
    SIGNAL int_v0 :  STD_LOGIC;
    SIGNAL int_v1 :  STD_LOGIC;
    SIGNAL int_v2 :  STD_LOGIC;
    SIGNAL int_v3 :  STD_LOGIC;
    SIGNAL int_s :  STD_LOGIC_VECTOR(3 downto 0);
    SIGNAL out_val : STD_LOGIC;

    component quad_mux_selector IS 
        PORT (
            in_tt, in_tf, in_ft, in_ff : IN STD_LOGIC;
            in_sel_tt : IN STD_LOGIC;
            in_sel_tf : IN STD_LOGIC;
            in_sel_ft : IN STD_LOGIC;
            in_sel_ff : IN STD_LOGIC;
            out_mux : OUT STD_LOGIC
    );
    END component;
BEGIN

    quad_mux_selector_inst: quad_mux_selector
     port map(
        in_tt => int_v3,
        in_tf => int_v2,
        in_ft => int_v1,
        in_ff => int_v0,
        in_sel_tt => int_s(3),
        in_sel_tf => int_s(2),
        in_sel_ft => int_s(1),
        in_sel_ff => int_s(0),
        out_mux => out_val
    );

    -- Behaviourally simulate a range of inputs for the latch
    sim: PROCESS IS
    BEGIN
        int_v0 <= '1';
        int_v1 <= '0';
        int_v2 <= '1';
        int_v3 <= '0';
        int_s <= "1000";
        WAIT FOR 10 ns;
        assert out_val = '0';

        int_s <= "0100";
        WAIT FOR 10 ns;
        assert out_val = '1';

        int_s <= "0010";
        WAIT FOR 10 ns;
        assert out_val = '0';

        int_s <= "0001";
        WAIT FOR 10 ns;
        assert out_val = '1';

        WAIT;
    END PROCESS sim;
END sim;
