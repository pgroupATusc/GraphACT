`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2019 12:49:59 PM
// Design Name: 
// Module Name: Aggregation
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
module Aggregation #(
	parameter dataWidth = 32,   // the data bit width
	parameter pvadd= 128,   // the parallesim in feature adder
	parameter k = 1024  // define k as the block size
)
(
	// system signal
	clk,
	rst,
	enable,

	// port for indptrDoubleBuffer
	indptr_writeEnableA1,
	indptr_writeEnableB1,
	indptr_addressportA1_outside,
	indptr_addressportB1_outside,
	indptr_writeportA1,
	indptr_writeportB1,

	indptr_startAddressA,
	indptr_startAddressB,
	indptr_endAddress,

	// port for indiceDoubleBuffer
	indice_writeEnableA1,
	indice_writeEnableB1,
	indice_addressportA1_outside,
	indice_addressportB1_outside,
	indice_writeportA1,
	indice_writeportB1,

	// port for DoubleColumnBuffer
	columnbuffer_writeEnableA1,
	columnbuffer_writeEnableB1,
	columnbuffer_addressportA1_outside,
	columnbuffer_addressportB1_outside,
	columnbuffer_writeportA1,
	columnbuffer_writeportB1,

	// port for Double Row Buffer

	rowbuffer_addressportA1_outside,
	rowbuffer_dataOut


);

input clk;
input rst;
input enable;
// define the two state FSM
wire finish;
reg triggerA;
reg triggerB;

reg [indice_addressWidth - 1:0] indiceCounterA;
reg [indice_addressWidth - 1:0] indiceCounterB;

parameter S1 = 1'b0;
parameter S2 = 1'b1;

reg state;

always @(posedge clk or negedge rst) begin : proc_state
	if(~rst) begin
		state <= S1;
	end else begin
		if(finish)begin
			if(state == S1)
				state <= S2 ;
			else
				state <= S1;
		end
		else
			state <= state;
	end
end



//define the parameter and port for indptrDoubleBuffer
// write the indptrDouble buffer is from outside

reg [indptr_addressWidth - 1:0] indptrCounterA;
reg [indptr_addressWidth - 1:0] indptrCounterB;

parameter indptr_addressWidth = $clog2(k + 1);
parameter indptr_dataportWidth =  $clog2(k*k/32);

input indptr_writeEnableA1;
input indptr_writeEnableB1;
input [indptr_dataportWidth - 1:0] indptr_writeportA1;
input [indptr_dataportWidth - 1:0] indptr_writeportB1;

wire [indptr_dataportWidth - 1:0]  indptr_readportA1;
wire [indptr_dataportWidth - 1:0]  indptr_readportA2;
wire [indptr_dataportWidth - 1:0]  indptr_readportB1;
wire [indptr_dataportWidth - 1:0]  indptr_readportB2;


wire [indptr_addressWidth - 1:0] indptr_addressportA1;
wire [indptr_addressWidth - 1:0] indptr_addressportA2;
wire [indptr_addressWidth - 1:0] indptr_addressportB1;
wire [indptr_addressWidth - 1:0] indptr_addressportB2;

input [indptr_addressWidth - 1:0] indptr_addressportA1_outside;
input [indptr_addressWidth - 1:0] indptr_addressportB1_outside;





wire [indptr_dataportWidth - 1:0] indptrAout;

assign indptrAout = (state == S1)? indptr_readportA1:indptr_readportB1;

wire [indptr_dataportWidth - 1:0] indptrBout;

assign indptrBout = (state == S1)? indptr_readportA2:indptr_readportB2;


// ping pong operation
assign indptr_addressportA1 = (state == S1)? indptr_addressportA1_outside: indptrCounterA;
assign indptr_addressportA2 = (state == S1)? indptr_addressportB1_outside: indptrCounterB;

assign indptr_addressportB1 = (state == S1)? indptrCounterA: indptr_addressportA1_outside;
assign indptr_addressportB2 = (state == S1)? indptrCounterB: indptr_addressportB1_outside;




indptrDoubleBuffer #(
    .k(k) 
)  singleindptrDoubleBuffer
(
	.clk(clk),
	.rst(rst),
	.enableA(enable),
	.enableB(enable),
	.writeEnableA1(indptr_writeEnableA1),
	.writeEnableA2(1'b0),
	.writeEnableB1(indptr_writeEnableB1),
	.writeEnableB2(1'b0),
	.readportA1(indptr_readportA1),
	.readportA2(indptr_readportA2),
	.writeportA1(indptr_writeportA1),
	.writeportA2(0),
	.readportB1(indptr_readportB1),
	.readportB2(indptr_readportB2),
	.writeportB1(indptr_writeportB1),
	.writeportB2(0),
    .addressportA1(indptr_addressportA1),
    .addressportA2(indptr_addressportA2),
    .addressportB1(indptr_addressportB1),
    .addressportB2(indptr_addressportB2)
);




//parameter for indiceDoubleBuffer

parameter indice_addressWidth = $clog2(k*k/32);
parameter indice_dataportWidth = $clog2(k);


input indice_writeEnableA1;
input indice_writeEnableB1;
input [indice_dataportWidth - 1:0] indice_writeportA1;
input [indice_dataportWidth - 1:0] indice_writeportB1;


wire [indice_dataportWidth - 1:0] indice_readportA1;
wire [indice_dataportWidth - 1:0] indice_readportA2;
wire [indice_dataportWidth - 1:0] indice_readportB1;
wire [indice_dataportWidth - 1:0] indice_readportB2;

wire [indice_addressWidth - 1:0] addressportA1;
wire [indice_addressWidth - 1:0] addressportA2;
wire [indice_addressWidth - 1:0] addressportB1;
wire [indice_addressWidth - 1:0] addressportB2;

input [indice_addressWidth - 1:0] indice_addressportA1_outside;
input [indice_addressWidth - 1:0] indice_addressportB1_outside;


assign addressportA1 = (state == S1)? indice_addressportA1_outside: indiceCounterA;
assign addressportA2 = (state == S1)? indice_addressportB1_outside: indiceCounterB;

assign addressportB1 = (state == S1)? indiceCounterA: indice_addressportA1_outside;
assign addressportB2 = (state == S1)? indiceCounterB: indice_addressportB1_outside;


wire [indice_dataportWidth - 1:0] indiceForColumnBufferA;
wire [indice_dataportWidth - 1:0] indiceForColumnBufferB;

assign indiceForColumnBufferA = (state == S1)? indice_readportA1: indice_readportB1;
assign indiceForColumnBufferB = (state == S1)? indice_readportA2: indice_readportB2;


indiceDoubleBuffer #(
    .k(k)
)  singleindiceDoubleBuffer
(
	.clk(clk),
	.rst(rst),
	.enableA(enable),
	.enableB(enable),
	.writeEnableA1(indice_writeEnableA1),
	.writeEnableA2(1'b0),
	.writeEnableB1(indice_writeEnableB1),
	.writeEnableB2(1'b0),
	.readportA1(indice_readportA1),
	.readportA2(indice_readportA2),
	.writeportA1(indice_writeportA1),
	.writeportA2(0),
	.readportB1(indice_readportB1),
	.readportB2(indice_readportB2),
	.writeportB1(indice_writeportB1),
	.writeportB2(0),
    .addressportA1(addressportA1),
    .addressportA2(addressportA2),
    .addressportB1(addressportB1),
    .addressportB2(addressportB2)
);




// define the parameter for columnBuffer

parameter columnbuffer_addressWidth = $clog2(k);
parameter columnbuffer_dataportWidth = dataWidth*pvadd;





input columnbuffer_writeEnableA1;
input columnbuffer_writeEnableB1;

wire [columnbuffer_dataportWidth - 1:0] columnbuffer_readportA1;
wire [columnbuffer_dataportWidth - 1:0] columnbuffer_readportA2;
wire [columnbuffer_dataportWidth - 1:0] columnbuffer_readportB1;
wire [columnbuffer_dataportWidth - 1:0] columnbuffer_readportB2;

wire [columnbuffer_addressWidth - 1:0] columnbuffer_addressportA1;
wire [columnbuffer_addressWidth - 1:0] columnbuffer_addressportA2;
wire [columnbuffer_addressWidth - 1:0] columnbuffer_addressportB1;
wire [columnbuffer_addressWidth - 1:0] columnbuffer_addressportB2;

input [columnbuffer_addressWidth - 1:0] columnbuffer_addressportA1_outside;
input [columnbuffer_addressWidth - 1:0] columnbuffer_addressportB1_outside;
input [columnbuffer_dataportWidth - 1:0] columnbuffer_writeportA1;
input [columnbuffer_dataportWidth - 1:0] columnbuffer_writeportB1;

// parameter for columnbuffer

assign columnbuffer_addressportA1 = (state == S1)? columnbuffer_addressportA1_outside: indiceCounterA;
assign columnbuffer_addressportA2 = (state == S1)? columnbuffer_addressportB1_outside: indiceCounterB;

assign columnbuffer_addressportB1 = (state == S1)? indiceCounterA: columnbuffer_addressportA1_outside;
assign columnbuffer_addressportB2 = (state == S1)? indiceCounterB: columnbuffer_addressportB1_outside;


wire [columnbuffer_dataportWidth - 1:0] dataForVadderA;
wire [columnbuffer_dataportWidth - 1:0] dataForVadderB;


assign dataForVadderA = (state == S1)? columnbuffer_readportA1: columnbuffer_readportB1;
assign dataForVadderB = (state == S1)? columnbuffer_readportA2: columnbuffer_readportB2;




columnbuffer  #(
	.dataWidth(dataWidth),   // the data bit width
    .pvadd(pvadd),   // the parallesim in feature adder
    .k(k)  // define k as the block size
)  singlecolumnbuffer
(
	.clk(clk),
	.rst(rst),
	.enableA(enable),
	.enableB(enable),
	.writeEnableA1(columnbuffer_writeEnableA1),
	.writeEnableA2(1'b0),
	.writeEnableB1(columnbuffer_writeEnableB1),
	.writeEnableB2(1'b0),
	.readportA1(columnbuffer_readportA1),
	.readportA2(columnbuffer_readportA2),
	.writeportA1(columnbuffer_writeportA1),
	.writeportA2(32'b0),
	.readportB1(columnbuffer_readportB1),
	.readportB2(columnbuffer_readportB2),
	.writeportB1(columnbuffer_writeportB1),
	.writeportB2(32'b0),
  	.addressportA1(columnbuffer_addressportA1),
  	.addressportA2(columnbuffer_addressportA2),
  	.addressportB1(columnbuffer_addressportB1),
  	.addressportB2(columnbuffer_addressportB2)
);







wire [columnbuffer_dataportWidth - 1:0] DataVectorAout;
wire [columnbuffer_dataportWidth - 1:0] DataVectorBout;



//  vectorAdder1

vectorAdd #(
    .dataWidth(dataWidth),
    .pvadd(pvadd)
) vectorAdderA
(
	.clk(clk),
	.rst(rst),
	.lastin(1'b1),
	.lastout(),
	.vectorIn(dataForVadderA),
	.vectorOut(DataVectorAout)    
);

//  vectorAdder2
vectorAdd #(
    .dataWidth(dataWidth),
    .pvadd(pvadd)
) vectorAdderB
(
	.clk(clk),
	.rst(rst),
	.lastin(1'b1),
	.lastout(),
	.vectorIn(dataForVadderB),
	.vectorOut(DataVectorBout)    
);


/// define the dataport for the row buffer

wire rowbuffer_writeEnableA1;
wire rowbuffer_writeEnableA2;
wire rowbuffer_writeEnableB1;
wire rowbuffer_writeEnableB2;


assign rowbuffer_writeEnableA1 = (state == S1)? 1'b1: 1'b0;
assign rowbuffer_writeEnableA2 = (state == S1)? 1'b1: 1'b0;

assign rowbuffer_writeEnableB1 = (state == S1)? 1'b0: 1'b1;
assign rowbuffer_writeEnableB2 = (state == S1)? 1'b0: 1'b1;

// logic for the row buffer
wire [columnbuffer_addressWidth - 1:0] rowbuffer_addressportA1;
wire [columnbuffer_addressWidth - 1:0] rowbuffer_addressportA2;
wire [columnbuffer_addressWidth - 1:0] rowbuffer_addressportB1;
wire [columnbuffer_addressWidth - 1:0] rowbuffer_addressportB2;


input [columnbuffer_addressWidth - 1:0] rowbuffer_addressportA1_outside;

assign rowbuffer_addressportA1 = (state == S1)? indptrCounterA: rowbuffer_addressportA1_outside;
assign rowbuffer_addressportA2 = (state == S1)? indptrCounterB: rowbuffer_addressportA1_outside;

assign rowbuffer_addressportB1 = (state == S1)? rowbuffer_addressportA1_outside: indptrCounterA;
assign rowbuffer_addressportB2 = (state == S1)? rowbuffer_addressportA1_outside: indptrCounterB;


wire [columnbuffer_dataportWidth - 1:0] rowbuffer_readportA1;

wire [columnbuffer_dataportWidth - 1:0] rowbuffer_readportB1;


output [columnbuffer_dataportWidth - 1:0] rowbuffer_dataOut;

assign rowbuffer_dataOut = (state == S1)? rowbuffer_readportB1: rowbuffer_readportA1;


rowbuffer #(
	.dataWidth(dataWidth) ,   // the data bit width
    .pvadd(pvadd),   // the parallesim in feature adder
    .k(k)  // define k as the block size
) singlerowBuffer
(
	.clk(clk),
	.rst(rst),
	.enableA(enable),
	.enableB(enable),
	.writeEnableA1(rowbuffer_writeEnableA1),
	.writeEnableA2(rowbuffer_writeEnableA2),
	.writeEnableB1(rowbuffer_writeEnableB1),
	.writeEnableB2(rowbuffer_writeEnableB2),
	.readportA1(rowbuffer_readportA1),
	.readportA2(),
	.writeportA1(DataVectorAout),
	.writeportA2(DataVectorBout),
	.readportB1(rowbuffer_readportB1),
	.readportB2(),
	.writeportB1(DataVectorAout),
	.writeportB2(DataVectorBout),
  	.addressportA1(rowbuffer_addressportA1),
  	.addressportA2(rowbuffer_addressportA2),
  	.addressportB1(rowbuffer_addressportB1),
  	.addressportB2(rowbuffer_addressportB2)
);





// define the communication signal



// 



reg [indice_addressWidth - 1:0] indptrA1;
reg [indice_addressWidth - 1:0] indptrA2;

reg [indice_addressWidth - 1:0] indptrB1;
reg [indice_addressWidth - 1:0] indptrB2;





input [indptr_addressWidth - 1:0] indptr_startAddressA;
input [indptr_addressWidth - 1:0] indptr_startAddressB;
input [indptr_addressWidth - 1:0] indptr_endAddress;

always @(posedge clk or negedge rst) begin : proc_indptrCounterA
	if(~rst) begin
		indptrCounterA <= 0;
	end else begin
		if(finish) begin 
			indptrCounterA <= indptr_startAddressA;
		end
		else if(triggerA)begin 
			indptrCounterA <= indptrCounterA + 1;
		end
		else begin
			indptrCounterA <= indptrCounterA; 
		end			
	end
end

always @(posedge clk or negedge rst) begin : proc_indptrCounterB
	if(~rst) begin
		indptrCounterB <= 0;
	end else begin
		if(finish) begin 
			indptrCounterB <= indptr_startAddressB;
		end
		else if(triggerA)begin 
			indptrCounterB <= indptrCounterB + 1;
		end
		else begin
			indptrCounterB <= indptrCounterB; 
		end
	end
end

assign finish = (indptrCounterA == indptr_startAddressB && indptrCounterB == indptr_endAddress) ? 1'b1: 1'b0;




always @(posedge clk or negedge rst) begin : proc_indptrA2
	if(~rst) begin
		indptrA2 <= 0;
	end else begin
		if(finish) begin
			indptrA2 <= indptrAout;
		end
		else if(indiceCounterA == indptrA2) begin 
			indptrA2 <= indptrAout;
		end
		else begin 
			indptrA2 <= indptrA2;
		end
	end
end

always @(posedge clk or negedge rst) begin : proc_indptrA1
	if(~rst) begin
		indptrA1 <= 0;
	end else begin
		if(finish) begin 
			indptrA1 <= indptrAout;
		end
		else if(indiceCounterA == indptrA2) begin 
			indptrA1 <= indptrA2;
		end
		else begin 
			indptrA1 <= indptrA1;
		end
	end
end

always @(posedge clk or negedge rst) begin : proc_indiceCounterA
	if(~rst) begin
		indiceCounterA <= 0;
	end else begin
		if(triggerA) begin 
			indiceCounterA <= indptrA1;
		end
		else if(indiceCounterA < indptrA2 - 1) begin 
			indiceCounterA <=  indiceCounterA + 1;
		end
		else begin 
			indiceCounterA <= indiceCounterA;
		end
	end
end

always @(posedge clk or negedge rst) begin : proc_triggerA
	if(~rst) begin
		triggerA <= 0;
	end else begin
		if(indiceCounterA == indptrA2 - 1) begin 
			triggerA <= 1'b1;
		end
		else begin 
			triggerA <= 1'b0;
		end
	end
end




///////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst) begin : proc_indptrB2
	if(~rst) begin
		indptrB2 <= 0;
	end else begin
		if(finish) begin
			indptrB2 <= indptrBout;
		end
		else if(indiceCounterB == indptrB2) begin 
			indptrB2 <= indptrBout;
		end
		else begin 
			indptrB2 <= indptrB2;
		end
	end
end

always @(posedge clk or negedge rst) begin : proc_indptrB1
	if(~rst) begin
		indptrB1 <= 0;
	end else begin
		if(finish) begin 
			indptrB1 <= indptrBout;
		end
		else if(indiceCounterB == indptrB2) begin 
			indptrB1 <= indptrB2;
		end
		else begin 
			indptrB1 <= indptrB1;
		end
	end
end

always @(posedge clk or negedge rst) begin : proc_indiceCounterB
	if(~rst) begin
		indiceCounterB <= 0;
	end else begin
		if(triggerB) begin 
			indiceCounterB <= indptrB1;
		end
		else if(indiceCounterB < indptrB2 - 1) begin 
			indiceCounterB <=  indiceCounterB + 1;
		end
		else begin 
			indiceCounterB <= indiceCounterB;
		end
	end
end

always @(posedge clk or negedge rst) begin : proc_triggerB
	if(~rst) begin
		triggerB <= 0;
	end else begin
		if(indiceCounterB == indptrB2 - 1) begin 
			triggerB <= 1'b1;
		end
		else begin 
			triggerB <= 1'b0;
		end
	end
end


//////////////////////////////////////////////////////////////




endmodule



