// this is a binary search algorithm module for task 2
`timescale 1 ps / 1 ps
module searcher(A, found, done, loc, clk, reset, start);
    input   logic [7:0] A;
    input   logic       clk, reset, start;
    output  logic       found, done;
    output  logic [4:0] loc;

    logic [7:0] curr_data;
    logic [4:0] ptr1, ptr2; // range pointers
    logic [4:0] new_addr;   // = (ptr1 + ptr2) / 2
    logic init_all, update_addr, set_ptr1, set_ptr2, set_found, set_done;

//control logic
    enum logic [1:0] {IDLE=2'b00, LOOP=2'b01, WAIT=2'b10, DONE=2'b11} ps, ns;

    // FSM logic
    always_comb begin
        case (ps)
            IDLE: ns = start ? LOOP : IDLE;
            LOOP: ns = (ptr1 > ptr2) ? DONE : WAIT;
            WAIT: ns = (curr_data == A) ? DONE : LOOP;
            DONE: ns = start ? DONE : IDLE;
        endcase
    end

    // ps dff
    always_ff @(posedge clk) begin
        if (reset)
            ps <= IDLE;
        else
            ps <= ns;
    end


    // FSM state outputs
    assign init_all = (ps == IDLE);
    assign update_addr = (ps == LOOP);
    assign set_ptr1 = (ps == LOOP) & (curr_data < A);
    assign set_ptr2 = (ps == LOOP) & (curr_data > A);
    assign set_found = (ps == LOOP) & (curr_data == A);
    assign set_done = (ps == DONE);
    
//datapath logic
    assign new_addr = (ptr1 + ptr2) / 2;

    always_ff @(posedge clk) begin
        if (init_all) begin
            ptr1 <= 5'd0;
            ptr2 <= 5'd31;
            loc <= 5'd0;
            done <= 0;
            found <= 0;
        end
        if (update_addr)
            loc <= new_addr;
        if (set_ptr1)
            ptr1 <= new_addr + 1;
        if (set_ptr2)
            ptr2 <= new_addr - 1;
        if (set_found)
            found <= 1;
        if (set_done)
            done <= 1;
    end


    ram32x8 RAM (.address(new_addr),
	.clock(clk),
	.data(),
	.wren(1'b0),
	.q(curr_data));

endmodule

module searcher_testbench ();
    logic [7:0] A;
    logic       clk, reset, start;
    logic       found, done;
    logic [4:0] loc;

    searcher dut (.*);

    //  set up the clock
    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    initial begin
        reset <= 1; @(posedge clk);
        reset <= 0; start <= 1; A <= 8'd5;  repeat(20) @(posedge clk);
        $stop();
    end

endmodule