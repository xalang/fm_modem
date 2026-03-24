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
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            phase_acc <= 32'd0;
        else
            phase_acc <= phase_acc + PHASE_INC;
    end
    
    assign cos_addr = phase_acc[31:20];
    assign sin_addr = phase_acc[31:20] + 12'd1024;
    
    cos_lut cos_lut (
        .addr(cos_addr),
        .data(cos_out)
    );
    
    cos_lut sin_lut (
        .addr(sin_addr),
        .data(sin_out)
    );

endmodule
