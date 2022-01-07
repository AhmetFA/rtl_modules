----------------------------------------------------------------------------------
--File Name 		uart_top.vhd
--Entity Name 		uart_top
--Architecture Name struct
--Generics
--osc_freq 			Frequency integer constant (100_000_000)
--width 			UART width integer constant (8)
--no_of_sample 		Number of samples taken during one baud time integer constant (16)
--Input Ports
--clk 				100 MHz Clock
--sw(2:0) 			3 bits switch bus connected to the switches on the board for baudrate selection
--rx_din 			UART RX input pin
--tx_data(7:0) 		UART TX 8 bits sent data
--tx_send 			UART transmitter send pulse
--Output Ports
--tx_dout 			UART TX output
--tx_active 		UART is sending data when this signal is asserted as 1
--rx_data_ready 	Informs cmd_handler that rx_data is ready
--rx_data(7:0) 		UART RX output. To be connected to cmd_handler
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.uart_pack.all;


entity uart_top is
  generic(
  osc_freq      : integer := 100_000_000; 
  Data_width 	: integer := 8;
  no_of_sample  : integer := 16
  );
  Port ( 
  Clock             : in  Std_logic;
  reset	     		: in  Std_logic;
  sw				: in  Std_logic_vector(2 downto 0); 
  rx_din			: in  std_logic;
  tx_data			: in  std_logic_vector(Data_width - 1 downto 0);
  tx_send			: in  std_logic;
  tx_dout			: out std_logic;
  tx_active			: out std_logic;
  rx_active			: out std_logic;
  rx_data_ready		: out std_logic;
  rx_data			: out std_logic_vector(Data_width - 1 downto 0)
  );
end uart_top;

architecture Behavioral of uart_top is
signal rx_active1   :std_logic;
signal tx_active1  :std_logic;
signal baud_en_rx  :std_logic;
signal baud_en_tx  :std_logic;

begin

id0 : Baud_gen  generic map(
  osc_freq       =>osc_freq,
  num_of_samples =>no_of_sample
  )
  port map(
  Clock         =>Clock,
  reset  		=>reset,
  rx_active	    =>rx_active1,
  tx_active     =>tx_active1,
  sw            =>sw,
  baud_en_rx  	=>baud_en_rx,
  baud_en_tx    =>baud_en_tx
  );
  
id1 : u_rx generic map(
Data_width 		  =>Data_width,
no_of_sample      =>no_of_sample)
 Port map(
 Clock   		=>Clock,
 reset  		=>reset, 
 data_in    	=>rx_din,
 baud_en_rx		=>baud_en_rx,
 rx_active		=>rx_active1,
 data_out		=>rx_data,
 data_ready		=>rx_data_ready
  );
 
 id2 : u_tx generic map(
Data_width 		=> Data_width,
no_of_sample    => no_of_sample)
 Port map(
 Clock   		=>Clock,
 reset  		=>reset,
 send    		=>tx_send,
 data_in   		=>tx_data,
 baud_en_tx		=>baud_en_tx,
 data_out		=>tx_dout,
 tx_active		=>tx_active1
  );
  
  tx_active <= tx_active1;
  rx_active <= rx_active1;
end Behavioral;
