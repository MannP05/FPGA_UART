LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- VHDL 2008 required

entity uart_receiver is
    port (
        baud8x: IN STD_LOGIC;
        resetFull: IN STD_LOGIC;
        resetBar: IN STD_LOGIC;
        RIE: IN STD_LOGIC;
        RDRF: OUT STD_LOGIC;
        RDR: OUT STD_LOGIC_VECTOR(6 downto 0);
        OE: OUT STD_LOGIC;
        FE: OUT STD_LOGIC;
        RxD: IN STD_LOGIC
    );
end entity uart_receiver;

architecture rtl of uart_receiver is
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

    component enarjff is
	PORT(
		i_j, i_k	: IN	STD_LOGIC;
		i_clock		: IN	STD_LOGIC;
        enable: IN STD_LOGIC;
        resetBar: IN STD_LOGIC;
		o_q, o_qBar	: OUT	STD_LOGIC);
    end component ;

    signal pulse_counter : STD_LOGIC_VECTOR(7 downto 0);
    signal nor_pulse_counter: STD_LOGIC;
    signal pulse_counter_next : STD_LOGIC_VECTOR(7 downto 0);
    signal pulse_counter_reset: std_logic;

    constant MAX_STATE: INTEGER := 10;
    signal nor_int_state: STD_LOGIC;
    signal int_state: STD_LOGIC_VECTOR(MAX_STATE downto 0);
    signal int_goto_state: STD_LOGIC_VECTOR(MAX_STATE downto 0);

    -- signals
    signal read_rxd : STD_LOGIC;
    signal load_RDR : STD_LOGIC;
    signal load_rds : STD_LOGIC_VECTOR(7 downto 0);
    signal xor_rds_val : STD_LOGIC;
    signal rds_val : STD_LOGIC_VECTOR(7 downto 0);
    signal i_RDRF : STD_LOGIC;
    signal i_FE : STD_LOGIC;

    -- helpers
    signal rds_valid: STD_LOGIC;
begin

    pulse_counter_reg: nbit_register
     generic map(
        BITS => 8
    )
     port map(
        in_val => pulse_counter_next,
        in_load => '1',
        in_resetBar => resetBar,
        in_clock => baud8x,
        out_val => pulse_counter
    );

    nor_pulse_counter <= NOT
                         (pulse_counter(7) OR
                        pulse_counter(6) OR
                        pulse_counter(5) OR
                        pulse_counter(4) OR
                        pulse_counter(3) OR
                        pulse_counter(2) OR
                        pulse_counter(1) OR
                        pulse_counter(0));

    -- pulse counter since we have 8x baud. Useful for offsetting from the regular baud
    pulse_counter_next(0) <= pulse_counter(7) OR nor_pulse_counter OR pulse_counter_reset;
    pulse_counter_next(1) <= pulse_counter(0) AND NOT pulse_counter_reset;
    pulse_counter_next(2) <= pulse_counter(1) AND NOT pulse_counter_reset;
    pulse_counter_next(3) <= pulse_counter(2) AND NOT pulse_counter_reset;
    pulse_counter_next(4) <= pulse_counter(3) AND NOT pulse_counter_reset;
    pulse_counter_next(5) <= pulse_counter(4) AND NOT pulse_counter_reset;
    pulse_counter_next(6) <= pulse_counter(5) AND NOT pulse_counter_reset;
    pulse_counter_next(7) <= pulse_counter(6) AND NOT pulse_counter_reset;


    nbit_register_inst: nbit_register
     generic map(
        BITS => MAX_STATE + 1
    )
     port map(
        in_val => int_goto_state,
        in_load => '1',
        in_resetBar => resetBar,
        in_clock => baud8x,
        out_val => int_state
    );

    -- state machine
    nor_int_state <= NOT
                   (int_state(10) OR
                    int_state(9) OR
                    int_state(8) OR
                    int_state(7) OR
                    int_state(6) OR
                    int_state(5) OR
                    int_state(4) OR
                    int_state(3) OR
                    int_state(2) OR
                    int_state(1) OR
                    int_state(0));

    int_goto_state(0)  <= (int_state(10) AND pulse_counter(4)) OR (int_state(0) AND RxD) OR nor_int_state;
    int_goto_state(1)  <= (int_state(0)  AND NOT RxD AND NOT RIE) OR (int_state(1) AND NOT pulse_counter(4));
    int_goto_state(2)  <= (int_state(1)  AND pulse_counter(3)) OR (int_state(2)  AND NOT pulse_counter(7));
    int_goto_state(3)  <= (int_state(2)  AND pulse_counter(7)) OR (int_state(3)  AND NOT pulse_counter(7));
    int_goto_state(4)  <= (int_state(3)  AND pulse_counter(7)) OR (int_state(4)  AND NOT pulse_counter(7));
    int_goto_state(5)  <= (int_state(4)  AND pulse_counter(7)) OR (int_state(5)  AND NOT pulse_counter(7));
    int_goto_state(6)  <= (int_state(5)  AND pulse_counter(7)) OR (int_state(6)  AND NOT pulse_counter(7));
    int_goto_state(7)  <= (int_state(6)  AND pulse_counter(7)) OR (int_state(7)  AND NOT pulse_counter(7));
    int_goto_state(8)  <= (int_state(7)  AND pulse_counter(7)) OR (int_state(8)  AND NOT pulse_counter(7));
    int_goto_state(9)  <= (int_state(8)  AND pulse_counter(7)) OR (int_state(9)  AND NOT pulse_counter(7));
    int_goto_state(10) <= (int_state(9)  AND pulse_counter(7)) OR (int_state(10) AND NOT pulse_counter(4));

    -- signals
    read_rxd <= pulse_counter(7);
    load_RDR <= int_state(10) AND rds_valid AND pulse_counter(4);
    rds_valid <= rds_val(0) XNOR xor_rds_val;
    pulse_counter_reset <= int_state(0) OR (int_state(1) AND pulse_counter(4));

    xor_rds_val <= 
                  rds_val(7) XOR
                  rds_val(6) XOR
                  rds_val(5) XOR
                  rds_val(4) XOR
                  rds_val(3) XOR
                  rds_val(2) XOR
                  rds_val(1);

    -- load data
    rds_reg: nbit_register
     generic map(
        BITS => 8
    )
     port map(
        in_val => load_rds,
        in_load => read_rxd,
        in_resetBar => resetBar,
        in_clock => baud8x,
        out_val => rds_val
    );

    load_rds(7) <= rds_val(6); -- left shift values in
    load_rds(6) <= rds_val(5);
    load_rds(5) <= rds_val(4);
    load_rds(4) <= rds_val(3);
    load_rds(3) <= rds_val(2);
    load_rds(2) <= rds_val(1);
    load_rds(1) <= rds_val(0);
    load_rds(0) <= RxD;


    -- transfer data to RRD
   rdr_reg: nbit_register
     generic map(
        BITS => 7
    )
     port map(
        in_val(6) => rds_val(1),
        in_val(5) => rds_val(2),
        in_val(4) => rds_val(3),
        in_val(3) => rds_val(4),
        in_val(2) => rds_val(5),
        in_val(1) => rds_val(6),
        in_val(0) => rds_val(7),
        in_load => load_RDR,
        in_resetBar => resetBar,
        in_clock => baud8x,
        out_val => RDR
    );

    rdrf_reg: enarjff
    port map(
                i_j => load_RDR,
                i_k => resetFull,
                enable => '1',
                resetBar => resetBar,
                i_clock => baud8x,
                o_q => i_RDRF,
                o_qBar => open
            );

    RDRF <= i_RDRF;
    i_FE <=NOT rds_valid OR NOT RxD;
    -- errors
    error_reg: nbit_register
     generic map(
        BITS => 2
    )
     port map(
        in_val(0) => i_RDRF, -- overrun error
        in_val(1) => i_FE, -- framing errror (parity fail or no clear stop bit)
        out_val(0) => OE,
        out_val(1) => FE,
        in_load => load_RDR,
        in_resetBar => resetBar,
        in_clock => baud8x
    );
    
end architecture rtl;
