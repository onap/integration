## PNF/NETCONF SIMULATOR CLI

### Overview
Anytime you want to see a basic usage of a tool, you can run fully descriptive help using command:
```
./{tool_name}.py -h # --help argument is also acceptable  
```   

#### PNF Simulator CLI
PNF Simulator CLI provides command line interface to remotely interact with running PNF Simulator. 

Using the PNF Simulator CLI user is able to trigger events, retrieve simulator's configuration and change default VES url stored 
inside simulator.   

#### Netconf Simulator CLI
Dedicated tool to help with management of the Netconf Server is also available. 

Using the Netconf Simulator CLI user is able to retrieve simulator's cm history stored inside simulator as well as open the live session to actively listen for new configuration changes.   

### Requirements and installation
Requirements
* Python > 3.5 

Installation:
* Go to directory containing setup.py and invoke `python setup.py install`
* Go to cli directory
* Add executable privilege to pnf_simulator.py and netconf_simulator.py (for example `chmod +x <path_to_pnf_simulator.py>`)

### Pnf simulator
#### Usage
* [send](#send-action)
* [configure](#configure-action)
* [get-config](#get-config-action)
* [template](#template-action)
* [filter](#filter-templates-action)


#### Help
Invoke `pnf_simulator.py [send|configure|get-config] -h` to display help.

##### Send Action
Send action allows user to trigger sending events from Simulator to VES Collector.  

*sending repeating events backed by template persisted in db
`usage: pnf_simulator.py send template  [-h] --address ADDRESS  --name NAME
                                        [--patch PATCH] [--repeats REPEATS]
                                        [--interval INTERVAL]
                                        [--ves-server-url VES_SERVER_URL] [--verbose]
`

Parameters  
`  --address ADDRESS`               `IP address of simulator`  
`  --name NAME`                     `Name of template file which should be used as a base for event.
                                     Cannot be used simultaneously with parameter: event.`    
`  --patch PATCH`                   `Json which should be merged into template to override parameters.
                                     Acceptable format: valid json wrapped using single quotes (example:'{"abc":1}').
                                     Cannot be used simultaneously with parameter: event.`      
`  --repeats REPEATS`               `Number of events to be send`  
`  --interval INTERVAL`             `Interval between two consecutive events (in seconds)`  
`  --ves-server-url VES_SERVER_URL` `Well-formed URL which will override current VES endpoint stored in simulator's DB`  
`  --verbose`                       `Displays additional logs`  


*sending event only once by passing path to file with complete event
`usage: pnf_simulator.py send event [-h] --address ADDRESS --filepath FILEPATH
                                    [--ves-server-url VES_SERVER_URL] [--verbose]
`
Parameters  
`  --address ADDRESS`               `IP address of simulator`  
`  --filepath FILEPATH`             `Path to file with full, legitimate event that is to be send directly to VES only once.
                                     This event is not associated with template and will not be persisted in db. 
                                     Cannot be used simultaneously with parameters: template and patch.`
`  --ves-server-url VES_SERVER_URL` `Well-formed URL which will override current VES endpoint stored in simulator's DB`  
`  --verbose`                       `Displays additional logs`

example content of file with complete event:
```
{
  "commonEventHeader": {
    "eventId": "#Timestamp",
    "sourceName": "#Increment",
    "version": 3.0
    }
}
```

##### Configure Action
Configure action allows user to change Simulator's configuration (VES Server URL)  
`usage: pnf_simulator.py configure [-h] --address ADDRESS --ves-server-url
                                   VES_SERVER_URL [--verbose]
`  

Parameters  

`  --address ADDRESS`               `IP address of simulator`  
`  --ves-server-url VES_SERVER_URL` `Well-formed URL which should be set as a default VES Server URL in simulator`  
`  --verbose`                       `Displays additional logs`

##### Get Config Action
Get Config action allows user to retrieve actual Simulator's configuration  
`usage: pnf_simulator.py get-config [-h] --address ADDRESS [--verbose] `  

Parameters

`--address ADDRESS`           `IP address of simulator`  
`--verbose`                   `Displays additional logs`

##### Template Action
Template action allows user to:
* retrieve a single template by name
* list all available templates. 
* upload template to PNF Simulator (can overwrite existing template)

`usage: pnf_simulator.py template [-h]
                                  (--list | --get-content NAME | --upload FILENAME)
                                  [--override] --address ADDRESS [--verbose]`  

Parameters

`--get-content NAME`        `Gets the template by name`  
`--list`                    `List all templates`  
`--upload FILENAME [--override]` `Uploads the template given as FILENAME file. Optionally overrides any exisitng templates with matching filename`  
`--address ADDRESS`         `IP address of simulator`    
`--verbose`                 `Displays additional logs`   

#### Filter Templates Action
Filter template action allows to search through templates in order to find names of those that satisfy given criteria. 
Criteria are passed in JSON format, as key-values pairs. Relation between pairs with criteria is AND (all conditions must be satisfied by template to have it returned).
No searching for null values is supported.
Search expression must be valid JSON, thus no duplicate keys are allowed - user could specify the same parameter multiple times, but only last occurrence will be applied to query.


`usage: pnf_simulator.py filter  [-h]
                                 --criteria CRITERIA --address ADDRESS [--verbose]`
                                 
Parameters
`--criteria CRITERIA`       `Json with criteria as key-value pairs, where values can be one of following data types: string, integer, double, boolean. 
                             Acceptable format: valid json wrapped using single quotes (example:'{"searchedInt":1}').
                             Cannot be used simultaneously with parameter: event.`      
`--address ADDRESS`         `IP address of simulator`    
`--verbose`                 `Displays additional logs`


### Netconf simulator
#### Usage
* [load-model](#load-model-action)
* [delete-model](#delete-model-action)
* [get-config](#get-config-action)
* [edit-config](#edit-config-action)
* [tailf](#tailf-action)
* [less](#less-action)
* [cm-history](#cm-history-action)

#### Help
Invoke `netconf_simulator.py [tailf|less|cm-history] -h` to display help.


#### Load-model action
Loads to netconf server new YANG model that corresponds with schema passed as yang-model parameter, 
assigns name specified in module-name and initializes model with startup configuration passed in config file.  
`usage: netconf_simulator.py load-module [-h] --address ADDRESS ---module-name MODULE_NAME --yang-model YANG_MODEL_FILEPATH --config <XML_CONFIG_FILEPATH> [--verbose]`

example YANG schema (file content for YANG_MODEL)
```
Response status: 200
module pnf-simulator {
  namespace "http://nokia.com/pnf-simulator";
  prefix config;
  container config {
    config true;
    leaf itemValue1 {type uint32;}
    leaf itemValue2 {type uint32;}
    leaf itemValue3 {type uint32;}
    leaf-list allow-user {
      type string;
      ordered-by user;
      description "A sample list of user names.";
    }
  }
}
```

example startup configuration (file content of XML_CONFIG)
```
<config xmlns="http://nokia.com/pnf-simulator">
  <itemValue1>100</itemValue1>
  <itemValue2>200</itemValue2>
  <itemValue3>300</itemValue3>
</config>
```  


example output (without verbose flag):
```
Response status: 200
Successfully started
```

#### Delete-model action
Deletes a YANG model loaded in the netconf server. 

`usage: netconf_simulator.py delete-model [-h] --address ADDRESS --model-name
                                         MODEL_NAME [--verbose]`
                                         
Example output (without verbose flag):
```
Response status: 200
Successfully deleted
```

#### Get-config Action
Returns active running configurations.
By default it returns all running configurations. To retrieve one specific configuration (represented by _/'module_name':'container'_ ) user needs to pass module-name and container.  
Example:  
`
netconf_simulator.py get-config --address localhost --module-name pnf-simulator --container config
`


`usage: netconf_simulator.py get-config [-h] --address ADDRESS [--verbose] [--module-name MODULE-NAME] [--container CONTAINER]`

example output (without verbose flag):
```
Response status: 200
<config xmlns="http://nokia.com/pnf-simulator" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
  <itemValue1>2781</itemValue1>
  <itemValue2>3782</itemValue2>
  <itemValue3>3333</itemValue3>
</config>
```

#### Edit-config Action
Modifies existing configuration (e.g. change parameter values, modify or remove parameter from model).
To edit configuration, netconf compliant XML file should be prepared and used as one of edit-config parameters.  
`usage: netconf_simulator.py edit-config [-h] --address ADDRESS --config <XML_CONFIG_FILEPATH> [--verbose]`

example - parameter values modification
file content:
```
<config xmlns="http://nokia.com/pnf-simulator">
  <itemValue1>1</itemValue1>
  <itemValue2>2</itemValue2>
  <itemValue3>3</itemValue3>
</config>
```

example output (without verbose flag):
```
Response status: 202
<config xmlns="http://nokia.com/pnf-simulator" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
  <itemValue1>1</itemValue1>
  <itemValue2>2</itemValue2>
  <itemValue3>3</itemValue3>
</config>
```  

##### Less Action
Less action allows user to watch historical configuration changes. 
Size of the configuration changes list is limited to the 100 last cm events by default, but can be incresed/decresead using a 'limit' attribute.
`usage: netconf_simulator.py less [-h] --address ADDRESS  [--limit LIMIT] [--verbose]`  

Output from the command can be easily piped into other tools like native less, more, etc. e.g.:
`netconf_simulator.py less --address 127.0.0.1 | less`

Last known configuration is last printed to the output, so order of the printed configuration events complies with time when the configuration was stored inside the simulator. 

Parameters:

`--address ADDRESS`  - `IP address of simulator`

`--limit LIMIT`  - ` Number of configurations to print at output`   

`--verbose`  - ` Displays additional logs`  

Single message is represented as a pair of timestamp in epoch format and suitable configuration entry.

##### Tailf Action
Tailf action allows user to actively listen for new uploaded configuration changes. 
Size of the historical configuration changes list is limited to the 10 last cm events.
`usage: netconf_simulator.py tailf [-h] --address ADDRESS [--verbose]`  

The listener can be easily terminated at anytime using `CTRL+C` shortcut.  

Parameters:

`--address ADDRESS`  - `IP address of simulator`

`--verbose`  - ` Displays additional logs`  

Single message is represented as a pair of timestamp in epoch format and suitable configuration entry.

##### Cm-history Action
Cm-history action allows user to view list of all uploaded configuration changes. 
`usage: netconf_simulator.py cm-history [-h] --address ADDRESS [--verbose]`  

Last known configuration is last printed to the output, so order of the printed configuration events complies with time when the configuration was stored inside the simulator.

Parameters:

`--address ADDRESS`  - `IP address of simulator`

`--verbose`  - ` Displays additional logs`  

Single message is represented as a pair of timestamp in epoch format and suitable configuration entry.
