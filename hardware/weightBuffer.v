
module weightBuffer #(
	parameter dataWidth = 32,
	parameter featureLen = 128,
	parameter psys = 32
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
parameter memorySize = featureLen * featureLen * dataWidth;



// define the input port
input clk;
input rst;
input enable;
input writenable;
input [dataportWidth - 1:0] din;
input [addressWidth -1:0] addr;
output [dataportWidth - 1:0] dout;




 xpm_memory_spram #(
      .ADDR_WIDTH_A(addressWidth),              // DECIMAL
      .AUTO_SLEEP_TIME(0),           			// DECIMAL
      .BYTE_WRITE_WIDTH_A(32),       			// DECIMAL
      .CASCADE_HEIGHT(0),            			// DECIMAL
      .ECC_MODE("no_ecc"),           			// String
      .MEMORY_INIT_FILE("none"),     			// String
      .MEMORY_INIT_PARAM("0"),       			// String
      .MEMORY_OPTIMIZATION("true"),  			// String
      .MEMORY_PRIMITIVE("auto"),     			// String
      .MEMORY_SIZE(memorySize),            		// DECIMAL
      .MESSAGE_CONTROL(0),           			// DECIMAL
      .READ_DATA_WIDTH_A(dataportWidth),        // DECIMAL
      .READ_LATENCY_A(2),            			// DECIMAL
      .READ_RESET_VALUE_A("0"),      			// String
      .RST_MODE_A("SYNC"),           			// String
      .SIM_ASSERT_CHK(0),            			// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_MEM_INIT(1),              			// DECIMAL
      .WAKEUP_TIME("disable_sleep"), 			// String
      .WRITE_DATA_WIDTH_A(dataportWidth),       // DECIMAL
      .WRITE_MODE_A("read_first")               // String
   )
   weightBuffer (
      .dbiterra(addr),             // 1-bit output: Status signal to indicate double bit error occurrence
                                       // on the data output of port A.

      .douta(dout),                   // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
      .sbiterra(),             // 1-bit output: Status signal to indicate single bit error occurrence
                                       // on the data output of port A.

      .addra(addra),                   // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
      .clka(clk),                     // 1-bit input: Clock signal for port A.
      .dina(din),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      .ena(enable),                       // 1-bit input: Memory enable signal for port A. Must be high on clock
                                       // cycles when read or write operations are initiated. Pipelined
                                       // internally.

      .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .regcea(1'b1),                 // 1-bit input: Clock Enable for the last register stage on the output
                                       // data path.

      .rsta(rst),                     // 1-bit input: Reset signal for the final port A output register stage.
                                       // Synchronously resets output port douta to the value specified by
                                       // parameter READ_RESET_VALUE_A.

      .sleep(1'b0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
      .wea(writenable)                        // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
                                       // data port dina. 1 bit wide when word-wide writes are used. In
                                       // byte-wide write configurations, each bit controls the writing one
                                       // byte of dina to address addra. For example, to synchronously write
                                       // only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
                                       // 4'b0010.

   );



endmodule