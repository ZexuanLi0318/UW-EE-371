// this is the top level module for only task2 on DE1_SoC board
`timescale 1 ps / 1 ps
module task2_top_level (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW, CLOCK_50);
	output  logic   [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output  logic   [9:0]   LEDR;
    input   logic   [9:0]   SW;
    input   logic   [3:0]   KEY;
	input   logic		    CLOCK_50;

    logic [4:0] loc;
    logic [3:0] loc1, loc0; // inputs for hex1-0 display
	logic reset, start, done, found;
	assign reset = ~KEY[0];
	assign start = ~KEY[3];
	assign LEDR[9] = done;
    assign LEDR[0] = found;
    assign loc1 = loc / 5'd10; // the tens bit
    assign loc0 = loc % 5'd10; // the single bit

	// clock divider code copied from EE271
	logic [31:0] div_clk;
	parameter whichClock = 25; // 0.75 Hz clock
	clock_divider cdiv (.clock(CLOCK_50), .reset(reset), .divided_clocks(div_clk));
	// Clock selection; allows for easy switching between simulation and boardclocks
	logic clkSelect;
	// Uncomment ONE of the following two lines depending on intention
	assign clkSelect = CLOCK_50; // for simulation
	//assign clkSelect = div_clk[whichClock]; // for board

	searcher loc_search (.A(SW[7:0]), .found, .done, .loc, .clk(clkSelect), .reset, .start);
	seg7 loc1_display (.hex(loc1), .leds(HEX1));
    seg7 loc0_display (.hex(loc0), .leds(HEX0));

endmodule  // DE1_SoC

module task2_top_level_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  	logic [9:0] LEDR;
  	logic [3:0] KEY;
  	logic [9:0] SW;
  	logic CLOCK_50;

  	task2_top_level dut (.*);

	// set up the clock
  	parameter CLOCK_PERIOD = 100;
  	initial begin
    	CLOCK_50 <= 0;
    	forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
  	end

  	initial begin
    	KEY[0] <= 0; 	SW[7:0] <= 8'd5;  @(posedge CLOCK_50);
    	KEY[0] <= 1; 	KEY[3] <= 0; repeat(20) @(posedge CLOCK_50);
    	
		$stop();
  	end

endmodule