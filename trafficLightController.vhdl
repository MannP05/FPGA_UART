library ieee;
use ieee.std_logic_1164.ALL;

entity trafficLightController is
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
end entity trafficLightController;

architecture rtl of trafficLightController is
    constant MAX_STATE : integer := 3;
    constant MT : STD_LOGIC_VECTOR(3 downto 0) := "1010";
    constant SST : STD_LOGIC_VECTOR(3 downto 0) := "0011";


    component nbit_register IS 
        generic ( 
                    BITS : integer := 8
                );
        PORT (
                 in_val : IN STD_LOGIC_VECTOR(BITS - 1 DOWNTO 0);
                 in_load : IN STD_LOGIC;
                 in_resetBar : IN STD_LOGIC;
                 in_clock : IN STD_LOGIC;
                 out_val : OUT STD_LOGIC_VECTOR(BITS - 1 DOWNTO 0)
             );
    END component;

    component srLatch IS
        PORT(
        i_set, i_reset		: IN	STD_LOGIC;
        o_q, o_qBar		: OUT	STD_LOGIC);
    END component;

    component counter is
    generic ( 
                BITS : integer := 4
            );
    port (
        incr : in STD_LOGIC;
        resetBar : in STD_LOGIC;
        clock : in STD_LOGIC;
        compare : in STD_LOGIC_VECTOR(BITS - 1 downto 0);
        val : out STD_LOGIC_VECTOR(BITS - 1 downto 0);
        val_gt : out STD_LOGIC;
        val_lt : out STD_LOGIC;
        val_gteq : out STD_LOGIC;
        val_lteq : out STD_LOGIC;
        val_equal : out STD_LOGIC
    );
    end component;

    component load_default_state is
    generic (
        MAX_STATE : INTEGER := 8
            );
    port (
             current_state : in std_logic_vector(MAX_STATE downto 0);
             default_state : in std_logic_vector(MAX_STATE downto 0);
             load_state : out std_logic_vector(MAX_STATE downto 0)
    );
    end component;

    component hex_bcd_decoder is
        port (
                 hex_val : IN std_logic_vector(3 downto 0);
                 dec_msb : OUT std_logic_vector(3 downto 0);
                 dec_lsb : OUT std_logic_vector(3 downto 0)
             );
    end component;


    signal int_reset_state : std_logic_vector(MAX_STATE downto 0);
    signal int_reset_out : std_logic_vector(MAX_STATE downto 0);
    signal int_load_state : std_logic_vector(MAX_STATE downto 0);

    signal int_goto_state : std_logic_vector(MAX_STATE downto 0);
    signal int_state : std_logic_vector(MAX_STATE downto 0);

    signal sCountG_val : STD_LOGIC_VECTOR(3 downto 0);
    signal sCountY_val : STD_LOGIC_VECTOR(3 downto 0);
    signal mCountY_val : STD_LOGIC_VECTOR(3 downto 0);
    signal mCountG_val : STD_LOGIC_VECTOR(3 downto 0);
    signal counter_val : STD_LOGIC_VECTOR(3 downto 0);

    signal counter_gteq : STD_LOGIC;
    signal car_present : STD_LOGIC;

    signal sCountG_gteq_ssc : STD_LOGIC;
    signal sCountY_gteq_sst : STD_LOGIC;
    signal mCountY_gteq_mt : STD_LOGIC;
    signal mCountG_gteq_msc : STD_LOGIC;

    signal ResetSSCS : STD_LOGIC;
    signal ResetMG : STD_LOGIC;
    signal ResetMY : STD_LOGIC;
    signal ResetSG : STD_LOGIC;
    signal ResetSY : STD_LOGIC;

begin

    states: nbit_register
     generic map(
        BITS => MAX_STATE + 1
    )
     port map(
        in_val => int_load_state,
        in_load => '1',
        in_resetBar => GReset,
        in_clock => GClock,
        out_val => int_state
    );

    default_state :  load_default_state
                     generic map(
                        MAX_STATE => MAX_STATE
                    )
                     port map(
                        current_state => int_state,
                        default_state => int_reset_state,
                        load_state => int_reset_out
                    );

    -- car arrived latch

    carlatch : srLatch
    port map(
                i_set => SSCS,
                i_reset => ResetSSCS,
                o_q => car_present,
                o_qBar => open
            );


    -- counters
    mCountG: counter
     generic map( BITS => 4)
     port map(
        incr => '1',
        resetBar => ResetMG,
        clock => GClock,
        compare => MSC,
        val_gteq => mCountG_gteq_msc,
        val => mCountG_val,
        val_lt => open, val_lteq => open, val_equal => open,  val_gt => open
    );

    mCountY: counter
     generic map( BITS => 4)
     port map(
        incr => '1',
        resetBar => ResetMY,
        clock => GClock,
        compare => MT,
        val_gteq => mCountY_gteq_mt,
        val => mCountY_val,
        val_lt => open, val_lteq => open, val_equal => open,  val_gt => open
    );

    sCountG: counter
     generic map( BITS => 4)
     port map(
        incr => '1',
        resetBar => ResetSG,
        clock => GClock,
        compare => SSC,
        val_gteq => sCountG_gteq_ssc,
        val => sCountG_val,
        val_lt => open, val_lteq => open, val_equal => open,  val_gt => open
    );

    sCountY: counter
     generic map( BITS => 4)
     port map(
        incr => '1',
        resetBar => ResetSY,
        clock => GClock,
        compare => SST,
        val_gteq => sCountY_gteq_sst,
        val => sCountY_val,
        val_lt => open, val_lteq => open, val_equal => open,  val_gt => open
    );

    -- FSM logic
    -- state transitions
    int_goto_state(3) <= (int_state(2) AND counter_gteq ) OR (int_state(3) AND NOT counter_gteq);
    int_goto_state(2) <= (int_state(1) AND counter_gteq ) OR (int_state(2) AND NOT counter_gteq);
    int_goto_state(1) <= (int_state(0) AND counter_gteq ) OR (int_state(1) AND NOT counter_gteq);
    int_goto_state(0) <= (int_state(3) AND counter_gteq ) OR (int_state(0) AND NOT counter_gteq);
    int_reset_state <= "0001";
    int_load_state <= int_goto_state OR int_reset_out; -- handle reset, idk if this is cleaner or not, but it causes compiler errors if i add another state so that's very good 

    -- signals
    counter_gteq <= mCountG_gteq_msc OR mCountY_gteq_mt OR sCountG_gteq_ssc OR sCountY_gteq_sst;


    -- outputs
    MSTL(2) <= int_state(0);
    MSTL(1) <= int_state(1);
    MSTL(0) <= int_state(2) OR int_state(3);

    SSTL(2) <= int_state(2);
    SSTL(1) <= int_state(3);
    SSTL(0) <= int_state(0) OR int_state(1);

    ResetSSCS <= int_state(0) NAND GReset;
    ResetMG <= int_state(0) AND car_present AND GReset;
    ResetMY <= int_state(1) AND GReset;
    ResetSG <= int_state(2) AND GReset;
    ResetSY <= int_state(3) AND GReset;

    -- BCD
    counter_val <= mCountG_val OR mCountY_val OR sCountG_val OR sCountY_val; -- only one counter is active at once, so OR  will just passthrough the active one
    bcd_decoder: hex_bcd_decoder 
        port map (
                 hex_val => counter_val,
                 dec_msb => BCD2,
                 dec_lsb => BCD1
             );

end architecture rtl;


