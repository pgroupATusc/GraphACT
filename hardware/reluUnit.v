
module reluUnit #(
    parameter dataWidth = 32
)
(
    clk, // system clock 
    rst,  // system rst
    z,  // input value Z
    a); // output activation A
input clk;
input rst;
input[dataWidth -1 : 0] z;
output[dataWidth - 1: 0] a;



wire [7:0] compare;
reg [dataWidth -1 : 0] a;



comp compareUnit (
		.clk    (clk),    //   input,   width = 1,    clk.clk
		.areset (rst), //   input,   width = 1, areset.reset
		.a      (z),      //   input,  width = 32,      a.a
		.b      (32'd0),      //   input,  width = 32,      b.b
		.q      (compare)       //  output,   width = 1,      q.q
	);


reg [dataWidth - 1: 0] z1;
reg [dataWidth - 1: 0] z2;

always @(posedge clk or negedge rst) begin : proc_z1
	if(~rst) begin
		z1 <= 0;
	end else begin
		z1 <= z;
	end
end

always @(posedge clk or negedge rst) begin : proc_z2
	if(~rst) begin
		z2 <= 0;
	end else begin
		z2 <= z1;
	end
end


always @(posedge clk or negedge rst) begin : proc_a
	if(~rst) begin
		a <= 0;
	end else begin
		if(compare[0])
			begin
				a <= z2; 
			end
		else
			begin
				a <= 32'd0; 
			end
	end
end




endmodule
