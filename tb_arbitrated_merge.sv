`timescale 1ns/1ns
import SystemVerilogCSP::*;

module tb_arbitrated_merge;

Channel #(.hsProtocol(P4PhaseBD),.WIDTH(8))  A();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(8)) B();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(8)) O();


parameter FL = 2;
parameter BL = 1;
parameter WIDTH = 8;
logic [WIDTH-1:0] A_data = 0;
logic [WIDTH-1:0] B_data = 0;
logic [WIDTH-1:0] Output = 0;
logic [WIDTH-1:0] Succeeding_Output = 0;

arbitrated_merge #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) arb_merge_tester(.A(A),.B(B),.O(O)); 

integer fp;
integer iteration;

initial
begin

  fp = $fopen("arbitrated_merge.dump","w");
  $fdisplay(fp, "ARBITRATED MERGE TEST BENCH DUMP");


  $fdisplay(fp, "\n\n SELECT A TEST");
  A_data = {$random}%64; B_data = {$random}%64;
  #5; fork A.Send(A_data); O.Receive(Output); join
  $fdisplay(fp, "A = %d, B = %d, Output = %d", A_data, B_data, Output);	


  $fdisplay(fp, "\n\n SELECT B TEST");
  A_data = {$random}%64; B_data = {$random}%64;
  #5; fork B.Send(B_data); O.Receive(Output); join
  $fdisplay(fp, "A = %d, B = %d, Output = %d", A_data, B_data, Output);	
  

  $fdisplay(fp, "\n\n SELECT RANDOMLY TEST");
  iteration = 0;
  while(iteration < 32)
  begin
    A_data = {$random}%64; B_data = {$random}%64;
    #5; fork 
    A.Send(A_data); B.Send(B_data); O.Receive(Output); 
    join
    O.Receive(Succeeding_Output); // Clear Output Channel
    $fdisplay(fp, "A = %d, B = %d, First Output = %d, Second Output = ", A_data, B_data, Output, Succeeding_Output);	
    iteration++;
  end

  $display("DONE");

end
endmodule


