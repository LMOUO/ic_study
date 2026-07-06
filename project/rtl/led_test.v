module	led_test
(
	input	wire		sys_clk		,
	input	wire		sys_rst_n	,
	
	
	output	wire		o_led		
	
);

reg		[9:0]	cnt_test = 'd0;
always@(posedge sys_clk) begin
	if(sys_rst_n == 'd0) begin
		cnt_test	<=	'd0;
	end
	else begin
		cnt_test	<=	cnt_test + 'd1;
	end
end





assign	o_led = cnt_test[9];



endmodule
