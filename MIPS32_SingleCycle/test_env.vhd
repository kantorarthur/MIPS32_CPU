----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2026 11:45:27 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
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



entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR(4 downto 0);
           sw : in STD_LOGIC_VECTOR(15 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end test_env;

architecture Behavioral of test_env is


component MPG is
    Port(enable: out STD_LOGIC;
         btn: in STD_LOGIC;
         clk: in STD_LOGIC);
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch is
    Port ( jump : in std_logic;
           jumpAddress : in std_logic_vector(31 downto 0);
           pcSrc : in std_logic;
           branchAddress : in std_logic_vector(31 downto 0);
           btn : in std_logic;
           rst : in std_logic;
           clk : in std_logic;
           instruction : out std_logic_vector(31 downto 0);
           pc4 : out std_logic_vector(31 downto 0));
end component;

component ID is
    Port ( clk : in std_logic;
           en : in std_logic;
           instr : in std_logic_vector(25 downto 0);
           wd : in std_logic_vector(31 downto 0);
           regwrite : in std_logic;
           regdst : in std_logic;
           extop : in std_logic;
           rd1 : out std_logic_vector(31 downto 0);
           rd2 : out std_logic_vector(31 downto 0);
           ext_imm : out std_logic_vector(31 downto 0);
           func : out std_logic_vector(5 downto 0);
           sa : out std_logic_vector(4 downto 0));
end component;

component UC is
    Port ( instr : in std_logic_vector(5 downto 0);
           regdst : out std_logic;
           extop : out std_logic;
           alusrc : out std_logic;
           branch : out std_logic;
           jump : out std_logic;
           aluop : out std_logic_vector(2 downto 0);
           memwrite : out std_logic;
           memtoreg : out std_logic;
           regwrite : out std_logic);
end component;

component EX is
    Port ( rd1 : in  std_logic_vector(31 downto 0);
           rd2 : in std_logic_vector(31 downto 0);
           ext_imm : in  std_logic_vector(31 downto 0);
           func : in  std_logic_vector(5 downto 0);
           sa : in  std_logic_vector(4 downto 0);
           aluop : in  std_logic_vector(2 downto 0);
           alusrc : in  std_logic;
           pc_plus4 : in  std_logic_vector(31 downto 0);
           alures : out std_logic_vector(31 downto 0);
           zero: out std_logic;
           gtz : out std_logic;
           branchaddr: out std_logic_vector(31 downto 0));
end component;

component MEM is
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           mem_write : in STD_LOGIC;
           alu_res_in : in STD_LOGIC_VECTOR (31 downto 0);
           rd2 : in STD_LOGIC_VECTOR (31 downto 0);
           mem_data : out STD_LOGIC_VECTOR (31 downto 0);
           alu_res_out: out STD_LOGIC_VECTOR (31 downto 0));
end component;


signal regdst, extop, alusrc, branch, jump, memwrite, memtoreg, regwrite : std_logic;
signal aluop : std_logic_vector(2 downto 0);


signal en, rst : std_logic;
signal instruction, pc4, rd1, rd2, ext_imm, alures, mem_data, alu_res_out : std_logic_vector(31 downto 0);
signal func : std_logic_vector(5 downto 0);
signal sa : std_logic_vector(4 downto 0);
signal zero, gtz : std_logic;
signal branchaddr, jumpaddr, wd : std_logic_vector(31 downto 0);
signal pcsrc : std_logic;


signal inSSD : std_logic_vector(31 downto 0);

begin

    monopulse_en : MPG port map(en, btn(0), clk);
    monopulse_rst : MPG port map(rst, btn(1), clk);

    jumpaddr <= pc4(31 downto 28) & instruction(25 downto 0) & "00";
    pcsrc <= branch and zero; 
    
    inst_IF : IFetch port map(jump, jumpaddr, pcsrc, branchaddr, en, rst, clk, instruction, pc4);


    inst_UC : UC port map(instruction(31 downto 26), regdst, extop, alusrc, branch, jump, aluop, memwrite, memtoreg, regwrite);
    
    inst_ID : ID port map(clk, en, instruction(25 downto 0), wd, regwrite, regdst, extop, rd1, rd2, ext_imm, func, sa);


    inst_EX : EX port map(rd1, rd2, ext_imm, func, sa, aluop, alusrc, pc4, alures, zero, gtz, branchaddr);


    inst_MEM : MEM port map(clk, en, memwrite, alures, rd2, mem_data, alu_res_out);


    wd <= mem_data when memtoreg = '1' else alu_res_out;

    led(8) <= aluop(0);
    led(7) <= regdst;
    led(6) <= extop;
    led(5) <= alusrc;
    led(4) <= branch;
    led(3) <= jump;
    led(2) <= memwrite;
    led(1) <= memtoreg;
    led(0) <= regwrite; 


    process(sw(7 downto 5), instruction, pc4, rd1, rd2, ext_imm, alures, mem_data, wd)
    begin
        case sw(7 downto 5) is
            when "000" => inSSD <= instruction;
            when "001" => inSSD <= pc4;
            when "010" => inSSD <= rd1;
            when "011" => inSSD <= rd2;
            when "100" => inSSD <= ext_imm;
            when "101" => inSSD <= alures;
            when "110" => inSSD <= mem_data;
            when "111" => inSSD <= wd;
            when others => inSSD <= (others => '0');
        end case;
    end process;

    display : SSD port map(clk, inSSD, an, cat);

end Behavioral;
