--------------------------------------------------------------------------------
-- Bloque de control para la ALU. Arq0 2019-2020.
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES, Quitar este mensaje)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo de control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por la ALU
   );
end alu_control;

architecture rtl of alu_control is

   subtype t_fun is std_logic_vector (5 downto 0);

   constant OP_ADD   : t_fun  := "100000";
   constant OP_AND   : t_fun  := "100100";
   constant OP_OR    : t_fun  := "100101";
   constant OP_SUB   : t_fun  := "100010";
   constant OP_XOR   : t_fun  := "100110";
   
begin
   process(Funct, ALUOp)
   begin
      if ALUOp = "010" then
         case Funct is
            when OP_ADD => ALUControl <= "0000";
            when OP_AND => ALUControl <= "0100";
            when OP_OR => ALUControl <= "0111";
            when OP_SUB => ALUControl <= "0001";
            when OP_XOR => ALUControl <= "0110";
            when others => ALUControl <= "1111";
         end case;

      elsif ALUOp = "000" then
         ALUControl <= "0000";
      
      elsif ALUOp = "001" then
         ALUControl <= "0001";
      
      elsif ALUOp = "011" then
         ALUControl <= "1110";

      elsif ALUOp = "100" then
         ALUControl <= "0010";
      else
         ALUControl <= "1111";
      end if;
   end process;
end architecture;
