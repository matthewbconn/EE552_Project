`timescale 1ns/100ps
import SystemVerilogCSP::*;

module Psum_Adder_Wrapper #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface DPkt_In, interface Pkt_Out);
  parameter PixelWIDTH = 40;
  parameter FilterWIDTH = 24;
  logic [PWIDTH-1:0] packet;
  logic [PixelWIDTH-1:0] pix;
  logic [FilterWIDTH-1:0] filt;

  //Interface Vector instatiation: 4-phase bundled data channel
  Channel #(.hsProtocol(P4PhaseBD)) intf  [2:1] (); 

  DP_adder #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH)) depacketizer_A (.In(DPkt_In), .Out(intf[1]));
  Psum_Adder #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH))  psum_adder_node (.In(intf[1]), .Out(intf[2]));
  P_adder #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH)) packetizer_A (.In(intf[2]), .Out(Pkt_Out));

endmodule
