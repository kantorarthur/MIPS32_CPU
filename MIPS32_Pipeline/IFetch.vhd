----------------------------------------------------------------------------------
-- Company: Technical University of Cluj-Napoca 
-- Engineer: Cristian Vancea
-- 
-- Module Name: IFetch - Behavioral
-- Description: 
--      Instruction Fecth Unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port (clk : in STD_LOGIC;
          rst : in STD_LOGIC;
          en : in STD_LOGIC;
          BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
          JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
          Jump : in STD_LOGIC;
          PCSrc : in STD_LOGIC;
          Instruction : out STD_LOGIC_VECTOR(31 downto 0);
          PCp4 : out STD_LOGIC_VECTOR(31 downto 0));
end IFetch;

architecture Behavioral of IFetch is

-- Memorie ROM
type tROM is array (0 to 33) of STD_LOGIC_VECTOR(31 downto 0);
signal ROM : tROM := (    
    0  => X"2010000C", -- ADDI $s0, $0, 12 - initalizez adresa de memorie
    1  => X"20110005", -- ADDI $s1, $0, 5 -- initalizez lungimea vectorului(n)
    2  => X"00009020", -- ADD $s2, $0, $0 -- initializez suma finala cu 0
    3  => X"00009820", -- ADD $s3, $0, $0 -- initializez contorul buclei(i = 0)
    4 => X"00000000", --NOOP
    5 => X"00000000", --NOOP  
    6  => X"12710019", -- LOOP: BEQ $s3, $s1, EXIT -- fac comparatie intre i si n iar daca i==n sar la exit
    7 => X"00000000", --NOOP
    8 => X"00000000", --NOOP
    9 => X"00000000", --NOOP
    10  => X"8E080000", -- LW $t0, 0($s0) -- citesc elementul curent din vector si il pun temporar in t0
    11 => X"00000000", --NOOP
    12 => X"00000000", --NOOP
    13  => X"29090003", -- SLTI $t1, $t0, 3 - verific daca valoarea curenta din vector e mai mica decat 3. daca e mai mica t1 devine 1
    14 => X"00000000", --NOOP
    15 => X"00000000", --NOOP
    16  => X"1520000B", -- BNE $t1, $0, NEXT -- daca t1 e 0 sare la next adica nu mai verific elementul
    17 => X"00000000", --NOOP
    18 => X"00000000", --NOOP
    19 => X"00000000", --NOOP
    20 => X"310A0001", -- ANDI $t2, $t0, 1 -- verific daca numarul curent din vector e impar. daca 
    21 => X"00000000", --NOOP
    22 => X"00000000", --NOOP
    23 => X"11400004", -- BEQ $t2, $0, NEXT daca t2 == 0 (adica e par) sar la next
    24 => X"00000000", --NOOP
    25 => X"00000000", --NOOP
    26 => X"00000000", --NOOP
    27 => X"02489020", -- ADD $s2, $s2, $t0 -- bag numarul curent in suma inala
    28 => X"22100004", -- NEXT: ADDI $s0, $s0, 4 -- cresc adresa de memorie cu 4 octeti ca sa verific nr urmator din vector
    29 => X"22730001", -- ADDI $s3, $s3, 1 -- incrementez i
    30 => X"08000006", -- J 6 (LOOP) -- sar inapoi la bucla
    31 => X"00000000", --NOOP
    32 => X"08000020", -- EXIT: J EXIT  -- opresc executia
    33 => X"00000000", --NOOP
    others => X"00000000"
);


signal PC : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal PCAux, NextAddr, AuxSgn : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- Program Counter
    process(clk, rst)
    begin
        if rst = '1' then
            PC <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                PC <= NextAddr;
            end if;
        end if;
    end process;

    -- Instruction OUT
    Instruction <= ROM(conv_integer(PC(7 downto 2)));

    -- PC + 4
    PCAux <= PC + 4;
    PCp4 <= PCAux;

    -- MUX for branch
    AuxSgn <= BranchAddress when PCSrc = '1' else PCAux;  
    
    -- MUX for jump
    NextAddr <= JumpAddress when Jump = '1' else AuxSgn;
    
end Behavioral;