----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2026 11:49:14 PM
-- Design Name: 
-- Module Name: ID - Behavioral
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
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ID is
 Port (
    clk : in std_logic;
    regwrite : in std_logic;
    instr : in std_logic_vector(25 downto 0);
    regdst : in std_logic;
    en : in std_logic;
    extop : in std_logic;
    wd : in std_logic_vector(31 downto 0);

    rd1 : out std_logic_vector(31 downto 0);
    rd2 : out std_logic_vector(31 downto 0);
    ext_imm : out std_logic_vector(31 downto 0);
    func : out std_logic_vector(5 downto 0);
    sa : out std_logic_vector(4 downto 0)
 );
end ID;

architecture Behavioral of ID is

type rf_type is array(0 to 31) of std_logic_vector(31 downto 0);
signal mem : rf_type := (others => X"00000000");

signal ra1, ra2, wa : std_logic_vector(4 downto 0);

begin

ra1 <= instr(25 downto 21); 
ra2 <= instr(20 downto 16); 

wa <= instr(15 downto 11) when regdst = '1' else  
      instr(20 downto 16);                        


process(clk)
begin
    if rising_edge(clk) then
        if regwrite = '1' and en = '1' then
            mem(conv_integer(wa)) <= wd;
        end if;
    end if;
end process;

rd1 <= mem(conv_integer(ra1));
rd2 <= mem(conv_integer(ra2));

ext_imm(15 downto 0) <= instr(15 downto 0);

ext_imm(31 downto 16) <= 
    (others => instr(15)) when extop = '1' else  
    (others => '0');                            

func <= instr(5 downto 0);
sa   <= instr(10 downto 6);

end Behavioral;
