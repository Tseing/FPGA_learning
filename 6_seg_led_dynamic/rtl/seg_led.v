module seg_led(
    input               clk,
    input               rst_n,
    input       [19:0]  data,               //显示数据 
    input       [5:0]   point,              //小数点位置，从高位到低位，高电平有效
    input               en,                 //数码管显示使能
    input               sign,               //符号位，高电平显示负号
    output  reg [5:0]   seg_sel,            //位选
    output  reg [7:0]   seg_led             //段选
);

localparam CLK_DIVIDE = 4'd10;              //时钟分频系数
localparam MAX_NUM = 13'd5000;              //数码管驱动时钟5MHz计数1ms

reg     [3:0]   clk_cnt;                    //时钟分频计数器
reg             dri_clk;                    //数码管驱动时钟5MHz
reg     [23:0]  num;                        //24位bcd码
reg     [12:0]  cnt0;                       //数码管计数器
reg             flag;                       //数码管计数器标志
reg     [2:0]   cnt_sel;                    //位选计数器
reg     [3:0]   num_disp;                   //当前数据
reg             dot_disp;                   //当前小数点

wire    [3:0]   data0;                      //个
wire    [3:0]   data1;                      //十
wire    [3:0]   data2;                      //百
wire    [3:0]   data3;                      //千
wire    [3:0]   data4;                      //万
wire    [3:0]   data5;                      //十万


assign data0 = data % 4'd10;                //个
assign data1 = data / 4'd10 % 4'd10;        //十
assign data2 = data / 7'd100 % 4'd10;       //百
assign data3 = data / 10'd1000 % 4'd10;     //千
assign data4 = data / 14'd10000 % 4'd10;    //万
assign data5 = data / 17'd100000;           //十万

//系统时钟10分频，得到5MHz的数码管驱动时钟dri_clk
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        clk_cnt <= 4'd0;
        dri_clk <= 1'b1;
    end
    else if(clk_cnt==CLK_DIVIDE/2 - 1'd1) begin
        clk_cnt <= 4'd0;
        dri_clk <= ~dri_clk;
    end
    else begin
        clk_cnt <= clk_cnt + 1'b1;
        dri_clk <= dri_clk;
    end 
end


//将20位二进制数转换为8421bcd码
always @(posedge dri_clk or negedge rst_n) begin
    if(!rst_n)
        num <= 24'b0;
    else begin
        if(data5||point[5]) begin           //显示6位十进制数
            num[23:20] <= data5;
            num[19:16] <= data4;
            num[15:12] <= data3;
            num[11:8]  <= data2;
            num[7:4]   <= data1;
            num[3:0]   <= data0;
        end
        else begin
            if(data4||point[4]) begin       //显示5位十进制数
                num[19:0] <= {data4, data3, data2, data1, data0};
                if(sign)
                    num[23:20] <= 4'd11;    //若显示负号，最高位为符号位
                else
                    num[23:20] <= 4'd10;    //若不显示负号，最高位不显示
            end
            else begin
                if(data3||point[3]) begin   //显示4位十进制数
                    num[15:0]  <= {data3, data2, data1, data0};
                    num[23:20] <= 4'd10;
                    if(sign)
                        num[19:16] <= 4'd11;
                    else
                        num[19:16] <= 4'd10;
                end
                else begin
                    if(data2||point[2]) begin   //显示3位十进制数
                        num[11:0]  <= {data2, data1, data0};
                        num[23:16] <= {2{4'd10}};
                        if(sign)
                            num[15:12] <= 4'd11;
                        else
                            num[15:12] <= 4'd10;
                    end
                    else begin
                        if(data1||point[1]) begin   //显示2位十进制数
                            num[7:0]   <= {data1, data0};
                            num[23:12] <= {3{4'd10}};
                            if(sign)
                                num[11:8] <= 4'd11;
                            else
                                num[11:8] <= 4'd10;
                        end
                        else begin                 //显示1位十进制数         
                            num[3:0]  <= data0;
                            num[23:8] <= {4{4'd10}};
                            if(sign)
                                num[7:4] <= 4'd11;
                            else
                                num[7:4] <= 4'd10;
                        end
                    end
                end
            end
        end
    end
end

//产生周期为1ms的脉冲
always @(posedge dri_clk or negedge rst_n) begin
    if(rst_n==1'b0) begin
        cnt0 <= 13'b0;
        flag <= 1'b0;
    end
    else if(cnt0<MAX_NUM - 1'b1) begin
        cnt0 <= cnt0 + 1'b1;
        flag <= 1'b0;
    end
    else begin
        cnt0 <= 13'b0;
        flag <= 1'b1;
    end
end

//cnt_sel从0计数至5，选择当前显示的数码管
always @(posedge dri_clk or negedge rst_n) begin
    if(rst_n==1'b0)
        cnt_sel <= 3'b0;
    else if(flag) begin
        if(cnt_sel <3'd5)
            cnt_sel <= cnt_sel + 1'b1;
        else
            cnt_sel <= 3'b0;
    end
    else
        cnt_sel <= cnt_sel;
end


//数码管位选，轮流显示
always @(posedge dri_clk or negedge rst_n) begin
    if(!rst_n) begin
        seg_sel     <= 6'b111111;                   //位选信号低电平有效
        num_disp    <= 4'b0;                        //显示数据
        dot_disp    <= 1'b1;                        //小数点，低电平有效
    end
    else begin
        if(en) begin
            case(cnt_sel)                           //数码管显示位数
                3'd0: begin
                    seg_sel     <= 6'b111110;       //显示第0位
                    num_disp    <= num[3:0];        //显示数据
                    dot_disp    <= ~point[0];       //显示小数点
                end
                3'd1: begin
                    seg_sel     <= 6'b111101;       //显示第1位
                    num_disp    <= num[7:4];
                    dot_disp    <= ~point[1];
                end
                3'd2: begin
                    seg_sel     <= 6'b111011;       //显示第0位
                    num_disp    <= num[11:8];
                    dot_disp    <= ~point[2];
                end
                3'd3: begin
                    seg_sel     <= 6'b110111;       //显示第0位
                    num_disp    <= num[15:12];
                    dot_disp    <= ~point[3];
                end
                3'd4: begin
                    seg_sel     <= 6'b101111;       //显示第0位
                    num_disp    <= num[19:16];
                    dot_disp    <= ~point[4];
                end
                3'd5: begin
                    seg_sel     <= 6'b011111;       //显示第0位
                    num_disp    <= num[23:20];
                    dot_disp    <= ~point[5];
                end
                default: begin
                    seg_sel     <= 6'b111111;
                    num_disp    <= 4'b0;
                    dot_disp    <= 1'b1;
                end
            endcase
        end
        else begin                                  //使能信号为0，不显示
            seg_sel     <= 6'b111111;
            num_disp    <= 4'b0;
            dot_disp    <= 1'b1;
        end
    end
end

//数码管段选，显示字符
always @(posedge dri_clk or negedge rst_n) begin
    if(!rst_n)
        seg_led <= 8'hc0;
    else begin
        case(num_disp)
            4'd0: seg_led <= {dot_disp, 7'b1000000};    //0
            4'd1: seg_led <= {dot_disp, 7'b1111001};    //1
            4'd2: seg_led <= {dot_disp, 7'b0100100};    //2
            4'd3: seg_led <= {dot_disp, 7'b0100100};    //3
            4'd4: seg_led <= {dot_disp, 7'b0011001};    //4
            4'd5: seg_led <= {dot_disp, 7'b0010010};    //5
            4'd6: seg_led <= {dot_disp, 7'b0000010};    //6
            4'd7: seg_led <= {dot_disp, 7'b1111000};    //7
            4'd8: seg_led <= {dot_disp, 7'b0000000};    //8
            4'd9: seg_led <= {dot_disp, 7'b0010000};    //9
            4'd10: seg_led <= 8'b1111111;               //不显示
            4'd11: seg_led <= 8'b1011111;               //负号
            default:
                seg_led <= {dot_disp, 7'b1000000};
        endcase
    end
end

endmodule