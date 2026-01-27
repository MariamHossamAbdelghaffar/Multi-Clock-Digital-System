import parameters_pkg::*;

module edge_bit_counter (
    input  logic                         CLK,
    input  logic                         RST,
    input  logic                         edg_bit_cnt_en,
    input  logic [PRESCALE_W-1:0]        Prescale,

    output logic [PRESCALE_W-1:0]        edge_cnt,
    output logic [$clog2(DATA_WIDTH):0]  bit_cnt
);

always_ff @(posedge CLK or negedge RST)  begin
    if (~RST) begin
        edge_cnt <= 'b0;
    end
    else if (edg_bit_cnt_en) begin // means detecting a falling edge in RX_IN (start of start bit)
        if (edge_cnt < Prescale - 'b1) begin
            edge_cnt <= edge_cnt + 'b1;
        end
        else begin 
            edge_cnt <= 'b0;
        end
    end
    else begin 
        edge_cnt <= 'b0;
    end
end 

always_ff @(posedge CLK or negedge RST)  begin
    if (~RST) begin
        bit_cnt <= 'b0;
    end
    else if (edg_bit_cnt_en) begin
        if ((edge_cnt == Prescale - 'b1)) begin // counted last edge in a bit
            bit_cnt <= bit_cnt + 'b1;
        end
    end
    else begin
        bit_cnt <= 'b0;
    end
end 
    
endmodule