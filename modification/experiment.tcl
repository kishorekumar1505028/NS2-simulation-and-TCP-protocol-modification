set number_of_nodes 10
set ns [new Simulator]
create-god $number_of_nodes       
################################################## necessary files #############################################
# nam for animation , tr for tracing and txt for saving topology
set nam_file experiment.nam
set tr experiment.tr
set topo_file_txt experiment.txt

#setting trace file
set tracefd [open $tr w]
$ns trace-all $tracefd
#$ns use-newtrace ;# use the new wireless trace file format

#setting nam file
set namtrace [open $nam_file w]
$ns namtrace-all $namtrace

#setting txt file
set topofiletxt [open $topo_file_txt "w"] ;
#congestion xgraph
set outfile [open  "congestion.xg"  w]
#to create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
$ns color 0 red 
$ns color 1 blue
$ns color 2 green
$ns color 3 yellow

	
# to create the link between the nodes with bandwidth, delay and queue
$ns duplex-link $n2 $n0 10Mb  2ms DropTail
$ns duplex-link $n3 $n0 10Mb  2ms DropTail
$ns duplex-link $n4 $n0 10Mb  2ms DropTail
$ns duplex-link $n5 $n0 10Mb  2ms DropTail

$ns duplex-link $n0 $n1 1.5Mb  50ms DropTail

$ns duplex-link $n6 $n1 10Mb  2ms DropTail
$ns duplex-link $n7 $n1 10Mb  2ms DropTail
$ns duplex-link $n8 $n1 10Mb  2ms DropTail
$ns duplex-link $n9 $n1 10Mb  2ms DropTail

$ns duplex-link-op $n2 $n0 orient left-up
$ns duplex-link-op $n3 $n0 orient left-up
$ns duplex-link-op $n4 $n0 orient left-down
$ns duplex-link-op $n5 $n0 orient left-down

$ns duplex-link-op $n1 $n0 orient left

$ns duplex-link-op $n6 $n1 orient right-up
$ns duplex-link-op $n7 $n1 orient right-up
$ns duplex-link-op $n8 $n1 orient right-down
$ns duplex-link-op $n9 $n1 orient right-down


$ns duplex-link-op $n6 $n1  color "green"
$ns duplex-link-op $n7 $n1  color "blue"
$ns duplex-link-op $n8 $n1  color "yellow"
$ns duplex-link-op $n9 $n1  color "red"

$ns duplex-link-op $n2 $n0  color "green"
$ns duplex-link-op $n3 $n0  color "blue"
$ns duplex-link-op $n4 $n0  color "yellow"
$ns duplex-link-op $n5 $n0  color "red"

# Sending node is 0 with agent as Reno Agent
#set tcp_(1) [new Agent/TCP/Newreno]
set tcp_(1) [new Agent/TCP]
set tcp_(2) [new Agent/TCP]
set tcp_(3) [new Agent/TCP]
set tcp_(4) [new Agent/TCP]

$ns attach-agent $n2 $tcp_(1)
$ns attach-agent $n3 $tcp_(2)
$ns attach-agent $n4 $tcp_(3)
$ns attach-agent $n5 $tcp_(4)



set sink_(1) [new Agent/TCPSink]
set sink_(2) [new Agent/TCPSink]
set sink_(3) [new Agent/TCPSink]
set sink_(4) [new Agent/TCPSink]

$ns attach-agent $n6 $sink_(1)
$ns attach-agent $n7 $sink_(2)
$ns attach-agent $n8 $sink_(3)
$ns attach-agent $n9 $sink_(4)

$ns connect $tcp_(1) $sink_(1)
$ns connect $tcp_(2) $sink_(2)
$ns connect $tcp_(3) $sink_(3)
$ns connect $tcp_(4) $sink_(4)

# Setup a FTP traffic generator on "tcp1"
set t 1 ;
for {set i 1} {$i <= 4 } {incr i} {
set ftp_($i) [new Application/FTP]
$ftp_($i) attach-agent $tcp_($i)
$ns at 0.0 "$ftp_($i) start" 
$ftp_($i) set fid_ $i
}
# start/stop the traffic

$ns  at  0.0  "plotWindow $tcp_(1)  $outfile"
#$ns  at  0.0  "plotWindow $tcp_(1)  $outfile2"
# Set simulation end time
$ns at 50.0 "finish"            
# procedure to plot the congestion window
proc plotWindow {tcpSource outfile} {
   global ns
   set now [$ns now]
   set cwnd [$tcpSource set cwnd_]

# the data is recorded in a file called congestion.xg (this can be plotted # using xgraph or gnuplot. this example uses xgraph to plot the cwnd_
   puts  $outfile  "$now $cwnd"
   $ns at [expr $now+0.1] "plotWindow $tcpSource  $outfile"
}
proc finish {} {
	global ns tracefd namtrace topofiletxt nam_file
	#global ns topofiletxt
	$ns flush-trace
	close $tracefd
	close $namtrace
	close $topofiletxt
	 exec xgraph congestion.xg -geometry 300x300 &
        exec nam $nam_file &
        exit 0
}

# Run simulation 
$ns run
