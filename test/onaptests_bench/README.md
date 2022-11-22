# onaptests\_bench

Python module to launch pythonsdk-test dockers for stability testing

**Requirements** <br/>
`pip install -r requirements.txt`

Python3.7+ is recommended for launching the tests. <br/>

**How to use** <br/>
Launch basic\_\* tests in parallel and report results
the possible basic tests are:

- basic\_onboarding
- basic\_vm
- basic\_vm\_macro
- basic\_network
- basic\_cnf
- ...

  Example usage:

$ run\_stability\_tests
\-t < test >
\-s < nb simultaneous occurences >
\-d < duration (in mins for now)>
\-r < reporting path >
