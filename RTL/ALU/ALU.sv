import parameters_pkg::*;
typedef enum logic [3:0] {ADD, SUB, MULT, DIV, AND, OR, NAND, NOR, XOR, XNOR, CMP_EQ, CMP_GR, CMP_LT, SHIFT_RIGHT, SHIFT_LEFT, NOP} alu_op;

module ALU (
    input  logic                    CLK,
    input  logic                    RST,

    // RegFile
    input  logic [DATA_WIDTH-1:0]   A, //REG0
    input  logic [DATA_WIDTH-1:0]   B, //REG1

    // SYS_CTRL
    input  logic [OP_WIDTH-1:0]     ALU_FUN,
    input  logic                    ALU_EN,

    // SYS_CTRL
    output logic [2*DATA_WIDTH-1:0] ALU_OUT,
    output logic                    ALU_OUT_Valid
);

alu_op op_code;
assign op_code = alu_op'(ALU_FUN);

always_ff @(posedge CLK or negedge RST) begin 
    if (~RST) begin 
        ALU_OUT   <= {DATA_WIDTH{1'b0}};
        ALU_OUT_Valid <= 0;
    end 
    else if (ALU_EN) begin 
        ALU_OUT_Valid <= 1;
        case (op_code)
            ADD: begin 
                ALU_OUT <= A + B;
            end
            SUB: begin 
                ALU_OUT <= A - B;
            end
            MULT: begin 
                ALU_OUT <= A * B;
            end
            DIV: begin 
                ALU_OUT <= A / B;
            end
            AND: begin 
                ALU_OUT <= A & B;
            end
            OR: begin 
                ALU_OUT <= A | B;
            end
            NAND: begin 
                ALU_OUT <= ~(A & B);
            end
            NOR: begin 
                ALU_OUT <= ~(A | B);
            end
            XOR: begin 
                ALU_OUT <= A ^ B;
            end
            XNOR: begin 
                ALU_OUT <= ~(A ^ B);
            end
            CMP_EQ: begin 
                ALU_OUT <= (A == B)? {{(2*DATA_WIDTH-1){1'b0}}, 1'b1} : '0;
            end
            CMP_GR: begin 
                ALU_OUT <= (A > B)? {{(2*DATA_WIDTH-2){1'b0}}, 2'b10} : '0;
            end
            CMP_LT: begin 
                ALU_OUT <= (A < B)? {{(2*DATA_WIDTH-2){1'b0}}, 2'b11} : '0;
            end
            SHIFT_RIGHT: begin 
                ALU_OUT <= A >> 1;
            end
            SHIFT_LEFT: begin 
                ALU_OUT <= A << 1;
            end
            NOP: begin
                ALU_OUT       <= '0;
                ALU_OUT_Valid <= 1'b0;
                end
            default: begin
                ALU_OUT       <= '0;
                ALU_OUT_Valid <= 0;
            end
        endcase
    end
    else begin
        ALU_OUT_Valid <= 0;
    end
end
    
endmodule : ALU