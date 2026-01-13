// --- I2C Slave ---
module i2c_slave #(parameter SLAVE_ADDR = 7'h50)(
    input clk, rst, scl,
    inout sda,
    output reg [7:0] rx_data
);
    localparam IDLE = 0, 
               ADDR  = 1, 
               ACK_A = 2, 
               DATA  = 3,
               ACK_D = 4;
  
    reg [2:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg sda_drive;

    assign sda = (sda_drive) ? 1'b0 : 1'bz;

    reg scl_prev, sda_prev;
    
    always @(posedge clk) begin 
      scl_prev <= scl; 
      sda_prev <= sda; 
    end
    
    wire start = (scl && sda_prev && !sda);
    wire scl_rise = (!scl_prev && scl);
    wire scl_fall = (scl_prev && !scl);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; 
            sda_drive <= 0; 
            rx_data <= 0;
        end 
        else if (start) begin
            state <= ADDR; 
            bit_cnt <= 0;
        end 
        else begin
            case (state)
                ADDR: begin
                  if (scl_rise) begin
                    shift_reg <= {shift_reg[6:0], sda};
                    if (bit_cnt == 7) 
                      state <= ACK_A;
                    else 
                      bit_cnt <= bit_cnt + 1;
                  end
                end
                ACK_A: begin
                    if (scl_fall) 
                      sda_drive <= (shift_reg[7:1] == SLAVE_ADDR);
                    if (scl_rise) begin
                        sda_drive <= 0;
                        bit_cnt <= 0;
                        state <= (shift_reg[7:1] == SLAVE_ADDR) ? DATA : IDLE;
                    end
                end

                DATA: begin
                  if (scl_rise) begin
                    shift_reg <= {shift_reg[6:0], sda};
                  if (bit_cnt == 7) begin
                    state <= ACK_D;
                    rx_data <= {shift_reg[6:0], sda};
                    sda_drive <= 1'b1; 
                  end
                  else begin
                    bit_cnt <= bit_cnt + 1;
                  end
                  end
                end

                ACK_D: begin
                  if (scl_fall) begin
                    sda_drive <= 1'b1; 
                  end 
                  if (scl_fall && sda_drive) begin
                    sda_drive <= 1'b0; 
                    state <= IDLE;     
                  end
                end
            endcase
        end
    end
endmodule
