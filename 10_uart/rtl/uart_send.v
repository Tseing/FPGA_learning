module uart_send(
    input           sys_clk,
    input           sys_rst_n,
    input           uart_en,                    //发送使能信号
    input   [7:0]   uart_din,                   //待发送信号
    output  reg     uart_txd                    //uart发送端口
);

parameter CLK_FREQ = 50000000;                  //系统时钟
parameter UART_BPS = 9600;                      //串口波特率
localparam BPS_CNT = CLK_FREQ / UART_BPS;       //为得到特定波特率，对系统时钟计数BPS_CNT次

reg         uart_en_d0;                         //延迟一个周期的发送数据
reg         uart_en_d1;                         //延迟两个周期的发送数据
reg [15:0]  clk_cnt;                            //系统时钟计数器
reg [3:0]   tx_cnt;                             //发送数据计数器
reg         tx_flag;                            //发送过程标志
reg [7:0]   tx_data;                            //发送数据寄存器

wire en_flag;

//捕获uart_en的上升沿，得到时钟脉冲信号
assign en_flag = (~uart_en_d1) & uart_en_d0;

//对发送的使能信号uart_en延迟两个时钟周期
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        uart_en_d0 <= 1'b0;
        uart_en_d1 <= 1'b0;
    end
    else begin
        uart_en_d0 <= uart_en;
        uart_en_d1 <= uart_en_d0;
    end
end

//当脉冲信号en_flag到达时，寄存待发送的数据，进入发送过程
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        tx_flag <= 1'b0;
        tx_data <= 8'd0;
    end
    else if(en_flag) begin                      //检测到发送使能的上升沿
        tx_flag <= 1'b1;                        //进入发送过程，标志位tx_flag拉高
        tx_data <= uart_din;                    //寄存待发送数据
    end
    else if((tx_cnt==4'd9)&&(clk_cnt==BPS_CNT/2))
    begin                                       //计数至停止位中间，停止发送
        tx_flag <= 1'b0;
        tx_data <= 8'd0;
    end
    else begin
        tx_flag <= tx_flag;
        tx_data <= tx_data;
    end
end

//进入发送过程，启运系统时钟计数器和发送数据计数据
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        clk_cnt <= 16'd0;
        tx_cnt <= 4'd0;
    end
    else if(tx_flag) begin                      //进入发送过程
        if(clk_cnt<BPS_CNT-1) begin
            clk_cnt <= clk_cnt + 1'b1;
            tx_cnt <= tx_cnt;
        end
        else begin
            clk_cnt <= 16'd0;                   //系统时钟达一个波特率周期后清零
            tx_cnt <= tx_cnt + 1'b1;            //此时启动发送数据计数器
        end
    end
    else begin                                  //发送过程结束
        clk_cnt <= 16'd0;
        tx_cnt <= 4'd0;
    end
end

//根据计数器给uart发送端口赋值
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        uart_txd <= 1'b1;
    else if(tx_flag)
        case(tx_cnt)
            4'd0: uart_txd <= 1'b0;             //起始位
            4'd1: uart_txd <= tx_data[0];       //数据最低位
            4'd2: uart_txd <= tx_data[1];
            4'd3: uart_txd <= tx_data[2];
            4'd4: uart_txd <= tx_data[3];
            4'd5: uart_txd <= tx_data[4];
            4'd6: uart_txd <= tx_data[5];
            4'd7: uart_txd <= tx_data[6];
            4'd8: uart_txd <= tx_data[7];       //数据最高位
            4'd9: uart_txd <= 1'b1;             //停止位
            default: ;
        endcase
    else
        uart_txd <= 1'b1;                       //空闲时为高电平
end

endmodule