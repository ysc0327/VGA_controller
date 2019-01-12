`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:47:13 01/10/2019 
// Design Name: 
// Module Name:    VGA_CTRL 
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
`define HA 640
`define HF 16
`define HS 96
`define HB 48
`define HT 800

`define VA 480
`define VF 10
`define VS 2
`define VB 33
`define VT 525

`define PIC_H 280
`define PIC_V 210

module VGA_CTRL(
	input CLOCK_50,
	input [3:0] KEY,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output reg VGA_VS,
	output reg VGA_HS,
	output VGA_SYNC_N,
	output VGA_BLANK_N,
	output VGA_CLK
	//output reg [15:0] ADR
);
reg [15:0] ADR;
reg [9:0] hori_cnt;
reg [9:0] verti_cnt;

reg clk25;
always @(posedge CLOCK_50)
	begin
		if(!KEY[0])
			clk25 <= 0;
		else
			clk25 <= ~clk25;
	end


always @(posedge clk25)
	begin
		if(!KEY[0])
			hori_cnt <= 0;
		else if(hori_cnt < `HT - 1)
			hori_cnt <= hori_cnt + 1;
		else
			hori_cnt <= 0;
	end

always @(posedge clk25)
	begin
		if(!KEY[0])
			verti_cnt <= 0;
		else if( hori_cnt == `HT -1)
				 if(verti_cnt < `VT - 1)
					verti_cnt <= verti_cnt + 1;
				  else
					verti_cnt <= 0;
	end
	
always @(posedge clk25)
	begin
		if(!KEY[0])
			VGA_HS <= 1;
		else if(hori_cnt >= (`HA + `HF - 1) && hori_cnt < (`HA + `HF + `HS - 1))
			VGA_HS <= 0;
		else
			VGA_HS <= 1;
	end
 
always @(posedge clk25)
	begin
		if(!KEY[0])
			VGA_VS <= 1;
		else if(verti_cnt >= (`VA + `VF - 1) && verti_cnt < (`VA + `VF + `VS - 1))
			VGA_VS <= 0;
		else
			VGA_VS <= 1;
	end
	
assign VGA_BLANK_N = ( hori_cnt < `PIC_H ) && ( verti_cnt < `PIC_V ) && (KEY[0]) ;
assign VGA_SYNC_N = 1;
assign VGA_CLK = clk25;

//ADR
reg[15:0] ADR_R;
always @(posedge clk25)
	begin
		if(!KEY[0])
			ADR_R <= 0 ;
		else if(hori_cnt == 0 && verti_cnt == 0)
			ADR_R <= 2;
		else if(VGA_BLANK_N)
			ADR_R <= ADR + 1;
	end

always @(*) begin
	if(!KEY[0])
		ADR = 0;
	else if(hori_cnt == 0 && verti_cnt == 0)
		ADR = 1;
	else if(!VGA_BLANK_N)
		ADR = ADR_R - 1;
	else if(ADR == (`PIC_H * `PIC_V - 1))
		ADR = 0;
	else
		ADR = ADR_R;
end

wire [23:0] pixel;

//assign {VGA_R,VGA_G,VGA_B} = (VGA_BLANK_N) ? 24'h30 : 24'h0; 
assign {VGA_R,VGA_G,VGA_B} = (VGA_BLANK_N) ? pixel : 24'h0; 

//using ALTERA DE2-115 IP-ROM (output non flip-flop)
rom3   inst1 (.address(ADR), .clock(clk25), .q(pixel));


endmodule
