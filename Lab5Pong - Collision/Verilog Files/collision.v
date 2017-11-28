module collision(
	input wire 			pixel_clk,
	input wire [9:0]	paddle_x, paddle_y,
	input wire [9:0]	paddle_width, paddle_height,
	input wire [9:0]	object_x, object_y,
	input wire [9:0]	object_r, object_width, object_height,
	input wire 			object_isCircle,
	output wire 		collide
	);
	
	reg collide_reg;
	
	reg [9:0]		a1_x, a2_x, a3_x, a4_x, a5_x, a6_x, a7_x, a8_x;
	reg [9:0]		a1_y, a2_y, a3_y, a4_y, a5_y, a6_y, a7_y, a8_y;
	reg [9:0]		b1_x, b2_x, b3_x, b4_x, b5_x, b6_x, b7_x, b8_x;
	reg [9:0]		b1_y, b2_y, b3_y, b4_y, b5_y, b6_y, b7_y, b8_y;
	reg [9:0]		c1_x, c2_x, c3_x, c4_x, c5_x, c6_x, c7_x, c8_x;
	reg [9:0]		c1_y, c2_y, c3_y, c4_y, c5_y, c6_y, c7_y, c8_y;
	reg [9:0]		d1_x, d2_x, d3_x, d4_x, d5_x, d6_x, d7_x, d8_x;
	reg [9:0]		d1_y, d2_y, d3_y, d4_y, d5_y, d6_y, d7_y, d8_y;
	
	
	always @(*)
		begin
			if(object_isCircle) begin
				a1_x = object_x + 2*object_r;
				a1_y = object_y + object_r;
				a2_x = object_x + 63;
				a2_y = object_y + 25;
				a3_x = object_x + 61;
				a3_y = object_y + 19;
				a4_x = object_x + 58;
				a4_y = object_y + 14;
				a5_x = object_x + 54;
				a5_y = object_y + 9;
				a6_x = object_x + 49;
				a6_y = object_y + 5;
				a7_x = object_x + 44;
				a7_y = object_y + 2;
				a8_x = object_x + 38;
				a8_y = object_y + 1;
				
				b1_x = object_x + 32;
				b1_y = object_y + 0;
				b2_x = object_x + 25;
				b2_y = object_y + 1;
				b3_x = object_x + 19;
				b3_y = object_y + 2;
				b4_x = object_x + 14;
				b4_y = object_y + 5;
				b5_x = object_x + 9;
				b5_y = object_y + 9;
				b6_x = object_x + 5;
				b6_y = object_y + 14;
				b7_x = object_x + 2;
				b7_y = object_y + 19;
				b8_x = object_x + 1;
				b8_y = object_y + 25;
				
				c1_x = object_x + 0;
				c1_y = object_y + 31;
				c2_x = object_x + 1;
				c2_y = object_y + 38;
				c3_x = object_x + 2;
				c3_y = object_y + 44;
				c4_x = object_x + 5;
				c4_y = object_y + 49;
				c5_x = object_x + 9;
				c5_y = object_y + 54;
				c6_x = object_x + 14;
				c6_y = object_y + 58;
				c7_x = object_x + 19;
				c7_y = object_y + 61;
				c8_x = object_x + 25;
				c8_y = object_y + 63;
				
				d1_x = object_x + 31;
				d1_y = object_y + 64;
				d2_x = object_x + 38;
				d2_y = object_y + 63;
				d3_x = object_x + 44;
				d3_y = object_y + 61;
				d4_x = object_x + 49;
				d4_y = object_y + 58;
				d5_x = object_x + 54;
				d5_y = object_y + 54;
				d6_x = object_x + 58;
				d6_y = object_y + 49;
				d7_x = object_x + 61;
				d7_y = object_y + 44;
				d8_x = object_x + 63;
				d8_y = object_y + 38;
				end
			end
			
	always @(posedge pixel_clk)
		begin
			if(object_isCircle) begin
				collide_reg <= (a1_x >= paddle_x) && (a1_x <= paddle_x + paddle_width) && (a1_y >= paddle_y) && (a1_y <= paddle_y + paddle_height)
								||	(a2_x >= paddle_x) && (a2_x <= paddle_x + paddle_width) && (a2_y >= paddle_y) && (a2_y <= paddle_y + paddle_height)
								||	(a3_x >= paddle_x) && (a3_x <= paddle_x + paddle_width) && (a3_y >= paddle_y) && (a3_y <= paddle_y + paddle_height)
								||	(a4_x >= paddle_x) && (a4_x <= paddle_x + paddle_width) && (a4_y >= paddle_y) && (a4_y <= paddle_y + paddle_height)
								||	(a5_x >= paddle_x) && (a5_x <= paddle_x + paddle_width) && (a5_y >= paddle_y) && (a5_y <= paddle_y + paddle_height)
								||	(a6_x >= paddle_x) && (a6_x <= paddle_x + paddle_width) && (a6_y >= paddle_y) && (a6_y <= paddle_y + paddle_height)
								||	(a7_x >= paddle_x) && (a7_x <= paddle_x + paddle_width) && (a7_y >= paddle_y) && (a7_y <= paddle_y + paddle_height)
								||	(a8_x >= paddle_x) && (a8_x <= paddle_x + paddle_width) && (a8_y >= paddle_y) && (a8_y <= paddle_y + paddle_height)
								
								||	(b1_x >= paddle_x) && (b1_x <= paddle_x + paddle_width) && (b1_y >= paddle_y) && (b1_y <= paddle_y + paddle_height)
								||	(b2_x >= paddle_x) && (b2_x <= paddle_x + paddle_width) && (b2_y >= paddle_y) && (b2_y <= paddle_y + paddle_height)
								||	(b3_x >= paddle_x) && (b3_x <= paddle_x + paddle_width) && (b3_y >= paddle_y) && (b3_y <= paddle_y + paddle_height)
								||	(b4_x >= paddle_x) && (b4_x <= paddle_x + paddle_width) && (b4_y >= paddle_y) && (b4_y <= paddle_y + paddle_height)
								||	(b5_x >= paddle_x) && (b5_x <= paddle_x + paddle_width) && (b5_y >= paddle_y) && (b5_y <= paddle_y + paddle_height)
								||	(b6_x >= paddle_x) && (b6_x <= paddle_x + paddle_width) && (b6_y >= paddle_y) && (b6_y <= paddle_y + paddle_height)
								||	(b7_x >= paddle_x) && (b7_x <= paddle_x + paddle_width) && (b7_y >= paddle_y) && (b7_y <= paddle_y + paddle_height)
								||	(b8_x >= paddle_x) && (b8_x <= paddle_x + paddle_width) && (b8_y >= paddle_y) && (b8_y <= paddle_y + paddle_height)
								
								||	(c1_x >= paddle_x) && (c1_x <= paddle_x + paddle_width) && (c1_y >= paddle_y) && (c1_y <= paddle_y + paddle_height)
								||	(c2_x >= paddle_x) && (c2_x <= paddle_x + paddle_width) && (c2_y >= paddle_y) && (c2_y <= paddle_y + paddle_height)
								||	(c3_x >= paddle_x) && (c3_x <= paddle_x + paddle_width) && (c3_y >= paddle_y) && (c3_y <= paddle_y + paddle_height)
								||	(c4_x >= paddle_x) && (c4_x <= paddle_x + paddle_width) && (c4_y >= paddle_y) && (c4_y <= paddle_y + paddle_height)
								||	(c5_x >= paddle_x) && (c5_x <= paddle_x + paddle_width) && (c5_y >= paddle_y) && (c5_y <= paddle_y + paddle_height)
								||	(c6_x >= paddle_x) && (c6_x <= paddle_x + paddle_width) && (c6_y >= paddle_y) && (c6_y <= paddle_y + paddle_height)
								||	(c7_x >= paddle_x) && (c7_x <= paddle_x + paddle_width) && (c7_y >= paddle_y) && (c7_y <= paddle_y + paddle_height)
								||	(c8_x >= paddle_x) && (c8_x <= paddle_x + paddle_width) && (c8_y >= paddle_y) && (c8_y <= paddle_y + paddle_height)
								
								||	(d1_x >= paddle_x) && (d1_x <= paddle_x + paddle_width) && (d1_y >= paddle_y) && (d1_y <= paddle_y + paddle_height)
								||	(d2_x >= paddle_x) && (d2_x <= paddle_x + paddle_width) && (d2_y >= paddle_y) && (d2_y <= paddle_y + paddle_height)
								||	(d3_x >= paddle_x) && (d3_x <= paddle_x + paddle_width) && (d3_y >= paddle_y) && (d3_y <= paddle_y + paddle_height)
								||	(d4_x >= paddle_x) && (d4_x <= paddle_x + paddle_width) && (d4_y >= paddle_y) && (d4_y <= paddle_y + paddle_height)
								||	(d5_x >= paddle_x) && (d5_x <= paddle_x + paddle_width) && (d5_y >= paddle_y) && (d5_y <= paddle_y + paddle_height)
								||	(d6_x >= paddle_x) && (d6_x <= paddle_x + paddle_width) && (d6_y >= paddle_y) && (d6_y <= paddle_y + paddle_height)
								||	(d7_x >= paddle_x) && (d7_x <= paddle_x + paddle_width) && (d7_y >= paddle_y) && (d7_y <= paddle_y + paddle_height)
								||	(d8_x >= paddle_x) && (d8_x <= paddle_x + paddle_width) && (d8_y >= paddle_y) && (d8_y <= paddle_y + paddle_height);
				end		
			else
				collide_reg <= (((object_x + object_width >= paddle_x) && (object_x + object_width <= paddle_x + paddle_width)) || ((object_x <= paddle_x + paddle_width) && (object_x >= paddle_x)))
								&& (((object_y >= paddle_y) && (object_y <= paddle_y + paddle_height)) || ((object_y + object_height >= paddle_y) && (object_y + object_height <= paddle_y + paddle_height)));
			end
	
	assign collide = collide_reg;
	
endmodule
