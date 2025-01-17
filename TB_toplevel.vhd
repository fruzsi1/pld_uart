library IEEE;
	use IEEE.std_logic_1164.all;
	
entity TB_toplevel is
end entity;

architecture TB_toplevel_arch of TB_toplevel is

	component toplevel is
    port(
        nReset		: in std_logic; -- pushbutton
        Pin1		: out std_logic; -- uart tx
		Pin2		: in std_logic; -- uart rx
		Led0		: out std_logic -- indicator led
    );

	end component;

	signal nReset : std_logic;
	signal tx : std_logic;
	signal rx : std_logic;
	signal LED : std_logic;
	signal data : std_logic_vector(7 downto 0) := "10101010";
	signal TB_sim_ended : std_logic := '0';
	

begin

	dut: toplevel
		port map(
			nReset 	=> nReset,
			Pin1 	=> tx,
			Pin2 	=> rx,
			Led0 	=> LED
		);
	
	
	stimuli : process
    begin
        
        rx <= '1'; 

       
        nReset <= '0';
        wait for 100 ns;
        nReset <= '1';
        wait for 100 ns;

      
        rx <= '0'; -- start bit
        wait for 1538 ns;

        for k in 0 to data'length - 1 loop
            rx <= data(k); 
            wait for 1538 ns;
        end loop;

        rx <= '1'; -- back to idle
        wait for 16000 ns;

        
        TB_sim_ended <= '1';
        wait;
    end process;

end architecture;
