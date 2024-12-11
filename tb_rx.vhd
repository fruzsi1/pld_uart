library ieee;
use ieee.std_logic_1164.all;

entity tb_uart_receiver is
end tb_uart_receiver;

architecture tb of tb_uart_receiver is

    component uart_receiver
        port (clk        : in std_logic;
              nReset     : in std_logic;
              rx         : in std_logic;
              dataout    : out std_logic_vector (7 downto 0);
              data_valid : out std_logic);
    end component;

    signal clk        : std_logic;
    signal nReset     : std_logic;
    signal rx         : std_logic;
    signal data_in    : std_logic_vector(7 downto 0) := "10101010"; -- Example data
    signal dataout    : std_logic_vector (7 downto 0);
    signal data_valid : std_logic;
    constant TbPeriod : time := 2000 ns;
    signal TbClock    : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : uart_receiver
        port map (clk        => clk,
                  nReset     => nReset,
                  rx         => rx,
                  dataout    => dataout,
                  data_valid => data_valid);

   
    TbClock <= not TbClock after TbPeriod / 2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    stimuli : process
    begin
        
        rx <= '1'; 

       
        nReset <= '0';
        wait for 100 ns;
        nReset <= '1';
        wait for 100 ns;

      
        rx <= '0'; 
        wait for 8000 ns;

        for k in 0 to data_in'length - 1 loop
            rx <= data_in(k); 
            wait for 8000 ns;
        end loop;

        rx <= '1'; 
        wait for 16000 ns;

        
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
