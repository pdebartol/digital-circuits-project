## Abstract

Multiple studies have shown that a Working-Zone approach can lower the power consumption of Microprocessors Address Buses. This project focuses on implementing such technique on an FPGA, providing a design that works properly during pre-synthesis and post-synthesis while keeping the code as simple as possible for future developments.

We present a single process implementation with two signals in his sensitivity list: i_clk and i_rst. The former provides a correct implementation of the asynchronous reset while the latter activates the process on its falling edge and thus, the execution of the current state.
We decided to save data as little as possible. Indeed, the component reads the Working-Zones from RAM for each encoding. This approach provides better scalability: if the number of working zones should increase we would not need major modifications in the source code.
