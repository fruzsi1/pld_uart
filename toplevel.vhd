library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	use ieee.math_real.all;

entity toplevel is
    port(
        nReset		: in std_logic; -- pushbutton
        Pin1		: out std_logic; -- uart tx
	Pin2		: in std_logic; -- uart rx
	Led0		: out std_logic -- indicator led
    );

end entity;

architecture toplevel_arch of toplevel is

	component Int_Osc is
		port(	stdBy		: in std_logic;
			Clk			: out std_logic
		);
	end component;
		
	component GENERIC_FIFO is
		port (
			clock       : in std_logic;
			reset       : in std_logic;
			write_data  : in std_logic_vector(7 downto 0);
			read_data   : out std_logic_vector(7 downto 0);
			write_en    : in std_logic;
			read_en     : in std_logic;
			full        : out std_logic;
			empty       : out std_logic
		);
	end component;
	
	component uart_receiver is
		port (
			clk         : in  std_logic;
			nReset      : in  std_logic;
			rx          : in  std_logic;
			dataout     : out std_logic_vector(7 downto 0);
			data_valid  : out std_logic
		);
	end component;
	
	component uart_transmitter is
		port(
			clk         : in    std_logic;
			nReset      : in    std_logic;
			datain      : in    std_logic_vector(7 downto 0);
			send_data   : in    std_logic;
			tx          : out   std_logic;
			busy        : out   std_logic
		);
	
	end component;
	
	signal clk_signal        : std_logic;
	signal reset_signal      : std_logic;
	signal dataout_signal    : std_logic_vector(7 downto 0); 	-- Data output from receiver
	signal data_valid_signal : std_logic;           			-- Data valid signal from receiver
	signal write_en_signal   : std_logic;           			-- FIFO write enable
	signal read_en_signal    : std_logic;           			-- FIFO read enable
	signal read_data_signal  : std_logic_vector(7 downto 0); 	-- Data read from FIFO
	signal send_data_signal  : std_logic;           			-- Trigger for sending data
	signal busy_signal       : std_logic;           			-- UART transmitter busy signal
	signal Pin1_io_tx        : std_logic;           			-- UART Tx (output)
	signal Pin2_io_rx        : std_logic;           			-- UART Rx (input)
	
begin
	
	osc1: Int_Osc
		port map (
			stdBy => '0',       -- Set stdBy to '0' to activate oscillator
			Clk => clk_signal
		);
	
	uart_rx: uart_receiver
		port map (
			clk         => clk_signal,          
			nReset      => reset_signal,        
			rx          => Pin2_io_rx,           
			dataout     => dataout_signal,      
			data_valid  => data_valid_signal    
		);
		
	fifo1: GENERIC_FIFO
		port map (
			clock       => clk_signal,            
			reset       => reset_signal,          
			write_data  => dataout_signal,        
			read_data   => read_data_signal,      
			write_en    => write_en_signal,       
			read_en     => read_en_signal,        
			full        => open,                  
			empty       => open                   
		);
		
	uart_tx: uart_transmitter
		port map (
			clk         => clk_signal,           
			nReset      => reset_signal,         
			datain      => read_data_signal,     
			send_data   => send_data_signal,     
			tx          => Pin1_io_tx,            
			busy        => busy_signal           
		);
	
	process(clk_signal, reset_signal)
begin
    if reset_signal = '0' then
        -- Initialize or reset signals when reset is active
        write_en_signal <= '0';
        read_en_signal <= '0';
        send_data_signal <= '0';
    elsif rising_edge(clk_signal) then
        -- FIFO write enable when data is valid from receiver
        if data_valid_signal = '1' then
            write_en_signal <= '1';
        else
            write_en_signal <= '0';
        end if;

        -- Read from FIFO and trigger UART transmission
        if read_en_signal = '0' then
            read_en_signal <= '1';  -- Read data from FIFO
        elsif busy_signal = '0' then
            -- Once UART is not busy, send the data from FIFO
            send_data_signal <= '1';
        else
            send_data_signal <= '0';
        end if;
    end if;
end process;
	
	-- Physical IO map
	reset_signal <= nReset;
	Pin1 <= Pin1_io_tx;       
	Pin2_io_rx <= Pin2;
	Led0 <= busy_signal; -- LED is used to indicate UART transmitter busy status
	
end architecture;
