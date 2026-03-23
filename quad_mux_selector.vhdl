LIBRARY ieee;
use ieee.std_logic_1164.ALL;

ENTITY quad_mux_selector IS 
    PORT (
    in_tt, in_tf, in_ft, in_ff : IN STD_LOGIC;
    in_sel_tt : IN STD_LOGIC;
    in_sel_tf : IN STD_LOGIC;
    in_sel_ft : IN STD_LOGIC;
    in_sel_ff : IN STD_LOGIC;
    out_mux : OUT STD_LOGIC
                        );
END quad_mux_selector;

ARCHITECTURE rtl of quad_mux_selector IS
    SIGNAL int_tt, int_tf, int_ft, int_ff : STD_LOGIC;
BEGIN
    int_tt <=  in_sel_tt AND in_tt;
    int_tf <=  in_sel_tf AND in_tf;
    int_ft <=  in_sel_ft AND in_ft;
    int_ff <=  in_sel_ff AND in_ff;

    -- output
    out_mux <=     int_tt 
               OR  int_tf 
               OR  int_ft 
               OR  int_ff;
END rtl;
