`timescale 1ns/100ps
import SystemVerilogCSP::*;
// Packetizer for the PE module...alternates between sending partial sums of CONV op. and sending filters

module P_PE #(parameter DWIDTH = 8, parameter PWIDTH = 47, parameter PE_Index = 0)
		 (interface PSum_In, interface Filter_In, interface Out);
  parameter FL = 1;
  parameter BL = 1;
  parameter numPSums = 3;
  logic [2:0] Adder_Node_Addr;
  logic [2:0] This_PE_Addr;
  logic [2:0] Next_PE_Addr;
  logic [3*DWIDTH-1:0] filter_frame;
  logic [PWIDTH-1:0] packet;
  logic [DWIDTH-1:0] Psum;
  logic IFM_one_FILT_zero;
  integer i = 0;
  
  always
  begin
    Adder_Node_Addr = 4;
    if (PE_Index == 0) begin
	This_PE_Addr = 3;//3b'011;
	Next_PE_Addr = 1;//3b'001;
	$display("PE 0 packetizer instantiated");
    end else if (PE_Index == 1) begin
	This_PE_Addr = 1;//3b'001;
	Next_PE_Addr = 0;//3b'000;
	$display("PE 1 packetizer instantiated");
    end else if (PE_Index == 2) begin
	This_PE_Addr = 0;//3b'000;
	Next_PE_Addr = 3;//3b'011;
	$display("PE 2 packetizer instantiated");
    end

    while (1) begin
	    for (i = 0; i < numPSums; i = i + 1) begin
		PSum_In.Receive(Psum);
		$display("%m received (relative) psum %d at time %d", i, $realtime);
		IFM_one_FILT_zero = 1;
		#FL;
	//		      ifm/filt,      ADDER NOde = dest,   source,       data (upper 32b = x) 
		packet = {IFM_one_FILT_zero,   Adder_Node_Addr,   This_PE_Addr,    32'hFFFF , Psum};
		Out.Send(packet);
		$display("%m sent out (relative) psum %d at time %d", i, $realtime);
		#BL;
	    end // for loop

	    Filter_In.Receive(filter_frame);
	    IFM_one_FILT_zero = 0;
	    #FL;
	//		ifm/filt,           dest,           source,       data (upper 32b = x) 
	    packet = {IFM_one_FILT_zero,   Next_PE_Addr,   This_PE_Addr,    8'h0,    8'h0 , filter_frame};
	    Out.Send(packet);
		$display("\t\t%m  XYXY PEaddr(%b)sending filters to next PEaddr(%b) at time %d", This_PE_Addr,Next_PE_Addr,$realtime);
	    #BL;

    

    end // while
  end  // always loop

endmodule
