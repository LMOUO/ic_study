//1R1W SRAM
module mem_sdp_sync
#(
    parameter DATA_WIDTH = 8,
    parameter MEM_DEPTH  = 128,
    parameter ADDR_WIDTH = (MEM_DEPTH <= 1) ? 1 : $clog2(MEM_DEPTH)
)
(
    input  wire                     clk,

    input  wire                     wr_en,
    input  wire [ADDR_WIDTH-1:0]    wr_addr,
    input  wire [DATA_WIDTH-1:0]    wr_data,

    input  wire                     rd_en,
    input  wire [ADDR_WIDTH-1:0]    rd_addr,
    output wire [DATA_WIDTH-1:0]    rd_data
);

`ifdef USE_SRAM_MACRO

    /*
     * SKY130 SRAM宏：  
     * 8 bit × 1024 word
     *
     * 当前FIFO深度128，只使用地址0～127。
     */
    localparam SRAM_ADDR_WIDTH = 10;

    wire [SRAM_ADDR_WIDTH-1:0] sram_wr_addr;
    wire [SRAM_ADDR_WIDTH-1:0] sram_rd_addr;
    wire [7:0] unused_dout0;

    /*
     * 仅允许：
     * DATA_WIDTH = 8
     * MEM_DEPTH <= 1024
     */
    assign sram_wr_addr = {{(SRAM_ADDR_WIDTH-ADDR_WIDTH){1'b0}},
                           wr_addr};

    assign sram_rd_addr = {{(SRAM_ADDR_WIDTH-ADDR_WIDTH){1'b0}},
                           rd_addr};

    sky130_sram_1kbyte_1rw1r_8x1024_8 #(
        .VERBOSE (0)
    ) u_sram (
        /*
         * Port 0：1RW端口
         * 在FIFO中固定作为写端口。
         */
        .clk0   (clk),
        .csb0   (~wr_en),
        .web0   (1'b0),
        .wmask0 (1'b1),
        .addr0  (sram_wr_addr),
        .din0   (wr_data),
        .dout0  (unused_dout0),

        /*
         * Port 1：只读端口
         */
        .clk1   (clk),
        .csb1   (~rd_en),
        .addr1  (sram_rd_addr),
        .dout1  (rd_data)
    );

`else
    /*
     * 通用RTL行为模型。
     */

reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
reg [DATA_WIDTH-1:0] rd_data_reg;
always @(posedge clk) begin
    if(wr_en)
        mem[wr_addr] <= wr_data;

    if(rd_en)
        rd_data_reg <= mem[rd_addr];
end

assign  rd_data = rd_data_reg;

`endif

endmodule