PROGNAME = main

obj:
	clang \
      -c \
      -S \
      -emit-llvm \
      -fPIC \
      -ffunction-sections \
      $(PROGNAME).c \
      -o $(PROGNAME).bc
base-bin: obj
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < $(PROGNAME).bc \
      > $(PROGNAME)_ls_opt.bc
	llc  \
      $(PROGNAME)_ls_opt.bc \
      -relocation-model=pic \
      -o $(PROGNAME)_ls_opt.s
	g++ \
      $(PROGNAME)_ls_opt.s \
      -o $(PROGNAME)_base \
      -lm -lrt
bc-ics: obj
	llvm-link $(PROGNAME).bc ics.ll -o $(PROGNAME)_ics.bc
bc-opt: bc-ics
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < $(PROGNAME)_ics.bc \
      > $(PROGNAME)_ls_ics_opt.bc
wpd-ics: bc-opt
	opt \
      --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < $(PROGNAME)_ls_ics_opt.bc \
      > $(PROGNAME)_wpd_ics_opt.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis $(PROGNAME)_wpd_ics_opt.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      $(PROGNAME)_wpd_ics_opt.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      $(PROGNAME)_wpd_ics_opt.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      $(PROGNAME)_wpd_ics_opt.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      $(PROGNAME)_wpd_ics_opt.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      $(PROGNAME)_wpd_ics_opt.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      $(PROGNAME)_wpd_ics_opt.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
      --function-sections \
      -always-inline \
      < $(PROGNAME)_wpd_ics_opt.ll \
      > $(PROGNAME)_wpd_ics_opt.bc
	llc  \
      --function-sections \
      $(PROGNAME)_wpd_ics_opt.bc \
      -relocation-model=pic \
      -o $(PROGNAME)_wpd_ics_opt.s
	# Produce a default linker script.
	# FIXME Is there an easier way to do this than building the entire binary here?
	g++ \
      -ffunction-sections \
      -Wl,--verbose \
      $(PROGNAME)_wpd_ics_opt.s \
      -o $(PROGNAME)_wpd_tmp \
      -ldebloat_rt -lm -lrt > linker.lds
	rm $(PROGNAME)_wpd_tmp
	# Create a custom linker script
	python3 linker.py .
	g++ \
      -g \
      -ffunction-sections \
      -c $(PROGNAME)_wpd_ics_opt.s \
      -o $(PROGNAME)_wpd_ics_opt.o
wpd-bin: wpd-ics
	g++ \
      -g \
      -ffunction-sections \
      -T wpd-linker-script.lds \
      $(PROGNAME)_wpd_ics_opt.o \
      -o $(PROGNAME)_wpd \
      -ldebloat_rt -lm -lrt
	readelf -s --wide $(PROGNAME)_wpd > readelf.out                   
	readelf --sections $(PROGNAME)_wpd > readelf-sections.out         
all: base-bin wpd-bin


clean:
	rm -f *.bc *.s a.out *.lds readelf*.out wpd*.txt wpd*.out debrt.out debrt*.out sed_changes*.txt $(PROGNAME)_wpd $(PROGNAME)_wpd_ics_opt.o $(PROGNAME)_wpd_ics_opt.ll $(PROGNAME)_base ics.ll linker.py
.PHONY: clean


