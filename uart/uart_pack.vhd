----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package uart_pack is
----------------------------------------------------------------------------------
component Baud_gen is
  generic(
  osc_freq       : integer := 100_000_000;
  num_of_samples : integer := 16
  );
  port (
  Clock         :    in  Std_logic;
  reset		    :    in  Std_logic;
  rx_active	    :	 in  Std_logic;
  tx_active     :    in  Std_logic;
  sw            :    in  Std_logic_vector(2 downto 0);
  baud_en_rx  	:    out Std_logic;
  baud_en_tx    :    out std_logic
  );
end component Baud_gen;
----------------------------------------------------------------------------------
component u_rx is
generic(
Data_width 		  : integer := 8;
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
end component u_rx;
----------------------------------------------------------------------------------
component u_tx is
generic(
Data_width 		  : integer := 8;
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
end component u_tx;

end package uart_pack;

