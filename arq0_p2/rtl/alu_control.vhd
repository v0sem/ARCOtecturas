--------------------------------------------------------------------------------
-- Bloque de control para la ALU. Arq0 2017.
--
-- Alejandro Cabana Suárez y Lucía Colmenarejo Pérez
-- Pareja 38
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
   );
end alu_control;

architecture rtl of alu_control is
   
begin

	--ALUControl
	process(ALUOp, Funct)
	begin
		case ALUOp is 
			--Instrucciones tipo R
			when "010" => 
				if Funct= "100100" then --And 
					ALUControl<= "0100"; --And de dos registros
				elsif Funct= "100000" then --Add
					ALUControl<= "0000"; --Suma dos registros
				elsif Funct= "100010" then --Sub
					ALUControl<= "0001"; --Resta dos registros
				elsif Funct= "100110" then --Xor
					ALUControl<= "0110"; --Xor de dos registros
				elsif Funct = "101010" then --Slt
					ALUControl<= "1010"; --Slt de dos registros
				elsif Funct = "100101" then --OR
					ALUControl<= "0111"; --OR de dos registros
				else
					ALUControl<= "1111"; --NOP
				end if;
		   --Instrucciones tipo I
			when "000"=> ALUControl <=  "0000"; --Lw, Sw y Addi: suma un registro y un dato inmmedianto
			when "001"=> ALUControl <=  "0001"; --Beq: resta dos registros para ver si son iguales
			when "011"=> ALUControl <=  "1101"; --Lui
			when others=> ALUControl <=  "1010"; --SLTi
			
		end case;
	end process;

end architecture;
