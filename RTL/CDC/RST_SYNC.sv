import parameters_pkg::*;

module RST_SYNC (
    input  logic CLK,
    input  logic RST,

    output logic SYNC_RST
); 
    
logic [PTR_WIDTH-1:0] sync_1, sync_2;

always_ff @(posedge CLK or negedge RST) begin
    if (~RST) begin
        sync_1 <= 1'b0;
        sync_2 <= 1'b0;
    end
    else begin
        sync_1 <= 1'b1;
        sync_2 <= sync_1;
    end
end

assign SYNC_RST = sync_2;

endmodule : RST_SYNC
