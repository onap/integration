==================
Installation Guide
==================

This project collects instructions related to the automatic creation
of a development environment. However, this requires only two
components previous to its execution.  These are an automation
building tool (Vagrant) and a provider platform (VirtualBox, Libvirt
and OpenStack). This section explains how to install the most common
set of configuration(Vagrant/VirtualBox) in different Operating
Systems.

Ubuntu 14.04 ("Trusty")
-----------------------

.. code-block:: console

    $ wget -q https://releases.hashicorp.com/vagrant/1.9.7/vagrant_1.9.7_x86_64.deb
    $ sudo dpkg -i vagrant_1.9.7_x86_64.deb
    $ echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" >> /etc/apt/sources.list
    $ wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    $ wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    $ sudo apt-get update -y
    $ sudo apt-get install -y virtualbox-5.1 dkms

.. end

CentOS
------

.. code-block:: console

    $ wget -q https://releases.hashicorp.com/vagrant/1.9.7/vagrant_1.9.7_x86_64.rpm
    $ sudo yum install vagrant_1.9.7_x86_64.rpm
    $ wget -q http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo -P /etc/yum.repos.d
    $ sudo yum --enablerepo=epel install dkms
    $ wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | rpm --import -
    $ sudo yum install VirtualBox-5.1

.. end

Mac OS
------

.. code-block:: console

    $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    $ brew cask install vagrant
    $ brew cask install virtualbox

.. end

Windows 7+ (PowerShell v2+)
---------------------------

.. code-block:: console

    PS C:\> Set-ExecutionPolicy AllSigned
    PS C:\> iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    PS C:\> choco install vagrant
    PS C:\> choco install virtualbox

.. end
