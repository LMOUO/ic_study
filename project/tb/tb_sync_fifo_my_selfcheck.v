`timescale 1ns/1ps

module tb_sync_fifo_my_selfcheck;

/* ============================================================
 * Test parameters
 * ============================================================ */

localparam DATA_WIDTH  = 8;
localparam FIFO_DEPTH  = 8;
localparam COUNT_WIDTH = $clog2(FIFO_DEPTH + 1);


/* ============================================================
 * DUT signals
 * ============================================================ */

reg                         sys_clk;
reg                         sys_rst_n;

reg  [DATA_WIDTH-1:0]       i_wr_data;
reg                         i_wr_en;

wire [DATA_WIDTH-1:0]       o_rd_data;
wire                        o_rd_valid;
reg                         i_rd_en;

wire [COUNT_WIDTH-1:0]      o_data_count;
wire                        o_fifo_full;
wire                        o_fifo_empty;


/* ============================================================
 * Clock generation
 * 50 MHz: period = 20 ns
 * ============================================================ */

initial begin
    sys_clk = 1'b0;
end

always #10 sys_clk = ~sys_clk;


/* ============================================================
 * DUT instance
 * ============================================================ */

sync_fifo_my #(
    .DATA_WIDTH (DATA_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH)
) dut (
    .sys_clk      (sys_clk),
    .sys_rst_n    (sys_rst_n),

    .i_wr_data    (i_wr_data),
    .i_wr_en      (i_wr_en),

    .o_rd_data    (o_rd_data),
    .o_rd_valid   (o_rd_valid),
    .i_rd_en      (i_rd_en),

    .o_data_count (o_data_count),

    .o_fifo_full  (o_fifo_full),
    .o_fifo_empty (o_fifo_empty)
);


/* ============================================================
 * Reference model
 *
 * 这是独立于 DUT 的 FIFO 行为模型。
 * 不读取 DUT 内部 mem。
 * ============================================================ */

reg [DATA_WIDTH-1:0] model_mem [0:FIFO_DEPTH-1];

integer model_wr_ptr;
integer model_rd_ptr;
integer model_count;

reg wr_accept;
reg rd_accept;

reg                  expected_rd_valid;
reg [DATA_WIDTH-1:0] expected_rd_data;

integer clock_cycle;
integer pass_count;


/* ============================================================
 * Scoreboard
 *
 * 在每个时钟上升沿：
 * 1. 判断 DUT 是否接受读写请求
 * 2. 更新参考模型
 * 3. 等待 DUT 非阻塞赋值完成
 * 4. 比较所有输出
 * ============================================================ */

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        model_wr_ptr      = 0;
        model_rd_ptr      = 0;
        model_count       = 0;

        wr_accept         = 1'b0;
        rd_accept         = 1'b0;

        expected_rd_valid = 1'b0;
        expected_rd_data  = {DATA_WIDTH{1'b0}};

        clock_cycle       = 0;
    end
    else begin
        clock_cycle = clock_cycle + 1;

        /*
         * 上升沿到来前的 full/empty 对应旧的 FIFO 状态，
         * 用它们判断本周期读写请求是否真正被接受。
         */
        wr_accept = i_wr_en && !o_fifo_full;
        rd_accept = i_rd_en && !o_fifo_empty;

        /*
         * 同步读时，本周期被接受的读请求会在上升沿后
         * 产生对应的 o_rd_data 和 o_rd_valid。
         *
         * 必须先保存旧地址的数据，再更新参考模型指针。
         */
        expected_rd_valid = rd_accept;

        if (rd_accept)
            expected_rd_data = model_mem[model_rd_ptr];

        /*
         * 更新参考存储器。
         *
         * 先获取 expected_rd_data，再写 model_mem，
         * 可以模拟 DUT 同地址同时读写时的 old-data/read-first 行为。
         */
        if (wr_accept) begin
            model_mem[model_wr_ptr] = i_wr_data;

            if (model_wr_ptr == FIFO_DEPTH - 1)
                model_wr_ptr = 0;
            else
                model_wr_ptr = model_wr_ptr + 1;
        end

        if (rd_accept) begin
            if (model_rd_ptr == FIFO_DEPTH - 1)
                model_rd_ptr = 0;
            else
                model_rd_ptr = model_rd_ptr + 1;
        end

        case ({wr_accept, rd_accept})
            2'b10: model_count = model_count + 1;
            2'b01: model_count = model_count - 1;
            2'b11: model_count = model_count;
            2'b00: model_count = model_count;
            default: model_count = model_count;
        endcase

        /*
         * DUT 使用非阻塞赋值。
         * 延迟 1 ns 后再比较，避免 testbench 与 DUT 在 posedge 竞争。
         */
        #1;

        /* 检查读有效信号 */
        if (o_rd_valid !== expected_rd_valid) begin
            $display("");
            $display("ERROR: o_rd_valid mismatch");
            $display("TIME       = %0t", $time);
            $display("CLOCK      = %0d", clock_cycle);
            $display("EXPECTED   = %0b", expected_rd_valid);
            $display("GOT        = %0b", o_rd_valid);
            $fatal;
        end

        /* 仅在数据有效时检查读数据 */
        if (expected_rd_valid) begin
            if (o_rd_data !== expected_rd_data) begin
                $display("");
                $display("ERROR: read data mismatch");
                $display("TIME       = %0t", $time);
                $display("CLOCK      = %0d", clock_cycle);
                $display("EXPECTED   = 0x%02h", expected_rd_data);
                $display("GOT        = 0x%02h", o_rd_data);
                $fatal;
            end
        end

        /* 检查数据数量 */
        if (o_data_count !== model_count) begin
            $display("");
            $display("ERROR: data count mismatch");
            $display("TIME       = %0t", $time);
            $display("CLOCK      = %0d", clock_cycle);
            $display("EXPECTED   = %0d", model_count);
            $display("GOT        = %0d", o_data_count);
            $fatal;
        end

        /* 检查 empty */
        if (o_fifo_empty !== (model_count == 0)) begin
            $display("");
            $display("ERROR: empty flag mismatch");
            $display("TIME       = %0t", $time);
            $display("CLOCK      = %0d", clock_cycle);
            $display("MODEL COUNT= %0d", model_count);
            $display("EMPTY      = %0b", o_fifo_empty);
            $fatal;
        end

        /* 检查 full */
        if (o_fifo_full !== (model_count == FIFO_DEPTH)) begin
            $display("");
            $display("ERROR: full flag mismatch");
            $display("TIME       = %0t", $time);
            $display("CLOCK      = %0d", clock_cycle);
            $display("MODEL COUNT= %0d", model_count);
            $display("FULL       = %0b", o_fifo_full);
            $fatal;
        end
    end
end


/* ============================================================
 * Driver tasks
 * ============================================================ */

/* 写入一个数据 */
task write_one;
    input [DATA_WIDTH-1:0] data;
    begin
        @(negedge sys_clk);

        i_wr_data = data;
        i_wr_en   = 1'b1;
        i_rd_en   = 1'b0;

        @(negedge sys_clk);

        i_wr_en = 1'b0;
    end
endtask


/* 发出一次读请求 */
task read_one;
    begin
        @(negedge sys_clk);

        i_wr_en = 1'b0;
        i_rd_en = 1'b1;

        @(negedge sys_clk);

        i_rd_en = 1'b0;
    end
endtask


/* 同一周期同时读写 */
task write_read_one;
    input [DATA_WIDTH-1:0] data;
    begin
        @(negedge sys_clk);

        i_wr_data = data;
        i_wr_en   = 1'b1;
        i_rd_en   = 1'b1;

        @(negedge sys_clk);

        i_wr_en = 1'b0;
        i_rd_en = 1'b0;
    end
endtask


/* 等待若干周期 */
task wait_cycles;
    input integer cycles;
    integer j;
    begin
        for (j = 0; j < cycles; j = j + 1)
            @(posedge sys_clk);
    end
endtask


/* 打印用例开始信息 */
task begin_case;
    input [8*64-1:0] case_name;
    begin
        $display("");
        $display("=================================================");
        $display("START CASE: %0s", case_name);
        $display("TIME      : %0t", $time);
        $display("=================================================");
    end
endtask


/* 打印用例通过信息 */
task end_case;
    input [8*64-1:0] case_name;
    begin
        pass_count = pass_count + 1;

        $display("PASS CASE : %0s", case_name);
        $display("TIME      : %0t", $time);
    end
endtask


/* ============================================================
 * Test sequence
 * ============================================================ */

integer i;

initial begin
    sys_rst_n = 1'b0;

    i_wr_data = {DATA_WIDTH{1'b0}};
    i_wr_en   = 1'b0;
    i_rd_en   = 1'b0;

    pass_count = 0;

    $dumpfile("../sim/waves/sync_fifo_my_wave.vcd");
    $dumpvars(0, tb_sync_fifo_my_selfcheck);

    /* 复位 */
    repeat (5) @(posedge sys_clk);

    @(negedge sys_clk);
    sys_rst_n = 1'b1;

    wait_cycles(2);


    /* ========================================================
     * CASE 1: Reset state
     * ======================================================== */

    begin_case("RESET_STATE");

    if (o_fifo_empty !== 1'b1) begin
        $display("ERROR: FIFO should be empty after reset");
        $fatal;
    end

    if (o_fifo_full !== 1'b0) begin
        $display("ERROR: FIFO should not be full after reset");
        $fatal;
    end

    if (o_data_count !== 0) begin
        $display("ERROR: FIFO count should be zero after reset");
        $fatal;
    end

    end_case("RESET_STATE");


    /* ========================================================
     * CASE 2: Single write and read
     * ======================================================== */

    begin_case("SINGLE_WRITE_READ");

    write_one(8'hA5);

    if (o_data_count !== 1) begin
        $display("ERROR: FIFO count should be 1");
        $fatal;
    end

    read_one();

    wait_cycles(1);

    if (!o_fifo_empty) begin
        $display("ERROR: FIFO should be empty");
        $fatal;
    end

    end_case("SINGLE_WRITE_READ");


    /* ========================================================
     * CASE 3: Multiple FIFO-order test
     * ======================================================== */

    begin_case("MULTIPLE_FIFO_ORDER");

    write_one(8'h11);
    write_one(8'h22);
    write_one(8'h33);
    write_one(8'h44);

    read_one();
    read_one();
    read_one();
    read_one();

    wait_cycles(1);

    if (!o_fifo_empty) begin
        $display("ERROR: FIFO should be empty after four reads");
        $fatal;
    end

    end_case("MULTIPLE_FIFO_ORDER");


    /* ========================================================
     * CASE 4: Fill FIFO and full flag
     * ======================================================== */

    begin_case("FIFO_FULL");

    for (i = 0; i < FIFO_DEPTH; i = i + 1)
        write_one(8'h40 + i);

    if (o_fifo_full !== 1'b1) begin
        $display("ERROR: full flag was not asserted");
        $fatal;
    end

    if (o_data_count !== FIFO_DEPTH) begin
        $display("ERROR: full FIFO count is incorrect");
        $fatal;
    end

    end_case("FIFO_FULL");


    /* ========================================================
     * CASE 5: Overflow protection
     * 满状态继续写入，必须被拒绝
     * ======================================================== */

    begin_case("OVERFLOW_PROTECTION");

    write_one(8'hEE);

    if (o_data_count !== FIFO_DEPTH) begin
        $display("ERROR: overflow request changed FIFO count");
        $fatal;
    end

    if (o_fifo_full !== 1'b1) begin
        $display("ERROR: FIFO should remain full");
        $fatal;
    end

    end_case("OVERFLOW_PROTECTION");


    /* ========================================================
     * CASE 6: Drain FIFO
     * ======================================================== */

    begin_case("DRAIN_FIFO");

    for (i = 0; i < FIFO_DEPTH; i = i + 1)
        read_one();

    wait_cycles(1);

    if (o_fifo_empty !== 1'b1) begin
        $display("ERROR: empty flag was not asserted");
        $fatal;
    end

    if (o_data_count !== 0) begin
        $display("ERROR: empty FIFO count is incorrect");
        $fatal;
    end

    end_case("DRAIN_FIFO");


    /* ========================================================
     * CASE 7: Underflow protection
     * 空状态继续读，不应产生有效数据
     * ======================================================== */

    begin_case("UNDERFLOW_PROTECTION");

    read_one();

    wait_cycles(1);

    if (o_rd_valid !== 1'b0) begin
        $display("ERROR: empty read generated valid data");
        $fatal;
    end

    if (o_data_count !== 0) begin
        $display("ERROR: underflow request changed FIFO count");
        $fatal;
    end

    end_case("UNDERFLOW_PROTECTION");


    /* ========================================================
     * CASE 8: Pointer wrap-around
     *
     * 写6个，读4个，再写6个：
     * 写指针和读指针都会发生回绕。
     * ======================================================== */

    begin_case("POINTER_WRAP_AROUND");

    for (i = 0; i < 6; i = i + 1)
        write_one(8'h60 + i);

    for (i = 0; i < 4; i = i + 1)
        read_one();

    for (i = 0; i < 6; i = i + 1)
        write_one(8'h80 + i);

    if (!o_fifo_full) begin
        $display("ERROR: FIFO should be full after wrap test writes");
        $fatal;
    end

    for (i = 0; i < FIFO_DEPTH; i = i + 1)
        read_one();

    wait_cycles(1);

    if (!o_fifo_empty) begin
        $display("ERROR: FIFO should be empty after wrap test");
        $fatal;
    end

    end_case("POINTER_WRAP_AROUND");


    /* ========================================================
     * CASE 9: Simultaneous read/write
     * ======================================================== */

    begin_case("SIMULTANEOUS_READ_WRITE");

    /* 先放入4个旧数据 */
    write_one(8'hA0);
    write_one(8'hA1);
    write_one(8'hA2);
    write_one(8'hA3);

    /*
     * 同时读写4次：
     * 每次读出一个旧数据，同时写入一个新数据。
     * data_count 应保持4。
     */
    write_read_one(8'hC0);
    write_read_one(8'hC1);
    write_read_one(8'hC2);
    write_read_one(8'hC3);

    if (o_data_count !== 4) begin
        $display("ERROR: simultaneous read/write changed count");
        $fatal;
    end

    /* 读出刚写入的4个新数据 */
    read_one();
    read_one();
    read_one();
    read_one();

    wait_cycles(1);

    if (!o_fifo_empty) begin
        $display("ERROR: FIFO should be empty after simultaneous test");
        $fatal;
    end

    end_case("SIMULTANEOUS_READ_WRITE");


    /* ========================================================
     * Final result
     * ======================================================== */

    wait_cycles(3);

    $display("");
    $display("==============================================");
    $display("PASS: sync_fifo_my self-check simulation");
    $display("TOTAL PASS CASES  = %0d", pass_count);
    $display("TOTAL CLOCK CYCLES= %0d", clock_cycle);
    $display("==============================================");

    $finish;
end


/* ============================================================
 * Global timeout
 * ============================================================ */

initial begin
    #1000000;  // 1 ms

    $display("");
    $display("ERROR: simulation timeout");
    $display("TIME = %0t", $time);

    $fatal;
end

endmodule