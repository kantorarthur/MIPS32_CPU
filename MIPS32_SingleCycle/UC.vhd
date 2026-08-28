----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2026 01:30:05 AM
-- Design Name: 
-- Module Name: UC - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UC is
Port ( instr : std_logic_vector(5 downto 0);
        regdst : out std_logic;
        extop : out std_logic;
        alusrc : out std_logic;
        branch : out std_logic;
        jump : out std_logic;
        aluop : out std_logic_vector(2 downto 0);
        memwrite : out std_logic;
        memtoreg : out std_logic;
        regwrite : out std_logic);
end UC;

architecture Behavioral of UC is
begin
--aleg 000 pt codr, 001 pt cod+,010 pt cod-, 011 pt cod<, 100 pt cod&, 101 pt cod|
process(instr)
begin
    regdst   <= '0';
    extop    <= '0';
    alusrc   <= '0';
    branch   <= '0';
    jump     <= '0';
    aluop    <= "000";
    memwrite <= '0';
    memtoreg <= '0';
    regwrite <= '0';

    case instr is
    --tip r
        when "000000" =>
            regdst   <= '1';
            alusrc   <= '0';
            branch   <= '0';    
            jump     <= '0';
            memwrite <= '0';
            memtoreg <= '0';
            regwrite <= '1';
            aluop    <= "000";


        -- slti
        when "001010" =>
            regdst   <= '0';
            extop    <= '1';
            alusrc   <= '1';
            branch   <= '0';
            jump     <= '0';
            memwrite <= '0';
            memtoreg <= '0';
            regwrite <= '1';
            aluop    <= "011"; 
            
        --addi
        when "001000" =>
            regdst   <= '0';
            extop    <= '1';
            alusrc   <= '1';
            branch   <= '0';
            jump     <= '0';
            memwrite <= '0';
            memtoreg <= '0';
            regwrite <= '1';
            aluop    <= "001"; 

        -- lw 
        when "100011" =>
            regdst   <= '0';
            extop    <= '1';
            alusrc   <= '1';
            branch   <= '0';
            jump     <= '0';
            memwrite <= '0';
            memtoreg <= '1';
            regwrite <= '1';
            aluop    <= "001"; 

        -- sw 
        when "101011" =>
            regdst   <= '0';
            extop    <= '1';
            alusrc   <= '1';
            branch   <= '0';
            jump     <= '0';
            memwrite <= '1';
            memtoreg <= '0'; 
            regwrite <= '0';
            aluop    <= "001";  

        -- beq 
        when "000100" =>
            regdst <= '0';
            extop <= '1';
            alusrc   <= '0';
            branch   <= '1';
            jump     <= '0';
            memwrite <= '0';
            memtoreg <= '0';
            regwrite <= '0';
            aluop    <= "010";  
            
         -- andi
        when "001100" =>
            regdst <= '0';
            extop <= '0';
            alusrc   <= '1';
            branch   <= '0';
            jump     <= '0';
            memwrite <= '0';
            memtoreg <= '0';
            regwrite <= '1';
            aluop    <= "100"; 
        
         -- ori
        when "001101" =>
            regdst <= '0';
            extop <= '0';
            alusrc   <= '1';
            branch   <= '0';
            jump     <= '0';
            memwrite <= '0';
            memtoreg <= '0';
            regwrite <= '1';
            aluop    <= "101"; 

        -- j 
        when "000010" =>
            regdst <= '0';
            extop <= '0';
            alusrc <= '0';
            jump     <= '1';
            branch   <= '0';
            regwrite <= '0';
            memtoreg <= '0';
            memwrite <= '0';

        -- bne
        when "000101" =>
            regdst   <= '0';
            extop    <= '1';
            alusrc   <= '0';
            branch   <= '1'; 
            jump     <= '0';
            memwrite <= '0';
            memtoreg <= '0';
            regwrite <= '0';
            aluop    <= "010"; 


        when others =>
            regdst <= '0';
            extop <= '0'; 
            alusrc <= '0';
            branch <= '0';
            jump <= '0'; 
            memwrite <= '0';
            memtoreg <= '0'; 
            regwrite <= '0'; 
            aluop <= "000";

    end case;
end process;

end Behavioral;
