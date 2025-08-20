`timescale 1ns/1ps

interface sram_if;
    logic clk;
    logic rst;
    logic [7:0] addr;
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic we;
    logic re;
endinterface

class transaction;
    rand bit [7:0] addr;
    rand bit [7:0] data_in;
    rand bit we;
    rand bit re;

    constraint valid_ops { we != re; }
    constraint addr_range { addr inside {[0:255]}; }

    function void print(string name);
        $display("%s: addr=%0d, data_in=%0d, we=%0b, re=%0b", name, addr, data_in, we, re);
    endfunction
endclass

class scoreboard;
    reg [7:0] exp_mem [0:255];

    function new();
        for (int i = 0; i < 256; i++) begin
            exp_mem[i] = 8'b0;
        end
    endfunction

    function void check(transaction tr, logic [7:0] actual_out, bit rst);
        logic [7:0] exp_out;
        if (rst) return;
        if (tr.we && !tr.re) begin
            exp_mem[tr.addr] = tr.data_in;
        end
        if (tr.re && !tr.we) begin
            exp_out = exp_mem[tr.addr];
            if (exp_out !== actual_out) begin
                $error("Mismatch! Addr=%0d, Exp=%0d, Act=%0d", tr.addr, exp_out, actual_out);
            end else begin
                $display("Match! Addr=%0d, Data=%0d", tr.addr, actual_out);
            end
        end
    endfunction
endclass

module tb;
    sram_if intf();
    sram dut (
        .clk(intf.clk),
        .rst(intf.rst),
        .addr(intf.addr),
        .data_in(intf.data_in),
        .data_out(intf.data_out),
        .we(intf.we),
        .re(intf.re)
    );

    initial begin
        intf.clk = 0;
        forever #5 intf.clk = ~intf.clk;
    end

    property read_timing;
        @(posedge intf.clk) disable iff (intf.rst)
        (intf.re && !intf.we) |=> (intf.data_out == $past(dut.mem[intf.addr], 1));
    endproperty
    assert property (read_timing) else $error("Read timing violation!");

    property write_timing;
        @(posedge intf.clk) disable iff (intf.rst)
        (intf.we && !intf.re) |=> (dut.mem[$past(intf.addr, 1)] == $past(intf.data_in, 1));
    endproperty
    assert property (write_timing) else $error("Write timing violation!");

    covergroup cg @(posedge intf.clk);
        addr_bins: coverpoint intf.addr {
            bins low = {[0:63]};
            bins mid = {[64:127]};
            bins high = {[128:191]};
            bins top = {[192:255]};
        }
        op_bins: coverpoint {intf.we, intf.re} {
            bins write = {2'b10};
            bins read = {2'b01};
        }
        cross_addr_op: cross addr_bins, op_bins;
    endgroup
    cg cov = new();

    transaction tr;
    transaction prev_tr;  
    scoreboard sb = new();

    initial begin
        intf.rst = 1;
        intf.addr = 0;
        intf.data_in = 0;
        intf.we = 0;
        intf.re = 0;
        #20 intf.rst = 0;

        repeat(1000) begin
            tr = new();
            assert(tr.randomize()) else $fatal(1, "Randomization failed");
            tr.print("Driving");

            
            @(posedge intf.clk);
            intf.addr = tr.addr;
            intf.data_in = tr.data_in;
            intf.we = tr.we;
            intf.re = tr.re;

            
            @(posedge intf.clk);
            if (prev_tr != null) begin  
                sb.check(prev_tr, intf.data_out, intf.rst);
            end
            prev_tr = tr;  

            cov.sample();
        end

        
        @(posedge intf.clk);
        if (prev_tr != null) begin
            sb.check(prev_tr, intf.data_out, intf.rst);
        end

        $display("Functional Coverage: %0.2f%%", cov.get_coverage());
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end
endmodule
