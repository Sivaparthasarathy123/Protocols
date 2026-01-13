// --- Clock Divider ---
module i2c_clock_divider #(parameter sys_clk_freq = 50_000_000, 
                           parameter i2c_clk_freq = 100_000)(
    input clk, rst,
    output reg scl_tick
);
    localparam clk_div = sys_clk_freq / (i2c_clk_freq * 2); 
    reg [$clog2(clk_div):0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            scl_tick <= 0;
        end 
        else if (counter == clk_div - 1) begin
            counter <= 0;
            scl_tick <= 1;
        end 
        else begin
            counter <= counter + 1;
            scl_tick <= 0;
        end
    end
endmodule
