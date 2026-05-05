//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: sample_rom
// Description: Top TB
//
//////////////////////////////////////////////////////////////////////////////////

module top_tb;

    logic clk;
    logic rst;
    logic pwm_out;
    logic pwm_sd;


    // Sample ROM
    logic signed [15:0] sample;
    logic sample_valid;
    sample_rom rom_inst (
        .clk(clk),
        .rst(rst),
        .data_valid(sample_valid),
        .data(sample)
    );

    fm_modem dut (
        .clk(clk),
        .rst(rst),
        .audio_sample(sample),
        .audio_sample_valid(sample_valid),
        .aud_pwm(pwm_out),
        .aud_sd(pwm_sd)
    );

    // 50 MHz clock
    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #100;
        rst = 0;

    end

endmodule
