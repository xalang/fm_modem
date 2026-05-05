//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: fm_modem
// Description: FM modem top
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module fm_modem (
    input  logic clk,       // 50 MHz clock
    input  logic rst,       // reset button / switch
    input  logic signed [15:0] audio_sample,
    input  logic audio_sample_valid,
    output logic s_axis_tready,
    output logic aud_pwm,    // PWM audio output
    output logic aud_sd
);
    assign aud_sd = 1;

    logic [21:0] sample_addr;
    logic signed [15:0] sample, interp_audio_sample;
    logic sample_valid,interp_audio_sample_valid;

    logic signed [15:0] fm_sample;
    // =========================================================
    // interpolate input audio samples to ~1MHz
    // =========================================================

    fir_interpolator fir_interpolator_inst (
        .clk(clk),
        .rst(rst),
        .in(audio_sample),
        .in_valid(audio_sample_valid),
        .s_axis_tready(s_axis_tready),
        .out(interp_audio_sample),
        .out_valid(interp_audio_sample_valid)
    );
    
    // =========================================================
    // FM Modem
    // =========================================================
    fm_mod fm_mod_inst (
       .clk(clk),
       .rst(rst),
       .audio_in_valid(interp_audio_sample_valid),
       .audio_in(interp_audio_sample),
       .fm_out(fm_sample)
    );

    fm_demod fm_demod_inst (
        .clk(clk),
        .rst(rst),
        .fm_in(fm_sample),
        .aud_pwm(aud_pwm)
    );


endmodule
