LIBRARY ieee;
use ieee.std_logic_1164.ALL;

-- VHDL 2008 required

entity message_writer is
    port (
             sel: IN STD_LOGIC_VECTOR(5 downto 0); -- MS(2 downto 0) SS(2 downto 0)
             clk: IN STD_LOGIC; 
             resetBar: IN STD_LOGIC;
             buffer_free: IN STD_LOGIC;
             write_buffer: OUT STD_LOGIC;
             val: OUT STD_LOGIC_VECTOR(6 downto 0)
    );
end entity message_writer;

architecture rtl of message_writer is
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

    component message_holder is
    generic ( message: std_logic_vector(6*7 -1 downto 0));
    port (
        resetBar: IN STD_LOGIC;
        nextChar: IN STD_LOGIC;
        char: OUT STD_LOGIC_VECTOR(6 downto 0);
        done: OUT STD_LOGIC
    );
    end component;


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


    constant MSG_MSG_VAL: STD_LOGIC_VECTOR(6*7 -1 downto 0) := "100110111001111011111101001111100100001010";
    constant MSY_MSG_VAL: STD_LOGIC_VECTOR(6*7 -1 downto 0) := "100110111110011011111101001111100100001010";
    constant SSG_MSG_VAL: STD_LOGIC_VECTOR(6*7 -1 downto 0) := "100110111100101011111101001111001110001010";
    constant SSY_MSG_VAL: STD_LOGIC_VECTOR(6*7 -1 downto 0) := "100110111100101011111101001111110010001010";

    signal active_state: std_logic_vector(3 downto 0);
    signal bank_reset: std_logic_vector(3 downto 0);
    signal nor_state_done : std_logic;
    signal state_done: std_logic_vector(3 downto 0);
    signal read_next: STD_LOGIC;

    signal msg_out : std_logic_vector(6 downto 0);
    signal msy_out : std_logic_vector(6 downto 0);
    signal ssg_out : std_logic_vector(6 downto 0);
    signal ssy_out : std_logic_vector(6 downto 0);

    signal nor_int_state: std_logic;
    signal int_state: std_logic_vector(4 downto 0);
    signal int_goto_state: std_logic_vector(4 downto 0);
begin

    bank_reset(0) <= active_state(0) AND resetBar;
msg_bank_holder: message_holder
                  generic map( message => MSG_MSG_VAL)
                  port map(
                     resetBar => bank_reset(0),
                     nextChar => read_next,
                     char => msg_out,
                     done => state_done(0)
                 );

                 bank_reset(1) <=active_state(1) AND resetBar;
msy_bank_holder: message_holder
                  generic map( message => MSY_MSG_VAL)
                  port map(
                     resetBar => bank_reset(1),
                     nextChar => read_next,
                     char => msy_out,
                     done => state_done(1)
                 );

                 bank_reset(2) <=active_state(2) AND resetBar;
ssg_bank_holder: message_holder
                  generic map( message => SSG_MSG_VAL)
                  port map(
                     resetBar => bank_reset(2),
                     nextChar => read_next,
                     char => ssg_out,
                     done => state_done(2)
                 );

                 bank_reset(3) <=active_state(3) AND resetBar;
ssy_bank_holder: message_holder
                  generic map( message => SSY_MSG_VAL)
                  port map(
                     resetBar => bank_reset(3),
                     nextChar => read_next,
                     char => ssy_out,
                     done => state_done(3)
                 );

                 active_state(0) <= sel(5); -- MSG
                 active_state(1) <= sel(4); -- MSY
                 active_state(2) <= sel(2); -- SSG
                 active_state(3) <= sel(1); -- SSY

                 -- output
                 ii: for i in 6 downto 0 generate
                     quad_mux_selector_inst: quad_mux_selector
                      port map(
                         in_tt => ssy_out(i),
                         in_tf => ssg_out(i),
                         in_ft => msy_out(i),
                         in_ff => msg_out(i),
                         in_sel_tt => active_state(3),
                         in_sel_tf => active_state(2),
                         in_sel_ft => active_state(1),
                         in_sel_ff => active_state(0),
                         out_mux => val(i)
                     );
                 end generate;


                 -- states
                 states: nbit_register
                  generic map(
                     BITS => 5
                 )
                  port map(
                     in_val => int_goto_state,
                     in_load => '1',
                     in_resetBar => resetBar,
                     in_clock => clk,
                     out_val => int_state
                 );

                 nor_int_state <= NOT
                                 (int_state(4) OR
                                 int_state(3) OR
                                 int_state(2) OR
                                 int_state(1) OR
                                 int_state(0));

                 nor_state_done <= NOT
                                  (state_done(3) OR
                                  state_done(2) OR
                                  state_done(1) OR
                                  state_done(0));

                 int_goto_state(0) <= nor_int_state OR int_state(3) OR (int_state(4) AND nor_state_done) OR (int_State(0) AND NOT buffer_free); -- it's 5am, this makes sense in my mind, good lucky figuring this out :)
                 int_goto_state(1) <= (int_state(0) AND buffer_free);
                 int_goto_state(2) <= int_state(1) OR (int_state(2) AND buffer_free); 
                 int_goto_state(3) <= int_state(2) AND nor_state_done;
                 int_goto_state(4) <= int_state(4) AND NOT nor_state_done; 

                 -- signals
                 write_buffer <= int_state(1);
                 read_next <= int_state(3);

end architecture rtl;
