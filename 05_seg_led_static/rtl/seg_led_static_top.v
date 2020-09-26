module seg_led_static_top(
    input           sys_clk,
    input           sys_rst_n,
    output  [5:0]   sel,                        //位选
    output  [7:0]   seg_led                     //段选
);

parameter TIME_SHOW = 25'd25000_000;            //0.5s显示时间

wire add_flag;

seg_led_static u_seg_led_static(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .sel        (sel),
    .seg_led    (seg_led),
    .add_flag   (add_flag)
);

time_count #(.MAX_NUM(TIME_SHOW)
) u_time_count(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .flag       (add_flag)
);

endmodule