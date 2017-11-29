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
	  input reg	 [10:0]	randx,
	  input reg  [9:0]	randy,
	  output reg [10:0]	rx,
	  output reg [9:0]	ry,
	  output reg [9:0]	r2pixel,
	  output reg [1:0]	mode,
	  output wire			randop
	  );
	 
	reg			display;
	wire			x_valid, y_valid;
	reg randop_reg;  
	
	parameter SHRINK	= 	2'b00;
	parameter BOOST	= 	2'b01;
	parameter idk		= 	2'b10;
	parameter SHIELD	=	2'b11; 	
	
	  
	always @(posedge clk)
		begin
			if(reset || (spawn && !eaten)) begin
				mode <= 2'b00;
				display <= 1;
				rx <= randx;//700;
				ry <= randy;//500;
				randop_reg <= 1;
				end
			else if(eaten) begin
				//display <= 0;
				rx <= 0;
				ry <= 0;
				end
			else
				randop_reg <= 0;
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


module shield(
	input wire clk,
	input wire reset,
	input wire active,
	input wire [10:0]	hcount, paddle_x,
	input wire [9:0] vcount, paddle_y,
	input wire [9:0] paddle_width, paddle_height
	);

	always @(posedge clk)
		begin
			if(active) begin
				end
			end
				
//	always @(hcount or vcount) 
//		begin
//			if ((hcount >= x && hcount < (x+WIDTH)) && (vcount >= y && vcount < (y+HEIGHT)))
//				pixel= COLOR;
//			else pixel= 0;
//			end
	
endmodule
