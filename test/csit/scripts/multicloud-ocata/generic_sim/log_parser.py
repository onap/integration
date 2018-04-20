import argparse

import yaml


def _find_aai_response_content(inp):
    return inp.split("||||")[1].split("with response content = ")[1]

def _find_openstack_url(inp):
    return inp.split("||||")[1].split("making request with URI:")[1]

def _find_openstack_response_content(inp):
    return inp.split("||||")[1].split("with content:")[1].replace("u'", "'")

def _add_response(all_responses, url, http_verb, body, status_code=200, content_type="application/json"):
    if url not in all_responses.keys():
        all_responses[url] = {
            http_verb: {
                "status_code": status_code,
                "content_type": content_type,
                "body": body
            }
        }
    elif http_verb not in all_responses[url].keys():
        all_responses[url][http_verb] = {
            "status_code": status_code,
            "content_type": content_type,
            "body": body
        }

def parse_lines(content, aai_ip):
    aai_pattern = "https://%s:30233/" % aai_ip
    openstack_pattern = "making request with URI:"

    openstack_responses = {}
    aai_responses = {}
    for i, line in enumerate(content):
        current_line = line.strip()
        if aai_pattern in current_line and "DEBUG" not in current_line:
            url = current_line.split(" ")[8][:-1].replace(aai_pattern, "")
            _add_response(aai_responses, url, current_line.split(" ")[9][:-1],
                _find_aai_response_content(content[i + 3]))
        elif openstack_pattern in current_line:
            _add_response(openstack_responses,
                _find_openstack_url(current_line), "get",
                _find_openstack_response_content(content[i + 2]))

    return [
    { "file": "nova.yml", "responses": openstack_responses },
    { "file": "aai.yml", "responses": aai_responses }
    ]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert logs to responses YAML tree file.')
    parser.add_argument('--log-file', type=argparse.FileType('r'), help="Log file to be parsed", required=True)
    parser.add_argument('--aai-ip', help="A&AI IP Address", required=True)
    args = parser.parse_args()

    for mock_responses in parse_lines(args.log_file.readlines(), args.aai_ip):
        with open(mock_responses["file"], 'w') as yaml_file:
            yaml.dump(mock_responses["responses"], yaml_file, default_flow_style=False)
