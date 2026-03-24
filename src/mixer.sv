module mixer (
    input  logic signed [15:0] in1,   // Q1.15 input 1
    input  logic signed [15:0] in2,   // Q1.15 input 2
    output logic signed [15:0] out    // Q1.15 output
);

    // Internal 32-bit product to avoid overflow
    logic signed [31:0] product;

    always_comb begin
        // Multiply two Q1.15 numbers
        product = in1 * in2;

        // Scale back to Q1.15 by shifting right 15 bits
        out = product[30:15]; 
    end

endmodule
