module PULSE_GEN (
    input  logic CLK,
    input  logic RST,
    input  logic LVL_SIG,

    output logic PULSE_SIG
);

logic lvl_sig_d; // level signal delayed

always_ff @(posedge CLK or negedge RST) begin
    if(~RST) begin
        lvl_sig_d <= 1'b0;
        PULSE_SIG <= 1'b0;
    end
    else begin 
        lvl_sig_d <= LVL_SIG;
        PULSE_SIG <= LVL_SIG && !lvl_sig_d;
    end
end

endmodule : PULSE_GEN