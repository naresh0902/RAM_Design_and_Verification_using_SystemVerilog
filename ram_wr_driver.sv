import ram_pkg::*;

class ram_wr_driver;

    virtual ram_if.WRITE_DRV vif;

    mailbox #(transaction) wr_mbx;
    mailbox #(bit)         wr_done_mbx;

    int unsigned txn_count;

    function new(virtual ram_if.WRITE_DRV vif,
                 mailbox #(transaction) wr_mbx,
                 mailbox #(bit)         wr_done_mbx);
        this.vif         = vif;
        this.wr_mbx      = wr_mbx;
        this.wr_done_mbx = wr_done_mbx;
    endfunction

    task drive(transaction txn);
        @(vif.wr_cb);
        vif.wr_cb.we    <= 1'b1;
        vif.wr_cb.addr  <= txn.addr;
        vif.wr_cb.wdata <= txn.wdata;

        @(vif.wr_cb);
        vif.wr_cb.we    <= 1'b0;
        vif.wr_cb.addr  <= 7'h00;
        vif.wr_cb.wdata <= 8'h00;
    endtask

    task run();
        transaction txn;
        forever begin
            wr_mbx.get(txn);
            drive(txn);
            txn_count++;
            wr_done_mbx.put(1'b1);
        end
    endtask

endclass
