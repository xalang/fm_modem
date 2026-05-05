//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: cic_decim
// Description: Implements a 3-stage 25x CIC decimator 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module cic_decim (
    input  logic                        clk,
    input  logic                        rst,
    input  logic signed [15:0]          in,
    output logic                        out_valid,
    output logic signed [15:0]          out
);

    // Integrators (50MHz)
    // Use 64 bits because there is risk of overflow when input has non-0 DC
    logic signed [63:0] integrator [0:2];
    integer i;

    // Register for timing
    logic signed [15:0] in_reg;
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            in_reg <= 0;
        else
            in_reg <= in;
    end

    // Accept sample into integrator stage every cycle and accumulate
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 3; i++)
                integrator[i] <= '0;
        end else begin
            integrator[0] <= integrator[0] + in_reg;
            for (i = 1; i < 3; i++)
                integrator[i] <= integrator[i] + integrator[i-1];
        end
    end

    // Decimation counter (50/25 = 2MHz)
    logic [4:0] dec_cnt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            dec_cnt      <= 0;
        end else begin
            if (dec_cnt == 24) begin
                dec_cnt      <= 0;
            end else begin
                dec_cnt <= dec_cnt + 1;
            end
        end
    end

    // Comb stages (2MHz)
    // Operate comb stage on decimated frequency to reduce storage requirements
    // (So dont need to store past 25 samples)
    logic signed [63:0] comb_delay [0:2];
    logic signed [63:0] comb_out   [0:2];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 3; i++) begin
                comb_delay[i] <= 0;
                comb_out[i]   <= 0;
            end
        end else if (dec_cnt == 24) begin // every 25 cycles, push integrator stage output into comb stage
            comb_out[0]   <= integrator[2] - comb_delay[0];
            comb_delay[0] <= integrator[2];
            for (i = 1; i < 3; i++) begin
                comb_out[i]   <= comb_out[i-1] - comb_delay[i];
                comb_delay[i] <= comb_out[i-1];
            end
        end
    end

    // Output scaling due to CIC gain - divides by 2^14
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            out <= 0;
        else if (dec_cnt == 24) begin
            out <= comb_out[2] >>> 14;
            out_valid <= 1;
        end else
            out_valid <= 0;
    end

endmodule
