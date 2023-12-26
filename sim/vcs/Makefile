all:	clean comp run
clean:
	\rm -rf simv* csrc* *.log
#compile AXIS:
#	vcs  -sverilog -full64 -kdb -debug_access+all ../../rtl/p2s.sv ../p2s_tb.sv  -l comp.log 
compile UART_RX:
	vcs  -sverilog -full64 -kdb -debug_access+all ../../rtl/uart_rx.sv ../uart_rx_tb.sv  -l comp.log 
run:
	./simv -verdi -l run.log