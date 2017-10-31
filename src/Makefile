all:
	bnfc Instant.cf
	happy -gca ParInstant.y
	alex -g LexInstant.x
	ghc --make JVM.hs
	ghc --make LLVM.hs
clean:
	-rm -f *.log *.aux *.hi *.o *.dvi
distclean: clean
	-rm -f DocInstant.* LexInstant.* ParInstant.* LayoutInstant.* SkelInstant.* PrintInstant.* TestInstant.* AbsInstant.* TestInstant ErrM.* SharedString.* ComposOp.* Instant.dtd 