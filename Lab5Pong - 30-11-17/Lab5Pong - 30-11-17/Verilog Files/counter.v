module powerup_timer(
	input wire clk,
	input wire reset,
	input wire eaten,
	input wire [1:0] mode,
	output wire [3:0] pp_status
	);
	
	parameter PP1_TIME = 3;
	parameter PP2_TIME = 2;
	parameter PP3_TIME = 5;
	parameter PP4_TIME = 4;
	
	reg [3:0] load;
	
	counter powerup_1(.clk(clk),
							.load(load[0]), //rmb to add load value
							.reset(reset),
							.clear(0),
							.value(PP1_TIME),
							.expired(pp1_expired));
							
	counter powerup_2(.clk(clk),
							.load(load[1]), //rmb to add load value
							.reset(reset),
							.clear(0),
							.value(PP2_TIME),
							.expired(pp2_expired));
							
	counter powerup_3(.clk(clk),
							.load(load[2]), //rmb to add load value
							.reset(reset),
							.clear(0),
							.value(PP3_TIME),
							.expired(pp3_expired));
							
	counter powerup_4(.clk(clk),
							.load(load[3]), //rmb to add load value
							.reset(reset),
							.clear(0),
							.value(PP4_TIME),
							.expired(pp4_expired));
	
	
	always @(posedge clk)
		begin
			if(eaten) begin
				case(mode)
					2'b00:
						load <= 4'b0001;
					2'b01:
						load <= 4'b0010;
					2'b10:
						load <= 4'b0100;
					2'b11:
						load <= 4'b1000;
					endcase
				end
			else
				load <= 4'b0000;
			end
	
	assign pp_status = reset? 4'b0000 : {!pp4_expired, !pp3_expired, !pp2_expired, !pp1_expired};
	
endmodule

module pp_timer(
	input wire			clk,
	input wire			eaten,
	output wire			spawn,
	output wire			expired,
	output wire			started_op
	);
	
	reg started;
	reg load_reg;
	reg spawn_reg;
	wire load;
	
	always @(posedge clk)
		begin
			if(!started)
				spawn_reg <= 0;
				if(eaten) begin
					started <= 1;
					load_reg <= 1;
					end
			if(started) begin
				load_reg <= 0;
				if(expired) begin
					spawn_reg <= 1;
					started <= 0;
					end
				else
					spawn_reg <= 0;
				end
			end
			
	assign load = load_reg;
	assign spawn = spawn_reg;
	assign started_op = started;
	
	counter mycounter(.clk(clk),
							.load(load),
							.reset(),
							.clear(0),
							.value(1),
							.expired(expired));
	
endmodule

module counter(
	input wire			clk,
	input wire			load,
	input wire			reset,
	input wire 			clear,
	input wire [3:0]	value,
	output wire			expired
	);
	
	reg[25:0] sec_count;
	reg old_expired;
	reg [3:0] count;
	reg stop;
	
	parameter PRESCALER = 64999999;
	
	wire increment;
	
	always @(posedge clk)
		begin
			if(reset) begin
				stop <= 1;
				end
			if(load || clear) begin
				sec_count <= 0;
				stop <= 0;
				end
			else
				sec_count <= (sec_count == PRESCALER)? 0 : sec_count + 1;
				
			count <= clear ? 0 : load ? (4'hF-value) : increment ? count+1 : count;
			old_expired <= expired;
			if(count == 15)
				stop <= 1;
			end
			
		assign one_hz = (sec_count == PRESCALER);
		assign increment = one_hz && !(count == 15);
		assign expired = ((count == 15) && !load) || stop;
		
endmodule


module game_timer(
	input wire 			clk,
	input wire			reset,
	output reg [31:0] seconds
	);	
	
	wire 			increment, one_hz;
	reg [25:0]	sec_count;
	
	parameter PRESCALER = 24999999;
	
	always @(posedge clk)
		begin
			if(reset) begin
				seconds <= 0;
				sec_count <= 0;
				end
			else begin
				sec_count <= one_hz? 0 : sec_count + 1;
				end
			seconds <= one_hz? seconds + 1 : seconds;
			end
				
	assign one_hz = (sec_count == PRESCALER);
				
endmodule
