SRCS = src/pc.v src/i_mem.v src/d_mem.v src/regfile.v \
       src/ula.v src/ula_ctrl.v src/ctrl.v src/mips_top.v

all:
	mkdir -p sim
	iverilog -o sim/mips.out tb/tb_mips_top.v $(SRCS)
	vvp sim/mips.out

wave:
	gtkwave sim/mips.vcd

clean:
	rm -f sim/*.out sim/*.vcd
