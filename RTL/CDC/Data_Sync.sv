import parameters_pkg::*;

module Data_Sync (
    input  logic [DATA_WIDTH-1:0] unsync_bus,
    input  logic                  bus_enable,
    input  logic                  dest_clk,
    input  logic                  dest_rst,

    output logic [DATA_WIDTH-1:0] sync_bus,
    output logic                  enable_pulse_d
);

logic                   sync_1;
logic                   sync_2;
logic                   enable_flop;
logic                   enable_pulse;
logic  [DATA_WIDTH-1:0] sync_bus_c;

// Double FF synchronizer
always @(posedge dest_clk or negedge dest_rst) begin
    if (~dest_rst) begin
        sync_1 <= 0;
        sync_2 <= 0;
    end
    else begin
        sync_1 <= bus_enable;
        sync_2 <= sync_1;
    end  
 end
 
// pulse generator 
always @(posedge dest_clk or negedge dest_rst) begin
    if (~dest_rst) begin
        enable_flop <= 0;	
    end
    else begin
        enable_flop <= sync_2;
    end  
 end

assign enable_pulse = sync_2 && !enable_flop ;

// mux
assign sync_bus_c =  enable_pulse ? unsync_bus : sync_bus ;  


// destination domain flop
always @(posedge dest_clk or negedge dest_rst) begin
    if (~dest_rst) begin
        sync_bus <= 'b0;
    end
    else begin
        sync_bus <= sync_bus_c;
    end  
end

// delay generated pulse
always @(posedge dest_clk or negedge dest_rst) begin
    if (~dest_rst) begin
        enable_pulse_d <= 0;
    end
    else begin
        enable_pulse_d <= enable_pulse;
    end  
end

endmodule