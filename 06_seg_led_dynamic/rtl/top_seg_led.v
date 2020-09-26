module top_seg_led(
    input           sys_clk,
    input           sys_rst_n,
    output  [5:0]   seg_sel,                //数码管亮灭
    output  [7:0]   seg_led                 //数码管led亮灭
);

wire    [19:0]  data;                       //数码管数据
wire    [5:0]   point;                      //数码管小数点
wire            en;                         //数码管显示使能
wire            sign;                       //数码管符号

seg_led u_seg_led(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .seg_sel    (seg_sel),                  //段选
    .seg_led    (seg_led),                  //位选
    .data       (data),
    .point      (point),
    .en         (en),
    .sign       (sign)                      //符号位，低电平显示负号
);

count u_count(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .data       (data),
    .point      (point),
    .en         (en),
    .sign       (sign)
);

endmodule