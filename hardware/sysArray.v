
module sysArray #(
	parameter dataWidth = 32,
	parameter SysDimension = 32,
	parameter featureLen = 128
)
(
	clk, // define the input clock
	rst, // define the input reset
	enable,
	weightArray, // define the input weight array
	featureArray, // define the input feature array
	outputArray // define the output feature array
);

//define the inpt
input clk;
input rst;
input enable;
input [dataWidth*SysDimension - 1:0] weightArray;
input [dataWidth*SysDimension - 1:0] featureArray;
output [dataWidth*SysDimension - 1:0] outputArray;
reg [dataWidth*SysDimension - 1:0] outputArray;

wire [dataWidth*SysDimension - 1:0] weightWireArray[0:SysDimension - 1];
wire [dataWidth*SysDimension - 1:0] featureWireArray[0:SysDimension - 1];

wire [dataWidth*SysDimension - 1:0] resultWireArray[0:SysDimension - 1];


genvar i, j;
generate
	for(i = 0;i < SysDimension; i = i + 1) begin : rowUroll
		for(j = 0; j < SysDimension; j = j + 1) begin : columnUroll

			// define weight wire connection


			wire [dataWidth - 1:0] iweightwire;
			
			assign iweightwire = (j == 0) ? weightArray[(i + 1)*dataWidth - 1: i * dataWidth]: weightWireArray[j - 1][(i + 1)*dataWidth - 1: i * dataWidth];

			wire [dataWidth - 1:0] iweightwireOut;

			assign iweightwireOut = weightWireArray[j][(i + 1)*dataWidth  - 1: i * dataWidth];

			// define feature wire connection

			wire [dataWidth - 1:0] ifeaturewire ;

			assign ifeaturewire = (i == 0) ? featureArray[(j + 1)*dataWidth - 1: j * dataWidth]: featureWireArray[i - 1][(j + 1)*dataWidth - 1: j * dataWidth];

			wire [dataWidth - 1:0] ifeaturewireOut;

			assign ifeaturewireOut = featureWireArray[i][(j + 1)*dataWidth - 1: j * dataWidth];

			// define the result wire connection

			wire [dataWidth - 1:0] iresultIn;

			assign iresultIn = (i == 0)? 0:  resultWireArray[i - 1][(j + 1)*dataWidth - 1: j * dataWidth];

			wire [dataWidth - 1:0] iresultOut;

			assign resultWireArray[i][(j + 1)*dataWidth - 1: j * dataWidth] = iresultOut;

			

			sysUnit #(
   	 			.dataWidth(dataWidth),
    			.RowIndex(i),
    			.ColumnIndex(j),
    			.featureLen(featureLen),
    			.SysDimension(SysDimension)
			) singleSysUnit
			(
				.clk(clk),                    // input clock
				.rst(rst),                    // input reset
				.enable(enable),			  // input enable		
				.weight(iweightwire),         // input weight
				.featureIn(ifeaturewire),     // input feature
				.preresult(iresultIn),        // input previous result
				.featureOut(iresultOut),      // output feature  
				.featurePass(ifeaturewireOut),// output feature
				.weightPass(iweightwireOut)
			);

		end
	end
endgenerate


always @(posedge clk or negedge rst) begin : proc_outputArray
 	if(~rst) begin
 		outputArray <= 0;
 	end else begin
 		outputArray <= resultWireArray[SysDimension - 1];
 	end
 end 

endmodule