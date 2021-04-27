`timescale 1ns/100ps
import SystemVerilogCSP::*;
// Special Packetizer for the Adder
module P_adder #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface In, interface Out);
  parameter FL = 2;
  parameter BL = 2;
  logic [PWIDTH-1:0] packet;
  logic [DWIDTH-1:0] Psum;
  
  always
  begin
	In.Receive(Psum);
	#FL;
//		ifm/filt, dest. add, sour. add., data (upper 32b = x) 
	packet = {1'b1,   3'b110,   3'b100,    32'hFFFF , Psum};
//	$display("Packetizer passing result = %d", Psum);
	Out.Send(packet);
	#BL;
  end

endmodule


