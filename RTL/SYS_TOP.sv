import parameters_pkg::*;

module SYS_TOP (
    input  logic REF_CLK,
    input  logic UART_CLK,
    input  logic RST,
    input  logic RX_IN,

    output logic TX_OUT
);

// Reg File connections
logic [ADDR_WIDTH-1:0]   Address; 
logic                    WrEn;
logic                    RdEn;
logic [DATA_WIDTH-1:0]   WrData;
logic [DATA_WIDTH-1:0]   RdData;
logic                    RdData_valid;
logic [DATA_WIDTH-1:0]   UART_Config;
logic [DATA_WIDTH-1:0]   DIV_RATIO;

// ALU connections
logic [DATA_WIDTH-1:0]   A;
logic [DATA_WIDTH-1:0]   B;
logic [OP_WIDTH-1:0]     ALU_FUN;
logic                    ALU_EN;
logic [2*DATA_WIDTH-1:0] ALU_OUT;
logic                    ALU_OUT_Valid;
logic                    OUT_VALID;

// SYS Ctrl connections 
logic                    clk_div_en;
logic                    FIFO_FULL;
logic [DATA_WIDTH-1:0]   UART_RX_SYNC;
logic                    UART_RX_V_SYNC;
logic [DATA_WIDTH-1:0]   UART_TX_IN;
logic                    UART_TX_VLD;

// UART connections
logic [DATA_WIDTH-1:0]   UART_RX_OUT;
logic                    UART_RX_V_OUT;
logic [DATA_WIDTH-1:0]   UART_TX_SYNC;   // parallel input data to Tx
logic       		     UART_TX_V_SYNC; // indicate no valid data to Tx (fifo is empty)

logic                     CLK_EN;
logic                     ALU_CLK;
            
logic                     TX_CLK;
logic                     RX_CLK;
            
logic                     SYNC_RST_1;
logic                     SYNC_RST_2;
            
logic                     busy_pulse; // R_INC
logic                     busy;
            
//======================== Clock Domain 1 (REF_CLK) ========================//

/////////////
// RegFile //
/////////////
Register_file U0_RegFile (
    .CLK(REF_CLK),
    .RST(SYNC_RST_1),
    .REG0(A),
    .REG1(B),
    .REG2(UART_Config),
    .REG3(DIV_RATIO),
    .*
);

/////////////
///  ALU  ///
/////////////
ALU alu_dut (
    .CLK(ALU_CLK),
    .RST(SYNC_RST_1),
    .*
);

//////////////////
// Clock Gating //
//////////////////
CLK_GATE clkgate (
    .CLK(REF_CLK),
    .CLK_EN(CLK_EN),
    .GATED_CLK(ALU_CLK)
);

//////////////////
///  SYS_CTRL  ///
//////////////////
SYS_CTRL controller (
    .CLK(REF_CLK),
    .RST(SYNC_RST_1),
    .RX_P_DATA(UART_RX_SYNC),
    .RX_D_VLD(UART_RX_V_SYNC),
    .TX_P_DATA(UART_TX_IN),
    .TX_D_VLD(UART_TX_VLD),
    .*
);

//======================== Clock Domain 2 (UART_CLK) ========================//

///////////////
///// UART ////
///////////////
UART U0_UART (
    .TX_CLK(TX_CLK),
    .RX_CLK(RX_CLK),
    .RST(SYNC_RST_2),

    .parity_enable(UART_Config[0]),
    .parity_type(UART_Config[1]),
    .Prescale(UART_Config[7:2]),

    .RX_IN_S(RX_IN), 
    .TX_IN_P(UART_TX_SYNC), 
    .TX_IN_V(!UART_TX_V_SYNC),
    .RX_OUT_P(UART_RX_OUT),
    .RX_OUT_V(UART_RX_V_OUT),
    .TX_OUT_V(busy),
    .TX_OUT_S(TX_OUT)
);

///////////////
// PULSE_GEN //
///////////////
PULSE_GEN puls_gen(
    .CLK(TX_CLK),
    .RST(SYNC_RST_2),
    .LVL_SIG(busy),    // UART Tx busy
    .PULSE_SIG(busy_pulse)  // UART Tx busy Pulse
);

////////////////////
// Clock Dividers //
////////////////////
logic [PRESCALE_W-1:0] rx_div_ratio; // 8 bits to be safe

always_comb begin
    case (UART_Config[7:2]) // Prescale comes from REG2[7:2]
        6'd32: rx_div_ratio   = 8'd1; // Ratio 1
        6'd16: rx_div_ratio   = 8'd2; // Ratio 2
        6'd8:  rx_div_ratio   = 8'd4; // Ratio 4
        default: rx_div_ratio = 8'd1;
    endcase
end

ClkDiv #(.RATIO_WIDTH(DIV_RATIO_W)) clkdiv_tx ( 
    .I_ref_clk(UART_CLK),
    .I_rst_n(SYNC_RST_2),
    .I_clk_en(clk_div_en),
    .I_div_ratio(DIV_RATIO),
    .O_div_clk(TX_CLK)
);
    
ClkDiv #(.RATIO_WIDTH(PRESCALE_W)) clkdiv_rx ( 
    .I_ref_clk(UART_CLK),
    .I_rst_n(SYNC_RST_2),
    .I_clk_en(clk_div_en),
    .I_div_ratio(rx_div_ratio), 
    .O_div_clk(RX_CLK)
);

//======================== Data Synchronizers ========================//

// Sync reset for Clock Domain 1 (REF_CLK)
////////////////
// RST_SYNC_1 //
////////////////
RST_SYNC RST_SYNC_1 (
    .CLK(REF_CLK),
    .RST(RST),
    .SYNC_RST(SYNC_RST_1)
); 


// Sync reset for Clock Domain 2 (UART_CLK)
////////////////
// RST_SYNC_2 //
////////////////
RST_SYNC RST_SYNC_2 (
    .CLK(UART_CLK),
    .RST(RST),
    .SYNC_RST(SYNC_RST_2)
); 

///////////////////////
// Data Synchronizer //
///////////////////////
Data_Sync ref_sync (
    .unsync_bus(UART_RX_OUT),
    .bus_enable(UART_RX_V_OUT),
    .dest_clk(REF_CLK),
    .dest_rst(SYNC_RST_1),
    .sync_bus(UART_RX_SYNC),
    .enable_pulse_d(UART_RX_V_SYNC)
);

////////////////
// ASYNC FIFO //
////////////////
ASYC_FIFO asynch_fifo (
    // bet sys ctrl & fifo
    .W_CLK(REF_CLK),
    .W_RST(SYNC_RST_1),  
    .W_INC(UART_TX_VLD), 
    .WR_DATA(UART_TX_IN), // data out from sys ctrl

    // bet UART Tx & fifo
    .R_CLK(TX_CLK),
    .R_RST(SYNC_RST_2),  
    .R_INC(busy_pulse),        // UART Tx busy Pulse
    .RD_DATA(UART_TX_SYNC),

    .FULL(FIFO_FULL),
    .EMPTY(UART_TX_V_SYNC)
);

endmodule : SYS_TOP