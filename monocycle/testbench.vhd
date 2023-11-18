LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY test IS
END ENTITY test;

ARCHITECTURE behavior OF test IS
    SIGNAL wire_clock, wire_reset : STD_LOGIC;
    CONSTANT clock_period : TIME := 10 ns;

BEGIN
    PROCESSOR : ENTITY work.MYRISC
        PORT MAP(
            clk => wire_clock,
            rst => wire_reset
        );

    -- o processo abaixo é responsável por gerar o sinal de clock
    -- o sinal de clock é ativado por 5 vezes e desativado por 5 vezes
    CLOCKGEN : PROCESS
    BEGIN
        FOR i IN 1 TO 70 LOOP
            wire_clock <= '0';
            WAIT FOR clock_period / 2;
            wire_clock <= '1';
            WAIT FOR clock_period / 2;
        END LOOP;
        WAIT;
    END PROCESS CLOCKGEN;

    -- o processo abaixo é responsável por gerar o sinal de reset
    -- o sinal de reset é ativado por 10 ns e desativado por 10 ns
    RESETGEN: PROCESS
    BEGIN
        wire_reset <= '1';
        WAIT FOR 10 ns;
        wire_reset <= '0';
        WAIT FOR 10 ns;
        WAIT;
    END PROCESS RESETGEN;


END ARCHITECTURE behavior;