----------------------------------------------------------------------------------
-- Company: Technical University of Cluj-Napoca 
-- Engineer: Cristian Vancea
-- 
-- Module Name: MEM - Behavioral
-- Description: 
--      Memory Unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(31 downto 0));
end MEM;

architecture Behavioral of MEM is

type mem_type is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
signal MEM : mem_type := (
    3 => X"00000005", -- impar si >2 - se aduna
    4 => X"00000002", -- par si mai mic - nu se aduna
    5 => X"00000009", -- impar si mai mare - se aduna
    6 => X"00000001", --  impar dar mai mic - nu se aduna
    others => X"00000000" -- rezultat final ar trebui sa fie 14
    );



begin

    -- Data Memory
    process(clk) 			
    begin
        if rising_edge(clk) then
            if en = '1' and MemWrite = '1' then
                MEM(conv_integer(ALUResIn(7 downto 2))) <= RD2;			
            end if;
        end if;
    end process;

    -- outputs
    MemData <= MEM(conv_integer(ALUResIn(7 downto 2)));
    ALUResOut <= ALUResIn;

end Behavioral;