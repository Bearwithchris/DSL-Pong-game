module pp_timer(
	input wire			clk,
	input wire			eaten,
	output wire			spawn
	);
	
	reg started;
	reg load_reg;
	reg spawn_reg;
	wire load, expired;
	
	always @(posedge clk)
		begin
			if(!started)
				spawn_reg <= 0;
				if(eaten) begin
					started <= 1;
					load_reg <= 1;
					end
			else if(started) begin
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
	
	counter mycounter(.clk(clk),
							.load(load),
							.clear(0),
							.value(3),
							.expired(expired));
	
endmodule

module counter(
	input wire			clk,
	input wire			load,
	input wire 			clear,
	input wire [3:0]	value,
	output wire			expired
	);
	
	reg[25:0] sec_count;
	reg old_expired;
	reg [3:0] count;
	
	parameter PRESCALER = 24999999;
	
	wire increment;
	
	always @(posedge clk)
		begin
			if(load || clear)
				sec_count <= 0;
			else
				sec_count <= (sec_count == PRESCALER)? 0 : sec_count + 1;
				
			count <= clear ? 0 : load ? (4'hF-value) : increment ? count+1 : count;
			old_expired <= expired;
			end
			
		assign one_hz = (sec_count == PRESCALER);
		assign increment = one_hz && !(count == 15);
		assign expired = ((count == 15) && !load);
		
endmodule
