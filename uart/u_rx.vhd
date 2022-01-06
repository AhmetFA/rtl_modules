----------------------------------------------------------------------------------
--File Name :u_rx.vhd
--Entity Name 		   : u_rx
--Architecture Name    : behav
--Generics
--width 			   : UART width integer constant (8)
--no_of_sample 		   : Number of samples taken during one baud time integer constant (16)
--Input Ports
--clk 				   : 100 MHz Clock
-- data_in 			   : UART RX input
-- baud_en_rx 		   : The enable signal to take samples
-- Output Ports
-- rx_active 		   : When data is receiving, it is asserted. Connected to the baud generator
-- data_out(width-1:0) : Received data (width bits) connected to cmd_handler
-- data_ready 		   : Ready signal which shows data_out is ready. Connected to cmd_handler

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity u_rx is
generic(
Data_width 	  : integer := 8;
no_of_sample  : integer := 16
);
 Port (
 Clock   		: in  std_logic;
 reset			: in  Std_logic;
 data_in    	: in  std_logic;
 baud_en_rx		: in  std_logic;
 rx_active		: out std_logic;
 data_out		: out std_logic_vector(Data_width-1 downto 0);
 data_ready		: out std_logic
  );
end u_rx;

architecture Behavioral of u_rx is
type   States is (idle,wait_mid_of_start_bit,receive_data,receive_stop_bit,after_receive);
signal Receive_State    : States;
signal data_out_buff    : Std_logic_vector(Data_width downto 0);--buffer for data out because of indexing it is 9 bits
signal data_in_buff     : Std_logic;
signal data_in_buff0    : Std_logic;
signal counter 		    : Integer range 0 to no_of_sample-1 := 0;--counter for tickcount
signal sample_number    : Integer range 0 to Data_width := 0;--sample number used for indexing output data
begin
rx_active <= '1';--as it is receiving operation it must stay high


process(Clock,data_in,baud_en_rx)
begin
if rising_edge(Clock) then
	if reset = '1' then
	    Receive_State <= idle;
	else
  
		data_in_buff0 <= data_in;
		data_in_buff  <= data_in_buff0;--as it is asyncronus input it must be passed through 2 Dff

		case Receive_State is 
		when idle 					=>
		data_out      <= (others => '0');
		data_out_buff <= (others => '0');
		data_ready    <=  '0';
		sample_number <=   0;
			if data_in_buff = '0' then
				Receive_State <= wait_mid_of_start_bit;
				counter 	  <= 0;
			else
				Receive_State <= idle;
			end if;
	--------------------------------------------------------
		when wait_mid_of_start_bit =>
		data_out      <= (others => '0');
		data_out_buff <= (others => '0');
		data_ready    <=  '0';
		sample_number <=   0;
		if baud_en_rx = '1' then
			if counter < no_of_sample/2-1 then
				if data_in_buff = '0' then
				counter <= counter +1;
				else
				Receive_State <= idle;
				end if;
			elsif counter = no_of_sample/2-1 and data_in_buff = '0' then
				Receive_State <= receive_data;
				counter <= 0;
				sample_number <= 0;
			else
				Receive_State <= idle;
			end if;
		else
		    	counter <= counter;	
		end if;	
	--------------------------------------------------------
		when receive_data 			=>
		data_out       <= (others => '0');
		data_ready     <=  '0';
		if sample_number < Data_width then
			if baud_en_rx = '1' then
				if counter < no_of_sample-1 then
					counter <= counter +1;
                else
					data_out_buff(sample_number) <= data_in_buff;
					sample_number <= sample_number +1;
					counter       <= 0;
				end if;
			end if;
        else
			sample_number <= 0;
			counter 	  <= 0;
			Receive_State <= receive_stop_bit;	
		end if;	
	--------------------------------------------------------
		when receive_stop_bit 		=>
		if baud_en_rx = '1' then
			if counter < no_of_sample-1 then
				counter <= counter +1;
            else
				if data_in_buff = '1' then
					data_out<= data_out_buff(7 downto 0);
					data_ready <= '1';
					Receive_State <= idle;--after receive; --commented out parts are at v1
					counter <= 0;
				else
					Receive_State <= idle;
				end if;
			end if;
		else
		counter <= counter;	
		end if;  
	--------------------------------------------------------
		when others => Receive_State <= idle;
		end case;

  end if;
end if;
end process;
end Behavioral;
