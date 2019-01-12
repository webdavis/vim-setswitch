# -*- mode: ruby -*-
# vi:filetype=ruby shiftwidth=4 softtabstop=4:

# The plugin vbguest is installed and will provision guest virtual machines with the
# host's VirtualBox Guest Additions file VBoxGuestAdditions.iso automagically.
#
# Assuming you have the virtualbox-guest-utils package installed (consult your operating
# system for the appropriate package name) VBoxGuestAdditions.iso can be found in the
# following places depending on your operating system:
# - Most Linux distributions -- /opt/VirtualBox/VBoxGuestAdditions.iso
# - Arch Linux -- /usr/lib/virtualbox/additions/VBoxGuestAdditions.iso
# - MacOS -- /Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso
# - Windows -- C:\Program files\Oracle\VirtualBox/VBoxGuestAdditions.iso
#
# After running 'vagrant up' you will need to run the following commands to correctly
# provision your system:
#
#       vagrant vbguest ArchLinux-setswitch --do install --no-cleanup
#       vagrant ssh -c 'yes | sudo /mnt/VBoxLinuxAdditions.run' ArchLinux-setswitch
#       vagrant reload ArchLinux-setswitch
#
# ArchLinux-setswitch can be substituted with the machine of your choice.
# VBoxLinuxAdditions.run can be substituted with the following:
# - VBoxSolarisAdditions.pkg
# - VBoxWindowsAdditions.exe
# - VBoxWindowsAdditions-x86.exe
# - VBoxWindowsAdditions-amd64.exe

# Vagrant machines for Linux app testing.
VAGRANTFILE_API_VERSION = '2'
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # Run vbguest on all guest machines. This is 'true' by default. Set this to false to
    # prevent the plugin 'vbguest' from running.
    # config.vbguest.auto_update = false
    config.vm.provider :virtualbox do |vb|
        vb.memory = 512
        # CPU cores.
        vb.cpus = 1
        # Vagrant exposes a way to call any command against VBoxManage just prior to
        # booting the machine: the 'id' parameter is replaced with the ID of the virtual
        # machine being created, so when a VBoxManage command requires an ID, you can pass
        # this special parameter.
        vb.customize ['modifyvm', :id, '--ioapic', 'on']
    end

    # Ubuntu 16.04 box.
    config.vm.define 'Ubuntu-1604-setswitch' do |os|
        # config.vm.provider :virtualbox do |v|
        #     v.gui = true
        # end
        os.vm.box = 'bento/ubuntu-16.04'
        os.vm.hostname = 'Ubuntu-1604-setswitch'
        os.vm.provision 'updates', type: 'shell', inline: 'apt-get update', privileged: true
        os.vm.provision 'git', type: 'shell', inline: 'apt-get install -y git', privileged: true
        os.vm.provision 'plug', type: 'shell', inline: $provision_plug, name: 'provision_plug', privileged: false
        os.vm.provision 'setswitch', type: 'shell', inline: $provision_setswitch, name: 'provision_setswitch', privileged: false
        os.vm.provision 'vimrc', type: 'shell', inline: $provision_vimrc, name: 'provision_vimrc', privileged: false
        os.vm.provision 'nvimrc', type: 'shell', inline: $provision_nvimrc, name: 'provision_nvimrc', privileged: false
        os.vm.provision 'vim', type: 'shell', inline: 'apt-get install -y vim', privileged: true
        os.vm.provision 'nvim', type: 'shell', inline: $ubuntu_neovim, privileged: true
        os.vm.provision 'desktop', type: 'shell', inline: 'apt-get install -y gnome-shell', privileged: true
    end

    # CentOS 7 box.
    config.vm.define 'CentOS7-setswitch' do |os|
        # config.vm.provider :virtualbox do |v|
        #     v.gui = true
        # end
        os.vm.box = 'bento/centos-7'
        os.vm.hostname = 'CentOS7-setswitch'
        os.vm.provision 'updates', type: 'shell', inline: 'yum update -y', privileged: true
        os.vm.provision 'git', type: 'shell', inline: 'yum install -y git', privileged: true
        os.vm.provision 'plug', type: 'shell', inline: $provision_plug, name: 'provision_plug', privileged: false
        os.vm.provision 'setswitch', type: 'shell', inline: $provision_setswitch, name: 'provision_setswitch', privileged: false
        os.vm.provision 'vimrc', type: 'shell', inline: $provision_vimrc, name: 'provision_vimrc', privileged: false
        os.vm.provision 'nvimrc', type: 'shell', inline: $provision_nvimrc, name: 'provision_nvimrc', privileged: false
        os.vm.provision 'vim', type: 'shell', inline: 'yum install -y vim', privileged: true
        os.vm.provision 'nvim', type: 'shell', inline: $centos_neovim, privileged: true
        os.vm.provision 'desktop', type: 'shell', inline: $centos_desktop, privileged: true
    end

    # Arch Linux box.
    config.vm.define 'Arch-Linux-setswitch', primary: true do |os|
        # config.vm.provider :virtualbox do |v|
        #     v.gui = true
        # end
        os.vm.box = 'archlinux/archlinux'
        os.vm.hostname = 'Arch-Linux-setswitch'
        os.vm.provision 'updates', type: 'shell', inline: 'pacman -Syu --noconfirm', privileged: true
        os.vm.provision 'git', type: 'shell', inline: 'pacman -S --noconfirm git', privileged: true
        os.vm.provision 'vim', type: 'shell', inline: 'pacman -S --noconfirm vim', privileged: true
        os.vm.provision 'nvim', type: 'shell', inline: 'pacman -S --noconfirm neovim', privileged: true
        os.vm.provision 'vimrc', type: 'shell', inline: $provision_vimrc, name: 'provision_vimrc', privileged: false
        os.vm.provision 'nvimrc', type: 'shell', inline: $provision_nvimrc, name: 'provision_nvimrc', privileged: false
        os.vm.provision 'plug', type: 'shell', inline: $provision_plug, name: 'provision_plug', privileged: false
        os.vm.provision 'setswitch', type: 'shell', inline: $provision_setswitch, name: 'provision_setswitch', privileged: false
        os.vm.provision 'ctags', type: 'shell', inline: $provision_ctags, name: 'provision_ctags', privileged: false
        # os.vm.provision 'desktop', type: 'shell', inline: $archlinux_desktop, privileged: true
    end
end

$provision_vimrc = <<-'EOP'
[[ -d "${HOME}/.vim" ]] || mkdir -- "${HOME}/.vim"
ln -sf '/vagrant/test/vm-env/vimrc' "${HOME}/.vimrc"
EOP

$provision_nvimrc = <<-'EOP'
[[ -d "${HOME}/.vim" ]] || mkdir -- "${HOME}/.vim"
ln -sf '/vagrant/test/vm-env/vimrc' "${HOME}/.vimrc"

[[ -d "${HOME}/.config" ]] || mkdir -- "${HOME}/.config"
ln -sf "${HOME}/.vim" "${HOME}/.config/nvim"
ln -sf '/vagrant/test/vm-env/init.vim' "${HOME}/.vim/init.vim"
EOP

$provision_plug = <<-'EOP'
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
EOP

$provision_ctags = <<-'EOP'
sudo pacman --sync --noconfirm autoconf pkgconf make automake gcc
git clone https://github.com/universal-ctags/ctags.git ~/ctags
cd ~/ctags
./autogen.sh
./configure
make
sudo make install
EOP

$provision_setswitch = <<-'EOP'
[[ -d "${HOME}/.vim" ]] || mkdir -p -- "${HOME}/.vim"
ln -sf '/vagrant/doc' "${HOME}/.vim/doc"
ln -sf '/vagrant/plugin' "${HOME}/.vim/plugin"
ln -sf '/vagrant/test' "${HOME}/.vim/test"
EOP

$archlinux_desktop = <<-'EOP'
if [[ -x "$(command -v vim)" ]]; then pacman --remove --nosave --unneeded --noconfirm vim; fi

pacman --sync --noconfirm gvim xorg xorg-xinit gnome
systemctl enable gdm.service
EOP
