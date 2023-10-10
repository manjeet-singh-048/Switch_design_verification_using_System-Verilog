`ifndef GUARD_TESTCASE
`define GUARD_TESTCASE

class small_packet extends packet_c;
//    constraint small_cons{data.size > 200;}
      constraint small_cons{data.size < 20;} //extremely smalll packet

endclass : small_packet


program testcase(mem_interface.MEM mem_intf,input_interface.IP input_intf,output_interface.OP output_intf[4]);

Environment env;  //declaring EnV object
small_packet spkt; 

initial
begin
$display(" ******************* Start of testcase ****************");
spkt = new ();
env = new(mem_intf, input_intf, output_intf);
env.build();
env.drvr.gpkt = spkt;
env.reset();
env.cfg_dut();
env.start();
env.wait_for_end();
env.report();

//env.run();

#1000;
end

final
$display(" ******************** End of testcase *****************");

endprogram

`endif
