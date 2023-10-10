`ifndef GUARD_PKT
`define GUARD_PKT

typedef enum {Good_fcs, Bad_fcs} fcs_type_id;
typedef enum {Good_length, Bad_length} length_type_id;



class packet_c;

rand fcs_type_id fcs_type;
rand length_type_id length_type;

//defining packet fields now - DA, SA, DATA, Length, FCS
rand bit [7:0] length;
rand bit [7:0] da;
rand bit [7:0] sa;
rand byte data[];
rand byte fcs;


//constraints for above rand vars
constraint add_cons {da inside {`P0, `P1, `P2, `P3};}
constraint data_size{data.size inside {[0:255]};} // accepting data.size == 0 also
constraint length_type_c{
    (length_type == Good_length) -> length==data.size;
    (length_type == Bad_length) -> length== data.size + 3;}

//Using Solve to direct the randomization to generate dynamic data array first
//and then random length
constraint solve_size_length {solve data.size before length;}
constraint fcs_type_c {
    (fcs_type==Good_fcs) -> fcs == 8'b0;
    (fcs_type==Bad_fcs)  -> fcs == 8'b1;} //TODO  make bad_fcs as a dist

function byte calc_fcs;
    byte calc;
    calc = 0;
    calc = calc ^ da;
    calc = calc ^ sa;
    calc = calc ^ length;
    foreach(data[i])   //TODO check for loop
    calc = calc ^ data[i];
    calc = fcs ^ calc;
    return calc;      //sending calclulated FCS result
endfunction: calc_fcs


//PACKET DATA DISPLAY METHOD
virtual function void display();

$display("\n---------------------- PACKET KIND ------------------------- ");
$display(" fcs_type : %s ",fcs_type.name() );
$display(" length_type : %s ",length_type.name() );
$display("-------- PACKET ---------- ");
$display(" 0 : %h ",da);
$display(" 1 : %h ",sa);
$display(" 2 : %h ",length);
foreach(data[i])
 $write("%3d : %0h ",i + 3,data[i]);
$display("\n %2d : %h ",data.size() + 3 , calc_fcs);
$display("----------------------------------------------------------- \n");
endfunction : display

//Method to pack the packet into bytes array
virtual function int unsigned byte_pack(ref logic[7:0] bytes[]);
    bytes = new[data.size+4];
    bytes[0] = da;
    bytes[1] = sa;
    bytes[2] = length;
    foreach(data[i])
    bytes[3+i] = data[i];
    bytes[data.size()+3] = calc_fcs; //calling calculate FCS method
    byte_pack = bytes.size;          //Byte_pack stores final bytes size
endfunction : byte_pack

//Method to unpack the bytes into packet
virtual function void byte_unpack(const ref logic[7:0] bytes[]); // ref is used for pointer... const ref will not modify the array for outised variable
this.da = bytes[0];
this.sa = bytes[1];
this.length = bytes[2];
this.fcs = bytes[bytes.size-1];
this.data = new[bytes.size -4];

foreach(data[i])
data[i] = bytes[i+3];
this.fcs = 8'b0;                //TODO FCS issue Checkpoint
if(bytes[bytes.size -1] != calc_fcs)
    this.fcs = 8'b1;
endfunction: byte_unpack


//COMPARE method - Method to compare the packets
virtual function bit compare(packet_c pkt);    
    compare = 1;
    if(pkt == null)
    begin
    $display(" ** ERROR ** : pkt : received a null object ");
    compare = 0;
    end
    else
    begin
    if(pkt.da !== this.da)
    begin
    $display(" ** ERROR **: pkt : Da field did not match");
    compare = 0;
    end
    if(pkt.sa !== this.sa)
    begin
    $display(" ** ERROR **: pkt : Sa field did not match");
    compare = 0;
    end
    
    if(pkt.length !== this.length)
    begin
    $display(" ** ERROR **: pkt : Length field did not match");
    compare = 0;
    end
    foreach(this.data[i])
    if(pkt.data[i] !== this.data[i])
    begin
    $display(" ** ERROR **: pkt : Data[%0d] field did not match",i);
    compare = 0;
    end
    
    if(pkt.fcs !== this.fcs)
    begin
    $display(" ** ERROR **: pkt : fcs field did not match %h %h",pkt.fcs ,this.fcs);
    compare = 0;
    end
    end
endfunction: compare    
    
    

endclass: packet_c
 

`endif
