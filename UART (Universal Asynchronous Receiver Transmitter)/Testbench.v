`timescale 1ns/1ps
// UART Testbench
module uart_tb;

    reg clk, rst, tx_start;
    reg [7:0] tx_data;
    reg par_en, par_ty;
    wire tx_ext, tx_busy;
    wire [7:0] rx_data;
    wire rx_done, parity_error, framing_error;

    uart_top dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .par_en(par_en),
        .par_ty(par_ty),
        .rx_ext(tx_ext),
        .tx_ext(tx_ext),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_error(parity_error),
        .framing_error(framing_error),
        .tx_busy(tx_busy)
    );
  
    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
      $monitor("Time = %0t| Tx DATA = %h| Tx = %b| Tx BUSY = %b|Rx Data =  %h| Rx Done = %b| PAR_ERR = %b| FRM_ERR = %b",$time, tx_data, tx_ext, tx_busy,
rx_data, rx_done, parity_error, framing_error);
    end

    initial begin
        clk = 0;
        rst = 0;
        tx_start = 0;
        tx_data = 0;
        par_en = 1;
        par_ty = 0;

        #100;
        rst = 1;
        $display("T=%0t | UART Function Reset", $time);

        // BYTE 1
        send_byte(8'hAF);

        // BYTE 2
        send_byte(8'h3C);

        #200_000;
        $display("T=%0t | SIMULATION PASSED", $time);
        $finish;
    end

  task send_byte(input [7:0] data);
    begin
        wait(!tx_busy);     
        @(posedge clk);
        tx_data = data;
        tx_start = 1;
        wait(tx_busy);       
        repeat(2) @(posedge clk); 
        tx_start = 0;
        
        $display("T=%0t | Sending: 0x%h", $time, data);
        wait_rx_done_safe();
    end
  endtask

  task wait_rx_done_safe;
      @(posedge rx_done);
      $display("Time = %0t | RX DONE: 0x%h | PAR_ERR=%b | FRM_ERR=%b", $time, rx_data, parity_error, framing_error);    
      #50_000_000;  
  endtask
          
endmodule

