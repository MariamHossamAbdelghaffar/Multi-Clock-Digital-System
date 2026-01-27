import parameters_pkg::*;

module write_pointer_handler (
    input  logic                 W_CLK,
    input  logic                 W_RST,
    input  logic                 W_INC,
    input  logic [PTR_WIDTH-1:0] g_rptr_sync, // syncronized gray encoded read ptr

    output logic [PTR_WIDTH-1:0] b_wptr,      // binary coded write ptr
    output logic [PTR_WIDTH-1:0] g_wptr,      // gray coded write ptr
    output logic                 FULL
);

logic [PTR_WIDTH-1:0] b_rptr_sync;

always_ff @(posedge W_CLK or negedge W_RST) begin : blockName
    if(~W_RST) begin
        b_wptr <= 0;
    end
    else if(W_INC && ~FULL) begin
        b_wptr <= b_wptr + 1;
    end
     
end

// encode wr ptr with gray to be sent accros domain crossing
assign g_wptr = b_wptr ^ (b_wptr >> 1);

// convert gray rd ptr back to binary
genvar i;
generate
    for (i = 0 ; i < PTR_WIDTH-1 ; i = i+1) begin : gen_bin
        assign b_rptr_sync[i] = ^(g_rptr_sync >> i);
    end
endgenerate

assign b_rptr_sync[PTR_WIDTH-1] = g_rptr_sync[PTR_WIDTH-1];

assign FULL =   (b_wptr[PTR_WIDTH-2:0] == b_rptr_sync[PTR_WIDTH-2:0]) &&
                (b_wptr[PTR_WIDTH-1] != b_rptr_sync[PTR_WIDTH-1]);

endmodule : write_pointer_handler