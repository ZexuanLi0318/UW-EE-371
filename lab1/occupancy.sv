module occupancy(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, inner, outer, reset, clk);
    output logic [6:0]      HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0]      LEDR;
    input  logic            inner, outer, reset, clk;

    logic incr, decr;
    
    logic [7:0] carNumIn, enterNum, exitNum;
    logic [3:0] y1, y0;
    logic [6:0] y1_ledr, y0_ledr;   
    assign y1 = carNumIn / 4'd10;
    assign y0 = carNumIn % 4'd10;
    
    detection detect(.inner, .outer, .enter(incr), .exit(decr), .reset, .clk);
    counter carCounter(.incr, .decr, .out(carNumIn), .reset, .clk);

    seg7 hex5 (.bcd(y1), .leds(y1_ledr));
    seg7 hex4 (.bcd(y0), .leds(y0_ledr));
    // muxes
    always_comb begin
        if(carNumIn==5'd16) begin
            HEX5 = 7'b0001110; //F
            HEX4 = 7'b1000001; //U
            HEX3 = 7'b1000111; //L
            HEX2 = 7'b1000111; //L
            HEX1 = 7'b1111111; //off
            HEX0 = 7'b1111111; //off
        end
        else if(carNumIn==5'd0) begin
            HEX5 = 7'b1000110; //C
            HEX4 = 7'b1000111; //L
            HEX3 = 7'b0000110; //E
            HEX2 = 7'b1001000; //A
            HEX1 = 7'b0001000; //R
            HEX0 = 7'b1000000; //0
        end
        else begin
            HEX5 = y1_ledr;
            HEX4 = y0_ledr;
            HEX3 = 7'b1111111; //off
            HEX2 = 7'b1111111; //off
            HEX1 = 7'b1111111; //off
            HEX0 = 7'b1111111; //off
        end
    end

endmodule

module occupancy_testbench();
    logic [6:0]      HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0]      LEDR;
    logic            inner, outer, reset, clk;

    occupancy dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR, .inner, .outer, .reset, .clk);

    //set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

    integer i;
    initial begin
        reset<=1;                       @(posedge clk);
        reset<=0; 
        for(i=0; i<17; i++) begin
            {outer, inner} <= 2'b10;        @(posedge clk);
            {outer, inner} <= 2'b11;        @(posedge clk);
            {outer, inner} <= 2'b01;        @(posedge clk);
            {outer, inner} <= 2'b00;        @(posedge clk);
        end

         for(i=0; i<16; i++) begin
            {outer, inner} = 2'b01;        @(posedge clk);
            {outer, inner} = 2'b11;        @(posedge clk);
            {outer, inner} = 2'b10;        @(posedge clk);
            {outer, inner} = 2'b00;        @(posedge clk);
        end       

        for(i=0; i<3; i++) begin
            {outer, inner} = 2'b10;        @(posedge clk);
            {outer, inner} = 2'b11;        @(posedge clk);
            {outer, inner} = 2'b01;        @(posedge clk);
            {outer, inner} = 2'b00;        @(posedge clk);
        end
        for(i=0; i<2; i++) begin
            {outer, inner} = 2'b01;        @(posedge clk);
            {outer, inner} = 2'b11;        @(posedge clk);
            {outer, inner} = 2'b10;        @(posedge clk);
            {outer, inner} = 2'b00;        @(posedge clk);
        end
        $stop;
    end 
endmodule