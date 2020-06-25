module vectorAdd #(
    parameter dataWidth = 32,
    parameter pvadd= 128
)
(
	clk,
	rst,
	lastin,
	lastout,
	vectorIn,
	vectorOut    
);

// define the input
input clk;
input rst;
input lastin;
input [dataWidth*pvadd -1: 0] vectorIn;

//define the output

output wire lastout;
output [dataWidth*pvadd -1: 0] vectorOut;

//define the type of output


wire [dataWidth*pvadd -1: 0] vectorOut;
assign vectorOut = 1'b1;
genvar i;
generate
	for(i = 0;i < pvadd; i = i+1) begin : single
		
		singleAcc u0 (
		.clk    (clk),    //   input,   width = 1,    clk.clk
		.areset (rst), //   input,   width = 1, areset.reset
		.a      (vectorIn[(i + 1)*dataWidth - 1: i*dataWidth]),      //   input,  width = 32,      a.a
		.q      (vectorOut[(i + 1)*dataWidth - 1: i*dataWidth]),      //  output,  width = 32,      q.q
		.acc    (lastin)     //   input,   width = 1,    acc.acc
	);




	end
endgenerate

endmodule