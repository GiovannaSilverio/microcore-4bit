module control_fsm
(
	input wire [1:0] mnm,
	input wire clk,
	input wire rst,
	input wire ula_ack,
	input wire wr_ack,
	input wire pc_ack,
	input wire ri_ack,
	output reg ena_pc,
	output reg ena_ri,
	output reg ena_wr,
	output reg sel_r0_rd,
	output reg sel_addr_data,
	output reg sel_ldr_ula,
	output reg ena_ula,
	output wire [2:0] state_out
);

	// Declare state register
	reg [2:0] current_state;
	assign state_out = current_state;

	// Declare states
	localparam PC = 3'd0, FETCH = 3'd1, LDR = 3'd2, ARIT= 3'd3, LOGIC = 3'd4, WRITE_BACK_RD = 3'd5, WRITE_BACK_R0= 3'd6;

	// Output depends only on the state
	always @ (*) 
		begin
			ena_pc = 0;
			ena_ri = 0;
			ena_wr = 0;
			ena_ula = 0;
			sel_r0_rd = 0;
			sel_addr_data = 0;
			sel_ldr_ula = 0;
			
			case (current_state)

			  PC: begin
					ena_pc = 1; // habilita contador de programa
			  end

			  FETCH: begin
					ena_ri = 1; //habilita registro de instrução
			  end

			  LDR: begin
					ena_wr = 1;				 //habilita escrita no banco
					sel_ldr_ula = 1;         //seleciona a instrução como fonte de dados
					sel_r0_rd = 1;           // escreve no RD escolhido
			  end

			  ARIT: begin
					ena_ula = 1;			 //habilita a ula
					sel_addr_data = 1;       //passa os endereços para o banco ler
			  end

			  LOGIC: begin
					ena_ula = 1;		     //habilita a ula
					sel_addr_data = 1;       //passa os endereços para o banco ler
			  end

			  WRITE_BACK_RD: begin
					ena_wr = 1;			     //habilita escrita no banco
					sel_r0_rd = 1;           //seleção de endereço de escrita no banco : escreve em RD
			  end

			  WRITE_BACK_R0: begin
					ena_wr = 1;				 //habilita escrita no banco
					sel_r0_rd = 0;           //seleção de endereço de escrita no banco : escreve em R0
			  end
				
			endcase
		end
	// Determine the next state
	always @ (posedge clk or negedge rst) begin
		if (!rst)
			current_state <= FETCH;
		else
			case(current_state)
								
				PC: if(pc_ack) 
					current_state <= FETCH;
					else	current_state <= PC;
						
				FETCH: if(!ri_ack)		current_state <= FETCH;
					else	if (mnm== 2'b01 && ri_ack)		current_state <=	LOGIC;
					else	if ((mnm == 2'b10 || mnm == 2'b11 )&& ri_ack)		current_state <=	ARIT;
					else	if ( mnm == 2'b00 && ri_ack)		current_state <= LDR;
						
				LDR: if(wr_ack) 	current_state <= PC;
					else		current_state <= LDR;
					
				ARIT: if(ula_ack)		current_state <= WRITE_BACK_RD;
						else	current_state <= ARIT;
						
				LOGIC: if (ula_ack)		current_state <= WRITE_BACK_R0;
						else current_state <= LOGIC;
					
					
				WRITE_BACK_RD:	if(wr_ack)		current_state <= PC;
						else current_state <= WRITE_BACK_RD;
					
					
				WRITE_BACK_R0: if(wr_ack)		current_state <= PC;
						else	current_state <= WRITE_BACK_R0;
						
				default: 
					current_state <= FETCH;
				
		endcase
	end

endmodule
