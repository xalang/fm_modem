`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2026 03:31:06 AM
// Design Name: 
// Module Name: fm_modem_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "fm_modem_params.vh"

module fm_modem_tb();

    logic signed [15:0] fm_samples [0:`NUM_FM_SAMPLES-1];

    initial begin
        $readmemh("fm_samples.mem",fm_samples);
    end

    logic clk;
    logic rst;
    logic start;

    logic [15:0] in;

    integer n;

    initial begin
        clk = 0;
        rst = 0;
        start = 0;
        n = 0;
        in = '0;
        repeat (2) @(posedge clk);
        rst = 1;
        repeat (2) @(posedge clk);
        rst = 0;
        start = 1;

    end

    // 50 MHz
    always #20 clk = ~clk;

    always @(posedge clk) begin
        if (start) begin
            in <= fm_samples[n];
            n <= n + 1;
        end
    end

    fm_modem fm_modem_inst (
        .clk(clk),
        .rst(rst),
        .fm_in(in)
    );

endmodule
