//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: fm_modem_wrapper
// Description: interface with vivado axi-4 stream interface
//////////////////////////////////////////////////////////////////////////////////

module fm_modem_wrapper (
    input  wire        clk,
    input  wire        rstn,
    // AXI4-Stream Slave from DMA
    input  wire [15:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    // FM module interface
    output wire        aud_pwm,
    output wire        aud_sd
);
    
    wire rst;
    assign rst = ~rstn;

    assign s_axis_tready = 1;

    fm_modem fm_modem_inst(
        .clk(clk),
        .rst(rst),
        .audio_sample(s_axis_tdata),
        .audio_sample_valid(s_axis_tvalid),
        .aud_pwm(aud_pwm),
        .aud_sd(aud_sd)
    );
    

endmodule
