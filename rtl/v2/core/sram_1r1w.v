// 
// Copyright (C) 2011-2014 Jeff Bush
// 
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Library General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
// 
// You should have received a copy of the GNU Library General Public
// License along with this library; if not, write to the
// Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
// Boston, MA  02110-1301, USA.
// 


`include "defines.v"

//
// Block SRAM with 1 read port and 1 write port. Reads and writes are performed 
// synchronously, with the value for a read appearing on the next clock edge after 
// the address is asserted. If a read and a write are performed to the same address 
// in the same cycle, the newly written data will be returned ("read-after-write").
//

module sram_1r1w
	#(parameter DATA_WIDTH = 32,
	parameter SIZE = 1024,
	parameter ADDR_WIDTH = $clog2(SIZE))

	(input                         clk,
	input                          rd_en,
	input [ADDR_WIDTH - 1:0]       rd_addr,
	output logic[DATA_WIDTH - 1:0] rd_data,
	input                          wr_en,
	input [ADDR_WIDTH - 1:0]       wr_addr,
	input [DATA_WIDTH - 1:0]       wr_data);

	logic[DATA_WIDTH - 1:0] data[SIZE] /*verilator public*/;
	
`ifdef VENDOR_ALTERA
	// Note that the use of blocking assignments is not usually proper
	// in sequential logic, but this is explicitly recommended by 
	// Altera's "Recommended HDL Coding Styles" document (Example 13-13).
	// to infer a block RAM with the proper read-after-write behavior. 
	always_ff @(posedge clk)
	begin
		if (wr_en)
			data[wr_addr] = wr_data;	

		if (rd_en)
			rd_data = data[rd_addr];
	end
`else
	// Simulation
	initial
	begin : clear
		rd_data = 0;
	end

	always_ff @(posedge clk)
	begin
		if (wr_en)
			data[wr_addr] <= wr_data;	

		if (wr_addr == rd_addr && wr_en && rd_en)
			rd_data <= wr_data;
		else if (rd_en)
			rd_data <= data[rd_addr];
	end
`endif
endmodule

// Local Variables:
// verilog-typedef-regexp:"_t$"
// End:
