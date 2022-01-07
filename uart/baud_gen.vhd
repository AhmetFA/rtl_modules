library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.numeric_std.all;
entity Baud_gen is
  generic(
  osc_freq       : integer := 100_000_000;
  num_of_samples : integer := 16
  );
  port (
  Clock         :    in  Std_logic;
  reset			:    in  Std_logic;
  rx_active	    :	 in  Std_logic;
  tx_active     :    in  Std_logic;
  sw            :    in  Std_logic_vector(2 downto 0);
  baud_en_rx  	:    out Std_logic;
  baud_en_tx    :    out std_logic
  );
end;

architecture RTL of Baud_gen is

signal counter      : integer range 0 to 1023 ;
signal baud_number  : integer range 0 to 1023 ;
signal flag			: std_logic;
begin

process(clock,rx_active,tx_active)
begin

baud_switch : case sw is
 when "000"  => baud_number <= 651; -- 9600 baudrate
 when "001"  => baud_number <= 325; -- 19200 baudrate
 when "010"  => baud_number <= 163; -- 38400 baudrate
 when "011"  => baud_number <= 109; -- 57600 baudrate
 when "100"  => baud_number <= 54;  -- 115200 baudrate
 when others => baud_number <= 651;
end case; 

if rising_edge(clock) then
	if reset = '1' then
	counter    <=  0 ;
	baud_en_rx <= '0';
	baud_en_tx <= '0';
	else
		if counter < baud_number then
		counter <= counter + 1;
		flag <= '0';
		else
		counter <= 0;
		flag <= '1';
		end if;
	
		if rx_active = '1' then 
		baud_en_rx <= flag;
		else
		baud_en_rx <= '0';
		end if;
	
		if tx_active = '1' then
		baud_en_tx <= flag;
		else
		baud_en_tx <= '0';
		end if;
		
	end if;
end if;
end process;


end;
