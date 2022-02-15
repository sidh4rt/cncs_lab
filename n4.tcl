set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround 
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqlen) 50
set val(nn) 2
set val(rp) DSDV
set val(x) 700
set val(y) 444
set val(stop) 10.0

set ns [new Simulator]
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

set tracefile [open out.tr w]
$ns trace-all $tracefile

set namfile [open out.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];

$ns node-config         -adhocRouting           $val(rp)\
                        -llType                 $val(ll)\
                        -macType                $val(mac)\
                        -ifqType                $val(ifq)\
                        -ifqLen                 $val(ifqlen)\
                        -antType                $val(ant)\
                        -propType               $val(prop)\
                        -phyType                $val(netif)\
                        -channel                $chan\
                        -topoInstance           $topo\
                        -agentTrace             ON\
                        -routerTrace            ON\
                        -macTrace               ON\
                        -movementTrace          ON

set n0 [$ns node]
$n0 set X_ 268
$n0 set Y_ 339
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 428
$n1 set Y_ 344
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20

$ns at .1 " $n0 setdest 600 344 100 "
$ns at .1 " $n1 setdest 300 339 100 "

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 1.0 "$ftp0 start"
$ns at 5.0 "$ftp0 stop"

proc finish {} {
global ns tracefile namfile
$ns flush-trace
close $tracefile
close $namfile
exec nam out.nam &
exit 0
}

for {set i 0} {$i < $val(nn) } { incr i } {
$ns at $val(stop) "\$n$i reset"
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run



AWK:



BEGIN{
count=0;
total=0;
}
{
event=$1;
if(event=="D"){
count++;
}
}
END{
printf("No. of packets dropped: %d \n",count);
}

Execution:
ns n3.tcl
awk -f n3.awk 4.tr
