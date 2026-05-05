//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: audio_lpf
// Description: Implements 63-tap symmetrical audio LPF with stopband 150KHz and 
//              decimation by factor of 40 to get output rate 25 KHz. Time multiplex
//              LPF to reduce DSP usage
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module audio_lpf (
    input  logic clk,
    input  logic rst,

    input  logic signed [15:0] in,
    input  logic in_valid,

    output logic signed [15:0] out,
    output logic out_valid
);

    // Shift register for past samples
    logic signed [15:0] shift_reg [0:63];
    
    // FIR coefficients (symmetric, 32 taps)
    logic signed [15:0] coeff [0:31];
    initial begin
        coeff[0]  = 16'sd6;
        coeff[1]  = 16'sd9;
        coeff[2]  = 16'sd14;
        coeff[3]  = 16'sd20;
        coeff[4]  = 16'sd28;
        coeff[5]  = 16'sd39;
        coeff[6]  = 16'sd54;
        coeff[7]  = 16'sd72;
        coeff[8]  = 16'sd95;
        coeff[9]  = 16'sd122;
        coeff[10] = 16'sd155;
        coeff[11] = 16'sd192;
        coeff[12] = 16'sd235;
        coeff[13] = 16'sd282;
        coeff[14] = 16'sd334;
        coeff[15] = 16'sd391;
        coeff[16] = 16'sd451;
        coeff[17] = 16'sd514;
        coeff[18] = 16'sd580;
        coeff[19] = 16'sd647;
        coeff[20] = 16'sd715;
        coeff[21] = 16'sd782;
        coeff[22] = 16'sd847;
        coeff[23] = 16'sd910;
        coeff[24] = 16'sd969;
        coeff[25] = 16'sd1023;
        coeff[26] = 16'sd1071;
        coeff[27] = 16'sd1113;
        coeff[28] = 16'sd1148;
        coeff[29] = 16'sd1174;
        coeff[30] = 16'sd1192;
        coeff[31] = 16'sd1201;
    end

    // Time-multiplexing signals
    logic [5:0] tap_idx;           // 0..31
    logic signed [39:0] acc_temp;  // accumulator
    logic processing;              // MAC in progress
    logic [5:0] dec_cnt;           // decimation counter

    logic signed [16:0] pair_sum_temp;

    // Registers for timing
    logic signed [16:0] pair_sum_temp_reg;
    logic signed [15:0] coeff_reg;
    logic signed [32:0] mult_reg;
    logic [5:0] tap_pipe_cnt;

    integer i;

    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 64; i++)
                shift_reg[i] <= 0;
            pair_sum_temp_reg <= 0;
            coeff_reg         <= 0;
            mult_reg          <= 0;
            acc_temp          <= 0;
            tap_idx           <= 0;
            processing        <= 0;
            dec_cnt           <= 0;
            out_valid         <= 0;
            out               <= 0;
            tap_pipe_cnt      <= 0;
        end
        else begin
            out_valid <= 0;

            // Shift new sample
            if (in_valid) begin
                for (i = 63; i > 0; i--)
                    shift_reg[i] <= shift_reg[i-1];
                shift_reg[0] <= in;

                // Start LPF process every 40 input samples
                if (dec_cnt == 39 && !processing) begin
                    dec_cnt    <= 0;
                    tap_idx    <= 0;
                    acc_temp   <= 0;
                    tap_pipe_cnt <= 0;
                    processing <= 1;
                end
                else begin
                    dec_cnt <= dec_cnt + 1;
                end
            end
            // LPF pipeline
            if (processing) begin
                // Stage 1: sum symmetric terms & register
                if (tap_idx < 31) begin
                    pair_sum_temp_reg <= shift_reg[tap_idx] + shift_reg[63 - tap_idx];
                    coeff_reg         <= coeff[tap_idx];
                    tap_idx           <= tap_idx + 1;
                end
                else if (tap_idx == 31) begin
                    // center tap
                    pair_sum_temp_reg <= shift_reg[31];
                    coeff_reg         <= coeff[31];
                    tap_idx           <= tap_idx + 1;
                end

                // Stage 2: multiply
                mult_reg <= pair_sum_temp_reg * coeff_reg;

                // Stage 3: accumulate
                acc_temp <= acc_temp + mult_reg;

                // Increment pipeline counter
                if (tap_pipe_cnt < 33) // 32 taps + 1 extra for center
                    tap_pipe_cnt <= tap_pipe_cnt + 1;

                // Output only after last MAC finishes
                if (tap_pipe_cnt == 33) begin
                    out       <= acc_temp[30:15] <<< 4; // scaling
                    out_valid <= 1;
                    processing <= 0;
                end
            end
        end
    end

 endmodule
