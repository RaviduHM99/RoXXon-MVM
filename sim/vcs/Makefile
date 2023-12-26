all:	clean comp run
clean:
	\rm -rf simv* csrc* *.log
#comp: #AXI Stream compilation
#	vcs  -sverilog -full64 -kdb -debug_access+all ../../rtl/p2s.sv ../p2s_tb.sv  -l comp.log 
comp: #Uart RX compilation
	vcs  -sverilog -full64 -kdb -debug_access+all ../../rtl/uart_rx.sv ../uart_rx_tb.sv  -l comp.log 
run:
	./simv -verdi -l run.log