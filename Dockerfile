# This Dockerfile configures an CentOS 7 test environment.
#
# Run the following commands from the project root folder vim-setswitch/.
#
# Create image:
#
#   $ sudo docker build \
#         --tag test-vim-setswitch .
#
# Enter container:
#
#   $ sudo docker run --rm -ti \
#         --hostname centos-7 \
#         --name test-vim-setswitch \
#         test-vim-setswitch
#
FROM centos:latest
ENV container docker

#########################################################################################
# Note! Layers are not condensed on-purpose. This will never be reimaged and having
# separate layers aids debugging in TravisCI.
#########################################################################################

# Fixes the PID 1 zombie reaping problem. Read the following resources in their respective
# order:
# - https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/
# - https://developers.redhat.com/blog/2016/09/13/running-systemd-in-a-non-privileged-container/
# - https://github.com/solita/docker-systemd
# Fixing this ensures the proper propagation of signals to the init process (systemd).
RUN find /etc/systemd/system \
        /lib/systemd/system \
        -path '*.wants/*' \
        -not -name '*journald*' \
        -not -name '*systemd-tmpfiles*' \
        -not -name '*systemd-user-sessions*' \
        -exec rm \{} \;
RUN /usr/bin/systemctl set-default multi-user.target

# Systemd expects SIGRTMIN+3 from `docker stop` to gracefully shutdown.
STOPSIGNAL SIGRTMIN+3

ENV HOME /home/localuser

RUN yum update -y
RUN /usr/bin/systemctl enable systemd-user-sessions.service

RUN useradd --create-home localuser
RUN echo 'localuser:localuser' | chpasswd
RUN echo 'localuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/localuser
RUN chmod 440 /etc/sudoers.d/localuser

# Installs required packages for Vim, Neovim, and dependencies for Vim plugins compatible
# with vim-setswitch.
RUN curl -o /etc/yum.repos.d/dperson-neovim-epel-7.repo https://copr.fedorainfracloud.org/coprs/dperson/neovim/repo/epel-7/dperson-neovim-epel-7.repo
RUN yum install -y epel-release
RUN yum install -y sudo vim-X11 neovim git autoconf pkgconfig make automake gcc tree
RUN git clone https://github.com/universal-ctags/ctags.git "${HOME}/ctags"
WORKDIR "${HOME}/ctags"
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install
RUN chown --recursive localuser:localuser "$HOME"

# Run inside an unprivileged user account to mimic the real world usage.
USER localuser

# Ensure Plug, a Vim plugin manager is installed.
RUN curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

WORKDIR $HOME

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/sbin/init"]
