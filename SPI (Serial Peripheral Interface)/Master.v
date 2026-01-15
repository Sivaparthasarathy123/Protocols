// SPI Master
module spi_master (
    input      clk, 
    input      rst, 
    input      start,
    input      tick,              // Pulse from divider
    input      [7:0] tx_data,
    output reg [7:0] rx_data,
    output reg ready,
    input      miso,
    output reg sclk, 
    output reg mosi, 
    output reg cs
);
    reg [1:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;

    localparam IDLE = 0, 
               START = 1, 
               SHIFT = 2, 
               DONE  = 3;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            sclk <= 0; 
            mosi <= 0; 
            cs <= 1;
            ready <= 1;
        end 
        else begin
            case (state)
                IDLE: begin
                    ready <= 1;
                    cs <= 1;
                    sclk <= 0;
                    if (start) begin
                        shift_reg <= tx_data;
                        bit_cnt <= 0;
                        ready <= 0;
                        state <= START;
                    end
                end

                START: begin
                    if (tick) begin
                        cs <= 0;
                        state <= SHIFT;
                    end
                end

                SHIFT: begin
                    if (tick) begin
                        if (sclk == 0) begin
                            sclk <= 1;
                            mosi <= shift_reg[7];
                        end 
                        else begin
                            sclk <= 0;
                            rx_data <= {rx_data[6:0], miso};
                            shift_reg <= {shift_reg[6:0], 1'b0};
                              if (bit_cnt == 7) 
                                state <= DONE;
                              else 
                                bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                DONE: begin
                    if (tick) begin
                        cs <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
