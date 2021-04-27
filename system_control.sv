/* system_control.sv

   Moises Herrera
   herrerab@usc.edu
   
   SP21 EE-552 Final project 
   
   INSTRUCTIONS:
   1. You can add code to this file, if needed.
   
   2. Marked with TODO:
   You can change/modify if needed
   
   3. the control module needs to wait for the start token to
   start the system operation
   
   4. The control needs to send done to the testbench, when 
   system operations finish.
   
*/

`timescale 1ns/1ps

//import SystemVerilogCSP::*;

// system control
// TODO complete this module
module system_control(interface start, done, results_ready);
 logic star_t;
 logic completed;
 int fpt; 

 initial begin
  fpt = $fopen("transcript.dump");
  start.Receive(star_t);
  $fwrite(fpt,"%m start token received at %t \n",$realtime);
  $display("%m start token received at %t \n",$realtime);
// The memory have been loaded and the system starts
   
  results_ready.Receive(completed);
   
// sending done token when all results are in the memory already!
  #0.1;
  done.Send(0);
  $fwrite(fpt,"%m sent done token at %t \n",$realtime);
  $display("%m sent done token at %t",$realtime);
 end
endmodule
