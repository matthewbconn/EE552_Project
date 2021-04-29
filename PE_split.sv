`timescale 1ns/100ps
import SystemVerilogCSP::*;

module PE_split #(parameter DWIDTH = 8) (interface In, interface ACC_OUT, interface PKT_OUT);

  parameter FL = 2;
  parameter BL = 2;
  logic [DWIDTH-1:0] data;

  always
  begin
	// Do first accumulation
	In.Receive(data);
	#FL;
	ACC_OUT.Send(data);
	#BL;

	// Do second accumulation
	In.Receive(data);
	#FL;
	ACC_OUT.Send(data);
	#BL;

	// Pass out the PSum to be packetized
	In.Receive(data);
	#FL;
//$display("%m has a psum available, sending now...t = %d",$time);
	PKT_OUT.Send(data);
//$display("%m completed send of psum...t = %d",$time);
	#BL;
  end

endmodule

