`timescale 1ns/100ps
import SystemVerilogCSP::*;

module DP_PE #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface In, interface Pixel_Out, interface Filter_out);
  parameter FL = 1;
  parameter BL = 1;
  parameter PixelWIDTH = 40;
  parameter FilterWIDTH = 24;
  logic [PWIDTH-1:0] packet = 0;
  logic [DWIDTH-1:0] Psum;
  logic [PixelWIDTH-1:0] pix;
  logic [FilterWIDTH-1:0] filt;
  
  always
  begin
	In.Receive(packet);
	//$display("\tPacket received: %b",packet);
	$display("\t%m received ifm(1)/filt(0): %b from source %b...time is %d", packet[PWIDTH-1],packet[42:40],$time);
	#FL;
// TO DO add conditional send to pixel mem or filt mem
	if (packet[PWIDTH-1] == 1'b1) begin // packet contains pixels (need 40 bits)
		pix = packet[5*DWIDTH-1:0];
		$display("\t\t%m (addr %b) received pixels [%d, %d, %d %d %d] from addr %b.  , time: %d", packet[45:43],  packet[39:32], packet[31:24], packet[23:16], packet[15:8], packet[7:0], packet[42:40], $realtime);
		Pixel_Out.Send(pix);
	end else begin // packet contains filters (need 24 bits)
		$display("\t\t%m (addr %b) received filters [%d, %d, %d] from addr %b.  , time: %d", packet[45:43],  packet[23:16], packet[15:8], packet[7:0], packet[42:40], $realtime);
		filt = packet[3*DWIDTH-1:0];
//		$display("\tDePacketizer passing filter data");
		Filter_out.Send(filt);
	end
	#BL;
  end

endmodule
