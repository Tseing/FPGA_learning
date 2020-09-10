`timescale 1ns/1ns

module key_led_tb();

parameter T = 20;

reg [3:0]   key;
reg         sys_clk;
reg         sys_rst_n;
reg         key_value;

wire [3:0]  led;

initial begin
    key             <= 4'b1111;
    sys_clk         <= 1'b0;
    sys_rst_n       <= 1'b0;
    #T  sys_rst_n   <= 1'b1;

    #600_000_020 key[0] <= 0;               //0.6s，按键1
    #800_000_000 key[0] <= 1;
    key[1]              <= 0;               //0.8s，按键2
    #800_000_000 key[1] <= 1;
    key[2]              <= 0;               //0.8s，按键3
    #800_000_000 key[2] <= 1;
    key[3]              <= 0;               //0.8s，按键4
    #800_000_000 key[3] <= 1;

end

always #(T/2) sys_rst_n <= ~sys_clk;        //50MHz

key_led u_key_led(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .key        (key),
    .led        (led)
);

endmodule