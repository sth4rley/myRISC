----------------------------------------------------------------------------------------------
-- Instruction execute                                                                      --
--														                                    --
-- myRISC												                                    --
-- Prof. Max Santana  (2023)                                                                --
-- CEComp/Univasf                                                                           --
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity execute is
  port(
    PCplus4    : in std_logic_vector(31 downto 0);   -- next program counter (PC+4)
    aluSrc     : in std_logic;                       -- control signal (aluSrc)
    readData1  : in std_logic_vector(31 downto 0);   -- Read data 1
    readData2  : in std_logic_vector(31 downto 0);   -- Read data 2
    imm  	   : in std_logic_vector(31 downto 0);   -- Imm (32 bits)
    funct      : in std_logic_vector(5 downto 0);    -- control signal (funct)
    aluOP	   : in std_logic_vector(1 downto 0);    -- control signal (aluOP)
    zero       : out std_logic;                      -- zero
    result     : out std_logic_vector(31 downto 0);  -- result (32 bits)
    branchAddr : out std_logic_vector(31 downto 0)
  );
end execute;

architecture behavior of execute is
  signal wireRegB   	: std_logic_vector(31 downto 0);
  signal wireOper   	: std_logic_vector(2 downto 0);
begin
  MUXREGB: entity work.mux232 port map (
    d0 => readData2,
    d1 => imm,
    s  => aluSrc,
    y  => wireRegB
  );
  ALURISC: entity work.alu port map (
    regA   => readData1,	
    regB   => wireRegB,	
    oper   => wireOper,
	result => result, 
    zero   => zero
  );
  ALUCTRL: entity work.alucontrol port map (
    aluOP => aluOP,
    funct => funct,
    oper  => wireOper
  );
  ADDER: entity work.adder32 port map (
    a => PCplus4,
    b => imm sll 2,
    s => branchAddr
  );
end behavior;