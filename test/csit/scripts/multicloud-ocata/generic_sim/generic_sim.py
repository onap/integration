# Copyright 2018 Intel Corporation, Inc
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import json
import logging

import web
from web import webapi
import yaml

urls = (
  '/(.*)','MockController'
)

def setup_logger(name, log_file, level=logging.DEBUG):
    handler = logging.FileHandler(log_file)
    formatter = logging.Formatter('%(message)s')
    handler.setFormatter(formatter)

    logger = logging.getLogger(name)
    logger.setLevel(level)
    logger.addHandler(handler)

    return logger


class MockResponse:
    def __init__(self, http_verb, status_code, content_type="application/json", body="{}"):
        self.http_verb = http_verb
        self.status_code = status_code
        self.content_type = content_type
        self.body = body

def _get_path(root, site_tree):
    try:
        first_subpath = site_tree.keys()[0]
        return _get_path(root + first_subpath + "/", site_tree[first_subpath])
    except AttributeError:
        mock_responses = []
        for response in site_tree:
            mock = MockResponse(response.keys()[0], **response[response.keys()[0]])
            mock_responses.append(mock)
        return root[:-1], mock_responses
    except:
        return root[:-1], []

def _remove_path(path, site_tree):
    if len(path) == 1:
       site_tree.pop(path[0])
    else:
       _remove_path(path[1:], site_tree[path[0]])

def _parse_responses(parsed_responses):
    result = {}
    while parsed_responses:
        path, responses = _get_path("", parsed_responses)
        _remove_path(path.split("/"), parsed_responses)
        result[path] = responses
    return result

def get_responses(filename):
    with open(filename) as yaml_file:
        responses_file = yaml.safe_load(yaml_file)
    responses_map = _parse_responses(responses_file)
    return responses_map

def get_response(url, http_verb):
    responses = [ r for r in responses_map[url] if r.http_verb == http_verb]
    return responses[0]




class MockController:
    def POST(self, url):
        logger.info('{}'.format(web.ctx.env.get('wsgi.input').read()))
        try:
            response = get_response(url, "post")
            web.header('Content-Type', response.content_type)
            return response.body
        except:
            webapi.NotFound()

    def GET(self, url):
        try:
            response = get_response(url, "get")
            web.header('Content-Type', response.content_type)
            return response.body
        except:
            webapi.NotFound()


logger = setup_logger('mock_controller', '/tmp/generic_sim.log')
responses_map = get_responses('/opt/generic_sim/responses.yml')
app = web.application(urls, globals())
if __name__ == "__main__":
    app.run()
