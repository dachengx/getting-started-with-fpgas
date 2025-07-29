module Count_And_Toggle #(COUNT_LIMIT = 10) (
  input i_Clk,
  input i_Enable,
  output reg o_Toggle
);
  reg [$clog2(COUNT_LIMIT-1):0] r_Counter;
  always @(posedge i_Clk)
  begin
    if (i_Enable == 1'b1)
    begin
      if (r_Counter == COUNT_LIMIT - 1)
      begin
        o_Toggle <= !o_Toggle;
        r_Counter <= 0;
      end
      else
        r_Counter <= r_Counter + 1;
    end
    else
      o_Toggle <= 1'b0;
  end
endmodule
