library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Debounce_Filter is
  generic (DEBOUNCE_LIMIT : integer := 20);
  port (
    i_Clk       : in  std_logic;
    i_Bouncy    : in  std_logic;
    o_Debounced : out std_logic
    );
end entity Debounce_Filter;

architecture RTL of Debounce_Filter is

  signal r_Count : integer range 0 to DEBOUNCE_LIMIT := 0;
  signal r_State : std_logic := '0';

begin

  process (i_Clk) is
  begin
    if rising_edge(i_Clk) then

      if (i_Bouncy /= r_State and r_Count < DEBOUNCE_LIMIT-1) then
        r_Count <= r_Count + 1;

      elsif r_Count = DEBOUNCE_LIMIT-1 then
        r_State <= i_Bouncy;
        r_Count <= 0;

      else
        r_Count <= 0;

      end if;
    end if;
  end process;

  o_Debounced <= r_State;

end architecture RTL;
