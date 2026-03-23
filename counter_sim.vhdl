library ieee;
use ieee.std_logic_1164.ALL;

entity counter_sim is
end entity counter_sim;

architecture sim of counter_sim is

    component counter is
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
end component;
signal incr : std_logic := '1';
signal resetbar : std_logic := '0';
signal clock : std_logic := '0';
signal compare : std_logic_vector(7 downto 0) := "00000010";
signal val : std_logic_vector(7 downto 0);
signal i_equal : std_logic := '0';
signal i_gt : std_logic := '0';
signal i_gteq : std_logic := '0';
signal i_lt : std_logic := '0';
signal i_lteq : std_logic := '0';

begin

    counter_inst: counter
     generic map(
        BITS => 8
    )
     port map(
        incr => incr,
        resetBar => resetBar,
        clock => clock,
        compare => compare,
        val => val,
        val_gt => i_gt,
        val_lt => i_lt,
        val_gteq => i_gteq,
        val_lteq => i_lteq,
        val_equal => i_equal
    );


    stimulus: process
    begin
        wait for 10 ns;
        assert val = "00000000";
        assert i_equal =  '0';
        assert i_lt =  '1';
        assert i_gt =  '0';
        resetbar <= '1';

        clock <= '1';
        wait for 10 ns;
        clock <= '0';
        wait for 10 ns;

        assert val =  "00000001";
        assert i_equal =  '0';
        assert i_lt =  '1';
        assert i_gt =  '0';

        clock <= '1';
        wait for 10 ns;
        clock <= '0';
        wait for 10 ns;

        assert val =  "00000010";
        assert i_equal =  '1';
        assert i_lt =  '0';
        assert i_gt =  '0';

        clock <= '1';
        wait for 10 ns;
        clock <= '0';
        wait for 10 ns;


        clock <= '1';
        wait for 10 ns;
        clock <= '0';
        wait for 10 ns;

        assert val =  "00000100";
        assert i_equal =  '0';
        assert i_lt =  '0';
        assert i_gt =  '1';

        resetbar <= '0';
        wait for 10 ns;
        assert val =  "00000000";

        wait;
    end process;
    
    
    
end architecture sim ;
