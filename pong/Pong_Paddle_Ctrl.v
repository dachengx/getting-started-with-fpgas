module Pong_Paddle_Ctrl
  #(
    parameter c_PLAYER_PADDLE_X = 0,
    parameter c_PADDLE_HEIGHT   = 6,
    parameter c_GAME_HEIGHT     = 30,
    parameter c_GAME_WIDTH      = 40,
    parameter c_PADDLE_SPEED    = 1250000  // Move per pong game unit every 50 ms
  )
  (
    input i_Clk,
    input [$clog2(c_GAME_WIDTH)-1:0]       i_Col_Count_Div,
    input [$clog2(c_GAME_HEIGHT)-1:0]      i_Row_Count_Div,
    input i_Paddle_Up,
    input i_Paddle_Dn,
    output reg                             o_Draw_Paddle,
    output reg [$clog2(c_GAME_HEIGHT)-1:0] o_Paddle_Y
  );

  reg [$clog2(c_PADDLE_SPEED)-1:0] r_Paddle_Count = 0;

  wire w_Paddle_Count_En;

  // Only allow paddles to move if only one button is pushed.
  // ^ is an XOR bitwise operation.
  assign w_Paddle_Count_En = i_Paddle_Up ^ i_Paddle_Dn;

  always @(posedge i_Clk)
  begin
    if (w_Paddle_Count_En == 1'b1)
    begin
      if (r_Paddle_Count == c_PADDLE_SPEED)
        r_Paddle_Count <= 0;
      else
        r_Paddle_Count <= r_Paddle_Count + 1;
    end

    // Update the paddle location slowly. Only allowed when the
    // paddle count reaches its limit. Don't update if paddle is
    // already at the top of the screen.
    if (i_Paddle_Up == 1'b1 && r_Paddle_Count == c_PADDLE_SPEED && o_Paddle_Y != 0)
      o_Paddle_Y <= o_Paddle_Y - 1;
    else if (i_Paddle_Dn == 1'b1 && r_Paddle_Count == c_PADDLE_SPEED && o_Paddle_Y != c_GAME_HEIGHT - c_PADDLE_HEIGHT)
      o_Paddle_Y <= o_Paddle_Y + 1;
  end

  // Draw the paddles as determined by input parameter
  // c_PLAYER_PADDLE_X as well as o_Paddle_Y.
  always @(posedge i_Clk)
  begin
    // Draws in a single columns and in a range of rows.
    // Range of rows is determined by c_PADDLE_HEIGHT.
    if (i_Col_Count_Div == c_PLAYER_PADDLE_X && i_Row_Count_Div >= o_Paddle_Y && i_Row_Count_Div < o_Paddle_Y + c_PADDLE_HEIGHT)
      o_Draw_Paddle <= 1'b1;
    else
      o_Draw_Paddle <= 1'b0;
  end
endmodule
