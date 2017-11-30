module power_pack2 #(parameter WIDTH=20,
										 HEIGHT=20, 
										 box_size = 7'd64,
										 COLOR=8'b000_000_11) 
	 (input wire 			clk,
	  input wire 			reset,
	  input wire			eaten,
	  input wire			spawn,
	  input wire [10:0]	hcount,
	  input wire [9:0]	vcount,
	  output reg [10:0]	rx,
	  output reg [9:0]	ry,
	  output reg [9:0]	r2pixel,
	  output wire			randop
	  );
	 
	wire [9:0]	randx, randy;
	reg			display;
	wire			randx_rdy_clr, randy_rdy_clr;
	wire			randx_rdy, randy_rdy;
	wire randop_reg;
	  
	rndm_gen x_coor(.clock(clk),
						 .reset(reset),
						 .rnd(randx));
						 
	rndm_gen y_coor(.clock(clk),
						 .reset(reset),
						 .rnd(randy));
							
	always @(posedge clk)
		begin
			if(spawn)
				randop_reg <= 1;
			else
				randop_reg <= 0;
			if(reset || (spawn && !eaten)) begin
				display <= 1;
				rx <= 700;
				ry <= 500;
				end
			else if(eaten) begin
				//display <= 0;
				rx <= 0;
				ry <= 0;
				end
			end
	  
	always @(hcount or vcount) 
		begin
			if ((hcount >= rx && hcount < (rx+WIDTH)) && (vcount >= ry && vcount < (ry+HEIGHT))) begin
				if(display)
					r2pixel= COLOR;
				else
					r2pixel = 0;
				end
			else 
				r2pixel= 0;	
			end
				
	assign randop = randop_reg;			
	
endmodule
