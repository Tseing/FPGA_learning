module fifo_rd(
    input           clk,
    input           rst_n,
    input   [7:0]   data,                   //输出数据
    input           rdfull,                 //读满标志
    input           rdempty,                //读空标志
    output          rdreq                   //读请求
);

reg         rdreq_t;                        //读信号
reg [7:0]   data_fifo;                      //读取数据
reg [1:0]   flow_cnt/*systhesis preserve*/; //状态流转计数

assign rdreq = ~rdempty & rdreq_t;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rdreq_t <= 1'b0;
        data_fifo <= 8'd0;
    end
    else begin
        case(flow_cnt)                      //状态不断流转
            2'd0: begin                     //检读满状态
                if(rdfull) begin            //读满（fifo中数据满）则读信号置1，进入下一状态
                    rdreq_t <= 1'b1;
                    flow_cnt <= flow_cnt + 1'b1;
                end
                else
                    flow_cnt <= flow_cnt;   //未读满继续等待
            end
            2'd1: begin                     //检读空状态
                if(rdempty) begin           //读空则读信号置0，清空读取数据，返回检读满状态
                    rdreq_t <= 1'b0;
                    data_fifo <= 8'd0;
                    flow_cnt <= 2'd0;
                end
                else begin                  //非读空则读信号置1，传出数据
                    rdreq_t <= 1'b1;
                    data_fifo <= data;
                end
            end
            default: flow_cnt <= 2'd0;
        endcase
    end
end

endmodule