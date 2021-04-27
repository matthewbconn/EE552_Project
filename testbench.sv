/* testbench.sv

   Moises Herrera
   herrerab@usc.edu
   
   SP21 EE-552 Final project 
   
   INSTRUCTIONS:
   1. You can add code to this file, if needed.
   
   2. Marked with TODO:
   You can change/modify if needed
   
   3. Note: Do not modify the result code!
*/

`timescale 1ns/1ps

import SystemVerilogCSP::*;

//control testbench
module ctrl_tb(interface mem_data, mem_addr, result_data, result_addr, start, done, output reg reset);

// data width
 parameter WIDTH = 8;
 
// feature map is 5 x 5 
 parameter DEPTH_I = 5;
 parameter WIDTH_I = 5;
 parameter ADDR_I = 5;
 
// filter is 3x3 
 parameter DEPTH_F = 3;
 parameter WIDTH_F = 3;
 parameter ADDR_F = 4;
 
// result is 3x3
 parameter DEPTH_R = 3;
 parameter WIDTH_R = 3;
 parameter ADDR_R = 4;

// pointer to the result matrix  
// TODO you can edit this parameter if needed 
 parameter READ_FINAL_F_MAP = 200;
 
 logic [(WIDTH)-1:0] data_ifmap, data_filter, res;
 logic [ADDR_F-1:0] addr_filter = 0;
 logic [ADDR_I-1:0] addr_ifmap = 0;
 logic [WIDTH-1:0] comp[DEPTH_R*WIDTH_R-1:0];
 integer count, error_count, fpo, fpt, fpi_f, fpi_i, fpi_r,status, don_e = 0;
 
// main execution
 initial begin
 $timeformat(-9, 2, " ns");
// reset 
 reset = 0;
 
// sending values to M module
   fpi_f = $fopen("filter.txt","r");
   fpi_i = $fopen("ifmap.txt","r");
   fpi_r = $fopen("golden_result.txt","r");
   fpo = $fopen("test.dump","w");
   fpt = $fopen("transcript.dump");
   if(!fpi_f || !fpi_i)
   begin
       $display("A file cannot be opened!");
       $stop;
   end
//sending to the memory filter and feature map
	   for(integer i=0; i<(DEPTH_F*WIDTH_F); i++) begin
	    if(!$feof(fpi_f)) begin
	     status = $fscanf(fpi_f,"%d\n", data_filter);
	     $display("fpf data read:%d", data_filter);
	     mem_addr.Send(addr_filter);
	     mem_data.Send(data_filter); 
	     comp[addr_filter] = data_filter;
	     $display("filter memory: mem[%d]= %d",addr_filter,data_filter);
	     $fdisplay(fpt,"filter memory: mem[%d]= %d",addr_filter,data_filter);
	     addr_filter++;
	     $display("addr_filter=%d",addr_filter);
	   end end
$display("%mFinished writing filter data to memory, about to begin writing pixels");	   
	   count = DEPTH_F*WIDTH_F;
	   for(integer i=0; i<DEPTH_I*WIDTH_I; i++) begin
	    if (!$feof(fpi_i)) begin
	     status = $fscanf(fpi_i,"%d\n", data_ifmap);
	     $display("fpi data read:%d", data_ifmap);
	     mem_addr.Send(count);
	     mem_data.Send(data_ifmap); 
	     comp[addr_ifmap] = data_ifmap; // Matt question: why is this line used?,  it is overwritten very soon after
	     $display("ifmap memory: mem[%d]= %d",count, data_ifmap);
	     $fdisplay(fpt,"ifmap memory: mem[%d]= %d",count, data_ifmap);
	     count++;
	   end end
$display("%m finished writing pixel data to memory");	   
// loading golden_results
   	   for(integer i=0; i<(DEPTH_R*WIDTH_R); i++) begin
	    if(!$feof(fpi_r)) begin
	     status = $fscanf(fpi_r,"%d\n", res);
	     $display("fpi_r data read:%d", res);
	     comp[i] = res;
	     $fdisplay(fpt,"comp[%d]= %d",i,res); 
	     $display("comp[%d]= %d",i,res);

	   end end

// starting the system
 #0.1;
 reset = 1;
  start.Send(0); 
  $fdisplay(fpt,"%m sent start token at %t",$realtime);
  $display("%m sent start token at %t",$realtime);
// TODO you can add code here

// system operation finished, now waiting for done
 #0.1;
 done.Receive(don_e);
 $fdisplay(fpt,"%m done token received at %t",$realtime);
//  
// comparing results
 error_count = 0;
 count = READ_FINAL_F_MAP;
 for(integer i=0; i<DEPTH_R*WIDTH_R; i++) begin
  result_addr.Send(count);
  count++;
  result_data.Receive(res);
  if (res !== comp[i])  begin
   $fdisplay(fpo,"%d != %d error!",res,comp[i]);
   $fdisplay(fpt,"%d != %d error!",res,comp[i]);
   $display("%d != %d error!",res,comp[i]);
   $fdisplay(fpt,"mem[%d] = %d == comp[%d] = %d",count, res, i, comp[i]);
   $fdisplay(fpo,"mem[%d] = %d == comp[%d] = %d",count, res, i, comp[i]);
   error_count++;
  end else begin
   $display(fpt,"mem[%d] = %d == comp[%d] = %d",count, res, i, comp[i]);
   $fdisplay(fpo,"mem[%d] = %d == comp[%d] = %d",count, res, i, comp[i]);
   $display("%m result value %0d: %d received at %t",i, res, $realtime);
  end
 end
 $fdisplay(fpo,"total errors = %d",error_count);
 $fdisplay(fpt,"total errors = %d",error_count);
 $display("total errors = %d",error_count); 
 
  $display("%m Results compared, ending simulation at %t",$realtime);
  $fdisplay(fpt,"%m Results compared, ending simulation at %t",$realtime);
  $fdisplay(fpo,"%m Results compared, ending simulation at %t",$realtime);
  $fclose(fpt);
  $fclose(fpo);
  $stop;
 end
 
// watchdog timer
 initial begin
 #600;
 $display("*** Stopped by watchdog timer ***");
 $stop;
 end

endmodule



//testbench instantiation
module testbench;
 Channel #(.hsProtocol(P4PhaseBD), .WIDTH(8)) intf  [10:0] (); 
 Channel #(.hsProtocol(P4PhaseBD), .WIDTH(47)) wide_intf  [12:11] (); 

// parameter WIDTH = 8;
// TODO you can add parameters if needed
 
// use signal rst if needed
 wire rst;
 
// control testbench
// TODO you can add more interfaces if needed (DO NOT remove interfaces)
ctrl_tb tb ( .reset(rst), .start(intf[0]), .mem_data(intf[1]), .mem_addr(intf[2]),
 .result_data(intf[3]), .result_addr(intf[4]), .done(intf[5]));	


//memory module
// TODO you can add more interfaces if needed (DO NOT remove interfaces)
memory mem(.tb_data_in(intf[1]), .tb_addr_in(intf[2]), .tb_data_out(intf[3]), .tb_addr_out(intf[4]),
				.sys_data_in(intf[7]), .sys_addr_in(intf[8]), .sys_data_out(intf[9]), .sys_addr_out(intf[10])); 

	
//system control
// TODO add interfaces as needed
system_control sys_ctrl(.start(intf[0]), .done(intf[5]), .results_ready(intf[6]));

Memory_Wrapper #(.DWIDTH(8), .PWIDTH(47)) mem_wrapped 
	( .Packet_2_NoC(wide_intf[11]), .Packet_from_NoC(wide_intf[12]), .read_from_this_addr(intf[10]), .read_data(intf[9]), 
		.write_to_addr(intf[8]), .write_data(intf[7]), .all_results_written(intf[6]));

Integrated_Modules #(.DWIDTH(8), .PWIDTH(47)) NoC_minus_Mem ( .Mem_In(wide_intf[11]), .Mem_Out(wide_intf[12]));


endmodule
 

