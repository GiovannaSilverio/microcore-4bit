`timescale 1ns/100ps

module microcore_tb();

	reg clk;
	reg rst;
	
	
	wire [3:0] state; 
	
	wire [6:0] estado; wire [6:0] a; wire [6:0] b; wire [6:0] r; wire [6:0] d0; wire [6:0] d1;
	
	wire [3:0] operando_a; 
	wire [3:0] operando_b;
	wire [3:0] wr_data_ula;
	
	microcore DUT(
	
		.clk(clk),
		.rst(rst),
		.state(estado),
		.operando_A(a),
		.operando_B(b),
		.result(r),
		.data_bus2(d0),
		.data_bus1(d1)
	
	);
	assign state = DUT.fio_estado;
	assign operando_a = DUT.operando_A;
	assign operando_b = DUT.operando_B;
	assign wr_data_ula = DUT.res;

	always #10 clk = ~clk;

	initial begin
		clk = 0;
		rst = 0;
		
		#10 
		rst = 1;
		
		#2000 $stop;

	end
endmodule 