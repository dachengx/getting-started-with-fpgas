module Pong_Ball_Ctrl
  #(
    parameter c_GAME_WIDTH = 40,
    parameter c_GAME_HEIGHT = 30,
    parameter c_BALL_SPEED = 1250000  // Move per pong game unit every 50 ms
  )
  (
    input i_Clk,
    input i_Game_Active,
    input [$clog2(c_GAME_WIDTH)-1:0]       i_Col_Count_Div,
    input [$clog2(c_GAME_HEIGHT)-1:0]      i_Row_Count_Div,
    output reg                             o_Draw_Ball,
    output reg [$clog2(c_GAME_WIDTH)-1:0]  o_Ball_X = 0,
    output reg [$clog2(c_GAME_HEIGHT)-1:0] o_Ball_Y = 0
  );

  reg [$clog2(c_GAME_WIDTH)-1:0]  r_Ball_X_Prev = 0;
  reg [$clog2(c_GAME_HEIGHT)-1:0] r_Ball_Y_Prev = 0;
  reg [$clog2(c_BALL_SPEED)-1:0]  r_Ball_Count = 0;

  always @(posedge i_Clk)
  begin
    // IF the game is not active, ball stays in the middle of
    // screen until the game starts.
    if (i_Game_Active == 1'b0)
    begin
      o_Ball_X      <= c_GAME_WIDTH / 2;
      o_Ball_Y      <= c_GAME_HEIGHT / 2;
      r_Ball_X_Prev <= c_GAME_WIDTH / 2;
      r_Ball_Y_Prev <= c_GAME_HEIGHT / 2;
    end

    // Update the ball counter continuously. Ball movement
    // updtae rate is determined by input parametwer c_BALL_SPEED.
    // If ball counter is at the limit, update the ball position
    // in both X and Y.
    else
    begin
      if (r_Ball_Count < c_BALL_SPEED)
        r_Ball_Count <= r_Ball_Count + 1;
      else
      begin
        r_Ball_Count <= 0;

        // Store previous location to keep track of movement
        r_Ball_X_Prev <= o_Ball_X;
        r_Ball_Y_Prev <= o_Ball_Y;

        // When previous value is less than current value, ball is moving
        // to the right/down. Keep it moving to the right/down unless it
        // is at wall. When previous value is greater than current value, ball is
        // moving to the left/up. Keep it moving to the left/up unless it
        // is at wall.
        if ((r_Ball_X_Prev < o_Ball_X && o_Ball_X == c_GAME_WIDTH - 1) || (r_Ball_X_Prev > o_Ball_X && o_Ball_X != 0))
          o_Ball_X <= o_Ball_X - 1;
        else
          o_Ball_X <= o_Ball_X + 1;

        if ((r_Ball_Y_Prev < o_Ball_Y && o_Ball_Y == c_GAME_HEIGHT - 1) || (r_Ball_Y_Prev > o_Ball_Y && o_Ball_Y != 0))
          o_Ball_Y <= o_Ball_Y - 1;
        else
          o_Ball_Y <= o_Ball_Y + 1;
      end
    end
  end // always @(posedge i_Clk)

  // Draw a ball at the location determined by X and Y indexes
  always @(posedge i_Clk)
  begin
    if (i_Col_Count_Div == o_Ball_X && i_Row_Count_Div == o_Ball_Y)
      o_Draw_Ball <= 1'b1;
    else
      o_Draw_Ball <= 1'b0;
  end
endmodule  // Pong_Ball_Ctrl
