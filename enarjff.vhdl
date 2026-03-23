-- Modifierd from profs jkff_2, but adds an async reset and enable

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity enarjff is
	PORT(
		i_j, i_k	: IN	STD_LOGIC;
		i_clock		: IN	STD_LOGIC;
        enable: IN STD_LOGIC;
        resetBar: IN STD_LOGIC;
		o_q, o_qBar	: OUT	STD_LOGIC);
end entity enarjff;

ARCHITECTURE rtl OF enarjff IS
	SIGNAL int_q, int_qBar, int_muxOutput : STD_LOGIC;
	SIGNAL int_jk : STD_LOGIC_VECTOR(1 downto 0);

    component  enARdFF_2 IS
	PORT(
		i_resetBar	: IN	STD_LOGIC;
		i_d		: IN	STD_LOGIC;
		i_enable	: IN	STD_LOGIC;
		i_clock		: IN	STD_LOGIC;
		o_q, o_qBar	: OUT	STD_LOGIC);
    END component;

BEGIN

dFlipFlop: enARdFF_2
PORT MAP (i_d => int_muxOutput, 
          i_resetBar => resetBar,
          i_enable => enable,
          i_clock => i_clock,
          o_q => int_q,
          o_qBar => int_qBar);

int_jk			<=	i_j & i_k;
-- I did not write this, this is from the profs code. It's shorthand for a mux
-- and can be translated 1:1 to AND gates. I wouldn't consider this behavioral
int_muxOutput	<=	int_q when int_jk = "00" else
					'0' when int_jk = "01" else
					'1' when int_jk = "10" else
					int_qBar;

	-- Output Driver
	o_q	<= int_q;
	o_qBar	<= int_qBar;

END rtl;

