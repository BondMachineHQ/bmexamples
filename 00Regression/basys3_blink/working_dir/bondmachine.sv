
`timescale 1ns/1ps
module a0(clock_signal, reset_signal, o0, o0_valid, o0_received);

	input clock_signal;
	input reset_signal;

	output [0:0] o0;
	output o0_valid;
	input o0_received;

	wire [1:0] rom_bus;
	wire [3:0] rom_value;


	p0 p0_instance(clock_signal, reset_signal, rom_bus, rom_value, o0, o0_valid, o0_received);
	p0rom p0rom_instance(rom_bus, rom_value);

endmodule
module bondmachine_main(

	input clk,
	input btnC,
	output reg [7:0] led
);

	assign reset = btnC;
	wire [0:0] Output0;

	reg [31:0] divider;

	bondmachine bondmachine_inst (divider[23], reset, Output0, Output0_valid, Output0_received);


	always @ (posedge clk) begin
		divider <= divider + 1;
	end
	always @ (posedge clk) begin
		led[0] <= Output0[0];
	end
endmodule
module bondmachine(clk, reset, o0, o0_valid, o0_received);

	input clk, reset;
	//--------------Output Ports-----------------------
	output [0:0] o0;
	output o0_valid;
	input o0_received;



	wire [0:0] p0o0;
	wire p0o0_valid;
	wire p0o0_received;
	wire o0_received;


	//Instantiation of the Processors and Shared Objects
	a0 a0_inst(clk, reset, p0o0, p0o0_valid, p0o0_received);

	assign o0 = p0o0;
	assign o0_valid = p0o0_valid;

	assign p0o0_received = o0_received;

endmodule
`timescale 1ns/1ps
module p0rom(input [1:0] rom_bus, output [3:0] rom_value);
	reg [3:0] _rom [0:3];
	initial
	begin
	_rom[0] = 4'b0000;
	_rom[1] = 4'b1000;
	_rom[2] = 4'b0100;
	end
	assign rom_value = _rom[rom_bus];
endmodule
`timescale 1ns/1ps
module p0(clock_signal, reset_signal, rom_bus, rom_value, o0, o0_valid, o0_received);

	input clock_signal;
	input reset_signal;
	output  [1:0] rom_bus;
	input  [3:0] rom_value;

	output [0:0] o0;
	output o0_valid;
	input o0_received;

			// Opcodes in the instructions, length according the number of the selected.
	localparam	INC=2'b00,          // Increment a register by 1
			J=2'b01,          // Jump to a program location
			R2O=2'b10;          // Register to output

	localparam	R0=1'b0,		// Registers in the intructions
			R1=1'b1;
	localparam			O0=1'b0;
	reg [0:0] _auxo0;

	reg [0:0] _ram [0:0];		// Internal processor RAM

	(* KEEP = "TRUE" *) reg [1:0] _pc;		// Program counter

	// The number of registers are 2^R, two letters and an underscore as identifier , maximum R=8 and 265 rigisters
	(* KEEP = "TRUE" *) reg [0:0] _r0;
	(* KEEP = "TRUE" *) reg [0:0] _r1;

	wire [3:0] current_instruction;
	assign current_instruction=rom_value;


	reg o0_val;
	reg waitsm;
	initial waitsm = 1'b0;

	always @(posedge clock_signal, posedge reset_signal)
	begin
		if (reset_signal)
		begin
			o0_val <= #1 1'b0;
		end
		else
		begin
			case(current_instruction[3:2])
				R2O: begin
					case (current_instruction[0])
					O0 : begin
						o0_val <= 1'b1;
					end
					default: begin
						if (o0_received)
						begin
							o0_val <= #1 1'b0;
						end
					end
					endcase
				end
				default: begin
					if (o0_received)
					begin
						o0_val <= #1 1'b0;
					end
				end
			endcase
		end
	end

	always @(posedge clock_signal, posedge reset_signal)
	begin
		if(reset_signal)
		begin
			_pc <= #1 2'h0;
			_r0 <= #1 1'h0;
			_r1 <= #1 1'h0;
		end
		else begin
			// ha placeholder
			$display("Program Counter:%d", _pc);
			$display("Instruction:%b", rom_value);
			$display("Registers r0:%b r1:%b ", _r0, _r1);
				case(current_instruction[3:2])
					INC: begin
						case (current_instruction[1])
						R0 : begin
							_r0 <= #1 _r0 + 1'b1;
							$display("INC R0");
						end
						R1 : begin
							_r1 <= #1 _r1 + 1'b1;
							$display("INC R1");
						end
						endcase
						_pc <= #1 _pc + 1'b1;
					end
					J: begin
						_pc <= #1 current_instruction[1:0];
						$display("J ", current_instruction[1:0]);
					end
					R2O: begin
						case (current_instruction[1])
						R0 : begin
							case (current_instruction[0])
							O0 : begin
								_auxo0 <= #1 _r0;
								$display("R2O R0 O0");
							end
							endcase
						end
						R1 : begin
							case (current_instruction[0])
							O0 : begin
								_auxo0 <= #1 _r1;
								$display("R2O R1 O0");
							end
							endcase
						end
						endcase
						_pc <= #1 _pc + 1'b1;
					end
					default : begin
						$display("Unknown Opcode");
						_pc <= #1 _pc + 1'b1;
					end
				endcase
			// ha placeholder
		end
	end
	assign rom_bus = _pc;
	assign o0 = _auxo0;
	assign o0_valid = o0_val;
endmodule
