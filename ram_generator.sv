import ram_pkg::*;

class ram_generator;

    mailbox #(transaction) wr_mbx;
    mailbox #(transaction) rd_mbx;
    mailbox #(bit)         wr_done_mbx;

    function new(mailbox #(transaction) wr_mbx,
                 mailbox #(transaction) rd_mbx,
                 mailbox #(bit)         wr_done_mbx);
        this.wr_mbx      = wr_mbx;
        this.rd_mbx      = rd_mbx;
        this.wr_done_mbx = wr_done_mbx;
    endfunction

    local task send_write(logic [6:0] addr, logic [7:0] data);
        transaction txn = new();
        txn.op    = WRITE;
        txn.addr  = addr;
        txn.wdata = data;
        txn.print("GEN-WR");
        wr_mbx.put(txn);
    endtask

    local task send_read(logic [6:0] addr);
        transaction txn = new();
        txn.op   = READ;
        txn.addr = addr;
        txn.print("GEN-RD");
        rd_mbx.put(txn);
    endtask

    local task wait_writes_done(int unsigned n);
        bit tok;
        repeat (n) wr_done_mbx.get(tok);
    endtask

    task run(input logic [6:0] wr_addrs[],
             input logic [7:0] wr_datas[],
             input int unsigned n_writes,
             input logic [6:0] rd_addrs[],
             input int unsigned n_reads,
             input bit          randomize_txns = 0);

        $display("[GEN] sending %0d writes", n_writes);
        if (randomize_txns) begin
            for (int i = 0; i < n_writes; i++) begin
                transaction txn = new();
                if (!txn.randomize() with {op == WRITE;})
                    $fatal(1, "[GEN] randomize failed for write %0d", i);
                send_write(txn.addr, txn.wdata);
            end
        end
        else begin
            for (int i = 0; i < n_writes; i++)
                send_write(wr_addrs[i], wr_datas[i]);
        end

        wait_writes_done(n_writes);
        $display("[GEN] all writes done");

        $display("[GEN] sending %0d reads", n_reads);
        if (randomize_txns) begin
            for (int i = 0; i < n_reads; i++) begin
                transaction txn = new();
                if (!txn.randomize() with {op == READ;})
                    $fatal(1, "[GEN] randomize failed for read %0d", i);
                send_read(txn.addr);
            end
        end
        else begin
            for (int i = 0; i < n_reads; i++)
                send_read(rd_addrs[i]);
        end

        $display("[GEN] done");
    endtask

endclass
