// this module instantiates the ram32x3 module for task1
`timescale 1 ps / 1 ps
module task1 (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW, CLOCK_50);
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;
    input logic [3:0] KEY;
    input logic [9:0] SW;
    input logic   CLOCK_50;

	// immediate signals
    logic	[4:0]   address;
	logic	        clock;
	logic	[2:0]   data;
	logic	        wren;
	logic	[2:0]   q;

	
    assign LEDR[2:0] = q;
    assign address = SW[4:0];
    assign data = SW[7:5];
    assign wren = SW[8];

    ram32x3 RAM (.address, .clock(CLOCK_50), .data, .wren, .q);
    
endmodule


module task1_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
   logic [9:0] LEDR;
   logic [3:0] KEY;
   logic [9:0] SW;
   logic   clk;
	
	task1 dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR, .KEY, .SW, .CLOCK_50(clk));
	
	//set up the clock
	parameter CLOCK_PERIOD = 100;
   initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end
	
	integer i;
	initial begin
		@(posedge clk);
		SW <= 10'b0_1_000_00000; @(posedge clk);
		SW <= 10'b0_1_111_00010; @(posedge clk);
		SW <= 10'b0_0_000_00001; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop(); 
	end
endmodule
