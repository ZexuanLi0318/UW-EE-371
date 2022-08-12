// top level module for switching task 1 and 2 using SW9
`timescale 1 ps / 1 ps
module switch_tasks (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW, CLOCK_50);
	output  logic   [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output  logic   [9:0]   LEDR;
    input   logic   [9:0]   SW;
    input   logic   [3:0]   KEY;
	input   logic		    CLOCK_50;

	logic [3:0] result; // task1 counter
    logic [4:0] loc;    // task2 location found
    logic [3:0] loc1, loc0; // inputs for hex1-0 display
	logic reset, start, done1, done2, found;
	assign reset = ~KEY[0];
	assign start = ~KEY[3];
	//assign LEDR[9] = done;
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

	// turn off the unused hexs
	assign HEX5 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX2 = 7'b1111111;


//switch logic
	// both program runs in parallel, output goes to a mux
	logic [3:0] h1, h0;
	always_comb begin
		if(SW[9]) begin	//task1
			h1 = 4'd0;
			h0 = result;
			LEDR[9] = done1;
		end
		else begin		//task2
			h1 = loc1;
			h0 = loc0;
			LEDR[9] = done2;
		end
	end

	searcher loc_search (.A(SW[7:0]), .found, .done(done2), .loc, .clk(clkSelect), .reset, .start);
	counter counter (.A(SW[7:0]), .result, .clk(clkSelect), .reset, .start, .done(done1));
	seg7 hex1 (.hex(h1), .leds(HEX1));
    seg7 hex0 (.hex(h0), .leds(HEX0));

endmodule  // DE1_SoC

module switch_tasks_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  	logic [9:0] LEDR;
  	logic [3:0] KEY;
  	logic [9:0] SW;
  	logic CLOCK_50;

  	switch_tasks dut (.*);

	// set up the clock
  	parameter CLOCK_PERIOD = 100;
  	initial begin
    	CLOCK_50 <= 0;
    	forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
  	end

  	initial begin
		//task1	  
    	SW[9] <= 1; KEY[0] <= 0; 					SW[7:0] <= 8'd5;  @(posedge CLOCK_50);
    				KEY[0] <= 1; 	KEY[3] <= 1; 	@(posedge CLOCK_50); //task 1 need to read A first
									KEY[3] <= 0; 	repeat(10) @(posedge CLOCK_50);
    	//task2
		SW[9] <= 0; repeat(10) @(posedge CLOCK_50);
		
		
		$stop();
  	end

endmodule