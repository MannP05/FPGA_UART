LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- VHDL 2008 required

entity uart_transmitter is
    port (
        TDR: IN STD_LOGIC_VECTOR(6 downto 0);
        load_data: IN STD_LOGIC;
        resetBar: IN STD_LOGIC;
        baud: IN STD_LOGIC;
        TIE: IN STD_LOGIC;

        -- uart specific signals
        TxD: OUT STD_LOGIC;
        TDRE: OUT STD_LOGIC
    );
end entity uart_transmitter;

architecture rtl of uart_transmitter is
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


    constant MAX_STATE: INTEGER := 9;
    signal nor_int_state: STD_LOGIC;
    signal int_state: STD_LOGIC_VECTOR(MAX_STATE downto 0);
    signal int_goto_state: STD_LOGIC_VECTOR(MAX_STATE downto 0);
    signal tdr_val : STD_LOGIC_VECTOR(6 downto 0);
    signal xor_tdrs_val : STD_LOGIC;
    signal tdrs_val : STD_LOGIC_VECTOR(6 downto 0);

    signal  i_tdre : std_logic;
    -- signals
    signal load_tdrs: std_logic := '0';
    signal reset_tdre: std_logic := '0';
begin
    
    states: nbit_register
     generic map(
        BITS => MAX_STATE+1
    )
     port map(
        in_val => int_goto_state,
        in_load => '1',
        in_resetBar => resetBar,
        in_clock => baud,
        out_val => int_state
    );

    tdr_reg: nbit_register
     generic map(
        BITS => 7
    )
     port map(
        in_val => TDR,
        in_load => load_data,
        in_resetBar => resetBar,
        in_clock => baud,
        out_val => tdr_val
    );

    tdrs_reg: nbit_register
     generic map(
        BITS => 7
    )
     port map(
        in_val => tdr_val,
        in_load => load_tdrs,
        in_resetBar => resetBar,
        in_clock => baud,
        out_val => TDRS_val
    );

    tdre_reg :  enarjff
    port map(
                i_j => load_data,
                i_k => reset_tdre,
                enable => '1',
                resetBar => resetBar,
                i_clock => baud,
                o_q => open,
                o_qBar => i_tdre
            );

    -- state transitions
    int_goto_state(0) <= nor_int_state OR int_state(9) OR (int_state(0) AND (TIE OR i_tdre));
    int_goto_state(1) <= int_state(0) AND NOT i_tdre AND NOT TIE;
    int_goto_state(2) <= int_state(1); -- write bit(1)
    int_goto_state(3) <= int_state(2); -- write bit(2)
    int_goto_state(4) <= int_state(3); -- write bit(3)
    int_goto_state(5) <= int_state(4); -- write bit(4)
    int_goto_state(6) <= int_state(5); -- write bit(5)
    int_goto_state(7) <= int_state(6); -- write bit(6)
    int_goto_state(8) <= int_state(7); -- write bit(7)
    int_goto_state(9) <= int_state(8); -- write xor

    -- signals
    load_tdrs  <= int_state(1);
    reset_tdre <= int_state(1);

    -- output driver
    nor_int_state <= NOT (
                     int_state(0) OR
                     int_state(1) OR
                     int_state(2) OR
                     int_state(3) OR
                     int_state(4) OR
                     int_state(5) OR
                     int_state(6) OR
                     int_state(7) OR
                     int_state(8) OR
                     int_state(9)
                     );
    xor_tdrs_val <= (
                    TDRS_val(6) XOR
                    TDRS_val(5) XOR
                    TDRS_val(4) XOR
                    TDRS_val(3) XOR
                    TDRS_val(2) XOR
                    TDRS_val(1) XOR
                    TDRS_val(0)
                    );

    TxD <= (nor_int_state) OR -- force 1 when in invalid state
         (int_state(0) AND '1') OR
         (int_state(1) AND '0') OR
         (int_state(2) AND TDRS_val(0)) OR
         (int_state(3) AND TDRS_val(1)) OR
         (int_state(4) AND TDRS_val(2)) OR
         (int_state(5) AND TDRS_val(3)) OR
         (int_state(6) AND TDRS_val(4)) OR
         (int_state(7) AND TDRS_val(5)) OR
         (int_state(8) AND TDRS_val(6)) OR
         (int_state(9) AND xor_tdrs_val);

    TDRE <= i_tdre;
    
end architecture rtl;
