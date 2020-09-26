module count(
    input               clk,
    input               rst_n,
    output  reg [19:0]  data,
    output  reg [5:0]   point,
    output  reg         en,
    output  reg         sign
);

parameter MAX_NUM = 23'd5000_000;               //计数器最大值，100ms

reg [22:0]  cnt;                                //计数器
reg         flag;                               //计数标志

//计数100ms
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt     <= 23'b0;
        flag    <= 1'b0;
    end
    else if(cnt<MAX_NUM - 1'b1) begin
        cnt     <= cnt + 1'b1;
        flag    <= 1'b0;
    end
    else begin
        cnt     <= 23'b0;
        flag    <= 1'b1;
    end
end

//改变数码管数据，从0累加至999999
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data    <= 20'b0;
        point   <= 6'b000000;
        en      <= 1'b0;
        sign    <= 1'b0;
    end
    else begin
        point   <= 6'b000000;                   //不显示小数点
        en      <= 1'b1;                        //打开显示使能
        sign    <= 1'b0;                        //不显示负号
        if(flag) begin                          //每100ms累加一次数码管数据
            if(data<20'd999999)
                data <= data + 1'b1;
            else
                data <= 20'b0;
        end
    end
end

endmodule