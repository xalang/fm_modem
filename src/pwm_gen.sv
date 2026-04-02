//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: pwm_gen
// Description: Converts q1.15 audio samples to PWM audio @ 97 KHz (%0 MHz/ 2^9 counter). 
//              Audio is encode in the widths of the pulse: > 50% duty = +ve voltage, <50% = -ve.
//              The 97KHz represents how fast the period of the pwm cycles are, but 
//              audio is the moving average of those pwm samples.
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


module audio_pwm (
    input  logic clk,
    input  logic rst,

    input  logic signed [15:0] in,
    input  logic in_valid,

    output logic pwm_out
);

    logic signed [15:0] sample_reg;
    logic signed [8:0]  sample_short;
    logic [8:0] pwm_level;
    logic [8:0] pwm_counter;

    // Hold latest audio sample
    always_ff @(posedge clk) begin
        if (rst)
            sample_reg <= 0;
        else if (in_valid)
            sample_reg <= in;
    end

    // Reduce Q1.15 -> 9-bit signed
    // take 9 bits -> -256 to 256 range
    assign sample_short = sample_reg[15:7];

    // Convert signed -> unsigned for PWM
    // add 256 to make range 0->512
    assign pwm_level = sample_short + 9'd256;

    // 9-bit PWM counter
    always_ff @(posedge clk) begin
        if (rst)
            pwm_counter <= 0;
        else
            pwm_counter <= pwm_counter + 1;
    end

    // PWM comparator
    always_ff @(posedge clk) begin
        if (rst)
            pwm_out <= 0;
        else
            pwm_out <= (pwm_counter < pwm_level);
    end

endmodule
