module key_beep(
    input      sys_clk,
    input      sys_rst_n,
    input      key,
    output     beep
);

wire key_value;
wire key_flag;


key_debounce u_key_debounce(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .key            (key),
    .key_flag       (key_flag),
    .key_value      (key_value)
);

beep_control u_beep_control(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .key_value      (key_value),
    .key_flag       (key_flag),
    .beep           (beep)
);

endmodule

module key_debounce(
    input       sys_clk,
    input       sys_rst_n,
    input       key,
    output  reg key_flag,           //按键有效标志
    output  reg key_value           //按键消抖数据
);

reg [31:0]  delay_cnt;
reg         key_reg;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        key_reg     <= 1'b1;                            //装入初始值
        delay_cnt   <= 32'd0;
    end
    else begin
       key_reg  <= key;                                 //装入初始值
       if(key_reg!=key)                                 //按键状态发生变化
            delay_cnt <= 32'd1_000_000;                 //计数器装入初始值，20ms
        else if(key_reg==key) begin                     //按键状态保持不变，计数器开始递减，20ms倒计时
            if(delay_cnt>32'd0)
                delay_cnt <= delay_cnt -1'b1;
            else
                delay_cnt <= delay_cnt; 
        end
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        key_flag    <= 1'b0;
        key_value   <= 4'b1;
    end
    else begin
       if(delay_cnt==32'd1) begin                       //20ms计数完成
           key_flag     <= 1'b1;                        //标志完成
           key_value    <= key;                         //记录此时按键数据
       end 
       else begin
           key_flag     <= 1'b0;                        //标志未完成
           key_value    <= key_value;                   //不记录此时按键数据
       end
    end
end
endmodule

module beep_control(
    input       sys_clk,
    input       sys_rst_n,
    input       key_flag,
    input       key_value,
    output  reg beep
);

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        beep <= 1'b1;                                   //蜂鸣器鸣叫
    else if(key_flag&&(~key_value))                     //按键有数据且标志消抖完成
        beep <= ~beep;                                  //改变蜂鸣器状态
end
endmodule