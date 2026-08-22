import ram_pkg::*;

class ram_read_driver;

    virtual ram_if.READ_DRV vif;

    mailbox #(transaction) rd_mbx;
    mailbox #(transaction) rm_rd_mbx;  // forwards the requested address to the ref model

    int unsigned txn_count;

    function new(virtual ram_if.READ_DRV vif,
                 mailbox #(transaction) rd_mbx,
                 mailbox #(transaction) rm_rd_mbx);
        this.vif       = vif;
        this.rd_mbx    = rd_mbx;
        this.rm_rd_mbx = rm_rd_mbx;
    endfunction

    task drive(transaction txn);
        @(vif.rd_cb);
        vif.rd_cb.re   <= 1'b1;
        vif.rd_cb.addr <= txn.addr;

        @(vif.rd_cb);
        vif.rd_cb.re   <= 1'b0;
        vif.rd_cb.addr <= 7'h00;
    endtask

    task run();
        transaction txn;
        forever begin
            rd_mbx.get(txn);
            rm_rd_mbx.put(txn.copy());  // let the ref model compute the expected value
            drive(txn);
            txn_count++;
        end
    endtask

endclass
