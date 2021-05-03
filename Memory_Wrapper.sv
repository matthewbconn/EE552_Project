`timescale 1ns/100ps
import SystemVerilogCSP::*;

module Memory_Wrapper #(parameter DWIDTH = 8, parameter PWIDTH = 47) 
(interface Packet_2_NoC, interface Packet_from_NoC, interface read_from_this_addr, interface read_data, interface write_to_addr, interface write_data, interface all_results_written);

  parameter PixelRowWIDTH = 5*DWIDTH;
  parameter FilterWIDTH = 3*DWIDTH;
  logic [PWIDTH-1:0] packet;
  logic [PixelRowWIDTH-1:0] pix;
  logic [FilterWIDTH-1:0] filt;
  logic [7:0] index, flit_raw;
  logic ifm_filt;
  logic [2:0] Dest_Addr;
  logic [2:0] Source_Addr;
  logic [DWIDTH-1:0] result [8:0];
  integer i, j, OFF_SET;
  integer pixel_frame_counter = 1;
  
  // Unused bc built in packetizer, depacketizer
		//Interface Vector instatiation: 4-phase bundled data channel
		//Channel #(.hsProtocol(P4PhaseBD), .WIDTH(PWIDTH)) intf  [12:1] ();
  
  initial begin
    ifm_filt = 0;
	Source_Addr = 6; // memory = 3'b110
	#10;

	// Get Filters from mem and send into NoC
	for (i = 0; i < 9; i = i + 3) begin
		index = i;
		read_from_this_addr.Send(index);
		read_data.Receive(flit_raw);		
		$display("\t\t%m received filter flit # %d contents %b",index, flit_raw);
		filt[23:16] = flit_raw;
		
		index = i+1;
		read_from_this_addr.Send(index);
		read_data.Receive(flit_raw);		
		$display("\t\t%m received filter flit # %d contents %b",index, flit_raw);
		filt[15:8] = flit_raw;
		
		index = i+2;
		read_from_this_addr.Send(index);
		read_data.Receive(flit_raw);		
		$display("\t\t%m received filter flit # %d contents %b",index, flit_raw);
		filt[7:0] = flit_raw;

		if (i == 0) begin // Send to PE0
			Dest_Addr = 3; // PE0 = 3'b011
		end else if (i == 3) begin // Send to PE1
			Dest_Addr = 1; // PE1 = 3'b001
		end else begin // i == 6 ...Send to PE2
			Dest_Addr = 0; // PE2 = 3'b000
		end
	//		      ifm/filt,      dest,         source,       data (upper 16b = x) 
		packet = {ifm_filt,   Dest_Addr,   Source_Addr,    16'hFF , filt};
$display("\t%m sent packet (to dest %b) with contents %b", Dest_Addr, packet);
		Packet_2_NoC.Send(packet);
	end // i loop

$display("\t%m completed sends of all 3 pixel frames to NoC");
 
	ifm_filt = 1;
	// Get Pixels from mem, send into NoC
	for (i = 9; i < 34; i = i + 5) begin
		index = i;
		read_from_this_addr.Send(index);
		read_data.Receive(flit_raw);
		$display("\t\t%m received pixel flit # %d contents %b",index, flit_raw);
		pix[39:32] = flit_raw;

		index = i+1;
		read_from_this_addr.Send(index);
		read_data.Receive(flit_raw);
		$display("\t\t%m received pixel flit # %d contents %b",index, flit_raw);
		pix[31:24] = flit_raw;

		index = i+2;
		read_from_this_addr.Send(index);
		read_data.Receive(flit_raw);
		$display("\t\t%m received pixel flit # %d contents %b",index, flit_raw);
		pix[23:16] = flit_raw;

		index = i+3;
		read_from_this_addr.Send(index);
		read_data.Receive(flit_raw);
		$display("\t\t%m received pixel flit # %d contents %b",index, flit_raw);
		pix[15:8] = flit_raw;

		index = i+4;
		read_from_this_addr.Send(index);
		read_data.Receive(flit_raw);
		$display("\t\t%m received pixel flit # %d contents %b",index, flit_raw);
		pix[7:0] = flit_raw;

		if (i == 9 || i == 24)  begin // Send to PE0
			Dest_Addr = 3; // PE0 = 3'b011
		end else if (i == 14 || i == 29) begin // Send to PE1
			Dest_Addr = 1; // PE1 = 3'b001
		end else begin // i == 19 ...Send to PE2
			Dest_Addr = 0; // PE2 = 3'b000
		end
$display("\t%m sending pixel frame %d to the NoC @ %d", pixel_frame_counter,$realtime);		
	//		      ifm/filt,      dest,         source,       data
		packet = {ifm_filt,   Dest_Addr,   Source_Addr,    pix};

//$display("%m sending packet with pixels to dest: %b", Dest_Addr);		
//$display("%m sent packet with contents %b", packet);
		Packet_2_NoC.Send(packet);
$display("\t%m complted send of pixel frame %d to the NoC @ %d", pixel_frame_counter,$realtime);
pixel_frame_counter = pixel_frame_counter + 1;
	end // i loop

$display("\t%m completed sends of ALL pixels to NoC");

	// Get results back
$display("\tMemory Wrapper getting results back:");
	for (i = 0; i < 9; i = i + 1) begin
		Packet_from_NoC.Receive(packet);
		result[i] = packet[DWIDTH-1:0];
$display("\t%m res[%d] = %d",i, result[i]);
	end
 
	OFF_SET = 200;
	// Send to final memory starting at location 200
	for (i = 0; i < 9; i = i + 1) begin
		j = OFF_SET + i;
		write_to_addr.Send(j);
		write_data.Send(result[i]);
	end
	
	all_results_written.Send(0);
  end
  
endmodule

