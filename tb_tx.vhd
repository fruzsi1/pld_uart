library ieee;
use ieee.std_logic_1164.all;

entity tb_uart_transmitter is
end tb_uart_transmitter;

architecture tb of tb_uart_transmitter is

    component uart_transmitter
        port (clk       : in std_logic;
              nReset    : in std_logic;
              datain    : in std_logic_vector (7 downto 0);
              send_data : in std_logic;
              tx        : out std_logic;
              busy      : out std_logic);
    end component;

    signal clk       : std_logic;
    signal nReset    : std_logic;
    signal datain    : std_logic_vector (7 downto 0);
    signal send_data : std_logic;
    signal tx        : std_logic;
    signal busy      : std_logic;

    constant TbPeriod : time := 1000 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : uart_transmitter
    port map (clk       => clk,
              nReset    => nReset,
              datain    => datain,
              send_data => send_data,
              tx        => tx,
              busy      => busy);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- data initialization
        datain <= (others => '0');
        send_data <= '0';

        -- Reset generation
        nReset <= '0';
        wait for 100 ns;
        nReset <= '1';
        wait for 100 ns;

        -- EDIT Add stimuli here
        datain <= x"49";
        send_data <= '1';
        wait for 10000 ns;
        
        datain <= x"6b";
        send_data <= '1';
        wait for 10000 ns;

        -- Stop the clock and terminate simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
