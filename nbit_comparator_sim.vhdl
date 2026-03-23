LIBRARY ieee;
use ieee.std_logic_1164.ALL;

entity nbit_comparator_sim is
end entity nbit_comparator_sim;

architecture sim of nbit_comparator_sim is

    component  nbit_comparator is
        GENERIC (
                    BITS : natural := 8
                );
        port (
                 in_a : in STD_LOGIC_VECTOR(BITS - 1 DOWNTO 0);
                 in_b : in STD_LOGIC_VECTOR(BITS - 1 DOWNTO 0);
                 a_gt_b : out STD_LOGIC;
                 a_gteq_b : out STD_LOGIC;
                 a_lt_b : out STD_LOGIC;
                 a_lteq_b : out STD_LOGIC;
                 a_eq_b : out STD_LOGIC
             );
    end component;

    SIGNAL A : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    SIGNAL B : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    SIGNAL A_LT_B : STD_LOGIC;
    SIGNAL A_LTEQ_B : STD_LOGIC;
    SIGNAL A_GT_B : STD_LOGIC;
    SIGNAL A_GTEQ_B : STD_LOGIC;
    SIGNAL A_EQ_B : STD_LOGIC;

begin

comparator_inst: nbit_comparator
 generic map(
    BITS => 8
)
 port map(
    in_a => A,
    in_b => B,
    a_gt_b => A_GT_B,
    a_lt_b => A_LT_B,
    a_eq_b => A_EQ_B,
    a_gteq_b => A_GTEQ_B,
    a_lteq_b => A_LTEQ_B
);

    stimulus: process
    begin
        WAIT FOR 10 NS;
        assert a_eq_b = '1';
        assert a_lt_b = '0';
        assert a_gt_b = '0';
        assert a_lteq_b = '1';
        assert a_gteq_b = '1';


        A <= "00010000";
        B <= "00011000";

        WAIT FOR 10 NS;
        assert a_eq_b = '0';
        assert a_lt_b = '1';
        assert a_gt_b = '0';
        assert a_lteq_b = '1';
        assert a_gteq_b = '0';

        A <= "01010000";
        B <= "00011000";

        WAIT FOR 10 NS;
        assert a_eq_b = '0';
        assert a_lt_b = '0';
        assert a_gt_b = '1';
        assert a_lteq_b = '0';
        assert a_gteq_b = '1';

        A <= "01010000";
        B <= "00011000";

        WAIT FOR 10 NS;
        assert a_eq_b = '0';
        assert a_lt_b = '0';
        assert a_gt_b = '1';
        assert a_lteq_b = '0';
        assert a_gteq_b = '1';

        wait;
    
    end process;
    
end architecture sim;
