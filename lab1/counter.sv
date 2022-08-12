module counter(incr, decr, out, reset, clk);
    parameter           MAX_CAPACITY =5'd16;

    input logic         incr, decr, reset, clk;
    output logic [7:0]  out;
    
    always_ff @(posedge clk) begin
        if(reset)   
            out <= 5'b0;
        else if(~reset & incr & (out < MAX_CAPACITY))
            out <= out + 5'b1;
        else if(~reset & decr & (out > 5'b0))
            out <= out - 5'b1;
    end

endmodule


module counter_testbench();
    parameter           MAX_CAPACITY = 5'd16,
                        CLOCK_PERIOD = 100;

    logic         incr, decr, reset, clk;
    logic [7:0]  out;
    
    counter dut(.incr, .decr, .out, .reset, .clk);
    
    //set up the clock
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

    integer i;
    initial begin
        reset<=1;                   @(posedge clk);
        reset<=0;                   @(posedge clk);
        
        incr<=1; decr<=0;
        for(i=0; i<16; i++) begin
            @(posedge clk);
        end
        
        incr<=0; decr<=1;
        for(i=0; i<16; i++) begin
            @(posedge clk);
        end

        incr<=1; decr<=0;           @(posedge clk);
        incr<=0; decr<=1;           @(posedge clk);
        incr<=1; decr<=0;           @(posedge clk);

        $stop;
    end
endmodule