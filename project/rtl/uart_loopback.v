`include "../rtl/uart_rx.v"
`include "../rtl/uart_tx.v"

module uart_loopback
#(
    parameter CLK_FREQ = 50000000,
    parameter UART_BPS = 9600
)
(
    input  wire sys_clk,
    input  wire sys_rst_n,

    input  wire uart_rxd,
    output wire uart_txd
);

// ============================================================
// Internal wires
// ============================================================

wire       uart_recv_done;
wire [7:0] uart_recv_data;

reg        uart_send_en;
reg  [7:0] uart_send_data;
wire       uart_tx_busy;

// loopback buffer
reg        pending_valid;
reg [7:0]  pending_data;
reg        overflow_flag;

// ============================================================
// UART RX instance
// ============================================================

uart_rx #(
    .CLK_FREQ (CLK_FREQ),
    .UART_BPS (UART_BPS)
) u_uart_rx (
    .sys_clk   (sys_clk),
    .sys_rst_n (sys_rst_n),

    .uart_rxd  (uart_rxd),
    .uart_done (uart_recv_done),
    .uart_data (uart_recv_data)
);

// ============================================================
// UART TX instance
// ============================================================

uart_tx #(
    .CLK_FREQ (CLK_FREQ),
    .UART_BPS (UART_BPS)
) u_uart_tx (
    .sys_clk      (sys_clk),
    .sys_rst_n    (sys_rst_n),

    .uart_en      (uart_send_en),
    .uart_din     (uart_send_data),
    .uart_tx_busy (uart_tx_busy),
    .uart_txd     (uart_txd)
);

// ============================================================
// Loopback control logic
// ============================================================

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        uart_send_en  <= 1'b0;
        uart_send_data <= 8'd0;

        pending_valid <= 1'b0;
        pending_data  <= 8'd0;
        overflow_flag <= 1'b0;
    end
    else begin
        // send_en 必须默认拉低，保证它是一个 1-cycle pulse
        uart_send_en <= 1'b0;

        // 情况 1：TX 空闲，并且已经有缓存数据，则先发送缓存数据
        if ((!uart_tx_busy) && pending_valid) begin
            uart_send_data <= pending_data;
            uart_send_en   <= 1'b1;
            pending_valid  <= 1'b0;
        end

        // 情况 2：RX 收到新数据
        if (uart_recv_done) begin
            // TX 空闲，且没有缓存数据：直接发送
            if ((!uart_tx_busy) && (!pending_valid)) begin
                uart_send_data <= uart_recv_data;
                uart_send_en   <= 1'b1;
            end

            // TX 空闲，但本周期刚好在发送缓存数据：
            // 新接收到的数据放入缓存
            else if ((!uart_tx_busy) && pending_valid) begin
                pending_data  <= uart_recv_data;
                pending_valid <= 1'b1;
            end

            // TX 忙，且缓存为空：先缓存
            else if (uart_tx_busy && (!pending_valid)) begin
                pending_data  <= uart_recv_data;
                pending_valid <= 1'b1;
            end

            // TX 忙，且缓存已有数据：说明来不及发送，发生覆盖
            else begin
                pending_data  <= uart_recv_data;
                pending_valid <= 1'b1;
                overflow_flag <= 1'b1;
            end
        end
    end
end

endmodule