`timescale 1ns/100ps
import SystemVerilogCSP::*;

module Psum_Adder #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface In, interface Out);
  parameter FL = 3;
  parameter BL = 2;
  logic [DWIDTH-1:0] Psum [2:0];
  logic [DWIDTH-1:0] SUM;
  
  always
  begin
	In.Receive(Psum[2]);
	In.Receive(Psum[1]);
	SUM = Psum[2] + Psum[1];
	In.Receive(Psum[0]);
	SUM = Psum[0] + SUM;
	#FL;
	Out.Send(SUM);
	#BL;
  end

endmodule


