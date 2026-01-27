import parameters_pkg::*;

module serializer (
    input  logic                  CLK,
    input  logic                  RST,
    input  logic [DATA_WIDTH-1:0] P_DATA,
    input  logic                  ser_en,
    input  logic                  Data_Valid,
    input  logic                  busy,

    output logic                  ser_done,
    output logic                  ser_data
);

logic [$clog2(DATA_WIDTH)-1:0] count;
logic [DATA_WIDTH-1:0]         DATA_r;

always @(posedge CLK or negedge RST) begin
    if (~RST) begin
        DATA_r <= 'b0;
        count  <= 0;
    end
    else if (Data_Valid && !busy) begin
        DATA_r <= P_DATA;
    end
    else if (ser_en) begin   
        DATA_r <= DATA_r >> 1;
        count  <= count + 1'b1;
    end
    else begin
        count  <= 0;
    end
end

assign ser_data = DATA_r[0];
assign ser_done = (count == DATA_WIDTH-1);

endmodule
