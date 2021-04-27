`timescale 1ns/1ns
module data_bucket #(parameter WIDTH = 8) (interface r);
  parameter BL = 0; //ideal environment
  logic [WIDTH-1:0] ReceiveValue = 0;
  
  always
  begin
    r.Receive(ReceiveValue);
    $display("\t%m finshed receive of data = %d , at time = %dns\n",ReceiveValue,$time);
    #BL;
  end

endmodule

