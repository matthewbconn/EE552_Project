`timescale 1ns/1ns
import SystemVerilogCSP::*;

//------------------------------------
//---------- ARBITER MODULE ----------
//------------------------------------
module arbiter (interface Req_1, Req_2, Win);
  parameter FL = 2;
  parameter BL = 1;
  parameter WIDTH = 1;
  logic [WIDTH-1:0] sel = 0; // '0' means Req_1 gets access, '1' means Req_2 gets access

  always
  begin

    wait(Req_1.status != idle || Req_2.status != idle);
	
    // Case_I: Both ports request access
    if (Req_1.status != idle && Req_2.status != idle)
      begin
        //pick one randomly
        if ($urandom%2==0)
          begin
            //Req_1 gets access;
            sel = 0;
            Win.Send(sel);
          end
        else
          begin
            //Req_2 gets access;
            sel = 1;
            Win.Send(sel);
          end
      end

    else if (Req_1.status != idle)
      begin
        //Req_1 gets access;;
        sel = 0;
        Win.Send(sel);
      end

    else
      begin
        //Req_2 gets access;;
        sel = 1;
        Win.Send(sel);
      end

    #BL;

  end
endmodule


//------------------------------------
//---------- MERGE MODULE ------------
//------------------------------------
module merge (interface S, A, B, O);
  parameter FL = 2;
  parameter BL = 1;
  parameter WIDTH = 47;//8;
  logic select = 0;
  logic [WIDTH-1:0] data = 0;

  always
  begin

    S.Receive(select);
    
    case(select)

      0: begin
           A.Receive(data);
         end

      1: begin
           B.Receive(data);
         end

    endcase
    #FL;
$display("%m beginning a send...time = %d", $time);
    O.Send(data);
$display("%m finished a send...time = %d", $time);	
    #BL;
    
  end
endmodule


//------------------------------------
//----- ARBITRATED MERGE MODULE ------
//------------------------------------
module arbitrated_merge(interface A, B, O);
  parameter FL = 2;
  parameter BL = 1;
  parameter WIDTH = 47;//8;

  //Interface Vector instatiation: 4-phase bundled data channel
  Channel #(.hsProtocol(P4PhaseBD)) intf  [1:0] (); 

  //arbiter (interface R1, R2, W);
  arbiter #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) two_a(A, B, intf[0]);

  //merge (interface S, A, B, O);
  merge #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) two_m(intf[0], A, B, O);
  
 endmodule


//------------------------------------
//----------- SWITCH MODULE ----------
//------------------------------------
module switch (interface In, Out_1, Out_2);
  parameter FL = 2;
  parameter BL = 1;
  parameter WIDTH = 47;
  parameter address = 3'b000;
  parameter mask = 3'b000;
  parameter input_type = 1'b0; //0 for child, 1 for parent 
  
  logic [WIDTH-1:0] packet = 0;

  //------ PACKET FORMAT ------ //
  // [46] ifm/filt load to ifmap memory or filter memory inside PEs 
  // [45:43] Destination Address
  // [42:40] Source Address
  // [39:0] Data 
  // packet =  ifm/filt	 dest_addr	src addr	 data
  // packet = 	x		   xxx	     xxx		40b'xxx..		

  always
  begin

    In.Receive(packet);
	$display("%m received packet contents: %b", packet);
    $display("Router Instance: %m");
    $display("Router Address: %b, Mask: %b, Packet Destination: %b", address, mask, packet[45:43]);

    #FL;

    if ( input_type == 1'b0 ) //INPUT FROM A CHILD: OUT_1 = OTHER CHILD AND OUT_2 = PARENT 
      begin
//        $display("Received packet from a child node");
        if(packet[45:43] == address) // IF DESTINATION ADDRESS MATCHES: SEND TO PARENT 
          begin
//            $display("Sent = %b to parent", packet);
            Out_2.Send(packet);
          end

        else // SEND TO OTHER CHILD  
          begin
//		    $display("Sent = %b to other child", packet);
            Out_1.Send(packet);
          end
      end

    else //INPUT FROM PARENT: OUT_1 = CHILD_1 AND OUT_2 = CHILD_2

      begin
 //       $display("Received packet from a parent node");
        if(mask[2] == 0) // Finding first unmasked bit - MASK = 000
          begin
            if(packet[45] == 0)
              begin
//                $display("Sent = %b to child-1", packet);
                Out_1.Send(packet);
              end
            else
              begin
 //               $display("Sent = %b to child-2", packet);
                Out_2.Send(packet);
              end
          end
      else if(mask[1] == 0) // Finding first unmasked bit - MASK = 100
        begin
          if(packet[44] == 0)
            begin
 //             $display("Sent = %b to child-1", packet);
              Out_1.Send(packet);
            end
          else
            begin
//              $display("Sent = %b to child-2", packet);
              Out_2.Send(packet);
            end
        end
      else if(mask[0] == 0) // Finding first unmasked bit - MASK = 110
        begin
          if(packet[43] == 0)
            begin
//              $display("Sent = %b to child-1", packet);
              Out_1.Send(packet);
            end
          else
            begin
//              $display("Sent = %b to child-2", packet);
              Out_2.Send(packet);
            end
        end
    end

//    $display("-----------------------------------------------------------------------------\n"); 

    #BL;
   
  end
endmodule


//------------------------------------
//---------- ROUTER MODULE -----------
//------------------------------------
module router(interface C1_In, C1_Out, C2_In, C2_Out, P_In, P_Out);
  parameter FL = 2;
  parameter BL = 1;
  parameter WIDTH = 47;
  parameter address = 3'b000;
  parameter mask = 3'b000;

  //Interface Vector instatiation: 4-phase bundled data channel
  Channel #(.hsProtocol(P4PhaseBD),.WIDTH(WIDTH)) intf  [5:0] (); 

  // switch (interface In, Out_1, Out_2);
  // INPUT_TYPE parameter: '0' = input from child, '1' = input from parent
  switch #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(address), .mask(mask), 
			.input_type(1'b0)) switch_c1_in(C1_In, intf[0], intf[1]);
  switch #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(address), .mask(mask),
			.input_type(1'b0)) switch_c2_in(C2_In, intf[2], intf[3]);
  switch #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(address), .mask(mask),
			.input_type(1'b1)) switch_p_in(P_In, intf[4], intf[5]);

  // arbitrated_merge(interface A, B, O);
  arbitrated_merge #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) 
			arb_merge_C1(intf[2], intf[4], C1_Out);
  arbitrated_merge #(.WIDTH(WIDTH), .FL(FL), .BL(BL))
			arb_merge_C2(intf[0], intf[5], C2_Out);
  arbitrated_merge #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) 
			arb_merge_P(intf[3], intf[1], P_Out);
  
 endmodule


//------------------------------------
//------- NoC TOP LEVEL MODULE -------
//------------------------------------
module noc_top_level(interface Mem_In, PE0_In, PE1_In, PE2_In, Adder_In, Mem_out, PE0_out, PE1_out, PE2_out, Adder_out);
  parameter FL = 2;
  parameter BL = 1;
  parameter WIDTH = 47;
  parameter number_of_tests = 100;  

  //Interface Vector instatiation: 4-phase bundled data channel
  Channel #(.hsProtocol(P4PhaseBD),.WIDTH(WIDTH)) intf  [30:0] (); 

  // module router(interface C1_In, C1_Out, C2_In, C2_Out, P_In, P_Out);
  // MEM router: Mask 110, Addr 110													     
  router #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(3'b110), .mask(3'b110))
  MEM_router (intf[0], intf[1], intf[2], intf[3], Mem_In, Mem_out);
  
  // PE0 router: Mask 011, Addr 011													 
  router #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(3'b011), .mask(3'b011))
  PE0_router (intf[6], intf[7], intf[3], intf[2], PE0_In, PE0_out);
  
  // PE1 router: Mask 100, Addr 001												    
  router #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(3'b001), .mask(3'b100))
  PE1_router (intf[10], intf[11], intf[7], intf[6], PE1_In, PE1_out);
  
  // PE2 router: Mask 000, Addr 000												    
  router #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(3'b000), .mask(3'b000))
  PE2_router (intf[11], intf[10], intf[14], intf[15], PE2_In, PE2_out);
  
  // Adder router: Mask 100, Addr 100												    
  router #(.WIDTH(WIDTH), .FL(FL), .BL(BL), .address(3'b100), .mask(3'b100)) 
  Adder_router (intf[15], intf[14], intf[1], intf[0], Adder_In, Adder_out);
  

 endmodule
