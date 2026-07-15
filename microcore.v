module microcore(
	input wire clk,
	input wire rst,
	output wire [6:0] result ,
	output wire [6:0] operando_A,
	output wire [6:0] operando_B,
	output wire [6:0] state,
	output wire [6:0] data_bus1,
	output wire [6:0] data_bus2

);

//estado
wire [2:0] fio_estado;

//pc
wire ena_pc;
wire pc_ack;
wire [7:0] addr_bus;

//memoria
wire [7:0] data_bus;

//ri
wire ena_ri;
wire ri_ack;
wire [1:0] mnm;
wire [1:0] wr_addr_mnm;
wire [3:0] rd_addr_wr_data;

// Banco
wire ena_wr;
wire [1:0] wr_addr; //endereço de escrita
wire [3:0] wr_data;
wire [1:0] rd_addr1;
wire [1:0] rd_addr2;
wire [3:0] rd_data1;
wire [3:0] rd_data2;
wire wr_ack;


//ula
wire ena_ula;
wire ula_ack;
wire [3:0] res;

//mux e demux
wire sel_r0_rd;
wire sel_addr_data;
wire sel_ldr_ula;
wire [3:0] wr_data_ldr;
wire [3:0] rd_addr;

//saida do demux entra no rd_addr
assign rd_addr1 = rd_addr[3:2]; 
assign rd_addr2 = rd_addr[1:0];

program_counter pc(
    .clk(clk),
    .en(ena_pc),
    .rst(rst),
    .ack(pc_ack),
    .pc_out(addr_bus)

);


rom_8x256 memoria(
    .addr(addr_bus),
    .data(data_bus)

);

instruction_register ri(

    .data_in(data_bus),
    .clk(clk),
    .ena(ena_ri),
    .rst(rst),

    .mnm(mnm),
    .wr_addr_mnm(wr_addr_mnm),
    .rd_addr_wr_data(rd_addr_wr_data),

    .ack(ri_ack)

);

register_file banco(

    .clk(clk),
    .wr_en(ena_wr),

    .wr_data(wr_data),
    .wr_addr(wr_addr),

    .rd_addr1(rd_addr1),
    .rd_addr2(rd_addr2),

    .rd_data1(rd_data1),
    .rd_data2(rd_data2),

    .wr_ack(wr_ack)

); 

ula_4bit_sync ula(

    .a(rd_data1),
    .b(rd_data2),

    .sel({mnm, wr_addr_mnm}),

    .clk(clk),
    .enable(ena_ula),

    .result(res),
    .ula_ack(ula_ack)

);

control_fsm state_machine(

    .mnm(mnm),
    .clk(clk),
    .rst(rst),
    .ula_ack(ula_ack),
    .wr_ack(wr_ack),
    .pc_ack(pc_ack),
    .ri_ack(ri_ack),
    .ena_pc(ena_pc),
    .ena_ri(ena_ri),
    .ena_wr(ena_wr),
    .sel_r0_rd(sel_r0_rd),
    .sel_addr_data(sel_addr_data),
    .sel_ldr_ula(sel_ldr_ula),
    .ena_ula(ena_ula),	 
	 .state_out(fio_estado) 

);

demux1x2_4bit demux(
	.in(rd_addr_wr_data),    
	.sel(sel_addr_data),
	.out0(wr_data_ldr), 
	.out1(rd_addr)

);

mux2x1_4bit mux_fonte_dados(
	.in0(res),      
	.in1(wr_data_ldr),
	.sel(sel_ldr_ula),       
	.out(wr_data)          

);

mux2x1_2bit mux_endereco_reg(
	.in0(2'b00),        
	.in1(wr_addr_mnm),   
	.sel(sel_r0_rd),
	.out(wr_addr)

);

decodificador opA(
	.data(rd_data1),
	.disp(operando_A)

);

decodificador opB(
	.data(rd_data2),
	.disp(operando_B)
);


decodificador resultado(
	.data(wr_data),
	.disp(result)

);

decodificador estado(
	.data({1'b0, fio_estado}),
	.disp( state)

);

decodificador display_memoria1(
	.data(data_bus[7:4]), //pega os 4 bits mais significativos
	.disp(data_bus1)      // conecta aos 7 pinos do primeiro display
);

decodificador display_memoria2(
	.data(data_bus[3:0]), //pega os 4 bits menos significativos
	.disp(data_bus2)      //conecta aos 7 pinos do segundo display
);

endmodule