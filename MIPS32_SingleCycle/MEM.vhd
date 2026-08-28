----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2026 10:55:07 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity MEM is
    Port ( 
        clk        : in  STD_LOGIC;
        en         : in  STD_LOGIC;
        mem_write  : in  STD_LOGIC;
        alu_res_in : in  STD_LOGIC_VECTOR (31 downto 0);
        rd2        : in  STD_LOGIC_VECTOR (31 downto 0);
        mem_data   : out STD_LOGIC_VECTOR (31 downto 0);
        alu_res_out: out STD_LOGIC_VECTOR (31 downto 0)
    );
end MEM;

architecture Behavioral of MEM is
    type ram_type is array (0 to 63) of STD_LOGIC_VECTOR (31 downto 0);
    signal MEM : ram_type := (
    3 => X"00000005", -- impar si >2 - se aduna
    4 => X"00000002", -- par si mai mic - nu se aduna
    5 => X"00000009", -- impar si mai mare - se aduna
    6 => X"00000001", --  impar dar mai mic - nu se aduna
    others => X"00000000" -- rezultat final ar trebui sa fie 14
    );

    signal address : STD_LOGIC_VECTOR(5 downto 0);

begin


    address <= alu_res_in(7 downto 2);

    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and mem_write = '1' then
                MEM(conv_integer(address)) <= rd2;
            end if;
        end if;
    end process;

    mem_data <= MEM(conv_integer(address));

    alu_res_out <= alu_res_in;

end Behavioral;