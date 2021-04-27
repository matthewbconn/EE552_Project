`timescale 1ns/1ns
import SystemVerilogCSP::*;

module tb_merge;

Channel #(.hsProtocol(P4PhaseBD),.WIDTH(1))  S();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(8)) A();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(8)) B();
Channel #(.hsProtocol(P4PhaseBD), .WIDTH(8)) O();

parameter FL = 2;
parameter BL = 1;
parameter WIDTH = 8;
logic Select = 0;
logic [WIDTH-1:0] A_data = 0;
logic [WIDTH-1:0] B_data = 0;
logic [WIDTH-1:0] Output = 0;

merge #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) merge_tester(.S(S),.A(A),.B(B),.O(O)); 

integer fp;
integer iteration;

initial
begin

  fp = $fopen("merge.dump","w");
  $fdisplay(fp, "MERGE TEST BENCH DUMP\n");
  $fdisplay(fp, "Select = 0 : A Selected");
  $fdisplay(fp, "Select = 1 : B Selected");

  iteration = 0;
  while(iteration < 32)
  begin
    A_data = {$random}%64; B_data = {$random}%64; Select = {$random}%2;
    #5; 
	fork S.Send(Select); A.Send(A_data); B.Send(B_data); O.Receive(Output);
    // CLEAR UNSELECTED CHANNEL
    if(Select == 0)
      begin
        B.Receive(B_data);
      end
    else
      begin
        A.Receive(A_data);
      end
    join
    $fdisplay(fp, "A = %d, B = %d, Select = %d, Output = %d", A_data, B_data, Select, Output);	
    iteration++;
  end

  $display("DONE");

end
endmodule

