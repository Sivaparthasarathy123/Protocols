// Testbench
`timescale 1ns/1ps
module tb_i2c();
    reg clk, rst; 
    reg [6:0] addr;
    reg [7:0] data;
    wire [7:0] rx;

    i2c_top uut (clk, rst, addr, data, rx);

    pullup(uut.sda); 
    pullup(uut.scl);

    always #5 clk = ~clk;

    reg [2:0] prev_state;
    reg scl_delayed; 

    always @(posedge clk) begin
        prev_state <= uut.mstr.state;
        scl_delayed <= uut.scl;
    end

  always @(posedge clk) begin
    if (!rst) begin
            //  Monitor Address Transmission Start
            if (uut.mstr.state == 1 && prev_state == 0)
              $display("\n[Process @ %0t] Master: Generating START Condition", $time);

            if (uut.mstr.state == 2 && prev_state == 1)
              $display("[Process @ %0t] Master: Beginning Address Transmission (7'h%h and Write)", $time, addr);

            //  Monitor Address ACK/NACK
            if (uut.mstr.state == 3 && uut.scl == 1 && scl_delayed == 0) begin
                if (uut.sda == 0)
                  $display("[Process @ %0t] Master: Address ACK Received from Slave!", $time);
                else
                  $display("[Process @ %0t] Master: Address NACK! No Slave responded.", $time);
            end

            // Monitor Data Transmission Start
            if (uut.mstr.state == 4 && prev_state == 3)
              $display("[Process @ %0t] Master: Starting Data Transmission (8'h%h)", $time, data);

            // Monitor Data ACK/NACK
            if (uut.mstr.state == 5 && uut.scl == 1 && scl_delayed == 0) begin
            #1; 
            if (uut.sda == 0)
              $display("[Process @ %0t] Master: Data ACK Received!", $time);
            else
              $display("[Process @ %0t] Master: Data NACK Received!", $time);
            end

            // Monitor Stop Condition
            if (uut.mstr.state == 6 && prev_state == 5)
              $display("[Process @ %0t] Master: Generating STOP Condition.\n", $time);
        end
    end
  
    initial begin
      $monitor("Time=%0t | State=%0d | SCL=%b | SDA=%b |  SlaveRx=%h", $time, uut.mstr.state, uut.scl, uut.sda, rx);
    end

    initial begin
      $dumpfile("i2c.vcd");
      $dumpvars;
        clk=0; rst=1; addr=7'h50; data=8'hA5;
        #100 rst=0;
        wait(uut.mstr.done);
        #100;
        if (rx == 8'hA5) 
            $display("MATCH PERFECT: Slave received 0x%h", rx);
        else 
            $display("ERROR: Slave received 0x%h", rx);
        $finish;
    end
endmodule
