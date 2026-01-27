import parameters_pkg::*;

module UART_RX (
    input  logic                  CLK,
    input  logic                  RST,
    input  logic                  RX_IN,
    input  logic                  parity_enable,
    input  logic                  parity_type,
    input  logic [PRESCALE_W-1:0] Prescale,

    //output logic                  par_err,
    //output logic                  framing_error,
    output logic                  Data_Valid,
    output logic [DATA_WIDTH-1:0] P_DATA
);
   
logic par_err;
logic strt_glitch;
logic stp_err;
logic [$clog2(DATA_WIDTH):0] bit_cnt;
logic [PRESCALE_W-1:0] edge_cnt;
logic strt_chk_en;
logic par_chk_en;
logic stp_chk_en;
logic deser_en;
logic edg_bit_cnt_en;
logic data_samp_en;
logic sampled_bit;

RX_FSM rx_fsm_dut (.*);
data_sampling data_samp_dut (.*);
edge_bit_counter edg_bit_dut (.*);
deserializer deser_dut (.*);
parity_check par_chk_dut (.*);
strt_check strt_chk_dut (.*);
stop_check stp_chk_dut (.*);
    
endmodule