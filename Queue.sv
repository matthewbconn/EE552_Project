`timescale 1ns/100ps
import SystemVerilogCSP::*;

module Queue #(parameter DWIDTH = 8)(interface Left, interface Right);
  parameter FL = 2;
  parameter BL = 2;
  logic [DWIDTH-1:0] data = 0;

  Channel #(.hsProtocol(P4PhaseBD), .WIDTH(DWIDTH)) intf  [8:1] (); 

  Buffer #(.WIDTH(DWIDTH)) Queue_Entry( .left(Left), .right(intf[1]));
  Buffer #(.WIDTH(DWIDTH)) Queue_Stage2( .left(intf[1]), .right(intf[2]));
  Buffer #(.WIDTH(DWIDTH)) Queue_Stage3( .left(intf[2]), .right(intf[3]));
  Buffer #(.WIDTH(DWIDTH)) Queue_Stage4( .left(intf[3]), .right(intf[4]));
  Buffer #(.WIDTH(DWIDTH)) Queue_Stage5( .left(intf[4]), .right(intf[5]));
  Buffer #(.WIDTH(DWIDTH)) Queue_Stage6( .left(intf[5]), .right(intf[6]));
  Buffer #(.WIDTH(DWIDTH)) Queue_Stage7( .left(intf[6]), .right(intf[7]));
  Buffer #(.WIDTH(DWIDTH)) Queue_Stage8( .left(intf[7]), .right(intf[8]));
  Buffer #(.WIDTH(DWIDTH)) Queue_Exit( .left(intf[8]), .right(Right));

endmodule
