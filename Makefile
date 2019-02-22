#
# This makefile can perform the following options:
# - builds the Docker container
# - Run the Makefile in the ./vim-setswitch/test directory
#

.PHONY: test build $(wildcard docker/*)

# People may configure Docker differently: requiring sudo, or adding their user to the
# "docker" group. This Makefile assumes you haven't added your user to the "docker" group,
# requiring you to prepend your docker commands with "sudo". If you have added your user
# to the docker group then you have a couple of options to run this Makefile. You can
# either change the following variable definition to "docker := docker". Alternatively,
# run make with the "-e" option, like so:
#
# 	make -e docker='docker'
#
docker := sudo docker

# The name of the Docker tag.
tag := test-vim-setswitch

default: docker/test

test:
	$(MAKE) --directory=$@ $(TARGET)

exec = ${docker} exec -ti ${tag} /bin/bash

# The build instructions are complex, but worth it. It provides the ability to work on the
# plugin in the test environment.
build:
ifneq ($(shell ${docker} inspect --format "{{.State.Running}}" ${tag} 2>/dev/null),true)
	${docker} build --tag ${tag} .
	${docker} run \
		--tmpfs /run \
		--tmpfs /run/lock \
		--volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
		--detach --tty \
		--volume $(shell pwd)/plugin:/home/root/.vim/plugin \
		--volume $(shell pwd)/doc:/home/root/.vim/doc \
		--volume $(shell pwd)/test:/home/root/.vim/test \
		--hostname centos-7 \
		--name ${tag} \
		${tag}
	${exec} './.vim/test/files/linker.bash'
endif

# Run one of the following two commands to execute tests inside Vim or Neovim, respectively:
#
#     $ make docker/vim
#     $ make docker/nvim
#
docker/%:
	@/bin/sh -c 'if test $(@F) != vim -a $(@F) != nvim; then exit 1; fi'
	$(MAKE) build
	${exec} -c 'cd ./.vim/test && make $(@F)'

docker/test: build
	${exec} -c 'cd ./.vim/test && { make; make nvim; }'

clean:
ifeq ($(shell ${docker} inspect --format "{{.State.Running}}" ${tag} 2>/dev/null),true)
	${docker} container stop ${tag}
	${docker} rm ${tag}
endif

cleanall: clean
	${docker} image rm ${tag}
