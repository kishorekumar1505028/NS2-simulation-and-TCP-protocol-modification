BEGIN {
#initialization
	max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;
	
	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;
	idHighestnode = 0;

	nDropPackets = 0.0;

	total_energy_consumption = 0;

	temp = 0;
	
	for (i=0; i<max_node; i++) {
		energy_consumption[i] = 0;		
	}
	for (i=0; i<max_node; i++) {
		per_node_throughput[i] = 0;		
	}
	
	total_retransmit = 0;
	for (i=0; i<max_pckt; i++) {
		retransmit[i] = 0;		
	}

}

{
#s 100.0000000 _0_ AGT  --- 286 tcp 40 [0 0 0 0] [energy 911.457859 ei 88.185 es 0.000 et 0.022 er 0.335] ------- [0:0 20:0 32 0] [0 0] 0 0
#1 2           3   4    5   6   7   8  9.....12   13      14       15   16   17   18  19  20   21  22     23      24   25  26 27 28 29 30 31

#evnet/ starttime/ node_id/ Applayer/--- packet id/ Agent/packet size/---- [a b c d] / [energy/total energy/ei/idle energy/es/sleep energy/et/transmit energy/er/receive energy]/--- [ip:port of src/ ip:port of dest /ip header TTL/next hop] [tcp sequence number/ack number] [?/number of retransmit]
														#a -- the packet duration in mac layer header
														#b -- the mac address of destination
														#c -- the mac address of source
														#d -- the mac type of the packet body

#	event = $1;    time = $2;    node_id = $3;    type = $4;    reason = $5;    node_id 2 = $5;    
#	packetid = $6;    mac_sub_type=$7;    size=$8;    source = $11;    dest = $10;    energy=$14;

	event_type = $1 ;			event_time = $2 ;
	node_id = $3 ;
	traffic_type = $4 ;			packet_id = $6 ;
	agent_type = $7 ;#tcp or udp
	packet_size = $8;#pkt size

	energy = $13;			
	total_energy = $14;
	idle_energy_consumption = $16;
	sleep_energy_consumption = $18; 
	transmit_energy_consumption = $20;
	receive_energy_consumption = $22; 
	num_retransmit = $30;
	
	
#eliminating _ and _ from _node_idid_
	sub(/^_*/, "", node_id);
	sub(/_*$/, "", node_id);
	node_id = int (node_id) ;
#add all energy consumptions
	if (energy == "[energy") {
		energy_consumption[node_id] = (idle_energy_consumption + sleep_energy_consumption + transmit_energy_consumption +receive_energy_consumption);
		#printf("%d %15.5f\n", node_id, energy_consumption[node_id]);
	}
#print Droppped packets
	if(energy == "[energy" && event_type == "D") {
		#printf("%s %15.5f %d %s %15.5f %15.5f %15.5f %15.5f %15.5f \n", event_type, event_time, packet_id, energy, total_energy, idle_energy_consumption, sleep_energy_consumption, transmit_energy_consumption, receive_energy_consumption);
		temp+=1;
	}

#AGT over TCP
	if ( traffic_type == "AGT"   &&   agent_type == "tcp" ) {
	#keep track of packet with highets and lowest id
		if (packet_id > idHighestPacket) idHighestPacket = packet_id;
		if (packet_id < idLowestPacket) idLowestPacket = packet_id;

	#keep track of the time the last packet (with compare to time) has been received and the first packet sent  	
		if(event_time>rEndTime) rEndTime=event_time;
		if(event_time<rStartTime) rStartTime=event_time;
#keep track of total sent packets and sent time
		if ( event_type == "s" &&   agent_type == "tcp" ) {
			nSentPackets += 1 ;	rSentTime[ packet_id ] = event_time ;
			#if (node_id > idHighestnode) idHighestnode = node_id;
#			printf("%15.5f\n", nSentPackets);
		#per_node_throughput[node_id] += packet_size ;
		}
		if ( event_type == "r" ) {
#keep track of total packets and bytes , received time , delay and total delay that have been sent by some node_id
#		if ( event_type == "r" && packet_id >= idLowestPacket) {
			nReceivedPackets += 1 ;		nReceivedBytes += packet_size;
#			printf("%15.0f\n", packet_size);
			rReceivedTime[ packet_id ] = event_time ;
			rDelay[packet_id] = rReceivedTime[ packet_id] - rSentTime[ packet_id ];
#			rTotalDelay += rReceivedTime[ packet_id] - rSentTime[ packet_id ];
			rTotalDelay += rDelay[packet_id]; 
			#printf ("cc %d ",node_id) ;
			if (node_id > idHighestnode) idHighestnode = node_id;
			#printf ("%d\n" ,idHighestnode) ;
			per_node_throughput[node_id] += packet_size ;

#			printf("%15.5f   %15.5f\n", rDelay[packet_id], rReceivedTime[ packet_id] - rSentTime[ packet_id ]);
		}
	}

#store total dropped packtes
	if( event_type == "D"   &&   agent_type == "tcp" )
	{
		if(event_time>rEndTime) rEndTime=event_time;
		if(event_time<rStartTime) rStartTime=event_time;
		nDropPackets += 1;
	}

#stores retransmitted packts' retransmission number
	if( agent_type == "tcp" )
	{
#		printf("%d \n", packet_id);
#		printf("%d %15d\n", packet_id, num_retransmit);
		retransmit[packet_id] = num_retransmit;		
	}
}

END {
#event_time = totoal time of packet transmission
#rThroughput = bits/time
	event_time = rEndTime - rStartTime ;
	rThroughput = nReceivedBytes*8 / event_time;
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;

	for(i=0; i<max_node;i++) {
#		printf("%d %15.5f\n", i, energy_consumption[i]);
		total_energy_consumption += energy_consumption[i];
	}
	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
		avg_energy_per_packet = total_energy_consumption / nReceivedPackets ;
	}

	if ( nReceivedBytes != 0 ) {
		avg_energy_per_byte = total_energy_consumption / nReceivedBytes ;
		avg_energy_per_bit = avg_energy_per_byte / 8;
	}

	for (i=0; i<max_pckt; i++) {
		total_retransmit += retransmit[i] ;		
#		printf("%d %15.5f\n", i, retransmit[i]);
	
	}

	if ( idHighestnode < max_node ) {
	max_node =  idHighestnode ;
	}
	for (i=0; i<=idHighestnode; i++) {
		per_node_throughput[i] = per_node_throughput[i]*8/event_time ;
		printf ("%d %15.2f\n",i ,per_node_throughput[i]) ;
	}
		printf ("per node throughput\n") ;	

#	printf( "AverageDelay: %15.5f PacketDeliveryRatio: %10.2f\n", rAverageDelay, rPacketDeliveryRatio ) ;

#	printf( "%15.2f\n%15.5f\n%15.2f\n%15.2f\n%15.2f\n%10.2f\n%10.2f\n%10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,event_time) ;
#	printf("%15.5f\n%15.5f\n%15.5f\n%15.5f\n%15.0f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit);


#	printf( "%15.2f\n%15.5f\n%15.2f\n%15.2f\n%15.5f\n", rThroughput, rAverageDelay, rPacketDeliveryRatio, rPacketDropRatio,total_energy_consumption) ;
	#printf("%15.5f\n%15.5f\n%15.5f\n%15.5f\n%15.0f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit);


	printf( "Throughput: %15.2f Delay: %15.5f Sent_Pckts: %15.2f Rcvd_Pckts: %15.2f Drop_Pckts: %15.2f Delivery_Ratio: %15.2f Drop_Ratio: %15.2f Time: %15.5f ", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,event_time) ;
#	printf("Total_energy: %15.5f Avg_enr_per_bit: %15.5f Avg_enr_per_byte: %15.5f Avg_enr_per_pckt: %15.5f Total_rexmit: %15.0f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit);


#	printf( "Throughput: %15.2f AverageDelay: %15.5f \nSent Packets: %15.2f Received Packets: %15.2f Dropped Packets: %15.2f \nPacketDeliveryRatio: %10.2f PacketDropRatio: %10.2f\nTotal time: %10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,event_time) ;
#	printf("\n\nTotal energy consumption: %15.5f Average Energy per bit: %15.5f Average Energy per byte: %15.5f Average energy per packet: %15.5f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet);
}


