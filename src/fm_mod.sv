//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: fm_mod
// Description: Implements an FM modulator 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module fm_mod (
    input  logic        clk,
    input  logic        rst,
    input  logic        audio_in_valid,
    input  logic signed [15:0] audio_in, // Q1.15 input (~1 MHz)
    output logic signed [15:0] fm_out // Q1.15 output
);

    // Parameters
    localparam int FS        = 50_000_000;     // system clock
    localparam int FC        = 10_700_000;     // carrier frequency
    localparam int FD        = 75_000;         // FM deviation
    localparam int LUT_BITS  = 12;             // 4096-entry cosine LUT
    localparam int PHASE_WIDTH = 32;           // phase accumulator width

    // Precompute base phase increment for carrier: freq_inc_base = FC * 2^PHASE_WIDTH / FS
    localparam logic [PHASE_WIDTH-1:0] FREQ_INC_BASE = (FC * 64'd4294967296) / FS;

    // Phase accumulator and frequency increment
    logic [PHASE_WIDTH-1:0] phase_acc;
    logic [PHASE_WIDTH-1:0] freq_inc;

    // Cos LUT
    logic [LUT_BITS-1:0] lut_addr;
    logic signed [15:0] cos_val;

    cos_lut cos_table (
        .addr(lut_addr),
        .data(cos_val)
    );

    // Compute phase increment with modulation
    // Q1.15 input scaled to deviation: delta = (FD * audio_in) / 32768
    always_comb begin
        logic signed [31:0] delta;  // extra width to prevent overflow
        if (rst)
            freq_inc = 0;
        else if (audio_in_valid) begin
            delta = (FD * audio_in) >>> 15; // Q1.15 scaling
            freq_inc = FREQ_INC_BASE + delta * (64'd429496729 / FS);
        end
    end

    // Phase accumulator and LUT mapping
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            phase_acc <= 0;
            fm_out <= 0;
            lut_addr <= 0;
        end else begin
            phase_acc <= phase_acc + freq_inc;
            lut_addr <= phase_acc[PHASE_WIDTH-1 -: LUT_BITS];
            fm_out <= cos_val;
        end
    end

endmodule
