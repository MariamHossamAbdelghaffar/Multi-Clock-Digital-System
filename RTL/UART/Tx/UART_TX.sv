import parameters_pkg::*;

module UART_TX (
    input  logic                  CLK,
    input  logic                  RST,
    input  logic [DATA_WIDTH-1:0] P_DATA,
    input  logic                  Data_Valid,
    input  logic                  parity_enable,
    input  logic                  parity_type,
 
    output logic                  TX_OUT,
    output logic                  busy
);

localparam ZERO = 0;
localparam ONE  = 1;

logic start_bit, stop_bit;
logic [1:0] mux_sel;
logic ser_en, ser_done, ser_data;

logic par_bit;

assign start_bit = ZERO;
assign stop_bit  = ONE;

MUX mux_inst (.*);
parity_calc par_calc (.*);
TX_FSM fsm (.*);
serializer ser (.*);
    
endmodule