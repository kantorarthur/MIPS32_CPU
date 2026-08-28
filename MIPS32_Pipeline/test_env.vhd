----------------------------------------------------------------------------------
-- Company: Technical University of Cluj-Napoca 
-- Engineer: Cristian Vancea
-- 
-- Module Name: test_env - Behavioral
-- Description: 
--      
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(31 downto 0);
           PCp4 : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component ID
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;    
           Instr : in STD_LOGIC_VECTOR(25 downto 0);
           WD : in STD_LOGIC_VECTOR(31 downto 0);
           WA : in STD_LOGIC_VECTOR(4 downto 0); 
           RegWrite : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR(31 downto 0);
           RD2 : out STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);
           func : out STD_LOGIC_VECTOR(5 downto 0);
           sa : out STD_LOGIC_VECTOR(4 downto 0);
           rt : out STD_LOGIC_VECTOR(4 downto 0);
           rd : out STD_LOGIC_VECTOR(4 downto 0));
end component;

component EX
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
end component;

component UC
    Port ( Instr : in STD_LOGIC_VECTOR(5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           bne : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;


component MEM
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(31 downto 0));
end component;


signal Instruction, PCp4, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(31 downto 0); 
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(31 downto 0);
signal func : STD_LOGIC_VECTOR(5 downto 0);
signal sa : STD_LOGIC_VECTOR(4 downto 0);
signal zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(31 downto 0);
signal en, rst, PCSrc : STD_LOGIC; 

signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);
signal rt, rd : STD_LOGIC_VECTOR(4 downto 0);
signal rWA : STD_LOGIC_VECTOR(4 downto 0);
signal GTZ : STD_LOGIC; 


signal instr_if, pcp4_if : std_logic_vector(31 downto 0);
signal rd1_id, rd2_id, ext_imm_id : std_logic_vector(31 downto 0);
signal func_id : std_logic_vector(5 downto 0);
signal sa_id, rt_id, rd_id : std_logic_vector(4 downto 0);
signal alures_ex, br_addr_ex : std_logic_vector(31 downto 0);
signal zero_ex, gtz_ex : std_logic;
signal rwa_ex : std_logic_vector(4 downto 0);
signal mem_data_mem, alures_mem : std_logic_vector(31 downto 0);



signal if_id_instr, if_id_pcp4 : std_logic_vector(31 downto 0);


signal id_ex_rd1, id_ex_rd2, id_ex_ext_imm, id_ex_pcp4 : std_logic_vector(31 downto 0);
signal id_ex_func : std_logic_vector(5 downto 0);
signal id_ex_sa, id_ex_rt, id_ex_rd : std_logic_vector(4 downto 0);
signal id_ex_regdst, id_ex_alusrc, id_ex_branch, id_ex_jump : std_logic;
signal id_ex_memwrite, id_ex_memtoreg, id_ex_regwrite : std_logic;
signal id_ex_aluop : std_logic_vector(2 downto 0);


signal ex_mem_alures, ex_mem_rd2, ex_mem_br_addr : std_logic_vector(31 downto 0);
signal ex_mem_rwa : std_logic_vector(4 downto 0);
signal ex_mem_zero, ex_mem_branch, ex_mem_memwrite, ex_mem_memtoreg, ex_mem_regwrite : std_logic;

signal mem_wb_memdata, mem_wb_alures : std_logic_vector(31 downto 0);
signal mem_wb_rwa : std_logic_vector(4 downto 0);
signal mem_wb_memtoreg, mem_wb_regwrite : std_logic;

signal bne : std_logic;

signal id_ex_bne : STD_LOGIC;
signal ex_mem_bne : STD_LOGIC;

begin


    monopulse_en : MPG port map(en, btn(0), clk);
    monopulse_rst : MPG port map(rst, btn(1), clk);


    --ifetch

   inst_IFetch : IFetch port map(clk,rst,en,ex_mem_br_addr,JumpAddress,Jump,PCSrc,instr_if,pcp4_if);

    --if-id
    process(clk) begin
        if rising_edge(clk) and en = '1' then
            if_id_instr <= instr_if;
            if_id_pcp4 <= pcp4_if;
        end if;
    end process;


    inst_UC : UC port map(if_id_instr(31 downto 26), RegDst, ExtOp, ALUSrc, Branch,bne, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);
    inst_ID : ID
    port map(clk=> clk,en=> en,Instr=> if_id_instr(25 downto 0),WD=> WD,WA=> mem_wb_rwa,RegWrite => mem_wb_regwrite,ExtOp=> ExtOp,RD1=> rd1_id,RD2=> rd2_id,Ext_Imm=> ext_imm_id,func=> func_id,sa=> sa_id,rt=> rt_id,rd=> rd_id);
        
    --ID-EX
    process(clk) begin
        if rising_edge(clk) and en = '1' then
            id_ex_rd1 <= rd1_id; 
            id_ex_rd2 <= rd2_id; 
            id_ex_ext_imm <= ext_imm_id;
            id_ex_func <= func_id; 
            id_ex_sa <= sa_id; 
            id_ex_rt <= rt_id; 
            id_ex_rd <= rd_id;
            id_ex_pcp4 <= if_id_pcp4;
            id_ex_bne <= bne;

            id_ex_regdst <= RegDst; 
            id_ex_alusrc <= ALUSrc; 
            id_ex_aluop <= ALUOp;
            id_ex_branch <= Branch; 
            id_ex_jump <= Jump;
            id_ex_memwrite <= MemWrite; 
            id_ex_memtoreg <= MemtoReg; 
            id_ex_regwrite <= RegWrite;
        end if;
    end process;

    
    --ex
    inst_EX : EX port map(id_ex_pcp4, id_ex_rd1, id_ex_rd2, id_ex_ext_imm, id_ex_func, id_ex_sa, id_ex_rt, id_ex_rd, 
                         id_ex_alusrc, id_ex_aluop, id_ex_regdst, br_addr_ex, alures_ex, zero_ex, gtz_ex, rwa_ex);

    --ex-mem
    process(clk) begin
        if rising_edge(clk) and en = '1' then
            ex_mem_alures <= alures_ex; 
            ex_mem_rd2 <= id_ex_rd2;
            ex_mem_br_addr <= br_addr_ex; 
            ex_mem_rwa <= rwa_ex;
            ex_mem_zero <= zero_ex;
            ex_mem_bne <= id_ex_bne;

            ex_mem_branch <= id_ex_branch;
            ex_mem_memwrite <= id_ex_memwrite;
            ex_mem_memtoreg <= id_ex_memtoreg; 
            ex_mem_regwrite <= id_ex_regwrite;
        end if;
    end process;

    --mem
    inst_MEM : MEM port map(clk, en, ex_mem_alures, ex_mem_rd2, ex_mem_memwrite, mem_data_mem, alures_mem);

    --mem-wb
    process(clk) begin
        if rising_edge(clk) and en = '1' then
            mem_wb_memdata <= mem_data_mem;
            mem_wb_alures <= alures_mem;
            mem_wb_rwa <= ex_mem_rwa;

            mem_wb_memtoreg <= ex_mem_memtoreg;
            mem_wb_regwrite <= ex_mem_regwrite;
        end if;
    end process;

   
    --wb
    WD <= mem_wb_memdata when mem_wb_memtoreg = '1' else mem_wb_alures;

    --jump logic
    PCSrc <= (ex_mem_zero and ex_mem_branch) or
         ((not ex_mem_zero) and ex_mem_bne);
    JumpAddress <= if_id_pcp4(31 downto 28) & if_id_instr(25 downto 0) & "00";

    --ssd mux
    with sw(7 downto 5) select
        digits <= if_id_instr    when "000",
                  if_id_pcp4     when "001",
                  id_ex_rd1      when "010",
                  id_ex_rd2      when "011",
                  id_ex_ext_imm  when "100",
                  ex_mem_alures  when "101",
                  mem_data_mem   when "110",
                  WD             when "111",
                  (others => '0') when others;

    display : SSD port map(clk, digits, an, cat);
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

end Behavioral;