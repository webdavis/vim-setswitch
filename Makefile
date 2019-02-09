#
# This makefile can perform the following options:
# - builds the Docker container
# - Run the Makefile in the ./vim-setswitch/test directory
#

.PHONY: test build $(wildcard docker/*)

# The name of the Docker tag.
tag = test-vim-setswitch

default: docker/test

test:
		$(MAKE) --directory=$@ $(TARGET)

build:
ifneq ($(shell sudo docker inspect --format "{{.State.Running}}" ${tag} 2>/dev/null),true)
		sudo docker build --tag ${tag} .
		sudo docker run -d -ti --hostname archlinux --name ${tag} ${tag}
endif

exec := sudo docker exec -ti ${tag} /bin/bash -c

# Run one of the following two commands to execute tests inside Vim or Neovim, respectively:
#
#     $ make docker/vim
#     $ make docker/nvim
#
docker/%: build
		@/bin/sh -c 'if test $(@F) != vim -a $(@F) != nvim; then exit 1; fi'
		${exec} 'cd .vim/test && make $(@F)'

docker/test: build
		${exec} 'cd .vim/test && { make; make nvim; }'

clean:
		sudo docker container stop ${tag}
		sudo docker rm ${tag}
