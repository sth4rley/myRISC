library ieee ;
use ieee.std_logic_1164.all;

entity mux215 is
  port(	
    d0, d1 : in std_logic_vector(4 downto 0);
    s      : in std_logic;
    y	   : out std_logic_vector(4 downto 0)
  );
end mux215;

architecture behavior of mux215 is
begin
  y <= d0 when s = '0' else d1 when s = '1';
end behavior;