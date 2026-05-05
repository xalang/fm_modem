//////////////////////////////////////////////////////////////////////////////////
// By:          Andy Lang
// Create Date: 03/24/2026   
// Module Name: sample_rom
// Description: Output samples of audio at 48khz. Used for testbench.
//
//////////////////////////////////////////////////////////////////////////////////

module sample_rom (
    input  logic clk,          // 50 MHz input clock
    input  logic rst,
    output logic data_valid,
    output logic signed [15:0] data
);

    logic signed [15:0] mem [0:250000];

    logic [17:0] sample_addr;      // Enough bits for 250000 entries
    logic [10:0] clk_div;          // Counts up to 1041

    initial begin
        $readmemh("raw_audio_q15.mem", mem);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            sample_addr <= 0;
            clk_div     <= 0;
            data        <= 0;
            data_valid  <= 1;
        end
        else begin
            // Divide 50MHz by 1042 to get ~48KHz output rate
            if (clk_div == 1041) begin
                clk_div <= 0;

                data <= mem[sample_addr];
                data_valid <= 1;
                if (sample_addr == 250000)
                    sample_addr <= 0;
                else
                    sample_addr <= sample_addr + 1;
            end
            else begin
                clk_div <= clk_div + 1;
            end
        end
    end

endmodule
