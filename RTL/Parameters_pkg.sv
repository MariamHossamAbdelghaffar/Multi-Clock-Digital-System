package parameters_pkg;
    parameter DATA_WIDTH = 8;
    parameter OP_WIDTH   = 4;

    // Reg File
    parameter RF_DEPTH   = 16;
    parameter ADDR_WIDTH = 4; //$clog2(RF_DEPTH);

    // FIFO
    parameter FIFO_DEPTH = 8; // TO BE EDITED 
    parameter PTR_WIDTH  = $clog2(FIFO_DEPTH) + 1;

    // Clk Dividers
    parameter DIV_RATIO_W = 8;  // clk div for Tx 
    parameter PRESCALE_W  = 6;  // clk div for Rx

endpackage