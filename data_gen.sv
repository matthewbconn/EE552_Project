//Sample data_generator module
`timescale 1ns/1ns
module data_gen #(parameter WIDTH = 8) (interface r);
  parameter FL = 0; //ideal environment
  logic [WIDTH-1:0] SendValue=0;
  always
  begin 
    SendValue = $random() % 16;//(2**(WIDTH-1));
    #FL;
    r.Send(SendValue);
  end
endmodule
