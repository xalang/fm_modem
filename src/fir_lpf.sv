`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Module Name: fir_lpf
// Description: FIR 79-tap LPF filter
//
//////////////////////////////////////////////////////////////////////////////////

module fir_lpf (
    input  logic               clk,       // 50 MHz system clock
    input  logic               rst,

    input  logic               in_valid,  // 2 MHz pulse (1 clk wide)
    input  logic signed [15:0] in,        // Q1.15 input

    output logic               out_valid, // 1 MHz pulse
    output logic signed [15:0] out        // Q1.15 output
);

    // ------------------------------------------------------------
    // Symmetric FIR coefficients (Q1.15)
    // only first half + center tap needed
    // ------------------------------------------------------------
    logic signed [15:0] coeff [0:39];

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
        coeff[39] = 16'sd5735; // center tap
    end

    // ------------------------------------------------------------
    // Delay line
    // ------------------------------------------------------------
    logic signed [15:0] shift_reg [0:78];

    integer i;
    logic decim_phase;

    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 79; i++)
                shift_reg[i] <= 0;

            decim_phase <= 0;
            out_valid   <= 0;
            out         <= 0;
        end
        else begin
            out_valid <= 0;

            if (in_valid) begin
                // Shift samples
                for (i = 78; i > 0; i--)
                    shift_reg[i] <= shift_reg[i-1];

                shift_reg[0] <= in;

                decim_phase <= ~decim_phase;

                // Output every 2nd sample
                if (decim_phase) begin
                    logic signed [39:0] acc_temp;
                    logic signed [16:0] pair_sum_temp;

                    acc_temp = 0;

                    for (i = 0; i < 39; i++) begin
                        pair_sum_temp = shift_reg[i] + shift_reg[78-i];
                        acc_temp += pair_sum_temp * coeff[i];
                    end

                    acc_temp += shift_reg[39] * coeff[39];

                    out <= acc_temp[30:15];
                    out_valid <= 1;
                end
            end
        end
    end

endmodule
