module randgen(
	input clk,
	output reg [7:0] LFSR = 255
	);

	wire feedback = LFSR[7];

	always @(posedge clk)
		begin
			LFSR[0] <= feedback;
			LFSR[1] <= LFSR[0];
			LFSR[2] <= LFSR[1] ^ feedback;
			LFSR[3] <= LFSR[2] ^ feedback;
			LFSR[4] <= LFSR[3] ^ feedback;
			LFSR[5] <= LFSR[4];
			LFSR[6] <= LFSR[5];
			LFSR[7] <= LFSR[6];
			end
endmodule


module randgen_10bit(
	input clk,
	output reg [9:0] LFSR = 255
	);

	wire feedback = LFSR[7];

	always @(posedge clk)
		begin
			LFSR[0] <= feedback;
			LFSR[1] <= LFSR[0];
			LFSR[2] <= LFSR[1];
			LFSR[3] <= LFSR[2] ^ feedback;
			LFSR[4] <= LFSR[3];
			LFSR[5] <= LFSR[4];
			LFSR[6] <= LFSR[5] ^ feedback;
			LFSR[7] <= LFSR[6];
			LFSR[8] <= LFSR[7] ^ feedback;
			LFSR[9] <= LFSR[8] ^ feedback;
			end
endmodule