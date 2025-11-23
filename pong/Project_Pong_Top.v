module Project_Pong_Top
  (
    input i_Clk,
    input i_UART_RX,
    // Push button
    input i_Switch_1,
    input i_Switch_2,
    input i_Switch_3,
    input i_Switch_4,
    // Segment1 is upper digit, Segment2 is lower digit
    output o_Segment1_A,
    output o_Segment1_B,
    output o_Segment1_C,
    output o_Segment1_D,
    output o_Segment1_E,
    output o_Segment1_F,
    output o_Segment1_G,
    output o_Segment2_A,
    output o_Segment2_B,
    output o_Segment2_C,
    output o_Segment2_D,
    output o_Segment2_E,
    output o_Segment2_F,
    output o_Segment2_G,
    // VGA
    output o_VGA_HSync,
    output o_VGA_VSync,
    output o_VGA_Red_0,
    output o_VGA_Red_1,
    output o_VGA_Red_2,
    output o_VGA_Grn_0,
    output o_VGA_Grn_1,
    output o_VGA_Grn_2,
    output o_VGA_Blu_0,
    output o_VGA_Blu_1,
    output o_VGA_Blu_2
  );

  // VGA constants to set frame size
  parameter c_VIDEO_WIDTH = 3;
  parameter c_TOTAL_COLS  = 800;
  parameter c_TOTAL_ROWS  = 525;
  parameter c_ACTIVE_COLS = 640;
  parameter c_ACTIVE_ROWS = 480;
  parameter c_FRONT_PORCH_HORZ = 16;
  parameter c_BACK_PORCH_HORZ  = 48;
  parameter c_FRONT_PORCH_VERT = 10;
  parameter c_BACK_PORCH_VERT  = 33;

  parameter c_BALL_SPEED   = 1250000;
  parameter c_PADDLE_SPEED = 1250000;

  // Common VGA signals
  wire [c_VIDEO_WIDTH-1:0] w_Red_Video_Pong, w_Red_Video_Porch;
  wire [c_VIDEO_WIDTH-1:0] w_Grn_Video_Pong, w_Grn_Video_Porch;
  wire [c_VIDEO_WIDTH-1:0] w_Blu_Video_Pong, w_Blu_Video_Porch;

  // Player scores (4-bit each)
  wire [3:0] w_P1_Score;
  wire [3:0] w_P2_Score;

  // 25,000,000 // 115,200 = 217
  UART_RX #(.CLKS_PER_BIT(217)) UART_RX_Inst
  (
    .i_Clock(i_Clk),
    .i_RX_Serial(i_UART_RX),
    .o_RX_DV(w_RX_DV),
    .o_RX_Byte()
  );

  // Generates sync pulses to run VGA
  VGA_Sync_Pulses
  #(
    .TOTAL_COLS(c_TOTAL_COLS),
    .TOTAL_ROWS(c_TOTAL_ROWS),
    .ACTIVE_COLS(c_ACTIVE_COLS),
    .ACTIVE_ROWS(c_ACTIVE_ROWS)
  ) VGA_Sync_Pulses_Inst
  (
    .i_Clk(i_Clk),
    .o_HSync(w_HSync_Start),
    .o_VSync(w_VSync_Start),
    .o_Col_Count(),
    .o_Row_Count()
  );

  // Debounce switches
  Debounce_Filter #(.DEBOUNCE_LIMIT(250000)) Switch_1
  (
    .i_Clk(i_Clk),
    .i_Bouncy(i_Switch_1),
    .o_Debounced(w_Switch_1)
  );
  Debounce_Filter #(.DEBOUNCE_LIMIT(250000)) Switch_2
  (
    .i_Clk(i_Clk),
    .i_Bouncy(i_Switch_2),
    .o_Debounced(w_Switch_2)
  );
  Debounce_Filter #(.DEBOUNCE_LIMIT(250000)) Switch_3
  (
    .i_Clk(i_Clk),
    .i_Bouncy(i_Switch_3),
    .o_Debounced(w_Switch_3)
  );
  Debounce_Filter #(.DEBOUNCE_LIMIT(250000)) Switch_4
  (
    .i_Clk(i_Clk),
    .i_Bouncy(i_Switch_4),
    .o_Debounced(w_Switch_4)
  );

  Pong_Top
  #(
    .c_TOTAL_COLS(c_TOTAL_COLS),
    .c_TOTAL_ROWS(c_TOTAL_ROWS),
    .c_ACTIVE_COLS(c_ACTIVE_COLS),
    .c_ACTIVE_ROWS(c_ACTIVE_ROWS),
    .c_BALL_SPEED(c_BALL_SPEED),
    .c_PADDLE_SPEED(c_PADDLE_SPEED)
  )
  (
    .i_Clk(i_Clk),
    .i_HSync(w_HSync_Start),
    .i_VSync(w_VSync_Start),
    .i_Game_Start(w_RX_DV),
    .i_Paddle_Up_P1(w_Switch_1),
    .i_Paddle_Dn_P1(w_Switch_2),
    .i_Paddle_Up_P2(w_Switch_3),
    .i_Paddle_Dn_P2(w_Switch_4),
    .o_P1_Score(w_P1_Score),
    .o_P2_Score(w_P2_Score),
    .o_HSync(w_HSync_Pong),
    .o_VSync(w_VSync_Pong),
    .o_Red_Video(w_Red_Video_Pong),
    .o_Grn_Video(w_Grn_Video_Pong),
    .o_Blu_Video(w_Blu_Video_Pong)
  );

  // Binary to 7-segment converter for upper digit
  Binary_To_7Segment SevenSeg1_Inst
  (
    .i_Clk(i_Clk),
    .i_Binary_Num(w_P1_Score),
    .o_Segment_A(w_Segment1_A),
    .o_Segment_B(w_Segment1_B),
    .o_Segment_C(w_Segment1_C),
    .o_Segment_D(w_Segment1_D),
    .o_Segment_E(w_Segment1_E),
    .o_Segment_F(w_Segment1_F),
    .o_Segment_G(w_Segment1_G)
  );

  assign o_Segment1_A = ~w_Segment1_A;
  assign o_Segment1_B = ~w_Segment1_B;
  assign o_Segment1_C = ~w_Segment1_C;
  assign o_Segment1_D = ~w_Segment1_D;
  assign o_Segment1_E = ~w_Segment1_E;
  assign o_Segment1_F = ~w_Segment1_F;
  assign o_Segment1_G = ~w_Segment1_G;

  // Binary to 7-segment converter for lower digit
  Binary_To_7Segment SevenSeg2_Inst
  (
    .i_Clk(i_Clk),
    .i_Binary_Num(w_P2_Score),
    .o_Segment_A(w_Segment2_A),
    .o_Segment_B(w_Segment2_B),
    .o_Segment_C(w_Segment2_C),
    .o_Segment_D(w_Segment2_D),
    .o_Segment_E(w_Segment2_E),
    .o_Segment_F(w_Segment2_F),
    .o_Segment_G(w_Segment2_G)
  );

  assign o_Segment2_A = ~w_Segment2_A;
  assign o_Segment2_B = ~w_Segment2_B;
  assign o_Segment2_C = ~w_Segment2_C;
  assign o_Segment2_D = ~w_Segment2_D;
  assign o_Segment2_E = ~w_Segment2_E;
  assign o_Segment2_F = ~w_Segment2_F;
  assign o_Segment2_G = ~w_Segment2_G;

  VGA_Sync_Porch
  #(
    .VIDEO_WIDTH(c_VIDEO_WIDTH),
    .TOTAL_COLS(c_TOTAL_COLS),
    .TOTAL_ROWS(c_TOTAL_ROWS),
    .ACTIVE_COLS(c_ACTIVE_COLS),
    .ACTIVE_ROWS(c_ACTIVE_ROWS),
    .FRONT_PORCH_HORZ(c_FRONT_PORCH_HORZ),
    .BACK_PORCH_HORZ(c_BACK_PORCH_HORZ),
    .FRONT_PORCH_VERT(c_FRONT_PORCH_VERT),
    .BACK_PORCH_VERT(c_BACK_PORCH_VERT)
  ) VGA_Sync_Porch_Inst
  (
    .i_Clk(i_Clk),
    .i_HSync(w_HSync_Pong),
    .i_VSync(w_VSync_Pong),
    .i_Red_Video(w_Red_Video_Pong),
    .i_Grn_Video(w_Grn_Video_Pong),
    .i_Blu_Video(w_Blu_Video_Pong),
    .o_HSync(o_VGA_HSync),
    .o_VSync(o_VGA_VSync),
    .o_Red_Video(w_Red_Video_Porch),
    .o_Grn_Video(w_Grn_Video_Porch),
    .o_Blu_Video(w_Blu_Video_Porch)
  );

  assign o_VGA_Red_0 = w_Red_Video_Porch[0];
  assign o_VGA_Red_1 = w_Red_Video_Porch[1];
  assign o_VGA_Red_2 = w_Red_Video_Porch[2];

  assign o_VGA_Grn_0 = w_Grn_Video_Porch[0];
  assign o_VGA_Grn_1 = w_Grn_Video_Porch[1];
  assign o_VGA_Grn_2 = w_Grn_Video_Porch[2];

  assign o_VGA_Blu_0 = w_Blu_Video_Porch[0];
  assign o_VGA_Blu_1 = w_Blu_Video_Porch[1];
  assign o_VGA_Blu_2 = w_Blu_Video_Porch[2];
endmodule