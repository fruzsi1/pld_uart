library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_transmitter is
   
    port(
        clk         : in    std_logic;
        nReset      : in    std_logic;
        datain      : in    std_logic_vector(7 downto 0);
        send_data   : in    std_logic;
        tx          : out   std_logic;
        busy        : out   std_logic
    );
end entity;

architecture uart_transmitter_arch of uart_transmitter is
    constant clk_frq     	: integer := 2304000;
    constant baud_rt     	: integer := 115200;

    constant baud_div       	: integer := clk_frq / baud_rt;
    
    type state_stype is (START, DATA, STOP_BIT, IDLE);
    signal state            : state_stype := IDLE;

    signal baud_cnt         : integer range 0 to baud_div - 1 := 0;
    signal bit_cnt          : integer range 0 to 7 := 0;

    signal shift_reg        : std_logic_vector(7 downto 0) := (others => '0');
    signal transmitter_line : std_logic := '1';

begin   
    process(clk, nReset)
    begin
        if nReset = '0' then
            state           <= IDLE;
            baud_cnt        <= 0;
            bit_cnt         <= 0;
            shift_reg       <= (others => '0');
            transmitter_line <= '1';
            busy            <= '0';
        elsif (clk'event and clk = '1') then
            case state is
                when IDLE =>
                    transmitter_line <= '1';
                    busy <= '0';
                    if send_data = '1' then
                        shift_reg     <= datain;
                        state         <= START;
                        baud_cnt      <= 0;
                        busy          <= '1';
                    end if;

                when START =>
                    transmitter_line <= '0';
                    if baud_cnt < baud_div - 1 then
                        baud_cnt <= baud_cnt + 1;
                    else
                        baud_cnt <= 0;
                        state <= DATA;
                    end if;

                when DATA =>
                    transmitter_line <= shift_reg(bit_cnt);
                    if baud_cnt < baud_div - 1 then
                        baud_cnt <= baud_cnt + 1;
                    else
                        baud_cnt <= 0;

                        if bit_cnt < 7 then
                            bit_cnt <= bit_cnt + 1;
                        else
                            bit_cnt <= 0;
                            state <= STOP_BIT;
                        end if;
                    end if;

                when STOP_BIT =>
                    transmitter_line <= '1';
                    if baud_cnt < baud_div - 1 then
                        baud_cnt <= baud_cnt + 1;
                    else
                        baud_cnt <= 0;
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;

    tx <= transmitter_line;

end uart_transmitter_arch;
