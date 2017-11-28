`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:51:37 04/11/2013 C
// Design Name: 
// Module Name:    labkit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module labkit(
    input clk_100mhz,
    input [7:0] switch,
	 
    input btn_up,       // buttons, depress = high
    input btn_enter,
    input btn_left,
    input btn_down,
    input btn_right, 
	 
    output [7:0] seg,   //output 0->6 = seg A->G ACTIVE LOW, 
                        //output 7 = decimal point, all active low
								
    output [3:0] dig,   //selects digits 0-3, ACTIVE LOW
    output [7:0] led,   // 1 turns on leds
	 
    output [2:0] vgared,
    output [2:0] vgagreen,
    output [2:1] vgablue,
    output hsync,
    output vsync,
	 
    inout [7:0] ja,
    inout [7:0] jb,
    inout [7:0] jc,
    input [7:0] jd,
    inout [19:0] exp_io_n,
    inout [19:0] exp_io_p
    );

    // all unused outputs must be assigned
//    assign vgared = 3'b111;
//    assign vgagreen = 3'b111;
//    assign vgablue = 2'b11;
//    assign hsync = 1'b1;
//    assign vsync = 1'b1;
	 
// next three lines turns the 7 seg display completely off
//    assign seg = 7'b111_1111; 	//output 0->6 = seg A->G ACTIVE LOW
//    assign dp = 1'b1; 				//decimal point ACTIVE LOW
//    assign dig = 4'hF;  			//selectives digits 0-3, ACTIVE LOW
 //
 
  
//////////////////////////////////////////////////////////////////
// dcm_all is a general purpose digital clock manager. It is used
// to create clocks at desired frequncies and phases.
//
	wire clk_25mhz;
   wire clk_65mhz;
	wire clk_100mhz_buf;  // 100mhz buffered clock, not used
		
   dcm_all_v2 #(.DCM_DIVIDE(20), .DCM_MULTIPLY(13))
     	my_clocks(
				.CLK(clk_100mhz),
				.CLKSYS(clk_100mhz_buf),
				.CLK25(clk_25mhz),
				.CLK_out(clk_65mhz)
	);
//
//////////////////////////////////////////////////////////////////

   wire pixel_clk = clk_65mhz;  // clock for 1024 x 768 60hz resolution  

   assign led = switch;  // provide feedback

   wire [10:0] hcount;
   wire [9:0]  vcount;   
	wire blank, hblank;
		
	wire [7:0] pixel; //,paddle_pix,ball;
	
	//assign pixel = paddle_pix | ball;
	
	assign vgared = blank ? pixel[7:5] : 3'b0;
	assign vgagreen = blank ? pixel[4:2] : 3'b0;
	assign vgablue = blank ? pixel[1:0] : 2'b0;
	
	debounce  db_up(.reset(reset), .clock(pixel_clk), .noisy(btn_up), .clean(up));			 
	debounce  db_down(.reset(reset), .clock(pixel_clk), .noisy(btn_down), .clean(down)); 
	debounce  db_left(.reset(reset), .clock(pixel_clk), .noisy(btn_left), .clean(left));			 
	debounce  db_right(.reset(reset), .clock(pixel_clk), .noisy(btn_right), .clean(right));    
	debounce  db_enter(.reset(1'b0), .clock(pixel_clk), .noisy(btn_enter), .clean(enter)); 
	
   assign reset = enter;
	
   vga_general video_driver(.pixel_clk(pixel_clk),.hcount(hcount), .vcount(vcount),
		.hsync(hsync1),.vsync(vsync1), .blank(blank1), .hblank(hblank1));

   wire [7:0] pong_pixel;
	
	reg [7:0] rgb;
	reg hs, vs, b;
   
	wire border = (hcount==0 | hcount==1023 | vcount==0 | vcount==767);
	
   always @(posedge pixel_clk) begin
//     case (switch[7:6])
     case (switch[1:0])
		2'b00: begin   // send the pong pixels through
		         hs <= phsync;
					vs <= pvsync;
					b <= pblank;
					rgb <= pong_pixel;
				 end
		2'b01:	 begin  // 1 pixel outline of visible area (white)
		         hs <= hsync1;
					vs <= vsync1;
					b <= blank1;
					rgb <= {{8{border}}};
				 end
		2'b10:  begin  // color bars
		         hs <= hsync1;
					vs <= vsync1;
					b <= blank1;
					rgb <= {{3{hcount[8]}}, {3{hcount[7]}}, {2{hcount[6]}}};				
             end
		2'b11: begin   // send the pong pixels through
		         hs <= phsync;
					vs <= pvsync;
					b <= pblank;
					rgb <= pong_pixel;
				 end
		 endcase
	  end
				 
               
		
   assign pixel = rgb; //{{3{hcount[8]}}, {3{hcount[7]}}, {2{hcount[6]}}};	//rgb;
	assign blank = b;
	assign vsync = vs;
	assign hsync = hs;	
	
	wire switch2 = switch[2];
	
   pong_game psolution(.pixel_clk(pixel_clk), .reset(reset), .switch(switch2) ,.up(up), .down(down),.left(left),.right(right), .pspeed(switch[7:4]),
	    .hcount(hcount), .vcount(vcount), .hsync(hsync1), .vsync(vsync1), .blank(blank1),
		 .phsync(phsync), .pvsync(pvsync), .pblank(pblank), .pixel(pong_pixel));
	

//////////////////////////////////////////////////////////////////
// 
// just show counter working as a system check - not necessary.
	reg [30:0] counter;
	
	always@(posedge pixel_clk) begin
	  counter <=  counter + 1;
	end
	
	assign seg[7] = 1'b0; // turn off decimal point

	display_4hex  my_display(
	  .clk(pixel_clk),
     .data(counter[30:15]),
	  .seg(seg[6:0]),
     .strobe(dig)
    );
//
//////////////////////////////////////////////////////////////////
	
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// pong_game: the game itself!
//
////////////////////////////////////////////////////////////////////////////////

module pong_game (
   input pixel_clk,	// 65MHz clock
   input reset,		// 1 to initialize module
	input switch,
   input up,		// 1 when paddle should move up
   input down,  	// 1 when paddle should move down
	input left,		// 1 when paddle should move left
   input right,  	// 1 when paddle should move right
   input [3:0] pspeed,  // puck speed in pixels/tick 
   input [10:0] hcount,	// horizontal index of current pixel (0..1023)
   input [9:0]  vcount, // vertical index of current pixel (0..767)
   input hsync,		// XVGA horizontal sync signal (active low)
   input vsync,		// XVGA vertical sync signal (active low)
   input blank,		// XVGA blanking (1 means output black pixel)
 	
   output phsync,	// pong game's horizontal sync
   output pvsync,	// pong game's vertical sync
   output pblank,	// pong game's blanking
   output reg [7:0] pixel	// pong game's pixel  // r=7:5, g=4:2, b=1:0 
   );

   wire [2:0] checkerboard;
	wire pp_eaten;
	
////////////////////////////////////////////////////////////////////	
// REPLACE ME! The code below just generates a color checkerboard
// using 64 pixel by 64 pixel squares.
   
//   assign phsync = hsync;
//   assign pvsync = vsync;
//   assign pblank = blank;
//   assign checkerboard = hcount[8:6] + vcount[8:6];

   // here we use three bits from hcount and vcount to generate the \
   // checkerboard

//  assign pixel = {{8{checkerboard[2]}}, {8{checkerboard[1]}}, {8{checkerboard[0]}}} ;
////////////////////////////////////////////////////////////////////	


////////////////////////////////////////////////////////////////////	
// need to take care of the pipe line delays;
// the round puck is delayed by two clock cycles
// deleay paddle_pix, hsync, vsync, pblank by two clock cycles

  reg [15:0] paddle_pix_delay;
  reg [1:0] hsync_delay, vsync_delay, blank_delay;
  
  always @(posedge pixel_clk) begin
    hsync_delay <= {hsync_delay[0],hsync};
	 vsync_delay <= {vsync_delay[0],vsync};
	 blank_delay <= {blank_delay[0],blank};
	 paddle_pix_delay <= {paddle_pix_delay[7:0],paddle_pix};

  end
 
   assign phsync = hsync_delay[1];
   assign pvsync = vsync_delay[1];
   assign pblank = blank_delay[1]; 
	
	reg[5:0] boost;
	always @(posedge pixel_clk)begin
	if (switch==0)begin
	pixel <= paddle_pix_delay[15:8] | ball | ball2 |powerbox | powerbox2;
	boost <=0;
	end
	else if(switch==1)begin
	pixel <= paddle_pix_delay[15:8] | ball | ball2 | ball3 | ball4 | powerbox | powerbox2;
	boost <=80;
	end
	end
  



////////////////////////////////////////////////////////////////////	



//   assign pixel =  paddle_pix | ball; //{{8{checkerboard[2]}}, {8{checkerboard[1]}}, {8{checkerboard[0]}}} ;
 
 
 	wire [7:0] paddle_pix,ball,ball2,ball3,ball4,powerbox, powerbox2;

   //parameter PADDLE_WIDTH = 16;
	//parameter PADDLE_HEIGHT = 128;
	wire [9:0] PADDLE_WIDTH;
	wire [9:0] PADDLE_HEIGHT;
   wire [9:0] PADDLE_X;
   wire [9:0] paddle_y;
	
//	draw_box #(.WIDTH(PADDLE_WIDTH), .HEIGHT(PADDLE_HEIGHT), .COLOR(8'b000_111_00))
//	   paddle (.pixel_clk(pixel_clk), .hcount(hcount), .vcount(vcount),
//		.x(PADDLE_X), .y(paddle_y), .pixel(paddle_pix));
		
	draw_box #(.COLOR(8'b000_111_00))
	   paddle (.pixel_clk(pixel_clk),.left(left),.right(right),.up(up),.down(down),.reset(reset), .hcount(hcount), .vcount(vcount),
		.x(PADDLE_X), .y(paddle_y), .paddle_width(PADDLE_WIDTH), .paddle_height(PADDLE_HEIGHT), .pixel(paddle_pix));


//////////////////////////////////////////////////////////////////
// create a pulse every vertical refresh

	reg vsync_delayed;    
	always @(posedge pixel_clk)
	vsync_delayed <= vsync;
	assign vsync_pulse = vsync_delayed && ~vsync;
//
//////////////////////////////////////////////////////////////////


			 			
	wire stop;  // used to halt the game
	
   move_paddle paddle_motion(.pixel_clk(pixel_clk), .vsync_pulse(vsync_pulse),
		.up(up), .down(down),.left(left),.right(right), .paddle_x(PADDLE_X),.paddle_y(paddle_y), .reset(reset), .stop(stop));

//===========Ball1=====================
	reg [9:0] ball_y = 300; 
	reg [10:0] ball_x = 300;
	reg [4:0] speed_x, speed_y;
//===========Ball2=====================
	reg [9:0] ball_y2= 100; 
	reg [10:0] ball_x2= 100;
//===========Ball3=====================
	reg [9:0] ball_y3= 400; 
	reg [10:0] ball_x3= 600;
//===========Ball4=====================
	reg [9:0] ball_y4= 700; 
	reg [10:0] ball_x4= 400;
	

always @(posedge pixel_clk)begin
	 speed_x = pspeed[3:2]*2+boost;
	 speed_y = pspeed[1:0]*2+boost;
	end

   parameter BALL_SIZE = 7'd64;
   parameter MAX_BALL_Y = 767 - BALL_SIZE; //
   parameter MIN_BALL_Y = 1;
   parameter MAX_BALL_X = 1023 - BALL_SIZE; //
	parameter MIN_BALL_X = 5;
	reg ball_up, ball_right, ball_up2,ball_right2, ball_up3,ball_right3, ball_up4,ball_right4;
	
	wire [10:0] new_ball_x = ball_right ? ball_x + speed_x : ball_x - speed_x;
	wire [9:0]  new_ball_y = ball_up    ? ball_y - speed_y : ball_y + speed_y;
	
	wire [10:0] new_ball_x2 = ball_right2 ? ball_x2 + speed_x : ball_x2 - speed_x;
	wire [9:0]  new_ball_y2 = ball_up2    ? ball_y2 - speed_y : ball_y2 + speed_y;
	
	wire [10:0] new_ball_x3 = ball_right3 ? ball_x3 + speed_x : ball_x3 - speed_x;
	wire [9:0]  new_ball_y3 = ball_up3    ? ball_y3 - speed_y : ball_y3 + speed_y;
	
	wire [10:0] new_ball_x4 = ball_right4 ? ball_x4 + speed_x : ball_x4 - speed_x;
	wire [9:0]  new_ball_y4 = ball_up4    ? ball_y4 - speed_y : ball_y4 + speed_y;
//	wire paddle_range1 = ((ball_y+BALL_SIZE)>= paddle_y) && 
//				(ball_y<paddle_y+PADDLE_HEIGHT);

	wire stop1, stop2, stop3, stop4;
	
	collision c1(.pixel_clk(pixel_clk),
					 .paddle_x(PADDLE_X),
					 .paddle_y(paddle_y),
					 .paddle_width(PADDLE_WIDTH),
					 .paddle_height(PADDLE_HEIGHT),
					 .object_x(ball_x),
					 .object_y(ball_y),
					 .object_r(6'd32),
					 .object_width(),
					 .object_height(),
					 .object_isCircle(1),
					 .collide(stop1));
					 
	collision c2(.pixel_clk(pixel_clk),
					 .paddle_x(PADDLE_X),
					 .paddle_y(paddle_y),
					 .paddle_width(PADDLE_WIDTH),
					 .paddle_height(PADDLE_HEIGHT),
					 .object_x(ball_x2),
					 .object_y(ball_y2),
					 .object_r(6'd32),
					 .object_width(),
					 .object_height(),
					 .object_isCircle(1),
					 .collide(stop2));
					 
//	collision c3(.pixel_clk(pixel_clk),
//					 .paddle_x(PADDLE_X),
//					 .paddle_y(paddle_y),
//					 .paddle_width(PADDLE_WIDTH),
//					 .paddle_height(PADDLE_HEIGHT),
//					 .object_x(ball_x3),
//					 .object_y(ball_y3),
//					 .object_r(6'd32),
//					 .object_width(),
//					 .object_height(),
//					 .object_isCircle(1),
//					 .collide(stop3));
//
//	collision c4(.pixel_clk(pixel_clk),
//					 .paddle_x(PADDLE_X),
//					 .paddle_y(paddle_y),
//					 .paddle_width(PADDLE_WIDTH),
//					 .paddle_height(PADDLE_HEIGHT),
//					 .object_x(ball_x4),
//					 .object_y(ball_y4),
//					 .object_r(6'd32),
//					 .object_width(),
//					 .object_height(),
//					 .object_isCircle(1),
//					 .collide(stop4));
	
	assign stop = stop1 | stop2 | stop3 | stop4;
					 
	//wire 			pp_eaten;
	wire [10:0] pp_x;
	wire [9:0]	pp_y;
					 
	collision pp(.pixel_clk(pixel_clk),
					 .paddle_x(PADDLE_X),
					 .paddle_y(paddle_y),
					 .paddle_width(PADDLE_WIDTH),
					 .paddle_height(PADDLE_HEIGHT),
					 .object_x(pp_x),
					 .object_y(pp_y),
					 .object_r(),
					 .object_width(20),
					 .object_height(20),
					 .object_isCircle(0),
					 .collide(pp_eaten));


   //assign stop = ball_x + 1 < PADDLE_X + PADDLE_WIDTH;

//////////////////////////////////////////////////////////////////	
// use to draw a square puck
//
//	draw_box #(.WIDTH(BALL_SIZE), .HEIGHT(BALL_SIZE), .COLOR(8'b111_111_11))
//	   create_ball (.pixel_clk(pixel_clk), .hcount(hcount), .vcount(vcount),
//		.x(ball_x), .y(ball_y), .pixel(ball));
//
//////////////////////////////////////////////////////////////////
//   Power pack
	//wire pack1x;
	//wire pack1y;


//	randomGrid rg(.pixel_clk(pixel_clk),.rand_X(pack1x),.rand_Y(pack1y));

	//reg [9:0] pack1x = 0; 
	//reg [10:0] pack1y = 300;
  power_pack pack1(.pixel_clk(pixel_clk),.reset(reset),.up(up), .down(down),.left(left),.right(right),.rx(pack1x),.hcount(hcount),.ry(pack1y)
  , .vcount(vcount), .r2pixel(powerbox));
  
  wire spawn, counter_expired;
  
  power_pack2 pack2(.clk(pixel_clk),
						  .reset(reset),
						  .eaten(pp_eaten),
						  .spawn(spawn),
						  .hcount(hcount),
						  .vcount(vcount),
						  .rx(pp_x),
						  .ry(pp_y),
						  .r2pixel(powerbox2));
						  
	pp_timer	myPp_timer(.clk(clk_25mhz),
							  .eaten(eaten),
							  .spawn(spawn));
	

//////////////////////////////////////////////////////////////////
// create a round puck, pipelined by two stages
/////////////////////////////////////////////////////////////////
   round_piped #(.COLOR(8'b111_000_11)) round_puck(.pixel_clk(pixel_clk), .ball_size(BALL_SIZE), .rx(ball_x),
	   .hcount(hcount), .ry(ball_y), .vcount(vcount), .rpixel(ball));
		
   round_piped #(.COLOR(8'b111_111_00)) round_puck2(.pixel_clk(pixel_clk), .ball_size(BALL_SIZE), .rx(ball_x2),
	   .hcount(hcount), .ry(ball_y2), .vcount(vcount), .rpixel(ball2));
		
	round_piped #(.COLOR(8'b000_000_11)) round_puck3(.pixel_clk(pixel_clk), .ball_size(BALL_SIZE), .rx(ball_x3),
	   .hcount(hcount), .ry(ball_y3), .vcount(vcount), .rpixel(ball3));
		
   round_piped round_puck4(.pixel_clk(pixel_clk), .ball_size(BALL_SIZE), .rx(ball_x4),
	   .hcount(hcount), .ry(ball_y4), .vcount(vcount), .rpixel(ball4));

//////////////////////////////////////////////////////////////////
//                  Ball 1's motion
//////////////////////////////////////////////////////////////////
	always @(posedge pixel_clk)
		if (reset) begin
			//speed_x <= {3'b0,switch[3:2]};
			//speed_y <= {3'b0,switch[1:0]};
			ball_x <= 150;
			ball_y <= 100;
			ball_up <= 1;
			ball_right <= 0;
			end
		else if (vsync_pulse && ~stop) begin
		// vertical movement
				ball_y <= new_ball_y;
			   if ((ball_up)&&(new_ball_y < MIN_BALL_Y) || (new_ball_y>MAX_BALL_Y)) begin
					ball_up <= 0;
					ball_y <= MIN_BALL_Y;
				end
			   if ((~ball_up)&&(new_ball_y > MAX_BALL_Y))begin
					ball_up <= 1;
					ball_y <= MAX_BALL_Y;
				end
		//horizontal movement
				ball_x <= new_ball_x;
				if ((~ball_right)&& (new_ball_x < MIN_BALL_X)||(new_ball_x>MAX_BALL_X)) begin
				   ball_right <= 1;
					ball_x <= MIN_BALL_X;
				   end
				if ((ball_right)&&(new_ball_x > MAX_BALL_X)) begin
				   ball_right <= 0;
					ball_x <= MAX_BALL_X;
				   end
				//if (~ball_right && paddle_range1	&& new_ball_x < PADDLE_X+PADDLE_WIDTH) begin
					//ball_right <=1;
					//ball_x <= PADDLE_X+PADDLE_WIDTH;
					
				
					// lower half of the paddle, speed up 4x
//					speed_x <= (ball_y >= paddle_y + paddle_height/2) ? sw[3:2]*4 : sw[3:2];
//					speed_y <= (ball_y >= paddle_y + paddle_height/2) ? sw[1:0]*4 : sw[1:0];
//					speed_x <= switch[3:2];
//					speed_y <= switch[1:0];
					//end		
	
//				if((ball_x==pack1x)&&(ball_y==pack1y))begin
//					speed_x<=speed_x/2;
//					speed_y<=speed_y/2;
//					ball_up <= 1;
//					end
			
       end	

////////////////////////////////////////////////////////////////////////////////////
//								balls 2's motion
///////////////////////////////////////////////////////////////////////////////////		

always @(posedge pixel_clk)
		if (reset) begin
			//speed_x <= {3'b0,switch[3:2]};
			//speed_y <= {3'b0,switch[1:0]};
			ball_x2 <= 10;
			ball_y2 <= 100;
			ball_up2 <= 1;
			ball_right2 <= 1;
			end
		else if (vsync_pulse && ~stop) begin
		// vertical movement
				ball_y2 <= new_ball_y2;
			   if ((ball_up2)&&(new_ball_y2 < MIN_BALL_Y) || (new_ball_y2>MAX_BALL_Y)) begin
					ball_up2 <= 0;
					ball_y2 <= MIN_BALL_Y;
				end
			   if ((~ball_up2)&&(new_ball_y2 > MAX_BALL_Y))begin
					ball_up2 <= 1;
					ball_y2 <= MAX_BALL_Y;
				end
		//horizontal movement
				ball_x2 <= new_ball_x2;
				if ((~ball_right2)&& (new_ball_x2 < MIN_BALL_X)||(new_ball_x2>MAX_BALL_X)) begin
				   ball_right2 <= 1;
					ball_x2 <= MIN_BALL_X;
				   end
				if ((ball_right2)&&(new_ball_x2 > MAX_BALL_X)) begin
				   ball_right2 <= 0;
					ball_x2 <= MAX_BALL_X;
				   end
				//if (~ball_right2 && paddle_range1	&& new_ball_x2 < PADDLE_X+PADDLE_WIDTH) begin
					//ball_right2 <=1;
					//ball_x2 <= PADDLE_X+PADDLE_WIDTH;
					
				
			
       end				 


 


////////////////////////////////////////////////////////////////////////////////////
//								balls 3's motion
///////////////////////////////////////////////////////////////////////////////////		

always @(posedge pixel_clk)
		if (reset) begin
			//speed_x <= {3'b0,switch[3:2]};
			//speed_y <= {3'b0,switch[1:0]};
			ball_x3 <= 50;
			ball_y3 <= 500;
			ball_up3 <= 1;
			ball_right3 <= 0;
			end
		else if (vsync_pulse && ~stop) begin
		// vertical movement
				ball_y3 <= new_ball_y3;
			   if ((ball_up3)&&(new_ball_y3 < MIN_BALL_Y) || (new_ball_y3>MAX_BALL_Y)) begin
					ball_up3 <= 0;
					ball_y3 <= MIN_BALL_Y;
				end
			   if ((~ball_up3)&&(new_ball_y3 > MAX_BALL_Y))begin
					ball_up3 <= 1;
					ball_y3 <= MAX_BALL_Y;
				end
		//horizontal movement
				ball_x3 <= new_ball_x3;
				if ((~ball_right3)&& (new_ball_x3 < MIN_BALL_X)||(new_ball_x3>MAX_BALL_X)) begin
				   ball_right3 <= 1;
					ball_x3 <= MIN_BALL_X;
				   end
				if ((ball_right3)&&(new_ball_x3 > MAX_BALL_X)) begin
				   ball_right3 <= 0;
					ball_x3 <= MAX_BALL_X;
				   end
				//if (~ball_right3 && paddle_range1	&& new_ball_x3 < PADDLE_X+PADDLE_WIDTH) begin
					//ball_right3 <=1;
					//ball_x3 <= PADDLE_X+PADDLE_WIDTH;
					
				
			
       end	

////////////////////////////////////////////////////////////////////////////////////
//								balls 4's motion
///////////////////////////////////////////////////////////////////////////////////		
always @(posedge pixel_clk)
		if (reset) begin
			//speed_x <= {3'b0,switch[3:2]};
			//speed_y <= {3'b0,switch[1:0]};
			ball_x4 <= 900;
			ball_y4 <= 100;
			ball_up4 <= 1;
			ball_right4 <= 0;
			end
		else if (vsync_pulse && ~stop) begin
		// vertical movement
				ball_y4 <= new_ball_y4;
			   if ((ball_up4)&&(new_ball_y4 < MIN_BALL_Y) || (new_ball_y4>MAX_BALL_Y)) begin
					ball_up4 <= 0;
					ball_y4 <= MIN_BALL_Y;
				end
			   if ((~ball_up4)&&(new_ball_y4 > MAX_BALL_Y))begin
					ball_up4 <= 1;
					ball_y4 <= MAX_BALL_Y;
				end
		//horizontal movement
				ball_x4 <= new_ball_x4;
				if ((~ball_right4)&& (new_ball_x4 < MIN_BALL_X)||(new_ball_x4>MAX_BALL_X)) begin
				   ball_right4 <= 1;
					ball_x4 <= MIN_BALL_X;
				   end
				if ((ball_right4)&&(new_ball_x4 > MAX_BALL_X)) begin
				   ball_right4 <= 0;
					ball_x4 <= MAX_BALL_X;
				   end
				//if (~ball_right3 && paddle_range1	&& new_ball_x3 < PADDLE_X+PADDLE_WIDTH) begin
					//ball_right3 <=1;
					//ball_x3 <= PADDLE_X+PADDLE_WIDTH;
					
				
			
       end	
		 
endmodule 
///////////////////////////////////////////////////////////////////
//                  INNOVATIVE PORTION
//////////////////////////////////////////////////////////////////

/*
module randomGrid(
	input pixel_clk,
	output reg [10:0]rand_X,
	output reg [9:0]rand_Y);
	
	reg [6:0] pointX, pointY = 5;

	always @(posedge pixel_clk)begin
	 if(pointX<200)begin
		pointX<=pointX+1;
		pointY<=pointY+1;
		rand_X<=20;
		rand_Y<=20;
	end
	else begin
		pointX<=pointX-2;
		pointX<=pointX-2;
		rand_X<=100;
		rand_Y<=100;
	end
	end
endmodule
*/

module power_pack	
	#(parameter WIDTH=30,
	 HEIGHT=30, 
	 box_size = 7'd64,
	 COLOR=8'b111_000_00) //deault colour: red
	
	(input pixel_clk,
	 input reset,
	 input up,down,left,right, 
	 input [10:0] hcount,
	 output reg [10:0] rx,
	 input [9:0] vcount,
	 output reg [9:0] ry,
	 output reg [7:0] r2pixel);
	 
	 reg[5:0] upcount=0;
	 reg[5:0] downcount=0;
	 reg[5:0] leftcount=0;
	 reg[5:0] rightcount=0;
	 
	 reg Rpressed=0;
	 reg Rreleased=0;
	 reg Lpressed=0;
	 reg Lreleased=0;
	 reg Upressed=0;
	 reg Ureleased=0;
	 reg Dpressed=0;
	 reg Dreleased=0;
	 
	 integer offset=10;
	 integer multiplier=1;
	 
	 integer rxreg=300;
	 integer ryreg=300;
	 always@(posedge pixel_clk)begin
	  rx<=rxreg;
	  ry<=ryreg;
	if(reset)begin
		Rpressed<=0;
		Rreleased<=0;
		Lpressed<=0;
		Lreleased<=0;
		Upressed<=0;
		Ureleased<=0;
		Dpressed<=0;
		Dreleased<=0;
		rxreg<=600;
		ryreg<=600;
		leftcount<=0;
		rightcount<=0;
		upcount<=0;
		downcount<=0;
		end
		
	if(right==1)
   	Rpressed<=1;
	else if(right==0)
	   Rreleased<=1;
	if(left==1)
   	Lpressed<=1;
	else if(left==0)
	   Lreleased<=1;
	if(up==1)
   	Upressed<=1;
	else if(up==0)
	   Ureleased<=1;
	if(down==1)
   	Dpressed<=1;
	else if(down==0)
	   Dreleased<=1;	

	if(Lpressed==1 && Lreleased==1)begin
	 Lpressed<=0;
	 Lreleased<=0;
	 leftcount<=leftcount+1;
	 //rxreg<=100*leftcount;
	 end
	if(Rpressed==1 && Rreleased==1)begin
	 Rpressed<=0;
	 Rreleased<=0;
	 rightcount<=rightcount+1;
	 //ryreg<=100*rightcount;
	 end
	if(Upressed==1 && Ureleased==1)begin
	 Upressed<=0;
	 Ureleased<=0;
	 upcount<=upcount+1;
	 end
	 if(Dpressed==1 && Dreleased==1)begin
	 Dpressed<=0;
	 Dreleased<=0;
	 downcount<=downcount+1;
	 end
	 

	
	 if(leftcount==3||upcount==2)begin
	 //rxreg<=300+offset;
	 //ryreg<=500-offset;
	 rxreg<=900;
	 ryreg<=500;
	 upcount<=0;
	 downcount<=0;
	 leftcount<=0;
	 rightcount<=0;
	 offset<=offset*multiplier;
	 end
	 
	 else if(downcount==2||rightcount==3)begin
	 //rxreg<=700-offset;
	 //ryreg<=500+offset;
		rxreg<=200;
		ryreg<=100;
	 upcount<=0;
	 downcount<=0;
	 leftcount<=0;
	 rightcount<=0;
	 //offset<=offset*multiplier;
	 end
	 else if(upcount==1&&downcount==1&&leftcount==1&&rightcount==1)begin
	 rx<=100;
	 ry<=100;
	 upcount<=0;
	 downcount<=0;
	 leftcount<=0;
	 rightcount<=0;
	 end
	 else if(upcount+downcount+leftcount+rightcount>4)begin
	 rx<=1000;
	 ry<=500;
	 upcount<=0;
	 downcount<=0;
	 leftcount<=0;
	 rightcount<=0;
	 end


	if (offset>700)
	offset<=300;
	if (multiplier>5)
	multiplier<=1;
	if(rx>1000 ||ry>700 || rx<0 ||ry<0)begin
	rx<=500;
	ry<=300;
	end
	 end

	always @(hcount or vcount) begin
	

	if ((hcount >= rx && hcount < (rx+WIDTH)) &&
		(vcount >= ry && vcount < (ry+HEIGHT)))
		 r2pixel= COLOR;

	else r2pixel= 0;
	
	end
endmodule


//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
//\\//\\//\\//\\IMPLEMENTING RANDOM GENEREATOR//\\//\\//\\//\\//\\//\\//\\//
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

module rndm_gen (
	input clock,
	input reset,
	output reg [9:0] rnd 
);

	wire feedback;
	wire [9:0] lfsr_next;

	//An LFSR cannot have an all 0 state, thus reset to non-zero value
	reg [9:0] reset_value = 13;
	reg [9:0] lfsr;
	reg [3:0] count;
	reg rdy;

	always @ (posedge clock or posedge reset)
		begin
			if (reset) begin
				lfsr <= reset_value; 
				count <= 4'hF; 
				
				rnd <= 0;
				end
			else if(!rdy) begin
				lfsr <= lfsr_next;
				count <= count + 1;
				// a new random value is ready
				if (count == 4'd9) begin 
					count <= 0;
					rdy <= 1;
					rnd <= lfsr; //assign the lfsr number to output after 10 shifts
					end
				end
			end

	// X10+x7
	assign feedback = lfsr[9] ^ lfsr[6]; 
	assign lfsr_next = {lfsr[8:0], feedback};
	
endmodule

 
//////////////////////////////////////////////////////////////////
//						draw paddle
///////////////////////////////////////////////////////////////////

module draw_box
	#(parameter //default height 64pixels
	  COLOR=8'b111_111_111) //deault colour: red
	
	(input pixel_clk,
	input [10:0] hcount, x,
	input [9:0] vcount, y,
	input left,
	input right,
	input up,
	input down,
	input reset,
	output [9:0] paddle_height,
	output [9:0] paddle_width,
	output reg [7:0] pixel);
	
	 integer WIDTH=20;
	 integer HEIGHT=20;
	 reg [9:0] ADDWIDTH;
	 reg [9:0] ADDHEIGHT;
	 
	 reg Rpressed;
	 reg Rreleased;
	 reg Lpressed;
	 reg Lreleased;
	 reg Upressed;
	 reg Ureleased;
	 reg Dpressed;
	 reg Dreleased;
	 
	always @(negedge pixel_clk)begin
	
	if(reset)begin
		WIDTH<=20;
		HEIGHT<=20;
		Rpressed<=0;
		Rreleased<=0;
		Lpressed<=0;
		Lreleased<=0;
		Upressed<=0;
		Ureleased<=0;
		Dpressed<=0;
		Dreleased<=0;
		end
		
	if(right==1)
   	Rpressed<=1;
	else if(right==0)
	   Rreleased<=1;
	if(left==1)
   	Lpressed<=1;
	else if(left==0)
	   Lreleased<=1;
	if(up==1)
   	Upressed<=1;
	else if(up==0)
	   Ureleased<=1;
	if(down==1)
   	Dpressed<=1;
	else if(down==0)
	   Dreleased<=1;	
	

	if(left && Lpressed==1 && Lreleased==1)begin
	 WIDTH<=WIDTH+10;
	 HEIGHT<=HEIGHT+10;
	 Lpressed<=0;
	 Lreleased<=0;
	 end
	if(right && Rpressed==1 && Rreleased==1)begin
	 WIDTH<=WIDTH+10;
	 HEIGHT<=HEIGHT+10;
	 Rpressed<=0;
	 Rreleased<=0;
	 end
	if(up && Upressed==1 && Ureleased==1)begin
	 WIDTH<=WIDTH+10;
	 HEIGHT<=HEIGHT+10;
	 Upressed<=0;
	 Ureleased<=0;
	 end
	 if(down && Dpressed==1 && Dreleased==1)begin
	 WIDTH<=WIDTH+10;
	 HEIGHT<=HEIGHT+10;
	 Dpressed<=0;
	 Dreleased<=0;
	 end
	 end
	
	 
	always @(hcount or vcount) begin
	if ((hcount >= x && hcount < (x+WIDTH)) &&
	(vcount >= y && vcount < (y+HEIGHT)))
	pixel= COLOR;

else pixel= 0;
end
	
	assign paddle_height = HEIGHT;
	assign paddle_width = WIDTH;

endmodule
///////////////////////////////////////////////////////////////////

////////////////////move paddle////////////////////////////// INPUT2
module move_paddle 
		(input pixel_clk,
		input vsync_pulse,
		input up,
		input down,
		input left,
		input right,
		output reg [9:0] paddle_x,paddle_y,
		input reset,
		input stop);

	always @(posedge pixel_clk)begin
		if (reset) begin
			paddle_x <= 320;
			end
		else if (vsync_pulse && ~stop) begin
			if (down && paddle_x - 8 > 20) 
			paddle_x <= paddle_x - 8;
			else if (up && paddle_x + 8 < 1000) //else if (down && paddle_y + 4 < 648) 
			paddle_x <= paddle_x + 8;
			
			if (left && paddle_y - 8 > 20) 
			paddle_y <= paddle_y- 8;
			else if (right && paddle_y + 8 < 648) //else if (down && paddle_y + 4 < 648) 
			paddle_y <= paddle_y + 8;
		end
		end				


endmodule
///////////////////////////////////////////////////////////////////////


//////////////////////Draw round puck/////////////////////////////////////Input3
module round_piped
	#(COLOR=8'b111_000_00) //deault colour: red
	
	(input pixel_clk,
	 input ball_size,
	 input [10:0] hcount, rx,
	 input [9:0] vcount, ry,
	 output reg [7:0] rpixel);
	 
	parameter bs = 7'd64;
	parameter radius = bs/2;
	parameter radiusSquare = radius*radius;
	reg [10:0] changeX;
	reg [9:0] changeY;
	reg [20:0] changeXSquare;
	reg [18:0] changeYSquare;
	
	always @(hcount or vcount) begin
	
	if (hcount> (rx+radius))
		changeX=hcount-(rx+radius);
	else
		changeX=(rx+radius)-hcount;
	
	if (vcount > (ry+radius))
		changeY=vcount-(ry+radius);
	else
		changeY=(ry+radius)-vcount;
		
	changeXSquare=changeX * changeX;
	changeYSquare=changeY * changeY;
	
	if(changeXSquare+changeYSquare<=radiusSquare)
		rpixel <= COLOR;
	else
		rpixel <= 0;
		

	end
endmodule
////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Gim P. Hom 3/22/2007
// 
// Create Date:    17:51:37 03/11/2007 
// Design Name: 
// Module Name:    vga_general 
// Project Name: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_general(
    input pixel_clk, 
    output reg [10:0] hcount,
    output reg [9:0] vcount,
    output blank,
    output hblank,	 
    output  hsync, 
    output  vsync
);	 
/*   //reg  hblank=1;
	assign vclock = pixel_clk;
	
   // horizontal: 1344 pixels total
   // display 1024 pixels per line
   reg vblank;
   wire hsyncon,hsyncoff,hreset,hblankon;
   assign hblankon = (hcount == 1023);    
   assign hsyncon = (hcount == 1047);
   assign hsyncoff = (hcount == 1183);
   assign hreset = (hcount == 1343);

   // vertical: 806 lines total
   // display 768 lines
   wire vsyncon,vsyncoff,vreset,vblankon;
   assign vblankon = hreset & (vcount == 767);    
   assign vsyncon = hreset & (vcount == 776);
   assign vsyncoff = hreset & (vcount == 782);
   assign vreset = hreset & (vcount == 805);

   // sync and blanking
   wire next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always @(posedge vclock) begin
      hcount <= hreset ? 0 : hcount + 1;
      hblank <= next_hblank;
      hsync <= hsyncon ? 0 : hsyncoff ? 1 : hsync;  // active low

      vcount <= hreset ? (vreset ? 0 : vcount + 1) : vcount;
      vblank <= next_vblank;
      vsync <= vsyncon ? 0 : vsyncoff ? 1 : vsync;  // active low

      blank <= next_vblank | (next_hblank & ~hreset);
   end*/

	 wire vblank;
	 
 
	 // 1024 x 768 @ 60hz;  alternate resolution = 640x480 75hz
	 parameter hfp = 24;  //24;  // 16;  
	 parameter hsy = 136;  //136; // 96;
	 parameter hbp = 160;  //160; // 48;
	 
	 parameter vfp = 3;  //3;  //  11;
	 parameter vsy = 6;   //6;  //  2;
	 parameter vbp = 29;  //29; //  32;
	 
	 parameter hsize = 1023; //1023; //639;  // there are 640 pixels counting 0
	 parameter vsize = 767; //767; //479;  // similarly there are 480 lines counting line 0
	 
	 wire  h_end = (hcount == (hsize + hfp + hsy + hbp));
	 wire  v_end = (vcount == (vsize + vfp + vsy + vbp));
	 
	 assign hsync = ((hcount < hsize + hfp) || (hcount > hsize + hfp + hsy));
	 assign vsync = ((vcount < vsize + vfp) || (vcount > vsize + vfp + vsy));
	 
	 assign hblank = (hcount <= hsize);
	 assign vblank = (vcount <= vsize);
	 
	 assign blank = hblank && vblank;
	 
	 always @(posedge pixel_clk)
	    begin
		 hcount <= h_end ? 0 : hcount + 1;
		 vcount <= h_end ? (v_end ? 0 : vcount + 1) : vcount;  
		 end
		 
endmodule

// Switch Debounce Module
// use your system clock for the clock input
// to produce a synchronous, debounced output
module debounce #(parameter DELAY=400000)   // .01 sec with a 49Mhz clock
	        (input reset, clock, noisy,
	         output reg clean);

   reg [19:0] count;
   reg new;

   always @(posedge clock)
     if (reset)
       begin
	  count <= 0;
	  new <= noisy;
	  clean <= noisy;
       end
     else if (noisy != new)
       begin
	  new <= noisy;
	  count <= 0;
       end
     else if (count == DELAY)
       clean <= new;
     else
       count <= count+1;
      
endmodule

// Description:  Display 4 hex numbers on 7 segment display
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module display_4hex(
    input clk,                 // system clock
    input [15:0] data,         // 4 hex numbers, msb first
    output reg [6:0] seg,      // seven segment display output
    output reg [3:0] strobe    // digit strobe
    );

    localparam bits = 13;
     
    reg [bits:0] counter = 0;  // clear on power up
     
    wire [6:0] segments[15:0]; // 16 7 bit memorys
    assign segments[0]  = 7'b100_0000;
    assign segments[1]  = 7'b111_1001;
    assign segments[2]  = 7'b010_0100;
    assign segments[3]  = 7'b011_0000;
    assign segments[4]  = 7'b001_1001;
    assign segments[5]  = 7'b001_0010;
    assign segments[6]  = 7'b000_0010;
    assign segments[7]  = 7'b111_1000;
    assign segments[8]  = 7'b000_0000;
    assign segments[9]  = 7'b001_1000;
    assign segments[10] = 7'b000_1000;
    assign segments[11] = 7'b000_0011;
    assign segments[12] = 7'b010_0111;
    assign segments[13] = 7'b010_0001;
    assign segments[14] = 7'b000_0110;
    assign segments[15] = 7'b000_1110;
     
    always @(posedge clk) begin
      counter <= counter + 1;
      case (counter[bits:bits-1])
          2'b00: begin
                  seg <= segments[data[15:12]];
                  strobe <= 4'b0111;
                 end

          2'b01: begin
                  seg <= segments[data[11:8]];
                  strobe <= 4'b1011;
                 end

          2'b10: begin
                   seg <= segments[data[7:4]];
                   strobe <= 4'b1101;
                  end
          2'b11: begin
                  seg <= segments[data[3:0]];
                  strobe <= 4'b1110;
                 end
       endcase
      end

endmodule


//////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc 2011
// Engineer: Michelle Yu  
// Create Date:    08/26/2011
// Module Name:    dcm_all
// Project Name:     PmodPS2_Demo
// Target Devices: Nexys3 
// Tool version:     ISE 14.2
// Description: This file contains the design for a dcm that generates a 25MHz and a 
//                40MHz clock from a 100MHz clock.
//
// Revision: 
// Revision 0.01 - File Created
// Revision 1.00 - Converted from VHDL to Verilog (Josh Sackos)
// Revision 2.00 - removed CLK25, add parameters for divide/multiply
//////////////////////////////////////////////////////////////////////////////////////////

// =======================================================================================
//                                 Define Module
// =======================================================================================
module dcm_all_v2  #(parameter DCM_DIVIDE = 4,
                               DCM_MULTIPLY = 2)
     (
      CLK,
//    RST,
      CLKSYS,
      CLK25,
      CLK_out
);

// =======================================================================================
//                               Port Declarations
// =======================================================================================

         input   CLK;
//         input   RST;
         output  CLKSYS;
         output  CLK25;
         output  CLK_out;

// =======================================================================================
//                        Parameters, Registers, and Wires
// =======================================================================================   

         // Output registers
         wire CLKSYS;
         wire CLK25;
         wire CLK_out;

         // architecture of dcm_all entity
         wire    GND = 1'b0;
         wire    CLKSYSint;
         wire    CLKSYSbuf;
         
         assign CLKSYS = CLKSYSbuf;

// =======================================================================================
//                                 Implementation
// =======================================================================================   

         // buffer system clock and wire to dcm feedback
         BUFG BUFG_clksys(
                  .O(CLKSYSbuf),
                  .I(CLKSYSint)
         );

         // Instantiation of the DCM device primitive.
         // Feedback is not used.
         // Clock multiplier is 2
         // Clock divider is 5
         // 100MHz * 2/5 = 40MHz   
         // The following generics are only necessary if you wish to change the default behavior.
         DCM #(
                  .CLK_FEEDBACK("1X"),
                  .CLKDV_DIVIDE(4.0),                   //  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                                                        //             7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
                  .CLKFX_DIVIDE(DCM_DIVIDE),            //  Can be any interger from 2 to 32
                  .CLKFX_MULTIPLY(DCM_MULTIPLY),        //  Can be any integer from 2 to 32
                  .CLKIN_DIVIDE_BY_2("FALSE"),          //  TRUE/FALSE to enable CLKIN divide by two feature
                  .CLKIN_PERIOD(10000.0),               //  Specify period of input clock (ps)
                  .CLKOUT_PHASE_SHIFT("NONE"),          //  Specify phase shift of NONE, FIXED or VARIABLE
                  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), //  SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                                        //        an integer from 0 to 15
                  .DFS_FREQUENCY_MODE("LOW"),           //  HIGH or LOW frequency mode for frequency synthesis
                  .DLL_FREQUENCY_MODE("LOW"),           //  HIGH or LOW frequency mode for DLL
                  .DUTY_CYCLE_CORRECTION("TRUE"),       //  Duty cycle correction, TRUE or FALSE
                  .FACTORY_JF(16'hC080),                //  FACTORY JF Values
                  .PHASE_SHIFT(0),                      //  Amount of fixed phase shift from -255 to 255
                  .STARTUP_WAIT("FALSE")                //  Delay configuration DONE until DCM LOCK, TRUE/FALSE
         )
         DCM_inst(
                  .CLK0(CLKSYSint),                     // 0 degree DCM CLK ouptput
                  .CLK180(),                            // 180 degree DCM CLK output
                  .CLK270(),                            // 270 degree DCM CLK output
                  .CLK2X(),                             // 2X DCM CLK output
                  .CLK2X180(),                          // 2X, 180 degree DCM CLK out
                  .CLK90(),                             // 90 degree DCM CLK output
                  .CLKDV(CLK25), //(CLK25),                  // Divided DCM CLK out (CLKDV_DIVIDE)
                  .CLKFX(CLK_out),                      // DCM CLK synthesis out (M/D)
                  .CLKFX180(),                          // 180 degree CLK synthesis out
                  .LOCKED(),                            // DCM LOCK status output
                  .PSDONE(),                            // Dynamic phase adjust done output
                  .STATUS(),                            // 8-bit DCM status bits output
                  .CLKFB(CLKSYSbuf),                    // DCM clock feedback
                  .CLKIN(CLK),                          // Clock input (from IBUFG, BUFG or DCM)
                  .PSCLK(GND),                          // Dynamic phase adjust clock input
                  .PSEN(GND),                           // Dynamic phase adjust enable input
                  .PSINCDEC(GND),                       // Dynamic phase adjust increment/decrement
                  .DSSEN(1'b0),
                  .RST (1'b0)  //(RST)                  // DCM asynchronous reset input
         );
   
endmodule
