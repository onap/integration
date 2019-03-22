### Mass PNF simulator
The purpose of this simulator is to mimic the PNF for benchmark purposes.
This variant is based on the PNF simulator and use several components.
The modification are focusing on the following areas:
    -add a script configuring and governing multiple instances of PNF simualtor
    -removing parts which are not required for benchmark purposes.
    -add functionality which creates and maintains the ROP files
    -add functionality to query the actual ROP files and construct VES events based on them



###Pre-configuration
The ipstart should align to a /28 Ip address range start (e.g. 10.11.0.16, 10.11.0.32)

For debug purposes, you can use your own IP address as VES collector, use "ip" command to determine it.

Example:
./mass-pnf-sim.py  --bootstrap 2 --ipves http://10.148.95.??:10000 --ipfileserver 10.148.95.??? --ipstart 10.11.0.16

###Replacing VES for test purposes
`sudo nc -vv -l -k -p 10000`

###Start
Define the amount of simulators to be launched
./mass-pnf-sim.py  --start 2

###Trigger 
./mass-pnf-sim.py  --trigger 2

###Stop and clean
./mass-pnf-sim.py  --stop 2
./mass-pnf-sim.py  --clean

###Cleaning and recovery after incorrect configuration
docker stop $(docker ps -aq); docker rm $(docker ps -aq)
