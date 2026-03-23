library ieee;
use ieee.std_logic_1164.ALL;

entity traffic_controller_sim is
end entity traffic_controller_sim;

architecture stimulus of traffic_controller_sim is
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

    signal clk : STD_LOGIC := '0';
    signal sim_end : STD_LOGIC := '0';

    signal resetBar : STD_LOGIC := '0';

    signal SS_Car : STD_LOGIC := '0';

    signal MS_Light : STD_LOGIC_VECTOR(2 downto 0);
    signal SS_Light : STD_LOGIC_VECTOR(2 downto 0);

    signal BCD1 : STD_LOGIC_VECTOR(3 downto 0);
    signal BCD2 : STD_LOGIC_VECTOR(3 downto 0);

    signal MSC : STD_LOGIC_VECTOR(3 downto 0) := "0110";
    signal SSC : STD_LOGIC_VECTOR(3 downto 0) := "0010";
begin
    trafficLightController_inst: trafficLightController
     port map(
        MSC => MSC,
        SSC => SSC,
        SSCS => SS_Car,
        GClock => clk,
        GReset => resetBar,
        MSTL => MS_Light,
        SSTL => SS_Light,
        BCD1 => BCD1,
        BCD2 => BCD2
    );

    clk <= not clk AFTER 500 ps WHEN sim_end /= '1' else '0';
    
    stimulus: process
    begin
        resetBar <= '1';

        -- not actually testing since timing based tests are kind of annoying, but it gives a sim for debug purposes

        wait for 5 ns;

        SS_Car <= '1';

        wait for 40 ns;

        sim_end <= '1';
        wait;
    end process;
    
    
end architecture stimulus;
