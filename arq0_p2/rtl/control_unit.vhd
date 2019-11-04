--------------------------------------------------------------------------------
-- Unidad de control principal del micro. Arq0 2017
--
-- Alejandro Cabana Suárez y Lucía Colmenarejo Pérez
-- Pareja 38
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
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
end control_unit;

architecture rtl of control_unit is

   -- Tipo para los codigos de operacion:
   subtype t_opCode is std_logic_vector (5 downto 0);

   -- Codigos de operacion para las diferentes instrucciones:
   constant OP_RTYPE  : t_opCode := "000000";
   constant OP_BEQ    : t_opCode := "000100";
	constant OP_SW     : t_opCode := "101011";
   constant OP_LW     : t_opCode := "100011";
   constant OP_LUI    : t_opCode := "001111";
	constant OP_SLTI   : t_opCode := "001010";
	constant OP_JUMP   : t_opCode := "000010";
	
begin

	--MemToReg
	MemToReg <= '1' when OPCode = OP_LW else '0'; --Lee de la memoria en vez de la ALU en lw
	
	--MemWrite
	MemWrite <= '1' when OPCode = OP_SW else '0'; --Solo se escribe en memoria con sw
	
	--MemRead
	MemRead <= '1' when OPCode = OP_LW else '0'; --Leer la memoria
	
	--Branch
	Branch <= '1' when OPCode = OP_BEQ else '0'; --Se activa con la instrucción beq independientemente de si realiza o no el salto al final
	
	--Jump
	Jump <= '1' when OPCode = OP_JUMP else '0'; --Se activa con la instruccion jump 
		
	--ALUSrc
	with OPCode select
		ALUSrc <= '0' when "000000", --En las instrucciones de tipo R a la ALU le entran dos registros
					 '0' when "000100", --En la instrucción beq a la ALU le entran dos registros
					 '1' when others; --En el resto de casos, a la ALU le entra un registro y un dato inmediato o es indiferente				 
	--RegDst				 
	RegDst <= '1' when OPCode ="000000" else '0'; --En las instrucciones de tipo R se escribe en el registro destino rd y en las de tipo I en el registro rt
	
	--RegWrite
	with OPCode select
		RegWrite <= '0' when OP_SW,
						'0' when OP_BEQ,
						'1' when others;
	
	--ALUOp
	with OPCode select
		ALUOp <= "010" when OP_RTYPE, --RType
					"100" when OP_SLTI, --SLTi
					"011" when OP_LUI, --LUI
					"001" when OP_BEQ, --BEQ
					"000" when others;
end architecture;
