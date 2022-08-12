module D_FF (d, q, reset, clk);
    input logic  d, reset, clk;
    output logic q;

    always @(posedge clk)
    begin
        if(reset)
            q <= 0;
        else
            q <= d;
    end
endmodule

module D_FF_testbench();
    logic d, reset, clk;
    logic q;

    D_FF dut (.d, .q, .reset, .clk);
    initial begin
        clk=0;
     forever #10 clk = ~clk;  
    end 

    initial begin 
        reset=1;
                d <= 0; #100;
        reset=0;
                d <= 1; #100;
                d <= 0; #100;
                d <= 1;
        $stop;
    end 
endmodule