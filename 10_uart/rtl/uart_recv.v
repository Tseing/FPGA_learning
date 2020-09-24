module uart_recv(
    input               sys_clk,
    input               sys_rst_n,
    input               uart_rxd,               //uart接收端口
    output  reg         uart_done,              //接收完一帧数据完成标志信号
    output  reg [7:0]   uart_data               //接收的数据
);

parameter CLK_FREQ = 50000000;                  //系统时钟频率
parameter UART_BPS = 9600;                      //串口波特率
localparam BPS_CNT = CLK_FREQ / UART_BPS;       //对系统时钟计数BPS_CNT次
                                                //即当前波特率下，串口传输1位需要的系统时钟数

reg         uart_rxd_d0;                        //延迟一个周期的接收数据
reg         uart_rxd_d1;                        //延迟两个周期的接收数据
reg [15:0]  clk_cnt;                            //系统时钟计数器
reg [3:0]   rx_cnt;                             //接收数据计数器
reg         rx_flag;                            //接收过程标志信号
reg [7:0]   rxdata;                             //接收数据寄存器

wire start_flag;

//捕获接收端口下降沿（起始位），得到一个时钟周期的脉冲信号，有旧数据无新数据时置1（检测下降沿）
assign srart_flag = uart_rxd_d1 & (~uart_rxd_d0);

//对uart接收端口的数据（电平）延迟两个时钟周期
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        uart_rxd_d0 <= 1'b0;
        uart_rxd_d1 <= uart_rxd_d0;
    end
end

//当脉冲start_flag到达时，进入接收过程
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        rx_flag <= 1'b1;
    else begin
        if(start_flag)                          //进入接收过程
            rx_flag <= 1'b1;
        else if((rx_cnt==4'd9)&&(clk_cnt==BPS_CNT/2))
            rx_flag <= 1'b0;                    //计数至停止位中间，停止接收
        else
            rx_flag <= rx_flag;
    end
end

//进入接收过程后，启动系统时钟计数器和接收数据计数器
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        clk_cnt <= 16'd0;
        rx_cnt <= 4'd0;
    end
    else if(rx_flag) begin                      //处于接收过程
        if(clk_cnt<BPS_CNT-1) begin
            clk_cnt <= clk_cnt + 1'b1;
            rx_cnt <= rx_cnt;
        end
        else begin                              //0~BPS_CNT-1恰好完成1位数据传输
            clk_cnt <= 16'd0;                   //计数到达一个波特率周期后，系统时钟计时器清零
            rx_cnt <= rx_cnt + 1'b1;            //接收数据计数器开始计数，判断是第几位数据
        end
    end
    else begin                                  //非接收过程，计数器全部清零
        clk_cnt <= 16'd0;
        rx_cnt <= 4'd0;
    end
end

//根据接收数据计时器来寄存uart端口数据
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        rxdata <= 8'd0;
    else if(rx_flag)                            //系统处于接收过程
        if(clk_cnt==BPS_CNT/2)begin             //系统时钟计数器位于数据中位，此时采样最稳定
            case(rx_cnt)
                4'd1: rxdata[0] <= uart_rxd_d1;
                4'd2: rxdata[1] <= uart_rxd_d1;
                4'd3: rxdata[2] <= uart_rxd_d1;
                4'd4: rxdata[3] <= uart_rxd_d1;
                4'd5: rxdata[4] <= uart_rxd_d1;
                4'd6: rxdata[5] <= uart_rxd_d1;
                4'd7: rxdata[6] <= uart_rxd_d1;
                4'd8: rxdata[7] <= uart_rxd_d1;
                default: ;
            endcase
        end
        else
            rxdata <= rxdata;
    else
        rxdata <= 8'd0;
end

//数据接收完毕并寄存接收到的数据
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        uart_data <= 8'd0;
        uart_done <= 1'b0;
    end
    else if(rx_cnt==4'd9) begin                 //接收数据计数器位于停止位
        uart_data <= rxdata;                    //寄存接收到的数据
        uart_done <= 1'b1;                      //数据接收完成标志
    end
    else begin
        uart_data <= 8'd0;
        uart_done <= 1'b0;
    end
end

endmodule