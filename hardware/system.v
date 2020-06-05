`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2019 05:26:25 PM
// Design Name: 
// Module Name: system
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



module system(

	clk,
	rst,
	enable,
	mode,
	indptr_addressportA1_outside,
	indptr_addressportB1_outside,
	indptr_startAddressA,
	indptr_startAddressB,
	indptr_endAddress,
	indptr_writeportA1,
	indptr_writeportB1,
	indice_addressportA1_outside,
	indice_addressportB1_outside,
	indice_writeportA1,
	indice_writeportB1,
	columnbuffer_addressportA1_outside,
	columnbuffer_addressportB1_outside,
	columnbuffer_writeportA1_narrow,
	columnbuffer_writeportB1_narrow,

	weight_narrow,
	resultOut_narrow

 );

parameter dataWidth = 32;
parameter pvadd = 128;
parameter k = 1024;
parameter psys = 32;
parameter featureLen = 128;
parameter pactivation = 128;
parameter pavdd = 128;

input clk;
input rst;
input enable;
input mode;

input [$clog2(k + 1) - 1:0] indptr_addressportA1_outside;
input [$clog2(k + 1) - 1:0] indptr_addressportB1_outside;
input [$clog2(k + 1) - 1:0] indptr_startAddressA;
input [$clog2(k + 1) - 1:0] indptr_startAddressB;
input [$clog2(k + 1) - 1:0] indptr_endAddress;

input [$clog2(k*k/32) - 1:0] indptr_writeportA1;
input [$clog2(k*k/32) - 1:0] indptr_writeportB1;

input [$clog2(k*k/32) - 1:0] indice_addressportA1_outside;
input [$clog2(k*k/32) - 1:0] indice_addressportB1_outside;

input [$clog2(k) - 1:0] indice_writeportA1; 
input [$clog2(k) - 1:0] indice_writeportB1;

input [$clog2(k) - 1:0] columnbuffer_addressportA1_outside;
input [$clog2(k) - 1:0] columnbuffer_addressportB1_outside;

input wire [dataWidth - 1:0] columnbuffer_writeportA1_narrow;
input wire [dataWidth - 1:0] columnbuffer_writeportB1_narrow;

input wire [dataWidth - 1:0] weight_narrow;
output wire [dataWidth - 1:0] resultOut_narrow;

wire [dataWidth*psys - 1:0] resultOut;

wire [dataWidth*pvadd - 1:0] columnbuffer_writeportA1;
wire [dataWidth*pvadd - 1:0] columnbuffer_writeportB1;


wire [dataWidth*psys - 1:0] weightIn;

genvar i;
generate
	for (i = 0; i< pvadd;i = i+1) begin:portnarrowTowide
		assign columnbuffer_writeportA1[ (i + 1)*dataWidth - 1 : i*dataWidth] = columnbuffer_writeportA1_narrow; 
		assign columnbuffer_writeportB1[ (i + 1)*dataWidth - 1 : i*dataWidth] = columnbuffer_writeportB1_narrow; 
	end
endgenerate

genvar j;
generate
	for (j = 0; j < psys ; j = j+1) begin: weightGenration
		assign weightIn[(j+1)*dataWidth - 1: j*dataWidth] = weight_narrow;
	end
endgenerate

genvar l;
generate
	 for (l = 0; l < psys - 1; l = l+1) begin : resultoutgeneration
	 	if(l == 0) begin : firstloop
	 		assign resultOut_narrow = resultOut[(l + 2)*dataWidth - 1:(l+1)*dataWidth] & resultOut[(l+1)*dataWidth - 1:l*dataWidth];
	 	end
	 	else begin : remainingloop
	 		assign resultOut_narrow = resultOut_narrow & resultOut[(l + 2)*dataWidth - 1:(l+1)*dataWidth];
	 	end
	 end
endgenerate


wire [$clog2(k) - 1:0] rowAddressConnection;
wire [pvadd*dataWidth - 1:0] rowdataConnection;

Aggregation #(
	.dataWidth(dataWidth),   // the data bit width
	.pvadd(pvadd),   // the parallesim in feature adder
	.k(k)  // define k as the block size
) singleAggregation
(
	// system signal
	.clk(clk),
	.rst(rst),
	.enable(enable),

	// port for indptrDoubleBuffer
	.indptr_writeEnableA1(enable),
	.indptr_writeEnableB1(enable),
	.indptr_addressportA1_outside(indptr_addressportA1_outside),
	.indptr_addressportB1_outside(indptr_addressportB1_outside),
	.indptr_writeportA1(indptr_writeportA1),
	.indptr_writeportB1(indptr_writeportB1),

	.indptr_startAddressA(indptr_startAddressA),
	.indptr_startAddressB(indptr_startAddressB),
	.indptr_endAddress(indptr_endAddress),

	// port for indiceDoubleBuffer
	.indice_writeEnableA1(enable),
	.indice_writeEnableB1(enable),
	.indice_addressportA1_outside(indice_addressportA1_outside),
	.indice_addressportB1_outside(indice_addressportB1_outside),
	.indice_writeportA1(indice_writeportA1),
	.indice_writeportB1(indice_writeportB1),

	// port for DoubleColumnBuffer
	.columnbuffer_writeEnableA1(enable),
	.columnbuffer_writeEnableB1(enable),
	.columnbuffer_addressportA1_outside(columnbuffer_addressportA1_outside),
	.columnbuffer_addressportB1_outside(columnbuffer_addressportB1_outside),
	.columnbuffer_writeportA1(columnbuffer_writeportA1),
	.columnbuffer_writeportB1(columnbuffer_writeportB1),

	// port for Double Row Buffer

	.rowbuffer_addressportA1_outside(rowAddressConnection),
	.rowbuffer_dataOut(rowdataConnection)


);


transformationPlusActivation #(
	.dataWidth(dataWidth),
	.psys(psys),
	.featureLen(featureLen),
	.pactivation(pactivation),
	.pavdd(pavdd),
	.k(k)
) singletransformationPlusActivation
(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	// define port for weight buffer
	.weightWriteEnable(enable),
	.weigthDataIn(weightIn),

	//define port for systolic array
	

	//define the port for aggregation in
	.rowbuffer_address(rowAddressConnection),
	.rowbuffer_dataOut(rowdataConnection),

	//define the model
	.mode(mode), 

	//
	.resultOut(resultOut)

);



endmodule