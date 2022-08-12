module detection(inner, outer, enter, exit, reset, clk);
    input logic     inner, outer, reset, clk;
    output logic    enter, exit;
    
    // state variables
    enum logic [1:0] {S0=2'b00,  S1=2'b01, S2=2'b10, S3=2'b11} ps, ns;
    
    // next state logic
    always_comb begin 
        case(ps)
            S0: if(outer)               ns = S2;
                else if(inner)          ns = S1;
                else                    ns = S0;

            S1: if(outer)               ns = S3;
                else if(~inner)         ns = S0;
                else                    ns = S1;

            S2: if(~outer)              ns = S0;
                else if(inner)          ns = S3;
                else                    ns = S2;
            
            S3: if(~outer)              ns = S1;
                else if(~inner)         ns = S2;
                else                    ns = S3;
        endcase
    end

    // output logic
    assign enter = (ps==S1) & (ns==S0); 
    assign exit = (ps==S2) & (ns==S0); 

    // dff
    always_ff @(posedge clk)
    begin
        if(reset)
            ps <= S0;
        else
            ps <= ns;
    end

endmodule

module detection_testbench();
    logic inner, outer, reset, clk;
    logic enter, exit;

    detection dut(.inner, .outer, .enter, .exit, .reset, .clk);

    //set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

    initial begin
        reset<=1;                        @(posedge clk);
        reset<=0; {outer, inner}<=2'b00; @(posedge clk);
                  {outer, inner}<=2'b01; @(posedge clk);
                  {outer, inner}<=2'b01; @(posedge clk);
                  {outer, inner}<=2'b11; @(posedge clk);
                  {outer, inner}<=2'b11; @(posedge clk);
                  {outer, inner}<=2'b10; @(posedge clk);
                  {outer, inner}<=2'b10; @(posedge clk);
                  {outer, inner}<=2'b00; @(posedge clk);
                  {outer, inner}<=2'b10; @(posedge clk);
                  {outer, inner}<=2'b11; @(posedge clk);
                  {outer, inner}<=2'b01; @(posedge clk);
                  {outer, inner}<=2'b00; @(posedge clk);
        $stop;
    end

endmodule