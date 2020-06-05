module vectorAdd #(
    parameter dataWidth = 32,
    parameter pvadd= 128
)
(
	clk,
	rst,
	lastin,
	lastout,
	valid,
	vectorIn,
	vectorOut    
);

// define the input
input clk;
input rst;
input lastin;
input [dataWidth*pvadd -1: 0] vectorIn;

//define the output
output valid;
output lastout;
output [dataWidth*pvadd -1: 0] vectorOut;

//define the type of output
wire lastout;
wire valid;
wire [dataWidth*pvadd -1: 0] vectorOut;

genvar i;
generate
	for(i = 0;i < pvadd; i = i+1) begin : single
		floating_point_1 singleAcc (
  			.aclk(clk),                                                     		// input wire aclk
  			.aresetn(rst),                                                  		// input wire aresetn
  			.s_axis_a_tvalid(1'b1),                                         		// input wire s_axis_a_tvalid
  			.s_axis_a_tdata(vectorIn[(i + 1)*dataWidth - 1: i*dataWidth]),  		// input wire [31 : 0] s_axis_a_tdata
  			.s_axis_a_tlast(lastin),              				    				// input wire s_axis_a_tlast
  			.m_axis_result_tvalid(valid),                    						// output wire m_axis_result_tvalid
  			.m_axis_result_tdata(vectorOut[(i + 1)*dataWidth - 1: i*dataWidth]),    // output wire [31 : 0] m_axis_result_tdata
  			.m_axis_result_tlast(lastout)                       					// output wire m_axis_result_tlast
		);

	end
endgenerate

endmodule