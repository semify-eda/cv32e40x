module uart (
	clk,
	resetn,
	ser_tx,
	ser_rx,
	reg_div_we,
	reg_div_di,
	reg_div_do,
	reg_dat_we,
	reg_dat_re,
	reg_dat_di,
	reg_dat_do,
	reg_dat_wait
);
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:20:25
	parameter integer DEFAULT_DIV = 608;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:21:2
	input clk;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:22:2
	input resetn;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:24:2
	output wire ser_tx;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:25:2
	input ser_rx;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:27:2
	input [3:0] reg_div_we;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:28:2
	input [31:0] reg_div_di;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:29:2
	output wire [31:0] reg_div_do;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:31:2
	input reg_dat_we;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:32:2
	input reg_dat_re;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:33:2
	input [31:0] reg_dat_di;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:34:2
	output wire [31:0] reg_dat_do;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:35:2
	output wire reg_dat_wait;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:37:2
	reg [31:0] cfg_divider;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:39:2
	reg [3:0] recv_state;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:40:2
	reg [31:0] recv_divcnt;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:41:2
	reg [7:0] recv_pattern;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:42:2
	reg [7:0] recv_buf_data;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:43:2
	reg recv_buf_valid;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:45:2
	reg [9:0] send_pattern;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:46:2
	reg [3:0] send_bitcnt;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:47:2
	reg [31:0] send_divcnt;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:48:2
	reg send_dummy;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:50:2
	assign reg_div_do = cfg_divider;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:52:2
	assign reg_dat_wait = send_bitcnt || send_dummy;
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:53:2
	assign reg_dat_do = (recv_buf_valid ? recv_buf_data : ~0);
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:55:2
	always @(posedge clk)
		// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:56:3
		if (!resetn)
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:57:4
			cfg_divider <= DEFAULT_DIV;
		else begin
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:59:4
			if (reg_div_we[0])
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:59:23
				cfg_divider[7:0] <= reg_div_di[7:0];
			if (reg_div_we[1])
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:60:23
				cfg_divider[15:8] <= reg_div_di[15:8];
			if (reg_div_we[2])
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:61:23
				cfg_divider[23:16] <= reg_div_di[23:16];
			if (reg_div_we[3])
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:62:23
				cfg_divider[31:24] <= reg_div_di[31:24];
		end
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:66:2
	always @(posedge clk)
		// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:67:3
		if (!resetn) begin
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:68:4
			recv_state <= 0;
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:69:4
			recv_divcnt <= 0;
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:70:4
			recv_pattern <= 0;
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:71:4
			recv_buf_data <= 0;
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:72:4
			recv_buf_valid <= 0;
		end
		else begin
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:74:4
			recv_divcnt <= recv_divcnt + 1;
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:75:4
			if (reg_dat_re)
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:76:5
				recv_buf_valid <= 0;
			case (recv_state)
				0: begin
					// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:79:6
					if (!ser_rx)
						// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:80:7
						recv_state <= 1;
					// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:81:6
					recv_divcnt <= 0;
				end
				1:
					// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:84:6
					if ((2 * recv_divcnt) > cfg_divider) begin
						// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:85:7
						recv_state <= 2;
						// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:86:7
						recv_divcnt <= 0;
					end
				10:
					// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:90:6
					if (recv_divcnt > cfg_divider) begin
						// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:91:7
						recv_buf_data <= recv_pattern;
						// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:92:7
						recv_buf_valid <= 1;
						// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:93:7
						recv_state <= 0;
					end
				default:
					// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:97:6
					if (recv_divcnt > cfg_divider) begin
						// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:98:7
						recv_pattern <= {ser_rx, recv_pattern[7:1]};
						// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:99:7
						recv_state <= recv_state + 1;
						// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:100:7
						recv_divcnt <= 0;
					end
			endcase
		end
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:107:2
	assign ser_tx = send_pattern[0];
	// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:109:2
	always @(posedge clk) begin
		// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:110:3
		if (reg_div_we)
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:111:4
			send_dummy <= 1;
		// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:112:3
		send_divcnt <= send_divcnt + 1;
		if (!resetn) begin
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:114:4
			send_pattern <= ~0;
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:115:4
			send_bitcnt <= 0;
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:116:4
			send_divcnt <= 0;
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:117:4
			send_dummy <= 1;
		end
		else
			// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:119:4
			if (send_dummy && !send_bitcnt) begin
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:120:5
				send_pattern <= ~0;
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:121:5
				send_bitcnt <= 15;
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:122:5
				send_divcnt <= 0;
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:123:5
				send_dummy <= 0;
			end
			else if (reg_dat_we && !send_bitcnt) begin
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:126:5
				send_pattern <= {1'b1, reg_dat_di[7:0], 1'b0};
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:127:5
				send_bitcnt <= 10;
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:128:5
				send_divcnt <= 0;
			end
			else if ((send_divcnt > cfg_divider) && send_bitcnt) begin
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:131:5
				send_pattern <= {1'b1, send_pattern[9:1]};
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:132:5
				send_bitcnt <= send_bitcnt - 1;
				// Trace: /home/mario/uni/sem10/bachelorarbeit/gitclone/semify_brle/core-v-verif/core-v-cores/cv32e40x/rtl/uart/uart.sv:133:5
				send_divcnt <= 0;
			end
	end
endmodule
