`timescale 1ns/100ps
import SystemVerilogCSP::*;

module accumulator #(parameter WIDTH = 8) (interface next, interface sum);
  parameter FL = 0;
  parameter BL = 0;
  logic [WIDTH-1:0] current_sum = 0;
  
  always
  begin
	// reset the accumulator	
	current_sum = 0;
	#FL;
	sum.Send(current_sum);
	#BL;

	// first accumulation
	next.Receive(current_sum);
	#FL;
	sum.Send(current_sum);
	#BL;

	// second accumulation
	next.Receive(current_sum);
	#FL;
	sum.Send(current_sum);
	#BL;
  end

endmodule


