`timescale 1ns/100ps
import SystemVerilogCSP::*;
// includes everything BUT the memory...those are the channels that need to be connected, to a WRAPPER memory
module Integrated_Modules #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface Mem_In, interface Mem_Out);
	
	//Interface Vector instatiation: 4-phase bundled data channel
	Channel #(.hsProtocol(P4PhaseBD), .WIDTH(PWIDTH)) intf  [10:1] (); 

	noc_top_level theRing ( .Mem_In(Mem_In), .PE0_In(intf[2]), .PE1_In(intf[3]), .PE2_In(intf[4]), .Adder_In(intf[5]),
		.Mem_out(Mem_Out), .PE0_out(intf[7]), .PE1_out(intf[8]), .PE2_out(intf[9]), .Adder_out(intf[10]));

// swapped PE, Adder in, out interfaces...did not swap mem in, out
	PE_Wrapper #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH),  .PE_Index(0)) PE_Block0  (.DPkt_In(intf[7]), .Pkt_Out(intf[2]));
//	data_bucket_packet #(.DWIDTH(8), .PWIDTH(47)) test_bucket_PE (.r(intf[3]));
	PE_Wrapper #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH),  .PE_Index(1)) PE_Block1  (.DPkt_In(intf[8]), .Pkt_Out(intf[3]));
	PE_Wrapper #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH),  .PE_Index(2)) PE_Block2  (.DPkt_In(intf[9]), .Pkt_Out(intf[4]));
	Psum_Adder_Safe_Wrapper #(.DWIDTH(8), .PWIDTH(47)) Safe_Adder_Block (.DPkt_In(intf[10]), .Pkt_Out(intf[5])); // changed from Psum_Adder_Wrapper

endmodule
