import parameters_pkg::*;

module FIFO (
    input  logic                  W_CLK,
    input  logic                  W_RST,
    input  logic                  W_INC,
    input  logic [PTR_WIDTH-1:0]  b_wptr,

    input  logic                  R_CLK,  
    input  logic                  R_RST, 
    input  logic                  R_INC, 
    input  logic [PTR_WIDTH-1:0]  b_rptr, 

    input  logic [DATA_WIDTH-1:0] WR_DATA,
    output logic [DATA_WIDTH-1:0] RD_DATA,

    input  logic                  FULL,
    input  logic                  EMPTY
);

reg [DATA_WIDTH-1:0] async_fifo [FIFO_DEPTH-1:0];


always_ff @(posedge W_CLK or negedge W_RST) begin
    if(~W_RST) begin
        for (int i = 0 ; i < FIFO_DEPTH ; i++) begin
            async_fifo[i] <= 0;
        end
    end
    else if(W_INC && ~FULL) begin
        async_fifo[b_wptr[PTR_WIDTH-2:0]] <= WR_DATA;
    end
     
end

// Asynchronous read
assign RD_DATA = async_fifo[b_rptr[PTR_WIDTH-2:0]];

/*always_ff @(posedge R_CLK or negedge R_RST) begin 
    if(~R_RST) begin
        RD_DATA <= 'b0;
    end
    else if (R_INC && ~EMPTY) begin
        RD_DATA <= async_fifo[b_rptr[PTR_WIDTH-2:0]];
    end
end*/
   
endmodule