#!/bin/bash
#begin
extra="per_node_throughput.out";
truncate -s 0 node_wired.out;
truncate -s 0 flow_wired.out;
truncate -s 0 packet_wired.out;
truncate -s 0 per_node_throughput.out;
#variation : 
#no of nodes , no of flows , no of packets , speed/coverage
round=1;
total_round=3;
#in each round a parameter is varied 5 times  
iteration=5;

echo "total round: $total_round"
#-le means less than or equal
while [ $round -le $total_round ]
	do
		echo "                             EXECUTING "$round" th ROUND"
		###############################START A ROUND
		#initialize everything
		#network throughput , end-end delay , packet delivery ratio , packet drop ratio , energy consumption (wireless)
		throughput=0.0;
		delay_end=0.0;
		pckt_delivery_ratio=0.0;
		pckt_drop_ratio=0.0;
		s_packet=0.0;
		r_packet=0.0;
		dr_ratio=0.0; 
		i=1;
		echo "total iteration: $iteration"
		while [ $i -le $iteration ]
			do
				#################START AN ITERATION
				echo "                             EXECUTING "$i" th ITERATION"
				#execute tcl file
				if [ "$round" == "1" ]; then
				#varying number of nodes
				output_file="node_wired.out";
				echo "round is $round";
				#echo "Varying number of nodes round $round iteration $i" >> $output_file;
				n_of_node=$(($i*20));
				echo -n "$n_of_node " >> $output_file
				#echo "nodes number $n_of_node" >> $output_file;
				ns wired.tcl $round $n_of_node
				elif [ "$round" == "2" ]; then
				#varying number of flows
				output_file="flow_wired.out";
				#echo "Varying number of flows round $round iteration $i" >> $output_file;
				n_of_flow=$(($i*10))
				echo -n "$n_of_flow " >> $output_file 
				ns wired.tcl $round $n_of_flow
				elif [ "$round" == "3" ]; then
				#varying number of pckts
				output_file="packet_wired.out";
				#echo "Varying number of packets per second round $round iteration $i" >> $output_file;
				n_of_pckt=$(($i*100)) 
				echo -n "$n_of_pckt " >> $output_file
				ns wired.tcl $round $n_of_pckt
				#elif [ "$round" == 4 ]; then
				#varying speed of nodes
				#speed_of_nodes=$(($i*5)); 
				#ns wired.tcl $i $speed_of_nodes
				#elif [ "$round" == "4" ]; then
				#varying coverage area
				#echo "Varying coverage area round $round iteration $i" >> $output_file
				#coverage_area=$(($i))
				#ns wired.tcl $round $coverage_area
				fi
				echo "SIMULATION COMPLETE. BUILDING STAT......"
				#awk -f rule_th_del_enr_tcp.awk 802_11_grid_tcp_with_energy_random_traffic.tr > math_model1.out
				#execute awk file
				awk -f wired.awk wired.tr > wired.out
				#reading from tcp_wireless.out file
				l=0
				while read val
					do
					#	l=$(($l+$inc))
						l=$(($l+1))
						if [ "$val" == "per node throughput" ]; then
							boundary=$l;
							break;
						fi
					done < wired.out
				echo $boundary
				
				l=0;
				while read val
					do
					#	l=$(($l+$inc))
						l=$(($l+1))
						
						if [ $l -lt $boundary ]; then
							if [[ ($round -eq 1) && ($i -eq 1) ]]; then
							echo $val  >> $extra;
							fi
							
							
						elif [ $l -gt $boundary ]; then
							if [ $l -eq $(( $boundary + 1 )) ]; then
								throughput=$val
								echo -n "$val " >> $output_file
							elif [ $l -eq $(( $boundary + 2 )) ]; then
								delay_end=$val
								echo -n "$val " >> $output_file
							elif [ $l -eq $(( $boundary + 3 )) ]; then
								pckt_delivery_ratio=$val
								echo -n "$val " >> $output_file
							elif [ $l -eq $(( $boundary + 4 )) ]; then
								dr_ratio=$val
								printf "$val\n" >> $output_file;
								
							fi
							echo "";
						fi
					done < wired.out
				#################END AN ITERATION
				i=$(($i+1))
				l=0
			done
			#######################################END A ROUND
			round=$(($round+1))
done
gnuplot -p wired.plt 
echo "the end";
