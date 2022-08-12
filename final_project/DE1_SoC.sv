// this is the top-level module of lab6
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;

	// card input and control signals
	logic [4:0] card;
	logic [3:0] card_1, card_0;
	assign card = {SW[9], SW[8], SW[7], SW[6], SW[5]};
	assign card_1 = card / 10;
	assign card_0 = card % 10;

	seg7 HEX_display1 (.bcd(card_1), .leds(HEX1));
	seg7 HEX_display0 (.bcd(card_0), .leds(HEX0));
	assign HEX2 = '1;

	logic win, tie, lose;

    game blackjack(
	.RST_N(SW[0]),
	.CLK(CLOCK_50),
	.HIT_I(SW[1]),
	.STAY_I(SW[2]),
	.CARD_I(card),	
	.WIN_O(win),
	.TIE_O(tie),
	.LOSE_O(lose)	
    );

	seg7 HEXwin (.bcd({3'd0, win}), .leds(HEX5));
	seg7 HEXtie (.bcd({3'd0, tie}), .leds(HEX4));
	seg7 HEXlose (.bcd({3'd0, lose}), .leds(HEX3));

// VGA display
// edited and copied from lab5
	// color: 1 = white
    logic pixel_color, pixel_write, pixel_write_, pixel_write_r;
    logic done;
    logic clk, VGAreset, newreset, clear, clear_, newreset_, newreset_r;

    assign VGAreset = ~KEY[0];
    assign clear = ~KEY[1];
	logic [10:0] x0, y0, x1, y1, x, y;      // current coordinates
    logic [10:0] x0_, y0_, x1_, y1_;        // current drawing mode coords
    logic [10:0] x0_r, y0_r, x1_r, y1_r;    // current clear mode coords
    logic [11:0] xr;                        // counter for y-coord of drawing mode

    VGA_framebuffer fb (.clk50(CLOCK_50), .reset(VGAreset), .x, .y,
        .pixel_color, .pixel_write,
        .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
        .VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N)
    );

    line_drawer lines (
        .clk(CLOCK_50),
        .reset(VGAreset | newreset),
        .x0, .y0, .x1, .y1, .x, .y,
        .done
    );

    // clock divider
    logic [31:0] divided_clk;
    clock_divider getCLK (
        .clock(CLOCK_50),
        .divided_clocks(divided_clk)
    );
    assign clk = divided_clk[26];
    assign clk2 = divided_clk[14];

    // counter register for y-coord in drawing mode.
    always_ff @(posedge clk2) begin
        if (VGAreset)
            xr <= 0;
        else
            xr <= xr + 1;
    end

    // FSM for drawing lines
    enum {A, B, C, D, b1, b2, b3, b4, j1, j2, j3, j4, j5, j6} ps, ns;
    always_ff @(posedge clk, posedge VGAreset) begin
        if (VGAreset)
            ps <= A;
        else
            ps <= ns;
    end

    always_comb begin
        case (ps)
            A: begin
                ns = B;
                x0_ = 0;
                y0_ = 0;
                x1_ = 0;
                y1_ = 0;
                newreset_ = 1;
                pixel_write_ = 0;
            end
            B: begin
                ns = C;
                x0_ = 0;
                y0_ = 100;
                x1_ = 0;
                y1_ = 0;
                newreset_ = 0;
                pixel_write_ = 1;
            end
            C: begin
                ns = D;
                x0_ = 0;
                y0_ = 50;
                x1_ = 50;
                y1_ = 0;
                newreset_ = 1;
                pixel_write_ = 0;
            end
            D: begin
                ns = b1;
                x0_ = 50;
                y0_ = 50;
                x1_ = 50;
                y1_ = 50;
                newreset_ = 0;
                pixel_write_ = 1;
            end
            b1: begin
                ns = b2;
                x0_ = 200;
                y0_ = 50;
                x1_ = 50;
                y1_ = 50;
                newreset_ = 1;
                pixel_write_ = 0;
            end
            b2: begin
                ns = b3;
                x0_ = 0;
                y0_ = 100;
                x1_ = 0;
                y1_ = 0;
                newreset_ = 0;
                pixel_write_ = 1;
            end
            b3: begin
                ns = b4;
                x0_ = 50;
                y0_ = 100;
                x1_ = 100;
                y1_ = 50;
                newreset_ = 1;
                pixel_write_ = 0;
            end
            b4: begin
                ns = j1;
                x0_ = 0;
                y0_ = 0;
                x1_ = 0;
                y1_ = 100;
                newreset_ = 0;
                pixel_write_ = 1;
            end
            j1: begin
                ns = j2;
                x0_ = 0;
                y0_ = 200;
                x1_ = 200;
                y1_ = 0;
                newreset_ = 1;
                pixel_write_ = 0;
            end
            j2: begin
                ns = j3;
                x0_ = 0;
                y0_ = 300;
                x1_ = 300;
                y1_ = 0;
                newreset_ = 0;
                pixel_write_ = 1;
            end
            j3: begin
                ns = j4;
                x0_ = 0;
                y0_ = 150;
                x1_ = 0;
                y1_ = 150;
                newreset_ = 1;
                pixel_write_ = 0;
            end
            j4: begin
                ns = j5;
                x0_ = 100;
                y0_ = 150;
                x1_ = 0;
                y1_ = 0;
                newreset_ = 0;
                pixel_write_ = 1;
            end
            j5: begin
                ns = j6;
                x0_ = 100;
                y0_ = 150;
                x1_ = 100;
                y1_ = 50;
                newreset_ = 1;
                pixel_write_ = 0;
            end
            j6: begin
                ns = A;
                x0_ = 100;
                y0_ = 120;
                x1_ = 0;
                y1_ = 100;
                newreset_ = 0;
                pixel_write_ = 1;
            end
        endcase
    end

    // FSM for clearing the screen (drawing vertical black lines)
    enum {E, F} psr, nsr;
    always_ff @(posedge clk2, posedge VGAreset) begin
        if (VGAreset)
            psr <= E;
        else
            psr <= nsr;
    end

    always_comb begin
        case (psr)
            E: begin
                nsr = F;
                x0_r = xr[11:1];
                y0_r = 0;
                x1_r = xr[11:1];
                y1_r = 480;
                newreset_r = 1;
                pixel_write_r = 0;
            end
            F: begin
                nsr = E;
                x0_r = xr[11:1];
                y0_r = 0;
                x1_r = xr[11:1];
                y1_r = 480;
                newreset_r = 0;
                pixel_write_r = 1;
            end
        endcase
    end

    // select clear mode or drawing mode
    always_comb begin
        if (~clear) begin
            x0 = x0_;
            y0 = y0_;
            x1 = x1_;
            y1 = y1_;
            pixel_color = 1'b1;
            newreset = newreset_;
            pixel_write = pixel_write_;
        end else begin
            x0 = x0_r;
            y0 = y0_r;
            x1 = x1_r;
            y1 = y1_r;
            pixel_color = 1'b0;
            newreset = newreset_r;
            pixel_write = pixel_write_r;
        end
    end

endmodule

