import parameters_pkg::*;

module ASYC_FIFO (
    input  logic                  W_CLK,
    input  logic                  W_RST,   // RST SYNC 1
    input  logic                  W_INC,   // SYS_CTRL
    input  logic                  R_CLK,   // RST_SYNC_2 
    input  logic                  R_RST,   
    input  logic                  R_INC,   // PULSE_GEN
    input  logic [DATA_WIDTH-1:0] WR_DATA, // SYS_CTRL

    output logic [DATA_WIDTH-1:0] RD_DATA, // UART_TX 
    output logic                  FULL,
    output logic                  EMPTY
);

logic [PTR_WIDTH-1:0] b_wptr;
logic [PTR_WIDTH-1:0] g_wptr;
logic [PTR_WIDTH-1:0] b_rptr; 
logic [PTR_WIDTH-1:0] g_rptr;
logic [PTR_WIDTH-1:0] g_rptr_sync;
logic [PTR_WIDTH-1:0] g_wptr_sync;

FIFO fifo_dut (.*);
write_pointer_handler wr_ptr (.*);
read_pointer_handler rd_ptr (.*);

douple_ff_sync dff_sync_wr (
    .clk(W_CLK),
    .rst(W_RST),
    .D(g_rptr),
    .Q(g_rptr_sync)
);
douple_ff_sync dff_sync_rd (
    .clk(R_CLK),
    .rst(R_RST),
    .D(g_wptr),
    .Q(g_wptr_sync)
);

endmodule