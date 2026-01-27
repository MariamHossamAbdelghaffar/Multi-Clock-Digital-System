import parameters_pkg::*;

module Register_file(
    input  logic                  CLK,
    // RST_SYNC 
    input  logic                  RST,

    // SYS_CTRL
    input  logic [ADDR_WIDTH-1:0] Address,
    input  logic                  WrEn, // higher priority
    input  logic                  RdEn,
    input  logic [DATA_WIDTH-1:0] WrData,
    output logic [DATA_WIDTH-1:0] RdData,
    output logic                  RdData_valid,

    // ALU
    output logic [DATA_WIDTH-1:0] REG0,
    output logic [DATA_WIDTH-1:0] REG1,
    // UART
    output logic [DATA_WIDTH-1:0] REG2,
    // Clock Divider
    output logic [DATA_WIDTH-1:0] REG3
);

logic [DATA_WIDTH-1:0] regArr [RF_DEPTH-1:0];

always_ff @(posedge CLK or negedge RST) begin 
    if (~RST) begin 
        for (int i ; i < RF_DEPTH ; i++) begin 
            if (i == 2) begin 
                regArr[i] <= 'b1000_0001;
            end
            else if (i == 3) begin 
                regArr[i] <= 'b0010_0000;
            end
            else begin 
                regArr[i] <= {DATA_WIDTH{1'b0}};
            end
        end

        RdData_valid <= 0;
        RdData <= {DATA_WIDTH{1'b0}};
    end 
    else if (WrEn) begin
        regArr[Address] <= WrData;
    end
    else if (RdEn) begin
        RdData_valid <= 1;
        RdData <= regArr[Address];
    end
    else begin 
        RdData_valid <= 0;
    end
end

assign REG0 = regArr[0]; 
assign REG1 = regArr[1]; 
assign REG2 = regArr[2]; 
assign REG3 = regArr[3]; 
    
endmodule : Register_file