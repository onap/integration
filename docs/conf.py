from docs_conf.conf import *

branch = 'latest'
master_doc = 'index'

doc_url = 'https://docs.onap.org/projects'

linkcheck_ignore = [
    r'http://localhost:.*',
    'http://CONSUL_SERVER_UI:30270/ui/#/dc1/services',
    r'https://.*h=frankfurt',
    r'http.*frankfurt.*',
    r'http.*simpledemo.onap.org.*',
    r'http://ANY_K8S_IP.*',
    'http://so-monitoring:30224',
    r'http://SINK_IP_ADDRESS:667.*',
    r'http.*K8S_HOST:30227.*',
    r'http.*K8S_NODE_IP.*',
    'http://team.onap.eu'
]

intersphinx_mapping = {}
intersphinx_mapping['onap-oom'] = ('{}/onap-oom/en/%s'.format(doc_url) % branch, None)

html_last_updated_fmt = '%d-%b-%y %H:%M'

def setup(app):
    app.add_css_file("css/ribbon.css")
