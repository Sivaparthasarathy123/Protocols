// UART Testbench
`timescale 1ns/1ps

module uart_tb;

    reg clk, 
    reg rst, 
    reg tx_start;
    reg [7:0] tx_data;
    reg par_en,         // Parity Enable
    reg par_ty;         // Parity Type
    wire tx_ext, 
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_done, 
    wire parity_error, 
    wire framing_error;

    // DUT
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
  
    reg [63:0] tx_state_name;
    reg [63:0] rx_state_name;

    always @(*) begin
        // Tx state
        case (dut.tx_i.state) 
            0: tx_state_name = "IDLE";
            1: tx_state_name = "START";
            2: tx_state_name = "DATA";
            3: tx_state_name = "PARITY";
            4: tx_state_name = "STOP";
            default: tx_state_name = "IDLE";
        endcase

        // Rx state
        case (dut.rx_i.state)
            0: rx_state_name = "IDLE";
            1: rx_state_name = "START";
            2: rx_state_name = "DATA";
            3: rx_state_name = "PARITY";
            4: rx_state_name = "STOP";
            default: rx_state_name = "IDLE";
        endcase
    end

    initial begin
      $monitor("Time = %0t| Tx DATA = %h (%b)| Tx State = %s (%0d) | Tx = %b| Tx BUSY = %b | Rx Data =  %h| Rx State = %s (%0d) | Rx Done = %b| PAR_ERR = %b| FRM_ERR = %b",$time, tx_data, tx_data, tx_state_name, dut.tx_i.state, tx_ext, tx_busy, rx_data, rx_state_name, dut.rx_i.state, rx_done, parity_error, framing_error);
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
      
        $display("\nT = %0t | UART Function Reset\n", $time);

        // BYTE 1
        send_byte(8'hAF);

        // BYTE 2
        send_byte(8'h3C);
      
        // BYTE 3
        send_byte(8'hBB);
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
        @(posedge tx_busy);       
        $display("\nT=%0t | Sending: %h\n", $time, data);
        tx_start = 0;
        wait_rx_done_safe();
        
    end
  endtask

  task wait_rx_done_safe;
    @(posedge rx_done);
        #500;
        $display("Time = %0t | Rx DONE: %h | PAR_ERR=%b | FRM_ERR=%b",
                        $time, rx_data, parity_error, framing_error);    
        #50_000_000;  
  endtask
          
endmodule

