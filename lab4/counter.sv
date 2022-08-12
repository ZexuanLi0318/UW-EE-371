// this is the counter in task1 to count number of bits==1
// in an n-bit input A
module counter(A, result, clk, reset, start, done);
    parameter n = 8;
    input logic clk, reset, start;
    input logic [n-1:0] A;
    output reg [3:0] result;
    output logic done;

    logic [n-1:0] shift_A;

    enum logic [1:0] {S1, S2, S3} ps, ns;

//control logic
    // next state logic
    always_comb begin
        case(ps)
            S1: ns = start ? S2 : S1;
            S2: ns = (shift_A==0) ? S3 : S2;
            S3: ns = start ? S3 : S1;
        endcase
    end

    // ps dff
    always_ff @(posedge clk) begin
        if (reset)
            ps <= S1;
        else
            ps <= ns;
    end

    // state output
    assign  incr_result = (ps == S2) & (ns == S2) & (shift_A[0] == 1);
    assign  init_A = (ps == S1) & (~start);
    assign  rshift_A = (ps == S2);
    assign  done = (ps == S3);
    assign  init_result = (ps == S1);
//datapath logic

    always_ff @(posedge clk) begin
        if (incr_result)
            result <= result + 4'd1;
        if (rshift_A)
            shift_A <= shift_A >> 1;
        if (init_A)
            shift_A <= A;
        if (init_result)
            result <= 0;
    end
endmodule

module counter_testbench();
    parameter n = 8;
    logic clk, reset, start;
    logic [n-1:0] A;
    reg [3:0] result;
    logic done;

    counter dut (.*);

    //set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

    initial begin
        reset<=1; start<=0; A<=8'b11001100; @(posedge clk);
        reset<=0;  @(posedge clk);
        start<=1; repeat(20) @(posedge clk);

        reset<=1; start<=0; A<=8'b00111100; @(posedge clk);
        reset<=0;  @(posedge clk);
        start<=1; repeat(20) @(posedge clk);
        $stop();
    end
endmodule