// UART Transmitter 
`timescale 1ns/1ps

module uart_tx (
    input clk, 
    input rst, 
    input baud_tick, 
    input tx_start,
    input [7:0] tx_data,
    input par_en,           // Parity Enable 
    input par_ty,           // Parity Type
    output reg tx, 
    output reg tx_busy
);
    localparam  IDLE  = 0, 
                START  = 1, 
                DATA   = 2, 
                PARITY = 3, 
                STOP   = 4;
  
    reg [2:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        state   <= IDLE;
        tx_busy <= 0;
        tx      <= 1;    // Tx line High
        bit_cnt <= 0;
    end 
    else begin
        case (state)
            IDLE: begin
                tx <= 1;
                if (tx_start) begin
                    shift_reg <= tx_data;
                    tx_busy   <= 1;           // Tx is Busy
                    state     <= START; 
                end else begin
                    tx_busy   <= 0;
                end
            end
            
            START: begin
               if (baud_tick) begin
                    tx      <= 0; // Start bit
                    bit_cnt <= 0;
                    state   <= DATA;
               end
            end

            DATA: begin
                if (baud_tick) begin
                    tx <= shift_reg[bit_cnt];
                    if (bit_cnt == 7) begin
                        state <= par_en ? PARITY : STOP;   
                    end 
                    else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
            end

            PARITY: begin
                if (baud_tick) begin
                    tx    <= (par_ty) ? ^shift_reg : ~^shift_reg;
                    state <= STOP;
                end
            end

            STOP: begin
                if (baud_tick) begin
                    tx      <= 1;
                    state   <= IDLE;
                    tx_busy <= 0;
                end
            end
            
            default: state <= IDLE;
        endcase
    end
end
endmodule
