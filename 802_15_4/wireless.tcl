################################################################802.15.4 mobile
#traffic attributes
set packet_size 20
set packet_tx_rate 250Kb
#offline variable parameters default
set number_of_nodes 100 ;
set number_of_flows 10 ;
set number_of_packets 50 ;
set speed 10 ;
#############################################handling  arguments
set var_num [expr [lindex $argv 0]]

if {$var_num ==1} {
	set number_of_nodes [expr [lindex $argv 1]];
} elseif {$var_num ==2} {
	set number_of_flows [expr [lindex $argv 1]];
} elseif {$var_num ==3} {
	set number_of_packets [expr [lindex $argv 1]];
} elseif {$var_num ==4} {
	set speed [expr [lindex $argv 1]];
}

###################setting rows and columns
set num_of_col 10 ;
set num_of_row [expr $number_of_nodes / 10];
#handling corner cases
if {$num_of_row ==0} {
 set num_of_col [expr $number_of_nodes] ;
 set num_of_row 1;
}

if {$number_of_flows > [expr $number_of_nodes /2]} {
 puts "val [expr $number_of_nodes /2]";
 set number_of_flows [expr $number_of_nodes /2] ;
}

#network size and event parameters
set dst_between_2_nodes 5
set x_dim 50;
set y_dim 50;
set time_duration 50
set start_time 3
set node_size 3
set start_gap 0.5

puts "number of nodes $number_of_nodes\n number of columns $num_of_col\n number of rows $num_of_row\nnumber of flows $number_of_flows\n"
puts "range $x_dim m $y_dim m\n";

#defining distances ; e.g 5m means 7.69113e-06
set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07 ;

##########################################################  mobile node diagram   ##################################### 
#										     ->ARP
#										    |	
#channel <--> netif <--> MAC <--> IFq <--> LL <-- RTAgent <-- Agent
#			  |           |				   ^
#			  |			  |                |
#			  v		      ------------------
#			radio prop. model

#The function of class Channel is to deliver packets from a wireless node to its neighbors within sensing range
set val(chan) Channel/WirelessChannel ;# channel type -Physcal layer

#Netif - Hardware interface used by mobilenode to access the channel
#The function of class WirelessPhy is to send packets to Channel and receive packet from Channel
set val(netif) Phy/WirelessPhy/802_15_4 ;# network interface type -Physcal layer

#When the receiving power Pr is less than CSThresh_ (carrier sense threshold), the receiver cannot sense the packet; 
#Otherwise, the receiver can sense the packet and it can further decode (receive) it when Pr > RXThresh_ (i.e.
#reception threshold, which is > CSThresh_).
Phy/WirelessPhy set CSThresh_ $dist(40m) ; #-Physcal layer
Phy/WirelessPhy set RXThresh_ $dist(40m) ; #-Physcal layer

#Radio Propagation Model decides whether the packet can be received by the mobilenode with given distance,
#transmit power and wavelength
set val(prop) Propagation/TwoRayGround ;# radio-propagation model / (1/r^4)

#Radio Propagation Model implements Omni Directional Antenna module which has unity gain for all directions
set val(ant) Antenna/OmniAntenna ;# antenna model

set val(mac) Mac/802_15_4 ;# MAC type -Mac layer
#set val(mac) SMac/802_15_4 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ifqlen) 100 ;# max number of packets in ifq
set val(rp) AODV ;# routing protocol for ad hoc network - network layer
set val(nn) $number_of_nodes
set val(x) $x_dim
set val(y) $y_dim
set val(energymodel) EnergyModel;
set val(initialenergy) 100;
######################################### Initialize ns
set ns_ [new Simulator]

################################################## necessary files #############################################
# nam for animation , tr for tracing and txt for saving topology
set nam_file wireless.nam
set tr wireless.tr
set topo_file_txt wireless.txt

#setting trace file
set tracefd [open $tr w]
$ns_ trace-all $tracefd
#$ns_ use-newtrace ;# use the new wireless trace file format

#setting nam file
set namtrace [open $nam_file w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

#setting txt file
set topofiletxt [open $topo_file_txt "w"] ;
#congestion xgraph
set outfile [open  "congestion.xg"  w]


$ns_ color 0 red 
$ns_ color 1 blue
$ns_ color 2 green

# set up topography object
#and define it in x_dim x y_dim area
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
#$topo load_flatgrid 1000 1000

#God is used to store an array of the shortest number of hops
#required to reach from one node to another
#For example:$ns_ at 899.00 “$god_ setdist 2 3 1
create-god $val(nn)


#with an ad hoc network the topology may be changing all the time
#nodes can come and go or appear in new places at the drop of a bit
#DSDV, DSR, AODV, TORA are routing protocols for ad hoc network
$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) \
	     -macType $val(mac)  -ifqType $val(ifq) \
	     -ifqLen $val(ifqlen) -antType $val(ant) \
	     -propType $val(prop) -phyType $val(netif) \
	     -channel  [new $val(chan)] -topoInstance $topo \
	     -agentTrace ON -routerTrace OFF \
	     -macTrace OFF \
	     -movementTrace OFF \
         -energyModel $val(energymodel) \
         -initialEnergy $val(initialenergy) \
         -rxPower 35.28e-3 \
         -txPower 31.32e-3 \
	     -idlePower 712e-6 \
	     -sleepPower 144e-9 ;

 
#create  nodes : node_0 , node_1 , node_2 ... node_98 , node_99
#setting number of nodes in a column
for {set i 0} {$i <$number_of_nodes} {incr i} {
	set node_($i) [$ns_ node]
}
#setting up node parameters
#setting up x , y , z positions of each node
#setting up node parameters
#setting up x , y , z positions of each node

for {set i 0} {$i < $num_of_row} {incr i} {
	
	for {set j 0} {$j < $num_of_col } {incr j} {
	
	set m [expr $i*$num_of_col + $j];# nodes are indexed as 0 , 1 , 2 ; 10 , 11 , 12 
	puts "m is $m and i is $i and j is $j\n";

	set x_pos [expr $dst_between_2_nodes * $j];
	set y_pos [expr $dst_between_2_nodes * $i];
	
	#X_ , Y_ and Z_ are parameters of class node
	#$object_name set parameter value
	$node_($m) set X_ $x_pos;
	$node_($m) set Y_ $y_pos;
	$node_($m) set Z_ 0;
	$node_($m) color "blue" ;
	$node_($m) color "green" ;
	$node_($m) color "red" ;
	$node_($m) random-motion 0;
	puts "node_ $m's value: $node_($m)"
	puts -nonewline $topofiletxt "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
    }
    
}
#Define node initial position in nam
for {set i 0} {$i < $number_of_nodes} { incr i } {
	$ns_ initial_node_pos $node_($i) $node_size
}

######################################### Transport Layer (TCP)###############################

#####################################creating tcp sources and sinks####################
#setting agent  as TCP , an agent for each node
#tcp_0 , tcp_1 , tcp_2 are sources
#null_0 , null_1 , null_2 are sinks
for {set i 0} {$i < $number_of_flows} { incr i } {
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]
	set tcp_($i) [new Agent/TCP/Newreno] ; #define src
	$tcp_($i) set class_ $i ; # set value of parameter class_ as i
	#when we have different flows , we distinguish them by their fid_
	#$tcp_($i) set fid_ $i  ;#set fid_ as i
	$tcp_($i) set fid_ [expr $i %3];
	set null_($i) [new Agent/TCPSink] ; #define sink
	$ns_  at  0.0  "plotWindow $tcp_($i)  $outfile"
} 

########################### connecting agents with nodes #####################################
#n = number of flows
#tcp =  i
#tcp sink = i+1
#attach agent : node_i <--> tcp_k
#attach agent : node_i+1 <--> null_k
#tcp src : i NULL dest: i + 1
#chng
set n 0;
for {set i 0} {$i < $number_of_flows } {incr i} {

	set tcp_node_idx $n;
	set null_node_idx [expr $n+1];
	$ns_ attach-agent $node_($tcp_node_idx) $tcp_($i);
  	$ns_ attach-agent $node_($null_node_idx) $null_($i);
    set  n [expr $n + 2];
 
	puts -nonewline $topofiletxt "tcp Src: $tcp_node_idx NULL Dest: $null_node_idx\n";

}
puts "[expr $i] flows have been created\n";

##########################set connections between sources and sinks#########################
for {set i 0} {$i < $number_of_flows } {incr i} {
     $ns_ connect $tcp_($i) $null_($i)
}

######################################### Application Layer(CBR)###############################
#traffic sources : cbr_0 , cbr_1 , cbr_2 
for {set i 0} {$i < $number_of_flows } {incr i} {
	set cbr_($i) [new Application/FTP] ; # traffic source
	#$cbr_($i) set type_ $traffic_type
	$cbr_($i) set packetSize_ $packet_size;
	$cbr_($i) set rate_ $packet_tx_rate;
	#$cbr_($i) set interval_ 1;
	$cbr_($i) set interval_ [expr 1 / double($number_of_packets)];#number of packets sent per second = 1 / interval
	$cbr_($i) attach-agent $tcp_($i) ; # attaching agent for each traffic source
} 

######################################### Event Scheduling##################################
######################################starting flows
set n 0 ;
for {set i 0} {$i < $number_of_flows } {incr i} {
	$ns_ at [expr $start_time + $i*0.5] "$cbr_($i) start" ;
	set j [expr $n +1];
	if { [expr $n%3] == 0} {
		$ns_ at [expr $start_time + $i*0.5] "$node_($n) color blue";
		$ns_ at [expr $start_time + $i*0.5] "$node_($j) color blue";
		
		
	} elseif { [expr $n%3] == 1} {
		$ns_ at [expr $start_time + $i*0.5] "$node_($n) color green";
		$ns_ at [expr $start_time + $i*0.5] "$node_($j) color green";

	} else {
		$ns_ at [expr $start_time + $i*0.5] "$node_($n) color red";
		$ns_ at [expr $start_time + $i*0.5] "$node_($j) color red";
	}
	set  n [expr $n + 2];
    
}
#######################random motion#########################
for {set i 0} {$i < $number_of_nodes } {incr i} {
$ns_ at [expr $start_time + $number_of_flows*$start_gap+ $i*$start_gap] "$node_($i) setdest [expr $x_dim*rand()] [expr $y_dim*rand()] $speed"
}
###########################reset#############################
for {set i 0} {$i < $number_of_nodes } {incr i} {
set reset_time [expr $start_time + $number_of_flows*$start_gap + $time_duration];
}
puts "reset_time $reset_time \n" ;
#################################### Tell nodes when the simulation ends

for {set i 0} {$i < $number_of_nodes } {incr i} {
    $ns_ at [expr $reset_time] "$node_($i) reset";
    #$ns_ at [expr $reset_time+8.0] "$node_([expr $i + 10]) reset";
}
$ns_ at [expr $reset_time +5.0] "finish"
$ns_ at [expr $reset_time +5.0] "$ns_ nam-end-wireless [$ns_ now]"
$ns_ at [expr $reset_time +5.01] "puts \"NS Exiting...\"; $ns_ halt"

################plot congestion window
proc plotWindow {tcpSource outfile} {
   global ns_
   set now [$ns_ now]
   set cwnd [$tcpSource set cwnd_]

# the data is recorded in a file called congestion.xg (this can be plotted # using xgraph or gnuplot. this example uses xgraph to plot the cwnd_
   puts  $outfile  "$now $cwnd"
   $ns_ at [expr $now+0.1] "plotWindow $tcpSource  $outfile"
}





proc finish {} {
	global ns_ tracefd namtrace topofiletxt nam_file
	#global ns_ topofiletxt
	$ns_ flush-trace
	close $tracefd
	close $namtrace
	close $topofiletxt
        #exec nam $nam_file &
        #exec xgraph congestion.xg -geometry 300x300 &
        exit 0
}

#set opt(mobility) "position.txt"
#source $opt(mobility)
#set opt(traff) "traffic.txt"
#source $opt(traff)

#for {set i 0} {$i < [expr $num_of_row*$num_of_col]  } { incr i} {
#	$ns_ initial_node_position $node_($i) 20
#}

puts "Starting Simulation..."
$ns_ run 
#$ns_ nam-end-wireless [$ns_ now]

