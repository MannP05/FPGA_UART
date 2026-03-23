LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity uart is
    port (
            resetBar: IN STD_LOGIC;
            clk_25mhz: IN STD_LOGIC;
            SEL: IN STD_LOGIC_VECTOR(2 downto 0);

            TDR: IN STD_LOGIC_VECTOR(6 downto 0);
            load_tdr: IN STD_LOGIC;
            TIE: IN STD_LOGIC;
            TDRE: OUT STD_LOGIC;
            
            RIE: IN STD_LOGIC;
            RDRF: OUT STD_LOGIC;
            RDR: OUT STD_LOGIC_VECTOR(6 downto 0);
            read_rdr: IN STD_LOGIC;
            OE: OUT STD_LOGIC;
            FE: OUT STD_LOGIC;

            TxD: OUT STD_LOGIC;
            RxD: IN STD_LOGIC
    );
end entity uart;

architecture rtl of uart is
    component uart_transmitter is
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
    end component;

    component uart_receiver is
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

    component baud_generator is
        port (
                 sel: in std_logic_vector(2 downto 0);
                 clk: in std_logic;
                 resetBar: in std_logic;
                 baud: out std_logic;
                 baud_8x: out std_logic
             );
    end component;

    signal baud : STD_LOGIC;
    signal baud8x : STD_LOGIC;
begin

    baud_generator_inst: baud_generator
     port map(
        sel => SEL,
        clk => clk_25mhz,
        resetBar => resetBar,
        baud => baud,
        baud_8x => baud8x
    );

    uart_receiver_inst: uart_receiver
     port map(
        baud8x => baud8x,
        resetFull => read_rdr,
        resetBar => resetBar,
        RIE => RIE,
        RDRF => RDRF,
        RDR => RDR,
        OE => OE,
        FE => FE,
        RxD => RxD
    );

    uart_transmitter_inst: uart_transmitter
     port map(
        TDR => TDR,
        load_data => load_tdr,
        resetBar => resetBar,
        baud => baud,
        TIE => TIE,
        TxD => TxD,
        TDRE => TDRE
    );
    
end architecture rtl;
