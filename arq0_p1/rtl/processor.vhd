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
		OpCode  : in  std_logic_vector (5 downto 0);
		-- Seniales para el PC
		Branch : out  std_logic; -- 1 = Ejecutandose instruccion branch
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

signal RegDst, Z, Branch, ZBranch, MemToReg, ALUSrc, RegWrite : std_logic; --TODO: Z and Branch, MEmtoreg mux

begin

c0: reg_bank port map (
	Clk => Clk,
	Reset => Reset,
	A1 => IDataIn(25 downto 21),
	Rd1 => Rdata1,
	A2 => IDataIn(20 downto 16),
	Rd2 => Rdata2,
	A3 => A3,
	Wd3 => Wdata3,
	We3 => RegWrite
);

c1: alu port map (
	OpA => Rdata1,
	OpB => Op2,
	Control => ALUCon,
	Result => ALURes,
	ZFlag => Z
);

c2: alu_control port map (
	ALUOp => ALUOp,
	Funct => IDataIn(5 downto 0),
	ALUControl => ALUCon
);

c3: control_unit port map (
	OpCode => IDataIn(31 downto 26),
	Branch => Branch,
	MemToReg => MemToReg,
	MemWrite => DWrEn,
	MemRead => DRdEn,
	ALUSrc => ALUSrc,
	ALUOp => ALUOp,
	RegWrite => RegWrite,
	RegDst => RegDst
);

--AND

ZBranch <= Z and Branch;

--Multiplexores

A3 <= IDataIn(15 downto 11) when RegDst = '1' else IDataIn(20 downto 16);

ExtSign <= "1111111111111111" & IDataIn(15 downto 0) when IDataIn(15) = '1' else "0000000000000000" & IDataIn(15 downto 0); 
Op2 <= Rdata2 when ALUSrc = '0' else ExtSign;

Wdata3 <= DDataIn when MemToReg = '1' else ALURes;

Shift2 <= ExtSign(29 downto 0) & "00";
BranchAdd <= Shift2 + Add4;
Add4 <= AuxAddr + 4;
Mux1 <= BranchAdd when ZBranch = '1' else Add4;

--OUTS

DAddr <= ALURes;
DDataOut <= RData2;
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

	
end architecture;
