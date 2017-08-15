First off, thank you for considering contributing to ONAP on Vagrant project.
It's people like you that make it such a great tool.

ONAP on Vagrant is an open source project and we love to receive contributions
from our community — you! There are many ways to contribute, from writing
tutorials or blog posts, improving the documentation, submitting bug reports and
feature requests or writing code which can be incorporated into ONAP on Vagrant
itself.

Unit Testing
============

The **_tests_** folder contains ~~scripts~~ _test suites_ that ensure the proper
implementation of the _functions_ created on **_lib_** folder.  In order to
display the Usage information you must execute the script with question mark as
an argument like follows:

    $ ./tools/run.sh -?

or using PowerShell

    PS C:\> Set-ExecutionPolicy Bypass -Scope CurrentUser
    PS C:\> .\tools\Run.ps1 testing -?

Examples
--------

    $ ./tools/run.sh -y testing # Executes all the Unit Tests unattended mode
    $ ./tools/run.sh -s functions testing # Executes all the Unit Tests of Functions Test Suite
    $ ./tools/run.sh -s functions -c install_maven testing # Executes the install_maven Unit Test of Functions Test Suite
