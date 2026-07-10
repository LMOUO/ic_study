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
    output reg  [DATA_WIDTH-1:0]    rd_data
);

reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

always @(posedge clk) begin
    if(wr_en)
        mem[wr_addr] <= wr_data;

    if(rd_en)
        rd_data <= mem[rd_addr];
end

endmodule