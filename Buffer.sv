`timescale 1ns/1ns
module Buffer #(parameter WIDTH = 8)(interface left, interface right);
  parameter FL = 2;
  parameter BL = 2;
  logic [WIDTH-1:0] data = 0;
  always
  begin
    left.Receive(data);
//$display("\t%m received");
	//$display("\t%m finished receive of data at time %d\n",$time);
    #FL; //Forward Latency: Delay from recieving inputs to send the results forward
	//$display("\t%m started to send data at time %d\n",$time);
    right.Send(data);
//$display("\t%m sent");
	//$display("\t%m finshed send of data at time %d\n",$time);
    #BL;//Backward Latency: Delay from the time data is delivered to the time next input can be accepted
  end
endmodule
