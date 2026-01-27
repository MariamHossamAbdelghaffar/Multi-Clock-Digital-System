import parameters_pkg::*;

module read_pointer_handler (
    input  logic                 R_CLK, 
    input  logic                 R_RST,
    input  logic                 R_INC,
    input  logic [PTR_WIDTH-1:0] g_wptr_sync, // syncronized gray encoded write ptr

    output logic [PTR_WIDTH-1:0] b_rptr,      // binary coded read ptr
    output logic [PTR_WIDTH-1:0] g_rptr,      // gray coded read ptr
    output logic                 EMPTY
);

logic [PTR_WIDTH-1:0] b_wptr_sync;

always_ff @(posedge R_CLK or negedge R_RST) begin : blockName
    if(~R_RST) begin
        b_rptr <= 0;
    end
    else if(R_INC && ~EMPTY) begin
        b_rptr <= b_rptr + 1;
    end
end

// encode rd ptr with gray to be sent accros domain crossing
assign g_rptr = b_rptr ^ (b_rptr >> 1);

// convert gray wr ptr back to binary
genvar i;
generate
    for (i = 0 ; i < PTR_WIDTH-1 ; i = i+1) begin : gen_bin
        assign b_wptr_sync[i] = ^(g_wptr_sync >> i);
    end
endgenerate

assign b_wptr_sync[PTR_WIDTH-1] = g_wptr_sync[PTR_WIDTH-1];

assign EMPTY = (b_rptr == b_wptr_sync);

endmodule : read_pointer_handler