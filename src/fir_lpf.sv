//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: fir_lpf
// Description: Implements a 79-tap FIR LPF with cutoff 150KHz using tap symmetry to reduce 
//              multiplies to 39+1 instead of 79. Also decimates by a factor of 2.
//              TODO: time multiplex one multiplier. samples come in at 2 Mhz
//                    and go out at 1 MHz. You have 50 cycles to multiply, 50 > 40.
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module fir_lpf (
    input  logic               clk,
    input  logic               rst,

    input  logic               in_valid,
    input  logic signed [15:0] in,

    output logic               out_valid,
    output logic signed [15:0] out
);

    logic signed [15:0] coeff [0:39];
    logic signed [15:0] shift_reg [0:78];
    integer i;

    // Time-multiplexing
    logic [5:0] tap_idx; // 0..39
    logic processing;

    logic decim_phase;
    
    // for timing
    logic signed [16:0] sample_sum;
    logic signed [15:0] coeff_reg;
    logic signed [32:0] mult_reg;
    logic signed [39:0] acc_temp;

    // Initialize coefficients (same as before)
    initial begin
        coeff[0]  = 16'sd0;
        coeff[1]  = 16'sd1;
        coeff[2]  = 16'sd2;
        coeff[3]  = 16'sd3;
        coeff[4]  = 16'sd2;
        coeff[5]  = -16'sd1;
        coeff[6]  = -16'sd7;
        coeff[7]  = -16'sd14;
        coeff[8]  = -16'sd18;
        coeff[9]  = -16'sd17;
        coeff[10] = -16'sd7;
        coeff[11] = 16'sd12;
        coeff[12] = 16'sd38;
        coeff[13] = 16'sd60;
        coeff[14] = 16'sd69;
        coeff[15] = 16'sd53;
        coeff[16] = 16'sd9;
        coeff[17] = -16'sd59;
        coeff[18] = -16'sd131;
        coeff[19] = -16'sd182;
        coeff[20] = -16'sd182;
        coeff[21] = -16'sd113;
        coeff[22] = 16'sd23;
        coeff[23] = 16'sd199;
        coeff[24] = 16'sd362;
        coeff[25] = 16'sd447;
        coeff[26] = 16'sd398;
        coeff[27] = 16'sd187;
        coeff[28] = -16'sd163;
        coeff[29] = -16'sd575;
        coeff[30] = -16'sd921;
        coeff[31] = -16'sd1058;
        coeff[32] = -16'sd857;
        coeff[33] = -16'sd249;
        coeff[34] = 16'sd751;
        coeff[35] = 16'sd2028;
        coeff[36] = 16'sd3390;
        coeff[37] = 16'sd4601;
        coeff[38] = 16'sd5437;
        coeff[39] = 16'sd5735;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 79; i++)
                shift_reg[i] <= 0;

            tap_idx     <= 0;
            acc_temp    <= 0;
            processing  <= 0;
            decim_phase <= 0;
            out_valid   <= 0;
            out         <= 0;
        end
        else begin
            out_valid <= 0;

            // Shift in new sample
            if (in_valid) begin
                for (i = 78; i > 0; i--)
                    shift_reg[i] <= shift_reg[i-1];
                shift_reg[0] <= in;

                decim_phase <= ~decim_phase;

                // Start processing every 2nd input (1 MHz output)
                if (decim_phase) begin
                    tap_idx    <= 0;
                    acc_temp   <= 0;
                    processing <= 1;
                end
            end

            // Time-multiplexed MAC
            if (processing) begin
                if (tap_idx < 39) begin
                    sample_sum <= shift_reg[tap_idx] + shift_reg[78-tap_idx];
                    coeff_reg  <= coeff[tap_idx];
                    mult_reg   <= sample_sum * coeff_reg;
                    acc_temp   <= acc_temp + mult_reg;
                    tap_idx    <= tap_idx + 1;
                end
                else if (tap_idx == 39) begin
                    // center tap
                    mult_reg <= shift_reg[39] * coeff[39];
                    acc_temp <= acc_temp + mult_reg;
                    tap_idx  <= tap_idx + 1;
                end
                else begin
                    // all taps done, output result
                    out       <= acc_temp[30:15];
                    out_valid <= 1;
                    processing <= 0;
                end
            end
        end
    end

endmodule
