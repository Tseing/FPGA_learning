module lcd_display(
    input               lcd_clk,                    //lcd驱动时钟
    input               sys_rst_n,                  //复位信号

    input       [10:0]  pixel_xpos,                 //像素点横坐标
    input       [10:0]  pixel_ypos,                 //像素点纵坐标
    output  reg [15:0]  pixel_data                  //像素点数据
);

parameter   H_DISP  = 11'd480;                      //行分辨率
parameter   V_DISP  = 11'd272;                      //列分辨率
localparam  WHITE   = 16'b11111_111111_11111;       //RGB565 白色
localparam  BLACK   = 16'b00000_000000_00000;       //RGB565 黑色
localparam  RED     = 16'b11111_000000_00000;       //RGB565 红色
localparam  GREEN   = 16'b00000_111111_00000;       //RGB565 绿色
localparam  BLUE    = 16'b00000_000000_11111;       //RGB565 蓝色

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pixel_data <= 16'd0;
    else begin
        if((pixel_xpos>=0)&&(pixel_xpos<(H_DISP/5)*1))
            pixel_data <= WHITE;
        else if((pixel_xpos>=(H_DISP/5)*1)&&(pixel_xpos<(H_DISP/5)*2))
            pixel_data <= BLACK;
        else if((pixel_xpos>=(H_DISP/5)*2)&&(pixel_xpos<(H_DISP/5)*3))
            pixel_data <= RED;
        else if((pixel_xpos>=(H_DISP/5)*3)&&(pixel_xpos<(H_DISP/5)*4))
            pixel_data <= GREEN;
        else
            pixel_data <= BLUE;
    end
end

endmodule