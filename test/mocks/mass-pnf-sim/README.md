### Mass PNF simulator

The purpose of this simulator is to mimic the PNF for benchmark purposes.
This variant is based on the PNF simulator and use several components.
The modification are focusing on the following areas:

- add a script configuring and governing multiple instances of PNF simualtor
- removing parts which are not required for benchmark purposes.
- add functionality which creates and maintains the ROP files
- add functionality to query the actual ROP files and construct VES events based on them

### Pre-configuration

The ipstart should align to a /28 Ip address range start (e.g. 10.11.0.16, 10.11.0.32)

For debug purposes, you can use your own IP address as VES collector, use "ip" command to determine it.

Run ./setup.sh to create pre-set Python virtualenv with all required dependencies for the scripts.

### Build simulator image

```
./mass-pnf-sim.py build
```

### Bootstrap simulator instances

```
./mass-pnf-sim.py bootstrap --count 2 --urlves http://10.148.95.??:10000/eventListener/v7 --ipfileserver 10.148.95.??? --typefileserver sftp --ipstart 10.11.0.16
```

Note that the file creator is started at a time of the bootstrapping.
Stop/start will not re-launch it.

### Replacing VES for test purposes

```
sudo nc -vv -l -k -p 10000
```

### Start all bootstrapped instances

```
./mass-pnf-sim.py start
```

### Trigger

```
./mass-pnf-sim.py trigger
```

### Trigger only a subset of the simulators

The following command will trigger 0,1,2,3:

```
./mass-pnf-sim.py trigger-custom --triggerstart 0 --triggerend 3
```

The following command will trigger 4 and 5:

```
./mass-pnf-sim.py trigger-custom --triggerstart 4 --triggerend 5
```

### Stop sending PNF registration messages from simulators

```
./mass-pnf-sim.py stop_simulator
```

### Stop docker containers and clean bootstrapped simulators

```
./mass-pnf-sim.py stop
./mass-pnf-sim.py clean
```

### Verbose printout from Python

```
python3 -m trace --trace --count -C . ./mass-pnf-sim.py .....
```

### Cleaning and recovery after incorrect configuration

```
./clean.sh
```
