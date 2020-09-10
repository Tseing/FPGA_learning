module key_led(
    input                 sys_clk,
    input                 sys_rst_n,
    input        [3:0]    key,
    output reg   [3:0]    led
);

reg [23:0]  counter;
reg [1:0]   led_control;

//0.2s计数器
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        counter <= 24'd9_999_999;
    else if (counter <24'd9_999_999)
        counter <= counter + 1'b1;
    else
        counter <= 24'd0;
end

//0.2s计数标志
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led_control <= 2'b00;
    else if(counter == 24'd9_999_999)
        led_control <= led_control + 1'b1;
    else
        led_control <= led_control; 
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 4'b0000;
    else if(key[0]==0)                      //按键1
        case(led_control)                   //右向左
            2'b00   : led <= 4'b1000;
            2'b01   : led <= 4'b0100;
            2'b10   : led <= 4'b0010;
            2'b11   : led <= 4'b0001;
            default : led <= 4'b0000;
        endcase
    else if(key[1]==0)                      //按键2
        case (led_control)                  //左向右
            2'b00   : led <= 4'b0001;
            2'b01   : led <= 4'b0010;
            2'b10   : led <= 4'b0100;
            2'b11   : led <= 4'b1000;
            default : led <= 4'b0000;
        endcase
    else if(key[2]==0)                      //按键3
        case(led_control)                   //闪烁
            2'b00   : led <= 4'b1111;
            2'b01   : led <= 4'b0000;
            2'b10   : led <= 4'b1111;
            2'b11   : led <= 4'b1000;
            default : led <= 4'b0000;
        endcase
    else if(key[3]==0)                      //按键4
        led = 4'b1111;                      //点亮
    else
        led = 4'b0000;
end

endmodule