module time_count(
    input        clk,
    input        rst_n,
    output  reg  flag                   //计数标志
);

parameter   MAX_NUM = 25000_000;        //最大计数0.5s

reg [24:0]  cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        flag    <= 1'b0;
        cnt     <= 24'b0;
    end
    else if(cnt<MAX_NUM - 1'b1) begin
        flag    <= 1'b0;
        cnt     <= cnt + 1'b1;
    end
    else begin
        flag    <= 1'b1;
        cnt     <= 24'b0;
    end
end

endmodule