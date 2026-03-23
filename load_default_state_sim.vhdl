LIBRARY ieee;
use ieee.std_logic_1164.ALL;

entity load_default_state_sim is
end entity load_default_state_sim;

architecture sim of load_default_state_sim is
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

    signal C : std_logic_vector(3 downto 0) := (others => '0');
    signal D : std_logic_vector(3 downto 0) := (others => '0');
    signal L : std_logic_vector(3 downto 0) := (others => '0');
begin

    loader_inst: load_default_state
     generic map(
        MAX_STATE => 3
    )
     port map(
        current_state => C,
        default_state => D,
        load_state => L
    );

    stimulus: process
    begin
        wait for 1 NS;
        assert L = "0000";

        D <= "1000";
        wait for 1 NS;
        assert L = "1000";

        C <= "1000";
        wait for 1 NS;
        assert L = "0000";

        C <= "0010";
        D <= "0110";

        wait for 1 NS;
        assert L = "0000";


        C <= "0000";
        wait for 1 NS;
        assert L = "0110";

        wait;
    end process;
    
    
    
end architecture sim;
