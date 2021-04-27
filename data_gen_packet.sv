//Sample data_generator module
`timescale 1ns/1ns
import SystemVerilogCSP::*;


module data_gen_packet #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface r);
  parameter FL = 0; //ideal environment
  logic [DWIDTH*5 - 1 : 0] data_portion = 0;
  logic [PWIDTH-1: DWIDTH*5] upper_portion;
  logic [PWIDTH-1:0] packet=0;
  logic [DWIDTH-1:0] single_data;
  integer counter = 1;

  always
  begin 
    data_portion = $urandom();
    upper_portion = $urandom();
    single_data = data_portion[DWIDTH-1:0];
    packet = {upper_portion, data_portion};
    $display("Sent data # %d = %d to child-2", counter, single_data);
    #FL;
    r.Send(packet);
    counter = counter + 1;
  end
endmodule
