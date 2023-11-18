----------------------------------------------------------------------------------------------
-- Control              								    --
--										            --
-- myRISC									            --
-- Prof. Max Santana  (2023)                                                                --
-- CEComp/Univasf                                                                           --
----------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY control IS
  PORT (
    op : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    regDst : OUT std_logic_vector (1 downto 0);
    jump : OUT STD_LOGIC;
    branch : OUT STD_LOGIC;
    memWR : OUT STD_LOGIC; -- when 0 (write), 1 (read)
    memToReg   : OUT std_logic_vector (1 downto 0);
    aluOp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- when 10 (R-type), 
    --      00 (addi, lw, sw), 
    --      01 (beq, bne), 
    --      xx (j)
    aluSrc : OUT STD_LOGIC;
    regWrite : OUT STD_LOGIC;
    bne : OUT STD_LOGIC;
    jr : OUT STD_LOGIC;
    funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0)
  );
END control;

ARCHITECTURE behavior OF control IS
BEGIN
  PROCESS (op,funct)
  BEGIN
    CASE (op) IS
      WHEN "000000" => -- R type			   
        regDst <= "01";
        jump <= '0';
        branch <= '0';
        memWR <= 'X';
        memToReg <= "00";
        aluOp <= "10";
        aluSrc <= '0';
        regWrite <= '1';
        bne <= '0';
        jr <= '1' when funct = "001000" else '0';

      WHEN "100011" => -- lw
      regDst   <= "00";
	  jump     <= '0';
      branch   <= '0';
      memWR    <= '0';
      memToReg <= "01";
      aluOp	 <= "00";
      aluSrc	 <= '1';
      regWrite <= '1';
      bne <= '0';
	  jr <= '0';
      

      WHEN "101011" => -- sw
      regDst   <= "XX";
	  jump     <= '0';
      branch   <= '0';
      memWR    <= '1';
      memToReg <= "XX";
      aluOp	 <= "00";
      aluSrc	 <= '1';
      regWrite <= '0';
      bne      <= '0';
      
      
      -- when "100011" => -- lw
      --	regDst   <= "00";
	--	jump     <= "00";
     --   branch   <= '0';
      --  memWR    <= '0';
       -- memToReg <= "01";
       -- aluOp	 <= "00";
       -- aluSrc	 <= '1';
       -- regWrite <= '1';
      --  bne <= '0';
      --when "101011" => -- sw
      --	regDst   <= "XX";
		--jump     <= "00";
       -- branch   <= '0';
       -- memWR    <= '1';
       -- memToReg <= "XX";
       -- aluOp	 <= "00";
       -- aluSrc	 <= '1';
       -- regWrite <= '0';
       -- bne      <= '0';

      WHEN "000100" => -- beq
        regDst <= "XX";
        jump <= '0';
        branch <= '1';
        memWR <= 'X';
        memToReg <= "00";
        aluOp <= "01";
        aluSrc <= '0';
        regWrite <= '0';
        bne <= '0';
        jr <= '0';

      WHEN "000101" => -- bne
        regDst <= "XX";
        jump <= '0';
        branch <= '1';
        memWR <= 'X';
        memToReg <= "00";
        aluOp <= "01";
        aluSrc <= '0';
        regWrite <= '0';
        bne <= '1';
        jr <= '0';
        
      WHEN "001000" => -- addi
        regDst <= "00";
        jump <= '0';
        branch <= '0';
        memWR <= 'X';
        memToReg <= "00";
        aluOp <= "00";
        aluSrc <= '1';
        regWrite <= '1';
        jr <= '0';

      WHEN "000010" => -- j
        regDst <= "XX";
        jump <= '1';
        branch <= 'X';
        memWR <= 'X';
        memToReg <= "XX";
        aluOp <= "XX";
        aluSrc <= 'X';
        regWrite <= 'X';
        jr <= '0';

      WHEN "000011" => -- jal
      regDst   <= "10";
		jump     <= '1';
        branch   <= 'X';
        memWR    <= 'X';
        memToReg <= "10";
        aluOp	 <= "XX";
        aluSrc	 <= 'X';
        regWrite <= '1';
        bne      <= 'X';
        jr <= '0';

      WHEN OTHERS =>
        regDst <= "XX";
        jump <= 'X';
        branch <= 'X';
        memWR <= 'X';
        memToReg <= "XX";
        aluOp <= "XX";
        aluSrc <= 'X';
        regWrite <= '0';
        jr <= '0';
    END CASE;
  END PROCESS;

END behavior;