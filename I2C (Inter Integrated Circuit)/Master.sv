// --- I2C Master ---
module i2c_master (
    input clk, rst, 
    input [6:0] addr,
    input [7:0] din,
    input scl_tick,
    output reg done,
    inout scl, sda
);
    localparam IDLE = 0, 
               START = 1, 
               ADDR  = 2, 
               ACK_A = 3, 
               WRITE = 4, 
               ACK_D = 5, 
               STOP  = 6;
    
    reg [2:0] state;
    reg [3:0] bit_cnt;
    reg sda_out, scl_out;

    assign sda = (sda_out) ? 1'bz : 1'b0;
    assign scl = (scl_out) ? 1'bz : 1'b0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; 
            sda_out <= 1; 
            scl_out <= 1; 
            done <= 0;
        end 
        else if (scl_tick) begin
            case (state)
                IDLE: begin
                    done <= 0; 
                    sda_out <= 1; 
                    scl_out <= 1;
                    state <= START;
                end
               
                START: begin
                    sda_out <= 0; 
                    bit_cnt <= 7;
                    state <= ADDR;
                end
                
                ADDR: begin
                    scl_out <= ~scl_out;
                  if (scl_out) begin // Changing data
                        if (bit_cnt > 0) begin
                            sda_out <= addr[bit_cnt-1];
                            bit_cnt <= bit_cnt - 1;
                        end 
                        else begin
                            sda_out <= 0; // Write bit
                            state <= ACK_A;
                        end
                    end
                end
                
                ACK_A: begin
                    scl_out <= ~scl_out;
                    if (scl_out) begin
                        sda_out <= 1; // Release for ACK
                        bit_cnt <= 7;
                        state <= WRITE;
                    end
                end
                
                WRITE: begin
                    scl_out <= ~scl_out;
                    if (scl_out) begin
                        sda_out <= din[bit_cnt];
                        if (bit_cnt == 0) 
                          state <= ACK_D;
                        else 
                          bit_cnt <= bit_cnt - 1;
                    end
                end

                ACK_D: begin
                    scl_out <= ~scl_out;
                    if (scl_out) begin 
                      sda_out <= 1'b1;
                    end 
                    else begin 
       
                    end
                    if (bit_cnt == 0 && scl_out) 
                      state <= STOP; 
                end
                
                STOP: begin
                    if (!scl_out) 
                       scl_out <= 1;
                    else begin
                        sda_out <= 1; 
                        done <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
