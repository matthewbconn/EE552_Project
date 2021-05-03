`timescale 1ns/100ps
import SystemVerilogCSP::*;
// special depacketizer for Psum adder - safe version
module DP_Adder_Safe #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface In, interface Out0, interface Out1, interface Out2);
  parameter FL = 1;
  parameter BL = 1;
  logic [PWIDTH-1:0] packet;
  logic [DWIDTH-1:0] Psum;
  logic [2:0] source;
  
  always
  begin
	In.Receive(packet);

	#FL;
	Psum = packet[DWIDTH-1:0];
	source = packet[42:40]; // source address
$display("\t%m received a psum from source %b at time %d", source, $realtime);	
	if (source == 3) begin // PE0 Queue
		Out0.Send(Psum);
		$display("\t\t dispatched Psum down PE0 queue");
	end else if (source == 1) begin // PE1 Queue
		Out1.Send(Psum);
		$display("\t\t dispatched Psum down PE1 queue");
	end else if (source == 0) begin // PE2 Queue
		Out2.Send(Psum);
		$display("\t\t dispatched Psum down PE2 queue");
	end
	$display("\tSafe_Adder DePacketizer passing psum = %d", Psum);
	#BL;
  end

endmodule


