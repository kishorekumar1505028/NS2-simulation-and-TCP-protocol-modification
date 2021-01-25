BEGIN {
#initialization
	max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;
	
	idHighestPacket = 0;
	idHighestnode = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;

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
#+ 3 0 1 tcp 40 ------- 0 0.0 1.0 0   0
#1 2 3 4 5   6          7   8  9  10 11
	event_type = $1 ;
    event_time = $2 ;
	src_node_id = $3 ;
	dst_node_id = $4 ;				packet_id = $12 ;
	agent_type = $5 ;#tcp or udp
	packet_size = $6;#pkt size
	#keep track of packet with highets and lowest id	
	if ((agent_type == "tcp") || (agent_type == "ack")) {
		if (packet_id > idHighestPacket) idHighestPacket = packet_id;
		if (packet_id < idLowestPacket) idLowestPacket = packet_id;

	#keep track of the time the last packet (with compare to time) has been received and the first packet sent  	
		if(event_time>rEndTime) rEndTime=event_time;
		if(event_time<rStartTime) rStartTime=event_time;
	
	#keep track of total sent packets and sent time
		if ((event_type == "+") && ((agent_type == "tcp") || (agent_type == "ack"))) {
			nSentPackets += 1 ;	rSentTime[ packet_id ] = event_time ;
			if (src_node_id > idHighestnode) idHighestnode = src_node_id;
#			printf("%15.5f\n", nSentPackets);
		}
		if ((event_type == "r") && ((agent_type == "tcp") || (agent_type == "ack"))) {
#		if ( event_type == "r" && packet_id >= idLowestPacket) {
			nReceivedPackets += 1 ;		nReceivedBytes += packet_size;
#			printf("%15.0f\n", packet_size);
			per_node_throughput[src_node_id] += packet_size ;
			rReceivedTime[ packet_id ] = event_time ;
			rDelay[packet_id] = rReceivedTime[ packet_id] - rSentTime[ packet_id ];
#			rTotalDelay += rReceivedTime[ packet_id] - rSentTime[ packet_id ];
			rTotalDelay += rDelay[packet_id]; 
			if (dst_node_id > idHighestnode) idHighestnode = dst_node_id;

#			printf("%15.5f   %15.5f\n", rDelay[packet_id], rReceivedTime[ packet_id] - rSentTime[ packet_id ]);
		}
	}

#store total dropped packtes
	if( (event_type == "d") && ((agent_type == "tcp") || (agent_type == "ack")) )
	{
		if(event_time>rEndTime) rEndTime=event_time;
		if(event_time<rStartTime) rStartTime=event_time;
		nDropPackets += 1;
	}

}

END {
#event_time = totoal time of packet transmission
#rThroughput = bits/time
	event_time = rEndTime - rStartTime ;
	rThroughput = nReceivedBytes*8 / event_time;
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;
	if (idHighestnode<=max_node) max_node =  idHighestnode ;
		for (i=0; i<=max_node; i++) {
		per_node_throughput[i] = per_node_throughput[i]*8/event_time ;
		printf ("%d %15.2f\n",i ,per_node_throughput[i]) ;
	}
	printf ("per node throughput\n") ;
	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
		avg_energy_per_packet = total_energy_consumption / nReceivedPackets ;
	}

#	printf( "AverageDelay: %15.5f PacketDeliveryRatio: %10.2f\n", rAverageDelay, rPacketDeliveryRatio ) ;

#	printf( "%15.2f\n%15.5f\n%10.2f\n%10.2f\n", rThroughput, rAverageDelay, rPacketDeliveryRatio, rPacketDropRatio) ;
#	printf("%15.5f\n%15.5f\n%15.5f\n%15.5f\n%15.0f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit);


#	printf( "%15.2f\n%15.5f\n%15.2f\n%15.2f\n%15.2f\n%15.2f\n%15.2f\n%15.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,event_time) ;
	#printf("%15.5f\n%15.5f\n%15.5f\n%15.5f\n%15.0f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit);


	printf( "Throughput: %15.2f Delay: %15.5f Sent_Pckts: %15.2f Rcvd_Pckts: %15.2f Drop_Pckts: %15.2f Delivery_Ratio: %15.2f Drop_Ratio: %15.2f Time: %15.5f ", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,event_time) ;
#   printf("Total_energy: %15.5f Avg_enr_per_bit: %15.5f Avg_enr_per_byte: %15.5f Avg_enr_per_pckt: %15.5f Total_rexmit: %15.0f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit);


#	printf( "Throughput: %15.2f AverageDelay: %15.5f \nSent Packets: %15.2f Received Packets: %15.2f Dropped Packets: %15.2f \nPacketDeliveryRatio: %10.2f PacketDropRatio: %10.2f\nTotal time: %10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,event_time) ;
#	printf("\n\nTotal energy consumption: %15.5f Average Energy per bit: %15.5f Average Energy per byte: %15.5f Average energy per packet: %15.5f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet);
}


