---------------------------------------------
--  Prova finale (Progetto di Reti Logiche)
--  Prof. WIlliam Fornaciari A.A. 2019/20
--  Piersilvio De Bartolomeis (887260), Ian Di Dio Lavore (891500)
--  March 2020
---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project_reti_logiche is
port (
      i_clk         : in  std_logic;
      i_start       : in  std_logic;
      i_rst         : in  std_logic;
      i_data        : in  std_logic_vector(7 downto 0);
      o_address     : out std_logic_vector(15 downto 0);
      o_done        : out std_logic;
      o_en          : out std_logic;
      o_we          : out std_logic;
      o_data        : out std_logic_vector (7 downto 0)
      );
end project_reti_logiche;

architecture behavioral of project_reti_logiche is
    type state_type is (START_PROCESS, READ_ADDRESS, START_CYCLE,END_CYCLE);
    begin
        lambda_delta_reg : process(i_clk, i_rst) is 
            variable state : state_type := START_PROCESS;  -- Defines the actual state of the FSM
            variable index_mask : integer range 0 to 8;    -- Counter to iterate through the Working-Zones
            variable address : integer range 0 to 127;     -- Contains the address to be encoded
            begin
                if i_rst = '1' then
                    state := START_PROCESS;
                    o_done <= '0';
                    o_en <= '0';
                    o_we <= '0';
                elsif falling_edge(i_clk) then
                    case state is
                        when START_PROCESS =>
                            if i_start = '0' then
                                o_en <= '0';
                                o_we <= '0';
                                o_done <= '0';
                                o_address <= std_logic_vector(to_unsigned(8, o_address'length));
                                o_data <= std_logic_vector(to_unsigned(0, o_data'length));
                                state := START_PROCESS;
                            elsif i_start = '1' then
                                index_mask := 0;
                                o_en <= '1';
                                o_we <= '0';
                                o_address <= std_logic_vector(to_unsigned(8, o_address'length));
                                state := READ_ADDRESS;
                            end if;
                        when READ_ADDRESS =>
                            address := to_integer(unsigned(i_data));
                            o_en <= '1';
                            o_we <= '0';
                            o_address <= std_logic_vector(to_unsigned(0, o_address'length)); 
                            state := START_CYCLE;                    
                        when START_CYCLE =>
                            o_en <= '1';
                            if index_mask > 7 then
                                -- we have checked all the Working-Zones without a match
                                o_data <= "0" & std_logic_vector(to_unsigned(address,7)); 
                                o_we <= '1';
                                o_address <= std_logic_vector(to_unsigned(9, o_address'length));
                                state := END_CYCLE;
                            elsif (address - to_integer(unsigned(i_data)) >= 0 and address- to_integer(unsigned(i_data)) <= 3) then
                                -- we have found a matching Working-Zone
                                case address - to_integer(unsigned(i_data)) is
                                    when 0  => o_data <= "1"  & std_logic_vector(to_unsigned(index_mask,3)) & "0001" ;
                                    when 1  => o_data <= "1" & std_logic_vector(to_unsigned(index_mask,3)) & "0010";
                                    when 2  => o_data <= "1" & std_logic_vector(to_unsigned(index_mask,3)) & "0100";
                                    when others  => o_data <= "1" & std_logic_vector(to_unsigned(index_mask,3)) & "1000";
                                end case;
                                 o_we <= '1';
                                 o_address <= std_logic_vector(to_unsigned(9, o_address'length));
                                state := END_CYCLE;
                            else
                              -- not a match -> check the next Working-Zone
                              index_mask := index_mask + 1;
                              o_address <= std_logic_vector(to_unsigned(index_mask, o_address'length));
                              state := START_CYCLE;
                            end if;
        
                        when END_CYCLE =>
                            o_en <= '0';
                            o_we <= '0';
                            if i_start = '1' then
                                o_done <= '1';
                                state := END_CYCLE;
                            elsif i_start = '0' then
                                o_done <= '0';
                                state := START_PROCESS;
                            end if;
                    end case;
                end if;
            end process;
    end behavioral;
    
