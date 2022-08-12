module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, GPIO_0, clk);
	input logic	[33:0] GPIO_0;
	input logic 	   clk;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	

	occupancy carInside (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR, .inner(GPIO_0[9]), .outer(GPIO_0[8]), .reset(GPIO_0[5]), .clk);
endmodule  // DE1_SoC


/* testbench for the DE1_SoC */
module DE1_SoC_testbench();
	logic [33:0]	GPIO_0;
	logic 			clk;
	logic [6:0] 	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0]		LEDR;

	
	// using SystemVerilog's implicit port connection syntax for brevity
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR, .GPIO_0, .clk);

	 //set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	integer i;
	initial begin
		GPIO_0[5]<=1;	@(posedge clk);
		GPIO_0[5]<=0;	
		for(i=0; i<17; i++) begin
			{GPIO_0[8], GPIO_0[9]} <= 2'b10;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} <= 2'b11;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} <= 2'b01;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} <= 2'b00;        @(posedge clk);
		end

		for(i=0; i<16; i++) begin
            {GPIO_0[8], GPIO_0[9]} = 2'b01;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} = 2'b11;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} = 2'b10;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} = 2'b00;        @(posedge clk);
        end       

        for(i=0; i<3; i++) begin
            {GPIO_0[8], GPIO_0[9]} = 2'b10;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} = 2'b11;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} = 2'b01;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} = 2'b00;        @(posedge clk);
        end
        for(i=0; i<2; i++) begin
            {GPIO_0[8], GPIO_0[9]} = 2'b01;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} = 2'b11;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} = 2'b10;        @(posedge clk);
            {GPIO_0[8], GPIO_0[9]} = 2'b00;        @(posedge clk);
        end
		$stop;
	end  // initial
	
endmodule  // DE1_SoC_testbench