library IEEE;
use IEEE.std_logic_1164.all;
library machxo2;
use machxo2.all;

entity Int_Osc is
  port (StdBy : in  std_logic;
        Clk   : out std_logic);
end entity;

architecture Int_Osc_arch of Int_Osc is

component OSCH
-- synthesis translate_off
  generic  (NOM_FREQ: string := "2.08");
-- synthesis translate_on
  port (STDBY    : in std_logic;
        OSC      : out std_logic;
        SEDSTDBY : out std_logic);
end component;

attribute NOM_FREQ : string;
attribute NOM_FREQ of OSCinst0 : label is "2.08"; -- original was "2.08"
-- 115200*20 = 2304000
   
begin

  OSCInst0: OSCH
-- synthesis translate_off
    generic map( NOM_FREQ  => "2.08" ) -- original was "2.08"
-- synthesis translate_on
    port map (STDBY => StdBy, 
	          OSC   => Clk);

end architecture;
