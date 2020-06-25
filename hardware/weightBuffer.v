
module weightBuffer #(
	parameter dataWidth = 32,
	parameter featureLen = 256,
	parameter psys = 24
)
(
	clk,
	rst,
	enable,
	writenable,
	din,
	dout,
	addr

);

parameter addressWidth = $clog2(featureLen * featureLen / psys);
parameter dataportWidth = dataWidth*psys;
parameter memorySize = 288 * 288 * dataWidth;



// define the input port
input clk;
input rst;
input enable;
input writenable;
input [dataportWidth - 1:0] din;
input [addressWidth -1:0] addr;
output [dataportWidth - 1:0] dout;

weightbuffer u0 (
	.data      (din),      //   input,  width = 768,      data.datain
	.q         (dout),         //  output,  width = 768,         q.dataout
	.wraddress ({1'b0, addr}), //   input,   width = 12, wraddress.wraddress
	.rdaddress ({1'b0, addr}), //   input,   width = 12, rdaddress.rdaddress
	.wren      (writenable),      //   input,    width = 1,      wren.wren
	.clock     (clk)      //   input,    width = 1,     clock.clk
);




endmodule