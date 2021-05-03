`timescale 1ns/100ps
import SystemVerilogCSP::*;
// Special Packetizer for the Adder
module P_adder #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface In, interface Out);
  parameter FL = 2;
  parameter BL = 2;
  logic [PWIDTH-1:0] packet;
  logic [DWIDTH-1:0] Psum;
  integer counter = 1;
  always
  begin
	In.Receive(Psum);
	#FL;
//		ifm/filt, dest. add = mem, sour. add. = safe adder, data (upper 32b = x) 
	packet = {1'b1,      3'b110,              3'b100, 	     32'hFFFF , Psum};
$display("\tFinal Output %d Packetizer passing result = %d", counter, packet[DWIDTH-1:0]);
	Out.Send(packet);
	#BL;
	counter = counter + 1;
  end

endmodule


