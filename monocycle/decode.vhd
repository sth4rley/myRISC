----------------------------------------------------------------------------------------------
-- Instruction decode                                                                       --
--										            --
-- myRISC									            --
-- Prof. Max Santana  (2023)                                                                --
-- CEComp/Univasf                                                                           --
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity decode is
  port(
    clk        : in std_logic;
    rst        : in std_logic;
    PCplus4    : in std_logic_vector(31 downto 0);  -- next program counter (PC+4)
    inst       : in std_logic_vector(31 downto 0);  -- instruction
    writeData  : in std_logic_vector(31 downto 0);  -- write data
    regDst     : in std_logic_vector(1 downto 0);   -- control signal (regdst)
    regWrite   : in std_logic;                      -- control signal (regwrite)
    opcode     : out std_logic_vector(5 downto 0);  -- opcode
    jumpAddr   : out std_logic_vector(31 downto 0); -- Jump Address
    readData1  : out std_logic_vector(31 downto 0); -- Read data 1
    readData2  : out std_logic_vector(31 downto 0); -- Read data 2
    imm        : out std_logic_vector(31 downto 0); -- Imm (32 bits)
    funct      : out std_logic_vector(5 downto 0)   -- funct    
  );
end decode;

architecture behavior of decode is
  signal wireWriteRegister   	: std_logic_vector(4 downto 0);
begin
  opcode <= inst(31 downto 26);
  funct  <= inst(5 downto 0);
  
  JUMPER: process(inst, PCPlus4)
  begin
    jumpaddr(1 downto 0)   <= "00";
    jumpaddr(27 downto 2)  <= inst(25 downto 0) ;
    jumpaddr(31 downto 28) <= PCplus4(31 downto 28);
  end process JUMPER;
  
  EXTENDIMM: process(inst)
  begin 
    if(inst(15)='1') then
	  imm(15 downto 0)  <= inst(15 downto 0);
	  imm(31 downto 16) <= "1111111111111111";
    else 
	  imm(15 downto 0)  <= inst(15 downto 0);
	  imm(31 downto 16) <= "0000000000000000";
    end if;
  end process EXTENDIMM;
  
  MUXRT: entity work.mux35 port map (
    d0 => inst(20 downto 16), -- RT
    d1 => inst(15 downto 11), -- RD
    d2 => std_logic_vector(to_unsigned(31,5)),
    s  => regDst,
    y  => wireWriteRegister
  );
  
  CPUREGISTERS: entity work.registers port map (
    clock => clk,
    reset => rst,
    rr1   => inst(25 downto 21), -- read register 1 (RS)
    rr2   => inst(20 downto 16), -- read register 2 (RT)
    rw    => regWrite,           -- read or write on register
    wr    => wireWriteRegister,  -- register for write
    wd 	  => writeData,          -- write data
    rd1	  => readData1,          -- read data 1
    rd2	  => readData2           -- read data 2
  );
  
end behavior;