module touch_led(
    input           sys_clk,
    input           sys_rst_n,
    input           touch_key,
    output  reg     led
);

reg     touch_key_d0;
reg     touch_key_d1;

wire    touch_en;

assign  touch_en = (~touch_key_d1)&touch_key_d0;    //新旧状态不同标志位

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n==1'b0) begin
        touch_key_d0 <= 1'b0;
        touch_key_d1 <= 1'b0;
    end
    else begin
        touch_key_d0 <= touch_key;                   //捕获触控新状态
        touch_key_d1 <= touch_key_d0;                //保持触控旧状态
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n==1'b0)
        led <= 1'b1;
    else if(touch_en)                               //按键状态发生变化时改变LED状态
        led <= ~led;
end

endmodule