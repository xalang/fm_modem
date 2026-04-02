//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: fm_modem
// Description: FM modem.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module fm_demod (
    input logic clk,
    input logic rst,
    input logic signed [15:0] fm_in,
    output logic aud_pwm
);

    // LO
    logic [15:0] LO_cos, LO_sin;

    // Mixer
    logic [15:0] I_mixer_out, Q_mixer_out;

    // CIC decimator
    logic [15:0] I_cic_out, Q_cic_out;
    logic I_cic_out_valid, Q_cic_out_valid;

    // FIR LPF
    logic [15:0] I_fir_lpf_out, Q_fir_lpf_out;
    logic I_fir_lpf_out_valid, Q_fir_lpf_out_valid;

    // Quadrature phase detector
    logic [31:0] sin_out, cos_out;
    logic quad_pd_out_valid;

    // Cordic vector mode
    logic cordic_out_valid;
    logic signed [15:0] cordic_out;

    // audio lpf + decimation
    logic audio_lpf_out_valid;
    logic signed [15:0] audio_lpf_out;

    // Instantiations
    nco nco_inst (
        .clk(clk),
        .rst(rst),
        .cos_out(LO_cos),
        .sin_out(LO_sin)
    );

    mixer I_fm_to_BB_mixer (
        .in1(fm_in),
        .in2(LO_cos),
        .out(I_mixer_out)
    );

    mixer Q_fm_to_BB_mixer (
        .in1(fm_in),
        .in2(LO_sin),
        .out(Q_mixer_out)
    );

    cic_decim I_cic_decim_inst (
        .clk(clk),
        .rst(rst),
        .in(I_mixer_out),
        .out_valid(I_cic_out_valid),
        .out(I_cic_out)
    );

    cic_decim Q_cic_decim_inst (
        .clk(clk),
        .rst(rst),
        .in(Q_mixer_out),
        .out_valid(Q_cic_out_valid),
        .out(Q_cic_out)
    );

    fir_lpf I_fir_lpf_inst (
        .clk(clk),
        .rst(rst),
        .in_valid(I_cic_out_valid),
        .in(I_cic_out),
        .out_valid(I_fir_lpf_out_valid),
        .out(I_fir_lpf_out)
    );

    fir_lpf Q_fir_lpf_inst (
        .clk(clk),
        .rst(rst),
        .in_valid(Q_cic_out_valid),
        .in(Q_cic_out),
        .out_valid(Q_fir_lpf_out_valid),
        .out(Q_fir_lpf_out)
    );

    wire signed [15:0] Q_fir_lpf_out_neg;
    assign Q_fir_lpf_out_neg = -Q_fir_lpf_out;

    quadrature_phase_detector quadrature_phase_detector_inst (
        .clk(clk),
        .rst(rst),
        .in_valid(I_fir_lpf_out_valid),
        .I_in(I_fir_lpf_out),
        .Q_in(Q_fir_lpf_out),
        .sin_out(sin_out),
        .cos_out(cos_out),
        .out_valid(quad_pd_out_valid)
    );

    cordic_vector cordic_vector_inst (
        .clk(clk),
        .rst(rst),
        .in_valid(quad_pd_out_valid),
        .x_in(cos_out),
        .y_in(sin_out),
        .angle_out(cordic_out),
        .out_valid(cordic_out_valid)
    );

    audio_lpf audio_lpf_inst (
        .clk(clk),
        .rst(rst),
        .in(cordic_out),
        .in_valid(cordic_out_valid),
        .out(audio_lpf_out),
        .out_valid(audio_cordic_out_valid)
    );

    audio_pwm audio_pwm_inst (
        .clk(clk),
        .rst(rst),
        .in(audio_lpf_out),
        .in_valid(audio_cordic_out_valid),
        .pwm_out(aud_pwm)
    );

endmodule
