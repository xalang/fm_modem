//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: nco
// Description: Implements an NCO for generating Q1.15 samples of 10.7MHz sin & cos
//              with 50MHz sample rate.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module nco (
    input  logic clk,
    input  logic rst,
    output logic signed [15:0] cos_out,
    output logic signed [15:0] sin_out
);

    localparam logic [31:0] PHASE_INC = 32'd919123001;
    
    logic [31:0] phase_acc;
    
    logic [11:0] cos_addr;
    logic [11:0] sin_addr;
    
    // Registers for timing
    logic signed [15:0] cos_out_reg,sin_out_reg;

    // Increment phases
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            phase_acc <= 32'd0;
            cos_out <= 0;
            sin_out <= 0;
        end else begin
            phase_acc <= phase_acc + PHASE_INC;
            cos_out <= cos_out_reg;
            sin_out <= sin_out_reg;
        end
    end
    
    // Top 12 bits for address (rest for resolution
    assign cos_addr = phase_acc[31:20];
    assign sin_addr = phase_acc[31:20] + 12'd1024; // 90 deg out of phase
    
    cos_lut cos_lut (
        .addr(cos_addr),
        .data(cos_out_reg)
    );
    
    cos_lut sin_lut (
        .addr(sin_addr),
        .data(sin_out_reg)
    );

endmodule
