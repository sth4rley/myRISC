LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY myRISCv2 IS
  PORT (
    clock : IN STD_LOGIC;
    reset : IN STD_LOGIC;
  );
END myRISCv2;
ARCHITECTURE behavior OF myRISCv2 IS

  -- 1 bit
  --SIGNAL wire_bne : STD_LOGIC;
  --SIGNAL wire_jump : STD_LOGIC;
  --SIGNAL wire_jr : STD_LOGIC;
  --SIGNAL wireAluSrc : STD_LOGIC;
  
  SIGNAL wire_clock : STD_LOGIC;
  SIGNAL wire_reset : STD_LOGIC;
  SIGNAL wire_zero : STD_LOGIC;
  
  SIGNAL wire_first: STD_LOGIC; -- debug primeira instrucao

  -- fios de controle
  SIGNAL wire_control_Branch : STD_LOGIC;
  SIGNAL wire_control_RegWrite : STD_LOGIC;
  SIGNAL wire_control_MemWrite : STD_LOGIC;
  SIGNAL wire_control_IRWrite : STD_LOGIC;
  SIGNAL wire_control_AluSrcA : STD_LOGIC;
  SIGNAL wire_control_RegDst : STD_LOGIC;
  SIGNAL wire_control_PcWrite : STD_LOGIC;
  SIGNAL wire_control_MemToReg : STD_LOGIC;
  SIGNAL wire_control_AluOp : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL wire_control_AluSrcB : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL wire_control_PcSrc : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL wire_control_AluOper : STD_LOGIC_VECTOR(2 DOWNTO 0); -- especifica a operacao da ALU

  -- 5 bits
  SIGNAL wireRT : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL wireRD : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL wireRS : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL wire_WriteRegister : STD_LOGIC_VECTOR(4 DOWNTO 0);

  -- 6 bits
  SIGNAL wire_opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL wire_funct : STD_LOGIC_VECTOR(5 DOWNTO 0);

  -- 16 bits
  SIGNAL wire_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0); -- extensao de sinal*

  -- 26 bits
  SIGNAL wire_addr : STD_LOGIC_VECTOR(25 DOWNTO 0);

  -- 32 bits
  SIGNAL wireJumpAddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wireBranchAddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wirePcPlus4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wireInst : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wireWriteData : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL wire_in_a : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wire_in_b : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wire_out_a : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wire_out_b : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wire_out_muxb : STD_LOGIC_VECTOR(31 DOWNTO 0); 
  SIGNAL wire_out_muxa : STD_LOGIC_VECTOR(31 DOWNTO 0); 

  SIGNAL wire_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wire_RomOut : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wire_AluOut : STD_LOGIC_VECTOR(31 DOWNTO 0);
  --SIGNAL wire_MemData : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL wire_out_mem : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wireNextPc : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wireNewPc : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL wire_MemDataRegOut : STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN
  PROCESS (clock, reset)
  BEGIN
    wire_clock <= clock;
    wire_reset <= reset;
  END PROCESS;

  CONTROL : ENTITY work.control PORT MAP(
  	-- TODO: Verificar a 1 instrucao
  	-- first => wire_first, -- debug primeira instrucao
    -- sinais de entrada do controle
    rst => wire_reset,
    clk => wire_clock,
    op => wire_opcode,
    -- sinais de saida do controle
    branch => wire_control_Branch,
    memWR => wire_control_MemWrite,
    memToReg => wire_control_MemToReg,
    aluOp => wire_control_AluOp,
    regWrite => wire_control_RegWrite,
    aluSrcA => wire_control_AluSrcA,
    aluSrcB => wire_control_AluSrcB,
    regDst => wire_control_RegDst,
    IRWrite => wire_control_IRWrite,
    PcWrite => wire_control_PcWrite,
    PcSrc => wire_control_PcSrc
    );

  ALUCONTROL : ENTITY work.aluControl PORT MAP (
    clk => wire_clock,
    aluOp => wire_control_AluOp,
    funct => wire_funct,
    oper => wire_control_AluOper
    );

  ALU : ENTITY work.alu PORT MAP (
    rega => wire_out_muxa,
    regb => wire_out_muxb,
    oper => wire_control_AluOper,
    result => wire_result,
    zero => wire_zero
    );
    
  PC : ENTITY work.reg32 PORT MAP(
    clk => wire_clock,
    rst => wire_reset,
    load => ((wire_zero AND wire_control_Branch) OR wire_control_PcWrite),-- AND (NOT wire_first), -- debug primeira execucao
    d => wireNextPc,
    q => wireNewPc
    );

  INSTRUCTION_MEMORY : ENTITY work.rom PORT MAP ( -- ROM
    address => wireNewPc,
    data => wire_RomOut
    );

  DATA_MEMORY : ENTITY work.ram PORT MAP ( -- RAM
    clk => wire_clock,
    datain => wire_out_b,
    address => wire_AluOut,
    write => wire_control_MemWrite,
    dataout => wire_out_Mem
    );

  INSTRUCTION_REGISTER : ENTITY work.instruction_register PORT MAP(
    clk => wire_clock,
    load => wire_control_IRWrite,
    inst => wire_RomOut,
    op => wire_opcode,
    addr => wire_addr,
    rs => wireRS,
    rt => wireRT,
    rd => wireRD,
    imm => wire_immediate,
    funct => wire_funct
    );

  REGISTERS : ENTITY work.registers PORT MAP (
    clock => wire_clock,
    reset => wire_reset,
    rr1 => wireRS, -- read register 1 (RS)
    rr2 => wireRt, -- read register 2 (RT)
    rw => wire_control_RegWrite, -- read or write on register -- control
    wr => wire_WriteRegister, -- register for write
    wd => wireWriteData, -- write data
    rd1 => wire_in_a, -- write a
    rd2 => wire_in_b -- write b
    );


  -- REGISTRADORES DE 32 BITS --
  REGISTER_A : ENTITY work.flipflop32 PORT MAP(
    clk => wire_clock,
    rst => wire_reset,
    d => wire_in_a,
    q => wire_out_a
    );

  REGISTER_B : ENTITY work.flipflop32 PORT MAP(
    clk => wire_clock,
    rst => wire_reset,
    d => wire_in_b,
    q => wire_out_b
    );

  ALU_OUT : ENTITY work.flipflop32 PORT MAP (
    clk => clock,
    rst => wire_reset,
    d => wire_result,
    q => wire_AluOut -- 
    );


  -- MULTIPLEXADORES --
  MUXWR : ENTITY work.mux215 PORT MAP( -- mux do write register do registrador
    d0 => wireRT,
    d1 => wireRD,
    s => wire_control_RegDst,
    y => wire_WriteRegister
    );

  MUXWD : ENTITY work.mux232 PORT MAP( -- mux do write data do registrador
    d0 => wire_AluOut,
    d1 => wire_MemDataRegOut,
    s => wire_control_MemToReg,
    y => wireWriteData
    );

  MUXA : ENTITY work.mux232 PORT MAP( -- mux do registrador A
    d0 => wireNewPc,
    d1 => wire_out_a,
    s => wire_control_AluSrcA,
    y => wire_out_muxa
    );

  MUXB : ENTITY work.mux432 PORT MAP( -- mux do registrador B
    d0 => wire_out_b,
    d1 => x"00000004",
    d2 => "0000000000000000" & wire_immediate,
    d3 => "00000000000000" & wire_immediate & "00",
    s => wire_control_AluSrcB,
    y => wire_out_muxb
    );

  MUXSOURCE : ENTITY work.mux332 PORT MAP( -- mux do source do alu
    d0 => wire_result,
    d1 => wire_AluOut,
    d2 => wireNewPC(31 DOWNTO 28) & wire_addr & "00",
    s => wire_control_PcSrc,
    y => wireNextPc
    );

END behavior;