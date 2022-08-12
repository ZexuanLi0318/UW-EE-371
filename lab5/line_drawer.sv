/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *	 x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 * Outputs:
 *   x 		- x coordinate of the pixel to color
 *   y 		- y coordinate of the pixel to color
 *   done	- flag that line has finished drawing
 *
 */
module line_drawer(clk, reset, x0, y0, x1, y1, x, y, done);
	input logic clk, reset;
	input logic [10:0]	x0, y0, x1, y1;
	output logic done;
	output logic [10:0]	x, y;
	
	/* You'll need to create some registers to keep track of things
	 * such as error and direction.
	 */
	logic signed [10:0] error;  // example - feel free to change/delete
	logic is_steep;							// boolean 
  	logic [10:0] abs_y, abs_x;				// absolute value 
  	logic [10:0] x0_0, x1_0, y0_0, y1_0; 	// swap value if is_sleep
  	logic [10:0] x0_1, x1_1, y0_1, y1_1;	// swap value if x0>x1
  	logic signed [10:0] dx, dy;				// delta value
  	logic signed [10:0] y_step;
  	logic signed [10:0] x_, y_;
  	logic [3:0] tst;
  	logic done0, done1;

	// get is_steep
  	abs ABSY (.out(abs_y), .a(y1), .b(y0));
  	abs ABSX (.out(abs_x), .a(x1), .b(x0));
  	assign is_steep = (abs_y > abs_x);

  	// if (is_steep) then swap(x0,y0) swap(x1,y1)
  	always_comb begin
    	if (is_steep) begin
      		x0_0 = y0;
      		y0_0 = x0;
      		x1_0 = y1;
      		y1_0 = x1;
    	end else begin
      		x0_0 = x0;
      		y0_0 = y0;
      		x1_0 = x1;
      		y1_0 = y1;
    	end
  	end

  	// if (x0 > x1) then swap(x0, x1) swap(y0, y1)
  	always_comb begin
    	if (x0_0 > x1_0) begin
      		x0_1 = x1_0;
      		x1_1 = x0_0;
      		y0_1 = y1_0;
      		y1_1 = y0_0;
    	end else begin
      		x0_1 = x0_0;
      		x1_1 = x1_0;
      		y0_1 = y0_0;
      		y1_1 = y1_0;
    	end
  	end

  	// get deltax and deltay
  	assign dx = x1_1 - x0_1;
  	abs #(11) ABSDY (.out(dy), .a(y1_1), .b(y0_1));

  	// get y_step
  	always_comb begin
    	if (y0_1 < y1_1)
      		y_step = 1;
    	else
      		y_step = -1;
  	end

	always_ff @(posedge clk) begin
		// YOUR CODE HERE
		//done1 <= done0;
    	if (reset) begin
     		// for loop initializing
      		x_ <= x0_1;
      		y_ <= y0_1;
      		tst <= 0;
      		error <= -(dx/2);
      		done0 <= 0;
      		done1 <= 0;
    	end else if (x_ < (x1_1 + 1)) begin
      		// in the loop
      		done1 <= done0;
      		x_ <= x_ + 1;
      		if (is_steep) begin
        		x <= y_;
        		y <= x_;
      		end else begin
        		x <= x_;
       		 	y <= y_;
      		end
      		if ((error + dy) >= 1) begin
        		tst <= tst + 1;
        		y_ <= y_ + y_step;
        		error <= error + dy - dx;
      		end else begin
        		y_ <= y_;
        		error <= error + dy;
      		end
    	end	else begin
      		// finished the loop, drawing job done
      		done0 <= 1;
      		done1 <= done0;
    	end
	end  // always_ff
	
	assign done = done0 ^ done1;

endmodule  // line_drawer


module line_drawer_testbench();
  logic clk, reset;
  logic [10:0]	x0, y0, x1, y1;
  logic [10:0]	x, y;
  logic done;

  line_drawer dut (.*);

  parameter CLOCK_PERIOD = 300;
  initial begin
    clk <= 0;
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
  end

  integer i;
  initial begin
    //reset <= 1; x0 <= 11'd0; y0 <= 11'd0; x1 <= 11'd4;  y1  <= 11'd4;
    //reset <= 1; x0 <= 11'd1; y0 <= 11'd1; x1 <= 11'd12;  y1  <= 11'd5;
    //reset <= 1; x1 <= 11'd1; y1 <= 11'd1; x0 <= 11'd12;  y0  <= 11'd5;
    reset <= 1; x0 <= 11'd1; y0 <= 11'd1; x1 <= 11'd1;  y1  <= 11'd5;
    @(posedge clk);
    reset <= 0;
    for (i = 0; i < 6; i++)
    @(posedge clk);

    reset <= 1; x0 <= 11'd1; y0 <= 11'd1; x1 <= 11'd12;  y1  <= 11'd5;
    @(posedge clk);
    reset <= 0;
    for (i = 0; i < 12 + 2; i++)
    @(posedge clk);
    
	$stop();
  end
endmodule