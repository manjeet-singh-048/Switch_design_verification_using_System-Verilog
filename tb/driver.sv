`ifndef GUARD_DRIVER
`define GUARD_DRIVER

//`include "../Global.sv"
class driver;
packet_c gpkt;

virtual input_interface.IP input_intf;

mailbox drvr2sb;  //send packets to Scoreboard from driver

function new(virtual input_interface.IP input_intf_new, mailbox drvr2sb);
    this.input_intf = input_intf_new;
    if(drvr2sb == null)
    begin
        $display("ERROR: drvr2sb is null");
        $finish;
     end 
     else
         this.drvr2sb =drvr2sb;
     gpkt = new ();

 endfunction : new

//Method to send the packet to DUT
task start();
    packet_c pkt;
    logic[7:0] bytes[];
    int length;
    repeat(num_of_pkts)
    begin
    repeat(3) @(posedge input_intf.clock);
    pkt = new gpkt;
    //Randomize the packet now
    if (pkt.randomize())
    begin
         $display("%0d: Driver:  Randomization successful ", $time);
         pkt.display();
         length = pkt.byte_pack(bytes);
         //assert the data status signal & send the packed bytes ( data_status
         //& data are two signals at the input
         foreach(bytes[i])
         begin
         @(posedge input_intf.clock);
         input_intf.cb.data_status <=1;
         input_intf.cb.data_in <= bytes[i];
         end
    //DeASSERT the data status signal
         @(posedge input_intf.clock);
         input_intf.cb.data_status <=0;
         input_intf.cb.data_in <=0;

    //Send the same packet to mailbox to Scoreboard
         drvr2sb.put(pkt);
         $display("%0d : Driver : finished driving the packet with length = %0d",$time, length);
    end
    else
    begin
         $display("%0d: Randomization Failed Miserably", $time);
         error++;
    end
    end
endtask: start

endclass: driver

`endif
