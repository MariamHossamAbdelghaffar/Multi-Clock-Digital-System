module strt_check (
    input  logic CLK,
    input  logic RST,
    input  logic strt_chk_en,
    input  logic sampled_bit,

    output logic strt_glitch
);
    
always_ff @(posedge CLK or negedge RST)  begin
    if (~RST) begin
        strt_glitch <= 0;
    end
    else if (strt_chk_en) begin
        strt_glitch <= sampled_bit;  // if sampled = 0 -> no glitch
    end                              // if sampled = 1 -> glitch
end

endmodule