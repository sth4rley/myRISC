LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY myRISC IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC
    );
END myRISC;

ARCHITECTURE behv OF myRISC IS
    SIGNAL wire_clock : STD_LOGIC;
    SIGNAL wire_reset : STD_LOGIC;
    SIGNAL wire_branch : STD_LOGIC;
    SIGNAL wire_jump : STD_LOGIC;
    SIGNAL wire_zero : STD_LOGIC;
    SIGNAL wire_reg_write : STD_LOGIC;
    SIGNAL wire_bne : STD_LOGIC;
    SIGNAL wire_alu_src : STD_LOGIC;
    SIGNAL wire_mem_read_write : STD_LOGIC;
    SIGNAL wire_jr : STD_LOGIC;
    SIGNAL wire_jump_address : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wire_branch_address : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wire_next_instruction_address : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wire_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wire_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wire_read_data_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wire_read_data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wire_immediate : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wire_alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0); 
    SIGNAL wire_memory_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wire_NULL : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wire_instruction_opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL wire_function : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL wire_alu_opcode : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL wire_register_destination : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL wire_memory_to_register : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL wire_operator : STD_LOGIC_VECTOR(2 DOWNTO 0);
    --  wire from read data 1 to MUXBRANCH for jr instruction
    SIGNAL wire_mux_branch : STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN

    -- A arquitetura myRISC é separada em estágios:
    -- fetch (IF), busca de instrução.
    -- control (ID), controle.
    -- instruction decode (ID), decodificação de instrução.
    -- execute (EX), execução.
    -- data memory (Mem), acesso a memória de dados.
    -- write back (WB), escrita de volta.


    -- responsável por sincronizar o clock e o reset.
    PROCESS (clk, rst)
    BEGIN
        wire_clock <= clk;
        wire_reset <= rst;
    END PROCESS;

    -- responsável por buscar a instrução na memória de instruções.
    FETCH : ENTITY work.fetch PORT MAP (
        clk => wire_clock,
        rst => wire_reset,
        branch => wire_branch,
        jump => wire_jump,
        zero => wire_zero,
        jumpAddr => wire_jump_address,
        PCplus4 => wire_next_instruction_address,
        inst => wire_instruction,
        branchAddr => wire_branch_address,
        bne => wire_bne,
        readData1 => wire_read_data_1,
        jr => wire_jr,
        funct => wire_function
        );

    -- responsável por controlar os sinais de controle
    CONTROL : ENTITY work.control PORT MAP (
        op => wire_instruction_opcode,
        regDst => wire_register_destination,
        jump => wire_jump,
        branch => wire_branch,
        bne => wire_bne,
        memToReg => wire_memory_to_register,
        aluSrc => wire_alu_src,
        regWrite => wire_reg_write,
        memWR => wire_mem_read_write,
        aluOp => wire_alu_opcode,
        -- jr function
        jr => wire_jr,
        funct => wire_function
        );

    -- responsável por decodificar a instrução.
    DECODE : ENTITY work.decode PORT MAP (
        clk => wire_clock,
        rst => wire_reset,
        PCplus4 => wire_next_instruction_address,
        inst => wire_instruction,
        writeData => wire_data,
        regDst => wire_register_destination,
        regWrite => wire_reg_write,
        opcode => wire_instruction_opcode,
        jumpAddr => wire_jump_address,
        readData1 => wire_read_data_1,
        readData2 => wire_read_data_2,
        imm => wire_immediate,
        funct => wire_function
        );

    -- responsável por executar a instrução.
    EXECUTE : ENTITY work.execute PORT MAP (
        PCplus4 => wire_next_instruction_address,
        readData1 => wire_read_data_1,
        readData2 => wire_read_data_2,
        imm => wire_immediate,
        funct => wire_function,
        aluSrc => wire_alu_src,
        aluOP => wire_alu_opcode,
        result => wire_alu_result,
        zero => wire_zero,
        branchAddr => wire_branch_address
        );

    -- responsável por acessar a memória de dados.
    MEMORYACCESS : ENTITY work.memoryAccess PORT MAP (
        address => wire_alu_result,
        memWrite => wire_mem_read_write,
        clk => wire_clock,
        writeData => wire_read_data_2,
        memoryData => wire_memory_data
        );

    -- responsável por escrever o resultado no registrador.
    WRITEBACK : ENTITY work.writeback PORT MAP (
        memoryData => wire_memory_data,
        result => wire_alu_result,
        memToReg => wire_memory_to_register,
        writeData => wire_data,
        PcPlus4 => wire_next_instruction_address -- !
        );

END ARCHITECTURE behv;