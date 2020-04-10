## Guide for hpa_automation.py script in heat

These guide describes how to run the hpa_automation.py script. It can be used to run the vFW and vDNS end to end use cases.

## Prerequisites

- Install ONAP CLI. See [link](https://onap.readthedocs.io/en/dublin/submodules/cli.git/docs/installation_guide.html)
- Install python mysql.connector (pip install mysql-connector-python)
- Must have connectivity to the ONAP, a k8s vm already running is recommended as connectivity to the ONAP k8s network is required for the SDC onboarding section.
- Create policies for homing using the temp_resource_module_name specified in hpa_automation_config.json. Sample policies can be seen in the sample_vfw_policies directory. Be sure to specify the right path to the directory in hpa_automation_config.json, only policies should exist in the directory
- Create Nodeport for Policy pdp using the pdp_service_expose.yaml file (copy pdp_service_expose.yaml in hpa_automation/heat to rancher and run kubectl apply -f pdp_expose.yaml)
- Put in the CSAR file to be used to create service models and specify its path in hpa_automation_config.json
- Modify the SO bpmn configmap to change the SO vnf adapter endpoint to v2. See step 4 [here](https://onap.readthedocs.io/en/casablanca/submodules/integration.git/docs/docs_vfwHPA.html#docs-vfw-hpa)
- Prepare sdnc_preload file and put in the right path to its location in hpa_automation_config.json 
- Put in the right parameters for automation in hpa_automation_config.json
- Ensure the insert_policy_models_heat.py script is in the same location as the hpa_automation.py script as the automation scripts calls the insert_policy_models_heat.py script.

**Points to Note:**

1. The hpa_automation.py runs end to end. It does the following;
   - Create cloud complex
   - Register cloud regions
   - Create service type
   - Create customer and adds customer subscription
   - SDC Onboarding (Create VLM, VSP, VF Model, and service model)
   - Upload policy models and adds policies
   - Create Service Instance and VNF Instance
   - SDNC Preload and Creates VF module
2. There are well named functions that do the above items every time the script is run. If you do not wish to run any part of that, you can go into the script and comment out the section at the bottom that handles that portion.
