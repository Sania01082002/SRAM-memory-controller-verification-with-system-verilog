# SRAM Memory Controller Verification with SystemVerilog
# Abstract
This project verifies a 256x8 synchronous SRAM memory controller using a SystemVerilog testbench. It employs constrained-random stimuli, SystemVerilog Assertions (SVA), and functional coverage to validate read/write operations, achieving 100% functional and code coverage. Simulated on EDA Playground (Aldec Riviera-PRO), results include code, waveforms, and coverage reports, uploaded to this GitHub repository.
Why: Ensures hardware reliability pre-fabrication, critical for ASIC design to avoid costly silicon defects. Teaches SystemVerilog verification skills for memory IPs (e.g., SoC caches).
Use: A portfolio project for VLSI verification roles, demonstrating random testing, SVA, and coverage analysis.
# Objective

Verify SRAM read/write functionality with one-cycle latency using a SystemVerilog testbench.
Achieve 100% functional (address/operation bins) and code coverage (statement/branch/toggle).
Fix bugs (e.g., timing, data mismatches) using SVA and scoreboard.
Share code, test plan, waveforms, and coverage reports on GitHub.

# Working

SRAM DUT (sram.v): Verilog module with 256x8 memory. Inputs: clk, rst, addr[7:0], data_in[7:0], we, re. Output: data_out[7:0]. Writes data_in to mem[addr] on we=1, reads mem[addr] to data_out on re=1, one-cycle latency.
Testbench (tb.sv):
Interface: sram_if connects DUT signals.
Transaction: Randomizes addr, data_in, we, re (constraints: we != re, addr in [0:255]).
Driver: Applies transactions at clock edges.
Scoreboard: Tracks exp_mem, checks data_out vs. exp_mem[addr] on reads.
Assertions: SVA verifies read/write timing (one-cycle latency).
Coverage: Covergroup tracks address bins (0-63, 64-127, 128-191, 192-255), operations (write/read), and cross-coverage.
Simulation: Runs 1000+ transactions on EDA Playground, dumps VCD for waveforms.

# Result
Console Output:
Driving: addr=232, data_in=78, we=1, re=0
Driving: addr=252, data_in=38, we=0, re=1
Match! Addr=252, Data=234
Driving: addr=29, data_in=2, we=0, re=1
Match! Addr=29, Data=9
...
Functional Coverage: 100.00%


Explanation: 
Driving: Shows random transactions (write: we=1, read: re=1).
Match!: Confirms data_out matches exp_mem[addr] on reads (e.g., read addr=252 returns 234).
No errors (mismatches/timing violations) after fixing scoreboard timing (using prev_tr).
100% functional coverage (all bins hit).



# Inference

Random Testing: Constrained-random stimuli catch bugs (e.g., stale data_out) efficiently.
SVA: Detects timing issues (e.g., read latency) using $past.
Scoreboard: Must align with DUT’s one-cycle latency (fixed via prev_tr).
Coverage: Ensures all scenarios tested, critical for reliability.
Debugging: Waveforms and logs pinpointed timing mismatches.

# Conclusion
The SRAM is fully verified with no errors, 100% coverage, and documented results (code, VCD, reports) in this repository. It’s a reusable SystemVerilog verification demo for learning ASIC testing or showcasing VLSI skills. Extend it for FIFO or UVM-based verification.

## Files
