LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY control IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    op : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    -- first: OUT STD_LOGIC; -- debug primeira instrucao
    irWrite : OUT STD_LOGIC;
    PcWrite : OUT STD_LOGIC;
    aluSrcA : OUT STD_LOGIC;
    aluSrcB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    aluOp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    regDst : OUT STD_LOGIC;
    regWrite : OUT STD_LOGIC;
    memWR : OUT STD_LOGIC;
    memToReg : OUT STD_LOGIC;
    PcSrc : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    state : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    branch : OUT STD_LOGIC
  );
END control;

ARCHITECTURE behavior OF control IS

  TYPE FSM IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11);

  SIGNAL current_state, next_state : FSM;

BEGIN
  PROCESS (clk, rst)
  BEGIN
    IF (falling_edge(rst)) THEN
      current_state <= S0;
      state <= "0000";
      -- first <= '1'; -- debug primeira instrucao
    ELSIF (falling_edge(clk)) THEN
      CASE current_state IS
        WHEN S0 => state <= "0000"; 
        WHEN S1 => state <= "0001"; -- first <= '0'; -- debug primeira instrucao
        WHEN S2 => state <= "0010";
        WHEN S3 => state <= "0011";
        WHEN S4 => state <= "0100";
        WHEN S5 => state <= "1001";
        WHEN S6 => state <= "0110";
        WHEN S7 => state <= "0111";
        WHEN S8 => state <= "1000";
        WHEN S9 => state <= "1001";
        WHEN S10 => state <= "1010";
        WHEN S11 => state <= "1011";
        WHEN OTHERS =>
      END CASE;

      current_state <= next_state;
    END IF;
  END PROCESS;

  PROCESS (current_state, op)
  BEGIN
    CASE current_state IS
      WHEN S0 =>
        aluSrcA <= '0';
        aluSrcB <= "01";
        aluOp <= "00";
        PcSrc <= "00";
        irWrite <= '1';
        PcWrite <= '1';
        branch <= 'X';
        memWR <= 'X';
        memToReg <= 'X';
        regWrite <= 'X';
        regDst <= 'X';
        next_state <= S1;

      WHEN S1 =>
        aluSrcA <= '0';
        aluSrcB <= "11";
        aluOp <= "00";
        irWrite <= 'X';
        PcWrite <= 'X';

        CASE op IS
          WHEN "000000" =>
            next_state <= S6;
          WHEN "100011" | "101011" =>
            next_state <= S2;
          WHEN "000100" =>
            next_state <= S8;
          WHEN "001000" =>
            next_state <= S9;
          WHEN OTHERS =>
            next_state <= S11;
        END CASE;

      WHEN S2 =>
        aluSrcA <= '1';
        aluSrcB <= "10";
        aluOp <= "00";

        IF (op = "100011") THEN
          next_state <= S3;
        ELSIF (op = "101011") THEN
          next_state <= S5;
        END IF;

      WHEN S3 =>
        next_state <= S4;

      WHEN S4 =>
        regDst <= '0';
        memToReg <= '1';
        regWrite <= '1';
        next_state <= S0;

      WHEN S5 =>
        memWR <= '1';
        next_state <= S0;

      WHEN S6 =>
        aluSrcA <= '1';
        aluSrcB <= "00";
        aluOp <= "10";
        next_state <= S7;

      WHEN S7 =>
        regDst <= '1';
        memToReg <= '0';
        regWrite <= '1';
        next_state <= S0;

      WHEN S8 =>
        aluSrcA <= '1';
        aluSrcB <= "00";
        aluOp <= "01";
        PcSrc <= "01";
        branch <= '1';
        next_state <= S0;

      WHEN S9 =>
        aluSrcA <= '1';
        aluSrcB <= "10";
        aluOp <= "00";
        next_state <= S10;

      WHEN S10 =>
        regDst <= '0';
        memToReg <= '0';
        regWrite <= '1';
        next_state <= S0;

      WHEN S11 =>
        PcSrc <= "10";
        PcWrite <= '1';
        next_state <= S0;

      WHEN OTHERS =>
    END CASE;
  END PROCESS;

END behavior;
