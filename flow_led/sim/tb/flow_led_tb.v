`timescale 1ns/1ns      //仿真时间单位1ns 精度为1ns

module flow_led_tb();

parameter T = 20;       //时钟周期为20ns

reg sys_clk;
reg sys_rst_n;

wire [3:0]  led;


//输入信号初始值
initial begin
    sys_clk             = 1'b0;
    sys_rst_n           = 1'b0;
    #(T+1) sys_rst_n    = 1'b1;     //21ns时拉高复位信号
end


//每10ns电平反转一次，周期为20ns，即50MHz
always #(T/2) sys_clk = ~sys_clk;


//例化模块
flow_led u0_flow_led(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .led        (led)
);

endmodule