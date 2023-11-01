----------------------------------------------------------------------------------------------
-- Write back                                                                               --
--														                                    --
-- myRISC												                                    --
-- Prof. Max Santana  (2023)                                                                --
-- CEComp/Univasf                                                                           --
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity writeback is
  port(
    memoryData : in std_logic_vector(31 downto 0);
    result     : in std_logic_vector(31 downto 0);
    memToReg   : in std_logic;
    writeData  : out std_logic_vector(31 downto 0)
  );
end writeback;

architecture behavior of writeback is
  signal wireRegB   	: std_logic_vector(31 downto 0);
  signal wireOper   	: std_logic_vector(2 downto 0);
begin
  MUXWD: entity work.mux232 port map (
    d0 => result,
    d1 => memoryData,
    s  => memToReg,
    y  => writeData
  );
end behavior;