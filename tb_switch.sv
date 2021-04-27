`timescale 1ns/1ns
import SystemVerilogCSP::*;

module tb_switch;

parameter FL = 2;
parameter BL = 1;
parameter WIDTH = 47;
parameter mask = 3'b110;
parameter address = 3'b100;
parameter input_type = 1'b0; // '0' Means input from child, '1' means input from parent

logic [WIDTH-1:0] packet = 47'b10111001111111111111111111111111111111111111111;
logic [WIDTH-1:0] packet_1 = 47'b0;
logic [WIDTH-1:0] packet_2 = 47'b0;
logic [WIDTH-1:0] packet_3 = 47'b0;
logic [WIDTH-1:0] packet_4 = 47'b0;

Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) C_In [0:4] ();

Channel #(.hsProtocol(P4PhaseBD), .WIDTH(WIDTH)) Out[0:9] ();

  //------ PACKET FORMAT ------ //
  // [46] ifm/filt load to ifmap memory or filter memory inside PEs 
  // [45:43] Destination Address
  // [42:40] Source Address
  // [39:0] Data 
  // packet =  ifm/filt	 dest_addr	src addr	 data
  // packet = 	x		   xxx	     xxx		40'bxxx..

//Sending on the parent input
//input_type = 1'b1 Addr = 000 mask = 000 ---- Receive from child 1
switch #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(3'b000), .mask(3'b000), 
			.input_type(1'b1)) r_core_p1_out(C_In[0], Out[0], Out[1]);
//input_type = 1'b1 Addr = 100 mask = 110 ---- Receive from child 2 
switch #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(3'b100), .mask(3'b110),
			.input_type(1'b1)) r_core_p2_out(C_In[1], Out[2], Out[3]);

//Sending on Child node input
//input_type = 1'b0 Addr = 100 mask = 110 ---- Receive from other child
switch #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(3'b100), .mask(3'b110),
			.input_type(1'b0)) r_core_c1_out(C_In[2], Out[4], Out[5]);
//input_type = 1'b0 Addr = 011 mask = 000 ---- Sent to parnet
switch #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(3'b011), .mask(3'b000), 
			.input_type(1'b0)) r_core_c2_out(C_In[3], Out[6], Out[7]);

integer fp;


initial
begin

  fp = $fopen("switch.dump","w");

  #5; C_In[0].Send(packet);   
  fork
	Out[0].Receive(packet_1);
	Out[1].Receive(packet_1);
  join_any
  $fdisplay(fp, "(1) Packet with destination 011 sent on parent input (mask=000 address=000) and received by child%d. received : %b", packet[45]+1, packet_1);
  
  #5; C_In[1].Send(packet);
  fork
	Out[2].Receive(packet_2);
	Out[3].Receive(packet_2);
  join_any
  $fdisplay(fp, "(2) Packet with destination 011 sent on parent input (mask=110 address=100) and received by child%d. received : %b", packet[43]+1, packet_2);	


  #5; C_In[2].Send(packet);
  fork
	Out[4].Receive(packet_3);
	Out[5].Receive(packet_3);
  join_any
  $fdisplay(fp, "(3) Packet with destination 011 sent on child input (mask=110 address=100) and received by other child. received : %b", packet_3);	
  
  #5; C_In[3].Send(packet);
  fork
	Out[6].Receive(packet_4);
	Out[7].Receive(packet_4);
  join_any
  $fdisplay(fp, "(4) Packet with destination 011 sent on child input (mask=000 address=011) and received by parent. received : %b", packet_4);

  $fdisplay(fp, "Successful Packets Received");
  $display("DONE");
  $stop;

end
endmodule


