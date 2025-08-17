module State_Machine_Game #(
  parameter CLKS_PER_SEC = 25000000,
  parameter GAME_LIMIT = 6
) (
  input i_Clk,
  input i_Switch_1,
  input i_Switch_2,
  input i_Switch_3,
  input i_Switch_4,
  output reg [3:0] o_Score,
  output o_LED_1,
  output o_LED_2,
  output o_LED_3,
  output o_LED_4
);

  localparam START        = 3'd0;
  localparam PATTERN_OFF  = 3'd1;
  localparam PATTERN_SHOW = 3'd2;
  localparam WAIT_PLAYER  = 3'd3;
  localparam INCR_SCORE   = 3'd4;
  localparam LOSER        = 3'd5;
  localparam WINNER       = 3'd6;

  reg [2:0] r_SM_Main;
  reg r_Toggle, r_Switch_1, r_Switch_2, r_Switch_3;
  reg r_Switch_4, r_Button_DV;
  reg [1:0] r_Pattern[0:10];
  wire [21:0] w_LFSR_Data;
  reg [$clog2(GAME_LIMIT)-1:0] r_Index;
  reg [1:0] r_Button_ID;
  wire w_Count_En, w_Toggle;

  always @(posedge i_Clk)
  begin
    if (i_Switch_1 & i_Switch_2)
      r_SM_Main <= START;
    else
    begin
      case (r_SM_Main)

        START:
        begin
            if (!i_Switch_1 & !i_Switch_2 & r_Button_DV)
            begin
                o_Score   <= 0;
                r_Index   <= 0;
                r_SM_Main <= PATTERN_OFF;
            end
        end

        PATTERN_OFF:
        begin
          if (!w_Toggle & r_Toggle)
            r_SM_Main <= PATTERN_SHOW;
        end

        PATTERN_SHOW:
        begin
          if (!w_Toggle & r_Toggle)
            if (o_Score == r_Index)
            begin
              r_Index   <= 0;
              r_SM_Main <= WAIT_PLAYER;
            end
            else
            begin
              r_Index   <= r_Index + 1;
              r_SM_Main <= PATTERN_OFF;
            end
        end

        WAIT_PLAYER:
        begin
          if (r_Button_DV)
            if (r_Pattern[r_Index] == r_Button_ID && r_Index == o_Score)
            begin
              r_Index   <= 0;
              r_SM_Main <= INCR_SCORE;
            end
            else if (r_Pattern[r_Index] != r_Button_ID)
              r_SM_Main <= LOSER;
            else
              r_Index <= r_Index + 1;
        end

        INCR_SCORE:
        begin
          o_Score <= o_Score + 1;
          if (o_Score == GAME_LIMIT - 1)
            r_SM_Main <= WINNER;
          else
            r_SM_Main <= PATTERN_OFF;
        end

        WINNER:
        begin
          o_Score <= 4'hA;
        end

        LOSER:
        begin
          o_Score <= 4'hF;
        end

        default:
          r_SM_Main <= START;
      endcase
    end
  end

  always @(posedge i_Clk)
  begin
    if (r_SM_Main == START)
    begin
      r_Pattern[0]  <= w_LFSR_Data[1:0];
      r_Pattern[1]  <= w_LFSR_Data[3:2];
      r_Pattern[2]  <= w_LFSR_Data[5:4];
      r_Pattern[3]  <= w_LFSR_Data[7:6];
      r_Pattern[4]  <= w_LFSR_Data[9:8];
      r_Pattern[5]  <= w_LFSR_Data[11:10];
      r_Pattern[6]  <= w_LFSR_Data[13:12];
      r_Pattern[7]  <= w_LFSR_Data[15:14];
      r_Pattern[8]  <= w_LFSR_Data[17:16];
      r_Pattern[9]  <= w_LFSR_Data[19:18];
      r_Pattern[10] <= w_LFSR_Data[21:20];
    end
  end

  assign o_LED_1 = (r_SM_Main == PATTERN_SHOW && r_Pattern[r_Index] == 2'b00) ? 1'b1 : i_Switch_1;
  assign o_LED_2 = (r_SM_Main == PATTERN_SHOW && r_Pattern[r_Index] == 2'b01) ? 1'b1 : i_Switch_2;
  assign o_LED_3 = (r_SM_Main == PATTERN_SHOW && r_Pattern[r_Index] == 2'b10) ? 1'b1 : i_Switch_3;
  assign o_LED_4 = (r_SM_Main == PATTERN_SHOW && r_Pattern[r_Index] == 2'b11) ? 1'b1 : i_Switch_4;

  always @(posedge i_Clk)
  begin
    r_Toggle   <= w_Toggle;
    r_Switch_1 <= i_Switch_1;
    r_Switch_2 <= i_Switch_2;
    r_Switch_3 <= i_Switch_3;
    r_Switch_4 <= i_Switch_4;

    if (r_Switch_1 & !i_Switch_1)
    begin
      r_Button_DV <= 1'b1;
      r_Button_ID <= 0;
    end
    else if (r_Switch_2 & !i_Switch_2)
    begin
      r_Button_DV <= 1'b1;
      r_Button_ID <= 1;
    end
    else if (r_Switch_3 & !i_Switch_3)
    begin
      r_Button_DV <= 1'b1;
      r_Button_ID <= 2;
    end
    else if (r_Switch_4 & !i_Switch_4)
    begin
      r_Button_DV <= 1'b1;
      r_Button_ID <= 3;
    end
    else
    begin
      r_Button_DV <= 1'b0;
      r_Button_ID <= 0;
    end
  end

  assign w_Count_En = (r_SM_Main == PATTERN_SHOW || r_SM_Main == PATTERN_OFF);

  Count_And_Toggle #(.COUNT_LIMIT(CLKS_PER_SEC / 4)) Count_Inst (
    .i_Clk(i_Clk),
    .i_Enable(w_Count_En),
    .o_Toggle(w_Toggle)
  );

  LFSR_22 LFSR_Inst (
    .i_Clk(i_Clk),
    .o_LFSR_Data(w_LFSR_Data),
    .o_LFSR_Done()
  );

endmodule
