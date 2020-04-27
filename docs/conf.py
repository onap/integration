from docs_conf.conf import *

branch = 'latest'
master_doc = 'index'

linkcheck_ignore = [
    r'http://localhost:\d+/',
    'http://CONSUL_SERVER_UI:30270/ui/#/dc1/services',
    r'https://.*h=frankfurt',
    r'http.*frankfurt.*',
    r'http.*simpledemo.onap.org.*',
    r'http://ANY_K8S_IP.*',
    'http://so-monitoring:30224',
    r'http://SINK_IP_ADDRESS:667.*',
    r'http.*K8S_HOST:30227.*',
    r'http.*K8S_NODE_IP.*'
]

intersphinx_mapping = {}

html_last_updated_fmt = '%d-%b-%y %H:%M'

def setup(app):
    app.add_stylesheet("css/ribbon_onap.css")
