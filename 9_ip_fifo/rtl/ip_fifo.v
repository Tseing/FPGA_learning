module ip_fifo(
    input           sys_clk,
    input           sys_rst_n
);

wire                wrreq;          //写请求
wire        [7:0]   data;           //写入fifo数据
wire                wrempty;        //写侧空信号
wire                wrfull;         //写侧满信号
wire                wrusedw;        //写侧fifo数据量
wire                rdreq;          //读请求
wire        [7:0]   q;              //fifo输出数据
wire                rdempty;        //读侧空信号
wire                rdfull;         //读侧满信号
wire                rdusedw;        //读侧数据量

fifo u_fifo(
    .wrclk          (sys_clk),
    .wrreq          (wrreq),        //写请求
    .data           (data),         //写入fifo数据
    .wrempty        (wrempty),      //写侧空信号
    .wrfull         (wrfull),       //写侧满信号
    .wrusedw        (wrusedw),     //写侧数据量

    .rdclk          (sys_clk),
    .rdreq          (rdreq),        //读请求
    .q              (q),            //fifo输出数据
    .rdempty        (rdempty),      //读侧空信号
    .rdfull         (rdfull),       //读侧满信号
    .rdusedw        (rdusedw)       //读侧数据量
);

fifo_wr u_fifo_wr(
    .clk            (sys_clk),
    .rst_n          (sys_rst_n),
    .wrreq          (wrreq),        //写请求
    .data           (data),         //写入fifo数据
    .wrempty        (wrempty),      //写侧空信号
    .wrfull         (wrfull)        //写侧满信号
);

fifo_rd u_fifo_rd(
    .clk            (sys_clk),
    .rst_n          (sys_rst_n),
    .rdreq          (rdreq),        //读请求
    .data           (q),            //fifo输出数据
    .rdempty        (rdempty),      //读侧空信号
    .rdfull         (rdfull)        //读侧满信号
);

endmodule