`timescale 1ns/100ps
import SystemVerilogCSP::*;
// special depacketizer for Psum adder
module DP_adder #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface In, interface Out);
  parameter FL = 1;
  parameter BL = 1;
  logic [PWIDTH-1:0] packet;
  logic [DWIDTH-1:0] Psum;
  
  always
  begin
	In.Receive(packet);
	#FL;
	Psum = packet[DWIDTH-1:0];
	Out.Send(Psum);
	$display("DePacketizer passing data = %d", Psum);
	#BL;
  end

endmodule


