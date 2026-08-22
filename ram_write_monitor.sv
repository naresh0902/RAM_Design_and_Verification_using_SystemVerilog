import ram_pkg::*;

class ram_write_monitor;

    virtual ram_if.WR_MON vif;

    mailbox #(transaction) rm_wr_mbx;  // forwards observed writes to the ref model

    int unsigned observed_count;

    function new(virtual ram_if.WR_MON vif,
                 mailbox #(transaction) rm_wr_mbx);
        this.vif       = vif;
        this.rm_wr_mbx = rm_wr_mbx;
    endfunction

    task run();
        transaction txn;
        $display("[WR-MON] started");
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.we) begin
                txn       = new();
                txn.op    = WRITE;
                txn.addr  = vif.mon_cb.addr;
                txn.wdata = vif.mon_cb.wdata;
                observed_count++;
                txn.print("WR-MON");
                rm_wr_mbx.put(txn);
            end
        end
    endtask

endclass
