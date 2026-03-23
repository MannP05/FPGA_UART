LIBRARY ieee;
use ieee.std_logic_1164.ALL;

entity n_clk_divider is
    GENERIC (
    DIVIDER_FACTOR: INTEGER := 2
            );
    port (
        i_clk : in STD_LOGIC;
        resetBar : in STD_LOGIC;
        enable : in STD_LOGIC;
        o_clk : out STD_LOGIC
    );
end entity n_clk_divider;

architecture rtl of n_clk_divider is
    component load_default_state is
    generic (
        MAX_STATE : INTEGER := 8
            );
    port (
             current_state : in std_logic_vector(MAX_STATE downto 0);
             default_state : in std_logic_vector(MAX_STATE downto 0);
             load_state : out std_logic_vector(MAX_STATE downto 0)
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

    signal int_state : STD_LOGIC_VECTOR(DIVIDER_FACTOR - 1 downto 0) := (others => '0');
    signal goto_state : STD_LOGIC_VECTOR(DIVIDER_FACTOR  - 1 downto 0):= (others => '0');
    signal default_state : STD_LOGIC_VECTOR(DIVIDER_FACTOR  - 1 downto 0):= (others => '0');
    signal ajdklajdlka: STD_LOGIC_VECTOR(DIVIDER_FACTOR  - 1 downto 0):= (others => '0');
begin


    load_default_state_inst: load_default_state
     generic map(
        MAX_STATE => DIVIDER_FACTOR - 1
    )
     port map(
        current_state => int_state,
        default_state => (0 => '1', others =>'0'),
        load_state => default_state
    );

    ajdklajdlka <= goto_state OR default_state;
    state_register : nbit_register 
    generic map ( 
                BITS => DIVIDER_FACTOR
            )
    PORT map (
             in_val => ajdklajdlka,
             in_load => enable ,
             in_resetBar => resetBar,
             in_clock => i_clk,
             out_val => int_state
         );

    m: for i in DIVIDER_FACTOR - 1 downto 1 generate
        goto_state(i) <= int_state(i-1);
    end generate;
    goto_state(0) <= int_state(DIVIDER_FACTOR - 1);


    o_clk <= int_state(DIVIDER_FACTOR - 1);
    
end architecture rtl;
