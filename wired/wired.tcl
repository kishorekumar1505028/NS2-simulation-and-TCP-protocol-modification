################################################################wired point-point link
#traffic attributes
set traffic_type CBR
set packet_size 20
set packet_tx_rate 250Kb
set queue_max 20
#offline variable parameters
set number_of_nodes 30 ;
set number_of_flows 10 ;
set number_of_packets 50 ;
set tx_range 50 ;

#############################################handling  arguments
set var_num [expr [lindex $argv 0]]

if {$var_num ==1} {
	set number_of_nodes [expr [lindex $argv 1]];
} elseif {$var_num ==2} {
	set number_of_flows [expr [lindex $argv 1]];
} elseif {$var_num ==3} {
	set number_of_packets [expr [lindex $argv 1]];
} elseif {$var_num ==4} {
	#set tx_range [expr $tx_range * [lindex $argv 1]];
}

#set x_dim $tx_range;
#set y_dim $tx_range;
set time_duration 50
set start_time 3
set node_size 10
set start_gap 0.5


######################################### Initialize ns
set ns_ [new Simulator]

################################################## necessary files #############################################
# nam for animation , tr for tracing and txt for saving topology
set nam_file wired.nam
set tr wired.tr
set topo_file_txt wired.txt

#setting trace file
set tracefd [open $tr w]
$ns_ trace-all $tracefd

#setting nam file
set namtrace [open $nam_file w]
$ns_ namtrace-all $namtrace

#setting txt file
set topofiletxt [open $topo_file_txt "w"] ;


# set up topography object
#and define it in x_dim x y_dim area
#set topo       [new Topography]
#$topo load_flatgrid $x_dim $y_dim
#$topo load_flatgrid 1000 1000

#God is used to store an array of the shortest number of hops
#required to reach from one node to another
#For example:$ns_ at 899.00 “$god_ setdist 2 3 1
#create-god $number_of_nodes
#############################creating nodes#############################
puts "start node creation"
for {set i 0} {$i < $number_of_nodes} {incr i} {
	set node_($i) [$ns_ node]
}
#############################creating duplex links############################

puts "creating link"
for {set i 0} { $i < $number_of_nodes } {incr i} {
	#puts "$i $j" < output.txt ;
	set j [expr ($i+1) % $number_of_nodes];
	
	if { $i < [expr $number_of_nodes /2]} {
	
	set k [expr ($i+($number_of_nodes /2)) % $number_of_nodes];
	$ns_ duplex-link $node_($i) $node_($k) 1Mb 10ms DropTail; #capacity prop. delay queue type
	puts -nonewline $topofiletxt "link between $i $k\n" ; 
	}
	
	puts -nonewline $topofiletxt "link between $i $j\n" ; 
    $ns_ duplex-link $node_($i) $node_($j) 1Mb 10ms DropTail; #capacity prop. delay queue type
    #$ns_ queue-limit $node_($n) $node_($j) 20;
    
}

######################################### Transport Layer (TCP)###############################

#####################################creating tcp sources and sinks####################
#setting agent  as TCP , an agent for each node
#tcp_0 , tcp_1 , tcp_2 are sources
#null_0 , null_1 , null_2 are sinks
for {set i 0} {$i < $number_of_flows} { incr i } {
	set tcp_($i) [new Agent/TCP] ; #define src
	$tcp_($i) set class_ $i ; # set value of parameter class_ as i
	#when we have different flows , we distinguish them by their fid_
	$tcp_($i) set fid_ [expr $i %3];
	set null_($i) [new Agent/TCPSink] ; #define sink
} 

########################### connecting agents with nodes (flows) #####################################
#n = number of flows
#tcp =  i
#tcp sink = i+1
#attach agent : node_i <--> tcp_k
#attach agent : node_i+1 <--> null_k
#tcp src : i NULL dest: i + 1
#chng

set random_flag 1;
set n 0 ;
#fixed
for {set i 0} { ($i < $number_of_flows) && ($random_flag==0) } {incr i} {

	set tcp_node_idx $n;
	set null_node_idx [expr ($n+1) % $number_of_nodes];
	$ns_ attach-agent $node_($tcp_node_idx) $tcp_($i);
  	$ns_ attach-agent $node_($null_node_idx) $null_($i);
    set n [expr $n + 2];
  	
	puts -nonewline $topofiletxt "tcp Src: $tcp_node_idx NULL Dest: $null_node_idx\n";

}

#random
for {set i 0} { ($i < $number_of_flows) && ($random_flag==1)} {incr i} {

	set nsrc 0 ;
	set nsink 0 ;
    while {$nsrc == $nsink} {
 	set nsrc [expr (int (rand() * $number_of_nodes)) % $number_of_nodes] ;
	set nsink [expr (int(rand() * $number_of_nodes)) % $number_of_nodes] ;
	}
	set tcp_node_idx [expr $nsrc];
	set null_node_idx [expr $nsink];
	$ns_ attach-agent $node_($tcp_node_idx) $tcp_($i);
  	$ns_ attach-agent $node_($null_node_idx) $null_($i);
  	
	puts -nonewline $topofiletxt "tcp Src: $tcp_node_idx NULL Dest: $null_node_idx\n";

	
}
puts "[expr $i] flows have been created\n";

##########################set connections between sources and sinks#########################
for {set i 0} {$i < $number_of_flows } {incr i} {
     $ns_ connect $tcp_($i) $null_($i)
}

######################################### Application Layer(CBR)###############################
#traffic sources : ftp_0 , ftp_1 , ftp_2 
for {set i 0} {$i < $number_of_flows } {incr i} {
	set ftp_($i) [new Application/FTP] ; # traffic source
	$ftp_($i) set packetSize_ $packet_size;
	$ftp_($i) set rate_ $packet_tx_rate;
	#$ftp_($i) set interval_ 1;
	$ftp_($i) set interval_ [expr 1 / double($number_of_packets)];#number of packets sent per second = 1 / interval
	$ftp_($i) attach-agent $tcp_($i) ; # attaching agent for each traffic source
} 
######################################### Event Scheduling##################################
######################################starting flows
for {set i 0} {$i < $number_of_flows } {incr i} {
	$ns_ at [expr $start_time] "$ftp_($i) start" ;    
}

###########################reset#############################
set reset_time [expr $start_time + 100];
puts "reset_time $reset_time \n" ;

for {set i 0} {$i < $number_of_nodes } {incr i} {
    $ns_ at [expr $reset_time] "$node_($i) reset";
}
#################################### Tell nodes when the simulation ends
$ns_ at [expr $reset_time +5.0] "finish"
$ns_ at [expr $reset_time +5.01] "puts \"NS Exiting...\"; $ns_ halt"

proc finish {} {
	global ns_ tracefd namtrace topofiletxt nam_file
	#global ns_ topofiletxt
	$ns_ flush-trace
	close $tracefd
	close $namtrace
	close $topofiletxt
        #exec nam $nam_file &
        exit 0
}



puts "Starting Simulation..."
$ns_ run

