`timescale 1ns/1ns
import SystemVerilogCSP::*;

module tb_noc;

parameter FL = 2;
parameter BL = 1;
parameter PACKET_SPACING_DELAY = 46; 
parameter number_of_tests = 100;
parameter WIDTH = 47;
parameter ADDR_WIDTH = 3;

logic [WIDTH-1:0] packet = 0;

logic ifm_filt = 1'b0;
logic [ADDR_WIDTH-1:0] dest_addr = 0;
logic [ADDR_WIDTH-1:0] src_addr = 0;
logic [40-1:0] data = 1'b0;

Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) Mem_In();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) PE0_In();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) PE1_In();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) PE2_In();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) Adder_In();

Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) Mem_out();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) PE0_out();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) PE1_out();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) PE2_out();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) Adder_out();

  //------ PACKET FORMAT ------ //
  // [46] ifm/filt load to ifmap memory or filter memory inside PEs 
  // [45:43] Destination Address
  // [42:40] Source Address
  // [39:0] Data 
  // packet =  ifm/filt	 dest_addr	src addr	 data
  // packet = 	x		   xxx	     xxx		40b'xxx..	

noc_top_level #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .number_of_tests(number_of_tests))
			noc_tester(.Mem_In(Mem_In), .PE0_In(PE0_In), .PE1_In(PE1_In), .PE2_In(PE2_In), .Adder_In(Adder_In),
			.Mem_out(Mem_out), .PE0_out(PE0_out), .PE1_out(PE1_out), .PE2_out(PE2_out), .Adder_out(Adder_out)); 

integer fp;
logic [7:0] iteration = 0; // SUPPORT FOR 256 ITERATIONS IN TEST BENCH

initial
begin
  
  while ( iteration < number_of_tests )
    begin
	  src_addr = $urandom%8;
	  dest_addr = $urandom%8;
	  
	  while (src_addr == 3'b010 || src_addr == 3'b101 || src_addr == 3'b111)
		begin
			src_addr = $urandom%8;
		end 
	  while (dest_addr == 3'b010 || dest_addr == 3'b101 || dest_addr == 3'b111)
		begin
			dest_addr = $urandom%8;
		end 
	  
	  while (src_addr == dest_addr) // MAKE SURE RANDOMIZED DESITINATION NODE != RANDOMIZED ORIGIN NODE
		begin
		  src_addr = $urandom%8;
		  dest_addr = $urandom%8;
		while (src_addr == 3'b010 || src_addr == 3'b101 || src_addr == 3'b111)
			begin
				src_addr = $urandom%8;
			end 
		while (dest_addr == 3'b010 || dest_addr == 3'b101 || dest_addr == 3'b111)
			begin
				dest_addr = $urandom%8;
			end 
		end
      data = $urandom%1024;
	  ifm_filt = $urandom%2;
      packet = {ifm_filt, dest_addr[ADDR_WIDTH-1:0], src_addr[ADDR_WIDTH-1:0], data[40-1:0]};
      
      $display("\n--------------------------------------------------------------------------------------------------------------------------------------------");
      $display("--------------------------------------------------------------------------------------------------------------------------------------------"); 
      $display("****************************** TB TEST #%0d @ Time: %0dns ******************************", iteration + 1, $time);
      $display("Source Node: %b, Destination Node: %b, Data: %b, Full Packet: %b", src_addr, dest_addr, data, packet);
      $display("--------------------------------------------------------------------------------------------------------------------------------------------");
      $display("--------------------------------------------------------------------------------------------------------------------------------------------\n"); 

      case(src_addr)
        3'b110: Mem_In.Send(packet);
        3'b011: PE0_In.Send(packet);
        3'b001: PE1_In.Send(packet);
        3'b000: PE2_In.Send(packet);
        3'b100: Adder_In.Send(packet);
        default: Mem_In.Send(packet);
      endcase
      
	  
      case(dest_addr)
        3'b110: Mem_out.Receive(packet);
        3'b011: PE0_out.Receive(packet);
        3'b001: PE1_out.Receive(packet);
        3'b000: PE2_out.Receive(packet);
        3'b100: Adder_out.Receive(packet);
        default: Mem_out.Receive(packet);
      endcase
	  
      iteration++;

      #PACKET_SPACING_DELAY;

    end

  #800;
  $display("\n\n ******************** TEST BENCH DONE ********************");

end
endmodule


