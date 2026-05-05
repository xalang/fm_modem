//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: fm_modem_wrapper
// Description: Top level wrapper
//
//////////////////////////////////////////////////////////////////////////////////

module fm_modem_wrapper (
    input  wire        clk,
    input  wire        rstn,
    input  wire [31:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    output wire        aud_pwm,
    output wire        aud_sd,
    output wire        LED_1
);
    
    wire rst;
    assign rst = ~rstn;

    // Remove if you want - used to verify PS clock configuration
    reg [25:0] counter;
    always @(posedge clk) begin
        if (rst)
            counter <= 0;
        else
            counter <= counter + 1;
    end
    assign LED_1 = counter[25];

    fm_modem fm_modem_inst(
        .clk(clk),
        .rst(rst),
        .audio_sample(s_axis_tdata[15:0]),
        .audio_sample_valid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .aud_pwm(aud_pwm),
        .aud_sd(aud_sd)
    );

endmodule
