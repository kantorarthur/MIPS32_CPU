----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2026 08:13:17 PM
-- Design Name: 
-- Module Name: EX - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity EX is
    Port (
        rd1 : in  std_logic_vector(31 downto 0);
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
        branchaddr: out std_logic_vector(31 downto 0)
    );
end EX;

architecture Behavioral of EX is

    signal b_input  : std_logic_vector(31 downto 0);
    signal aluctrl  : std_logic_vector(2 downto 0);
    signal c        : std_logic_vector(31 downto 0);

begin
    
    process
    begin
        if alusrc = '0' then
            b_input <= rd2;
        else
            b_input <= ext_imm;
        end if;
    end process;

 --alu ctrl
    process(aluop, func)
    begin
        case aluop is
            when "000" => -- codR
                case func is
                    when "100000" => aluctrl <= "001"; -- add
                    when "100010" => aluctrl <= "010"; -- sub
                    when "100100" => aluctrl <= "100"; -- and
                    when "100101" => aluctrl <= "101"; -- or
                    when "101010" => aluctrl <= "011"; -- slt
                    when "000000" => aluctrl <= "110"; -- sll
                    when "000010" => aluctrl <= "111"; -- srl
                    when others   => aluctrl <= (others => 'X');
                end case;

            when "001" => aluctrl <= "001"; -- cod+ 
            when "010" => aluctrl <= "010"; -- cod- 
            when "011" => aluctrl <= "011"; -- cod<
            when "100" => aluctrl <= "100"; -- cod& 
            when "101" => aluctrl <= "101"; -- cod| 

            when others =>
                aluctrl <= (others => 'X');
        end case;
    end process;


--alu
    process(rd1, b_input, aluctrl, sa)
    begin
        case aluctrl is
            when "001" =>
                c <= std_logic_vector(signed(rd1) + signed(b_input));

            when "010" => 
                c <= std_logic_vector(signed(rd1) - signed(b_input));

            when "100" => 
                c <= rd1 and b_input;

            when "101" =>
                c <= rd1 or b_input;

            when "011" =>
                if signed(rd1) < signed(b_input) then
                    c <= X"00000001";
                else
                    c <= X"00000000";
                end if;

            when "110" => 
                c <= std_logic_vector(shift_left(unsigned(b_input), to_integer(unsigned(sa))));

            when "111" => 
                c <= std_logic_vector(shift_right(unsigned(b_input), to_integer(unsigned(sa))));

            when others =>
                c <= (others => 'X');
        end case;
    end process;


    alures <= c;

    process
    begin
        if c = X"00000000" then
            zero <= '1';
        else
            zero <= '0';
        end if;
    end process;
    
    process
    begin
        if signed(c) > 0 then
            gtz <= '1';
        else
            gtz <= '0';
        end if;
    end process;

    branchaddr <= std_logic_vector(signed(pc_plus4) + (signed(ext_imm) sll 2));

end Behavioral;