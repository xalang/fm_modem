//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/28/2026   
// Module Name: fir_interpolator
// Description: 63-tap polyphase FIR interpolator for audio upsampling
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module fir_interpolator (
    input  logic clk,                   // 50MHz system clock
    input  logic rst,
    input  logic signed [15:0] in,
    input  logic in_valid,
    output logic signed [15:0] out,
    output logic out_valid
);

    // ---------------------------
    // Compute output interval in clocks
    // ---------------------------
    logic [7:0] clk_count;
    logic toggle;
    wire sample_tick = (clk_count == (toggle ? 49 : 48));

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_count <= 0;
            toggle <= 0;
        end else if (clk_count == (toggle ? 49 : 48)) begin
            clk_count <= 0;
            toggle <= ~toggle;
        end else begin
            clk_count <= clk_count + 1;
        end
    end

    // ---------------------------
    // Polyphase FIR Coefficients
    // ---------------------------
    logic signed [15:0] coeffs [0:104] = '{
     100,    52,     0,   -58,  -126,  -206,  -300,  -411,  -538,  -684,
     -846, -1024, -1213, -1410, -1609, -1803, -1983, -2140, -2264, -2343,
    -2366, -2321, -2196, -1980, -1661, -1230,  -679,     0,   811,  1756,
     2836,  4049,  5388,  6847,  8413, 10075, 11816, 13618, 15460, 17321,
    19178, 21005, 22780, 24476, 26070, 27539, 28860, 30015, 30985, 31755,
    32314, 32653, 32767, 32653, 32314, 31755, 30985, 30015, 28860, 27539,
    26070, 24476, 22780, 21005, 19178, 17321, 15460, 13618, 11816, 10075,
     8413,  6847,  5388,  4049,  2836,  1756,   811,     0,  -679, -1230,
    -1661, -1980, -2196, -2321, -2366, -2343, -2264, -2140, -1983, -1803,
    -1609, -1410, -1213, -1024,  -846,  -684,  -538,  -411,  -300,  -206,
     -126,   -58,     0,    52,   100
};

    // ---------------------------
    // Input sample shift register
    // ---------------------------
    logic signed [15:0] x_reg [0:4];
    integer i;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0;i<5;i=i+1) x_reg[i] <= 0;
        end else if (in_valid) begin
            for (i=4;i>0;i=i-1)
                x_reg[i] <= x_reg[i-1];
            x_reg[0] <= in;
        end
    end

    // ---------------------------
    // Phase counter for polyphase
    // ---------------------------
    logic [4:0] phase_cnt;
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            phase_cnt <= 0;
        else if (sample_tick) begin
            if (phase_cnt == 20)
                phase_cnt <= 0;
            else
                phase_cnt <= phase_cnt + 1;
        end
    end

    // ---------------------------
    // FIR accumulator
    // ---------------------------

    // Stage 1: multiply
    logic signed [31:0] m0, m1, m2, m3, m4;
    logic [4:0] phase_d1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            m0 <= 0;
            m1 <= 0;
            m2 <= 0;
            m3 <= 0;
            m4 <= 0;

        end else if (sample_tick) begin
            phase_d1 <= phase_cnt;
            m0 <= x_reg[0] * coeffs[phase_cnt];
            m1 <= x_reg[1] * coeffs[phase_cnt+21];
            m2 <= x_reg[2] * coeffs[phase_cnt+42];
            m3 <= x_reg[3] * coeffs[phase_cnt+63];
            m4 <= x_reg[4] * coeffs[phase_cnt+84];
        end
    end

    // Stage 2: accumulate
    logic signed [35:0] acc_reg;

    always_ff @(posedge clk) begin
        acc_reg <= m0 + m1 + m2 + m3 + m4;
    end

    // Stage 3: saturate
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 0;
            out_valid <= 0;
        end else begin
            if ((acc_reg >>> 15) > 32767)
                out <= 16'sh7FFF;
            else if ((acc_reg >>> 15) < -32768)
                out <= -16'sh8000;
            else
                out <= acc_reg >>> 15;

            out_valid <= sample_tick;
        end
    end

endmodule
