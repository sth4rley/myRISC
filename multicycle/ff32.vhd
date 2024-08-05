library IEEE;
use IEEE.std_logic_1164.all;

entity flipflop32 is
	port(
    	clk, rst : in std_logic;
        d		 : in std_logic_vector(31 downto 0);
        q        : out std_logic_vector(31 downto 0)
	);
end flipflop32;

architecture behavior of flipflop32 is
	begin
    	
        process(clk, rst)
        	begin
            	if (falling_edge(rst)) then
                	q <= (q'range => '0');
                elsif (falling_edge(clk)) then
                	q <= d;
                end if;
        end process;
end behavior;