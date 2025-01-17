library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_receiver is
    port (
        clk         : in  std_logic;
        nReset      : in  std_logic;
        rx          : in  std_logic;
        dataout     : out std_logic_vector(7 downto 0);
        data_valid  : out std_logic
    );
end entity;

architecture uart_receiver_arch of uart_receiver is
    constant clk_frq    : integer := 520000;  
    constant baud_rt    : integer := 65000; 

    constant baud_div   : integer := clk_frq / baud_rt;
    constant sample_cnt : integer := baud_div / 2;  
    type state_type is (IDLE, START, DATA, STOP_BIT);
    signal state        : state_type := IDLE;

    signal baud_cnt     : integer range 0 to baud_div - 1 := 0;
    signal bit_cnt      : integer range 0 to 7 := 0;
    signal rx_shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal sample_point : integer := (baud_div/2)-1;

    signal rx_data      : std_logic_vector(7 downto 0) := (others => '0');
    signal valid        : std_logic := '0';

begin
    process(clk, nReset)
    begin
        if nReset = '0' then
            state        <= IDLE;
            baud_cnt     <= 0;
            bit_cnt      <= 0;
            rx_shift_reg <= (others => '0');
            rx_data      <= (others => '0');
            valid        <= '0';
        elsif rising_edge(clk) then
            valid <= '0'; 

            case state is
                when IDLE =>
                    if rx = '0' then  
                        state <= START;
                        baud_cnt <= 0;
                    end if;

                when START =>
                    if baud_cnt = sample_point then
                        if rx = '0' then  
                            baud_cnt <= 0;
                            state <= DATA;
                        else  -- False start, return to IDLE
                            state <= IDLE;
                        end if;
                    else
                        baud_cnt <= baud_cnt + 1;
                    end if;

                when DATA =>
                    if baud_cnt = baud_div - 1 then
                        rx_shift_reg(bit_cnt) <= rx;
                        baud_cnt <= 0;

                        if bit_cnt < 7 then
                            bit_cnt <= bit_cnt + 1;
                        else
                            bit_cnt <= 0;
                            state <= STOP_BIT;
                        end if;
                    else
                        baud_cnt <= baud_cnt + 1;
                    end if;

                when STOP_BIT =>
                    if baud_cnt = baud_div - 1 then
                        if rx = '1' then  
                            rx_data <= rx_shift_reg;
                            valid <= '1';  
                        end if;
                        state <= IDLE;
                        baud_cnt <= 0;
                    else
                        baud_cnt <= baud_cnt + 1;
                    end if;
            end case;
        end if;
    end process;

    dataout <= rx_data;
    data_valid <= valid;
end uart_receiver_arch;
