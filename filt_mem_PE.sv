`timescale 1ns/100ps
import SystemVerilogCSP::*;

module filt_mem_PE #(parameter DWIDTH = 8, parameter PWIDTH = 47)
	(interface Filter_Frame_In, interface Filter_Frame_Out, interface Filter_Single_Out);
parameter FL = 2;
parameter BL = 2;
logic [DWIDTH*3 - 1 : 0] filt_frame;
logic [DWIDTH-1:0] single_filter [2:0];
parameter NUM_SENDS = 3;
integer i;

always begin
    Filter_Frame_In.Receive(filt_frame);
//$display("\t%m received filters");
    single_filter[2] = filt_frame[DWIDTH*3 - 1 : DWIDTH*2];
    single_filter[1] = filt_frame[DWIDTH*2 - 1 : DWIDTH*1];
    single_filter[0] = filt_frame[DWIDTH*1 - 1 : DWIDTH*0];
    for (i = 0; i < NUM_SENDS; i = i + 1) begin
	#FL;
	Filter_Single_Out.Send(single_filter[2]);
	#BL; #FL;
	Filter_Single_Out.Send(single_filter[1]);
	#BL; #FL;
	Filter_Single_Out.Send(single_filter[0]);
	#BL;
    end

    Filter_Frame_Out.Send(filt_frame);
$display("\t%m completed filter frame send at time %d",$realtime);
end //always
endmodule


