module rowbuffer #(
	parameter dataWidth = 32,   // the data bit width
    parameter pvadd= 256,   // the parallesim in feature adder
    parameter k = 1024  // define k as the block size
)
(
	clk,
	rst,
	enableA,
	enableB,
	writeEnableA1,
	writeEnableA2,
	writeEnableB1,
	writeEnableB2,
	readportA1,
	readportA2,
	writeportA1,
	writeportA2,
	readportB1,
	readportB2,
	writeportB1,
	writeportB2,
  addressportA1,
  addressportA2,
  addressportB1,
  addressportB2
);


parameter addressWidth = $clog2(k);
parameter dataportWidth = dataWidth*pvadd;
parameter memorySize = k * dataportWidth;


// define the input
input clk;
input rst;
input enableA;
input enableB;
input writeEnableA1;
input writeEnableA2;
	input writeEnableB1;
input writeEnableB2;

//define the addressport

input [addressWidth - 1 : 0] addressportA1;
input [addressWidth - 1 : 0] addressportA2;
input [addressWidth - 1 : 0] addressportB1;
input [addressWidth - 1 : 0] addressportB2;

// define the dataport input


output [dataportWidth - 1:0] readportA1;
output [dataportWidth - 1:0] readportA2;
input [dataportWidth - 1:0] writeportA1;
input [dataportWidth - 1:0] writeportA2;
output [dataportWidth - 1:0] readportB1;
output [dataportWidth - 1:0] readportB2;
input [dataportWidth - 1:0] writeportB1;
input [dataportWidth - 1:0] writeportB2;

rowbuffer u0 (
	.data_a    (writeportA1),    //   input,  width = 8192,    data_a.datain_a
	.q_a       (readportA1),       //  output,  width = 8192,       q_a.dataout_a
	.data_b    (writeportA2),    //   input,  width = 8192,    data_b.datain_b
	.q_b       (readportA2),       //  output,  width = 8192,       q_b.dataout_b
	.address_a (addressportA1), //   input,    width = 10, address_a.address_a
	.address_b (addressportA2), //   input,    width = 10, address_b.address_b
	.wren_a    (writeEnableA1),    //   input,     width = 1,    wren_a.wren_a
	.wren_b    (writeEnableA2),    //   input,     width = 1,    wren_b.wren_b
	.clock     (clk)      //   input,     width = 1,     clock.clk
);

rowbuffer u1 (
	.data_a    (writeportB1),    //   input,  width = 8192,    data_a.datain_a
	.q_a       (readportB1),       //  output,  width = 8192,       q_a.dataout_a
	.data_b    (writeportB2),    //   input,  width = 8192,    data_b.datain_b
	.q_b       (readportB2),       //  output,  width = 8192,       q_b.dataout_b
	.address_a (addressportB1), //   input,    width = 10, address_a.address_a
	.address_b (addressportB2), //   input,    width = 10, address_b.address_b
	.wren_a    (writeEnableB1),    //   input,     width = 1,    wren_a.wren_a
	.wren_b    (writeEnableB2),    //   input,     width = 1,    wren_b.wren_b
	.clock     (clk)      //   input,     width = 1,     clock.clk
);



endmodule
