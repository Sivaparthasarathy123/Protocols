// SPI Slave
module spi_slave (
  input      sclk,
  input      cs,
  input      mosi,
  input      [7:0] tx_data_slave,
  output reg miso,
  output reg [7:0] rx_data_slave);
  
  reg [2:0] bit_cnt;
  reg [7:0] shift_reg;
  
   // Load data when CS goes low
    always @(negedge cs) begin
        shift_reg <= tx_data_slave;
    end

    // Mode 0: Sample MOSI on Rising Edge
    always @(posedge sclk) begin
        if (!cs) begin
            rx_data_slave <= {rx_data_slave[6:0], mosi};
        end
    end

    // Mode 0: Shift out MISO on Falling Edge
    always @(negedge sclk) begin
        if (!cs) begin
            shift_reg <= {shift_reg[6:0], 1'b0};
        end
    end
    
    // Drive MISO line
    always @(*) begin
        if (!cs) 
          miso = shift_reg[7];
        else 
          miso = 1'bz; 
    end

endmodule
