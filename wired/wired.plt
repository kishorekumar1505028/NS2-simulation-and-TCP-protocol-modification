set title "Throughput vs Number of nodes\n"
set xlabel "number of nodes"
set ylabel "throughput"
set grid
set term png
set output 'thr_vs_num_of_nodes.png'
plot 'node_wired.out' u (column(1)):2 with linespoints ls 1 title""


set title "Throughput vs Number of flows\n"
set xlabel "number of flows"
set ylabel "throughput"
set grid
set term png
set output 'thr_vs_num_of_flow.png'
plot 'flow_wired.out' u (column(1)):2 with linespoints ls 1 title""

set title "Throughput vs Number of packets\n"
set xlabel "number of packets/sec"
set ylabel "throughput"
set grid
set term png
set output 'thr_vs_num_of_packet.png'
plot 'packet_wired.out' u (column(1)):2 with linespoints ls 1 title""




set title "Delay vs Number of nodes\n"
set xlabel "number of nodes"
set ylabel "Delay"
set grid
set term png
set output 'delay_vs_num_of_nodes.png'
plot 'node_wired.out' u (column(1)):3 with linespoints ls 1 title""


set title "Delay vs Number of flows\n"
set xlabel "number of flows"
set ylabel "Delay"
set grid
set term png
set output 'delay_vs_num_of_flow.png'
plot 'flow_wired.out' u (column(1)):3 with linespoints ls 1 title""

set title "Delay vs Number of packets\n"
set xlabel "number of packets/sec"
set ylabel "Delay"
set grid
set term png
set output 'delay_vs_num_of_packet.png'
plot 'packet_wired.out' u (column(1)):3 with linespoints ls 1 title""



set title "Delivery_ratio vs Number of nodes\n"
set xlabel "number of nodes"
set ylabel "Delivery_ratio"
set grid
set term png
set output 'Delivery_ratio_vs_num_of_nodes.png'
plot 'node_wired.out' u (column(1)):4 with linespoints ls 1 title""


set title "Delivery_ratio vs Number of flows\n"
set xlabel "number of flows"
set ylabel "Delivery_ratio"
set grid
set term png
set output 'Delivery_ratio_vs_num_of_flow.png'
plot 'flow_wired.out' u (column(1)):4 with linespoints ls 1 title""

set title "Delivery_ratio vs Number of packets\n"
set xlabel "number of packets/sec"
set ylabel "Delivery_ratio"
set grid
set term png
set output 'Delivery_ratio_vs_num_of_packet.png'
plot 'packet_wired.out' u (column(1)):4 with linespoints ls 1 title""

set title "Drop_ratio vs Number of nodes\n"
set xlabel "number of nodes"
set ylabel "Drop_ratio"
set grid
set term png
set output 'Drop_ratio_vs_num_of_nodes.png'
plot 'node_wired.out' u (column(1)):5 with linespoints ls 1 title""


set title "Drop_ratio vs Number of flows\n"
set xlabel "number of flows"
set ylabel "Drop_ratio"
set grid
set term png
set output 'Drop_ratio_vs_num_of_flow.png'
plot 'flow_wired.out' u (column(1)):5 with linespoints ls 1 title""

set title "Drop_ratio vs Number of packets\n"
set xlabel "number of packets/sec"
set ylabel "Drop_ratio"
set grid
set term png
set output 'Drop_ratio_vs_num_of_packet.png'
plot 'packet_wired.out' u (column(1)):5 with linespoints ls 1 title""

set title "Per node throughput\n"
set xlabel "node_id/sec"
set ylabel "Throughput"
set grid
set term png
set output 'per_node_throughput.png'
plot 'per_node_throughput.out' u (column(1)):2 with linespoints ls 1 title""
