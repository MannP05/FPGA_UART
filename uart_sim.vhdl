LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity uart_sim is
end entity uart_sim;

architecture sim of uart_sim is
    component uart is
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
    end component;

    signal resetBar: STD_LOGIC;
    signal clk_25mhz: STD_LOGIC := '0';
    signal SEL: STD_LOGIC_VECTOR(2 downto 0) := "111";

    signal TDR: STD_LOGIC_VECTOR(6 downto 0);
    signal load_tdr: STD_LOGIC := '0';
    signal TIE: STD_LOGIC := '0';
    signal TDRE: STD_LOGIC;

    signal RIE: STD_LOGIC := '0';
    signal RDRF: STD_LOGIC;
    signal RDR: STD_LOGIC_VECTOR(6 downto 0);
    signal read_rdr: STD_LOGIC := '0';
    signal OE: STD_LOGIC;
    signal FE: STD_LOGIC;

    signal TxD: STD_LOGIC;
    signal RxD: STD_LOGIC;

    signal sim_end: STD_LOGIC := '0';
begin

    uart_inst: uart
     port map(
        resetBar => resetBar,
        clk_25mhz => clk_25mhz,
        SEL => SEL,
        TDR => TDR,
        load_tdr => load_tdr,
        TIE => TIE,
        TDRE => TDRE,
        RIE => RIE,
        RDRF => RDRF,
        RDR => RDR,
        read_rdr => read_rdr,
        OE => OE,
        FE => FE,
        TxD => TxD,
        RxD => RxD
    );

    clk_25mhz <= not clk_25mhz AFTER 20 ps WHEN sim_end /= '1' else '0'; -- really damn fast clock, I hope this doesn't break anything

    RxD <= TxD;

    process 
    begin
        resetBar <= '0';
        TDR <= "1001110";
        wait for 1 ns;
        resetBar <= '1';

        wait for 50 ns;

        load_tdr <= '1';
        while TDRE = '1' loop
            wait for 1 ps;
        end loop;
        load_tdr <= '0';
        TDR <= "0011010";

        wait for 30 ns;

        load_tdr <= '1';
        while TDRE = '1' loop
            wait for 1 ps;
        end loop;
        load_tdr <= '0';

        while RDRF /= '1' loop
            wait for 1 ns;
        end loop;
        assert RDR = "1001110";
        read_rdr <= '1';
        wait for 30 ns;
        read_rdr <= '0';

        while RDRF /= '1' loop
            wait for 1 ns;
        end loop;
        assert RDR = "0011010";

        -- allow reading final state
        wait for 100 ns;

        sim_end <= '1';
        WAIT;
    end process;


end architecture sim;

