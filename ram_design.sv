module ram_design (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       we,
    input  logic       re,
    input  logic [6:0] addr,
    input  logic [7:0] wdata,
    output logic [7:0] rdata,
    output logic       valid
);

    wire [3:0] cs;              // chip select for the 4 memory blocks
    wire [4:0] word_address;    // location within the chosen block

    integer i;

    assign word_address = addr[4:0];
    assign cs[0] = (addr[6:5] == 2'b00);
    assign cs[1] = (addr[6:5] == 2'b01);
    assign cs[2] = (addr[6:5] == 2'b10);
    assign cs[3] = (addr[6:5] == 2'b11);

    reg [7:0] mem_block0[0:31];
    reg [7:0] mem_block1[0:31];
    reg [7:0] mem_block2[0:31];
    reg [7:0] mem_block3[0:31];

    // write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                mem_block0[i] <= 0;
                mem_block1[i] <= 0;
                mem_block2[i] <= 0;
                mem_block3[i] <= 0;
            end
        end
        else if (we) begin
            case (cs)
                4'b0001: mem_block0[word_address] <= wdata;
                4'b0010: mem_block1[word_address] <= wdata;
                4'b0100: mem_block2[word_address] <= wdata;
                4'b1000: mem_block3[word_address] <= wdata;
                default: ; // no valid chip selected
            endcase
        end
    end

    // read logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata <= 8'h00;
            valid <= 1'b0;
        end
        else if (re) begin
            valid <= 1'b1;
            case (cs)
                4'b0001: rdata <= mem_block0[word_address];
                4'b0010: rdata <= mem_block1[word_address];
                4'b0100: rdata <= mem_block2[word_address];
                4'b1000: rdata <= mem_block3[word_address];
                default: rdata <= 8'h00;
            endcase
        end
        else begin
            valid <= 1'b0;
        end
    end

endmodule