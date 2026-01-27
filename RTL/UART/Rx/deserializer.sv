import parameters_pkg::*;

module deserializer (
    input  logic                  CLK,
    input  logic                  RST,
    input  logic                  deser_en,
    input  logic                  sampled_bit,
    input  logic [PRESCALE_W-1:0] Prescale,
    input  logic [PRESCALE_W-1:0] edge_cnt,

    output logic [DATA_WIDTH-1:0] P_DATA
);
    
always_ff @(posedge CLK or negedge RST) begin
    if (~RST) begin
        P_DATA <= {DATA_WIDTH{1'b0}};
    end
    else if (deser_en && (edge_cnt == Prescale - 'b1)) begin 
        P_DATA <= {sampled_bit, P_DATA[7:1]};
    end
end

endmodule

// send start bit first 
// then send bit 0 of data then bit 1 then bit 2 ans so on
// so enter them from left to right
// b0 000 0000
// b1 b0 00 0000
// b2 b1 b0 0 0000
// ..
// b7 b6 b5 b4 b3 b2 b1 b0