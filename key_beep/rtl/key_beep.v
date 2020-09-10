module top_key_beep(
    input      sys_clk;
    input      sys_rst_n;
    input      key;
    output     beep;
)

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