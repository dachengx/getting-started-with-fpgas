library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

entity Turnstile_Example_TB is
end entity Turnstile_Example_TB;

architecture test of Turnstile_Example_TB is

  signal r_Reset : std_logic := '1';
  signal r_Clk, r_Coin, r_Push : std_logic := '0';
  signal w_Locked : std_logic;

begin

  UUT : entity work.Turnstile_Example
  port map (
    i_Reset => r_Reset,
    i_Clk => r_Clk,
    i_Coin => r_Coin,
    i_Push => r_Push,
    o_Locked => w_Locked
  );

  r_Clk <= not r_Clk after 1 ns;

  process is
  begin
    wait for 10 ns;
    r_Reset <= '0';
    wait for 10 ns;
    assert w_Locked = '1' severity failure;

    r_Coin <= '1';
    wait for 10 ns;
    assert w_Locked = '0' severity failure;

    r_Push <= '1';
    wait for 10 ns;
    assert w_Locked = '1' severity failure;

    r_Coin <= '0';
    wait for 10 ns;
    assert w_Locked = '1' severity failure;

    r_Push <= '0';
    wait for 10 ns;
    assert w_Locked = '1' severity failure;

    finish;
  end process;

end test;
