import parameters_pkg::*;

module data_sampling (
    input logic                  CLK,
    input logic                  RST,
    input logic                  RX_IN,
    input logic [PRESCALE_W-1:0] Prescale,
    input logic                  data_samp_en,
    input logic [PRESCALE_W-1:0] edge_cnt,

    output logic                 sampled_bit
);

logic [PRESCALE_W-1:0] mid_point;
logic [2:0] sample;

assign mid_point = (Prescale >> 1) - 'b1;

always_ff @(posedge CLK or negedge RST) begin
    if (~RST) begin
        sample <= 'b0;
        sampled_bit <= 1'b0;
    end
    else if (data_samp_en) begin 
        if (edge_cnt == mid_point - 1) begin
            sample[0] <= RX_IN;
        end
        else if (edge_cnt == mid_point) begin
            sample[1] <= RX_IN;
        end
        else if (edge_cnt == mid_point + 1) begin
            sample[2] <= RX_IN;
        end

        sampled_bit <= (sample[0] & sample[1]) | (sample[0] & sample[2]) | (sample[1] & sample[2]);
    end
    else begin
        sample <= 'b0;
        sampled_bit <= 1'b0;
    end
end

endmodule : data_sampling
