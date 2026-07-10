`include "../rtl/mem_sdp_sync.v"

module	sync_fifo_my
#(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 128	
)
(
	input	wire								sys_clk			,
	input	wire								sys_rst_n		,
				
	input	wire	[DATA_WIDTH-1:0]			i_wr_data		,
	input	wire								i_wr_en			,
				
	output	wire	[DATA_WIDTH-1:0]			o_rd_data		,
	output	wire								o_rd_valid		,
	input	wire								i_rd_en			,
	
	output	wire	[$clog2(FIFO_DEPTH+1)-1:0]	o_data_count	,
	
	output	wire								o_fifo_full		,
	output	wire								o_fifo_empty	
	
);


localparam ADDR_WIDTH  = (FIFO_DEPTH <= 1) ? 1 : $clog2(FIFO_DEPTH);
localparam COUNT_WIDTH = $clog2(FIFO_DEPTH + 1);
localparam [ADDR_WIDTH-1:0] LAST_ADDR = FIFO_DEPTH - 1;
localparam [COUNT_WIDTH-1:0] DEPTH_COUNT = FIFO_DEPTH;

reg		[COUNT_WIDTH-1:0]	data_cnt;
//空满信号判断
wire	empty = (data_cnt == {COUNT_WIDTH{1'b0}}) 	? 1'd1 : 1'd0;
wire	full  = (data_cnt == DEPTH_COUNT) 			? 1'd1 : 1'd0;
//有效写信号判断和有效读信号判断
wire	wr_fire = i_wr_en & !full;
wire	rd_fire = i_rd_en & !empty;


//写指针功能块
reg		[ADDR_WIDTH-1:0]	wr_ptr					; //写指针
always@(posedge sys_clk or negedge sys_rst_n) begin
	if(sys_rst_n == 1'b0) begin
		wr_ptr	<=	{ADDR_WIDTH{1'd0}};
	end
	else if(wr_fire == 1'd1 && wr_ptr == LAST_ADDR) begin
		wr_ptr	<=	{ADDR_WIDTH{1'b0}};
	end
	else if(wr_fire == 1'd1)begin
		wr_ptr	<=	wr_ptr + 1'd1;
	end
end

//读指针功能块
reg		[ADDR_WIDTH-1:0]	rd_ptr					; //读指针
always@(posedge sys_clk or negedge sys_rst_n) begin
	if(sys_rst_n == 1'b0) begin
		rd_ptr	<=	{ADDR_WIDTH{1'd0}};
	end
	else if(rd_fire == 1'd1 && rd_ptr == LAST_ADDR) begin
		rd_ptr	<=	{ADDR_WIDTH{1'b0}};
	end
	else if(rd_fire == 1'd1)begin
		rd_ptr	<=	rd_ptr + 1'd1;
	end
end

wire [DATA_WIDTH-1:0] mem_rd_data;
mem_sdp_sync #(
    .DATA_WIDTH (DATA_WIDTH),
    .MEM_DEPTH  (FIFO_DEPTH)
) 
u_mem_sdp_sync 
(
    .clk      (sys_clk),

    .wr_en    (wr_fire),
    .wr_addr  (wr_ptr),
    .wr_data  (i_wr_data),

    .rd_en    (rd_fire),
    .rd_addr  (rd_ptr),
    .rd_data  (mem_rd_data)
);


//打一拍使能，方便输出数据对齐
reg		rd_fire_d;
always@(posedge sys_clk or negedge sys_rst_n) begin
	if(sys_rst_n == 1'd0) begin
		rd_fire_d	<=	1'b0;
	end
	else  begin
		rd_fire_d	<=	rd_fire;
	end
end

//有效数据个数控制
always@(posedge sys_clk or negedge sys_rst_n) begin
	if(sys_rst_n == 1'b0) begin
		data_cnt	<=	1'd0;
	end
	else begin
		case({wr_fire, rd_fire})
			2'b00 : data_cnt <= data_cnt;
			2'b01 : data_cnt <= data_cnt - 1'd1;
			2'b10 : data_cnt <= data_cnt + 1'd1;
			2'b11 : data_cnt <= data_cnt;
		endcase
	end
end

assign	o_fifo_full 	= 	full		;
assign	o_fifo_empty	=	empty		;
assign	o_rd_data		=	mem_rd_data	;
assign	o_rd_valid		=	rd_fire_d	;
assign	o_data_count	=	data_cnt	;


endmodule


