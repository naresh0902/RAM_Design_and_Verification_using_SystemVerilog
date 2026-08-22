package ram_pkg;

    typedef enum {WRITE, READ} op_t;

    class transaction;
        rand op_t        op;
        rand logic [6:0] addr;
        rand logic [7:0] wdata;
        logic [7:0]      rdata;
        logic            valid;

        function new();
            op    = WRITE;
            addr  = 7'h00;
            wdata = 8'h00;
            rdata = 8'h00;
            valid = 1'b0;
        endfunction

        function void print(string tag = "");
            $display("%0t : %s | op=%s addr=%0h wdata=%0h rdata=%0h valid=%0b",
                       $time, tag, op.name(), addr, wdata, rdata, valid);
        endfunction

        // Returns a fresh object with the same field values.
        // Use this whenever the same logical transaction needs to be
        // handed to more than one mailbox/component, so two components
        // never end up sharing (and separately mutating) one handle.
        function transaction copy();
            transaction t = new();
            t.op    = op;
            t.addr  = addr;
            t.wdata = wdata;
            t.rdata = rdata;
            t.valid = valid;
            return t;
        endfunction
    endclass

endpackage
