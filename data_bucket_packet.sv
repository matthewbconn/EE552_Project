//Sample data_generator module
`timescale 1ns/1ns
import SystemVerilogCSP::*;

module data_bucket_packet #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface r);
  parameter BL = 0; //ideal environment
  logic [PWIDTH-1:0] packet=0;
  logic [DWIDTH-1:0] single_data;
  integer counter = 1;

  always
  begin 
    r.Receive(packet);
    single_data = packet[DWIDTH-1:0];
$display("%m RECEIVED PACKET from parent merge at %d", $realtime);
//    $display("Received data # %d = %d", counter, single_data);
    #BL;
    counter = counter + 1;
  end
endmodule