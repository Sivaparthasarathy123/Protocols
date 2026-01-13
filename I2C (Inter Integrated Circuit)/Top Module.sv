`include "Master.sv"
`include "Slave.sv"
`include "clock_divider.sv"
// --- Top Module ---
module i2c_top(
    input clk, rst, 
    input [6:0] addr,
    input [7:0] master_din,
    output [7:0] slave_rx_out
);
    wire scl, sda, tick;
  
    i2c_clock_divider clk_gen (clk, rst, tick);
    i2c_master mstr (clk, rst, addr, master_din, tick, done, scl, sda);
    i2c_slave #(7'h50) slv (clk, rst, scl, sda, slave_rx_out);
endmodule
