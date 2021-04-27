`timescale 1ns/100ps
import SystemVerilogCSP::*;

module multiplier #(parameter DWIDTH = 8) (interface facA, interface facB, interface prod);

  parameter FL = 2;
  parameter BL = 2;
  logic [DWIDTH-1:0] factor1;
  logic [DWIDTH-1:0] factor2;
  logic [DWIDTH-1:0] product;

  always
  begin
	fork
		facA.Receive(factor1);
		facB.Receive(factor2);
	join
	//$display("\t%m completed receives");
	#FL; //Forward Latency: Delay from recieving inputs to send the results forward
	
	product = factor1 * factor2;
	prod.Send(product);
    #BL;//Backward Latency: Delay from the time data is delivered to the time next input can be accepted
  end

endmodule


