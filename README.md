# dualVth
![](https://img.shields.io/badge/Development-Stopped-red)

 dualVth project carried out in the Synthesis and optimization of digital systems course at Politecnico di Torino.

 The project consist in a plug-in for Synopsis's PrimeTime : the script, written in TCL, implements a post-synthesis power minimization procedure. The script performs
 a leakage-constrained Dual-Vth cell assignment such that slack penalties are minimized. The savings obtained from swapping LVT cells with HVT cells is obtained as follows

 savings = (start_power - end_power) / start_power

Allowed input values may range from 0 (no leakage minimization) to 1 (maximum leakage savings). Every cell have to keep the same cell footprint during the optimization.

Circuits such as https://s2.smu.edu/~dhoungninou/Benchmarks/ISCAS85/VERILOG/c1908.v and https://s2.smu.edu/~dhoungninou/Benchmarks/ISCAS85/VERILOG/c5315.v were used as benchmarks.
