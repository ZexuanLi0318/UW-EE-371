// this is the  top level module for only task1
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW, CLOCK_50);
	output  logic   [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output  logic   [9:0]   LEDR;
    input   logic   [9:0]   SW;
    input   logic   [3:0]   KEY;
	input   logic		    CLOCK_50;

	logic [3:0] result;
	logic reset, start, done;
	assign reset = ~KEY[0];
	assign start = ~KEY[3];
	assign LEDR[9] = done;

	// clock divider code copied from EE271
	logic [31:0] div_clk;
	parameter whichClock = 25; // 0.75 Hz clock
	clock_divider cdiv (.clock(CLOCK_50), .reset(reset), .divided_clocks(div_clk));
	// Clock selection; allows for easy switching between simulation and boardclocks
	logic clkSelect;
	// Uncomment ONE of the following two lines depending on intention
	assign clkSelect = CLOCK_50; // for simulation
	//assign clkSelect = div_clk[whichClock]; // for board

	counter bit_counter (.A(SW[7:0]), .result, .clk(clkSelect), .reset, .start, .done);
	seg7 result_display (.hex(result), .leds(HEX0));

endmodule  // DE1_SoC

module DE1_SoC_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  	logic [9:0] LEDR;
  	logic [3:0] KEY;
  	logic [9:0] SW;
  	logic CLOCK_50;

  	DE1_SoC dut (.*);

	// set up the clock
  	parameter CLOCK_PERIOD = 100;
  	initial begin
    	CLOCK_50 <= 0;
    	forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
  	end

  	initial begin
    	KEY[0] <= 0; 	SW[7:0] <= 8'b11110010;  @(posedge CLOCK_50);
    	KEY[0] <= 1; 	KEY[3] <= 1; @(posedge CLOCK_50);
						KEY[3] <= 0; repeat(12) @(posedge CLOCK_50);
    	
		$stop();
  	end

endmodule