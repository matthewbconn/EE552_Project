`timescale 1ns/1ns
import SystemVerilogCSP::*;

module tb_router;

parameter FL = 2;
parameter BL = 1;
parameter WIDTH = 47;
parameter ADDR_WIDTH = 3;
parameter mask = 3'b110;
parameter address = 3'b100;
logic [ADDR_WIDTH-1:0] dest_addr = 0;
logic [WIDTH-1:0] packet = 47'b10111001111111111111111111111111111111111111111;

Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) C1_In();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) C1_Out();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) C2_In();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) C2_Out();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) P_In();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) P_Out();

  //------ PACKET FORMAT ------ //
  // [46] ifm/filt load to ifmap memory or filter memory inside PEs 
  // [45:43] Destination Address
  // [42:40] Source Address
  // [39:0] Data 
  // packet =  ifm/filt	 dest_addr	src addr	 data
  // packet = 	x		   xxx	     xxx		40'bxxx..

router #(.WIDTH(WIDTH), .address(address), .mask(mask), .FL(FL), .BL(BL)) router_tester(.C1_In(C1_In), .C1_Out(C1_Out), .C2_In(C2_In), .C2_Out(C2_Out), .P_In(P_In), .P_Out(P_Out)); 

integer fp;
integer iteration;

initial
begin

  fp = $fopen("router.dump","w");
  $fdisplay(fp, "ROUTER TEST BENCH DUMP");


  $fdisplay(fp, "\n\nTEST PACKET FROM CHILD-1 TO PARENT");
  //mask = 3'b110; address = 3'b100;
  dest_addr = 3'b100;
  packet = {packet[46], dest_addr[ADDR_WIDTH-1:0], packet[42:0]};
  #5; C1_In.Send(packet); P_Out.Receive(packet);
  $fdisplay(fp, "mask = %b, address = %b, dest_addr = %b", mask, address, dest_addr);	
  $fdisplay(fp, "Successful Packet From C1 to P");

  $fdisplay(fp, "\n\nTEST PACKET FROM CHILD-2 TO PARENT");
  //mask = 3'b110; address = 3'b100; 
  dest_addr = 3'b100;
  packet = {packet[46], dest_addr[ADDR_WIDTH-1:0], packet[42:0]};
  #5; C2_In.Send(packet); P_Out.Receive(packet);
  $fdisplay(fp, "mask = %b, address = %b, dest_addr = %b", mask, address, dest_addr);	
  $fdisplay(fp, "Successful Packet From C2 to P");


  $fdisplay(fp, "\n\nTEST PACKET FROM CHILD-1 TO CHILD-2");
  //mask = 3'b110; address = 3'b100;
  dest_addr = 3'b001;
  packet = {packet[46], dest_addr[ADDR_WIDTH-1:0], packet[42:0]};
  #5; C1_In.Send(packet); C2_Out.Receive(packet);
  $fdisplay(fp, "mask = %b, address = %b, dest_addr = %b", mask, address, dest_addr);	
  $fdisplay(fp, "Successful Packet From C1 to C2");

  $fdisplay(fp, "\n\nTEST PACKET FROM CHILD-2 TO CHILD-1");
  //mask = 3'b110; address = 3'b100; 
  dest_addr = 3'b010;
  packet = {packet[46], dest_addr[ADDR_WIDTH-1:0], packet[42:0]};
  #5; C2_In.Send(packet); C1_Out.Receive(packet);
  $fdisplay(fp, "mask = %b, address = %b, dest_addr = %b", mask, address, dest_addr);	
  $fdisplay(fp, "Successful Packet From C2 to C1");


  $fdisplay(fp, "\n\nTEST PACKET FROM PARNET TO CHILD-2");
  //mask = 3'b110; address = 3'b100;
  dest_addr = 3'b001;
  packet = {packet[46], dest_addr[ADDR_WIDTH-1:0], packet[42:0]};
  #5; P_In.Send(packet); C2_Out.Receive(packet);
  $fdisplay(fp, "mask = %b, address = %b, dest_addr = %b", mask, address, dest_addr);	
  $fdisplay(fp, "Successful Packet From P to C2");

  $fdisplay(fp, "\n\nTEST PACKET FROM PARNET TO CHILD-1");
  //mask = 3'b110; address = 3'b100; 
  dest_addr = 3'b110;
  packet = {packet[46], dest_addr[ADDR_WIDTH-1:0], packet[42:0]};
  #5; P_In.Send(packet); C1_Out.Receive(packet);
  $fdisplay(fp, "mask = %b, address = %b, dest_addr = %b", mask, address, dest_addr);	
  $fdisplay(fp, "Successful Packet From P to C1");


  $display("DONE");
  $stop;

end
endmodule


