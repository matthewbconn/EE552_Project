`timescale 1ns/100ps
import SystemVerilogCSP::*;

module PE_tb #(parameter DWIDTH = 8, parameter PWIDTH = 47);// (interface In, interface Pixel_Out, interface Filter_out);
  parameter PixelWIDTH = DWIDTH*5;
  parameter FilterWIDTH = DWIDTH*3;
  logic [PWIDTH-1:0] packet;
  logic [PixelWIDTH-1:0] pix;
  logic [FilterWIDTH-1:0] filt;

  //Interface Vector instatiation: 4-phase bundled data channel
  Channel #(.hsProtocol(P4PhaseBD), .WIDTH(PWIDTH)) intf  [1:0] (); 

  PE_packet_gen #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH)) packet_generator (.r(intf[0]));
  PE_Wrapper #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH),  .PE_Index(2)) PE_Block  (.DPkt_In(intf[0]), .Pkt_Out(intf[1]));
  PE_packet_bucket #(.DWIDTH(DWIDTH), .PWIDTH(PWIDTH)) packet_bucket (.l(intf[1]));

  initial
	#260 $stop;

endmodule



// Accompanying packet gen and packet bucket modules...ok to make local changes w/o global effect

module PE_packet_bucket #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface l);
  parameter BL = 0; //ideal environment
  logic [PWIDTH-1:0] packet;
  logic [DWIDTH-1:0] psum;
  logic [DWIDTH-1:0] filt [2:0];
  integer counter = 1;

  always
  begin 
    l.Receive(packet);
    if (packet[PWIDTH-1] == 1'b0) begin
	filt[2] = packet[DWIDTH*3-1:DWIDTH*2];
	filt[1] = packet[DWIDTH*2-1:DWIDTH*1];
	filt[0] = packet[DWIDTH*1-1:DWIDTH*0];
	$display("PE_bucket received filters %d %d %d", filt[2], filt[1], filt[0]);
    end else begin
	psum = packet[DWIDTH-1:0];
	$display("PE_bucket received a psum: %d", psum);
    end
    #BL;
    counter = counter + 1;
  end
endmodule

module PE_packet_gen #(parameter DWIDTH = 8, parameter PWIDTH = 47) (interface r);
  parameter FL = 0; //ideal environment
  logic [DWIDTH*5 - 1 : 0] data_portion;
  logic [PWIDTH-1: DWIDTH*5] upper_portion;
  logic [PWIDTH-1:0] packet;
  logic [DWIDTH-1:0] single_pixel [4:0];
  logic [DWIDTH-1:0] single_filter [2:0];
  logic isPixel;

  always
  begin 
	    single_pixel[4] = 8'h4;//$urandom() % 64;
	    single_pixel[3] = 8'h3;//$urandom() % 64;
	    single_pixel[2] = 8'h2;//$urandom() % 64;
	    single_pixel[1] = 8'h1;//$urandom() % 64;
	    single_pixel[0] = 8'h0;//$urandom() % 64;

	    isPixel = 1;
//		IFM/filt, dest. add, sour. add., data
	    packet = {isPixel,   3'b011,   3'b110,    single_pixel[4],    single_pixel[3],    single_pixel[2],    single_pixel[1],    single_pixel[0]};
	    #FL;
	    r.Send(packet);
//            $display("Packet_Gen sent pixels(%b) %d %d %d %d %d", packet[PWIDTH-1], single_pixel[4], single_pixel[3], single_pixel[2], single_pixel[1], single_pixel[0]);
	    $display("\tPacket sent was %b", packet);

	    single_filter[2] = 8'h1;//$urandom() % 64;
	    single_filter[1] = 8'h0;//$urandom() % 64;
	    single_filter[0] = 8'h1;//$urandom() % 64;

	    isPixel = 0;
//		ifm/FILT, dest. add, sour. add., data 
	    packet = {isPixel,   3'b011,   3'b110,    8'h0,    8'h0,    single_filter[2],    single_filter[1],    single_filter[0]};
   	    #FL;
    	    r.Send(packet);
//            $display("Packet_Gen sent filters(%b) %d %d %d", packet[PWIDTH-1], single_filter[2], single_filter[1], single_filter[0]);
	    $display("\tPacket sent was %b", packet);
  end //always

endmodule
