// --- UART Receiver ---
module uart_rx(
    input clk, rst, baud16_tick, rx, par_en, par_ty,
    output reg [7:0] rx_data,
    output reg rx_done, parity_error, framing_error
);
    localparam IDLE   = 0, 
               START  = 1, 
               DATA   = 2, 
               PARITY = 3, 
               STOP   = 4;
    reg [2:0] state;
    reg [3:0] sample_cnt;
    reg [2:0] bit_cnt;
    reg [7:0] temp_data;
    
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
            state <= IDLE; 
            rx_done <= 0; 
            rx_data <= 0;
            parity_error <= 0; 
            framing_error <= 0;
        end 
        else if (baud16_tick) begin
            case (state)
                IDLE: begin
                    rx_done <= 0;
                    sample_cnt <= 0;
                    if (rx == 0) 
                      state <= START; 
                end
                START: begin
                    if (sample_cnt == 7) begin 
                        if (rx == 0) begin
                            sample_cnt <= 0;
                            bit_cnt <= 0;
                            state <= DATA;
                        end 
                        else 
                          state <= IDLE; 
                    end 
                    else 
                      sample_cnt <= sample_cnt + 1;
                    end
                DATA: begin
                    if (sample_cnt == 15) begin
                        sample_cnt <= 0;
                        temp_data[bit_cnt] <= rx;
                       if (bit_cnt == 7) begin
                            state <= par_en ? PARITY : STOP;
                        end 
                        else 
                          bit_cnt <= bit_cnt + 1;
                    end 
                    else 
                       sample_cnt <= sample_cnt + 1;
                end
                PARITY: begin
                    if (sample_cnt == 15) begin
                        sample_cnt <= 0;
                        parity_error <= (par_ty) ? (^temp_data != rx) : (^temp_data == rx);
                        state <= STOP;
                    end 
                    else 
                      sample_cnt <= sample_cnt + 1;
                end
                STOP: begin
                    if (sample_cnt == 15) begin
                        rx_data <= temp_data;
                        framing_error <= (rx != 1);
                        rx_done <= 1;
                        state <= IDLE;
                    end 
                    else 
                      sample_cnt <= sample_cnt + 1;
                end
            endcase
        end
    end
endmodule
