module CLK_GATE (
    input  logic CLK,  // REF_CLK
    input  logic CLK_EN,

    output logic GATED_CLK 
);

logic latch_out;

always_comb begin
    if (~CLK) begin
        latch_out = CLK_EN;
    end
end

assign GATED_CLK = CLK & latch_out;

endmodule