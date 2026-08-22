`timescale 1ns/1ps
import ram_pkg::*;

module tb_top;

    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    ram_if dut_if (clk);

    ram_design dut (
        .clk   (clk),
        .rst_n (dut_if.rst_n),
        .we    (dut_if.we),
        .re    (dut_if.re),
        .addr  (dut_if.addr),
        .wdata (dut_if.wdata),
        .rdata (dut_if.rdata),
        .valid (dut_if.valid)
    );

    ram_env env;

    initial begin
        logic [6:0] wr_addrs[8];
        logic [7:0] wr_datas[8];
        logic [6:0] rd_addrs[8];

        // reset is driven directly on the plain interface handle,
        // not through any modport
        dut_if.rst_n = 1'b0;
        dut_if.we    = 1'b0;
        dut_if.re    = 1'b0;
        dut_if.addr  = 7'h00;
        dut_if.wdata = 8'h00;

        repeat (4) @(posedge clk);
        dut_if.rst_n = 1'b1;
        @(posedge clk);

        // Two addresses per block (first and last location of each
        // 32-location block) so the decoder's all 4 chip-select lines
        // actually get exercised, not just block 0:
        //   block0: 0,31   block1: 32,63   block2: 64,95   block3: 96,127
        wr_addrs[0] = 7'd0;   wr_addrs[1] = 7'd31;
        wr_addrs[2] = 7'd32;  wr_addrs[3] = 7'd63;
        wr_addrs[4] = 7'd64;  wr_addrs[5] = 7'd95;
        wr_addrs[6] = 7'd96;  wr_addrs[7] = 7'd127;

        for (int i = 0; i < 8; i++) begin
            wr_datas[i] = $urandom_range(0, 255);
            rd_addrs[i] = wr_addrs[i];
        end

        env = new(dut_if, dut_if, dut_if, dut_if);
        env.build();
        env.start();
        env.run(wr_addrs, wr_datas, 8, rd_addrs, 8, 1'b0);

        // The write path has a wr_done handshake so the generator only
        // returns once all writes are driven. Reads have no equivalent
        // handshake, so env.run() returns as soon as all read *requests*
        // are queued -- not once they're actually driven and checked.
        // Wait here until the scoreboard has checked all 8 reads, with a
        // safety timeout in case something upstream stalls.
        fork
            begin
                wait (env.sb.pass_count + env.sb.fail_count >= 8);
            end
            begin
                #2000;
                $display("[TB_TOP] WARNING: timed out waiting for all reads to be checked");
            end
        join_any
        disable fork;

        env.report();
        $display("TESTBENCH COMPLETE");
        $finish;
    end

endmodule