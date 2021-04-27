`timescale 1ns/100ps
import SystemVerilogCSP::*;

module PE_adder #(parameter DWIDTH = 8) (interface a, interface b, interface sum);

  parameter FL = 0;
  parameter BL = 0;
  logic [DWIDTH-1:0] add1;
  logic [DWIDTH-1:0] add2;
  logic [DWIDTH-1:0] res;

  always
  begin
	fork
		b.Receive(add1);
		a.Receive(add2);
	join
	#FL; //Forward Latency: Delay from recieving inputs to send the results forward
	
	res = add1 + add2;
	sum.Send(res);
    #BL;//Backward Latency: Delay from the time data is delivered to the time next input can be accepted
  end

endmodule

