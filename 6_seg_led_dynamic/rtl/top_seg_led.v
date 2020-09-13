module top_seg_led(
    input           sys_clk,
    input           sys_rst_n,
    output  [5:0]   sel,
    output  [7:0]   seg_led
);

wire    [19:0]  data;
wire    [5:0]   point;
wire            en;
wire            sign;

seg_led u_seg_led(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .sel        (sel),
    .seg_led    (seg_led),
    .data       (data),
    .point      (point),
    .en         (en),
    .sign       (sign)
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