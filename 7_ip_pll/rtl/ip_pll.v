module ip_pll(
    input       sys_clk,
    input       sys_rst_n,
    output      clk_100m,               //100MHz
    output      clk_100m_180deg,        //100MHz，偏移180度
    output      clk_50m,                //50MHz
    output      clk_25m                 //25MHz
);

wire rst_n;                             //复位信号
wire locked;                            //locked信号拉高，锁相环开始稳定输出

assign rst_n = sys_rst_n & locked;      //系统复位和locked相与，其他模块复位信号

pll_clk u_pll_clk(
    .areset     (~sys_rst_n),           //锁相环高电平复位，系统复位信号取反
    .inclk0     (sys_clk),
    .c0         (clk_100m),
    .c1         (clk_100m_180deg),
    .c2         (clk_50m),
    .c3         (clk_25m),
    .locked     (locked)
);

endmodule