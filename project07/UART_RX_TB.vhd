library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity UART_RX_TB is
end UART_RX_TB;

architecture Behave of UART_RX_TB is
  -- Test bench uses a 25 MHz clock
  constant c_CLK_PERIOD : time := 40 ns;

  -- Want to interface to 115200 baud ART
  --- 25,000,000 / 115200 = 217 clocks per bit.
  constant c_CLKS_PER_BIT : integer := 217;

  -- 1/115200:
  constant c_BIT_PERIOD : time := 8600 ns;

  signal r_Clock : std_logic := '0';
  signal w_RX_Byte : std_logic_vector(7 downto 0);
  signal r_RX_Serial : std_logic := '1';

  -- Low-level byte-write
  procedure UART_WRITE_BYTE (
    i_Data_In : in std_logic_vector(7 downto 0);
    signal o_Serial : out std_logic 
  ) is
  begin
    -- Send start bit
    o_Serial <= '0';
    wait for c_BIT_PERIOD;

    -- Send data byte
    for ii in 0 to 7 loop
      o_Serial <= i_Data_In(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii

    -- Send stop bit
    o_Serial <= '1';
    wait for c_BIT_PERIOD;
  end UART_WRITE_BYTE;

begin
  -- Instantiate UART receiver
  UART_RX_INST : entity work.UART_RX
    generic map (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
    )
    port map (
      i_Clk       => r_Clock,
      i_RX_Serial => r_RX_Serial,
      o_RX_DV     => open,
      o_RX_Byte   => w_RX_Byte
    );

  r_Clock <= not r_Clock after c_CLK_PERIOD/2;

  process
  begin
    -- Send a command to the UART
    wait until rising_edge(r_Clock);
    UART_WRITE_BYTE(X"37", r_RX_Serial);
    wait until rising_edge(r_Clock);

    -- Check that the correct command was received
    if w_RX_Byte = X"37" then
      report "Test Passed - Correct Byte Received" severity note;
    else
      report "Test Failed - Incorrect Byte Received" severity note;
    end if;

    assert false report "Test Complete" severity failure;
  end process;
end Behave;
