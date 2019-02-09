# This Dockerfile configures an Arch Linux test environment.
#
# Run the following commands from the project root ./vim-setswitch/.
#
# Create image:
#
#   $ sudo docker build \
#         --tag test-vim-setswitch .
#
# Enter container:
#
#   $ sudo docker run --rm -ti \
#         --hostname archlinux \
#         --name test-vim-setswitch \
#         test-vim-setswitch
#
FROM archlinux/base:latest

# Installs required packages for Vim, Neovim, and plugins.
RUN pacman -Syu --noconfirm sudo vim neovim git autoconf pkgconf make automake gcc tree

ENV HOME /home/user

# Create the user account and set the account password to "user".
RUN useradd --create-home --user-group user \
        && echo 'user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/user \
        && chmod 440 /etc/sudoers.d/user \
        && echo 'user:user' | chpasswd

# Install plugins.
RUN curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
        && git clone https://github.com/universal-ctags/ctags.git "${HOME}/ctags" \
        && cd "${HOME}/ctags" \
        && ./autogen.sh \
        && ./configure \
        && make \
        && make install

# Create configuration directories and copy files over.
COPY . ${HOME}/.vim
RUN mkdir --parents -- "${HOME}/.config" \
        && ln -sf "${HOME}/.vim/test/files/vimrc" "${HOME}/.vimrc" \
        && ln -sf "${HOME}/.vim" "${HOME}/.config/nvim" \
        && ln -sf "${HOME}/.vim/test/files/init.vim" "${HOME}/.vim/init.vim"

# This allows you to run :PlugInstall without entering Vim. See this post:
# https://github.com/junegunn/vim-plug/issues/225
RUN nvim -E -s -u "${HOME}/.vimrc" +PlugInstall +qall
RUN chown --recursive user:user "$HOME"

WORKDIR $HOME
USER user

CMD ["/bin/bash"]
