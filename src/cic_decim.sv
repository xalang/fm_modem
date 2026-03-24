module cic_decimator 
(
    input  logic                        clk,
    input  logic                        rst,
    input  logic signed [15:0]          in,
    output logic                        out_valid,
    output logic signed [15:0]          out
);

    //------------------------------------------
    // Integrators (run at input clock)
    //------------------------------------------
    logic signed [63:0] integrator [0:2];
    integer i;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 3; i++)
                integrator[i] <= '0;
        end else begin
            integrator[0] <= integrator[0] + in;
            for (i = 1; i < 3; i++)
                integrator[i] <= integrator[i] + integrator[i-1];
        end
    end

    //------------------------------------------
    // Decimation counter
    //------------------------------------------
    logic [4:0] dec_cnt;
    logic signed [63:0] decim_sample;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            dec_cnt      <= 0;
            decim_sample <= 0;
        end else begin
            if (dec_cnt == 24) begin
                dec_cnt      <= 0;
                decim_sample <= integrator[2];
            end else begin
                dec_cnt <= dec_cnt + 1;
            end
        end
    end

    //------------------------------------------
    // Comb stages (run at decimated rate)
    //------------------------------------------
    logic signed [63:0] comb_delay [0:2];
    logic signed [63:0] comb_out   [0:2];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 3; i++) begin
                comb_delay[i] <= 0;
                comb_out[i]   <= 0;
            end
        end else if (dec_cnt == 24) begin
            comb_out[0]   <= decim_sample - comb_delay[0];
            comb_delay[0] <= decim_sample;
            for (i = 1; i < 3; i++) begin
                comb_out[i]   <= comb_out[i-1] - comb_delay[i];
                comb_delay[i] <= comb_out[i-1];
            end
        end
    end

    //------------------------------------------
    // Output scaling - divides by 2^14
    //------------------------------------------

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
