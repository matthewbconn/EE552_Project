`timescale 1ns/100ps
import SystemVerilogCSP::*;

module PE_Wrapper #(parameter DWIDTH = 8, parameter PWIDTH = 47,  parameter PE_Index = 0) (interface DPkt_In, interface Pkt_Out);
  parameter PixelRowWIDTH = 5*DWIDTH;
  parameter FilterWIDTH = 3*DWIDTH;
  logic [PWIDTH-1:0] packet;
  logic [PixelRowWIDTH-1:0] pix;
  logic [FilterWIDTH-1:0] filt;

  //Interface Vector instatiation: 4-phase bundled data channel
  Channel #(.hsProtocol(P4PhaseBD), .WIDTH(PWIDTH)) intf  [12:1] (); 

  DP_PE #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH)) depacketizer ( .In(DPkt_In), .Pixel_Out(intf[3]), .Filter_out(intf[1]));

  Buffer #(.WIDTH(FilterWIDTH))Filter_Buffer( .left(intf[1]), .right(intf[2]));
  filt_mem_PE #(.DWIDTH(DWIDTH),.PWIDTH(PWIDTH)) Filter_Memory ( .Filter_Frame_In(intf[2]), .Filter_Frame_Out(intf[5]), .Filter_Single_Out(intf[6]));

  Buffer #(.WIDTH(PixelRowWIDTH)) Pixels_Buffer( .left(intf[3]), .right(intf[4]));
  pix_mem_PE #( .DWIDTH(DWIDTH),  .PWIDTH(PWIDTH), .PEnum(PE_Index)) Pixel_Memory	( .Pixel_Frame_In(intf[4]), .Pixel_Single_Out(intf[7]));

  multiplier #( .DWIDTH(DWIDTH)) my_mult ( .facA(intf[6]), .facB(intf[7]), .prod(intf[8]));
  PE_adder #( .DWIDTH(DWIDTH)) add_block ( .a(intf[8]), .b(intf[11]), .sum(intf[9]));
  accumulator #( .WIDTH(DWIDTH)) my_acc ( .next(intf[10]), .sum(intf[11]));
  PE_split #( .DWIDTH(DWIDTH)) split_element ( .In(intf[9]), .ACC_OUT(intf[10]), .PKT_OUT(intf[12]));

  P_PE #( .DWIDTH(DWIDTH), .PWIDTH(PWIDTH), .PE_Index(PE_Index))
		Packetizer ( .PSum_In(intf[12]), .Filter_In(intf[5]), .Out(Pkt_Out));







endmodule
