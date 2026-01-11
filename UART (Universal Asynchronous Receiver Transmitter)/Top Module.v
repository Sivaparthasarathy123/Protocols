`include "UART_TX.sv"
`include "UART_RX.sv"
`include "UART_BG.sv"
`timescale 1ns/1ps

module uart_top (
    input clk, rst, tx_start,
    input [7:0] tx_data,
    input par_en, par_ty, rx_ext,
    output tx_ext, rx_done, parity_error, framing_error,
    output [7:0] rx_data,
    output tx_busy
);
    wire b_tick, b16_tick;

    uart_baud_gen baud_inst (
        .clk(clk), 
        .rst(rst),
        .baud_tick(b_tick),
        .baud16_tick(b16_tick)
    );

    uart_tx tx_i (
        .clk(clk), 
        .rst(rst), 
        .baud_tick(b_tick),
        .tx_start(tx_start), 
        .tx_data(tx_data),
        .par_en(par_en), 
        .par_ty(par_ty),
        .tx(tx_ext), 
        .tx_busy(tx_busy)
    );

    uart_rx rx_i (
        .clk(clk), 
        .rst(rst), 
        .baud16_tick(b16_tick),
        .rx(rx_ext), 
        .par_en(par_en), 
        .par_ty(par_ty),
        .rx_data(rx_data), 
        .rx_done(rx_done),
        .parity_error(parity_error),
        .framing_error(framing_error)
    );
endmodule
