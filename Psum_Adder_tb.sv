`timescale 1ns/100ps
import SystemVerilogCSP::*;

module Psum_Adder_tb #(parameter DWIDTH = 8, parameter PWIDTH = 47);// (interface In, interface Pixel_Out, interface Filter_out);
  parameter PixelWIDTH = 40;
  parameter FilterWIDTH = 24;
  logic [PWIDTH-1:0] packet;
  logic [PixelWIDTH-1:0] pix;
  logic [FilterWIDTH-1:0] filt;

  //Interface Vector instatiation: 4-phase bundled data channel
  Channel #(.hsProtocol(P4PhaseBD)) intf  [1:0] (); 

  Psum_gen #(.DWIDTH(8), .PWIDTH(47)) dgen_A (.r(intf[0]));
  Psum_Adder_Wrapper #(.DWIDTH(8), .PWIDTH(47)) Adder_Block (.DPkt_In(intf[0]), .Pkt_Out(intf[1]));
  Psum_bucket #(.DWIDTH(8), .PWIDTH(47)) dbucket_A (.r(intf[1]));

  initial
	#50 $stop;

endmodule



// Accompanying packet gen and packet bucket modules...ok to make local changes w/o global effect

module Psum_bucket #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface r);
  parameter BL = 0; //ideal environment
  logic [PWIDTH-1:0] packet=0;
  logic [DWIDTH-1:0] single_data;
  integer counter = 1;

  always
  begin 
    r.Receive(packet);
    single_data = packet[DWIDTH-1:0];
    $display("Psum_bucket received SUM # %d = %d", counter, single_data);
    #BL;
    counter = counter + 1;
  end
endmodule

module Psum_gen #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface r);
  parameter FL = 0; //ideal environment
  logic [DWIDTH*5 - 1 : 0] data_portion = 0;
  logic [PWIDTH-1: DWIDTH*5] upper_portion;
  logic [PWIDTH-1:0] packet=0;
  logic [DWIDTH-1:0] single_data;
  integer counter = 1;

  always
  begin 
//    if (counter < 6) begin
	    data_portion = $urandom() % 64;
	    upper_portion = $urandom();
	    single_data = data_portion[DWIDTH-1:0];
	    packet = {upper_portion, data_portion};
	    $display("PSum_Gen sent packet # %d w/ data = %d to child-2", counter, single_data);
	    #FL;
	    r.Send(packet);
	    counter = counter + 1;
//    end else begin
//	    #FL;
//    end // if
  end //always
endmodule
