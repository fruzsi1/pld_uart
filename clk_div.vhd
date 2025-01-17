library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;
	
entity clk_div is
	port(
		nReset : in std_logic;
		Osc_clk : in std_logic;
		RxTx_clk : out std_logic);
end entity;

architecture clk_div_arch of clk_div is

	signal kcount : unsigned(1 downto 0);
	signal kmax : unsigned(1 downto 0) := "11";
	signal Q : std_logic;

	-- Notes on how to calculate this
	-- Osc_clk = 2.08 MHz = 2080000 (hardware specific value)
	-- Desired baud rate = 65000 (not standard but i dont want to divide by a non-integer)  PERIOD IS 1538 ns (roughly)
	-- Desired clocks per baud = 8
	-- RxTx_clk must therefore be: 65000 * 8 = 520000										PERIOD IS 192 ns  (roughly)
	-- what we divide by is 2080000 / 520000 = 4
	-- represented on 2 bits, kmax is "11" in binary
	
begin

	process(nReset, Osc_clk)
	begin
		if (nReset = '0') then
			Q <= '0';
			kcount <= (others => '0');
		else
			if(Osc_clk'event and Osc_clk = '1') then
				if(kcount = kmax) then
					Q <= not Q;
					kcount <= (others => '0');
				else
					kcount <= kcount + 1;
				end if;
			end if;
		end if;
	
	end process;
	
	RxTx_clk <= Q;
	
end architecture;
		
