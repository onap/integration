# NETCONF Plug-and-Play Simulator

Instead of a single docker image aggregating all Yang models and simulation logic, this simulator uses a modular
approach that is reflected on this directory structure:

- engine: Contains only the core NETCONF engine and files required to build the
  docker image;
- modules: The modules containing the Yang models and its corresponding
  applications goes here.
