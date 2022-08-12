// this is the top_level module for task3
`timescale 1 ps / 1 ps
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW, CLOCK_50);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input	logic CLOCK_50;

	// immediate signals
	logic [4:0] wraddr, rdaddr; // write address and read address(counter)
	logic [3:0] wraddr0, wraddr1, rdaddr0, rdaddr1; // signals for HEX display
	logic [2:0] data, dataOut_display; // dataIn and dataOut
	logic	[2:0] q_task2; // q output of RAM task2 one port module
	logic	[2:0] q_task3; // q output of RAM task3 two port module
	logic wren; // write enable signal
	logic [6:0]	HEX2_task3, HEX3_task3; // coutner HEX display signals
	
  
	assign wren = SW[0];				
	assign data = SW[3:1];			
	assign reset = ~KEY[3];
	// write address input from DE1_SoC board
	assign wraddr[4] = SW[8];
	assign wraddr[3] = SW[7];
	assign wraddr[2] = SW[6];
	assign wraddr[1] = SW[5];
	assign wraddr[0] = SW[4];
	// signals for HEX display
	// one for decimal tenth digit, zero for decimal signal digit 
	assign wraddr0 = wraddr % 4'd10;
	assign wraddr1 = wraddr / 4'd10;
	assign rdaddr0 = rdaddr % 4'd10;
	assign rdaddr1 = rdaddr / 4'd10;
	
	// mux to toggle between task 2 and task 3
	always_comb begin
		if(SW[9]) begin
			dataOut_display = q_task3;
			HEX3 = HEX3_task3;
			HEX2 = HEX2_task3;
		end
		else begin
			dataOut_display = q_task2;
			HEX3 = 7'b1111111;
			HEX2 = 7'b1111111;
		end
	end
	
			
	// clock divider code copied from EE271
	logic [31:0] div_clk;
	parameter whichClock = 25; // 0.75 Hz clock
	clock_divider cdiv (.clock(CLOCK_50), .reset(reset), .divided_clocks(div_clk));
		// Clock selection; allows for easy switching between simulation and boardclocks
	logic clkSelect;
		// Uncomment ONE of the following two lines depending on intention
	assign clkSelect = CLOCK_50; // for simulation
		//assign clkSelect = div_clk[whichClock]; // for board
	
	
	// counter for read address
	always_ff @(posedge clkSelect) begin
		if (reset)
			rdaddr <= 5'b0;
		else
			rdaddr <= rdaddr + 5'b1;
	end
	
	// instantiate modules
	task2 RAM_task2 (.address(wraddr), .clock(KEY[0]), .data, .wren, .q(q_task2));
	ram32x3port2 RAM_task3(.clock(clkSelect), .data(data), .rdaddress(rdaddr), .wraddress(wraddr), .wren, .q(q_task3));

	seg7 wrAddr1 (.hex(wraddr1), .leds(HEX5));
	seg7 wrAddr0 (.hex(wraddr0), .leds(HEX4));
	seg7 rdAddr1 (.hex(rdaddr1), .leds(HEX3_task3));
	seg7 rdAddr0 (.hex(rdaddr0), .leds(HEX2_task3));
	seg7 DataIn (.hex({1'b0,data}), .leds(HEX1));
	seg7 DataOut (.hex({1'b0,dataOut_display}), .leds(HEX0));
	
	 
endmodule


module DE1_SoC_testbench ();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic CLOCK_50;

	
	DE1_SoC dut (.*);
	
	// set up the clock for task3
	parameter CLOCK_PERIOD = 100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end
	// set up the clock for task2
	initial begin
		KEY[0] <= 0;
		forever #(CLOCK_PERIOD/2) KEY[0] <= ~KEY[0];
	end

	integer i;
	initial begin
		KEY[3]<=0; @(posedge KEY[0]); //reset=~KEY[3]
		KEY[3]<=1; @(posedge KEY[0]);
		// only task2, SW9=0
		SW <= 10'b0_00000_000_1; @(posedge KEY[0]);	// write 0 to address 0
		@(posedge CLOCK_50);
		SW <= 10'b0_00010_100_1; @(posedge KEY[0]);	// write 4 to adderss 2
		@(posedge CLOCK_50);
		SW <= 10'b0_00010_000_0; @(posedge KEY[0]);  
		@(posedge CLOCK_50);
		SW <= 10'b0_00011_101_1; @(posedge KEY[0]);	
		@(posedge KEY[0]);
		@(posedge KEY[0]);
		
		// only task3, SW9=1
		SW <= 10'b1_00000_000_1; @(posedge CLOCK_50);	// write 0 to address 0
	
		SW <= 10'b1_00010_100_1; @(posedge CLOCK_50);	// write 4 to adderss 2
		
		SW <= 10'b1_00010_000_0; @(posedge CLOCK_50);  
		
		@(posedge CLOCK_50);
		repeat(30) 	@(posedge CLOCK_50);
		// toggle between task2 and 3
		SW <= 10'b0_00100_100_1; @(posedge KEY[0]);	
	
		SW <= 10'b1_00100_100_1; @(posedge CLOCK_50);
		
		$stop(); 
	end
endmodule
