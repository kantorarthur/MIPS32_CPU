----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2026 01:07:16 PM
-- Design Name: 
-- Module Name: IFetch - Behavioral
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

entity IFetch is
Port ( jump : in std_logic;
       jumpAddress : in std_logic_vector(31 downto 0);
       pcSrc : in std_logic;
       branchAddress : in std_logic_vector(31 downto 0);
       btn : in std_logic;
       rst : in std_logic;
       clk : in std_logic;
       instruction : out std_logic_vector(31 downto 0);
       pc4 : out std_logic_vector(31 downto 0));
end IFetch;

architecture Behavioral of IFetch is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

signal en : std_logic := '0';
signal qPC : std_logic_vector(31 downto 0) := (others => '0');
signal muxInWhen0 : std_logic_vector(31 downto 0) := (others => '0');

type rom_type is array(0 to 31) of std_logic_vector(31 downto 0);
signal mem : rom_type := (
    0  => X"2010000C", -- ADDI $s0, $0, 12
    1  => X"20110005", -- ADDI $s1, $0, 5
    2  => X"00009020", -- ADD $s2, $0, $0
    3  => X"00009820", -- ADD $s3, $0, $0
    4  => X"12710009", -- LOOP: BEQ $s3, $s1, EXIT
    5  => X"8E080000", -- LW $t0, 0($s0)
    6  => X"29090003", -- SLTI $t1, $t0, 3
    7  => X"15200004", -- BNE $t1, $0, NEXT
    8  => X"310A0001", -- ANDI $t2, $t0, 1
    9  => X"11400002", -- BEQ $t2, $0, NEXT
    10 => X"02489020", -- ADD $s2, $s2, $t0
    11 => X"22100004", -- NEXT: ADDI $s0, $s0, 4
    12 => X"22730001", -- ADDI $s3, $s3, 1
    13 => X"08000004", -- J LOOP
    14 => X"0800000E", -- EXIT: J EXIT 
    others => X"00000000"
);
signal do : std_logic_vector(4 downto 0);

begin

--PC
monopulse : MPG port map(en,btn,clk);

--mux din mijloc
process
begin
    case pcSrc is
        when '0' => muxInWhen0 <= qPc+4;
        when '1' => muxInWhen0 <= branchAddress;
        when others => muxInWhen0 <= (others => '0');
     end case;
end process;

    
--PC
process(clk, rst)
begin
    if rst = '1' then
        qPC <= (others => '0');

    elsif rising_edge(clk) then
        if en = '1' then 
            if jump = '1' then
                qPC <= jumpAddress;

            elsif pcSrc = '1' then
                qPC <= branchAddress;

            else
                qPC <= qPC + 4;

            end if;

        end if;
    end if;
end process;

pc4 <= qPC + 4;

do <= qpc(6 downto 2);
instruction <= mem(conv_integer(do));



    

end Behavioral;
