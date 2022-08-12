// this is the top-level module only for task2
`timescale 1 ps / 1 ps
module task2_top_level (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	// immediate signals
	logic [4:0] addr_task2;
	logic [2:0] data, q;
	logic wren;
	logic [3:0] addr_task2_0, addr_task2_1;

	// signals for HEX display
	// one for decimal tenth digit, zero for decimal signal digit
	assign addr_task2_0 = addr_task2 % 4'd10;
	assign addr_task2_1 = addr_task2 / 4'd10;

	assign wren = SW[0];				// write enable
	assign addr_task2 = SW[8:4];
	assign data = SW[3:1];			// input data
	
	// turn off the not used HEXs	
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
  
	task2 RAM (.address(addr_task2), .clock(KEY[0]), .data, .wren, .q);
 
	// instantiates seg7 for HEX display
	seg7 Addr1 (.hex(addr_task2_1), .leds(HEX5));
	seg7 Addr0 (.hex(addr_task2_0), .leds(HEX4));
	seg7 DataIn (.hex({1'b0,data}), .leds(HEX1));
	seg7 DataOut (.hex({1'b0,q}), .leds(HEX0));
	
endmodule


module task2_top_level_testbench ();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;

	
	task2_top_level dut (.*);
	
	// set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
		KEY[0] <= 0;
		forever #(CLOCK_PERIOD/2) KEY[0] <= ~KEY[0];
	end

	integer i;
	initial begin
//testbench for task2
		// format: [wren_addr_data]
		// HEX5:		addr1
		// HEX4:		addr0
		// HEX1:		data input
		// HEX0:		data output
		//x_addr_dataIn_wren
		@(posedge KEY[0]);
		
		SW <= 10'b0_00000_000_1; @(posedge KEY[0]);	// write 0 to address 0
		@(posedge KEY[0]);
		
		SW <= 10'b0_00000_000_0; @(posedge KEY[0]);	// read from address 0
		@(posedge KEY[0]);
		
		SW <= 10'b0_00010_100_1; @(posedge KEY[0]);	// write 4 to adderss 2
		@(posedge KEY[0]);
		
		SW <= 10'b0_00010_000_0; @(posedge KEY[0]);	// read from address 2
		@(posedge KEY[0]);
		
		SW <= 10'b0_00000_000_0; @(posedge KEY[0]);	// read from address 0
		@(posedge KEY[0]);
		@(posedge KEY[0]);
	   @(posedge KEY[0]);


		$stop();

	end
endmodule