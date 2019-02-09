#
# Common Makefile, defines the list of tests to run. These variables are put in a separate
# file so that tests for bufswitch.vim may be extended to run on other operating systems.
#

# Options for protecting the tests against undesirable interaction with the environment.
# NO_PLUGINS = --noplugin
NO_INITS = -U NONE $(NO_PLUGINS)

# Tests using runtest.vim. Make sure tests are sorted in alphabetical order.
TESTS = \
	test_setswitch.res \
	test_nerdtree_compatibility.res \
	test_tagbar_compatibility.res
