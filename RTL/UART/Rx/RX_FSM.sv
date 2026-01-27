import parameters_pkg::*;
typedef enum bit [2:0] {IDLE, START, RCV, PARITY, STOP, ERR_CHK} state_e;

module RX_FSM (
    input  logic                     CLK,
    input  logic                     RST,
    input  logic                     parity_enable,
    input  logic                     RX_IN,
    input  logic                     par_err,
    input  logic                     strt_glitch,
    input  logic                     stp_err,
    input  logic [$clog2(DATA_WIDTH):0] bit_cnt,
    input  logic [PRESCALE_W-1:0]    edge_cnt,
    input  logic [PRESCALE_W-1:0]    Prescale,

    output logic                     Data_Valid,
    output logic                     strt_chk_en,
    output logic                     par_chk_en,
    output logic                     stp_chk_en,
    output logic                     deser_en,
    output logic                     edg_bit_cnt_en,
    output logic                     data_samp_en
);

state_e current_state, next_state;
wire [$clog2(DATA_WIDTH):0] frame_end_bit;
wire no_err; 
wire bit_end, bit_end_err;

assign frame_end_bit = parity_enable ? (DATA_WIDTH + 2) : (DATA_WIDTH + 1);

assign no_err = parity_enable ? (!par_err && !stp_err) : (!stp_err);

assign bit_end = (edge_cnt == Prescale - 6'd1);
assign bit_end_err = (edge_cnt == Prescale - 6'd2);

always_ff @(posedge CLK or negedge RST) begin
    if(~RST) begin
        current_state <= IDLE;
    end
    else begin 
        current_state <= next_state;
    end
end

// next state logic 
always_comb begin 
    unique case (current_state)
        IDLE: begin
            if (!RX_IN) begin
                next_state = START;
            end
            else begin 
                next_state = IDLE;
            end
        end 

        START: begin
            if ((bit_cnt == 0) && bit_end) begin
                if (!strt_glitch) begin
                    next_state = RCV;
                end
                else begin
                    next_state = IDLE;
                end
            end
            else begin
                next_state = START;
            end
        end

        RCV: begin
            if ((bit_cnt == DATA_WIDTH) && bit_end) begin 
                if (parity_enable) begin
                    next_state = PARITY;
                end
                else begin
                    next_state = STOP;
                end
            end
            else begin
                next_state = RCV;
            end  
        end

        PARITY: begin
            if ((bit_cnt == (DATA_WIDTH + 1)) && bit_end_err) begin 
                next_state = STOP;
            end
            else begin
                next_state = PARITY;
            end
        end

        STOP: begin
            if (frame_end_bit && bit_end_err) begin 
                next_state = ERR_CHK;
            end
            else begin
                next_state = STOP;
            end 
        end

        ERR_CHK: begin
            // after a frame is finished, check it there's a consequent one   
            if (!RX_IN) begin
                next_state = START;
            end
            else begin 
                next_state = IDLE;
            end
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end 

// output logic
always_comb begin
    Data_Valid     = 0;
    strt_chk_en    = 0;
    par_chk_en     = 0;
    stp_chk_en     = 0;
    deser_en       = 0;
    edg_bit_cnt_en = 0;
    data_samp_en   = 0; 

    unique case (current_state)
        IDLE: begin
            Data_Valid     = 0;
            strt_chk_en    = 0;
            par_chk_en     = 0;
            stp_chk_en     = 0;
            deser_en       = 0;
            edg_bit_cnt_en = 0;
            data_samp_en   = 0;
        end 

        START: begin
            edg_bit_cnt_en = 1;
            data_samp_en   = 1;
            strt_chk_en    = 1;
        end

        RCV: begin
            edg_bit_cnt_en = 1;
            data_samp_en   = 1;
            deser_en       = 1;
            strt_chk_en    = 0;
        end

        PARITY: begin
            edg_bit_cnt_en = 1;
            data_samp_en   = 1;
            deser_en       = 0;
            par_chk_en     = 1;
        end

        STOP: begin
            edg_bit_cnt_en = 1;
            data_samp_en   = 1;
            deser_en       = 0;
            par_chk_en     = 0;
            stp_chk_en     = 1;
        end

        ERR_CHK: begin
            edg_bit_cnt_en = 0;
            data_samp_en   = 1;
            deser_en       = 0;
            par_chk_en     = 0;
            stp_chk_en     = 1;
            
            if (no_err) begin
                Data_Valid = 1;
            end
            else begin 
                Data_Valid = 0;
            end
        end

        default: begin
            Data_Valid     = 0;
            strt_chk_en    = 0;
            par_chk_en     = 0;
            stp_chk_en     = 0;
            deser_en       = 0;
            edg_bit_cnt_en = 0;
            data_samp_en   = 0;
        end
    endcase
end 

endmodule : RX_FSM
