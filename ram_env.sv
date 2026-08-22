import ram_pkg::*;

class ram_env;

    ram_generator     gen;
    ram_wr_driver     wr_drv;
    ram_read_driver   rd_drv;
    ram_write_monitor wr_mon;
    ram_read_monitor  rd_mon;
    ram_ref_model     rm;
    ram_scoreboard    sb;

    mailbox #(transaction) wr_mbx;
    mailbox #(transaction) rd_mbx;
    mailbox #(bit)         wr_done_mbx;
    mailbox #(transaction) rm_wr_mbx;
    mailbox #(transaction) rm_rd_mbx;
    mailbox #(transaction) sb_rd_mbx;
    mailbox #(transaction) sb_exp_mbx;

    virtual ram_if.WRITE_DRV wr_vif;
    virtual ram_if.READ_DRV  rd_vif;
    virtual ram_if.WR_MON    wr_mon_vif;
    virtual ram_if.RD_MON    rd_mon_vif;

    function new(virtual ram_if.WRITE_DRV wr_vif,
                 virtual ram_if.READ_DRV  rd_vif,
                 virtual ram_if.WR_MON    wr_mon_vif,
                 virtual ram_if.RD_MON    rd_mon_vif);
        this.wr_vif     = wr_vif;
        this.rd_vif     = rd_vif;
        this.wr_mon_vif = wr_mon_vif;
        this.rd_mon_vif = rd_mon_vif;

        wr_mbx      = new();
        rd_mbx      = new();
        wr_done_mbx = new();
        rm_wr_mbx   = new();
        rm_rd_mbx   = new();
        sb_rd_mbx   = new();
        sb_exp_mbx  = new();
    endfunction

    function void build();
        gen    = new(wr_mbx, rd_mbx, wr_done_mbx);
        wr_drv = new(wr_vif, wr_mbx, wr_done_mbx);
        rd_drv = new(rd_vif, rd_mbx, rm_rd_mbx);
        wr_mon = new(wr_mon_vif, rm_wr_mbx);
        rd_mon = new(rd_mon_vif, sb_rd_mbx);
        rm     = new(rm_wr_mbx, rm_rd_mbx, sb_exp_mbx);
        sb     = new(sb_rd_mbx, sb_exp_mbx);
        $display("[ENV] all components built");
    endfunction

    task start();
        fork
            wr_drv.run();
            rd_drv.run();
            wr_mon.run();
            rd_mon.run();
            rm.run_writes();
            rm.run_reads();
            sb.run_check();
        join_none
        $display("[ENV] all threads started");
    endtask

    task run(input logic [6:0] wr_addrs[],
             input logic [7:0] wr_datas[],
             input int unsigned n_writes,
             input logic [6:0] rd_addrs[],
             input int unsigned n_reads,
             input bit          randomize_txns = 0);
        gen.run(wr_addrs, wr_datas, n_writes, rd_addrs, n_reads, randomize_txns);
    endtask

    function void report();
        sb.report();
    endfunction

endclass
