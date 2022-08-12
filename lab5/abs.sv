// this module calculates the absolute value of a-b
module abs #(parameter WIDTH = 11) (
  output logic [WIDTH-1:0] out,
  input logic [WIDTH-1:0] a, b
  );

  always_comb begin
    if (a > b)
      out = a - b;
    else
      out = b - a;
  end
endmodule