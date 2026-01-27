typedef enum logic [2:0] {IDLE, START, DATA, PARITY, DONE} state_e;

module TX_FSM (
    input logic CLK,
    input logic RST,
    input logic Data_Valid,
    input logic parity_enable,
    input logic ser_done,

    output logic [1:0] mux_sel,
    output logic ser_en,
    output logic busy
);

state_e current_state, next_state;

logic busy_comb;

always_ff @(posedge CLK or negedge RST) begin
    if(~RST) begin
        current_state <= IDLE;
    end
    else begin 
        current_state <= next_state;
    end
end

// next state lpgic 
always_comb begin
    case (current_state)
        IDLE: begin
            if (Data_Valid) begin
                next_state = START;
            end
            else begin
                next_state = IDLE;
            end
        end 

        START: begin
            next_state = DATA;
        end

        DATA: begin
            if (ser_done) begin 
                if (parity_enable) begin
                    next_state = PARITY;
                end
                else begin
                    next_state = DONE;
                end
            end
            else begin
                next_state = DATA;
            end
        end

        PARITY: begin
            next_state = DONE;
        end

        DONE: begin
            next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end

always_comb begin
    // Defaults
    busy_comb = 0;
    ser_en    = 0;
    mux_sel   = 2'b00; 

    case (current_state)
        IDLE: begin 
            busy_comb = 0;
            ser_en    = 0;
            mux_sel   = 2'b01; // to be 1 by default
        end 

        START: begin
            // receive new data on P_DATA when Data_Valid is high
            busy_comb = 1;
            ser_en    = 0;
            mux_sel   = 2'b00;   // start to receive
        end

        DATA: begin    
            busy_comb = 1;
            ser_en    = 1; 
            mux_sel   = 2'b10;   // when busy_comb, take ser data

            if (ser_done) begin
                ser_en = 0;
            end
            else begin
                ser_en = 1;
            end
        end

        PARITY: begin
            busy_comb = 1;
            ser_en    = 0; 
            mux_sel   = 2'b11;
        end

        DONE: begin
            busy_comb = 1;
            ser_en    = 0; 
            mux_sel   = 2'b01;   // stop bit
        end

        default: begin
            busy_comb = 0;
            ser_en    = 0;
            mux_sel   = 2'b00;
        end
    endcase
end

//register output 
always @ (posedge CLK or negedge RST) begin
    if(!RST) begin
        busy <= 1'b0 ;
    end
    else begin
        busy <= busy_comb ;
    end
end

endmodule