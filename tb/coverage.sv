`ifndef GUARD_Coverage
`define GUARD_Coverage

class coverage;
    packet_c pkt;


//CREATE A COVERGROUP for all COVERPOINTS
covergroup switch_coverage;

//ADD COVERPOINTS FOR ALL TESTS TO BE COVERED
length       : coverpoint pkt.length;
da           : coverpoint pkt.da {
    bins p0 = {`P0};
    bins p1 = {`P1};
    bins p2 = {`P2};
    bins p3 = {`P3}; }

length_type  : coverpoint pkt.length_type;
fcs_type     : coverpoint pkt.fcs_type;

//CROSS of ALL of Above COVERPOINTS
all_cross    : cross length, da, length_type, fcs_type;
endgroup :  switch_coverage

function new();
    switch_coverage = new();
endfunction: new


//TASK to call the SAMPLE method for coverage group
task sample(packet_c pkt);
    this.pkt=pkt;
    switch_coverage.sample();
endtask: sample


endclass: coverage
`endif
