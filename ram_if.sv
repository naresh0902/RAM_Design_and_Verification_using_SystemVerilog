interface ram_if (input logic clk);

    logic       rst_n;
    logic       we;
    logic       re;
    logic [6:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;
    logic       valid;

    // clocking block used by the write driver
    clocking wr_cb @(posedge clk);
        default input #1 output #1;
        output we;
        output addr;
        output wdata;
        input  rdata;
        input  valid;
    endclocking

    // clocking block used by the read driver
    clocking rd_cb @(posedge clk);
        default input #1 output #1;
        output re;
        output addr;
        input  rdata;
        input  valid;
    endclocking

    // clocking block used by monitors (sampling only, no outputs)
    clocking mon_cb @(posedge clk);
        default input #1;
        input we;
        input re;
        input addr;
        input wdata;
        input rdata;
        input valid;
    endclocking

    modport WRITE_DRV (clocking wr_cb, input clk);
    modport READ_DRV  (clocking rd_cb, input clk);
    modport WR_MON    (clocking mon_cb, input clk);
    modport RD_MON    (clocking mon_cb, input clk);

    // NOTE: rst_n is intentionally not exposed through any modport.
    // It is driven directly on the plain (non-modport) interface handle
    // from tb_top, since reset is asynchronous and not really a
    // "driver" concern.

endinterface