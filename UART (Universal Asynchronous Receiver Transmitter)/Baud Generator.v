// UART Baud Generator 
`timescale 1ns/1ps

module uart_baud_gen#(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 9600)
(
    input  clk, rst,
    output reg baud_tick,
    output reg baud16_tick
);
    localparam integer BAUD_DIV   = CLK_FREQ / BAUD_RATE;
    localparam integer BAUD16_DIV = CLK_FREQ / (BAUD_RATE * 16);

    reg [15:0] baud_cnt; 
    reg [15:0] baud16_cnt;

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
            baud_cnt <= 0; 
            baud16_cnt <= 0;
            baud_tick <= 0;  
            baud16_tick <= 0;
        end else begin
            // TX Tick
            if (baud_cnt >= BAUD_DIV - 1) begin
                baud_cnt <= 0; 
                baud_tick <= 1;
            end 
            else begin
                baud_cnt <= baud_cnt + 1; 
                baud_tick <= 0;
            end
            // RX Tick (16x)
            if (baud16_cnt >= BAUD16_DIV - 1) begin
                baud16_cnt <= 0; 
                baud16_tick <= 1;
            end 
            else begin
                baud16_cnt <= baud16_cnt + 1; 
                baud16_tick <= 0;
            end
        end
    end
endmodule
