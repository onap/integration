#!/bin/bash

export VAGRANT_DEFAULT_PROVIDER=libvirt

source /etc/os-release || source /usr/lib/os-release
case ${ID,,} in
    *suse)
    ;;
    ubuntu|debian)
    # vagrant-libvirt dependencies
    sudo apt-get install -y qemu libvirt-bin ebtables dnsmasq libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev

    # NFS
    sudo apt-get install -y nfs-kernel-server
    ;;
    rhel|centos|fedora)
    PKG_MANAGER=$(which dnf || which yum)
    sudo $PKG_MANAGER install -y qemu libvirt libvirt-devel ruby-devel gcc qemu-kvm
    ;;
esac
vagrant plugin install vagrant-libvirt
