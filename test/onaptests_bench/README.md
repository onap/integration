# onaptests_bench

Python module to launch pythonsdk-test dockers for stability testing

**Requirements**
<br/>
`pip install -r requirements.txt`

Python3.7+ is recommended for launching the tests.
<br/>

**How to use**
<br/>
Launch basic_* tests in parallel and report results
the possible basic tests are:
 - basic_onboarding
 - basic_vm
 - basic_vm_macro
 - basic_network
 - basic_cnf
 - ...
Example usage:

$ pip install git+https://gitlab.com/Orange-OpenSource/lfn/onap/integration/onaptests_bench.git
$ run_stability_tests
               -t < test >
               -s < nb simultaneous occurences >
               -d < duration (in mins for now)>
               -r < reporting path >
