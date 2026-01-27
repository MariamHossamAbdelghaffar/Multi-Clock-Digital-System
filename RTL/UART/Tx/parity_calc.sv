module parity_calc #(
    parameter DATA_WD = 8
)(
    input  logic CLK,
    input  logic RST,
    input  logic [DATA_WD-1:0] P_DATA,
    input  logic Data_Valid,
    input  logic parity_type,
    input  logic busy,

    output logic par_bit
);

logic [DATA_WD-1:0] P_DATA_parity;

// won't calc parity unless the data is valid and it's not busy
always @(posedge CLK or negedge RST) begin
    if (~RST) begin
        P_DATA_parity <= 0;
    end
    else if (Data_Valid && !busy) begin
        P_DATA_parity <= P_DATA;
    end
end

always @(posedge CLK or negedge RST) begin
    if (~RST) begin
        par_bit <= 0;
    end
    else begin
        case (parity_type)
            1'b0: begin
                par_bit <= ^P_DATA_parity;    // even parity
            end
            1'b1: begin
                par_bit <= ~(^P_DATA_parity); // odd parity
            end
        endcase
    end
end

endmodule