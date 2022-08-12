// this module is similar to the ram32x3 but uses a multidimensional array
module task2(address, clock, data, wren, q);
	input	logic [4:0]  address;
	input	logic        clock;
	input	logic	[2:0]  data;
	input	logic		    wren;
	output	logic	[2:0]  q;
	
	logic [2:0] memory_array [31:0]; 
	
	logic [4:0] addr1;
	logic [2:0] data1;
	logic 		wren1;
	
	always_ff @(posedge clock) begin
		addr1 <= address;
		data1 <= data;
		wren1 <= wren;
	end
	
	always_comb begin
		if (wren1) begin
			memory_array[addr1] = data1;
			q = data1;
		end else begin
			q = memory_array[addr1];
		end
			
	end
endmodule

module task2_testbench();
	logic [2:0] q;
	logic [2:0] data;
	logic [4:0] address;
	logic clock, wren;
	
	task2 dut (.*);
	
	// set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
	 clock <= 0;
	 forever #(CLOCK_PERIOD/2) clock <= ~clock;
	end	
	
	initial begin
		@(posedge clock);
		wren <= 1; data <= 3'd0; address <= 5'd0; @(posedge clock);
		wren <= 1; data <= 3'd1; address <= 5'd1; @(posedge clock);
		wren <= 0; 					 address <= 5'd0; @(posedge clock);
										 address <= 5'd1; @(posedge clock);
		@(posedge clock);
		$stop();
	end
endmodule
