--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2019-2020
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
	port(
		Clk         : in  std_logic; -- Reloj activo en flanco subida
		Reset       : in  std_logic; -- Reset asincrono activo nivel alto
		-- Instruction memory
		IAddr      : out std_logic_vector(31 downto 0); -- Direccion Instr
		IDataIn    : in  std_logic_vector(31 downto 0); -- Instruccion leida
		-- Data memory
		DAddr      : out std_logic_vector(31 downto 0); -- Direccion
		DRdEn      : out std_logic;                     -- Habilitacion lectura
		DWrEn      : out std_logic;                     -- Habilitacion escritura
		DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
		DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
	);
end processor;

architecture rtl of processor is 

component reg_bank
	port (
		Clk   : in std_logic; -- Reloj activo en flanco de subida
		Reset : in std_logic; -- Reset as�ncrono a nivel alto
		A1    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd1
		Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
		A2    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd2
		Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
		A3    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Wd3
		Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
		We3   : in std_logic -- Habilitaci�n de la escritura de Wd3
	);
end component;

component alu
	port (
		OpA     : in  std_logic_vector (31 downto 0); -- Operando A
		OpB     : in  std_logic_vector (31 downto 0); -- Operando B
		Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
		Result  : out std_logic_vector (31 downto 0); -- Resultado
		ZFlag   : out std_logic                       -- Flag Z
   );
end component;

component alu_control
	port (
		-- Entradas:
		ALUOp  : in std_logic_vector (2 downto 0); -- Codigo de control desde la unidad de control
		Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
		-- Salida de control para la ALU:
		ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por la ALU
   );
end component;

component control_unit
	port (
		-- Entrada = codigo de operacion en la instruccion:
		OpCode  : in  std_logic_vector (31 downto 0);
		-- Seniales para el PC
		Branch : out  std_logic; -- 1 = Ejecutandose instruccion branch
		Jump : out std_logic;
		-- Seniales relativas a la memoria
		MemToReg : out  std_logic; -- 1 = Escribir en registro la salida de la mem.
		MemWrite : out  std_logic; -- Escribir la memoria
		MemRead  : out  std_logic; -- Leer la memoria
		-- Seniales para la ALU
		ALUSrc : out  std_logic;                     -- 0 = oper.B es registro, 1 = es valor inm.
		ALUOp  : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
		-- Seniales para el GPR
		RegWrite : out  std_logic; -- 1=Escribir registro
		RegDst   : out  std_logic  -- 0=Reg. destino es rt, 1=rd
	);
end component;

signal Rdata1, Rdata2, Wdata3, Op2, ALURes, ExtSign, Shift2, BranchAdd, Add4, AuxAddr, Mux1 : std_logic_vector(31 downto 0); --TODO: Wdata3 mux, Op2 mux, ALURes mux,

signal A3 : std_logic_vector(4 downto 0);

signal ALUCon : std_logic_vector(3 downto 0);

signal ALUOp : std_logic_vector(2 downto 0);

signal RegDst, Z, Branch, ZBranch, MemToReg, ALUSrc, RegWrite, MemRead, MemWrite, JumpOrBranch, Jump : std_logic;

-- IF/ID signals
signal Add4_id, Ittr_id : std_logic_vector(31 downto 0);

-- ID/EX signals
signal Add4_ex, Rdata1_ex, Rdata2_ex, ExtSign_ex : std_logic_vector(31 downto 0);

signal Ittr20_ex, Ittr15_ex : std_logic_vector(4 downto 0);

signal ALUOp_ex : std_logic_vector(2 downto 0);

signal RegDst_ex, ALUSrc_ex, WBRegWrite_ex, WBMemToReg_ex, MBranch_ex, MMemRead_ex, MMemWrite_ex, Jump_ex : std_logic; 

-- EX/MEM
signal Rdata2_mem, ALURes_mem, BranchAdd_mem : std_logic_vector(31 downto 0);

signal A3_mem : std_logic_vector(4 downto 0);

signal Branch_mem, MemWrite_mem, MemRead_Mem, Z_mem, Jump_mem : std_logic;

-- EX/WB
signal DDataIn_wb, ALURes_wb : std_logic_vector(31 downto 0);

signal A3_wb : std_logic_vector(4 downto 0);

signal WBRegWrite_mem, WBMemToReg_mem, RegWrite_wb, MemToReg_wb : std_logic;

begin

c0: reg_bank port map (
	Clk => Clk,
	Reset => Reset,
	A1 => Ittr_id(25 downto 21),
	Rd1 => Rdata1,
	A2 => Ittr_id(20 downto 16),
	Rd2 => Rdata2,
	A3 => A3_wb,
	Wd3 => Wdata3,
	We3 => RegWrite_wb
);

c1: alu port map (
	OpA => Rdata1_ex,
	OpB => Op2,
	Control => ALUCon,
	Result => ALURes,
	ZFlag => Z
);

c2: alu_control port map (
	ALUOp => ALUOp_ex,
	Funct => ExtSign_ex(5 downto 0),
	ALUControl => ALUCon
);

c3: control_unit port map (
	OpCode => Ittr_id,
	Branch => Branch,
	Jump => Jump,
	MemToReg => MemToReg,
	MemWrite => MemWrite,
	MemRead => MemRead,
	ALUSrc => ALUSrc,
	ALUOp => ALUOp,
	RegWrite => RegWrite,
	RegDst => RegDst
);

--AND

ZBranch <= Z_mem and Branch_mem;

--Multiplexores

A3 <= Ittr15_ex when RegDst = '1' else Ittr20_ex;

ExtSign <= "1111111111111111" & Ittr_id(15 downto 0) when Ittr_id(15) = '1' else "0000000000000000" & Ittr_id(15 downto 0); 
Op2 <= Rdata2_ex when ALUSrc_ex = '0' else ExtSign_ex;

Wdata3 <= DDataIn_wb when MemToReg_wb = '1' else ALURes_wb;

Shift2 <= ExtSign_ex(29 downto 0) & "00";
BranchAdd <= Shift2 + Add4_ex;
Add4 <= AuxAddr + 4;
JumpOrBranch <= Jump_mem or ZBranch;
Mux1 <= BranchAdd_mem when JumpOrBranch = '1' else Add4;

--OUTS

DAddr <= ALURes_mem;
DDataOut <= RData2_mem;
DWrEn <= MemWrite_mem;
DRdEn <= MemRead_mem;

IAddr <= AuxAddr;

--Clock and Reset
process (Clk, Reset)
	begin
		if Reset = '1' then
			AuxAddr <= (others => '0');
		elsif rising_edge(Clk) then
			AuxAddr <= Mux1;
	end if;
end process;

process (Clk, Reset)
	begin
		if Reset = '1' then
			Add4_id <= (others => '0');
			Ittr_id <= (others => '0');
		elsif rising_edge(Clk) then
			Add4_id <= Add4;
			Ittr_id <= IDataIn;
		end if;
end process;

process (Clk, Reset)
	begin
		if Reset = '1' then
			WBRegWrite_ex <= '0';
			WBMemToReg_ex <= '0';
			MBranch_ex <= '0';
			MMemRead_ex <= '0';
			MMemWrite_ex <= '0';
			RegDst_ex <= '0';
			ALUSrc_ex <= '0';
			ALUOp_ex <= "111";
			Add4_ex <= x"00000000";
			Rdata1_ex <= x"00000000";
			Rdata2_ex <= x"00000000";
			ExtSign_ex <= x"00000000";
			Ittr20_ex <= "00000";
			Ittr15_ex <= "00000";
			Jump_ex <= '0';
		elsif rising_edge(Clk) then
			WBRegWrite_ex <= RegWrite;
			WBMemToReg_ex <= MemToReg;
			MBranch_ex <= Branch;
			MMemRead_ex <= MemRead;
			MMemWrite_ex <= MemWrite;
			RegDst_ex <= RegDst;
			ALUSrc_ex <= ALUSrc;
			ALUOp_ex <= ALUOp;
			Add4_ex <= Add4_id;
			Rdata1_ex <= Rdata1;
			Rdata2_ex <= Rdata2;
			ExtSign_ex <= ExtSign;
			Ittr20_ex <= Ittr_id(20 downto 16);
			Ittr15_ex <= Ittr_id(15 downto 11);
			Jump_ex <= Jump;
		end if;
end process;

process (Clk, Reset)
	begin
		if Reset = '1' then
			WBRegWrite_mem <= '0';
			WBMemToReg_mem <= '0';
			Branch_mem <= '0';
			MemWrite_mem <= '0';
			MemRead_mem <= '0';
			Z_mem <= '0';
			ALURes_mem <= x"00000000";
			Rdata2_mem <= x"00000000";
			A3_mem <= "00000";
			Jump_mem <= '0';
		elsif rising_edge(Clk) then
			WBRegWrite_mem <= WBRegWrite_ex;
			WBMemToReg_mem <= WBMemToReg_ex;
			Branch_mem <= MBranch_ex;
			MemWrite_mem <= MMemWrite_ex;
			MemRead_mem <= MMemRead_ex;
			Z_mem <= Z;
			ALURes_mem <= ALURes;
			Rdata2_mem <= Rdata2_ex;
			A3_mem <= A3;
			Jump_mem <= Jump_ex;
		end if;
end process;

process (Clk, Reset)
	begin
		if Reset = '1' then
			RegWrite_wb <= '0';
			MemToReg_wb <= '0';
			DDataIn_wb <= x"00000000";
			ALURes_wb <= x"00000000";
			A3_wb <= "00000";
		elsif rising_edge(Clk) then
			RegWrite_wb <= WBRegWrite_mem;
			MemToReg_wb <= WBMemToReg_mem;
			DDataIn_wb <= DDataIn;
			ALURes_wb <= ALURes_mem;
			A3_wb <= A3_mem;
		end if;
end process;

end architecture;
