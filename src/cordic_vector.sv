//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: cordic_vector
// Description: Implements vectoring mode cordic algorithm for arctan calculcation
//              using shift-add logic. Algorithm iterates 16 times.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module cordic_vector (
    input  logic clk,
    input  logic rst,
    input  logic in_valid,

    input  logic signed [31:0] x_in,   // cos(theta) Q1.15
    input  logic signed [31:0] y_in,   // sin(theta) Q1.15

    output logic signed [15:0] angle_out,
    output logic out_valid
);

    logic signed [32:0] x, y, z; //1 extra bit for safety
    logic [4:0] iter;

    // 16-iteration atan table in Q2.30
    logic signed [31:0] atan_table [0:15];
    
    initial begin
        atan_table[0]  = 32'sd843314857;   // atan(2^0)  ≈ 0.785398 rad
        atan_table[1]  = 32'sd497837829;   // atan(2^-1) ≈ 0.463648 rad
        atan_table[2]  = 32'sd262464144;   // atan(2^-2) ≈ 0.244978 rad
        atan_table[3]  = 32'sd133657454;   // atan(2^-3) ≈ 0.124355 rad
        atan_table[4]  = 32'sd67115904;    // atan(2^-4) ≈ 0.062419 rad
        atan_table[5]  = 32'sd33554533;    // atan(2^-5) ≈ 0.031240 rad
        atan_table[6]  = 32'sd16777273;    // atan(2^-6) ≈ 0.015624 rad
        atan_table[7]  = 32'sd8388608;     // atan(2^-7) ≈ 0.007812 rad
        atan_table[8]  = 32'sd4194304;     // atan(2^-8) ≈ 0.003906 rad
        atan_table[9]  = 32'sd2097152;     // atan(2^-9) ≈ 0.001953 rad
        atan_table[10] = 32'sd1048576;     // atan(2^-10) ≈ 0.000977 rad
        atan_table[11] = 32'sd524288;      // atan(2^-11) ≈ 0.000488 rad
        atan_table[12] = 32'sd262144;      // atan(2^-12) ≈ 0.000244 rad
        atan_table[13] = 32'sd131072;      // atan(2^-13) ≈ 0.000122 rad
        atan_table[14] = 32'sd65536;       // atan(2^-14) ≈ 0.000061 rad
        atan_table[15] = 32'sd32768;       // atan(2^-15) ≈ 0.000031 rad
    end
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            x <= 0;
            y <= 0;
            z <= 0;
            iter <= 0;
            out_valid <= 0;
            angle_out <= 0;
        end
        else begin
            out_valid <= 0;

            // Start new vectoring operation
            if (in_valid && iter == 0) begin
                x <= x_in;
                y <= y_in;

                z <= 0;
                iter <= 1;
            end
            // Iterative CORDIC vectoring
            else if (iter != 0 && iter < 16) begin
                if (y >= 0) begin

                    //rotate CW
                    x <= x + (y >>> (iter-1));
                    y <= y - (x >>> (iter-1));
                    z <= z + atan_table[iter-1];
                end
                else begin

                    //rotate CCW
                    x <= x - (y >>> (iter-1));
                    y <= y + (x >>> (iter-1));
                    z <= z - atan_table[iter-1];
                end

                iter <= iter + 1;

            // Final output
            end else if (iter == 16) begin
                angle_out <= z[30:15];
                out_valid <= 1;
                iter <= 0;
            end
        end
    end

endmodule
