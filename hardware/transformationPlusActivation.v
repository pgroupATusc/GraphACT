`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2019 09:53:24 AM
// Design Name: 
// Module Name: transformationPlusActivation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module transformationPlusActivation #(
	parameter dataWidth = 32,
	parameter psys = 32,
	parameter featureLen = 128,
	parameter pactivation = 128,
	parameter pavdd = 128,
	parameter k = 1024
)
(
	clk,
	rst,
	enable,
	// define port for weight buffer
	weightWriteEnable,
	weigthDataIn,

	//define port for systolic array
	

	//define the port for aggregation in
	rowbuffer_address,
	rowbuffer_dataOut,

	//define the model
	mode, 

	//
	resultOut

);
input clk;
input rst;
input enable;
input weightWriteEnable;
input [dataWidth*psys -1 :0] weigthDataIn;
input mode;

input [featureLen*dataWidth - 1:0] rowbuffer_dataOut;

output wire [psys*dataWidth - 1:0] resultOut;


wire [psys*dataWidth - 1:0] reluIn;
wire [psys*dataWidth - 1:0] reluOut;


wire [dataWidth*psys -1 :0] weightBufferTosysArray;

reg [$clog2(k) - 1:0] rowAddressCounter;
output wire [$clog2(k) - 1:0] rowbuffer_address;


always @(posedge clk or negedge rst) begin : rowAddressCounter_r
	if(~rst) begin
		rowAddressCounter <= 0;
	end else begin
		rowAddressCounter <= rowAddressCounter + 1 ;
	end
end

assign rowbuffer_address = rowAddressCounter;


parameter integer round = $floor(featureLen / psys);


wire [dataWidth*psys -1 :0] sysin[0:round- 2];


wire [dataWidth*psys -1 :0] sysDataOut;


genvar i;
generate
for(i = 0; i< round - 2;i=i+1) begin:sysin_loop
	if(i == 0) begin : round_r
		assign sysin[i] = rowbuffer_dataOut[(i+1)*psys * dataWidth - 1: i*psys*dataWidth] & rowbuffer_dataOut[(i+2)*psys * dataWidth - 1: (i + 1)*psys*dataWidth];
	end
	else begin : round_p
		assign sysin[i] = sysin[i - 1] & rowbuffer_dataOut[(i+2)*psys * dataWidth - 1: (i + 1)*psys*dataWidth];
	end
end
endgenerate



wire [dataWidth*psys -1 :0] sysarrayIn;

assign sysarrayIn = (mode == 1'b0)? sysin[round - 2]: reluOut;

assign reluIn = (mode == 1'b0)? sysDataOut: sysin[round - 2];

assign resultOut = (mode == 1'b0)? reluOut: sysDataOut;

sysArray #(
	.dataWidth(dataWidth),
	.SysDimension(psys),
	.featureLen(featureLen)
) singlesysArray
(
	.clk(clk), 								// define the input clock
	.rst(rst), 								// define the input reset
	.enable(enable),						// define the enable signal port
	.weightArray(weightBufferTosysArray),   // define the input weight array
	.featureArray(sysarrayIn),                        // define the input feature array
	.outputArray(sysDataOut) 				// define the output feature array
);

parameter weightBufferAddressWidth = $clog2(featureLen * featureLen / psys);


reg[weightBufferAddressWidth - 1:0] WeightAddr;


always @(posedge clk or negedge rst) begin : proc_WeightAddr
	if(~rst) begin
		WeightAddr <= 0;
	end else begin
		WeightAddr <= WeightAddr + 1;
	end
end

weightBuffer #(
	.dataWidth(dataWidth),
	.featureLen(featureLen),
	.psys(psys)
) singleWeightBuffer
(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.writenable(weightWriteEnable),
	.din(weigthDataIn),
	.dout(weightBufferTosysArray),
	.addr(WeightAddr)
);






reluArray #(
	.dataWidth(dataWidth),
    .pactivation(pactivation)
) singlereluArray
(
	.clk(clk),
	.rst(rst),
	.inputArray(reluIn),
	.outputArray(reluOut)
);

endmodule

