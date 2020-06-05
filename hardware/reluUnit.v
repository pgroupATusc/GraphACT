
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


floating_point_0 compareUnit (
  .aclk(clk),                                  // input wire aclk
  .s_axis_a_tvalid(1'b1),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata(z),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(1'b1),            // input wire s_axis_b_tvalid
  .s_axis_b_tdata(32'd0),              // input wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid(),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(compare)    // output wire [7 : 0] m_axis_result_tdata
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
