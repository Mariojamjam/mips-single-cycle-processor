SRCS = src/pc.v src/i_mem.v src/d_mem.v src/regfile.v \
       src/ula.v src/ula_ctrl.v src/ctrl.v src/mips_top.v

all:
	#quick visual run with the lightweight wave-oriented bench
	mkdir -p sim
	iverilog -o sim/mips.out tb/tb_mips_wave.v $(SRCS)
	vvp sim/mips.out

wave:
	#same flow as all, but already pops GTKWave open at the end
	mkdir -p sim
	iverilog -o sim/mips.out tb/tb_mips_wave.v $(SRCS)
	vvp sim/mips.out
	gtkwave sim/mips_wave.vcd

clean:
	rm -f sim/*.out sim/*.vcd
