--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2017-18
--
-- Alejandro Cabana Suárez y Lucía Colmenarejo Pérez
-- Pareja 38
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion
      IDataIn    : in  std_logic_vector(31 downto 0); -- Dato leido
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
      Reset : in std_logic; -- Reset asíncrono a nivel alto
      A1    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd1
      Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
      A2    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd2
      Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
      A3    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
      Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
      We3   : in std_logic -- Habilitación de la escritura de Wd3
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

component control_unit
   port (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode  : in  std_logic_vector (5 downto 0);
      -- Seniales para el PC
      Branch : out  std_logic; -- 1=Ejecutandose instruccion branch
      Jump : out std_logic; -- 1 =Ejecuntandose instruccion jump 
      -- Seniales relativas a la memoria
      MemToReg : out  std_logic; -- 1=Escribir en registro la salida de la mem.
      MemWrite : out  std_logic; -- Escribir la memoria
      MemRead  : out  std_logic; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : out  std_logic;                     -- 0=oper.B es registro, 1=es valor inm.
      ALUOp  : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU		
      -- Seniales para el GPR
      RegWrite : out  std_logic; -- 1=Escribir registro
      RegDst   : out  std_logic  -- 0=Reg. destino es rt, 1=rd
   );
end component;

component alu_control
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
   );
end component;

signal enable_IFID, enable_IDEX, enable_EXMEM, enable_MEMWB: std_logic; 

signal ALUControl: std_logic_vector(3 downto 0);

--Señales de control
signal Bubble: std_logic;
signal RegDest_ID, RegDest_EX: std_logic;
signal ALUSrc_ID, ALUSrc_EX: std_logic;
signal ALUOp_ID, ALUOp_EX: std_logic_vector (2 downto 0);
signal Branch_ID, Branch_EX, Branch_MEM: std_logic;
signal MemRead_ID, MemRead_EX, MemRead_MEM: std_logic;
signal MemWrite_ID, MemWrite_EX, MemWrite_MEM: std_logic;
signal MemToReg_ID, MemToReg_EX, MemToReg_MEM, MemToReg_WB: std_logic;
signal RegWrite_ID, RegWrite_EX, RegWrite_MEM, RegWrite_WB: std_logic;
signal Jump_ID, Jump_EX, Jump_MEM: std_logic;

--Señales auxiliares

signal PC: std_logic_vector(31 downto 0);
signal PCplus4_IF, PCplus4_ID, PCplus4_EX: std_logic_vector(31 downto 0);

signal PCWrite: std_logic;
signal IFIDWrite: std_logic;

signal IDataIn_ID: std_logic_vector(31 downto 0);

signal RT_EX, RD_EX, RD_MEM, RD_WB: std_logic_vector(4 downto 0);
signal RS_EX: std_logic_vector(4 downto 0);

signal RD1_ID, RD1_EX: std_logic_vector(31 downto 0);
signal RD2_ID, RD2_EX, RD2_MEM: std_logic_vector(31 downto 0);

signal MUXRegDst_EX: std_logic_vector(4 downto 0);

signal Result_EX, Result_MEM, Result_WB: std_logic_vector(31 downto 0);

signal ZFlag_EX, ZFlag_MEM: std_logic;

signal DDataIn_WB: std_logic_vector(31 downto 0);

signal MUXALUSrc: std_logic_vector(31 downto 0);
signal MUXMemToReg: std_logic_vector(31 downto 0);

signal FwA, FwB: std_logic_vector(1 downto 0);
signal MUXFwA, MUXFwB: std_logic_vector(31 downto 0);

signal DatoExtSigno_ID, DatoExtSigno_EX: std_logic_vector(31 downto 0);
signal DatoExtSignoDespl_EX: std_logic_vector(31 downto 0);

signal BTA_EX, BTA_MEM: std_logic_vector(31 downto 0);
signal MUXBTA: std_logic_vector(31 downto 0);

signal PcSrc_MEM: std_logic;
signal MUXPCSrc: std_logic_vector(31 downto 0);

signal JumpAddr_ID, JumpAddr_EX, JumpAddr_MEM: std_logic_vector(31 downto 0);

begin

reg: reg_bank PORT MAP(
			Clk => Clk,
			Reset => Reset,
			We3 => RegWrite_WB,
			A1 => IDataIn_ID(25 downto 21),
			A2 => IDataIn_ID(20 downto 16),
			A3 => RD_WB,
			Rd1 => Rd1_ID,
			Rd2 => Rd2_ID, 	
			Wd3 => MUXMemToReg
);

al: alu PORT MAP(
			Control => ALUControl,
			OpA => MUXFwA,
			OpB => MUXALUSrc,
			Result => Result_EX,
			ZFlag => ZFlag_EX
);

ctrl_unit: control_unit PORT MAP(
		OpCode => IDataIn_ID(31 downto 26),
      Branch => Branch_ID,
		Jump => Jump_ID,
      MemToReg => MemToReg_ID,
      MemWrite => MemWrite_ID,
		MemRead => MemRead_ID,
      ALUSrc => ALUSrc_ID,
		ALUOp => ALUOp_ID,
      RegWrite => RegWrite_ID,
      RegDst => RegDest_ID
);

alu_ctrl: alu_control PORT MAP(
		ALUOp => ALUOp_EX,
      Funct => DatoExtSigno_EX(5 downto 0),
      ALUControl => ALUControl
);


--PC
process(Clk, Reset, PCWrite)
begin
	if Reset = '1' then
		PC <= (others => '0');
	elsif rising_edge(Clk) and PCWrite = '1' then
		PC <= MUXPCSrc;
	end if;
end process;

IAddr <= PC;


--BTA
PCplus4_IF <= PC+4;

--------------------------------------------------------------------------------------
------------------------------- Registro IF/ID ---------------------------------------
--------------------------------------------------------------------------------------
process(Clk, Reset, IFIDWRite)
begin
	if Reset = '1' then
		PCplus4_ID <= x"00000000";
		IDataIn_ID <= x"00000000";
	elsif rising_edge(Clk) and IFIDWRite = '1' then
		PCplus4_ID <= PCplus4_IF;
		IDataIn_ID <= IDataIn;
	end if;
end process;

-- Implementación de la extensión de signo
DatoExtSigno_ID(31 downto 16) <= (others => IDataIn_ID(15));
DatoExtSigno_ID(15 downto 0) <= IDataIn_ID(15 downto 0);

--------------------------------------------------------------------------------------
------------------------------- Registro ID/EX ---------------------------------------
--------------------------------------------------------------------------------------
process(Clk, Reset)
begin
	if Reset = '1' then
		RegWrite_EX <= '0';
		Branch_EX <= '0';
		Jump_EX <= '0';
		JumpAddr_EX <= x"00000000"; 
		MemRead_EX <= '0';
		MemWrite_EX <= '0';
		RegDest_EX <= '0';
		MemToReg_EX <= '0';
		ALUOp_EX <= "000";
		ALUSrc_EX <= '0';
		PCplus4_EX <= x"00000000";
		Rd1_EX <= x"00000000";
		Rd2_EX <= x"00000000";
		DatoExtSigno_EX <= x"00000000";
		RT_EX <= "00000";
		RD_EX <= "00000";
	elsif rising_edge(Clk) then
		if Bubble = '1' then
			RegWrite_EX <= '0';
			Branch_EX <= '0';
			Jump_EX <= '0';
			JumpAddr_EX <= x"00000000"; 
			MemRead_EX <= '0';
			MemWrite_EX <= '0';
			RegDest_EX <= '0';
			MemToReg_EX <= '0';
			ALUOp_EX <= "000";
			ALUSrc_EX <= '0';
			PCplus4_EX <= x"00000000";
			Rd1_EX <= x"00000000";
			Rd2_EX <= x"00000000";
			DatoExtSigno_EX <= x"00000000";
			RT_EX <= "00000";
			RD_EX <= "00000";
		else
			RegWrite_EX <= RegWrite_ID;
			Branch_EX <= Branch_ID;
			Jump_EX <= Jump_ID;
			JumpAddr_EX <= JumpAddr_ID;
			MemRead_EX <= MemRead_ID;
			MemWrite_EX <= MemWrite_ID;
			RegDest_EX <= RegDest_ID;
			MemToReg_EX <= MemToReg_ID; 
			ALUOp_EX <= ALUOp_ID;
			ALUSrc_EX <= ALUSrc_ID;
			PCplus4_EX <= PCplus4_ID;
			Rd1_EX <= Rd1_ID;
			Rd2_EX <= Rd2_ID;
			DatoExtSigno_EX <= DatoExtSigno_ID;
			RS_EX <= IDataIn_ID(25 downto 21);
			RT_EX <= IDataIn_ID(20 downto 16);
			RD_EX <= IDataIn_ID(15 downto 11);
		end if;
	end if;
end process;

--Desplazamiento <<2 de DatoExtSigno
DatoExtSignoDespl_EX <= DatoExtSigno_EX(29 downto 0) & "00";

--Sumador BTA
BTA_EX <= DatoExtSignoDespl_EX + PCplus4_EX;

--Multiplexor adelantamiento operando A
with FwA select
	MUXFwA <=	Rd1_EX when "00",
					MUXMemToReg when "01",
					Result_MEM when others;

--Multiplexor adelantamiento operando B
with FwB select
	MUXFwB <=	Rd2_EX when "00",
					MUXMemToReg when "01",
					Result_MEM when others;

--Multiplexor ALUSrc
MUXALUSrc <= MUXFwB when ALUSrc_EX = '0' else DatoExtSigno_EX;

--Multiplexor RegDest
MUXRegDst_EX <= RT_EX when RegDest_EX = '0' else RD_EX;

--------------------------------------------------------------------------------------
------------------------------- Registro EX/MEM --------------------------------------
--------------------------------------------------------------------------------------
process(Clk, Reset)
begin
	if Reset = '1' then
		RegWrite_MEM <= '0';
		MemToReg_MEM <= '0';
		Branch_MEM <= '0';
		Jump_MEM <= '0';
		JumpAddr_MEM <= x"00000000";
		MemRead_MEM <= '0';
		MemWrite_MEM <= '0';
		BTA_MEM <= x"00000000";
		ZFlag_MEM <= '0';
		Result_MEM <= x"00000000";
		Rd2_MEM <= x"00000000";
		RD_MEM <= "00000";
	elsif rising_edge(Clk) then
		RegWrite_MEM <= RegWrite_EX;
		MemToReg_MEM <= MemToReg_EX;
		Branch_MEM <= Branch_EX;
		Jump_MEM <= Jump_EX;
		JumpAddr_MEM <= JumpAddr_EX;
		MemRead_MEM <= MemRead_EX;
		MemWrite_MEM <= MemWrite_EX;
		BTA_MEM <= BTA_EX;
		ZFlag_MEM <= ZFlag_EX;
		Result_MEM <= Result_EX;
		Rd2_MEM <= MUXFwB;
		RD_MEM <= MUXRegDst_EX;
	end if;
end process;

--Jump Address
JumpAddr_ID <= PCplus4_ID(31 downto 28) & IDataIn_ID(25 downto 0) & "00";

--Multiplexor BTA
PCSrc_MEM <= ZFlag_MEM AND Branch_MEM;
MUXBTA <= PCplus4_IF when PCSrc_MEM = '0' else BTA_MEM;

--Multiplexor Jump
MUXPCSrc <= MUXBTA when Jump_MEM = '0' else JumpAddr_MEM;

--Memoria de datos
DAddr <= Result_MEM;
DRdEn <= MemRead_MEM;
DWrEn <= MemWrite_MEM;
DDataOut <= Rd2_MEM;

--------------------------------------------------------------------------------------
------------------------------- Registro MEM/WB --------------------------------------
--------------------------------------------------------------------------------------
process(Clk, Reset)
begin
	if Reset = '1' then
		RegWrite_WB <= '0';
		MemToReg_WB <= '0';
		DDataIn_WB <= x"00000000";
		Result_WB <= x"00000000";
		RD_WB <= "00000";
	elsif rising_edge(Clk) then
		RegWrite_WB <= RegWrite_MEM;
		MemToReg_WB <= MemToReg_MEM;
		DDataIn_WB <= DDataIn;
		Result_WB <= Result_MEM;
		RD_WB <= RD_MEM;
	end if;
end process;
	

--Multiplexor MemToReg
MUXMemToReg <= Result_WB when MemToReg_WB = '0' else DDataIn_WB;


--------------------------------------------------------------------------------------
------------------------------- Forwarding Unit --------------------------------------
--------------------------------------------------------------------------------------
--ForwardA
	FwA <=	"10" when ((RegWrite_MEM = '1' and (RD_MEM /= "00000")) and (RD_MEM = RS_EX)) else
				"01" when ((RegWrite_WB = '1' and (RD_WB /= "00000")) and (RD_MEM /= RS_EX) and (RD_WB = RS_EX)) else
				"00";
	
--ForwardB
	FwB <=	"10" when ((RegWrite_MEM = '1' and (RD_MEM /= "00000")) and (RD_MEM = RT_EX)) else
				"01" when ((RegWrite_WB = '1' and (RD_WB /= "00000")) and (RD_MEM /= RT_EX) and (RD_WB = RT_EX)) else
				"00";
--------------------------------------------------------------------------------------
---------------------------- Hazard Detection Unit -----------------------------------
--------------------------------------------------------------------------------------
PCWRite   <= 	'0' when MemRead_EX = '1' and (RT_EX = IDataIn_ID(25 downto 21) or RT_EX = IDataIn_ID(20 downto 16)) else
					'1';
IFIDWRite <= 	'0' when MemRead_EX = '1' and (RT_EX = IDataIn_ID(25 downto 21) or RT_EX = IDataIn_ID(20 downto 16)) else
					'1';
Bubble    <= 	'1' when MemRead_EX = '1' and (RT_EX = IDataIn_ID(25 downto 21) or RT_EX = IDataIn_ID(20 downto 16)) else
					'0';


end architecture;
