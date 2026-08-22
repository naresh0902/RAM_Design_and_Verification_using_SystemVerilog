import ram_pkg::*;

class ram_scoreboard;

    mailbox #(transaction) sb_rd_mbx;
    mailbox #(transaction) sb_exp_mbx;

    int unsigned pass_count;
    int unsigned fail_count;

    function new(mailbox #(transaction) sb_rd_mbx,
                 mailbox #(transaction) sb_exp_mbx);
        this.sb_rd_mbx  = sb_rd_mbx;
        this.sb_exp_mbx = sb_exp_mbx;
    endfunction

    function void check(transaction actual, transaction expected);
        bit addr_match, data_match, valid_match;

        addr_match  = (actual.addr  == expected.addr);
        data_match  = (actual.rdata == expected.rdata);
        valid_match = (actual.valid == expected.valid);

        if (addr_match && data_match && valid_match) begin
            pass_count++;
            $display("[SB] PASS addr=%0h data=%0h", actual.addr, actual.rdata);
        end
        else begin
            fail_count++;
            $display("[SB] FAIL addr=%0h actual_data=%0h expected_data=%0h actual_valid=%0b expected_valid=%0b",
                       actual.addr, actual.rdata, expected.rdata, actual.valid, expected.valid);
        end
    endfunction

    task run_check();
        transaction actual, expected;
        $display("[SB] started");
        forever begin
            sb_rd_mbx.get(actual);
            sb_exp_mbx.get(expected);
            check(actual, expected);
        end
    endtask

    function void report();
        $display("========================================");
        $display(" SCOREBOARD REPORT : PASS=%0d  FAIL=%0d", pass_count, fail_count);
        $display("========================================");
    endfunction

endclass
