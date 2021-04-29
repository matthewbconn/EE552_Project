/* memory.sv

   Moises Herrera
   herrerab@usc.edu
   
   SP21 EE-552 Final project 
   
   INSTRUCTIONS:
   1. You can add code to this file, if needed.
   
   2. Marked with TODO:
   You can change/modify if needed
   
*/

`timescale 1ns/1ps

// memory
// TODO you can add more interfaces if needed (DO NOT remove testbench (tb_ interfaces))
// TODO you can add more system ports if needed
// TODO you can add $display or $fwrite commands if needed
module memory(interface sys_data_in, sys_addr_in, sys_data_out, sys_addr_out, tb_data_in, tb_addr_in, tb_data_out, tb_addr_out); 
  parameter FL = 12;
  parameter BL = 4;
  parameter WIDTH = 8; 
  parameter DEPTH = 256; 
  parameter ADDR_W = 8;
  
  logic [ADDR_W-1:0] in_addr;
  logic [ADDR_W-1:0] out_addr;  
  logic [WIDTH-1:0] d_in, d_out;
  logic [WIDTH-1:0] mem[DEPTH-1:0];
  int fpt;
  integer counter = 0;
  integer my_count = 0;

  initial begin 
  fpt = $fopen("transcript.dump");
  end

  always begin  
  fork
// system ports
   begin // Memory Wrapper sends results and addresses (200 thru 208) to Mem
    sys_addr_in.Receive(in_addr);
    sys_data_in.Receive(d_in);
    mem[in_addr] = d_in;
    $fwrite(fpt,"%m received data at %t \n",d_in,$realtime);
//    $display("%m received data at %t \n",d_in,$realtime);
    #BL;
   end
   
   begin // Memory_Wrapper sends Mem an address, memory sends back the data
    sys_addr_out.Receive(out_addr);
    sys_data_out.Send(mem[out_addr]);
    $fwrite(fpt,"%m sent data %d at %t \n",mem[out_addr],$realtime);
//    $display("%m sent data %d at %t \n",mem[out_addr],$realtime);
    #FL;
   end

// tb-only ports   
   begin // populate the memory
    tb_addr_in.Receive(in_addr);
    tb_data_in.Receive(d_in);
//	$display("\t%m received flit contents %b",d_in);
    mem[in_addr] = d_in;
   end

   begin // return results to TB
    tb_addr_out.Receive(out_addr); // this won't happen until Wrapped Memory  tells system_control "done" which in turn tells testbench "done"
    tb_data_out.Send(mem[out_addr]);
//$display("%m sent a result to the testbench");
   end
     
  join_any // effect: tb, wrapped memory can keeps going after memory loads
  end
endmodule


