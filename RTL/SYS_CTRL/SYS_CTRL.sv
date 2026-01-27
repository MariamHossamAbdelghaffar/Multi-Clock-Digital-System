import parameters_pkg::*;
typedef enum bit [3:0] {IDLE, WRITE_ADDR, WRITE_DATA, READ_ADDR, SEND_READ_DATA, ALU_WP_OP_A, ALU_WP_OP_B, ALU_FUNC, ALU_STORE, SEND_ALU_LOW, SEND_ALU_HIGH} state_e;

module SYS_CTRL (
    input  logic                     CLK,
    // RST SYNC
    input  logic                     RST,

    // ALU
    input  logic [2*DATA_WIDTH-1:0]  ALU_OUT,
    input  logic                     ALU_OUT_Valid,
    output logic [OP_WIDTH-1:0]      ALU_FUN,
    output logic                     ALU_EN, 

    // CLK_GATE
    output logic                     CLK_EN,

    // Register File
    output logic [ADDR_WIDTH-1:0]    Address,
    output logic                     WrEn,
    output logic                     RdEn,
    output logic [DATA_WIDTH-1:0]    WrData,
    input  logic [DATA_WIDTH-1:0]    RdData,
    input  logic                     RdData_valid,

    // UART_RX 
    input  logic [DATA_WIDTH-1:0]    RX_P_DATA,
    input  logic                     RX_D_VLD,

    // UART_TX
    output logic [DATA_WIDTH-1:0]    TX_P_DATA, // FIFO_WR_DATA
    output logic                     TX_D_VLD,  // FIFO_WR_INC

    // FIFO
    input  logic                     FIFO_FULL,

    // CLKDiv 
    output logic                     clk_div_en 
);

state_e current_state, next_state;

reg [DATA_WIDTH-1:0]   rf_addr, rf_addr_reg;
reg [2*DATA_WIDTH-1:0] alu_result, alu_result_reg;

always_ff @(posedge CLK or negedge RST) begin
    if(~RST) begin
        current_state <= IDLE;
    end
    else begin 
        current_state <= next_state;
    end
end

// next state logic 
always_comb begin 
    unique case (current_state)
        IDLE: begin 
            if (RX_D_VLD) begin
                case (RX_P_DATA)
                    8'hAA: next_state   = WRITE_ADDR;
                    8'hBB: next_state   = READ_ADDR;
                    8'hCC: next_state   = ALU_WP_OP_A;
                    8'hDD: next_state   = ALU_FUNC;
                    default: next_state = IDLE;
                endcase
            end
            else begin
                next_state = IDLE;
            end
        end 

        WRITE_ADDR: begin
            if (RX_D_VLD) begin 
                next_state = WRITE_DATA;
            end
            else begin
                next_state = WRITE_ADDR;
            end
        end

        WRITE_DATA: begin
            if (RX_D_VLD) begin 
                next_state = IDLE;
            end
            else begin
                next_state = WRITE_DATA;
            end
        end

        READ_ADDR: begin
            if (RX_D_VLD) begin 
                next_state = SEND_READ_DATA;
            end
            else begin
                next_state = READ_ADDR;
            end
        end

        SEND_READ_DATA: begin
            if (RdData_valid) begin 
                next_state = IDLE;
            end
            else begin
                next_state = SEND_READ_DATA;
            end
        end

        ALU_WP_OP_A: begin
            if (RX_D_VLD) begin 
                next_state = ALU_WP_OP_B;
            end
            else begin
                next_state = ALU_WP_OP_A;
            end
        end

        ALU_WP_OP_B: begin
            if (RX_D_VLD) begin 
                next_state = ALU_FUNC;
            end
            else begin
                next_state = ALU_WP_OP_B;
            end
        end

        ALU_FUNC: begin
            if (RX_D_VLD) begin 
                next_state = ALU_STORE;
            end
            else begin
                next_state = ALU_FUNC;
            end
        end

        ALU_STORE: begin  
            if (ALU_OUT_Valid) begin 
                next_state = SEND_ALU_LOW;
            end
            else begin
                next_state = ALU_STORE;
            end
        end

        SEND_ALU_LOW: begin
            next_state = SEND_ALU_HIGH;
        end

        SEND_ALU_HIGH: begin
            next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end 

// output logic
always_comb begin 
    ALU_FUN    =  'b0;
    ALU_EN     = 1'b0;
    CLK_EN     = 1'b0;
    WrEn       = 1'b0;
    RdEn       = 1'b0;
    WrData     =  'b0;
    TX_P_DATA  =  'b0;
    TX_D_VLD   = 1'b0;
    clk_div_en = 1'b1; // Always on 

    unique case (current_state)
        IDLE: begin
            ALU_FUN    =  'b0;
            ALU_EN     = 1'b0;
            CLK_EN     = 1'b0;
            WrEn       = 1'b0;
            RdEn       = 1'b0;
            WrData     =  'b0;
            clk_div_en = 1'b1;
        end 

        // Rcv write addr from Rx 
        WRITE_ADDR: begin
            if (RX_D_VLD) begin
                rf_addr = RX_P_DATA[ADDR_WIDTH-1:0]; 
            end
            else begin
                rf_addr = 'b0;
            end
        end

        // write data into rcvd addr in reg file 
        WRITE_DATA: begin
            if (RX_D_VLD) begin
                WrEn    = 1;
                Address = rf_addr_reg;
                WrData  = RX_P_DATA;
            end
            else begin
                WrEn    = 0;
                Address = rf_addr_reg;
                WrData  = RX_P_DATA;
            end
        end

        // Rcv read addr from Rx 
        READ_ADDR: begin
            if (RX_D_VLD) begin
                Address = RX_P_DATA[ADDR_WIDTH-1:0];
                RdEn    = 1;
            end
            else begin
                RdEn    = 0;
            end
        end

        // send read data to fifo when it's valid
        SEND_READ_DATA: begin
            if (RdData_valid && !FIFO_FULL) begin
                TX_P_DATA = RdData;
                TX_D_VLD  = 1;
            end
            else begin
                TX_D_VLD  = 0;
            end
        end

        // rcv operand A value from Rx & write it in addr 0x0 in RF
        ALU_WP_OP_A: begin
            if (RX_D_VLD) begin
                WrEn = 1;
                Address = 8'h00;
                WrData = RX_P_DATA;
            end
            else begin
                WrEn = 0;
                Address = 8'h00;
                WrData = RX_P_DATA;
            end
        end

        // rcv operand B value from Rx & write it in addr 0x1 in RF
        ALU_WP_OP_B: begin
            if (RX_D_VLD) begin
                WrEn = 1;
                Address = 8'h01;
                WrData = RX_P_DATA;
            end
            else begin
                WrEn = 0;
                Address = 8'h01;
                WrData = RX_P_DATA;
            end
        end

        ALU_FUNC: begin
            CLK_EN = 1; 
            if (RX_D_VLD) begin
                ALU_EN  = 1;
                ALU_FUN = RX_P_DATA[OP_WIDTH-1:0];
            end
            else begin
                ALU_EN = 0;
                ALU_FUN = RX_P_DATA[OP_WIDTH-1:0];
            end
        end

        // rcv the 16-bit alu output 
        ALU_STORE: begin
            CLK_EN = 1;
            if (ALU_OUT_Valid) begin
                alu_result = ALU_OUT;
            end
            else begin
                alu_result = 'b0;
            end
        end

        // need to send the 16-bit out to fifo
        // send it on two steps, 8-bit per step 
        SEND_ALU_LOW: begin
            CLK_EN = 1;
            if (~FIFO_FULL) begin
                TX_P_DATA = alu_result_reg[DATA_WIDTH-1:0];
                TX_D_VLD  = 1;
            end
        end

        SEND_ALU_HIGH: begin
            CLK_EN = 1;
            if (~FIFO_FULL) begin
                TX_P_DATA = alu_result_reg[2*DATA_WIDTH-1:DATA_WIDTH];
                TX_D_VLD  = 1;
            end
        end

        default: begin
            ALU_FUN  =  'b0;
            ALU_EN   = 1'b0;
            CLK_EN   = 1'b0;
            WrEn     = 1'b0;
            RdEn     = 1'b0;
            WrData   =  'b0;
            clk_div_en = 1'b1; // Always on
        end
    endcase
end 

// register the address 
always_ff @(posedge CLK or negedge RST) begin 
    if(~RST) begin
        rf_addr_reg <= 'b0;
    end
    else begin 
        rf_addr_reg <= rf_addr;
    end
end

// register the alu out 
always_ff @(posedge CLK or negedge RST) begin 
    if(~RST) begin
        alu_result_reg <= 'b0;
    end
    else begin 
        alu_result_reg <= alu_result;
    end
end

endmodule : SYS_CTRL
