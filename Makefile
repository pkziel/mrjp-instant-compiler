all:
	chmod +x insc_jvm
	chmod +x insc_llvm
	make -C src
clean:
	make clean -C src
distclean:
	make distclean -C src		
