----------------------------------------------------------------------------------------------
-- Instruction fetch                                                                        --
--							                                    --
-- myRISC										    --
-- Prof. Max Santana  (2023)                                                                --
-- CEComp/Univasf                                                                           --
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fetch is
  port(
    clk        : in std_logic;
    rst        : in std_logic;
    branch     : in std_logic;                      -- control signal (branch)
    jump       : in std_logic;                      -- control signal (jump)
    zero       : in std_logic;                      -- control signal (zero)
    jumpAddr   : in std_logic_vector(31 downto 0);  -- Jump Address
    branchAddr : in std_logic_vector(31 downto 0);  -- Branch Address
    PCplus4    : out std_logic_vector(31 downto 0); -- next program counter (PC+4)
    inst       : out std_logic_vector(31 downto 0);  -- instruction
    bne        : in std_logic;
    jr         : in std_logic;
    readData1 : in std_logic_vector(31 downto 0);
    funct : in std_logic_vector(5 downto 0)
  );
end fetch;

architecture behavior of fetch is
  signal wireBranchAddr, wireInstAddr, wireNextPC, wireJumpAddr : std_logic_vector(31 downto 0);
  signal wireMuxJr : std_logic_vector(31 downto 0);
  signal branchEnable:std_logic;

begin
  PC : entity work.rreg32 port map (
    clk => clk, 
    rst => rst, 
    d => wireNextPC, 
    q => wireInstAddr
  );
  ADDER: entity work.adder32 port map (
    a => wireInstAddr,
    b => x"00000004",
    s => PCplus4
  );
  MUXJUMP: entity work.mux232 port map (
    d0 => wireBranchAddr,
    d1 => jumpAddr,
    s  => jump,
    y  => wireMuxJr
  );
  
    	process (zero, branch)
begin
  branchEnable <= (zero xor bne) and branch;
end process;
  
  MUXBRANCH: entity work.mux232 port map (
    d0 => PCPlus4,
    d1 => branchAddr,
    --s  => zero and branch,
    s => branchEnable,
    y  => wireBranchAddr
  );

  -- y = (s == 0) ? d0 : d1;
  MUXJR: entity work.mux232 port map (
    d0 => wireMuxJr, -- caso s = 0
    -- read data 1 no d1
    d1 => readData1, -- caso s = 1
    s  => jr, -- select do mux
    y  => wireNextPC -- saida do mux
  );

  IMEMORY: entity work.rom port map (
    address => wireInstAddr,
    data    => inst
  );
end behavior;