// SPI - Testbench
`timescale 1ns/1ps

module spi_tb();
    reg clk, rst, start;
    reg [7:0] m_tx, s_tx;
    wire [7:0] m_rx, s_rx;
    wire ready;

    always #10 clk = ~clk;

    spi_top uut (
        .clk(clk), 
        .rst(rst), 
        .start(start),
        .m_tx_data(m_tx), 
        .s_tx_data(s_tx),
        .m_rx_data(m_rx), 
        .s_rx_data(s_rx),
        .ready(ready)
    );

    initial begin
        // Initialize
        clk = 0; 
        rst = 0; 
        start = 0;
        m_tx = 8'hA5; 
        s_tx = 8'h3C; 

        $display("--- Starting SPI Simulation ---");
        #100 rst = 1;
        #100 start = 1;
        #20  start = 0; // Pulse start signal
        
       $monitor("Time = %0t | rst = %0b | start = %0b | Ready = %0b | Master Tx Data = %0h | Master Rx Data = %0h | Slave Tx Data = %0h | Slave Rx Data = %0h", $time, rst, start, ready, m_tx, m_rx, s_tx, s_rx); 
       
       $dumpfile("spi.vcd");
       $dumpvars;

        // Wait for transaction to complete
        wait(ready == 0); // Wait for busy
        wait(ready == 1); // Wait for finished

        #100;
        $display("---------------------------------");
        $display("Master Sent: %h | Master Received: %h", m_tx, m_rx);
        $display("Slave Sent:  %h | Slave Received:  %h", s_tx, s_rx);
        
        if (m_rx == s_tx && s_rx == m_tx)
            $display("SUCCESS: Data Exchange Perfect.");
        else
            $display("ERROR: Data Mismatch Detected.");
        $display("---------------------------------");

        #100 $finish;
    end
endmodule
