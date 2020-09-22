module ram_rw(
    input               clk,
    input               rst_n,
    output              ram_wr_en,              //写入使能
    output              ram_rd_en,              //读取使能
    output  reg [4:0]   ram_addr,               //读写地址
    output  reg [7:0]   ram_wr_data,            //写数据
    input       [7:0]   ram_rd_data             //读数据
);

reg [5:0]   rw_cnt;                             //读写控制计数器

//rw_cnt计数在0~31之间时，写入使能为1
assign ram_wr_en = ((rw_cnt>=6'd0)&&(rw_cnt<=6'd31)) ? 1'b1:1'b0;

//rw_cnt计数在32~63之间时，读取使能为1
assign ram_rd_en = ((rw_cnt>=6'd32)&&(rw_cnt<=6'd63)) ? 1'b1:1'b0;

//wr_cnt计数器，计数范围）0~63
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)
        rw_cnt <= 6'd0;
    else if(rw_cnt==6'd63)
        rw_cnt <= 6'd0;
    else
        rw_cnt <= rw_cnt + 6'd1;
end

//rw_cnt计数在0~31之间时，产生写入数据
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)
        ram_wr_data <= 8'd0;
    else if(rw_cnt>=6'd0&&rw_cnt<=6'd31)
        ram_wr_data <= ram_wr_data + 8'd1;
    else
        ram_wr_data <= 8'd0;
end

//4位的ram存储地址递增，地址范围0~31
always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)
        ram_addr <= 5'd0;
    else if(ram_addr==5'd31)
        ram_addr <= 5'd0;
    else
        ram_addr <= ram_addr + 1'b1;
end

endmodule