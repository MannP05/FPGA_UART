library ieee;
use ieee.std_logic_1164.ALL;

-- VHDL 2008 required

entity debuggableTrafficLightController is
    port (
             -- in
             KeyboardClock: in std_logic; -- wtf is this for??
             KeyboardData: in std_logic; -- wtf is this for??
             SSCS: in std_logic;
             SW1: in std_logic_vector(3 downto 0);
             SW2: in std_logic_vector(3 downto 0);
             RxD: in std_logic;
             GClock: in std_logic; --  shove a 50mhz on this boi
             GReset: in std_logic;

             -- out
             TxD: out std_logic;
             MSTL: out std_logic_vector(2 downto 0);
             SSTL: out std_logic_vector(2 downto 0);
             BCD1: out std_logic_vector(3 downto 0);
             BCD2: out std_logic_vector(3 downto 0)
    );
end entity debuggableTrafficLightController;

architecture rtl of debuggableTrafficLightController is
    component trafficLightController is
        port (
                 MSC : IN STD_LOGIC_VECTOR(3 downto 0);
                 SSC : IN STD_LOGIC_VECTOR(3 downto 0);
                 SSCS : IN STD_LOGIC;
                 GClock : IN STD_LOGIC;
                 GReset : IN STD_LOGIC;

                 MSTL : OUT STD_LOGIC_VECTOR(2 downto 0);
                 SSTL : OUT STD_LOGIC_VECTOR(2 downto 0);
                 BCD1 : OUT STD_LOGIC_VECTOR(3 downto 0);
                 BCD2 : OUT STD_LOGIC_VECTOR(3 downto 0)
             );
    end component;

    component message_writer is
    port (
             sel: IN STD_LOGIC_VECTOR(5 downto 0); -- MS(2 downto 0) SS(2 downto 0)
             clk: IN STD_LOGIC; 
             resetBar: IN STD_LOGIC;
             buffer_free: IN STD_LOGIC;
             write_buffer: OUT STD_LOGIC;
             val: OUT STD_LOGIC_VECTOR(6 downto 0)
    );
    end component;

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


    component n_clk_divider is
        GENERIC (
                    DIVIDER_FACTOR: INTEGER := 2
                );
        port (
                 i_clk : in STD_LOGIC;
                 resetBar : in STD_LOGIC;
                 enable : in STD_LOGIC;
                 o_clk : out STD_LOGIC
             );
    end component;


    component clk_div IS
        PORT
        (
            clock_25Mhz				: IN	STD_LOGIC;
            GReset                  : IN	STD_LOGIC;
            clock_1Hz				: OUT	STD_LOGIC);

    END component;

    signal tdr_free: std_logic;
    signal tdr_write: std_logic;
    signal tdr_val: std_logic_vector(6 downto 0);
    signal clk_25mhz: std_logic;
    signal clk_1hz: std_logic;

    signal clk_div_vec : std_logic_vector(3 downto 0);
    signal i_MSTL: std_logic_vector(2 downto 0);
    signal i_SSTL: std_logic_vector(2 downto 0);
begin
    controller: trafficLightController
     port map(
        MSC => SW1,
        SSC => SW2,
        SSCS => SSCS,
        GClock => clk_1hz,
        GReset => GReset,
        MSTL => i_MSTL,
        SSTL => i_SSTL,
        BCD1 => BCD1,
        BCD2 => BCD2
    );

    MSTL <= i_MSTL;
    SSTL <= i_SSTL;

    message_writer_inst: message_writer
     port map(
        sel(5 downto 3) => i_MSTL,
        sel(2 downto 0) => i_SSTL,
        clk => GClock,
        resetBar => GReset,
        buffer_free => tdr_free,
        write_buffer => tdr_write,
        val => tdr_val
    );

    uart_inst: uart
     port map(
        resetBar => GReset,
        clk_25mhz => clk_25mhz,
        SEL => "000",
        TDR => tdr_val,
        load_tdr => tdr_write,
        TIE => '0',
        TDRE => tdr_free,
        RIE => '0',
        RDRF => open,
        RDR => open,
        read_rdr => '0',
        OE => open,
        FE => open,
        TxD => TxD,
        RxD => RxD
    );

    -- clocks
    n_clk_divider_inst: n_clk_divider
     generic map(
        DIVIDER_FACTOR => 2
    )
     port map(
        i_clk => GClock,
        resetBar => GReset,
        enable => '1',
        o_clk => clk_25mhz
    );

    clk_div_inst: clk_div
     port map(
        clock_25Mhz => clk_25mhz,
        clock_1Hz => clk_1hz,
        GReset => GReset
    );


end architecture rtl;
