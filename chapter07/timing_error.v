module timing_error (
  input i_Clk,
  input [7:0] i_Data,
  output reg [15:0] o_Data
);

reg [7:0] r0_Data, r1_Data, r2_Data = 0;

always @(posedge i_Clk)
begin
  r0_Data <= i_Data;
  // o_Data <= ((r0_Data / 3) + 1) * 5;
  r1_Data <= r0_Data / 3;
  r2_Data <= r1_Data + 1;
  o_Data  <= r2_Data * 5;
end
  
endmodule
