module sram (
    input clk,
    input rst,
    input [7:0] addr,
    input [7:0] data_in,
    output reg [7:0] data_out,
    input we,
    input re
);
    reg [7:0] mem [0:255];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            data_out <= 8'b0;
            for (i = 0; i < 256; i = i + 1) begin
                mem[i] <= 8'b0;
            end
        end else begin
            if (we && !re) begin
                mem[addr] <= data_in;
            end
            if (re && !we) begin
                data_out <= mem[addr];
            end
        end
    end
endmodule
