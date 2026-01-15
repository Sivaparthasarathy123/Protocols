// Top Module
`include "clock_divider.sv"
`include "Master.sv"
`include "Slave.sv"

module spi_top(
    input  clk, 
    input  rst, 
    input  start,
    input  [7:0] m_tx_data,
    input  [7:0] s_tx_data,
    output [7:0] m_rx_data,
    output [7:0] s_rx_data,
    output ready
);
    wire tick_w, sclk_w, mosi_w, miso_w, cs_w;

    spi_clk_gen #(.SYS_CLK(50_000_000), .SPI_CLK(10_000_000)) clk_inst (
        .clk(clk), 
        .rst(rst), 
        .tick(tick_w)
    );

    spi_master master_inst (
        .clk(clk), 
        .rst(rst), 
        .start(start), 
        .tick(tick_w),
        .tx_data(m_tx_data), 
        .rx_data(m_rx_data), 
        .ready(ready),
        .miso(miso_w), 
        .sclk(sclk_w), 
        .mosi(mosi_w), 
        .cs(cs_w)
    );

    spi_slave slave_inst (
        .sclk(sclk_w), 
        .cs(cs_w), 
        .mosi(mosi_w), 
        .miso(miso_w),
        .tx_data_slave(s_tx_data), 
        .rx_data_slave(s_rx_data)
    );
endmodule
