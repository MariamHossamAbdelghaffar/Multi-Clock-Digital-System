module MUX (
    
    input  logic       CLK,
    input  logic       RST,
    input  logic       start_bit,
    input  logic       stop_bit,
    input  logic       ser_data,
    input  logic       par_bit,
    input  logic [1:0] mux_sel,

    output logic       TX_OUT
);

always_ff @(posedge CLK or negedge RST) begin
    if (~RST) begin
        TX_OUT <= 0;
    end
    else begin
        case (mux_sel)
            2'b00: TX_OUT <= start_bit;
            2'b01: TX_OUT <= stop_bit;
            2'b10: TX_OUT <= ser_data;
            2'b11: TX_OUT <= par_bit;
        endcase
    end
end
    
endmodule