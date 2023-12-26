all:	clean comp run
clean:
	\rm -rf simv* csrc* *.log
comp:
	vcs  -sverilog -full64 -kdb -debug_access+all ../../rtl/p2s.sv ../p2s_tb.sv  -l comp.log 
run:
	./simv -verdi -l run.log