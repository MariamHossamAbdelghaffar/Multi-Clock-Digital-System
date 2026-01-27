import parameters_pkg::*;

module douple_ff_sync (
    input  logic                  clk,
    input  logic                  rst,
    input  logic [PTR_WIDTH-1:0] D,

    output logic [PTR_WIDTH-1:0] Q
);

logic [PTR_WIDTH-1:0] sync_1, sync_2;

always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
        sync_1 <= 0;
        sync_2 <= 0;
    end
    else begin
        sync_1 <= D;
        sync_2 <= sync_1;
    end
end

assign Q = sync_2;
    
endmodule : douple_ff_sync