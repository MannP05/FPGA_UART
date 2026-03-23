LIBRARY ieee;
use ieee.std_logic_1164.ALL;

-- holds strings of 6 ascii chars (generic this is hard)
entity message_holder is
    generic ( message: std_logic_vector(6*7 -1 downto 0));
    port (
        resetBar: IN STD_LOGIC;
        nextChar: IN STD_LOGIC;
        char: OUT STD_LOGIC_VECTOR(6 downto 0);
        done: OUT STD_LOGIC
    );
end entity message_holder;

architecture rtl of message_holder is
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

    signal int_state: std_logic_vector(6 downto 0);
    signal int_goto_state: std_logic_vector(6 downto 0);
    signal nor_int_state: std_logic;
begin

    states: nbit_register
     generic map(
        BITS => 7
    )
     port map(
        in_val => int_goto_state,
        in_load => '1',
        in_resetBar => resetBar,
        in_clock => nextChar,
        out_val => int_state
    );

    nor_int_state <= NOT
                    (int_state(6) OR
                    int_state(5) OR
                    int_state(4) OR
                    int_state(3) OR
                    int_state(2) OR
                    int_state(1) OR
                    int_state(0));
    -- chutes n ladders type FSM where you go up and fall all the way down when we reset
    int_goto_state(0) <= nor_int_state;
    int_goto_state(1) <= int_state(0);
    int_goto_state(2) <= int_state(1);
    int_goto_state(3) <= int_state(2);
    int_goto_state(4) <= int_state(3);
    int_goto_state(5) <= int_state(4);
    int_goto_state(6) <= int_state(5) OR int_state(6);
    
    g: for i in 6 downto 0 generate
        char(i) <= (int_state(5) AND message(i)) OR
                (int_state(4) AND message(i+7)) OR
                (int_state(3) AND message(i+7*2)) OR
                (int_state(2) AND message(i+7*3)) OR
                (int_state(1) AND message(i+7*4)) OR
                (int_state(0) AND message(i+7*5));
    end generate;
    
    done <= int_state(6);
    
end architecture rtl;
