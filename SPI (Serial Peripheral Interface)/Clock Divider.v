// SPI Clock Divider
module spi_clk_gen #(
    parameter SYS_CLK = 50_000_000,
    parameter SPI_CLK = 10_000_000
)(
    input clk, rst,
    output reg tick
);
  
    localparam DIVIDER = SYS_CLK / (SPI_CLK * 2);
    reg [$clog2(DIVIDER):0] counter;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            tick <= 0;
        end 
        else begin
          if (counter == DIVIDER - 1) begin
                tick <= 1;
                counter <= 0;
           end 
           else begin
                tick <= 0;
                counter <= counter + 1;
            end
        end
    end
endmodule
