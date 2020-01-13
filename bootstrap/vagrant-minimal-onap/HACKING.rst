=========================
 Development environment
=========================

Modifications made within this environment focus mainly on adjusting environment and override files
[#]_ located in `oom` repository. This repository is cloned to the Operator's machine and used
during initial provisioning. Editing said files on the host machine (instead of using remote editor
within `vagrant ssh operator` or Emacs TRAMP) requires synchronizing them from guest (operator) to
host using reverse_ SSHFS [#]_.

When Operator's machine is up, repository content is available in `./oom` directory on the host. It
vanishes if machine is halted, but then it is no longer relevant.

.. [#] Used by `helm deploy` command
.. [#] Other mechanisms_ considered: rsync (unidirectional, synchronized on machine reload) and NFS
       (requires privilege_ elevation to edit host configuration files for synchronization)

.. _reverse: https://github.com/dustymabe/vagrant-sshfs#options-specific-to-reverse-mounting-guesthost-mount
.. _mechanisms: https://github.com/vagrant-libvirt/vagrant-libvirt#synced-folders
.. _privilege: https://www.vagrantup.com/docs/synced-folders/nfs.html
