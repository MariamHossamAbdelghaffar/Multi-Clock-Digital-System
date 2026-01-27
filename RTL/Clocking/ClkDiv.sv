module ClkDiv #(
    parameter RATIO_WIDTH = 8
)(
    input  logic                   I_ref_clk,
    input  logic                   I_rst_n, 
    input  logic                   I_clk_en,
    input  logic [RATIO_WIDTH-1:0] I_div_ratio, 

    output logic                   O_div_clk 
);

logic [RATIO_WIDTH-1:0] counter;
logic [RATIO_WIDTH-1:0] half_count;
logic div_clk;

assign half_count = (I_div_ratio >> 1) - 1;

always_ff @(posedge I_ref_clk or negedge I_rst_n) begin
    if (~I_rst_n) begin
        div_clk <= 0;
        counter <= 'b0;
    end
    else if (I_clk_en) begin
        if ((I_div_ratio != 0) && (I_div_ratio != 1)) begin
            if (counter == half_count) begin
                div_clk <= ~div_clk;
                counter <= 0;
            end 
            else begin
                counter <= counter + 1'b1;
            end
        end
        else begin
            div_clk <= 0;
            counter <= 0;
        end 
    end
end

// if div ratio not 0 nor 1 and clk div is enabled -> take the divided clk otherwise take the ref clk 
assign O_div_clk = (I_clk_en && (I_div_ratio != 0) && (I_div_ratio != 1))? div_clk : I_ref_clk;

endmodule
