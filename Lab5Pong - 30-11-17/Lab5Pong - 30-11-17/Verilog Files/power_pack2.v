module power_pack2 #(parameter WIDTH=20,
										 HEIGHT=20, 
										 box_size = 7'd64) 
	 (input wire 			clk,
	  input wire 			reset,
	  input wire			eaten,
	  input wire			spawn,
	  input wire [10:0]	hcount,
	  input wire [9:0]	vcount,
	  input wire [10:0]	randx,
	  input wire [9:0]	randy,
	  output reg [10:0]	rx,
	  output reg [9:0]	ry,
	  output reg [9:0]	r2pixel,
	  output reg [1:0]	mode,
	  output wire			randop
	  );
	 
	reg			display;
	wire			x_valid, y_valid;
	reg randop_reg;  
	reg [7:0] color;
	wire [7:0] randnum;
	wire [9:0] randnum10;
	
	parameter SLOW		= 	2'b00;
	parameter BOOST	= 	2'b01;
	parameter EXTRA	= 	2'b10;
	parameter SHIELD	=	2'b11; 	
	
	
	parameter COLOR_SLOW	= 	8'b000_000_11;
	parameter COLOR_BOOST	=	8'b000_101_10;
	parameter COLOR_EXTRA		=	8'b111_000_11;
	parameter COLOR_SHIELD	=	8'b111_100_00;
	
	
	randgen pptype_gen(.clk(clk), .LFSR(randnum));
	randgen_10bit bitgen10(.clk(clk), .LFSR(randnum10));
	
	always @(*)
		begin
			if(reset || (spawn && !eaten)) begin
				mode = randnum10[5:4]; //randomly extract 2 bit number from the random generated number
				case(mode)
					SLOW: begin
						color = COLOR_SLOW;
						end
					BOOST: begin
						color = COLOR_BOOST;
						end
					SHIELD: begin
						color = COLOR_SHIELD;
						end
					EXTRA: begin
						color = COLOR_EXTRA;
						end
					endcase
				end
			end
	  
	always @(posedge clk)
		begin
			if(reset || (spawn && !eaten)) begin
//				mode <= randnum10[5:4]; //randomly extract 2 bit number from the random generated number
//				//mode <= SHIELD;
//				case(mode)
//					SLOW: begin
//						color <= COLOR_SLOW;
//						end
//					BOOST: begin
//						color <= COLOR_BOOST;
//						end
//					SHIELD: begin
//						color <= COLOR_SHIELD;
//						end
//					EXTRA: begin
//						color <= COLOR_EXTRA;
//						end
//					endcase
				display <= 1;
				rx <= randnum10;//randx;//700;
				ry <= randnum + randnum10[8:0];//randy;//500;
				randop_reg <= 1;
				end
			else if(eaten) begin
				display <= 0;
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
					r2pixel = color;
				else
					r2pixel = 0;
				end
			else 
				r2pixel= 0;	
			end
			
	assign randop = randop_reg;
	
endmodule
