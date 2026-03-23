entity sim is
    end entity sim;

architecture sim of sim is
    component counter_sim is end component;
    component nbit_comparator_sim is end component;
    component ripple_adder_4bit_sim is end component;
    component ripple_adder_8bit_sim is end component;
    component load_default_state_sim is end component;
    component traffic_controller_sim is end component;
    component hex_bcd_decoder_sim is end component;
    component n_clk_divider_sim is end component;
    component uart_sim is end component;
    component debuggable_traffic_light_sim is end component;

begin

    counter_sim_inst: counter_sim;
    nbit_comparator_sim_inst: nbit_comparator_sim;
    ripple_adder_4bit_sim_inst: ripple_adder_4bit_sim ;
    ripple_adder_8bit_sim_inst: ripple_adder_8bit_sim ;
    load_default_state_sim_inst : load_default_state_sim;
    traffic_controller_sim_inst : traffic_controller_sim;
    hex_bcd_decoder_sim_inst : hex_bcd_decoder_sim;
    n_clk_divider_sim_inst: n_clk_divider_sim;
    uart_sim_inst: uart_sim;
debuggable_traffic_light_sim_inst: debuggable_traffic_light_sim;
end architecture sim;
