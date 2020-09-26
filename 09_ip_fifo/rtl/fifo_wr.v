module fifo_wr(
    input               clk,
    input               rst_n,
    input               wrempty,            //写空标志
    input               wrfull,             //写满标志
    output  reg [7:0]   data,               //写入数据
    output              wrreq               //写请求
);

reg         wrreq_t;                        //写信号
reg [1:0]   flow_cnt/*systhesis preserve*/; //状态流转计数

assign wrreq = ~wrfull & wrreq_t;

//向fifo中写入数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wrreq_t <= 1'b0;
        data <= 8'd0;
        flow_cnt <= 2'd0;
    end
    else begin
        case(flow_cnt)                      //状态不断流转
            2'd0: begin                     //检写空状态
                if(wrempty) begin           //写空时，写请求置1，进入下个状态
                    wrreq_t <= 1'b1;
                    flow_cnt <= flow_cnt +1'b1;
                end
                else
                    flow_cnt <= flow_cnt;   //非空则继续等待
            end
            2'd1: begin                     //检写满状态
                if(wrfull)begin             //写满时，写请求置0，清空写入数据，返回检写空状态
                    wrreq_t <= 1'b0;
                    data <= 8'd0;
                    flow_cnt <= 2'd0;
                end
                else begin                  //非满则写请求置1，生成写入数据
                    wrreq_t <= 1'b1;
                    data <= data + 1'd1;
                end
            end
            default: flow_cnt <= 2'd0;
        endcase
    end
end

endmodule