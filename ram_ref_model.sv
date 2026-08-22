import ram_pkg::*;

class ram_ref_model;

    logic [7:0] mem[0:127];  // flat shadow memory; addr = block*32 + location

    mailbox #(transaction) rm_wr_mbx;
    mailbox #(transaction) rm_rd_mbx;
    mailbox #(transaction) sb_exp_mbx;

    int unsigned wr_processed;
    int unsigned rd_processed;

    function new(mailbox #(transaction) rm_wr_mbx,
                 mailbox #(transaction) rm_rd_mbx,
                 mailbox #(transaction) sb_exp_mbx);
        this.rm_wr_mbx  = rm_wr_mbx;
        this.rm_rd_mbx  = rm_rd_mbx;
        this.sb_exp_mbx = sb_exp_mbx;
    endfunction

    task run_writes();
        transaction txn;
        $display("[RM] write task started");
        forever begin
            rm_wr_mbx.get(txn);
            mem[txn.addr] = txn.wdata;
            wr_processed++;
            $display("[RM] wr addr=%0h data=%0h", txn.addr, txn.wdata);
        end
    endtask

    task run_reads();
        transaction txn;
        $display("[RM] read task started");
        forever begin
            rm_rd_mbx.get(txn);
            txn.rdata = mem[txn.addr];
            txn.valid = 1'b1;
            rd_processed++;
            sb_exp_mbx.put(txn);
        end
    endtask

endclass
