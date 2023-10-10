`ifndef GUARD_SCOREBOARD
`define GUARD_SCOREBOARD


class scoreboard;

mailbox drvr2sb;
mailbox rcvr2sb;
coverage cov = new();

function new(mailbox drvr2sb, mailbox rcvr2sb);
    this.drvr2sb = drvr2sb;
    this.rcvr2sb = rcvr2sb;
endfunction: new


task start();
    packet_c pkt_rcv;
    packet_c pkt_snt;
    forever
    begin
        pkt_snt = new ();
        pkt_rcv = new();
        rcvr2sb.get(pkt_rcv);
        $display("%0d : ScoreBoard : Scoreboard received a packet from receiver", $time);
        drvr2sb.get(pkt_snt);
        if(pkt_rcv.compare(pkt_snt))
        begin
            $display("%0d : ScoreBoard : *****Packet Matched*****", $time);
            cov.sample(pkt_snt);            //Sampling the coverage obj
        end
        else
            error++;
    end
endtask: start


endclass: scoreboard




`endif
