`timescale 1ns/100ps
import SystemVerilogCSP::*;

module Psum_Adder_Safe_Wrapper #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface DPkt_In, interface Pkt_Out);
  parameter PixelWIDTH = 40;
  parameter FilterWIDTH = 24;
  logic [PWIDTH-1:0] packet;
  logic [PixelWIDTH-1:0] pix;
  logic [FilterWIDTH-1:0] filt;

  //Interface Vector instatiation: 4-phase bundled data channel
  Channel #(.hsProtocol(P4PhaseBD)) intf  [6:0] (); 

  DP_Adder_Safe #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH)) depacketizer_safe(.In(DPkt_In), .Out0(intf[0]), .Out1(intf[1]), .Out2(intf[2]));
  Queue #(.DWIDTH(DWIDTH)) queuePE0 (.Left(intf[0]), .Right(intf[3]));
  Queue #(.DWIDTH(DWIDTH)) queuePE1 (.Left(intf[1]), .Right(intf[4]));
  Queue #(.DWIDTH(DWIDTH)) queuePE2 (.Left(intf[2]), .Right(intf[5]));
  Psum_Adder_Safe #(.DWIDTH(DWIDTH)) safe_adder (.In0(intf[3]), .In1(intf[4]), .In2(intf[5]), .Out(intf[6]));
  P_adder #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH)) packetizer_A (.In(intf[6]), .Out(Pkt_Out));

endmodule
