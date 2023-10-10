`ifndef GUARD_ENV
`define GUARD_ENV

class Environment ;

virtual mem_interface.MEM mem_intf;
virtual input_interface.IP input_intf;
virtual output_interface.OP output_intf[4];

driver drvr;
receiver rcvr[4]; //4 rcvr objects since 4 ports
scoreboard sb;
mailbox drvr2sb;
mailbox rcvr2sb;

function new(virtual mem_interface.MEM mem_intf_new, virtual input_interface.IP input_intf_new ,
virtual output_interface.OP output_intf_new[4] );

    this.mem_intf = mem_intf_new;
    this.input_intf = input_intf_new;
    this.output_intf = output_intf_new;
    $display("%0d: Environment: created env object",$time);
    endfunction :   new


function void build();
    $display(" %0d : Environment : start of build() method",$time);
    drvr2sb = new();
    drvr    = new(input_intf, drvr2sb);
    rcvr2sb = new();
    sb      = new(drvr2sb, rcvr2sb);
    foreach(rcvr[i])
    rcvr[i] = new(output_intf[i],rcvr2sb);
    $display(" %0d : Environment : end of build() method",$time);
endfunction :build

task reset();
    $display(" %0d : Environment : start of reset() method",$time);
    //mem intf signals setting to a value
    mem_intf.cb.mem_data <=0;
    mem_intf.cb.mem_add <=0;
    mem_intf.cb.mem_en <=0;
    mem_intf.cb.mem_rd_wr <=0;
    //input intf signals
    input_intf.cb.data_status <=0;
    input_intf.cb.data_in <=0;
    //output intf signals
    output_intf[0].cb.read <=0;
    output_intf[1].cb.read <=0;
    output_intf[2].cb.read <=0;
    output_intf[3].cb.read <=0;
    //Reset the DUT
    input_intf.reset<=1;
    repeat(4) @ input_intf.clock;
    input_intf.reset <= 0;
    $display(" %0d : Environment : end of reset() method",$time);
endtask : reset

task cfg_dut();
    $display(" %0d : Environment : start of cfg_dut() method",$time);

    // Configuring the DUT Signals
    mem_intf.cb.mem_en <=1;
    @(posedge mem_intf.clock);      //$display($time);
    mem_intf.cb.mem_rd_wr <=1;
    //Just setting add & data values for all combinations
    @(posedge mem_intf.clock);      //$display($time);
    mem_intf.cb.mem_add <= 8'h0;
    mem_intf.cb.mem_data <= `P0;
    $display(" %0d : Environment : Port 0 Address %h ",$time,`P0);    
    @(posedge mem_intf.clock);
    mem_intf.cb.mem_add <= 8'h1;
    mem_intf.cb.mem_data <= `P1;
    $display(" %0d : Environment : Port 1 Address %h ",$time,`P1);    
    @(posedge mem_intf.clock);
    mem_intf.cb.mem_add <= 8'h2;
    mem_intf.cb.mem_data <= `P2;
    $display(" %0d : Environment : Port 2 Address %h ",$time,`P2);
    @(posedge mem_intf.clock);
    mem_intf.cb.mem_add <= 8'h3;
    mem_intf.cb.mem_data <= `P3;
    $display(" %0d : Environment : Port 3 Address %h ",$time,`P3);    
    //Rolling back to reset values
    @(posedge mem_intf.clock);
    mem_intf.cb.mem_en <=0;
    mem_intf.cb.mem_rd_wr <= 0;
    mem_intf.cb.mem_add <= 0;
    mem_intf.cb.mem_data <= 0;
    $display(" %0d : Environment : end of cfg_dut() method",$time);
endtask : cfg_dut

task start();
    $display(" %0d : Environment : start of start() method",$time);
    fork
    drvr.start();
    rcvr[0].start();
    rcvr[1].start();
    rcvr[2].start();
    rcvr[3].start();
    sb.start();
    join_any
    $display(" %0d : Environment : end of start() method",$time);
endtask : start

task wait_for_end();
    $display(" %0d : Environment : start of wait_for_end() method",$time);
    repeat(5000) @(input_intf.clock);
    $display(" %0d : Environment : end of wait_for_end() method",$time);
endtask : wait_for_end



task run();
    $display(" %0d : Environment : start of run() method",$time);
    build();
    reset();
    cfg_dut();
    start();
    wait_for_end();
    report();
    $display(" %0d : Environment : end of run() method",$time);
endtask : run

//TEST PASS?FAIL based on error var
task report();
    $display("\n\n**************************************");
    if(0 == error) //DONT Worry This is just to prevent accidental assignment
        $display("****** TEST PASSED *******");
    else
        $display("****** TEST Failed with %0d Errors", error);
    $display("******************************************\n\n");
endtask : report

endclass : Environment

`endif    
