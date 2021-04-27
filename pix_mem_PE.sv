`timescale 1ns/100ps
import SystemVerilogCSP::*;

module pix_mem_PE #(parameter DWIDTH = 8, parameter PWIDTH = 47, parameter PEnum = 0)
	(interface Pixel_Frame_In, interface Pixel_Single_Out);
parameter FL = 2;
parameter BL = 2;
logic [DWIDTH*5 - 1 : 0] pixel_frame;
logic [DWIDTH-1:0] single_pixel [4:0];
parameter NUM_SENDS = 3;
integer i,j;
logic first_usage = 1;

always begin
    Pixel_Frame_In.Receive(pixel_frame);
$display("\t%m received pixels");
    single_pixel[4] = pixel_frame[DWIDTH*5 - 1 : DWIDTH*4];
    single_pixel[3] = pixel_frame[DWIDTH*4 - 1 : DWIDTH*3];
    single_pixel[2] = pixel_frame[DWIDTH*3 - 1 : DWIDTH*2];
    single_pixel[1] = pixel_frame[DWIDTH*2 - 1 : DWIDTH*1];
    single_pixel[0] = pixel_frame[DWIDTH*1 - 1 : DWIDTH*0];

	if (first_usage == 0) begin // first time each PE uses pixelrow a specific # of times
		first_usage = 1; // always use else branch after this
		for (j = 0; j <= PEnum; j = j + 1) begin
			for (i = 0; i < NUM_SENDS; i = i + 1) begin
				#FL;
				Pixel_Single_Out.Send(single_pixel[4-i]); // 4, then 3, then 2
				#BL; #FL;
				Pixel_Single_Out.Send(single_pixel[3-i]); // 3, then 2, then 1
				#BL; #FL;
				Pixel_Single_Out.Send(single_pixel[2-i]); // 2, then 1, then 0
				#BL;
			end // for I
		end // for J
	end else begin // all other times, the PE uses each pixelrow 3 times (== height of CONV filter)
		for (j = 0; j <= 3; j = j + 1) begin
			for (i = 0; i < NUM_SENDS; i = i + 1) begin
				#FL;
				Pixel_Single_Out.Send(single_pixel[4-i]); // 4, then 3, then 2
				#BL; #FL;
				Pixel_Single_Out.Send(single_pixel[3-i]); // 3, then 2, then 1
				#BL; #FL;
				Pixel_Single_Out.Send(single_pixel[2-i]); // 2, then 1, then 0
				#BL;
			end // for I
		end // for J
	end
	
	
$display("\t%m completed individual sends, pixel frame ready to be discarded");
end //always
endmodule


