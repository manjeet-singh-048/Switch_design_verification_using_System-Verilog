`ifndef GUARD_TESTCASE
`define GUARD_TESTCASE

program test();

packet_c pkt1 = new();
packet_c pkt2 = new();
logic [7:0] bytes[];

initial
repeat(15) 
if(pkt1.randomize)
begin
    $display(" ******************* Start of Packet testcase ****************");
    $display(" Randomization successful ");
    pkt1.display();
    pkt1.byte_pack(bytes);
    pkt2.byte_unpack(bytes);
    
    if(pkt2.compare(pkt1))
        $display("Packing...UnPacking.... Compare Successfull");
    else
        $display("Something went wrong during Packing/unpacking/Compare");
end

else 
    $display("Randomization Failed Miserably");


endprogram


`endif
