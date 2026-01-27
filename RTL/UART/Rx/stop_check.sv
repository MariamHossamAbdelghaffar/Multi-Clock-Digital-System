module stop_check (
    input  logic CLK,
    input  logic RST,
    input  logic stp_chk_en,
    input  logic sampled_bit,

    output logic stp_err
);

always_ff @(posedge CLK or negedge RST)  begin
    if (~RST) begin
        stp_err <= 0;
    end
    else if (stp_chk_en) begin
        stp_err <= ~sampled_bit; 
    end
end    
endmodule