module columnbuffer  #(
	  parameter dataWidth = 32,   // the data bit width
    parameter pvadd= 128,   // the parallesim in feature adder
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
parameter memorySize = addressWidth * dataportWidth;


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


xpm_memory_tdpram #(
  .ADDR_WIDTH_A(addressWidth),               // DECIMAL
  .ADDR_WIDTH_B(addressWidth),               // DECIMAL
  .AUTO_SLEEP_TIME(0),            // DECIMAL
  .BYTE_WRITE_WIDTH_A(32),        // DECIMAL
  .BYTE_WRITE_WIDTH_B(32),        // DECIMAL
  .CASCADE_HEIGHT(0),             // DECIMAL
  .CLOCKING_MODE("common_clock"), // String
  .ECC_MODE("no_ecc"),            // String
  .MEMORY_INIT_FILE("none"),      // String
  .MEMORY_INIT_PARAM("0"),        // String
  .MEMORY_OPTIMIZATION("true"),   // String
  .MEMORY_PRIMITIVE("auto"),      // String
  .MEMORY_SIZE(memorySize),             // DECIMAL
  .MESSAGE_CONTROL(0),            // DECIMAL
  .READ_DATA_WIDTH_A(dataportWidth),         // DECIMAL
  .READ_DATA_WIDTH_B(dataportWidth),         // DECIMAL
  .READ_LATENCY_A(2),             // DECIMAL
  .READ_LATENCY_B(2),             // DECIMAL
  .READ_RESET_VALUE_A("0"),       // String
  .READ_RESET_VALUE_B("0"),       // String
  .RST_MODE_A("SYNC"),            // String
  .RST_MODE_B("SYNC"),            // String
  .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
  .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
  .USE_MEM_INIT(1),               // DECIMAL
  .WAKEUP_TIME("disable_sleep"),  // String
  .WRITE_DATA_WIDTH_A(dataportWidth),        // DECIMAL
  .WRITE_DATA_WIDTH_B(dataportWidth),        // DECIMAL
  .WRITE_MODE_A("no_change"),     // String
  .WRITE_MODE_B("no_change")      // String
)
columnbuffer1 (
  .dbiterra(),                     // 1-bit output: Status signal to indicate double bit error occurrence
                                   // on the data output of port A.

  .dbiterrb(),                     // 1-bit output: Status signal to indicate double bit error occurrence
                                   // on the data output of port A.

  .douta(readportA1),              // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
  .doutb(readportA2),              // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
  .sbiterra(),                     // 1-bit output: Status signal to indicate single bit error occurrence
                                   // on the data output of port A.

  .sbiterrb(),                     // 1-bit output: Status signal to indicate single bit error occurrence
                                   // on the data output of port B.

  .addra(addressportA1),           // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
  .addrb(addressportA2),           // ADDR_WIDTH_B-bit input: Address for port B write and read operations.
  .clka(clk),                      // 1-bit input: Clock signal for port A. Also clocks port B when
                                   // parameter CLOCKING_MODE is "common_clock".

  .clkb(clk),                      // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                   // "independent_clock". Unused when parameter CLOCKING_MODE is
                                   // "common_clock".

  .dina(writeportA1),            // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
  .dinb(writeportA2),            // WRITE_DATA_WIDTH_B-bit input: Data input for port B write operations.

  .ena(enableA),                   // 1-bit input: Memory enable signal for port A. Must be high on clock
                                   // cycles when read or write operations are initiated. Pipelined
                                   // internally.

  .enb(enableA),                   // 1-bit input: Memory enable signal for port B. Must be high on clock
                                   // cycles when read or write operations are initiated. Pipelined
                                   // internally.

  .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                   // ECC enabled (Error injection capability is not available in
                                   // "decode_only" mode).

  .injectdbiterrb(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                   // ECC enabled (Error injection capability is not available in
                                   // "decode_only" mode).

  .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                   // ECC enabled (Error injection capability is not available in
                                   // "decode_only" mode).

  .injectsbiterrb(1'b0),           // 1-bit input: Controls single bit error injection on input data when
                                   // ECC enabled (Error injection capability is not available in
                                   // "decode_only" mode).

  .regcea(1'b1),                  // 1-bit input: Clock Enable for the last register stage on the output
                                  // data path.

  .regceb(1'b1),                   // 1-bit input: Clock Enable for the last register stage on the output
                                   // data path.

  .rsta(rst),                      // 1-bit input: Reset signal for the final port A output register stage.
                                   // Synchronously resets output port douta to the value specified by
                                   // parameter READ_RESET_VALUE_A.

  .rstb(rst),                       // 1-bit input: Reset signal for the final port B output register stage.
                                   // Synchronously resets output port doutb to the value specified by
                                   // parameter READ_RESET_VALUE_B.

  .sleep(1'b0),                    // 1-bit input: sleep signal to enable the dynamic power saving feature.
  .wea(writeEnableA1),                       // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
                                   // data port dina. 1 bit wide when word-wide writes are used. In
                                   // byte-wide write configurations, each bit controls the writing one
                                   // byte of dina to address addra. For example, to synchronously write
                                   // only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
                                   // 4'b0010.

  .web(writeEnableA2)                        // WRITE_DATA_WIDTH_B-bit input: Write enable vector for port B input
                                   // data port dinb. 1 bit wide when word-wide writes are used. In
                                   // byte-wide write configurations, each bit controls the writing one
                                   // byte of dinb to address addrb. For example, to synchronously write
                                   // only bits [15-8] of dinb when WRITE_DATA_WIDTH_B is 32, web would be
                                   // 4'b0010.

);

xpm_memory_tdpram #(
  .ADDR_WIDTH_A(addressWidth),               // DECIMAL
  .ADDR_WIDTH_B(addressWidth),               // DECIMAL
  .AUTO_SLEEP_TIME(0),            // DECIMAL
  .BYTE_WRITE_WIDTH_A(32),        // DECIMAL
  .BYTE_WRITE_WIDTH_B(32),        // DECIMAL
  .CASCADE_HEIGHT(0),             // DECIMAL
  .CLOCKING_MODE("common_clock"), // String
  .ECC_MODE("no_ecc"),            // String
  .MEMORY_INIT_FILE("none"),      // String
  .MEMORY_INIT_PARAM("0"),        // String
  .MEMORY_OPTIMIZATION("true"),   // String
  .MEMORY_PRIMITIVE("auto"),      // String
  .MEMORY_SIZE(memorySize),             // DECIMAL
  .MESSAGE_CONTROL(0),            // DECIMAL
  .READ_DATA_WIDTH_A(dataportWidth),         // DECIMAL
  .READ_DATA_WIDTH_B(dataportWidth),         // DECIMAL
  .READ_LATENCY_A(2),             // DECIMAL
  .READ_LATENCY_B(2),             // DECIMAL
  .READ_RESET_VALUE_A("0"),       // String
  .READ_RESET_VALUE_B("0"),       // String
  .RST_MODE_A("SYNC"),            // String
  .RST_MODE_B("SYNC"),            // String
  .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
  .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
  .USE_MEM_INIT(1),               // DECIMAL
  .WAKEUP_TIME("disable_sleep"),  // String
  .WRITE_DATA_WIDTH_A(dataportWidth),        // DECIMAL
  .WRITE_DATA_WIDTH_B(dataportWidth),        // DECIMAL
  .WRITE_MODE_A("no_change"),     // String
  .WRITE_MODE_B("no_change")      // String
)
columnbuffer2 (
  .dbiterra(),                     // 1-bit output: Status signal to indicate double bit error occurrence
                                   // on the data output of port A.

  .dbiterrb(),                     // 1-bit output: Status signal to indicate double bit error occurrence
                                   // on the data output of port A.

  .douta(readportB1),              // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
  .doutb(readportB2),              // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
  .sbiterra(),                     // 1-bit output: Status signal to indicate single bit error occurrence
                                   // on the data output of port A.

  .sbiterrb(),                     // 1-bit output: Status signal to indicate single bit error occurrence
                                   // on the data output of port B.

  .addra(addressportB1),           // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
  .addrb(addressportB2),           // ADDR_WIDTH_B-bit input: Address for port B write and read operations.
  .clka(clk),                      // 1-bit input: Clock signal for port A. Also clocks port B when
                                   // parameter CLOCKING_MODE is "common_clock".

  .clkb(clk),                      // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                   // "independent_clock". Unused when parameter CLOCKING_MODE is
                                   // "common_clock".

  .dina(writeportB1),            // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
  .dinb(writeportB2),            // WRITE_DATA_WIDTH_B-bit input: Data input for port B write operations.

  .ena(enableB),                   // 1-bit input: Memory enable signal for port A. Must be high on clock
                                   // cycles when read or write operations are initiated. Pipelined
                                   // internally.

  .enb(enableB),                   // 1-bit input: Memory enable signal for port B. Must be high on clock
                                   // cycles when read or write operations are initiated. Pipelined
                                   // internally.

  .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                   // ECC enabled (Error injection capability is not available in
                                   // "decode_only" mode).

  .injectdbiterrb(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                   // ECC enabled (Error injection capability is not available in
                                   // "decode_only" mode).

  .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                   // ECC enabled (Error injection capability is not available in
                                   // "decode_only" mode).

  .injectsbiterrb(1'b0),           // 1-bit input: Controls single bit error injection on input data when
                                   // ECC enabled (Error injection capability is not available in
                                   // "decode_only" mode).

  .regcea(1'b1),                  // 1-bit input: Clock Enable for the last register stage on the output
                                  // data path.

  .regceb(1'b1),                   // 1-bit input: Clock Enable for the last register stage on the output
                                   // data path.

  .rsta(rst),                      // 1-bit input: Reset signal for the final port A output register stage.
                                   // Synchronously resets output port douta to the value specified by
                                   // parameter READ_RESET_VALUE_A.

  .rstb(rst),                       // 1-bit input: Reset signal for the final port B output register stage.
                                   // Synchronously resets output port doutb to the value specified by
                                   // parameter READ_RESET_VALUE_B.

  .sleep(1'b0),                    // 1-bit input: sleep signal to enable the dynamic power saving feature.
  .wea(writeEnableB1),                       // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
                                   // data port dina. 1 bit wide when word-wide writes are used. In
                                   // byte-wide write configurations, each bit controls the writing one
                                   // byte of dina to address addra. For example, to synchronously write
                                   // only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
                                   // 4'b0010.

  .web(writeEnableB2)                        // WRITE_DATA_WIDTH_B-bit input: Write enable vector for port B input
                                   // data port dinb. 1 bit wide when word-wide writes are used. In
                                   // byte-wide write configurations, each bit controls the writing one
                                   // byte of dinb to address addrb. For example, to synchronously write
                                   // only bits [15-8] of dinb when WRITE_DATA_WIDTH_B is 32, web would be
                                   // 4'b0010.

);
endmodule