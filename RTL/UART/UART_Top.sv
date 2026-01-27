import parameters_pkg::*;

module UART (
    input  logic                  TX_CLK,
    input  logic                  RX_CLK,
    input  logic                  RST,
    input  logic                  parity_type,
    input  logic                  parity_enable,
    input  logic [PRESCALE_W-1:0] Prescale,
    input  logic                  RX_IN_S,   // serial data input to Rx from tb
    input  logic [DATA_WIDTH-1:0] TX_IN_P,   // parallel data input from fifo to Tx
    input  logic                  TX_IN_V,

    output logic [DATA_WIDTH-1:0] RX_OUT_P,  // parallel data out from Rx to Data sync
    output logic                  RX_OUT_V,
    output logic                  TX_OUT_V,
    output logic                  TX_OUT_S   // parallel data out from Tx to tb
);

UART_TX Tx (
    .CLK(TX_CLK),
    .P_DATA(TX_IN_P),
    .Data_Valid(TX_IN_V),
    .TX_OUT(TX_OUT_S),
    .busy(TX_OUT_V),
    .*
    );


UART_RX Rx (
    .CLK(RX_CLK),
    .RX_IN(RX_IN_S),
    .P_DATA(RX_OUT_P),
    .Data_Valid(RX_OUT_V),
    .*
    );


endmodule