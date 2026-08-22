import ram_pkg::*;

class ram_read_monitor;

    virtual ram_if.RD_MON vif;

    mailbox #(transaction) sb_rd_mbx;  // forwards observed (actual) reads to the scoreboard

    int unsigned observed_count;

    function new(virtual ram_if.RD_MON vif,
                 mailbox #(transaction) sb_rd_mbx);
        this.vif       = vif;
        this.sb_rd_mbx = sb_rd_mbx;
    endfunction

    // 're' and 'addr' are only on the bus during the request cycle, and
    // 'valid'/'rdata' appear one cycle later (registered output), so the
    // requested address is latched here and paired up with the data
    // once 'valid' actually arrives.
    task run();
        transaction txn;
        logic [6:0] pending_addr;
        bit         pending = 1'b0;

        forever begin
            @(vif.mon_cb);

            if (vif.mon_cb.re) begin
                pending_addr = vif.mon_cb.addr;
                pending      = 1'b1;
            end

            if (vif.mon_cb.valid && pending) begin
                txn       = new();
                txn.op    = READ;
                txn.addr  = pending_addr;
                txn.rdata = vif.mon_cb.rdata;
                txn.valid = vif.mon_cb.valid;
                observed_count++;
                txn.print("RD-MON");
                sb_rd_mbx.put(txn);
                pending = 1'b0;
            end
        end
    endtask

endclass
