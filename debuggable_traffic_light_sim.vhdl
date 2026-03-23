LIBRARY ieee;
use ieee.std_logic_1164.ALL;

entity debuggable_traffic_light_sim is
end entity debuggable_traffic_light_sim;


architecture rtl of debuggable_traffic_light_sim is
    component debuggableTrafficLightController is
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
    end component;

    signal KeyboardClock: std_logic;
    signal KeyboardData: std_logic;
    signal SSCS: std_logic := '1';
    signal SW1: std_logic_vector(3 downto 0) := "1000";
    signal SW2: std_logic_vector(3 downto 0) := "1000";
    signal RxD: std_logic;
    signal GClock: std_logic := '0';
    signal GReset: std_logic;
    signal TxD: std_logic;
    signal MSTL: std_logic_vector(2 downto 0);
    signal SSTL: std_logic_vector(2 downto 0);
    signal BCD1: std_logic_vector(3 downto 0);
    signal BCD2: std_logic_vector(3 downto 0);

    signal sim_end: STD_LOGIC := '0';
begin

    debuggableTrafficLightController_inst: debuggableTrafficLightController
     port map(
        KeyboardClock => KeyboardClock,
        KeyboardData => KeyboardData,
        SSCS => SSCS,
        SW1 => SW1,
        SW2 => SW2,
        RxD => RxD,
        GClock => GClock,
        GReset => GReset,
        TxD => TxD,
        MSTL => MSTL,
        SSTL => SSTL,
        BCD1 => BCD1,
        BCD2 => BCD2
    );

    RxD <= TxD;

    GClock <= not GClock AFTER 5 ps WHEN sim_end /= '1' else '0'; -- really damn fast clock, I hope this doesn't break anything
    process 
    begin
        GReset <= '0';
        wait for 1 ns;
        GReset <= '1';

        wait for 1 ms;
        sim_end <= '1';
        wait;
    end process;

end architecture rtl;
