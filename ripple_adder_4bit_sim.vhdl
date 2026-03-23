library ieee;
use ieee.std_logic_1164.ALL;

entity ripple_adder_4bit_sim is
end ripple_adder_4bit_sim;

architecture test of ripple_adder_4bit_sim is
    constant BITS : integer := 4;
    signal A, B : std_logic_vector(BITS - 1 downto 0);
    signal Cin, add_sub : std_logic;
    signal sum_diff : std_logic_vector(BITS - 1 downto 0);
    signal Cout,Zero,Overflow : std_logic;

    component ripple_adder
        generic (
                    BITS : integer
                );
        port(
                A: in std_logic_vector(BITS - 1 downto 0); 
                B : in std_logic_vector(BITS - 1 downto 0); 
                Cin : in std_logic; 
                sum : out std_logic_vector(BITS - 1 downto 0);
                Cout : out std_logic;
                Zero : out std_logic;
                Overflow : out std_logic;
                add_sub : in std_logic -- flag for add or subtract
            );
    end component;
begin
    temp: ripple_adder
    generic map (
                    BITS => BITS
                )
    port map (
                 A => A,
                 B => B,
                 Cin => Cin,
                 sum => sum_diff,
                 Cout => Cout,
                 add_sub => add_sub,
                 Zero => Zero,
                 Overflow =>  Overflow
             );

    stimulus: process
    begin
        -- Test addition
        A <= "0011";
        B <= "0011";
        Cin <= '0';
        add_sub <= '0';
        wait for 10 ns;
        -- answer should be 01000

        -- Test subtraction
        A <= "0101";
        B <= "0011";
        Cin <= '0';
        add_sub <= '1';
        wait for 10 ns;
        -- answer should be 11110 (2's complement of 2)

        wait;
    end process;
end test;
