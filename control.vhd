----------------------------------------------------------------------------------------------
-- Control              								    --
--										            --
-- myRISC									            --
-- Prof. Max Santana  (2023)                                                                --
-- CEComp/Univasf                                                                           --
----------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity control is
  port(
    op		 : in std_logic_vector(5 downto 0);
    regDst	 : out std_logic;
    jump	 : out std_logic;
    branch	 : out std_logic;
    bne		 : out std_logic;
    memWR	 : out std_logic;                    -- when 0 (write), 1 (read)
    memToReg     : out std_logic;
    aluOp	 : out std_logic_vector(1 downto 0); -- when 10 (R-type), 
                                                     --      00 (addi, lw, sw), 
                                                     --      01 (beq, bne), 
                                                     --      xx (j)
    aluSrc	 : out std_logic;
    regWrite     : out std_logic
  );
end control;

architecture behavior of control is
begin
  process(op)
  begin
    case (op) is
      when "000000" => -- R type			   
        regDst   <= '1';
	jump     <= '0';
        branch   <= '0';
        memWR    <= 'X';
        memToReg <= '0';
        aluOp	 <= "10";
        aluSrc	 <= '0';
        regWrite <= '1';  
      when "100011" => -- lw
        
      when "101011" => -- sw
        
      when "000100" => -- beq
        
      when "000101" => -- bne
              
      when "001000" => -- addi
        regDst	 <= '0';
	jump	 <= '0';
        branch	 <= '0';        
        memWR	 <= 'X';
        memToReg <= '0';
        aluOp	 <= "00";
        aluSrc	 <= '1';
        regWrite <= '1';
      when "000010" => -- j
        regDst	 <= 'X';
	jump	 <= '1';
        branch	 <= 'X';        
        memWR	 <= 'X';
        memToReg <= 'X';
        aluOp	 <= "XX";
        aluSrc	 <= 'X';
        regWrite <= 'X';
      when "000011" => -- jal      
      
      when others =>
        regDst	 <= 'X';
	jump	 <= 'X';
        branch	 <= 'X';
        memWR	 <= 'X';
        memToReg <= 'X';
        aluOp	 <= "XX";
        aluSrc	 <= 'X';
        regWrite <= '0';	 
    end case;	    
  end process;

end behavior;