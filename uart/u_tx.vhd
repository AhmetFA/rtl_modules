----------------------------------------------------------------------------------
-- File Name 			u_tx.vhd
-- Entity Name  		u_tx
-- Architecture Name 	behav
-- Generics
-- width 			  : UART width integer constant (8)
-- no_of_sample		  : Number of samples taken during one baud time integer constant (16)
-- Input Ports
-- clk 				  : 100 MHz Clock
-- send 			  : Send pulse signal. Asserts 1, UART starts to transmit
-- data_in(width-1:0) : TX (width) bits data input from cmd_handler
-- baud_en_tx 		  : The enable signal to take samples
-- Output Ports
-- data_out 		  : One bit serial UART TX data connected to top level output port (tx_dout)
-- tx_active 		  : UART is sending data when this signal is asserted as 1


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity u_tx is
generic(
Data_width 	  : integer := 8;
no_of_sample  : integer := 16
);
 Port (
 Clock   		: in  std_logic;
 reset			: in  Std_logic;
 send    		: in  std_logic;
 data_in   		: in  std_logic_vector(Data_width - 1 downto 0);
 baud_en_tx		: in  std_logic;
 data_out		: out std_logic;
 tx_active		: out std_logic
  );
end u_tx;

architecture Behavioral of u_tx is
type   States is (idle,send_start_bit,send_data,send_stop_bit);
signal Transmit_State : States;
signal Data_buff  	  : Std_logic_vector(Data_width downto 0);--when sample number becames 8(which is selection for data buff) state changes to make it compilible we must make this 9 bit 
signal counter    	  : integer	range 0 to no_of_sample  := 0;--holds the number of ticks detected during each baud
signal sample_num 	  : integer	range 0 to Data_width    := 0;--points the bit of data_in that is being send during that baud; 
begin

process(Clock,send,data_in,baud_en_tx)
begin
if rising_edge(Clock) then
	if reset = '1' then
	   Transmit_State <= idle;
	else
		case Transmit_State is 
		when idle			 =>
		data_out  <= '1';
		tx_active <= '0';
		counter	  <=  0;
		sample_num<=  0;
			if send ='1' then
				Transmit_State <= send_start_bit;
				Data_buff      <= '1' & data_in;
				tx_active<= '1';
			else
				Transmit_State <= idle;
				counter		   <= 0;--in next state we will use counter so we initialize it here
			end if;
	--------------------------------------------------------
		when send_start_bit  =>
		data_out <= '0';
		tx_active<= '1';
			if baud_en_tx = '1' then
				if counter < no_of_sample-1 then
					counter <= counter + 1;
				else 
					counter <= 0;
					Transmit_State <= send_data;
					sample_num<= 0;--in next state we will use sample_num so we initialize it here
				end if;
			else
				Transmit_State <= send_start_bit;
			end if;
	--------------------------------------------------------
		when send_data		 =>
		tx_active<= '1';	
		data_out<= Data_buff(sample_num);
			if  sample_num < Data_width then
				Transmit_State <= send_data;
				if baud_en_tx = '1' then
					if counter < no_of_sample-1 then
						counter <= counter + 1;
					else
						counter    <= 0;
						sample_num <= sample_num + 1;
					end if; 
				else
					counter    <= counter;
					sample_num <= sample_num;
				end if;
			else 
				sample_num <= 0;
				counter    <= 0;
				Transmit_State <= send_stop_bit;
			end if;
	--------------------------------------------------------
		when send_stop_bit   =>
		tx_active<= '1';	
		data_out <= '1';
			if baud_en_tx = '1' then
				if counter < no_of_sample-1 then
					counter <= counter + 1;
				else 
					counter <= 0;
					Transmit_State <= idle;
				end if;
			else
				Transmit_State <= send_stop_bit;
			end if;	
	--------------------------------------------------------
		when others 		 =>
		Transmit_State <= idle;
		data_out <= '1';
		end case;
	end if;
end if;
end process;
end Behavioral;

