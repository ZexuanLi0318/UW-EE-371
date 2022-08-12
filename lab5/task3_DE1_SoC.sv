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

    // color: 1 = white
    logic pixel_color, pixel_write, pixel_write_, pixel_write_r;
    logic done;
    logic clk, reset, newreset, clear, clear_, newreset_, newreset_r;

    assign reset = ~KEY[0];
    assign clear = ~KEY[1];

    assign HEX0 = '1;
    assign HEX1 = '1;
    assign HEX2 = '1;
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
    assign LEDR = SW;

    logic [10:0] x0, y0, x1, y1, x, y;      // current coordinates
    logic [10:0] x0_, y0_, x1_, y1_;        // current drawing mode coords
    logic [10:0] x0_r, y0_r, x1_r, y1_r;    // current clear mode coords
    logic [11:0] xr;                        // counter for y-coord of drawing mode

    VGA_framebuffer fb (.clk50(CLOCK_50), .reset, .x, .y,
        .pixel_color, .pixel_write,
        .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
        .VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N)
    );

    line_drawer lines (
        .clk(CLOCK_50),
        .reset(reset | newreset),
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
        if (reset)
            xr <= 0;
        else
            xr <= xr + 1;
    end

    // FSM for drawing two lines
    enum {A, B, C, D} ps, ns;
    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            ps <= A;
        else
            ps <= ns;
    end

    always_comb begin
        case (ps)
            A: begin
                ns = B;
                x0_ = 130;
                y0_ = 140;
                x1_ = 280;
                y1_ = 100;
                newreset_ = 1;
                pixel_write_ = 0;
            end
            B: begin
                ns = C;
                x0_ = 130;
                y0_ = 140;
                x1_ = 280;
                y1_ = 100;
                newreset_ = 0;
                pixel_write_ = 1;
            end
            C: begin
                ns = D;
                x0_ = 100;
                y0_ = 100;
                x1_ = 200;
                y1_ = 200;
                newreset_ = 1;
                pixel_write_ = 0;
            end
            D: begin
                ns = A;
                x0_ = 100;
                y0_ = 100;
                x1_ = 200;
                y1_ = 200;
                newreset_ = 0;
                pixel_write_ = 1;
            end
        endcase
    end

    // FSM for clearing the screen (drawing vertical black lines)
    enum {E, F} psr, nsr;
    always_ff @(posedge clk2, posedge reset) begin
        if (reset)
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