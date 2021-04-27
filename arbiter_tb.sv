`timescale 1ns/1ns

import SystemVerilogCSP::*;

module tb_arbiter;

Channel #(.hsProtocol(P4PhaseBD),.WIDTH(8))  Req_1();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(8)) Req_2();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(1)) Win();


parameter FL = 2;
parameter BL = 1;
parameter WIDTH = 8;
logic [WIDTH-1:0] Req_1_data = 0;
logic [WIDTH-1:0] Req_2_data = 0;
logic sel = 0;

integer fp;
integer iteration;

arbiter #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) two_arb_tester(.Req_1(Req_1),.Req_2(Req_2),.Win(Win)); 

initial
begin

  fp = $fopen("arbiter.dump","w");
  $fdisplay(fp, "sel = 0 : Req_1 gets access");
  $fdisplay(fp, "sel = 1 : Req_2 gets access");

  // TEST Req_1 WINNING -> sel = 0
  $fdisplay(fp, "\n\nTEST Req_1 ONLY");
  Req_1_data = 1;  Req_2_data = 2;
  #5; 
  fork
	Req_1.Send(Req_1_data);
	Win.Receive(sel);
  #5; 
	Req_1.Receive(Req_1_data); // CLEAR Req_1 CHANNEL
  join 
  $fdisplay(fp, "Req_1 gets access: sel = %d", sel);	


  // TEST Req_2 WINNING -> sel = 1
  $fdisplay(fp, "\n\nTEST Req_2 ONLY");
  Req_1_data = 1; Req_2_data = 2;
  #5; 
  fork 
	Req_2.Send(Req_2_data); 
	Win.Receive(sel); 
  #5; 
	Req_2.Receive(Req_2_data); // CLEAR Req_2 CHANNEL
  join 
  $fdisplay(fp, "Req_2 gets access: sel = %d", sel);	


  // TEST RANDOM WINNER -> sel = ?
  $fdisplay(fp, "\n\nTEST BOTH Req_1 & Req_2");
  iteration = 0;
  while(iteration < 16)
  begin
    Req_1_data = 1; Req_2_data = 2;
    #5; 
	fork 
		Req_1.Send(Req_1_data);
		Req_2.Send(Req_2_data); 
		Win.Receive(sel); 
    #5; 
		Req_1.Receive(Req_1_data); // CLEAR BOTH CHANNELS
		Req_2.Receive(Req_2_data); 
	join 
    $fdisplay(fp, "Req%d gets access: sel = %d", sel+1, sel);	
    iteration++;
  end

  $display("DONE");

end
endmodule

