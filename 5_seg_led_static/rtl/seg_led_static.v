module seg_led_static(
    input               clk,
    input               rst_n,
    input               add_flag,               //变化标志
    output  reg [5:0]   sel,                    //位选
    output  reg [7:0]   seg_led                 //段选
);

reg [3:0]   num;                                //显示数字

always @(posedge clk or negedge rst_n) begin    //低电平有效
    if(!rst_n)
        sel <= 6'b111111;
    else
        sel <= 6'b000000;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        num <= 4'h0;
    else if(add_flag) begin
        if(num<4'hf)
            num <= num + 1'b1;
        else
            num <= 4'h0;
        end
        else
            num <= num;
    end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        seg_led <= 8'h0;
    else begin
        case(num)
            4'h0:    seg_led <= 8'b1100_0000;
            4'h1:    seg_led <= 8'b1111_1001;
            4'h2:    seg_led <= 8'b1010_0100;
            4'h3:    seg_led <= 8'b1011_0000;
            4'h4:    seg_led <= 8'b1001_1001;
            4'h5:    seg_led <= 8'b1001_0010;
            4'h6:    seg_led <= 8'b1000_0010;
            4'h7:    seg_led <= 8'b1111_1000;
            4'h8:    seg_led <= 8'b1000_0000;
            4'h9:    seg_led <= 8'b1001_0000;
            4'ha:    seg_led <= 8'b1000_1000;
            4'hb:    seg_led <= 8'b1000_0011;
            4'hc:    seg_led <= 8'b1100_0110;
            4'hd:    seg_led <= 8'b1010_0001;
            4'he:    seg_led <= 8'b1000_0110;
            4'hf:    seg_led <= 8'b1000_1110;
            default: seg_led <= 8'b0000_0000;
        endcase
    end
end

endmodule