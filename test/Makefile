#
# This Makefile runs all setswitch tests for Vim and Neovim.
#

# Use Vim or Neovim.
VIMPROG = vim
NVIMPROG = nvim

.PHONY: default $(VIMPROG) $(NVIMPROG) log clean cleanall report test

default: $(VIMPROG)

# Test files should be appended to the TESTS variable in this file.
include Make_all.mak

$(VIMPROG): PROG = $(VIMPROG)
$(VIMPROG): RUN_PROG_TEST = $(PROG) -Nu setup.vim $(NO_INITS)
$(VIMPROG): clean test log report

$(NVIMPROG): PROG = $(NVIMPROG)
$(NVIMPROG): RUN_PROG_TEST = $(PROG) -Nu setup.vim $(NO_INITS) --headless 2>/dev/null
$(NVIMPROG): clean test log report

log:
	@/bin/sh -c 'if grep --quiet --no-messages "FAILED" messages; then \
			if ! test -d ./logs; then mkdir -- logs; fi; \
			cp messages logs/setswitch-$(PROG)-`date --iso-8601=seconds`.log; \
		fi'

clean:
	-rm -f --verbose *.res messages

cleanall: clean
	-rm -rf --verbose logs

# Limitation: these tests only work if Vim/Neovim has been compiled with the +eval
# feature. To check run the following in Vim/Neovim:
#
#     :echo has('eval')
#
# If a 1 (true) was echoed then Vim/Neovim has been compiled with the +eval feature.
report:
	@/bin/sh -c 'if test -f messages; then cat messages; \
			echo -en "\\nTest results: "; \
			if grep --quiet --no-messages "FAILED" messages; then echo "FAILED"; exit 1; \
			else echo "SUCCESS"; fi; \
		fi'

test: $(TESTS)

# This is a pattern rule that defines an implicit rule to make .res files from .vim
# files. To create new tests create a file "*.vim", e.g. test_file1.vim and place it in
# the same directory as this Makefile. Then add the test file name to the TESTS variable
# in the Make_all.mak file, replacing the .vim file extension with .res, like so:
#
#     TESTS = test_file1.res test_file2.res
#
# After `make` is run, two files: test_file1.res and test_file2.res will be in created in
# the same directory as this Makefile.
%.res :: %.vim
	@echo "$(PROG)" > vimcmd
	@echo "$(RUN_PROG_TEST)" >> vimcmd
	$(RUN_PROG_TEST) -S runtests.vim $<
	@rm vimcmd

# vim: tabstop=8 shiftwidth=8 softtabstop=8
