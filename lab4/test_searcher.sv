`timescale 1 ps / 1 ps

module test_searcher (
  // searcher top module. Instantiate controller and datapath.
  // use a wizard-generated RAM to store content to be searched.

  output logic found, done,
  output logic [4:0] addr,
  input logic [7:0] target,
  input logic clk, reset, start
  );

  logic [7:0] curr_data;
  logic [4:0] new_addr;  // (p1 + p2) / 2
  logic [4:0] p1, p2;  // pointers specifying search range

  // control signals
  logic init_all, update_addr, set_p1, set_p2, set_found, set_done;

  searcher_controller C (.*);
  searcher_datapath D (.*);

  ram32x8 RAM (
    .q(curr_data),
    .address(new_addr),
    .clock(clk),
    .data(),
    .wren(1'b0)
  );

endmodule

module searcher_controller (
  // implemented using a 4-state FSM.

  output logic init_all, update_addr, set_p1, set_p2, set_found, set_done,
  input logic [7:0] target,
  input logic [7:0] curr_data,
  input logic [4:0] p1, p2,
  input logic clk, reset, start
  );

  enum {IDLE, LOOP, WAIT, DONE} ps, ns;

  always_ff @(posedge clk) begin
    if (reset)
      ps <= IDLE;
    else
      ps <= ns;
  end

  always_comb begin
    case (ps)
      IDLE: ns = start ? LOOP : IDLE;
      LOOP: ns = (p1 > p2) ? DONE : WAIT;
      WAIT: ns = (curr_data == target) ? DONE : LOOP;
      DONE: ns = start ? DONE : IDLE;
    endcase
    // assign control signals
    init_all = (ps == IDLE);
    update_addr = (ps == LOOP);
    set_p1 = (ps == LOOP) & (curr_data < target);
    set_p2 = (ps == LOOP) & (curr_data > target);
    set_found = (ps == LOOP) & (curr_data == target);
    set_done = (ps == DONE);
  end
endmodule

module searcher_datapath (
  output logic [4:0] p1, p2, addr,
  output logic found, done,
  output logic [4:0] new_addr,
  input logic init_all, update_addr, set_p1, set_p2, set_found, set_done,
  input logic clk
  );

  assign new_addr = (p1 + p2) / 2;

  always_ff @(posedge clk) begin
    if (init_all) begin
      p1 <= 5'd0;
      p2 <= 5'd31;
      addr <= 5'd0;
      done <= 0;
      found <= 0;
    end
    if (update_addr)
      addr <= new_addr;
    if (set_p1)
      p1 <= new_addr + 1;
    if (set_p2)
      p2 <= new_addr - 1;
    if (set_found)
      found <= 1;
    if (set_done)
      done <= 1;
  end
endmodule

module test_searcher_testbench ();
  logic found, done;
  logic [4:0] addr;
  logic [7:0] target;
  logic clk, reset, start;

  test_searcher dut (.*);

  parameter CLOCK_PERIOD = 100;
  initial begin
    clk <= 0;
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
  end

  integer i;
  initial begin
    reset <= 1; @(posedge clk);
    reset <= 0; target <= 8'd5; start <= 1; @(posedge clk);
    for (i = 0; i < 32; i++)
      @(posedge clk);
    $stop();
  end
endmodule