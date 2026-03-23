LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

-- you're responsible for not overflowing the adder
entity counter is
    generic ( 
                BITS : integer := 4
            );
    port (
        incr : in STD_LOGIC;
        resetBar : in STD_LOGIC;
        clock : in STD_LOGIC;
        compare : in STD_LOGIC_VECTOR(BITS - 1 downto 0);
        val : out STD_LOGIC_VECTOR(BITS - 1 downto 0);
        val_gt : out STD_LOGIC;
        val_lt : out STD_LOGIC;
        val_gteq : out STD_LOGIC;
        val_lteq : out STD_LOGIC;
        val_equal : out STD_LOGIC
    );
end entity counter;

architecture rtl of counter is
    component ripple_adder is
        generic ( 
                    BITS : integer := 4
                );

        port (
                 A: in std_logic_vector(BITS - 1 downto 0); 
                 B : in std_logic_vector(BITS - 1 downto 0); 
                 Cin : in std_logic; 
                 sum : out std_logic_vector(BITS - 1 downto 0);
                 Cout : out std_logic;
                 Zero : out std_logic;
                 Overflow : out std_logic;
                 add_sub : in std_logic -- flag for add or subtract
             );
    end component;

    component nbit_register IS 
        generic ( 
                    BITS : integer := 4
                );
        PORT (
                 in_val : IN STD_LOGIC_VECTOR(BITS - 1 DOWNTO 0);
                 in_load : IN STD_LOGIC;
                 in_resetBar : IN STD_LOGIC;
                 in_clock : IN STD_LOGIC;
                 out_val : OUT STD_LOGIC_VECTOR(BITS - 1 DOWNTO 0)
             );
    END component;

    component nbit_comparator is
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

    SIGNAL i_val : STD_LOGIC_VECTOR(BITS - 1 downto 0)  := std_logic_vector(to_unsigned(0, BITS));
    SIGNAL i_sum : STD_LOGIC_VECTOR(BITS - 1 downto 0)  := std_logic_vector(to_unsigned(0, BITS));
begin

    store: nbit_register
     generic map(
        BITS => BITS
    )
     port map(
        in_val => i_sum,
        in_load => incr,
        in_resetBar => resetBar,
        in_clock => clock,
        out_val => i_val
    );

    c: ripple_adder
     generic map(
        BITS => BITS
    )
     port map(
        A => i_val,
        B => (0 => '1', others => '0'),
        Cin => '0',
        sum => i_sum,
        Cout => open,
        Zero => open,
        Overflow => open,
        add_sub => '0'
    );

    val <= i_val;

    nbit_comparator_inst: nbit_comparator
     generic map(
        BITS => BITS
    )
     port map(
        in_a => i_val,
        in_b => compare,
        a_gt_b => val_gt,
        a_gteq_b => val_gteq,
        a_lt_b => val_lt,
        a_lteq_b => val_lteq,
        a_eq_b => val_equal
    );

end architecture rtl;
