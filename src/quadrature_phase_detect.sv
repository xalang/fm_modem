`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: quadrature_phase_detector
// Description: Quadrature phase difference detection for FM demodulation.
// Implements the equations: sin{phi(n) - phi(n-1)}, cos{phi(n) - phi(n-1)}
//////////////////////////////////////////////////////////////////////////////////

module quadrature_phase_detector (
    input  logic              clk,
    input  logic              rst,
    input  logic              in_valid, // 1 MHz
    input  logic signed [15:0] I_in,
    input  logic signed [15:0] Q_in,
    // keep outputs Q2.30 for precision
    output logic signed [31:0] sin_out,
    output logic signed [31:0] cos_out,
    output logic               out_valid
);

    // -----------------------------------------
    // 1 cycle delayed samples
    // -----------------------------------------
    logic signed [15:0] I_in_d;
    logic signed [15:0] Q_in_d;

    logic signed [31:0] mult1, mult2, mult3, mult4;

    assign mult1 = $signed(Q_in) * $signed(I_in_d);
    assign mult2 = $signed(I_in) * $signed(Q_in_d);
    assign mult3 = $signed(I_in) * $signed(I_in_d);
    assign mult4 = $signed(Q_in) * $signed(Q_in_d);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            I_in_d      <= 0;
            Q_in_d      <= 0;
            sin_out     <= 0;
            cos_out     <= 0;
            out_valid   <= 0;
        end else begin
            if (in_valid) begin
                // Phase detector calculation
                sin_out   <= mult1 - mult2;
                cos_out   <= mult3 + mult4;
                out_valid <= 1;
            end else
                out_valid <= 0;
            
            // Update delay
            I_in_d <= I_in;
            Q_in_d <= Q_in;
        end
    end

endmodule
