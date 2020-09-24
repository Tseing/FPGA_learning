module uart_top(
    input           sys_clk,
    input           sys_rst_n,
    input           uart_rxd,           //uart接收端
    output          uart_txd            //uart发送端
);

parameter CLK_FREQ = 50000000;          //定义时钟频率
parameter UART_BPS = 115200;            //定义串口波特率

wire                uart_en_w;          //uart发送使能
wire        [7:0]   uart_data_w;        //uart发送数据
wire                clk_1m_w;           //SignalTap调试用1MHz时钟

clk_div u_pll(                          //时钟分频
    .inclk0         (sys_clk),
    .c0             (clk_1m_w)
);

uart_recv #(                            //串口接收模块
    .CLK_FREQ       (CLK_FREQ),
    .UART_BPS       (UART_BPS))
u_uart_recv(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .uart_rxd       (uart_rxd),
    .uart_done      (uart_en_w),
    .uart_data      (uart_data_w)
);

uart_send #(                            //串口发送模块
    .CLK_FREQ       (CLK_FREQ),
    .UART_BPS       (UART_BPS))
u_uart_send(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .uart_en        (uart_en_w),
    .uart_din       (uart_data_w),
    .uart_txd       (uart_txd)
);

endmodule