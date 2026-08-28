----------------------------------------------------------------------------------
-- Company: Technical University of Cluj-Napoca 
-- Engineer: Cristian Vancea
-- 
-- Module Name: EX - Behavioral
-- Description: 
--      Execute Unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

entity EX is
    Port ( PCp4 : in STD_LOGIC_VECTOR(31 downto 0);
           RD1 : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
           func : in STD_LOGIC_VECTOR(5 downto 0);
           sa : in STD_LOGIC_VECTOR(4 downto 0);
           rt : in STD_LOGIC_VECTOR(4 downto 0); 
           rd : in STD_LOGIC_VECTOR(4 downto 0); 
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           RegDst : in STD_LOGIC; 
           BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
           ALURes : out STD_LOGIC_VECTOR(31 downto 0);
           Zero : out STD_LOGIC;
           GTZ : out STD_LOGIC; 
           rWA : out STD_LOGIC_VECTOR(4 downto 0)); 
end EX;

architecture Behavioral of EX is
    signal B_input : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);
    signal C       : STD_LOGIC_VECTOR(31 downto 0);
begin


    B_input <= Ext_Imm when ALUSrc = '1' else RD2;


    process(ALUOp, func)
    begin
        case ALUOp is
            when "000" => -- Tip R
                case func is
                    when "100000" => ALUCtrl <= "001"; -- add
                    when "100010" => ALUCtrl <= "010"; -- sub
                    when "100100" => ALUCtrl <= "100"; -- and
                    when "100101" => ALUCtrl <= "101"; -- or
                    when "101010" => ALUCtrl <= "011"; -- slt
                    when "000000" => ALUCtrl <= "110"; -- sll
                    when "000010" => ALUCtrl <= "111"; -- srl
                    when others   => ALUCtrl <= (others => 'X');
                end case;
            when "001" => ALUCtrl <= "001"; -- cod+ 
            when "010" => ALUCtrl <= "010"; -- cod- 
            when "011" => ALUCtrl <= "011"; -- cod<
            when "100" => ALUCtrl <= "100"; -- cod& 
            when "101" => ALUCtrl <= "101"; -- cod| 
            when others => ALUCtrl <= (others => 'X');
        end case;
    end process;

 
    process(RD1, B_input, ALUCtrl, sa)
    begin
        case ALUCtrl is
            when "001" => -- adunare
                C <= std_logic_vector(signed(RD1) + signed(B_input));
            when "010" => -- scadere
                C <= std_logic_vector(signed(RD1) - signed(B_input));
            when "100" => -- and
                C <= RD1 and B_input;
            when "101" => -- or
                C <= RD1 or B_input;
            when "011" => -- set on less than
                if signed(RD1) < signed(B_input) then
                    C <= X"00000001";
                else
                    C <= X"00000000";
                end if;
            when "110" => -- shift left logical (sll)
                C <= std_logic_vector(shift_left(unsigned(B_input), to_integer(unsigned(sa))));
            when "111" => -- shift right logical (srl)
                C <= std_logic_vector(shift_right(unsigned(B_input), to_integer(unsigned(sa))));
            when others =>
                C <= (others => 'X');
        end case;
    end process;

    --iesiri alu
    ALURes <= C;
    Zero   <= '1' when C = X"00000000" else '0';
    GTZ    <= '1' when (signed(RD1) > 0) else '0'; 


    rWA <= rd when RegDst = '1' else rt;


    BranchAddress <= std_logic_vector(signed(PCp4) + (signed(Ext_Imm) sll 2));

end Behavioral;