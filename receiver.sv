`ifndef GUARD_RECEIVER
`define GUARD_RECEIVER

class receiver;

virtual output_interface.OP output_intf;
mailbox rcvr2sb;

//Constructor
function new(virtual output_interface.OP output_intf_new, mailbox rcvr2sb);
    this.output_intf = output_intf_new;
    if(rcvr2sb == null)
    begin
        $display("ERROR : rcvr2sb is null");
        $finish;
    end
    else
        this.rcvr2sb = rcvr2sb;
endfunction: new


//START METHOD- wait for rdy to be asserted by DUT
task start();
    logic [7:0] bytes[]; //create bytes array
    packet_c pkt;        //create a packet obj
    forever
    begin
    repeat(2) @(posedge output_intf.clock);
    wait(output_intf.cb.ready);
    output_intf.cb.read         <= 1;
    repeat(2) @(posedge output_intf.clock);
    while (output_intf.cb.ready)
    begin
        bytes = new[bytes.size + 1](bytes);
        bytes[bytes.size - 1] = output_intf.cb.data_out;
        @(posedge output_intf.clock);
    end
    output_intf.cb.read         <=0; //DEASSERT READ signal
    @(posedge output_intf.clock);
    $display("%0d : Receiver : Received a packet of length %0d", $time, bytes.size); //TODO check why bytes size id > by 1
    pkt = new();
    pkt.byte_unpack(bytes);
    pkt.display();
    //send the packet to Score Board also
    rcvr2sb.put(pkt);
    bytes.delete(); //delete the dyn array
    end

endtask :start


endclass : receiver
`endif
