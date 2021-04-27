`timescale 1ns/100ps
import SystemVerilogCSP::*;

module Psum_Adder_Safe #(parameter DWIDTH = 8) (interface In0, interface In1, interface In2, interface Out);
  parameter FL = 4; // bc two additions
  parameter BL = 2;
  logic [DWIDTH-1:0] Psum [2:0];
  logic [DWIDTH-1:0] SUM;
  integer j = 1;
  
  always
  begin
	fork
		In0.Receive(Psum[0]);
		In1.Receive(Psum[1]);
		In2.Receive(Psum[2]);
	join
	SUM = Psum[2] + Psum[1] + Psum[0];
	#FL;
//$display("%m preparing to send an output value @ %d", $time);
	Out.Send(SUM);
$display("%m received %d th psums: %d + %d + %d = %d @ %d", j, Psum[0], Psum[1], Psum[2], SUM, $realtime);
//$display("%m completed send of an output value @ %d", $time);
	#BL;
	j = j + 1;
  end

endmodule


