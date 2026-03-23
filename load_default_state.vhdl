library ieee;
use ieee.std_logic_1164.ALL;

-- OR the load_state with your int_goto_state. It will load initial state if no states are active
-- (Asusming hot bit state encoding)
entity load_default_state is
    generic (
        MAX_STATE : INTEGER := 8
            );
    port (
             current_state : in std_logic_vector(MAX_STATE downto 0);
             default_state : in std_logic_vector(MAX_STATE downto 0);
             load_state : out std_logic_vector(MAX_STATE downto 0)
    );
end entity load_default_state;

architecture rtl of load_default_state is
    signal r : std_logic_vector(MAX_STATE + 1 downto 0) := (others => '0');
begin

    f : for i in MAX_STATE downto 0 generate
        -- or reduction
        r(i) <= r(i+1) OR current_state(i);

        -- load output state
        load_state(i) <= '0' OR (NOT r(0) AND default_state(i));
    end generate;
    
end architecture rtl;
