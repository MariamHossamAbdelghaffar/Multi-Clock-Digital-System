import parameters_pkg::*;

module parity_check (
    input  logic                  CLK,
    input  logic                  RST,
    input  logic                  parity_type,
    input  logic                  sampled_bit, // sampled bit is the parity bit of tx
    input  logic                  par_chk_en, 
    input  logic [DATA_WIDTH-1:0] P_DATA,

    output logic                  par_err
);

logic par_bit;

always_comb begin
    case (parity_type)
        1'b0: begin
            par_bit = ^P_DATA;
        end
        1'b1: begin
            par_bit = ~(^P_DATA);
        end
    endcase
end 

always_ff @(posedge CLK or negedge RST) begin
    if (~RST) begin
        par_err <= 0;
    end
    else if (par_chk_en) begin 
        par_err <= sampled_bit ^ par_bit; 
    end
end
endmodule
 






/*
logic [$clog2(DATA_WIDTH)-1:0] count_ones, bit_count;

always @(posedge CLK) begin // Synchronized reset signal
    if (~RST) begin
        par_err    <= 0;
        count_ones <= 0;
        bit_count  <= 0;
    end
    else if (par_chk_en) begin
        bit_count  <= bit_count  + 1;

        if (sampled_bit && (bit_count < DATA_WIDTH)) begin
            count_ones <= count_ones + 1;
        end
        else if (bit_count == DATA_WIDTH-1) begin
            case ({parity_type, (count_ones % 2)}) // 0 -> even, 1 -> odd
                2'b00: begin 
                    par_err <= 0;
                end
                2'b01: begin 
                    par_err <= 1;
                end
                2'b10: begin 
                    par_err <= 1;
                end
                2'b11: begin 
                    par_err <= 0;
                end
            endcase

            count_ones <= 0;
        end
    end
    else begin
        par_err <= 0;
    end
end*/